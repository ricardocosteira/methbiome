rule validate_PacBio_input:
    localrule: True
    input:
        config["input"]["data_dir"]
    output:
        config["resources"]["input_validation"]
    conda:
        "../envs/main.yaml"
    log:
        config["logs"]["input_validation"]
    shell:
        """
        {{
            for uBAM in '{input}'/*.bam; do
                [ -e "$uBAM" ] || continue
                samtools quickcheck "$uBAM"
            done

            touch '{output}'
        }} &> {log}
        """
