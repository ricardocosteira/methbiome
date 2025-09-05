rule sequali:
    input:
        config["results"]["bam_dir"]
    output:
        directory(config["results"]["qc"]["sequali"]["dir"])
    conda:
        "../envs/sequali.yaml"
    log:
        config["logs"]["sequali"]
    shell:
        """
        {{
            mkdir -p '{output}'

            for uBAM in '{input}'/*.bam; do
                [ -e "$uBAM" ] || continue

                filename_with_extension="$(basename "$uBAM")"
                filename_without_extension="${{filename_with_extension%.*}}"
                sequali -t "$(nproc)" --html "$filename_without_extension.html" --json "$filename_without_extension.json" "$uBAM" --outdir '{output}'
            done
        }} &> {log}
        """

rule multiqc:
    input:
        config["results"]["qc"]["sequali"]["dir"]
    output:
        config["results"]["qc"]["multi_qc_report_path"]
    conda:
        "../envs/multiqc.yaml"
    log:
        config["logs"]["sequali"]
    shell:
        """
        {{
            multiqc '{input}' --force --filename '{output}'
        }} &> {log}
        """
