---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Animal model with dominance effect
==================================

Model
-----

Linear mixed models can handle a non-additive genetic model with dominance or epistatic
relationship matrices. In the dominance model, we can consider the additive genetic effect and the
dominance effect simultaneously. In this example, the author assumes the animal model
with one fixed effect, the additive genetic effect, the dominance effect, and the residual effect.
In this example,
the additive variance $\sigma_u^2 = 90$, the dominance variance $\sigma_d^2 = 80$, and the residual variance $\sigma_e^2 = 120$.
BLUPF90 doesn't have a function to calculate $\mathbf{D}^{-1}$, so we need to supply the elements as a file to the program.

Files
-----

A data file (`data_mr12a.txt`) should be prepared.
The pedigree file (`pedigree_mr12a.txt`) is also created.

The inverse of the dominance relationship matrix is supplied as a text file. See the textbook for details (p.207).

~~~~~{language=text caption="userinverse_mr12a.txt"}
 1  1  1.000
 2  2  1.000
...
11 12 -0.241
12 12  1.092
~~~~~

The parameter file defines 2 random effects.

~~~~~{language=blupf90 caption="param_mr12a.txt"}
DATAFILE
data_mr12a.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
3
OBSERVATION(S)
5
WEIGHT(S)

EFFECTS:
4  2 cross # fixed effect
1 12 cross # additive effect
1 12 cross # dominance effect
RANDOM_RESIDUAL VALUES
120.0
RANDOM_GROUP
2
RANDOM_TYPE
add_animal
FILE
pedigree_mr12a.txt
(CO)VARIANCES
90.0
RANDOM_GROUP
3
RANDOM_TYPE
user_file
FILE
userinverse_mr12a.txt
(CO)VARIANCES
80.0
OPTION solv_method FSPAK
~~~~~

Solutions
---------

The solutions are identical to the reference values in the textbook (p.207).
