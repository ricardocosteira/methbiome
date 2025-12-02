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
        for BED in '{input}'/*.bed; do
                [ -e "$BED" ] || continue

                filename_with_extension="$(basename "$BED")"
                filename_without_extension="${{filename_with_extension%.*}}"

                bgzip "$filename_with_extension"
                tabix "$filename_without_extension.gz"
            done
        }} &> {log}
        """
