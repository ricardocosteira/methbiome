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
        source workflow/scripts/print_first_10_lines.sh 
        {{
            for uBAM in '{input}'/*.bam; do
                [ -e "$uBAM" ] || continue
                samtools quickcheck -u "$uBAM" || true # Carry on even if samtools returns a non 0 exit code.
            done
        }} &> {log}
        if [ -s '{log}' ]; then 
            print_first_10_lines '{log}'
        fi
        touch '{output}'
        """
