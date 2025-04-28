---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Random regression model
=======================

Model
-----

Assume longitudinal data measured over time. If the genetic correlation between observations taken in 2 time-points is lower than 1, the repeatability model is inappropriate.  In this case, a multiple-trait model, which assumes that an observation measured in a differnt time-period is a separate trait, could be better to describe the trait. If the time interval is shorter, we will have more traits. As the interval approaches to 0, ultimately, we will have an infinite number of traits, and genetic correlations can be described using a function of 2 time periods. The random environmental effects also have the same covariance structure. This is equivalent to the random regression model.

In this example, we fit the 2nd order Legendre polynomials (3 coefficients including the intercept) to both additive genetic and permanent environmental effects. In this model, each animal has 3 random coefficients for the additive genetic effect and the other 3 coefficients for the permanent environmental effect. See the textbook for details for detailed modeling.

There are correlations between random regressions. This looks like a maternal model with a direct and maternal genetic covariance matrix. In this model, we have 3 random regression coefficients, each of the random effects. So the variance components are $3 \times 3$ matrix in additive genetic ($\mathbf{G}_0$) and permanent environmental effects ($\mathbf{P}_0$). The actual covariance matrices are
$$
\mathbf{G}_{0}
=
\left[
\begin{array}{rrr}
3.297&  0.594& -1.381\\
0.594&  0.921& -0.289\\
-1.381& -0.289& 1.005
\end{array}
\right]
\quad
\text{and}
\quad
\mathbf{P}_{0}
=
\left[
\begin{array}{rrr}
 6.872& -0.254& -1.101\\
-0.254&  3.171&  0.167\\
-1.101&  0.167&  2.457
\end{array}
\right]
$$
and $\sigma_e^2=3.710$.


Files
-----

We use the same data and pedigree files to the previous section (`data_mr09b.txt` and `pedigree_mr09b.txt`).

The parameter file is an extension to the previous one.

~~~~~{language=blupf90 caption="param_mr09b.txt"}
DATAFILE
data_mr09b.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
12
OBSERVATION(S)
4
WEIGHT(S)

EFFECTS:
 3 10 cross  # HTD
 5  1 cov    # Legendre polynomials (intercept) for fixed regression
 6  1 cov    # Legendre polynomials (1st order) for fixed regression
 7  1 cov    # Legendre polynomials (2nd order) for fixed regression
 8  1 cov    # Legendre polynomials (3rd order) for fixed regression
 9  1 cov    # Legendre polynomials (4th order) for fixed regression
 5  8 cov 1  # Legendre polynomials (intercept) for additive genetic effect
 6  8 cov 1  # Legendre polynomials (1st order) for additive genetic effect
 7  8 cov 1  # Legendre polynomials (2nd order) for additive genetic effect
 5  8 cov 1  # Legendre polynomials (intercept) for permanent environmental effect
 6  8 cov 1  # Legendre polynomials (1st order) for permanent environmental effect
 7  8 cov 1  # Legendre polynomials (2nd order) for permanent environmental effect
RANDOM_RESIDUAL VALUES
3.710
RANDOM_GROUP
7 8 9
RANDOM_TYPE
add_animal
FILE
pedigree_mr09b.txt
(CO)VARIANCES
 3.297  0.594 -1.381
 0.594  0.921 -0.289
-1.381 -0.289  1.005
RANDOM_GROUP
10 11 12
RANDOM_TYPE
diagonal
FILE

(CO)VARIANCES
 6.872 -0.254 -1.101
-0.254  3.171  0.167
-1.101  0.167  2.457
OPTION solv_method FSPAK
~~~~~

The additive genetic effect is defined for effects 7, 8, and 9 and the permanent environmental effect is defined for effects 10, 11, and 12. Both have a similar definition so we just explain the additive effect. Now we look at effect 7:

    5    8 cov 1

This refers to column 5 as an intercept of the regression. Because we have 8 animals in total so we should estimate 8 intercepts. The above statement means that column 5 is treated as a covariate and the regression is nested within the animal (column 1). The remaining 2 statements can be similarly interpreted. The corresponding `RANDOM_GROUP` statement contains 3 effects: 7, 8, and 9, so we need a $3 \times 3$ genetic covariance matrix.


Solutions
---------

The equations are not full rank so there are infinite solutions for fixed effects. The solutions for random effects are slightly different from the values in the textbook due to numerical error, but very similar.

Additive genetic random regressions are defined as effects 7, 8, and 9. For these effects, the number of levels is the maximum animal ID. With a random regression model, estimated breeding values for an animal are presented as regression coefficients. In this case, each animal has 3 coefficients. For example, breeding values for animal 3 are
$$
u_3
=
\left[
\begin{array}{r}
0.13166310\\
-0.02908467\\
0.07039573
\end{array}
\right].
$$
