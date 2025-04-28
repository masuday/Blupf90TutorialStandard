---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Repeatability model
===================

Model
-----

A repeatability model is an animal model applicable when an animal has more than 1 observations. In such a case, we can split the residual effect into 2: "true" temporary environmental effect and a permanent environmental effect which belongs to the animal. So the model contains 2 kinds of animal effects (additive genetic and permanent environmental effects).

The author assumes the repeatability model in Example 4.1 for fat yield in dairy cattle. The model has the fixed effects for parity and Herd-Year-Season, the additive genetic effect for the same animal, the permanent environmental effect for an animal, and the random residual effect. The author assumes the genetic variance is 20, the residual variance is 28, and the permanent-environmental variance is 12.

Files
-----

Data file (`data_mr04a.txt`) just contains the table shown at p.63 in the textbook. This file has 6 columns. Column 2 and 3 are not actually used in this analysis.

1. Animal ID (cow)
2. Sire ID
3. Dam ID
4. Parity (1 or 2)
5. HYS (from 1 to 4)
6. Fat yield (kg)

The pedigree file (`pedigree_mr04a.txt`) can be prepared as an usual, 3-column file.

This model contains 2 random effects besides the random error. The permanent environmental effects are not related to each other so you should use `diagonal` in the `RANDOM_TYPE` keyword. The position of permanent environmental effects is, in this case, the same as the additive genetic effects, because both effects are animal's individual effects - the only difference is the covariance structure. The parameter file is as follows.

~~~~~{language=blupf90 caption="param_mr04a.txt"}
DATAFILE
data_mr04a.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
4
OBSERVATION(S)
6
WEIGHT(S)

EFFECTS:
5 4 cross
4 2 cross
1 8 cross  # for additive genetic effect
1 8 cross  # for permanent environmental effect
RANDOM_RESIDUAL VALUES
28.0
RANDOM_GROUP   # additive genetic effect
3
RANDOM_TYPE
add_animal
FILE
pedigree_mr04a.txt
(CO)VARIANCES
20.0
RANDOM_GROUP  # permanent environmental effect
4
RANDOM_TYPE
diagonal
FILE

(CO)VARIANCES
12.0
OPTION solv_method FSPAK
~~~~~

Solutions
---------

The BLUPF90 calculates the solutions (not shown here) with the above parameter file. The left-hand side of the mixed model equations is not full rank and 2 solutions for fixed effects are replaced with 0. The positions of the zero-constraints are different from the textbook (p.64; Parity 1 and 2 here vs HYS 1 and 3 in the textbook). As before, a linear contrast is the same in both cases. BLUP for random effects is the same as the textbook. Solutions for PE for animal 1 to 3 are 0 (the expected value as a random effect with no information) because they have no observations. In this case, column 1 was shared for additive genetic and permanent environmental effects.


Putting arbitrary zero-constraints manually
-------------------------------------------

There is a trick to manually put user-defined zero-constraints on the mixed model equations. You can replace the target effect code in the data file with 0. This technique has been introduced in the previous section for unknown parent groups. The alternative data file (`data_mr04a1.txt`) provides the same solutions shown in the text file.

In the textbook, the author puts constraints on HYS 1 and 3. The 5th column in the above file has 0 for HYS 1 and 3. You can rewrite the parameter file to read the new data file; just change the `DATAFILE` block. Run BLUPF90 with the modified parameter file, and you can see different solutions.

Be careful if you use the manual constraints. If you put too many constraints on the equation, the solutions will make no sense.
