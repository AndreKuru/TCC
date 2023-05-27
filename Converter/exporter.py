from converter import Node, Output_tree
from pathlib import Path


THRESHOLD_SHIFT = 2**16


def bin_fixed_len(number: int | float, length: int = 31):
    number = int(number)

    if number < 0:
        number = ~number + 1
        binary = bin(number)[2:]
        return binary.rjust(length, "1")
    else:
        binary = bin(number)[2:]
        return binary.rjust(length, "0")


def export_configurations(
    threshold_size: int,
    features_amount: int,
    class_size: int,
    nodes_amount: int,
    levels_in_parallel: int,
    prefetch: int,
    filepath: Path,
) -> None:
    ...


def export_memory_block(
    nodes: list[Node],
    filepath: Path,
    feature_index_length: int,
    threshold_length: int,
    value_length: int,
) -> None:
    with open(filepath, "w") as file:
        count = -1
        for node in nodes:
            count += 1

            if node.leaf:
                leaf = "1"
                value = bin_fixed_len(node.value, value_length)

                node_serialized = leaf + value
            else:
                leaf = "0"
                threshold = bin_fixed_len(
                    node.threshold * THRESHOLD_SHIFT, threshold_length
                )
                feature = bin_fixed_len(node.feature, feature_index_length)

                node_serialized = leaf + feature + threshold

            file.write(node_serialized + "\n")


def export(
    tree: Output_tree,
    path: Path = Path.cwd(),
    memory_filename: str = "wine.ktree",
    configuration_filename: str = "accelerator_pkg.vhd",
) -> None:
    feature_index_length = tree.max_feature_index.bit_length()
    threshold_length = int(
        tree.max_threshold * THRESHOLD_SHIFT
    ).bit_length()  # THRESHOLD_SHIFT to simulate float as integer
    value_length = tree.max_value.bit_length()

    if value_length > (feature_index_length + threshold_length):
        threshold_length = value_length - (feature_index_length + threshold_length)
    else:
        value_length = (feature_index_length + threshold_length)

    export_memory_block(
        tree.nodes,
        path / memory_filename,
        feature_index_length,
        threshold_length,
        value_length,
    )
