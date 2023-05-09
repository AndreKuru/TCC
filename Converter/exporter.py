from Converter import Node
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
    




def export(tree : list[Node], filepath : Path = Path.cwd() / "tree1.ktree", threshold_lenght: int = 31, feature_lenght: int = 31) -> None:
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

            node_str = ' '.join([valid_bit, leaf, threshold, feature])
            # node_str = valid_bit + leaf + threshold + feature
            file.write(node_str + "\n")