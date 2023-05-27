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
    feature: int | None = None
    threshold: float | None = None
    value: int | float | None = None


@dataclass
class Output_tree:
    nodes: Node
    max_feature_index: int
    max_threshold: int | float
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
    max_input_index = 0

    while len(queue) > 0:
        input_node = queue.pop(0)  # input node is a index

        child_left = tree.children_left[input_node]

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

        child_right = tree.children_right[input_node]

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

    return input_indexes, max_input_index


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
    input_indexes, max_input_index = sort_input_tree(tree)

    new_nodes = list()
    child_leaf_values = dict()  # classes of all children of leafes by output tree index
    max_feature_index = 0
    max_threshold = 0

    limit_of_new_indexes = 2 ** max_input_index.bit_length()

    for new_index in range(limit_of_new_indexes):
        if new_index in input_indexes:
            input_index = input_indexes[new_index]

            if (
                tree.children_left[input_index] == -1
                and tree.children_right[input_index] == -1
            ):
                value = argmax(tree.value[input_index])
                new_node = Node(valid_bit=1, leaf=1, value=value)

                set_leaf_children(
                    new_index, limit_of_new_indexes, child_leaf_values, value
                )

            else:
                new_node = Node(
                    valid_bit=1,
                    leaf=0,
                    feature=tree.feature[input_index],
                    threshold=tree.threshold[input_index],
                )

            new_nodes.append(new_node)
            max_feature_index = max(max_feature_index, tree.feature[input_index])
            max_threshold = max(max_threshold, tree.threshold[input_index])

        elif new_index in child_leaf_values:
            value = child_leaf_values[new_index]
            new_node = Node(valid_bit=1, leaf=1, value=value)

            new_nodes.append(new_node)

        else:  # obsolete
            new_node = Node(INVALID_BIT, 0, 0, 0)
            new_nodes.append(new_node)

    max_value = len(tree.value[0][0]) - 1
    new_tree = Output_tree(new_nodes, int(max_feature_index), max_threshold, max_value)
    return new_tree
