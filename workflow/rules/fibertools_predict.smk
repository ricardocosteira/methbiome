rule fibertools_predict:
    input:
        data=config["input"]["data_dir"],
        validation=config["resources"]["input_validation"]
    output:
        directory(config["results"]["bam_dir"])
    conda:
        "../envs/main.yaml"
    log:
        config["logs"]["fibertools_predict"]
    shell:
        """
        {{
            mkdir -p '{output}'
            
            for uBAM in '{input.data}'/*.bam; do
                [ -e "$uBAM" ] || continue
                                
                filename_with_extension="$(basename "$uBAM")"
                filename_without_extension="${{filename_with_extension%.*}}"
                
                ft predict-m6a --keep -t "$(nproc)" -v "$uBAM" "{output}/$filename_without_extension.bam"
            done
        }} &> {log}

        """
