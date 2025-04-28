---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Animal model for a maternal trait
=================================

Model
-----

For some traits, especially defined early in an animal's life, the phenotypes are largely affected by its dam. For example, weaning weight is expected to be associated with its dam's milk yield. The dam provides an environment for its progeny to increase (or decrease) their phenotypic values. The dam's contribution is assumed to consists of genetic and environmental factors. Also, the animal model includes the dam's contribution originally from a non-genetic background.

In this example, the author applied a typical maternal model. Simply, the model has two, correlated additive-genetic effects, the direct genetic effect due to the animal's genes and the maternal genetic effect due to the dam's contribution. Assume the following model:
$$
\mathbf{y} = \mathbf{Xb} + \mathbf{Zu} + \mathbf{Wm} + \mathbf{Sp} + \mathbf{e}
$$
where $\mathbf{y}$ is a vector of observations, $\mathbf{b}$ is a vector of fixed effects, $\mathbf{u}$ is a vector of direct genetic effects, $\mathbf{m}$ is a vector of maternal genetic effects, $\mathbf{p}$ is a vector of maternal permanent-environmental effects, $\mathbf{e}$ is a vector of residual effects, and other matrices are incidence matrices. The covariance structure is typically assumed as
$$
\mathrm{var}
\left[
\begin{array}{l}
\mathbf{u}\\
\mathbf{m}\\
\mathbf{p}\\
\mathbf{e}
\end{array}
\right]
=
\left[
\begin{array}{llll}
\mathbf{A}\sigma_{d}^2&\mathbf{A}\sigma_{dm}&\mathbf{0}&\mathbf{0}\\
\mathbf{A}\sigma_{md}&\mathbf{A}\sigma_{d}^2&\mathbf{0}&\mathbf{0}\\
\mathbf{0}&\mathbf{0}&\mathbf{I}\sigma_{p}^2&\mathbf{0}\\
\mathbf{0}&\mathbf{0}&\mathbf{0}&\mathbf{I}\sigma_{e}^2\\
\end{array}
\right]
$$
where $\sigma_u^2$ is the direct genetic variance, $\sigma_m^2$ is the maternal genetic variance, $\sigma_{dm}$ is the covariance between direct and maternal genetic effects, $\sigma_p^2$ is the permanent environmental variance and $\sigma_e^2$ is the residual variance. Note that this model contains a genetic covariance matrix ($\mathbf{G}_0$) even though this is a single-trait model. In this numerical example, the covariance component is
$$
\mathbf{G}_{0}
=
\left[
\begin{array}{ll}
\sigma_{d}^2&\sigma_{dm}\\
\sigma_{md}&\sigma_{m}^2
\end{array}
\right]
=
\left[
\begin{array}{ll}
150&-40\\
-40&90
\end{array}
\right]
$$
and $\sigma_p^2=40$ and $\sigma_e^2=350$.


Files
-----

The data set is shown at p.111 (`data_mr07a.txt`).

   1. Animal ID (Calf)
   2. Sire ID
   3. Dam ID
   4. Herds
   5. Pen
   6. Birth weight (kg)

The pedigree is derived from the above data (`pedigree_mr07a.txt`).

The parameter file should be as follows.

~~~~~{language=blupf90 caption="param_mr07a.txt"}
DATAFILE
data_mr07a.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
5
OBSERVATION(S)
6
WEIGHT(S)

EFFECTS:
 4  3 cross  # herd
 5  2 cross  # pen
 1 14 cross  # direct genetic effect
 3 14 cross  # maternal genetic effect
 3  7 cross  # maternal permanent effect
RANDOM_RESIDUAL VALUES
350.0
RANDOM_GROUP
3 4
RANDOM_TYPE
add_animal
FILE
pedigree_mr07a.txt
(CO)VARIANCES
150.0 -40.0
-40.0  90.0
RANDOM_GROUP
5
RANDOM_TYPE
diagonal
FILE

(CO)VARIANCES
40.0
OPTION solv_method FSPAK
~~~~~

In this model, we consider 5 effects (herd, pen, direct genetic, maternal genetic and maternal environmental effects). The first 2 effects are fixed. The 3rd effect is for direct genetic effects so the number of levels should be 14 (that is the number of animals found in the pedigree). The 4th effect is for maternal genetic effect; here you can put the position of dam's ID. Note that the number of levels must be 14 because the maternal effect is correlated with the direct effect and the direct effect has 14 levels (in the pedigree). In other words, each animal has both direct breeding value and maternal breeding value and the solutions will be calculated for all 14 animals. The 5th column is for maternal permanent environmental effect. This effect does not consider the pedigree file; it will only be estimated for dams with records in the data file. So the number of levels is only 7, because the maximum number of dam ID in the data is 7, although the position of effect is the same as the previous
one.[^2]

[^2]: In this case, even if you put 14 as the number of levels in the 5th effect, the program correctly works. The program can work when you put a larger number of levels than the actual number.


The direct genetic effect and the maternal genetic effect are correlated. These effects are simultaneously listed in `RANDOM_GROUP`, which has `3 4`. This is still an animal model and you can specify `add_animal` and the pedigree file. This is a single-trait model but it has 2 correlated genetic effects so the covariance matrix ($\mathbf{G}_0$) should be $2 \times 2$ written in `(CO)VARIANCES`.

We have one more maternal effect which is an independent random effect. You just put 5 after `RANDOM_GROUP`. The type is diagonal. You do not need a pedigree file here. Only one variance component is required in `(CO)VARIANCES`.


Solutions
---------

You can confirm that the estimated direct and maternal breeding values are identical to the textbook (p.113).

As noted in the textbook, this equation has a dependency between fixed effects so we will have an infinite number of solutions for fixed effects. Above solutions are one of them. If you want to obtain the same solutions presented in the textbook, you can replace 1 with 0 for herd number in the data file and run BLUPF90 again. You can see that the solutions for the fixed effects are different from the previous results. The solutions for random effects will remain unchanged.
