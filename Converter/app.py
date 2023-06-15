import _pickle

from sklearn.datasets import load_iris, load_wine, load_digits, load_breast_cancer, load_diabetes
from sklearn.tree import DecisionTreeClassifier, plot_tree
from converter import Input_tree, convert, Output_tree
from reader import read_csv
from exporter import export
from test_generator import generate_testbench_setup
from matplotlib import pyplot
from pathlib import Path
from time import time


def import_dataset(
    filename: str,
    folderpath: Path = Path.cwd(),
    file_extension: str = ".csv",
):
    # X, y = [[0, 0], [0, 1], [1, 0], [1, 1]], [0, 1, 1, 0]
    # X, y = load_iris(return_X_y=True, as_frame=True)
    # X, y = load_wine(return_X_y=True, as_frame=True)
    # filename = 'wine'
    # X, y = load_diabetes(return_X_y=True, as_frame=True)
    # X, y = load_breast_cancer(return_X_y=True, as_frame=True)
    # X, y = load_digits(return_X_y=True, as_frame=True)

    labels, data, target = read_csv(folderpath / (filename + file_extension))
    X = data
    y = target

    return X, y

def build_tree(X, y, filename):
    classifier = DecisionTreeClassifier(max_depth=7)
    classifier.fit(X, y)

    tree = Input_tree(
        list(classifier.tree_.children_left),
        list(classifier.tree_.children_right),
        list(classifier.tree_.feature),
        list(classifier.tree_.threshold),
        list(classifier.tree_.value),
    )

    converted_tree = convert(tree)

    with open(Path.cwd() / (filename + "_converted_tree.ktreeb"), "wb") as output_file:
        _pickle.dump(converted_tree, output_file)
    with open(Path.cwd() / (filename + "_classifier.ktreeb"), "wb") as output_file:
        _pickle.dump(classifier, output_file)

    return converted_tree, classifier

def load_tree(filename):
    with open(Path.cwd() / (filename + "_converted_tree.ktreeb"), "rb") as input_file:
            converted_tree = _pickle.load(input_file)
    with open(Path.cwd() / (filename + "_classifier.ktreeb"), "rb") as input_file:
            classifier = _pickle.load(input_file)

    return converted_tree, classifier

def create(
    filname_to_import: str = "principais-imputados", 
    filename_to_serialize: str = None,
) -> tuple[Output_tree, DecisionTreeClassifier]:
    X, y = import_dataset(filename=filname_to_import)

    if filename_to_serialize is None:
        filename = filname_to_import
    else:
        filename = filename_to_serialize

    converted_tree, classifier = build_tree(X, y, filename)

    return converted_tree, classifier

def use(filename: str):
    converted_tree, classifier = load_tree(filename)

    # plot_tree(classifier)
    # # pyplot.show(block=False)
    # pyplot.savefig((filename + '.pdf'))

    # export(converted_tree, memory_filename=filename)
    
    # 6 levels
    features_6_levels = [[
        0, # 0
        0, # 1
        0, # 2
        0, # 3
        0.5, # 4
        0, # 5
        0, # 6
        0, # 7
        0, # 8
        26.5, # 9
        18, # 10
        38, # 11
        0, # 12
        0, # 13
        0, # 14
    ]]

    # 8 levels
    features_8_levels = [[
        0, # 0
        0, # 1
        0, # 2
        0, # 3
        0.5, # 4
        0, # 5
        0, # 6
        50, # 7
        21, # 8
        26.5, # 9
        18, # 10
        38, # 11
        0, # 12
        0, # 13
        0, # 14
    ]]

    # 12 levels
    features_12_levels = [[
        0, # 0
        0, # 1
        0, # 2
        0, # 3
        0, # 4
        0, # 5
        0, # 6
        0, # 7
        24, # 8
        13, # 9
        17, # 10
        20, # 11
        39, # 12
        38, # 13
        41, # 14
    ]]

    initial_time = time()
    for _ in range(100000):
        classifier.predict(features_12_levels)
    final_time = time()

    predict_time = (final_time - initial_time)/100000
    print(predict_time * 10**9)

def main():
    filename = "principais-imputados-8-levels"

    # create(filename)
    use(filename)