from dataclasses import dataclass
from pathlib import Path
from numpy import argmax

VALID_BIT = 1
INVALID_BIT = 0


@dataclass
class Input_tree:
    children_left: list[int]
    children_right: list[int]
    feature: list[int]
    threshold: list[float]
    value: list[list[int | float]]


@dataclass
class Node:
    valid_bit: bool
    leaf: bool
    threshold: float | None = None
    feature: int | None = None
    value: int | float | None = None


@dataclass
class Output_tree:
    nodes: Node
    max_threshold: int | float
    max_feature_index: int
    max_value: int


def sort_children(
    children: int,
    queue: list,
    queued: set,
    input_node: int,
    input_indexes: dict,
    new_indexes: dict,
    is_right_child: int,
):
    if children in queued:
        raise ("node", children, "was queued more than once.")

    new_index = new_indexes[input_node] * 2 + 1 + is_right_child
    new_indexes[children] = new_index
    input_indexes[new_index] = children

    queue.append(children)
    queued.add(children)

    return new_index


# Breadth first search in input tree
def sort_input_tree(tree: Input_tree) -> tuple[dict, int]:
    queue = [0]  # queue of nodes by input index
    queued = {0}  # nodes queueds by input index

    input_indexes = {0: 0}  # from index of output tree to node index in the input tree
    new_indexes = {0: 0}  # from index of input tree to node index in the output tree
    leaf_input_indexes = dict()  # all leafs by input tree index
    max_input_index = 0

    while len(queue) > 0:
        input_node = queue.pop(0)  # input node is a index

        child_left = tree.children_left[input_node]
        child_right = tree.children_right[input_node]

        if input_node in leaf_input_indexes:
            ...

        elif child_left == -1 and child_right == -1:
            ...

        else:
            if child_left != -1:
                max_input_index = sort_children(
                    child_left,
                    queue,
                    queued,
                    input_node,
                    input_indexes,
                    new_indexes,
                    is_right_child=0,
                )

            if child_right != -1:
                max_input_index = sort_children(
                    child_right,
                    queue,
                    queued,
                    input_node,
                    input_indexes,
                    new_indexes,
                    is_right_child=1,
                )

    return input_indexes, max_input_index, new_indexes


def set_leaf_children(
    new_index: int, limit_of_new_indexes: int, child_leaf_values: dict, value: int
) -> None:
    child_left = new_index * 2 + 1

    if child_left < limit_of_new_indexes:
        child_right = new_index * 2 + 2

        child_leaf_values[child_left] = value
        child_leaf_values[child_right] = value

        set_leaf_children(child_left, limit_of_new_indexes, child_leaf_values, value)
        set_leaf_children(child_right, limit_of_new_indexes, child_leaf_values, value)


def convert(tree: Input_tree) -> Output_tree:
    input_indexes, max_input_index, new_indexes = sort_input_tree(tree)

    new_nodes = list()
    child_leaf_values = dict()  # classes of all children of leafes by output tree index
    max_feature_index = 0

    limit_of_new_indexes = 2 ** max_input_index.bit_length()

    for new_index in range(limit_of_new_indexes):
        if new_index in input_indexes:
            input_index = input_indexes[new_index]

            if (
                tree.children_left[input_index] == -1
                and tree.children_right[input_index] == -1
            ):
                leaf = 1
                value = argmax(tree.value[input_index])
                new_node = Node(VALID_BIT, leaf, value=value)

                set_leaf_children(
                    new_index, limit_of_new_indexes, child_leaf_values, value
                )

            else:
                leaf = 0
                new_node = Node(
                    VALID_BIT,
                    leaf,
                    tree.threshold[input_index],
                    tree.feature[input_index],
                )

            new_nodes.append(new_node)
            max_threshold = max(max_threshold, tree.threshold[input_index])
            max_feature_index = max(max_feature_index, tree.feature[input_index])

        elif new_index in child_leaf_values:
            value = child_leaf_values[new_index]
            new_node = Node(VALID_BIT, leaf, value=value)

            new_nodes.append(new_node)

        else:
            new_node = Node(INVALID_BIT, 0, 0, 0)
            new_nodes.append(new_node)

    max_value = len(tree.value) - 1
    new_tree = Output_tree(new_nodes, max_threshold, max_feature_index, max_value)
    return new_tree


def write_tree(output_tree: list[Node], filepath: Path) -> None:
    with filepath.open("w") as file:
        for node in output_tree:
            line = (
                f"{node.valid_bit}{node.leaf}{node.feature:064b}{node.threshold:064b}"
            )
            file.write(line)
