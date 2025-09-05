rule bam_to_fastq_gz:
    input:
        config["results"]["bam_dir"]
    output:
        directory(config["results"]["fastq_gz_dir"])
    conda:
        "../envs/samtools.yaml"
    log:
        config["logs"]["bam_to_fastq_gz"]
    shell:
        """
        {{
            mkdir -p '{output}'

            for uBAM in '{input}'/*.bam; do
                [ -e "$uBAM" ] || continue

                filename_with_extension="$(basename "$uBAM")"
                filename_without_extension="${{filename_with_extension%.*}}"
                
                samtools fastq "$uBAM" | gzip > "{output}/$filename_without_extension.fastq.gz"
            done
        }} &> {log}
        """
