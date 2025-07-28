rule fibertools_predict:
    input:
        input_data=config["input"]["data"]["dir"]
    output:
        directory(config["results"]["bam_dir"])
    conda:
        "../envs/fibertools.yaml"
    log:
        config["logs"]["fibertools_predict"]
    shell:
        """
        mkdir -p '{output}'
        
        for uBAM in '{input}'/*.bam; do
            [ -e "$uBAM" ] || continue
                            
            filename_with_extension="$(basename "$uBAM")"
            filename_without_extension="${{filename_with_extension%.*}}"
            
            ft predict-m6a --keep -t "$(nproc)" -v "$uBAM" "{output}/$filename_without_extension.bam" &> {log}
        done
        """
