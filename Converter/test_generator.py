from converter import Node
from constants import THRESHOLD_SHIFT


def save_setup(
    value: int,
    features_setup: list[tuple[int, int] | None], 
    last_features_setup: list[tuple[int, int] | None],
    saved_setups: list[list[tuple[int, int] | None]],
    saved_results: list[int],
) -> None:

    difference_setup = list()

    for feature_setup in features_setup:
        if feature_setup not in last_features_setup and feature_setup is not None:
            difference_setup += [feature_setup]
    
    if len(difference_setup) > 0:
        last_features_setup = features_setup

        saved_setups += [difference_setup]
        saved_results += [value]

# depth first search
def visit_feature(
    nodes: list[Node], 
    index_node: int, 
    features_setup: list[tuple[int, int] | None], 
    last_features_setup: list[tuple[int, int] | None],
    saved_setups: list[list[tuple[int, int] | None]],
    saved_results: list[int],
) -> None:
    ...
    if nodes[index_node].leaf:
        feature_setup_left = features_setup + [None]
        feature_setup_right = features_setup + [None]
    else:
        feature = nodes[index_node].feature
        threshold = int(nodes[index_node].threshold * THRESHOLD_SHIFT)

        feature_setup_left = features_setup + [(feature, threshold)]
        feature_setup_right = features_setup + [(feature, threshold + 1)]

    children_left = index_node * 2 + 1   

    if children_left < len(nodes) - 1:
        children_right = children_left + 1

        visit_feature(nodes, children_left, feature_setup_left, last_features_setup, saved_setups, saved_results)
        visit_feature(nodes, children_right, feature_setup_right, last_features_setup, saved_setups, saved_results)
    else:
        value = nodes[index_node].value
        save_setup(value, features_setup, last_features_setup, saved_setups, saved_results)

def generate_testbench_setup(nodes: list[Node]
) -> tuple[list[list[tuple[int, int] | None]], list[int]]:

    # depth first search initialization
    features_setup = list()
    last_features_setup = [None]
    saved_results = list()
    saved_setups = list()

    # depth first search
    visit_feature(nodes, 0, features_setup, last_features_setup, saved_setups, saved_results)

    return saved_setups, saved_results