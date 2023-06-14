import _pickle

from sklearn.datasets import load_iris, load_wine, load_digits, load_breast_cancer, load_diabetes
from sklearn.tree import DecisionTreeClassifier, plot_tree
from converter import Input_tree, convert
from reader import read_csv
from exporter import export
from matplotlib import pyplot
from pathlib import Path
from time import time


def import_dataset(
    folderpath: Path = Path.cwd(),
    filename: str = "principais-imputados",
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

    return X, y, filename

def build_tree(X, y, filename):
    classifier = DecisionTreeClassifier(max_depth=11)
    classifier.fit(X, y)

    tree = Input_tree(
        list(classifier.tree_.children_left),
        list(classifier.tree_.children_right),
        list(classifier.tree_.feature),
        list(classifier.tree_.threshold),
        list(classifier.tree_.value),
    )

    converted_tree = convert(tree)

    plot_tree(classifier)

    pyplot.show(block=False)
    pyplot.savefig((filename + '.pdf'))

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

filename = "principais-imputados"

# X, y, filename = import_dataset(filename=filename)
# converted_tree, classifier = build_tree(X, y, filename)

converted_tree, classifier = load_tree(filename)
export(converted_tree, memory_filename=filename)