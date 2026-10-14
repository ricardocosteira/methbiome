rule validate_ONT_input:
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
            for pod5_file in '{input}'/*.pod5; do
                [ -e "$pod5_file" ] || continue
                echo "$pod5_file:"
                pod5 inspect summary "$pod5_file"
            done
        }} &> {log}
        if [ -s '{log}' ]; then 
            print_first_10_lines '{log}'
        fi
        touch '{output}'
        """
