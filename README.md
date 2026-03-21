# methbiome

Bioinformatic pipeline for the DNA methylation analysis of microbiomes. Reads in ONT and PacBio-generated data.

## I. Environment dependencies

### A. SLURM profile

This pipeline was built for execution with SLURM but can be easily adapted to other environments. To do so, you edit [`environment/config.yaml`](environment/config.yaml).

### B. CUDA

Basecalling with dorado relies on CUDA, which is loaded by the command `module load cuda`. You might need to change this command.

### C. Dorado for Linux x64

In this project, the dorado version we use is for Linux x64. For other environments, change the download link in the `install_dorado` rule.

## II. Set up

### A. Miniforge

Install [miniforge](https://conda-forge.org/download).

### B. Snakemake

See [snakemake installation](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html).

### C. Slurm plugin

```bash
pip install snakemake-executor-plugin-slurm
```

## III. Usage

### A. Download methbiome

```bash
git clone https://github.com/ricardocosteira/methbiome
```

### B. Configuration

- Place the ONT or PacBio files in a subdirectory of `resources`. Please avoid naming it with spaces and special characters (other than '-' and '_').
- Set parameters in [`config/config.yaml`](config/config.yaml) and resources in [`environment/config.yaml`](environment/config.yaml).

### C. Pipeline execution

#### 1. Execution of the entire pipeline

Open a tmux session so that snakemake can continue running in the background. Then, run the following command.

```bash
./run.sh
```

#### 2. Execution of part of the pipeline

Open a tmux session so that snakemake can continue running in the background. Then, replace `rule_name` in the following command and run it. 

This will run the pipeline up to the rule named `rule_name`, meaning that all rules on which `rule_name` depends are also executed.

```bash
snakemake --profile environment rule_name
```

### 3. Post-scripts

This is useful if you want to combine data from multiple samples.

Make sure you are in the `post-scripts` directory.

```bash
cd post-scripts
```

#### a. Combine MultiQC

Run the following command, where `<directory1>`, `<directory2>`, ... are directories containing MultiQC outputs.

```bash
./combine_multiqc.sh <directory1> <directory2> <directoryn>
```

#### b. Combine MPA reports

Run the following command, where `<directory1>`, `<directory2>`, ... are directories containing kraken2 MPA reports.

```bash
./combine_mpas.sh <directory1> <directory2> <directoryn>
```
