from sklearn.datasets import load_wine
from sklearn.tree import DecisionTreeClassifier
from Converter import Input_tree, convert

X, y = load_wine(return_X_y = True,as_frame = True )

classifier = DecisionTreeClassifier()
classifier.fit(X,y)

tree = Input_tree(
    list(classifier.tree_.children_left),
    list(classifier.tree_.children_right),
    list(classifier.tree_.feature),
    list(classifier.tree_.threshold)
)

converted_tree = convert(classifier.tree_)

for node in converted_tree:
    print(node)