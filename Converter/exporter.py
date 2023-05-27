from converter import Node
from pathlib import Path

def bin_fixed_len(number: int|float, length: int = 31):
    number = int(number)

    if number < 0:
        number = ~number + 1 
        binary = bin(number)[2:]
        return binary.rjust(length, '1')
    else:
        binary = bin(number)[2:]
        return binary.rjust(length, '0')
    

def export_configurations(
        threshold_size : int,
        features_amount : int, 
        class_size : int, 
        nodes_amount : int, 
        levels_in_parallel : int, 
        prefetch : int,
        filepath : Path
        ) -> None:
    ...

def export_memory_block(tree : list[Node], filepath : Path, threshold_lenght : int, feature_lenght: int) -> None:
    with open(filepath, 'w') as file:
        for node in tree:
            if node.valid_bit:
                valid_bit = '1'
                if node.leaf:
                    leaf = '1'
                    threshold = ''.rjust(threshold_lenght, '0')
                    feature = ''.rjust(feature_lenght, '0')
                else:
                    leaf = '0'
                    # threshold = bin_fixed_len(node.threshold, threshold_lenght)
                    threshold = bin_fixed_len(node.threshold * pow(2, 16), threshold_lenght) # to simulate float as integer
                    feature = bin_fixed_len(node.feature, feature_lenght)
            else:
                valid_bit = '0'
                leaf = '0'
                threshold = ''.rjust(threshold_lenght, '0')
                feature = ''.rjust(feature_lenght, '0')

            # node_str = ' '.join([valid_bit, leaf, feature, threshold])
            node_str = valid_bit + leaf + feature + threshold
            file.write(node_str + "\n")

def export(tree : list[Node], max_feature_index : int, threshold_max_value : int, class_amount, path : Path = Path.cwd(), memory_filename : str = "wine.ktree", configuration_filename : str = "accelerator_pkg.vhd", threshold_lenght: int = 31,) -> None:
    # export_memory_block(tree, path / memory_filename, threshold_lenght, feature_lenght)
    ...