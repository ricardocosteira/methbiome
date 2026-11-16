rule jasmine:
    input:
        data=config["input"]["data_dir"],
        validation=config["resources"]["input_validation"]
    output:
        directory(config["results"]["bam_dir"])
    conda:
        "../envs/main.yaml"
    params:
        intermediate_bam_dir=config["results"]["intermediate_bam_dir"]
    log:
        config["logs"]["jasmine"]
    shell:
        """
        {{
            mkdir -p '{output}'
            mkdir -p '{params.intermediate_bam_dir}'

            for uBAM in '{input.data}'/*.bam; do
                [ -e "$uBAM" ] || continue
                                
                filename_with_extension="$(basename "$uBAM")"
                filename_without_extension="${{filename_with_extension%.*}}"
                intermediate_bam="{params.intermediate_bam_dir}/$filename_without_extension.clean.bam"
                basecalled_bam="{output}/$filename_without_extension.jasmine.bam"

                samtools view -x MM,ML -O BAM -o "$intermediate_bam" "$uBAM"

                jasmine --num-threads "$(getconf _NPROCESSORS_ONLN)" \
                    --keep-kinetics \
                    "$intermediate_bam" \
                    "$basecalled_bam"
            done
        }} &> '{log}'
        """
