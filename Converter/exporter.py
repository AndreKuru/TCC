from converter import Node, Output_tree
from pathlib import Path


THRESHOLD_SHIFT = 2**16  # to simulate float as integer


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
    filepath: Path,
    memory_filename: str,
    features_amount: int,
    feature_index_length: int,
    threshold_length: int,
    threshold_length_complement: int,
    value_length: int,
    value_length_complement: int,
    node_length: int,
    nodes_amount: int,
    levels_in_parallel: int = 1,
    prefetch: int = 0,
) -> None:

    features_amount_remaining = 2**feature_index_length - features_amount
    levels_in_memory = (nodes_amount - 1).bit_length()

    lines = list()
    lines.append("package accelerator_pkg is")
    lines.append("    constant FEATURES_AMOUNT            : natural := " + str(features_amount) + ";")
    lines.append("    constant FEATURES_AMOUNT_REMAINING  : natural := " + str(features_amount_remaining) + ";")
    lines.append("    constant FEATURE_INDEX_SIZE         : natural := " + str(feature_index_length) + ";")
    lines.append("    constant THRESHOLD_SIZE             : natural := " + str(threshold_length) + ";")
    lines.append("    constant THRESHOLD_SIZE_COMPLEMENT  : natural := " + str(threshold_length_complement) + ";")
    lines.append("    constant CLASS_SIZE                 : natural := " + str(value_length) + ";")
    lines.append("    constant CLASS_SIZE_COMPLEMENT      : natural := " + str(value_length_complement) + ";")
    lines.append("    constant NODES_AMOUNT               : natural := " + str(nodes_amount) + ";")
    lines.append("    constant NODE_SIZE                  : natural := " + str(node_length) + ";")
    lines.append("    constant LEVELS_IN_MEMORY           : natural := " + str(levels_in_memory) + ";")
    lines.append("    constant LEVELS_IN_PARALLEL         : natural := " + str(levels_in_parallel) + ";")
    lines.append("    constant PREFETCH                   : natural := " + str(prefetch) + ";")
    lines.append(" -- constants for the tree serialized in the file: " + memory_filename)
    lines.append("")
    lines.append("    function Bit_length (")
    lines.append("        x : positive)")
    lines.append("        return natural;")
    lines.append("")
    lines.append("end package accelerator_pkg;")
    lines.append("")
    lines.append("-- Package Body Section")
    lines.append("package body accelerator_pkg is")
    lines.append("    function Bit_length (")
    lines.append("        x : positive) ")
    lines.append("    return natural is")
    lines.append("        variable i : natural;")
    lines.append("    begin")
    lines.append("        i := 0;  ")
    lines.append("        while (2**i < x) and i < 63 loop")
    lines.append("            i := i + 1;")
    lines.append("        end loop;")
    lines.append("            i := i + 1;")
    lines.append("        return i;")
    lines.append("    end function;")
    lines.append("")
    lines.append("end package body accelerator_pkg;")

    with open(filepath, "w") as file:
        for line in lines:
            file.write(line + "\n")

def export_memory_block(
    filepath: Path,
    nodes: list[Node],
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
    threshold_length = int(tree.max_threshold * THRESHOLD_SHIFT).bit_length()
    value_length = tree.max_value.bit_length()

    if value_length > (feature_index_length + threshold_length):
        node_length = value_length + 1 # leaf bit
        threshold_length_complement = value_length - (feature_index_length + threshold_length)
        value_length_complement = 0
    else:
        node_length = (feature_index_length + threshold_length) + 1 # leaf bit
        threshold_length_complement = 0
        value_length_complement = (feature_index_length + threshold_length) - value_length

    export_memory_block(
        path / memory_filename,
        tree.nodes,
        feature_index_length,
        threshold_length + threshold_length_complement,
        value_length + value_length_complement,
    )


    export_configurations(
        path / configuration_filename,
        memory_filename,
        tree.max_feature_index + 1,
        feature_index_length,
        threshold_length,
        threshold_length_complement,
        value_length,
        value_length_complement,
        node_length,
        len(tree.nodes),
    )