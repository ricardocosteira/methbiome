rule jasmine:
    input:
        data=config["input"]["data_dir"],
        validation=config["resources"]["input_validation"]
    output:
        directory(config["results"]["bam_dir"])
    conda:
        "../envs/main.yaml"
    log:
        config["logs"]["jasmine"]
    shell:
        """
        {{
            mkdir -p '{output}'
            
            for uBAM in '{input.data}'/*.bam; do
                [ -e "$uBAM" ] || continue
                                
                filename_with_extension="$(basename "$uBAM")"
                filename_without_extension="${{filename_with_extension%.*}}"
                intermediate_bam="{output}/$filename_without_extension.cln.bam"
                basecalled_bam="{output}/$filename_without_extension.jasmine.bam"

                samtools view -x MM,ML -O BAM -o "$intermediate_bam" "$uBAM"

                jasmine printf '<%s>\n' --num-threads "$(getconf _NPROCESSORS_ONLN)" \
                    --keep-kinetics \
                    "intermediate_bam" \
                    "basecalled_bam"
            done
        }} &> '{log}'
        """
