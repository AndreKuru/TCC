from converter import Node, Output_tree
from constants import THRESHOLD_SHIFT

from pathlib import Path
from test_generator import generate_testbench_setup


def bin_fixed_len(number: int | float, length: int = 31) -> str:
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

def initialize_testbench() -> list[str]:
    lines = list()

    lines.append("library ieee;")
    lines.append("use ieee.std_logic_1164.all;")
    lines.append("use work.accelerator_pkg.all;")
    lines.append("")
    lines.append("entity accelerator_tb is")
    lines.append("    generic(")
    lines.append("        features_amount             : natural := FEATURES_AMOUNT;")
    lines.append("        features_index_size         : natural := FEATURE_INDEX_SIZE;")
    lines.append("        features_amount_remaining   : natural := FEATURES_AMOUNT_REMAINING;")
    lines.append("        threshold_size              : natural := THRESHOLD_SIZE;")
    lines.append("        threshold_size_complement   : natural := THRESHOLD_SIZE_COMPLEMENT;")
    lines.append("        class_size                  : natural := CLASS_SIZE;")
    lines.append("        class_size_complement       : natural := CLASS_SIZE_COMPLEMENT;")
    lines.append("        nodes_amount                : natural := NODES_AMOUNT;")
    lines.append("        node_size                   : natural := NODE_SIZE;")
    lines.append("        levels_in_memory            : natural := LEVELS_IN_MEMORY;")
    lines.append("        levels_in_parallel          : natural := LEVELS_IN_PARALLEL;")
    lines.append("        prefetch                    : natural := PREFETCH")
    lines.append("    );")
    lines.append("end accelerator_tb;")
    lines.append("")
    lines.append("architecture tb of accelerator_tb is")
    lines.append("")
    lines.append("signal clk, reset      : std_logic;")
    lines.append("signal features        : std_logic_vector(threshold_size * features_amount - 1 downto 0);")
    lines.append("-- signal nodes_data_in   : std_logic_vector(nodes_amount * node_size - 1 downto 0);")
    lines.append("signal ready           : std_logic;")
    lines.append("signal class           : std_logic_vector(class_size - 1 downto 0);")
    lines.append("")
    lines.append("constant clkp : time := 1 ns;")
    lines.append("")
    lines.append("begin")
    lines.append("    UUT: entity work.accelerator ")
    lines.append("        generic map(")
    lines.append("            threshold_size              => threshold_size, ")
    lines.append("            features_amount             => features_amount,")
    lines.append("            features_index_size         => features_index_size,")
    lines.append("            class_size                  => class_size,")
    lines.append("            levels_in_memory            => levels_in_memory,")
    lines.append("            levels_in_parallel          => levels_in_parallel,")
    lines.append("            prefetch                    => prefetch,")
    lines.append("            features_amount_remaining   => features_amount_remaining")
    lines.append("        )")
    lines.append("        port map(")
    lines.append("            clk             => clk,")
    lines.append("            reset           => reset,")
    lines.append("            features        => features,")
    lines.append("            -- nodes_data_in   => nodes_data_in,")
    lines.append("            ready           => ready,")
    lines.append("            class           => class")
    lines.append("        );")
    lines.append("")
    lines.append("    Clk_simulation : process")
    lines.append("    begin")
    lines.append("        clk <= '0'; wait for clkp/2;")
    lines.append("        clk <= '1'; wait for clkp/2;")
    lines.append("    end process;")
    lines.append("")
    lines.append("    All_results_test : process")
    lines.append("    variable write_line : line;")
    lines.append("    file write_file     : text;")
    lines.append("    begin")
    lines.append("        -- Initialization")
    lines.append("        features <= (others => '0');")

    return lines


def generate_feature_assigment(index: int, threshold: int, threshold_length: int) -> str:
    feature_content = bin_fixed_len(threshold, threshold_length)
    return (
        "            features(threshold_size * ("
        + str(index)
        + " + 1) - 1 downto threshold_size * "
        + str(index)
        + ') <= "'
        + feature_content
        + '";'
    )

def generate_test_iteration(cont, threshold_length: int, lines: list[str], features_setup: list[tuple[int, int] | None]) -> list[str]:
    lines.append("")
    lines.append("        -- Setup " + str(cont))
    lines.append("        reset <= '1';")

    for feature_index, feature_content in features_setup:
        feature_assigment = generate_feature_assigment(feature_index, feature_content, threshold_length)
        lines.append(feature_assigment)

    lines.append("        wait for 2 * clkp;")
    lines.append("        wait until ready = '0';")
    lines.append("        reset <= '0'")
    lines.append("")
    lines.append("        -- Result " + str(cont))
    lines.append("        wait until ready = '1';")
    lines.append("        wait for 2 * clkp;")
    lines.append("        write(write_line, class)")
    lines.append("        writeline(write_file, write_line)")

def export_testbench(
    expected_output_filepath: Path,
    testbench_output_filepath: Path,
    testbench_filepath: Path,
    nodes: list[Node],
    threshold_length: int,
) -> None:
    saved_setups, saved_results = generate_testbench_setup(nodes)

    lines = initialize_testbench()

    lines.append('        file_open(write_file, "' + str(testbench_output_filepath) + '", write_mode);')

    cont = 0
    for setup in saved_setups:
        cont += 1
        generate_test_iteration(cont, threshold_length, lines, setup)


    lines.append("    end process;")
    lines.append("")
    lines.append("end tb;")


    with open(testbench_filepath, "w") as file:
        for line in lines:
            file.write(line + "\n")

def export(
    tree: Output_tree,
    path: Path = Path.cwd(),
    memory_filename: str = "wine",
    configuration_filename: str = "accelerator_pkg.vhd",
    testbench_filename: str = "accelerator_tb.vhd",
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
        path / (memory_filename + ".ktree"),
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

    export_testbench(
        path / (memory_filename + "_expected_output.ktreet"),
        path / (memory_filename + "_testbench_output.ktreet"),
        path / testbench_filename,
        tree.nodes,
        threshold_length,
    )
