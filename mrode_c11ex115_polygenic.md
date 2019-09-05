---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Mixed linear models with polygenic effects
==========================================

Model
-----

See the textbook for the details.

Files and solutions for SNP-BLUP
--------------------------------

First, we perform the SNP-BLUP analysis.
The data file (`data_mr11d1.txt`) is from the previous example.

We can use the same pedigree defined before (`pedigree_mr11d1.txt`).

The parameter file contains 10 SNP effects with the residual polygenic effects.

~~~~~{language=blupf90 caption="param_mr11d1.txt"}
DATAFILE
data_mr11d1.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
12
OBSERVATION(S)
6
WEIGHT(S)

EFFECTS:
 4  1 cross   # general mean
 1 26 cross   # residual polygenic effects
 8  1 cov     # SNP effect 1
 9  1 cov     # SNP effect 2
10  1 cov     # SNP effect 3
11  1 cov     # SNP effect 4
12  1 cov     # SNP effect 5
13  1 cov     # SNP effect 6
14  1 cov     # SNP effect 7
15  1 cov     # SNP effect 8
16  1 cov     # SNP effect 9
17  1 cov     # SNP effect 10
RANDOM_RESIDUAL VALUES
245.0
RANDOM_GROUP  # polygenic effect
2
RANDOM_TYPE
add_animal
FILE
pedigree_mr11d1.txt
(CO)VARIANCES
3.5241
RANDOM_GROUP  # jointly considering independent 10 SNP effects
3 4 5 6 7 8 9 10 11 12
RANDOM_TYPE
diagonal
FILE

(CO)VARIANCES
8.9636 0 0 0 0 0 0 0 0 0
0 8.9636 0 0 0 0 0 0 0 0
0 0 8.9636 0 0 0 0 0 0 0
0 0 0 8.9636 0 0 0 0 0 0
0 0 0 0 8.9636 0 0 0 0 0
0 0 0 0 0 8.9636 0 0 0 0
0 0 0 0 0 0 8.9636 0 0 0
0 0 0 0 0 0 0 8.9636 0 0
0 0 0 0 0 0 0 0 8.9636 0
0 0 0 0 0 0 0 0 0 8.9636
OPTION solv_method FSPAK
~~~~~

You can check the solutions.
See the reference values in the textbook
(p.190).

Files and solutions for GBLUP
-----------------------------

In this example with GBLUP, we use a text file for $\mathbf{G}_{w}^{-1}$ created with PREGSF90 in the previous section (the
first approach). See the instruction and prepare the file.

The data file (`data_mr11d2.txt`) is also common to the previous one.

The pedigree file is the same as SNP-BLUP.

The parameter file is shown below.

~~~~~{language=blupf90 caption="param_mr11d2.txt"}
DATAFILE
data_mr11d2.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
3
OBSERVATION(S)
6
WEIGHT(S)

EFFECTS:
4  1 cross
1 26 cross  # residual polygenic effect
8 14 cross  # new ID (renumbered only for genotyped animals)
RANDOM_RESIDUAL VALUES
245.0
RANDOM_GROUP
2
RANDOM_TYPE
add_animal
FILE
pedigree_mr11d2.txt
(CO)VARIANCES
3.5241
RANDOM_GROUP
3
RANDOM_TYPE
user_file
FILE
Gi
(CO)VARIANCES
31.717
OPTION solv_method FSPAK
~~~~~

The solutions are available by running the program.
