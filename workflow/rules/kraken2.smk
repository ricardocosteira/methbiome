rule kraken2:
    input:
        kraken2_db_dir=config["resources"]["kraken2_db"]["dir"],
        fastq_gz_dir=config["results"]["fastq_gz_dir"]
    output:
        directory(config["results"]["kraken2"]["dir"]),
    conda:
        "../envs/kraken2.yaml"
    params:
        kraken2_db_dir=config["resources"]["kraken2_db"]["dir"]
    log:
        config["logs"]["kraken2"]
    shell:
        """
        {{
            mkdir -p '{output}'

            for fastq_gz in '{input.fastq_gz_dir}'/*.fastq.gz; do
                [ -e "$fastq_gz" ] || continue
                
                filename_with_extension="$(basename "$fastq_gz")"
                filename_without_extension="${{filename_with_extension%.*}}"
                report_path="{output}/$filename_without_extension.kreport2"

                kraken2 --threads "$(nproc)" \
                    --db '{params.kraken2_db_dir}' \
                    --report "$report_path" \
                    --gzip-compressed "$fastq_gz" \
                    --output "{output}/$filename_without_extension.kraken2"

                kreport2mpa.py \
                    -r "$report_path" \
                    -o "$report_path.mpa" \
                    --intermediate-ranks --display-header
            done
        }} &> {log}
        """

rule kraken2_mpa:
    input:
        config["results"]["kraken2"]["dir"],
    output:
        config["results"]["kraken2"]["kraken2_mpa_path"]
    conda:
        "../envs/kraken2.yaml"
    log:
        config["logs"]["kraken2_mpa"]
    shell:
        """
        {{
            combine_mpa.py -i '{input}'/*.mpa -o '{output}'
        }} &> {log}
        """
