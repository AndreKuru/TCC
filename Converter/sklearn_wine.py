from sklearn.datasets import load_iris, load_wine, load_digits, load_breast_cancer, load_diabetes
from sklearn.tree import DecisionTreeClassifier, plot_tree
from converter import Input_tree, convert
from reader import read_csv
from exporter import export
from matplotlib import pyplot
from pathlib import Path


# X, y = [[0, 0], [0, 1], [1, 0], [1, 1]], [0, 1, 1, 0]
# X, y = load_iris(return_X_y=True, as_frame=True)
# X, y = load_wine(return_X_y=True, as_frame=True)
# filename = 'wine'
# X, y = load_diabetes(return_X_y=True, as_frame=True)
# X, y = load_breast_cancer(return_X_y=True, as_frame=True)
# X, y = load_digits(return_X_y=True, as_frame=True)

folderpath = Path.cwd()
filename = "principais-imputados"
file_extension = ".csv"
labels, data, target = read_csv(folderpath / (filename + file_extension))
X = data
y = target

classifier = DecisionTreeClassifier(max_depth=12)
classifier.fit(X, y)

tree = Input_tree(
    list(classifier.tree_.children_left),
    list(classifier.tree_.children_right),
    list(classifier.tree_.feature),
    list(classifier.tree_.threshold),
    list(classifier.tree_.value),
)

converted_tree = convert(tree)

# for i in range(len(tree.children_left)):
#     print(i, tree.children_left[i], tree.children_right[i], tree.feature[i], tree.feature[i])

i = 0
for node in converted_tree.nodes:
    print(i, end=" ")
    print(node)
    i = i + 1

print(converted_tree.max_feature_index)
print(int(converted_tree.max_feature_index).bit_length())

plot_tree(classifier)


pyplot.show(block=False)
pyplot.savefig((filename + '.pdf'))
export(converted_tree, memory_filename=filename)
