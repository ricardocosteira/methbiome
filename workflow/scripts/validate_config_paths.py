from pathlib import Path
from snakemake.exceptions import WorkflowError


def _fail(message):
    raise WorkflowError(f"Configuration error: {message}")


def _require_existing_file_if_not_none(filename, name):
    if not filename is None:
        path = Path(filename)
        if not path.is_file():
            _fail(f"File configured by '{name}' does not exist: {path}")


def _require_existing_directory_if_not_none(dirname, name):
    if not dirname is None:
        path = Path(dirname)
        if not path.is_dir():
            _fail(f"Directory configured by '{name}' does not exist: {path}")


def _contains_appropriate_file(dir, type, key_name):
    required_extension = "pod5" if type == "ONT" else "bam"
    _directory_contains_appropriate_file(dir, required_extension, key_name)


def _directory_contains_appropriate_file(dir, file_extension, key_name):
    path = Path(dir)
    if not any(candidate.is_file() for candidate in path.glob(f"*.{file_extension}")):
        _fail(
            f"Directory configured by '{key_name}' contains no "
            f"{file_extension} files: {path}"
        )


def _validate_multi(multi, key_name, reference_path):
    if multi is not None:
        for match_string, filename in multi.items():
            file = reference_path / filename
            _require_existing_file_if_not_none(
                file,
                f"{key_name}[{match_string}]",
            )

def validate_paths(config):
    input_attribute = config.get("input")
    input_files = config.get("input_files")

    data_dir = input_attribute.get("data_dir")
    _require_existing_directory_if_not_none(data_dir, "input_files.data.dir")
    _contains_appropriate_file(data_dir, input_files.get("data").get("type"), "input_files.data.dir")

    minimap2 = input_files.get("minimap2")
    _require_existing_directory_if_not_none(minimap2.get("custom_references_dir"), "input_files.minimap2.custom_references_dir")

    _require_existing_file_if_not_none(input_attribute.get("default_reference").get("path"), "input_files.minimap2.default_reference_filename")
    _require_existing_file_if_not_none(input_attribute.get("default_index").get("path"), "input_files.minimap2.default_index_filename")

    reference_path = Path(input_attribute.get("references_dir"))

    multi_reference_key = "multi_reference_filename"
    _validate_multi(minimap2.get(multi_reference_key), multi_reference_key, reference_path)
    multi_index_key = "multi_index_filename"
    _validate_multi(minimap2.get(multi_index_key), multi_index_key, reference_path)

    kraken2_database = input_files.get("kraken2").get("database")
    _require_existing_directory_if_not_none(kraken2_database.get("path"), "input_files.kraken2.database.path")

    dorado_archive_path = input_files.get("dorado").get("archive").get("path")
    _require_existing_directory_if_not_none(dorado_archive_path, "input_files.dorado.archive.path")
