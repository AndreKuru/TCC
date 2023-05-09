from sklearn.datasets import load_wine
from sklearn.tree import DecisionTreeClassifier, plot_tree
from Converter import Input_tree, convert
from exporter import export
from matplotlib import pyplot


X, y = load_wine(return_X_y = True,as_frame = True )

classifier = DecisionTreeClassifier()
classifier.fit(X,y)

tree = Input_tree(
    list(classifier.tree_.children_left),
    list(classifier.tree_.children_right),
    list(classifier.tree_.feature),
    list(classifier.tree_.threshold)
)

converted_tree = convert(tree)

# for i in range(len(tree.children_left)):
#     print(i, tree.children_left[i], tree.children_right[i], tree.feature[i], tree.feature[i])

i = 0
for node in converted_tree:
    i = i + 1
    print(i,end=' ')
    print(node)

plot_tree(classifier, fontsize=10)
pyplot.show()


# export(converted_tree)