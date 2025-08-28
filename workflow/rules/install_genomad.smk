rule install_genomad:
    output:
        config["resources"]["genomad"]["installed"]
    conda:
        "../envs/genomad.yaml"
    log:
        config["logs"]["install_genomad"]
    shell:
        """
        {{
            mamba install bioconda::genomad 
            touch '{output}'
        }} &> {log}
        """
