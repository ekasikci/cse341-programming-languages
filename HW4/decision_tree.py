from sklearn.datasets import load_iris
from sklearn.tree import DecisionTreeClassifier, plot_tree
import matplotlib.pyplot as plt
from sklearn.tree import export_text
from ucimlrepo import fetch_ucirepo

# fetch dataset
iris = fetch_ucirepo(id=53)

# data (as pandas dataframes)
X = iris.data.features
y = iris.data.targets

# metadata
print(iris.metadata)

# variable information
print(iris.variables)

# Fit a decision tree
tree_clf = DecisionTreeClassifier()
tree_clf.fit(X, y)

# Plot the tree
plt.figure(figsize=(20,10))
plot_tree(tree_clf, feature_names=iris.feature_names, class_names=iris.target_names, filled=True)
plt.show()
decision_rules = export_text(tree_clf, feature_names=iris.feature_names)

print(decision_rules)