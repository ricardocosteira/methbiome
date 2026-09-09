from pathlib import Path
from snakemake.exceptions import WorkflowError


def _fail(message):
    raise WorkflowError(f"Configuration error: {message}")


def _require_existing_file(filename, name):
    path = Path(filename)
    if not path.is_file():
        _fail(f"File configured by '{name}' does not exist: {path}")
    return path


def _require_existing_directory(dirname, name):
    path = Path(dirname)
    print(f"here is the pa{path}")
    if not path.is_dir():
        _fail(f"Directory configured by '{name}' does not exist: {path}")
    return path

def _contains_appropriate_file(dir, type, key_name):
    path = Path(dir)
    required_extension = "pod5" if type == "ONT" else "bam"
    if not any(candidate.is_file() for candidate in path.glob(f"*.{required_extension}")):
        _fail(
            f"Directory configured by '{key_name}' contains no "
            f"{required_extension} files: {path}"
        )


def _validate_data_dir(data_dir):
    _require_existing_directory(
        data_dir,
        "input_files.data.dir",
    )
    

def _validate_default_reference(default_reference_path):
    _require_existing_file(
        default_reference_path,
        "input_files.minimap2.default_reference_filename",
    )


def _validate_default_index(default_index_path):
    if default_index_path is not None:
         _require_existing_file(
             default_index_path,
             "input_files.minimap2.default_index_filename",
         )

def _validate_multi(multi, key_name, reference_path):
    if multi is not None:
        for match_string, filename in multi.items():
            file = reference_path / filename
            _require_existing_file(
                file,
                f"{key_name}[{match_string}]",
            )

def validate_paths(config):
    input_attribute = config.get("input")
    input_files = config.get("input_files")
    data_dir = input_attribute.get("data_dir")

    _validate_data_dir(data_dir)

    _contains_appropriate_file(data_dir, input_files.get("data").get("type"), "input_files.data.dir")

    _validate_default_reference(input_attribute.get("default_reference").get("path"))
    _validate_default_index(input_attribute.get("default_index").get("path"))

    reference_path = Path(input_attribute.get("references_dir"))
    minimap2 = input_files.get("minimap2")

    multi_reference_key = "multi_reference_filename"
    _validate_multi(minimap2.get(multi_reference_key), multi_reference_key, reference_path)
    multi_index_key = "multi_index_filename"
    _validate_multi(minimap2.get(multi_index_key), multi_index_key, reference_path)
