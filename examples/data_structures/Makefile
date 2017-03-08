FSTAR_HOME=../..
include ../Makefile.include
all: uall

uall: BinaryTrees.uver bst RBTree.uver vector

bst: BinarySearchTree.uver BinarySearchTree0.uver BinarySearchTreeBasic.uver BinarySearchTreeFirst.uver

vector:
	$(FSTAR) --explicit_deps ArrayRealized.fst Vector.fst

CFSTAR=$(subst CURRENT_DIR,examples/data_structures,$(CVERFSTAR))
all-cver: BinaryTrees.ucver BinarySearchTree.ucver BinarySearchTree0.ucver BinarySearchTreeBasic.ucver BinarySearchTreeFirst.ucver RBTree.ucver
	$(CFSTAR) --explicit_deps ArrayRealized.fst Vector.fst
