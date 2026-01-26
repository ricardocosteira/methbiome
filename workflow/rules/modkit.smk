my_output = directory(config["results"]["modkit"]["dir"])
if config["tabix"]:
    my_output = temp(my_output)

rule modkit:
    input:
        config["results"]["minimap2"]["filtered_dir"]
    output:
        my_output
    conda:
        "../envs/modkit.yaml"
    params:
        data_type=config["input_files"]["data"]["type"],
        minimum_methylation_likelihood=config["tool_specific_params"]["modkit"]["minimum_methylation_likelihood"]
    log:
        config["logs"]["modkit"]
    shell:
        """
        {{            
            for aBAM in '{input}'/*.sort.bam; do
                [ -e "$aBAM" ] || continue

                filename_with_extension="$(basename "$aBAM")"
                filename_without_extension="${{filename_with_extension%.*}}"
                input_bam="$aBAM"

                if [ '{params.data_type}' == 'PacBio' ]; then
                    explicit_bam="$input_bam_explicit.bam"
                    modkit modbam update-tags -t "$(nproc)" -m explicit $input_bam "$explicit_bam"

                    input_bam="$explicit_bam"
                fi

                samtools index "$input_bam"

                modkit pileup -t "$(nproc)" --filter-threshold '{params.minimum_methylation_likelihood}' --header "$input_bam" "{output}/$filename_without_extension.bed"
            done
        }} &> {log}
        """
