rule minimap2:
    input:
        config["results"]["bam_dir"]
    output:
        temp(directory(config["results"]["minimap2"]["temp_dir"])) # Deleted once every rule requiring it has been executed successfully
    conda:
        "../envs/minimap2.yaml"
    params:
        data_type=config["input_files"]["data"]["type"],
        reference_path=config["input"]["reference"]["path"]
    log:
        config["logs"]["minimap2"]
    shell:
        """
        {{
            if [ '{params.data_type}' == 'ONT' ]; then
                map_type='map-ont'
            elif [ '{params.data_type}' == 'PacBio' ]; then
                map_type='map-hifi'
            else
                echo 'Input data type not set'
                exit 1
            fi

            mkdir -p '{output}'

            for uBAM in '{input}'/*.bam; do
                [ -e "$uBAM" ] || continue

                filename_with_extension="$(basename "$uBAM")"
                filename_without_extension="${{filename_with_extension%.*}}"

                samtools fastq -TMM,ML "$uBAM" | \
                minimap2 -ax "$map_type" -t "$(nproc)" -y --secondary=no '{params.reference_path}' - > "{output}/$filename_without_extension.sam"
            done
        }} &> {log}
        """

rule filter_samtools:
    input:
        config["results"]["minimap2"]["temp_dir"]
    output:
        directory(config["results"]["minimap2"]["filtered_dir"])
    conda:
        "../envs/samtools.yaml"
    log:
        config["logs"]["filter_samtools"]
    shell:
        """
        {{
            mkdir -p '{output}'

            for sam in '{input}'/*.sam; do
                [ -e "$sam" ] || continue

                filename_with_extension="$(basename "$sam")"
                filename_without_extension="${{filename_with_extension%.*}}"
                flagstat="$filename_without_extension.flagstat"
                sort_bam="$filename_without_extension.mapq20.sort.bam"
                sort_depth="$filename_without_extension.mapq20.sort.depth"
                sort_coverage="$filename_without_extension.mapq20.sort.coverage"
                sort_flagstat="$filename_without_extension.mapq20.sort.flagstat"
                
                samtools flagstat "$sam" > "{output}/$flagstat"
                samtools view -h -q 20 -b -@ "$(nproc)" "$sam" | samtools sort -@ "$(nproc)" -o "{output}/$sort_bam"
                samtools depth "{output}/$sort_bam" > "{output}/$sort_depth"
                samtools coverage "{output}/$sort_bam" > "{output}/$sort_coverage"
                samtools flagstat "{output}/$sort_bam" > "{output}/$sort_flagstat"
            done
        }} &> {log}
        """     
