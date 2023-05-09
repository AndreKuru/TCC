from dataclasses import dataclass, field
from pathlib import Path

VALID_BIT = 1
INVALID_BIT = 0

@dataclass
class Input_tree:
    children_left   : list[int]
    children_right  : list[int]
    feature         : list[int]
    threshold       : list[float]

@dataclass
class Node:
    valid_bit       : bool
    leaf            : bool
    threshold       : float
    feature         : int


# Breadth first search in input tree
def sort_input_tree(tree: Input_tree) -> tuple[dict, int]:
    queue = [0]  # queue of nodes by input index
    queued = [0] # nodes queueds by input index

    new_indexes = {0: 0} # node index in the output tree
    input_indexes = {0: 0} # node index in the input tree
    max_index = 0

    while len(queue) > 0:
        input_node = queue.pop(0) # input node is a index

        children_left = tree.children_left[input_node]

        if children_left != -1:
            if children_left in queued:
                raise("node", children_left, "was queued more than once.")
            new_index = new_indexes[input_node] * 2 + 1
            new_indexes[children_left] = new_index
            input_indexes[new_index] = children_left
            max_index = new_index

            queue.append(children_left)
            queued.append(children_left)
        
        children_right = tree.children_right[input_node]

        if children_right != -1:
            if children_right in queued:
                raise("node", children_right, "was queued more than once.")
            new_index = new_indexes[input_node] * 2 + 2
            new_indexes[children_right] = new_index
            input_indexes[new_index] = children_right
            max_index = new_index

            queue.append(children_right)
            queued.append(children_right)
    
    return input_indexes, max_index

def convert(tree: Input_tree) -> list[Node]:
    input_indexes, max_index = sort_input_tree(tree)

    new_tree = list()

    for new_index in range(2**max_index.bit_length()):

        if new_index in input_indexes:
            input_index = input_indexes[new_index]

            if input_index in input_indexes and tree.children_left[input_index] == -1 and tree.children_right[input_index] == -1:
                leaf = 1
            else:
                leaf = 0

            new_node = Node(VALID_BIT, leaf, tree.threshold[input_index], tree.feature[input_index])
            new_tree.append(new_node)
        
        else:
            new_node = Node(INVALID_BIT, 0, 0, 0)
            new_tree.append(new_node)
        
    return new_tree

def write_tree(output_tree: list[Node], filepath: Path) -> None:
    with filepath.open("w") as file:
        for node in output_tree:
            line = f"{node.valid_bit}{node.leaf}{node.feature:064b}{node.threshold:064b}"
            file.write(line)


#class Output_tree:
#    nodes: list("Node") = field(default_factory=list)
#    queue: dict(int) = field(default_factory=dict)
#    position:   int
#
#    def set_root(self, tree: Input_tree):
#        leaf = check_leaf(tree, 0)
#        node = Node(1, leaf, tree.threshold[0], tree.feature[0])
#        self.nodes = [node]
#
#    def fill_queue(tree: Input_tree):
#        queue = dict()
#        for position in range (0, len(tree.feature)):
#            if tree.children_left != -1:
#                queue.add(2*position + 1, tree.children_left)
#
#            if tree.children_right != -1:
#                queue.add(2*position + 2, tree.children_right)
#        
#
#        children_right = tree.children_right
#        if children_left != -1:
#            queue.add(children_left)
#        ...
#        queue.add(children_right)
#
#
#
#def check_leaf(tree: Input_tree, index: int):
#    if (tree.children_left[index] == -1 and
#        tree.children_right[index == -1]):
#        return True
#
#def get_children_left(tree: Input_tree, index: int):
#    return tree.children_left[index]