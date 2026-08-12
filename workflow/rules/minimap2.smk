rule minimap2:
    input:
        config["results"]["bam_dir"]
    output:
        temp(directory(config["results"]["minimap2"]["temp_dir"])) # Deleted once every rule requiring it has been executed successfully
    conda:
        "../envs/main.yaml"
    params:
        data_type=config["input_files"]["data"]["type"],
        default_reference_path=config["input"]["default_reference"]["path"],
        reference_map=None if config["input_files"]["minimap2"]["barcode_reference_filename"] is None else lambda w: " ".join(f"{k}:{v}" for k, v in config["input_files"]["minimap2"]["barcode_reference_filename"].items()),
        parent_directory=config["input"]["references_dir"]
    log:
        config["logs"]["minimap2"]
    shell:
        """
        {{
            source workflow/scripts/get_matched_value.sh

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

                matched_reference_path="$(get_matched_value "$filename_without_extension" '{params.reference_map}' '{params.parent_directory}' '{params.default_reference_path}')"

                samtools fastq -TMM,ML "$uBAM" | \
                minimap2 -ax "$map_type" -t "$(nproc)" -y --secondary=no "$matched_reference_path" - > "{output}/$filename_without_extension.sam"
            done
        }} &> {log}
        """

rule filter_samtools:
    input:
        config["results"]["minimap2"]["temp_dir"]
    output:
        directory(config["results"]["minimap2"]["filtered_dir"])
    conda:
        "../envs/main.yaml"
    params:
        default_index_path=config["input"]["default_index"]["path"],
        index_map=None if config["input_files"]["minimap2"]["barcode_index_filename"] is None else lambda w: " ".join(f"{k}:{v}" for k, v in config["input_files"]["minimap2"]["barcode_index_filename"].items()),
        parent_directory=config["input"]["references_dir"],
        mapping_quality=config["tool_specific_params"]["minimap2"]["mapping_quality"]
    log:
        config["logs"]["filter_samtools"]
    shell:
        """
        {{
            source workflow/scripts/get_matched_value.sh

            mkdir -p '{output}'

            for sam in '{input}'/*.sam; do
                [ -e "$sam" ] || continue

                matched_index_path="$(get_matched_value "$sam" "{params.index_map}" "{params.parent_directory}" "{params.default_index_path}")

                filename_with_extension="$(basename "$sam")"
                filename_without_extension="${{filename_with_extension%.*}}"
                sort_bam="$filename_without_extension.sort.bam"
                sort_bai="$filename_without_extension.sort.bai"
                flagstat="$filename_without_extension.flagstat"
                sort_flagstat="$filename_without_extension.sort.flagstat"
                sort_coverage="$filename_without_extension.sort.coverage"

                samtools_view_command='samtools view -h -q "{params.mapping_quality}" -b -@ "$(nproc)"'
                if [ "$matched_index_path" != 'None' ]
                then
                    samtools_view_command+=' -t "$matched_index_path"'
                fi
                samtools_view_command+=' "$sam" | samtools sort -@ "$(nproc)" -o "{output}/$sort_bam"'
                
                samtools_flagstat_command='samtools flagstat -@ "$(nproc)"'
                if [ "$matched_index_path" != 'None' ]
                then
                    samtools_flagstat_command+=' --input-fmt-option reference="$matched_index_path"'
                fi
                samtools_flagstat_command+=' "$sam" > "{output}/$flagstat"'
                
                eval "$samtools_view_command"
                samtools index -@ "$(nproc)" -o "{output}/$sort_bai" "{output}/$sort_bam"
                eval "$samtools_flagstat_command"
                samtools flagstat -@ "$(nproc)" "{output}/$sort_bam" > "{output}/$sort_flagstat"
                samtools coverage "{output}/$sort_bam" > "{output}/$sort_coverage"
                
            done
        }} &> {log}
        """     
