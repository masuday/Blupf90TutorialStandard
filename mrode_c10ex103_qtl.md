---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Directly predicting the additive genetic merit with QTL
=======================================================

Model
-----

There is an approach to directly predict an animal’s marker genetic merit. The QTL relationship matrix ($\mathbf{G}_v$) can be reduced to a relationship matrix among animals ($\mathbf{A}_v$). The mathematical model contains fixed effects, additive polygenic effects and additive genetic effects related to the marker. The system of mixed model equations is
$$
\left[
\begin{array}{lll}
\mathbf{X}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{X}'\mathbf{R}^{-1}\mathbf{Z} & \mathbf{X}'\mathbf{R}^{-1}\mathbf{W}\\
\mathbf{Z}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{Z}'\mathbf{R}^{-1}\mathbf{Z} + \mathbf{A}_{u}^{-1}/\sigma_u^{2} & \mathbf{Z}'\mathbf{R}^{-1}\mathbf{W}\\
\mathbf{W}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{W}'\mathbf{R}^{-1}\mathbf{Z} & \mathbf{W}'\mathbf{R}^{-1}\mathbf{W} + \mathbf{A}_{v}^{-1}/\sigma_q^{2}\\
\end{array}
\right]
\left[
\begin{array}{c}
\mathbf{\hat{b}}\\
\mathbf{\hat{u}}\\
\mathbf{\hat{q}}
\end{array}
\right]
=
\left[
\begin{array}{l}
\mathbf{X}'\mathbf{R}^{-1}\mathbf{y} \\
\mathbf{Z}'\mathbf{R}^{-1}\mathbf{y} \\
\mathbf{W}'\mathbf{R}^{-1}\mathbf{y}
\end{array}
\right].
$$
The author assumes $\sigma_u^2 = 0.30$, $\sigma_q^2 = 0.10$, and $\sigma_e^2 = 0.60$.


Files
-----

We use the same data set as the previous example except for removing the paternal and maternal QTL effects (`data_mr10b.txt`). An explanation for each column is given as follows.

1. Animal ID (calf)
2. Sex (1=male and 2=female)
3. Sire ID
4. Dam ID
5. Post weaning weight (kg)

The pedigree file is also the same as before (`pedigree_mr10b.txt`). It has the 4th column with the inb/upg code.

In this case, we should prepare $\mathbf{A}_{v}^{-1}$ as an user-supplied file. The following file contains its diagonal and upper-triangular elements.

~~~~~{language=text caption="userinverse_mr10b.txt"}
  1 1  4.966
  1 2  0.286
  1 3 -0.148
...
  4 4  5.978
  4 5 -2.971
  5 5  4.836
~~~~~

The parameter file is as follows.

~~~~~{language=blupf90 caption="param_mr10b.txt"}
DATAFILE
data_mr10b.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
3
OBSERVATION(S)
5
WEIGHT(S)

EFFECTS:
2 2 cross    # fixed effect
1 5 cross    # additive polygenic effect
1 5 cross    # additive QTL effect
RANDOM_RESIDUAL VALUES
0.60
RANDOM_GROUP
2
RANDOM_TYPE  # considering inbreeding
add_an_upginb
FILE
pedigree_mr10b.txt
(CO)VARIANCES
0.30
RANDOM_GROUP
3
RANDOM_TYPE  # reading user-supplied file
user_file
FILE         # its file name
userinverse_mr10b.txt
(CO)VARIANCES
0.10
OPTION solv_method FSPAK
~~~~~

Solutions
---------

You can confirm the solutions are identical to the textbook.
