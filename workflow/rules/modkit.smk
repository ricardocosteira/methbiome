rule modkit:
    input:
        config["results"]["minimap2"]["filtered_dir"]
    output:
        directory(config["results"]["modkit"]["dir"])
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
            modkit_command='modkit pileup -t "$(nproc)" --filter-threshold '{params.minimum_methylation_likelihood}' --header'

            if [ '{params.data_type}' == 'PacBio' ]; then
                modkit_command+=' --force-allow-implicit' # Flag needed when input data is PacBio
            fi

            modkit_command+=' "$aBAM" "{output}/$filename_without_extension.bed"'
            
            for aBAM in '{input}'/*.sort.bam; do
                [ -e "$aBAM" ] || continue

                filename_with_extension="$(basename "$aBAM")"
                filename_without_extension="${{filename_with_extension%.*}}"

                samtools index "$aBAM"

                eval "$modkit_command"
            done
        }} &> {log}
        """
