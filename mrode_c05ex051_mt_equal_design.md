---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Multiple-trait model with equal design matrix and no missing observations
=========================================================================

Model
-----

Here we consider a multiple-trait model with equal design matrices, which means the same model is applied to all traits. We will consider a situation without missing observations.

In this example, the author considers the 2-trait model for the pre-weaning gain as the first trait (WWG) and the post-weaning gain as the second trait (PWG). Both traits have the same model that is, the fixed effect for sex, and two random effects, the additive genetic effect, and the residual effect.

We also consider the genetic covariance between two traits as well as the genetic variance for each trait. This is true for residual covariance components. The genetic covariance matrix ($\mathbf{G}_0$) and the residual covariance matrix $\mathbf{R}_0$ are both symmetric matrices ($2 \times 2$). The values are defined in the textbook as
$$
\mathbf{G}_{0}
=
\left[
\begin{array}{rr}
20&18\\
18&40
\end{array}
\right]
\quad
\text{and}
\quad
\mathbf{R}_{0}
=
\left[
\begin{array}{rr}
40&11\\
11&30
\end{array}
\right]
$$

A matrix notation of the above model and its mixed model equations have already introduced in the previous chapter. So here we just show some relevant equations. The model can be written as
$$
\mathbf{y} = \mathbf{Xb} + \mathbf{Zu} + \mathbf{e}.
$$
We have 2 options to order the observations in $\mathbf{y}$ (within-trait or within-animal). According to a discussion in the previous chapter, BLUPF90 orders the observations within-animal (see the previous chapter for details). The variance of $\mathbf{y}$ is
$$
\mathrm{var}(\mathbf{y}) = \mathbf{Z}\left(\mathbf{A} \otimes \mathbf{G}_{0}\right)\mathbf{Z}' + \mathbf{I} \otimes \mathbf{R}_{0}
$$
where $\otimes$ is the operator for Kronecker product. The mixed model equations can be written as
$$
\left[
\begin{array}{ll}
\mathbf{X}'(\mathbf{I}\otimes\mathbf{R}_{0}^{-1})\mathbf{X} & \mathbf{X}'(\mathbf{I}\otimes\mathbf{R}_{0}^{-1})\mathbf{Z} \\
\mathbf{Z}'(\mathbf{I}\otimes\mathbf{R}_{0}^{-1})\mathbf{X} & \mathbf{Z}'(\mathbf{I}\otimes\mathbf{R}_{0}^{-1})\mathbf{Z} + \mathbf{A}^{-1}\otimes\mathbf{G}^{-1}_{0}
\end{array}
\right]
\left[
\begin{array}{c}
\mathbf{\hat{b}}\\
\mathbf{\hat{u}}
\end{array}
\right]
=
\left[
\begin{array}{l}
\mathbf{X}'(\mathbf{I}\otimes\mathbf{R}_{0}^{-1})\mathbf{y} \\
\mathbf{Z}'(\mathbf{I}\otimes\mathbf{R}_{0}^{-1})\mathbf{y}
\end{array}
\right]
$$


Files
-----

The data file (`data_mr05a.txt`) is actually an extension of Example 3.1. It has an extra observation in the last column.

1. Animal ID (calves)
2. Sire ID
3. Dam ID
4. Pre-weaning gain (WWG; kg)
5. Post-weaning gain (PWG; kg)

The pedigree file (`pedigree_mr05a.txt`) is also the same as the previous one.

The parameter file contains 2 covariance matrices. We will compute the standard error of each estimate as to the square root of the corresponding diagonal element of the inverse of the left-hand side of mixed model equations.

~~~~~{language=blupf90 caption="param_mr05a.txt"}
DATAFILE
data_mr05a.txt
NUMBER_OF_TRAITS
2
NUMBER_OF_EFFECTS
2
OBSERVATION(S)
5 6
WEIGHT(S)

EFFECTS:
2 2 2 cross
1 1 8 cross
RANDOM_RESIDUAL VALUES
40.0 11.0
11.0 30.0
RANDOM_GROUP
2
RANDOM_TYPE
add_animal
FILE
pedigree_mr05a.txt
(CO)VARIANCES
20.0 18.0
18.0 40.0
OPTION solv_method FSPAK
OPTION sol se
~~~~~

Solutions
---------

The file `solution` has the solutions for the first and second traits. The solutions are identical to the values shown in the textbook (p.74).

The reliability of the estimated breeding value of an animal can be calculated with the solutions from BLUPF90. The reliability for trait $j$ of animal $i$ ($r_{ij}^2$) is
$$
r_{ij}^2=1-\frac{\mathrm{PEV}_{ij}}{\sigma_{u_j}^{2}}
$$
where $\mathrm{PEV}_{ij}$ is the diagonal element of the inverse of the left-hand side of mixed model equations corresponding to the effect to be considered. In the above solutions, the column `s.e.` contains the square root of the inverse ($\sqrt{\mathrm{PEV}_{ij}}$). For example, the reliabilities of animal 1 can be calculated as:
$$
r_{11}^2=1-\frac{4.313320612^2}{20}\approx 0.070
\quad
\text{and}
\quad
r_{21}^2=1-\frac{5.991809902^2}{40}\approx 0.102.
$$
