rule setup:
    input:
        # Dorado is provisioned for every run, including one that skips basecalling, so that a
        # single setup step is enough for the project.
        config["resources"]["dorado"]["dir"],
        config["resources"]["kraken2_db"]["dir"]
