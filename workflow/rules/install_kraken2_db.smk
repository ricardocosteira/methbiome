rule install_kraken2_db:
    output:
        directory(config["resources"]["kraken2_db"]["dir"])
    conda:
        "../envs/python.yaml"
    params:
        kraken2_db_archive_path=config["resources"]["kraken2_db"]["archive_path"]
    log:
        config["logs"]["install_kraken2_db"]
    shell:
        """
        {{
            link="$(python3 workflow/scripts/get_latest_kraken2_standard_db_link.py)"
            wget -q -O '{params.kraken2_db_archive_path}' "$link"

            mkdir -p '{output}'
            tar -xvzf '{params.kraken2_db_archive_path}' -C '{output}'
            
            rm -f '{params.kraken2_db_archive_path}'
        }} &> {log}
        """
