---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Fixed regression model
======================

Model
-----

When repeated measurements are considered as the same traits over time, a repeatability model can be suitable to apply. The assumption in this situation is that the genetic correlation between observations measured at any two time-points is 1. Even if the assumption is correct, the actual observations would have an average curve by a group over time. This non-genetic, systematic change can be modeled by fixed regression curves.

The author shows the test day measurements of fat yield in dairy cattle. A repeatability model with a fixed regression curve is assumed. See the textbook for details for the details. The variance components are $\sigma_u^2 =5.521$, $\sigma_p^2 = 8.470$, and $\sigma_e^2 = 3.710$.

Usually, fixed regressions are nested within an environmental class. It models the fact that an average trajectory can be differentiated depending on the specific environment nested within, for instance, herd, region, season, age, parity, and so on. This example is small, so the nested fixed regressions are not considered.


Files
-----

The author shows the data set (`data_mr09a.txt`). The Legendre polynomials should be prepared by the user and saved in the data file. The following is the detail of this data.

~~~~~{language=text caption="data_mr09a.txt"}
 4   4  1 17.0  0.7071 -1.2247  1.5811 -1.8708  2.1213
 4  38  2 18.6  0.7071 -0.9526  0.6442 -0.0180 -0.6205
 4  72  3 24.0  0.7071 -0.6804 -0.0586  0.7571 -0.7757
...
~~~~~

1.  Animal ID (cow)
2.  Days in milk (DIM)
3.  Herd-test-day class
4.  Test day fat yield
5.  0th order Legendre covariable $\phi_0$ (intercept)
6.  1st order Legendre covatiable $\phi_1$
7.  2nd order Legendre covariable $\phi_2$
8.  3rd order Legendre covariable $\phi_3$
9.  4th order Legendre covariable $\phi_4$


The pedigree is the same as Example 4.1 (`pedigree_mr09a.txt`).

The parameter file is shown below.

~~~~~{language=blupf90 caption="param_mr09a.txt"}
DATAFILE
data_mr09a.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
8
OBSERVATION(S)
4
WEIGHT(S)

EFFECTS:
 3 10 cross    # HTD
 5  1 cov      # Legendre polynomials (intercept)
 6  1 cov      # Legendre polynomials (1st order)
 7  1 cov      # Legendre polynomials (2nd order)
 8  1 cov      # Legendre polynomials (3rd order)
 9  1 cov      # Legendre polynomials (4th order)
 1  8 cross    # for additive genetic effect
 1  8 cross    # for permanent environmental effect
RANDOM_RESIDUAL VALUES
3.710
RANDOM_GROUP
7
RANDOM_TYPE
add_animal
FILE
pedigree_mr09a.txt
(CO)VARIANCES
5.521
RANDOM_GROUP
8
RANDOM_TYPE
diagonal
FILE

(CO)VARIANCES
8.470
OPTION solv_method FSPAK
~~~~~

Solutions
---------

The equations have a dependency so the solutions for fixed effects are not unique. Besides the fixed effects, the results from BLUPF90 are slightly different from the textbook.
