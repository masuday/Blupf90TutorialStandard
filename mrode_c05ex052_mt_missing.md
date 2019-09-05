---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Multiple-trait model with equal design matrix and missing records
=================================================================

Model
-----

Here we apply the same model described in the previous example to the data with missing
observations. Model descriptions and mixed model equations are identical as before.

With a missing observation, $\mathbf{R}_0$ and its inverse should be altered. For example, assuming a 2
trait model, if the observation of the first trait is missing, the first row and column in $\mathbf{R}_0$ should be
zeroed out. The corresponding inverse is the generalized inverse of this altered $\mathbf{R}_0$. Illustrating this
situation with the previous example, the result is
$$
\mathbf{R}_{0}
=
\left[
\begin{array}{rr}
0&0\\
0&30
\end{array}
\right]
\quad
\text{and}
\quad
\mathbf{R}_{0}^{-}
=
\left[
\begin{array}{rr}
0&0\\
0&30
\end{array}
\right]^{-}
=
\left[
\begin{array}{rr}
0&0\\
0&1/30
\end{array}
\right].
$$

The generalized inverse of this zeroed matrix is equivalent to the inverse of a matrix containing
only nonzero elements in the zeroed matrix (Searle, 1971).
BLUPF90 can detect a missing observation and prepares an appropriate $\mathbf{R}_{0}$ and its generalized
inverse.


Files
-----

One animal is added to the previous example and 2 observations are marked as missing.
The missing observation is indicated as 0, which is the default missing code used in the BLUPF90 family
(`data_mr05b.txt`).
We can use an extended pedigree file as the previous one by adding the animal 9 (`pedigree_mr05b.txt`).

The parameter file is also identical except for omitting an option for standard error calculations.

~~~~~{language=blupf90 caption="param_mr05b.txt"}
DATAFILE
data_mr05b.txt
NUMBER_OF_TRAITS
2
NUMBER_OF_EFFECTS
2
OBSERVATION(S)
5 6
WEIGHT(S)

EFFECTS:
2 2 2 cross
1 1 9 cross
RANDOM_RESIDUAL VALUES
40.0 11.0
11.0 30.0
RANDOM_GROUP
2
RANDOM_TYPE
add_animal
FILE
pedigree_mr05b.txt
(CO)VARIANCES
20.0 18.0
18.0 40.0
OPTION solv_method FSPAK
~~~~~

Solutions
---------

You can confirm the results are identical to the values in the textbook (p.80).
