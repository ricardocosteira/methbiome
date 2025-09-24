rule dorado:
    input:
        input_dir=config["input"]["dorado"],
        dorado_dir=config["resources"]["dorado"]["dir"]
    output:
        directory(config["results"]["bam_dir"])
    params:
        dorado_path=config["resources"]["dorado"]["binary_path"],
        intermediate_bam_path=config["results"]["dorado_intermediate_bam_path"],
        min_quality=config["tool_specific_params"]["dorado"]["min_quality"],
        trim=config["tool_specific_params"]["dorado"]["trim"],
        methylation_model=config["tool_specific_params"]["dorado"]["methylation_model"],
        demultiplexing=config["tool_specific_params"]["dorado"]["demultiplexing"],
        mux_barcode_kit=config["tool_specific_params"]["dorado"]["mux_barcode_kit"]
    log:
        config["logs"]["dorado"]
    shell:
        """
        {{ 
            # Double braces are interpreted as single braces by snakemake
            source workflow/scripts/source_profile.sh # Needed for module command to be recognised
            module load cuda

            '{params.dorado_path}' basecaller \
                --recursive \
                --verbose \
                {params.trim} \
                --min-qscore '{params.min_quality}' \
                --emit-moves \
                '{params.methylation_model}' \
                '{input.input_dir}' > '{params.intermediate_bam_path}'

            mkdir -p '{output}'

            if [ '{params.demultiplexing}' == 'True' ]; then
                '{params.dorado_path}' demux \
                    --verbose \
                    --output-dir '{output}' \
                    --kit-name '{params.mux_barcode_kit}' \
                    --threads "$(nproc)" \
                    '{params.intermediate_bam_path}'
            else
                mv '{params.intermediate_bam_path}' '{output}'
            fi
        }} &> {log}
        """
