#!/usr/bin/env python3

import argparse
from datetime import datetime
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
import pysam
import seaborn as sns


MODIFICATIONS = ["6mA", "5mC", "4mC"]


def plot_bedmethyl_region(
    bgz_file, contig, start, end, sample_name, modifications, output_file=None
):
    with pysam.TabixFile(str(bgz_file)) as tbx:
        records = []
        try:
            for row in tbx.fetch(contig, start, end):
                records.append(row.split("\t"))
        except ValueError as e:
            print(f"Region or contig error: {e}")
            return

    if not records:
        print(f"No methylation data found in region {contig}:{start}-{end}")
        return

    columns = ["Contig", "Pos", "ModBase", "Strand", "ValidCov", "PercentModified"]

    df = pd.DataFrame(records)
    df = df.iloc[:, [0, 2, 3, 5, 9, 10]]
    df.columns = columns

    df["Pos"] = df["Pos"].astype(int)
    df["ValidCov"] = df["ValidCov"].astype(int)
    df["PercentModified"] = df["PercentModified"].astype(float)

    df["ModBase"] = df["ModBase"].replace({
        "a": "6mA",
        "m": "5mC",
        "21839": "4mC",
    })

    df = df[df["ModBase"].isin(modifications)]
    if df.empty:
        print(
            f"No data found for the selected modification(s) "
            f"in {contig}:{start}-{end}"
        )
        return

    palette = {"6mA": "red", "5mC": "blue", "4mC": "green"}

    sns.set_theme(style="whitegrid")
    fig, ax1 = plt.subplots(figsize=(12, 5))

    ax1.set_xlabel(
        f"Base position on {contig}:{start}-{end} (bp)",
        fontsize=12,
        fontweight="bold",
    )
    ax1.set_ylabel("Proportion of DNAm (%)", fontsize=12, fontweight="bold")

    sns.scatterplot(
        data=df,
        x="Pos",
        y="PercentModified",
        size="ValidCov",
        sizes=(1, 20),
        hue="ModBase",
        hue_order=[mod for mod in MODIFICATIONS if mod in modifications],
        palette=palette,
        ax=ax1,
        legend="brief",
    )

    ax1.set_ylim(-5, 105)
    ax1.legend(title="Legend", loc="upper left")

    plt.title(
        f"DNA Methylation Profile in {sample_name}",
        fontsize=14,
        fontweight="bold",
    )
    plt.tight_layout()

    if output_file is not None:
        fig.savefig(output_file, format="pdf")
        print(f"Plot saved to: {output_file}")

    plt.close(fig)


def main():
    parser = argparse.ArgumentParser(
        description="Plot methylation data for a region from a tabix-indexed bedMethyl file."
    )
    parser.add_argument("file", type=Path, help="Path to the tabix-indexed input file")
    parser.add_argument("contig", help="Contig or chromosome name")
    parser.add_argument("start", type=int, help="Region start coordinate")
    parser.add_argument("end", type=int, help="Region end coordinate")
    parser.add_argument(
        "sample_name",
        nargs="?",
        default="Sample",
        help="Optional sample name used in the plot title and output filename",
    )
    parser.add_argument(
        "--modifications",
        nargs="+",
        choices=MODIFICATIONS,
        default=MODIFICATIONS,
        help="Modification type(s) to plot; defaults to all: 6mA 5mC 4mC",
    )

    args = parser.parse_args()

    if not args.file.is_file():
        parser.error(f"Input file does not exist: {args.file}")
    if args.start < 0 or args.end <= args.start:
        parser.error("Coordinates must satisfy: 0 <= start < end")

    output_dir = Path.cwd() / f"methylation_plot_{datetime.now():%Y%m%d_%H%M%S}"
    output_dir.mkdir(parents=True, exist_ok=True)

    mods_label = "_".join(args.modifications)
    output_file = output_dir / (
        f"{args.sample_name}_{args.contig}_{args.start}_{args.end}_{mods_label}.pdf"
    )

    plot_bedmethyl_region(
        args.file,
        args.contig,
        args.start,
        args.end,
        args.sample_name,
        args.modifications,
        output_file=output_file,
    )


if __name__ == "__main__":
    main()
