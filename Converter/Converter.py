from dataclasses import dataclass, field
from numpy import double

@dataclass
class Input_tree:
    children_left : list(int)
    children_right : list(int)
    feature : list(int)
    treshhold : list(double)

class Node:
    valid_bit:  list(bool)
    leaf:       list(bool)
    treshhold:  list(double)
    feature:    list(int)

class Output_tree:
    nodes: list("Node") = field(default_factory=list)
    queue: dict(int) = field(default_factory=dict)
    position:   int

    def set_root(self, tree: Input_tree):
        leaf = check_leaf(tree, 0)
        node = Node(1, leaf, tree.treshhold[0], tree.feature[0])
        self.nodes = [node]

    def fill_queue(tree: Input_tree):
        queue = dict()
        for position in range (0, len(tree.feature)):
            if tree.children_left != -1:
                queue.add(2*position + 1, tree.children_left)

            if tree.children_right != -1:
                queue.add(2*position + 2, tree.children_right)
        

        children_right = tree.children_right
        if children_left != -1:
            queue.add(children_left)
        ...
        queue.add(children_right)



def check_leaf(tree: Input_tree, index: int):
    if (tree.children_left[index] == -1 and
        tree.children_right[index == -1]):
        return True

def get_children_left(tree: Input_tree, index: int):
    return tree.children_left[index]