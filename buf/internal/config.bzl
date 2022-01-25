"""Defines buf_config macro"""

def buf_config(name = "buf_config", config = "buf.yaml"):
    """buf_config exports the `buf.yaml` file to make it avaialble to other rules

    Args:
        name: Name of the macro. Can be anything
        config: The `buf.yaml` file
    """
    native.exports_files([config])
