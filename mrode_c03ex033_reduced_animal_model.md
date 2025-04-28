---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Reduced animal model
====================

Model
-----

The reduced animal model is an animal model except that the model includes only parents (that is animals with progeny). Breeding values for animals without progeny will be indirectly calculated using their parents' breeding values. We omit the description of the model and theory here. See the textbook for details or Quaas and Pollak (1980) for details.

BLUPF90 does not directly support the reduced animal model, but it still handles it using (very) tricky ways. Some techniques used here will also be used in random regression models and social interaction models. Although there are several ways to perform reduced animal model in BLUPF90, we here introduce an educational example which is redundant but easier to understand.

Files
-----

We can use the same pedigree file (`pedigree_mr03c.txt`) to the previous animal model except for removing animals without progeny (animal 7 and 8 in this case).

The data file is extended with 5 additional columns. We here show few lines of the data file.

~~~~~{language=text caption="data_mr03c.txt"}
4 1 1 0 4.5  4 0.0 0.0 1.0  1.0
...
7 1 4 5 3.5  0 0.5 0.5 0.0  0.8
...
~~~~~

The 6th column (the first additional column) is animal ID but has 0 if the animal has no progeny. Columns 7, 8, and 9 contain actual values to be added to the incidence matrix W (see the textbook). This idea is similar to a way to support random regressions. The columns 7 and 8 are 0.0 if the animal is a parent, or 0.5 otherwise. Column 9 is 1.0 if the animal is a parent, or 0 otherwise.

The column 10 (the last column) contains a weight to adjust residual variance. For parent animals, the residual variance is $\sigma_e^2 = 40$ and its inverse is $1/\sigma_e^2 = 0.025$. For non-parents, in this case, the residual variance should be $\sigma_e^{2*}=\sigma_e^2+0.5\sigma_u^2= 40 + 0.5 \times 20 = 50$ and its inverse is $1/\sigma_e^{2*} = 0.020$. If the non-parent animal has missing parent, you should set different weight on $\sigma_u^2$ (see the textbook). We use `WEIGHT(S)` to alter the residual variances. The program reads the weight from the data file and multiplies it by the inverse of residual variance. In our example, the weight is 1.0 for parent animals and 0.8 for non-parent animals because $0.8 \times (1/\sigma_e^2) = 0.8 \times 0.025 = 0.020$ and it is the correct value for non-parent animals.

One issue is how to add these constants to $\mathbf{W}$. BLUPF90 can usually add only values of 1 to the incidence matrix per record for a cross-classified effect. To overcome this limitation, we introduce a tricky description in the `EFFECT:` block in a parameter file.

~~~~~{language=blupf90 caption="param_mr03c.txt"}
DATAFILE
data_mr03c.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
4
OBSERVATION(S)
5
WEIGHT(S)
10
EFFECTS:
2 2 cross
7 0 cov 3
8 0 cov 4
9 6 cov 6
RANDOM_RESIDUAL VALUES
40.0
RANDOM_GROUP
4
RANDOM_TYPE
add_animal
FILE
pedigree_mr03c.txt
(CO)VARIANCES
20.0
OPTION solv_method FSPAK
~~~~~

In the `EFFECTS:` block, the last 3 statements pass the value in the data file through the incidence matrix. You can see these 3 effects are in one block and only the last statement `9 6 cov 6` define the number of levels (that is the number of animals). For each statement, the program reads the value from the data file (the position is in the first number of that line) and recognizes it as a covariate (because of the `cov` keyword) and puts it into the location in the design matrix corresponding to an animal ID (the location is defined by the number after `cov`).

Let's see what happens when the program process these 3 statements for each record. We consider the first line of the data file.

~~~~~{language=text}
4 1 1 0 4.5       4 0.0 0.0 1.0        1.0
~~~~~

- Processing the statement 2 (`7 0 cov 3`): the program reads the 7th column from the data, and recognizes it as a real value (0.0), and adds it to $\mathbf{W}$ at the location defined by the 3rd column in the data file (1st column in $\mathbf{W}$).
- Processing the statement 3 (`8 0 cov 4`): the program reads the 8th column from the data, and recognizes it as a real value (0.0), and adds it to $\mathbf{W}$ at the location defined by the 4th column in the data file (the location 0; it is ignored).
- Processing the statement 4 (`9 6 cov 6`): the program reads the 9th column from the data, and recognizes it as a real value (1.0), and adds it to $\mathbf{W}$ at the location defined by the 6th column in the data file (4th column in $\mathbf{W}$).

After the process, the first row in $\mathbf{W}$ should be the following.
$$
\left[
\begin{array}{cccccc}
   0.0&0.0&0.0&1.0&0.0&0.0
\end{array}
\right]
$$

The we will see the 4th line of the data file.

~~~~~{language=text}
7 1 4 5 3.5       0 0.5 0.5 0.0        0.8
~~~~~

- Processing the statement 2 (`7 0 cov 3`): the program reads the 7th column from the data, and recognizes it as a real value (0.5), and adds it to $\mathbf{W}$ at the location defined by the 3rd column in the data file (4th column in $\mathbf{W}$).
- Processing the statement 3 (`8 0 cov 4`): the program reads the 8th column from the data, and recognizes it as a real value (0.5), and adds it to $\mathbf{W}$ at the location defined by the 4th column in the data file (5th column in $\mathbf{W}$).
- Processing the statement 4 (`9 6 cov 6`): the program reads the 9th column from the data, and recognizes it as a real value (0.0), and adds it to $\mathbf{W}$ at the location defined by the 6th column in the data file (the location 0; it is ignored).

After the process, the 4th row in $\mathbf{W}$ should be the following.
$$
\left[
\begin{array}{cccccc}
0.0& 0.0& 0.0& 0.5& 0.5& 0.0
\end{array}
\right]
$$

A similar technique will be used in a competitive model (social interaction model) which needs an incidence matrix where 2 or more elements take place in one row.


Solutions
---------

You can see the solutions are identical to the textbook (pp.53). You will find the other ways to use the reduced animal model using the same technique used above. Now BLUPF90 supports the heterogeneous residual variances. It may simplify the implementation of the reduced animal model. A curious reader can try this method.
