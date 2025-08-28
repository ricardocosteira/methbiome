rule genomad:
    input:
        fastq_gz_dir=config["results"]["fastq_gz_dir"],
        genomad_installed=config["resources"]["genomad"]["installed"],
        genomad_db=config["resources"]["genomad"]["db_dir"]
    output:
        directory(config["results"]["genomad"]["dir"]),
    conda:
        "../envs/genomad.yaml"
    params:
        fasta_dir=config["resources"]["genomad"]["fasta_dir"]
    log:
        config["logs"]["genomad"]
    shell:
        """
        {{
            mkdir -p '{output}'
            mkdir -p '{params.fasta_dir}'

            for fastq_gz in '{input.fastq_gz_dir}'/*.fastq.gz; do
                [ -e "$fastq_gz" ] || continue
                
                filename_with_extension="$(basename "$fastq_gz")"
                filename_without_extension="${{filename_with_extension%.fastq.gz}}"
                fasta_path="{params.fasta_dir}/$filename_without_extension.fasta"

                # Convert fastq.gz to fasta
                gunzip -c "$fastq_gz" |  awk '{{if(NR%4==1) {{printf(">%s\n",substr($0,2));}} else if(NR%4==2) print;}}' > "$fasta_path" # Double curly brackets escape a single curly bracket

                genomad end-to-end --cleanup --restart --threads "$(nproc)" --composition metagenome "$fasta_path" "{output}/$filename_without_extension_genomad" '{input.genomad_db}'
                
                rm -f "$fasta_path"
            done

            rm -rf '{params.fasta_dir}'
        }} &> {log}
        """
