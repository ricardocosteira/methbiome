rule tabix:
    input:
        config["results"]["modkit"]["dir"]
    output:
        directory(config["results"]["tabix"]["dir"])
    conda:
        "../envs/tabix.yaml"
    log:
        config["logs"]["tabix"]
    shell:
        """
        {{
        cp -R '{input}' '{output}'
        for BED in '{output}'/*.bed; do
                [ -e "$BED" ] || continue
                bgzip "$BED"
                tabix "$BED.gz"
            done
        }} &> {log}
        """
