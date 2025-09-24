rule jasmine:
    input:
        input_data=config["input"]["jasmine"]
    output:
        directory(config["results"]["jasmine"])
    conda:
        "../envs/jasmine.yaml"
    log:
        config["logs"]["jasmine"]
    shell:
        """
        {{

            mkdir -p '{output}'
            
            for uBAM in '{input}'/*.bam; do
                [ -e "$uBAM" ] || continue
                                
                filename_with_extension="$(basename "$uBAM")"
                filename_without_extension="${{filename_with_extension%.*}}"
                jasmine --keep-kinetics --num-threads "$(nproc)" "$uBAM" "{output}/$filename_without_extension.bam"

            done
        }} &> {log}
        """
