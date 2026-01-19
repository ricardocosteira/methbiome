rule install_dorado:
    output:
        directory(config["resources"]["dorado"]["dir"])
    conda:
        "../envs/python.yaml"
    params:
        dorado_archive_path=config["resources"]["dorado"]["archive_path"]
    log:
        config["logs"]["install_dorado"]
    shell:
        """
        {{
            link='https://cdn.oxfordnanoportal.com/software/analysis/dorado-1.3.1-linux-x64.tar.gz'
            wget -q -O '{params.dorado_archive_path}' "$link"
            
            mkdir -p '{output}'
            tar -xvzf '{params.dorado_archive_path}' -C '{output}' --strip-components=1

            rm -f '{params.dorado_archive_path}'
        }} &> {log}
        """
