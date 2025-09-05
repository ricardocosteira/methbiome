rule install_genomad_db:
    input:
        config["resources"]["genomad"]["installed"]
    output:
        directory(config["resources"]["genomad"]["db_dir"])
    conda:
        "../envs/genomad.yaml"
    params:
        resources=config["resources"]["dir"]
    log:
        config["logs"]["install_genomad_db"]
    shell:
        """
        {{
            cd '{params.resources}'
            genomad download-database .
        }} &> {log}
        """
