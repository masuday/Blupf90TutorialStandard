---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

The threshold model
===================

Model
-----

Some traits show categorical responses which can be potentially ordered by degree e.g., calving
difficulty (easy, slightly difficult, or difficult) and disease (no treatment needed, treated, or died).
For such traits, although the phenotype is not continuous, we can still assume that both genetic and
environmental factors affect the traits and there is the polygenic effect. In this case, it is a
reasonable model that each animal has a non-observable, hypothetical random variable like
a phenotype in a continuous trait, and such a variable contributes to the categorical response.
In this model, various factors can contribute to the underlying variable. When the
variable exceeds a certain level, it expresses the different category of response. This is a basic idea
of the threshold model and the variable is called liability and the level is known as the threshold.
The liability is usually assumed to be normally distributed in an underlying scale. We can apply
a linear model to the underlying variable. In this theory, the number of thresholds is equivalent to
the number of categories minus 1.

The author cites a well-known data set originally provided by Gianola and Foulley (1983). The
trait is calving ease with 3 categories. The sire model for liability is as follows:
$$
l_{ijkl} = H_i +C_j + s_k + e_{ijkl}
$$
where $l_{ijkl}$ is the liability, $H_i$ and $C_j$ are the fixed effects, $s_k$ is the random sire effect and $e_{ijkl}$ is the
residual. The variance components are $\sigma_s^2 = 1/19 = 0.0526$ and $\sigma_e^2 = 1.0$.

The BLUPF90 family used to have several software to handle the threshold. Now THRGIBBS1F90
is the only publicly available program. This is Gibbs sampler so we need many samples to estimate
the location parameters as the posterior means.


Files
-----

The pedigree file is prepared for the sire model.

~~~~~{language=text caption="pedigree_mr13a.txt"}
 1 0 0
...
~~~~~

The items are different from the animal model.

1. Animal (sire) ID
2. Sire (sire of sire) ID
3. Maternal grand sire ID

The data file is shown below. All the phenotype should be written in the flat file. There are 28
observations from 28 calves (p.223).

<!-- I leave it because it is a publicly available data set. -->
<!--
~~~~~{language=text caption="data_mr13a.txt"}
1 1 1 1   1
1 2 1 1   2
1 1 1 1   3
1 2 2 2   4
1 1 2 1   5
1 1 2 3   5
1 2 2 1   6
1 2 2 1   6
1 2 2 1   6
1 1 3 1   7
1 1 3 2   7
1 2 3 2   8
1 1 3 1   9
2 2 1 1  10
2 2 1 1  10
2 1 1 1  11
2 1 1 3  12
2 2 2 1  13
2 2 2 3  13
2 1 2 1  14
2 2 3 2  15
2 1 3 3  16
2 1 4 2  17
2 2 4 1  18
2 2 4 1  19
2 2 4 1  19
2 1 4 1  20
2 1 4 1  20
~~~~~
-->
~~~~~{language=text caption="data_mr13a.txt"}
1 1 1 1   1
...
2 1 4 1  20
~~~~~

The file has the 4th column just to show the original row in the table.

1. Herd ($H_i$)
2. Sex ($S_j$); 1=male and 2=female
3. Sire of calf ($s_k$)
4. The row in the original table corresponding to the data line.

The parameter file is similar to the standard one except some options.

~~~~~{language=blupf90 caption="param_mr13a.txt"}
DATAFILE
data_mr13a.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
3
OBSERVATION(S)
4
WEIGHT(S)

EFFECTS:    # l=H+C+s+e
1 2 cross   # Herd
2 2 cross   # Sex
3 4 cross   # sire
RANDOM_RESIDUAL VALUES  # residual variance = 1
1.0
RANDOM_GROUP
3
RANDOM_TYPE             # sire model
add_sire
FILE
pedigree_mr13a.txt
(CO)VARIANCES           # sire variance = 1/19
0.0526
OPTION cat 3
OPTION fixed_var mean
~~~~~

The following 2 options are required to perform the threshold analysis with THRGIBBS1F90.

- `OPTION cat` = defines the number of categories. This is a single-trait model so just put one
  value (3 categories for the trait 1). If you apply a multiple-trait model, supply as many integers
  as traits. The value 0 specifies that a trait is continuous (i.e. non-categorical trait).
- `OPTION fixed_var mean` = performs sampling only for the location parameters (i.e. solutions)
  with the fixed variance components supplied in the parameter file. This is useful when only
  the solutions are of interest.


You can run THRGIBBSF90 with many samples. In this example, we try 10,000 samples with 5,000
burn-in and save all the samples after burn-in. It may have too many samples but we make sure we have the converged
results.

Note that THRGIBBS1F90 doesn't estimate the thresholds in this case. If there are 2 thresholds
(3 categories), the program assumes two thresholds are fixed to be 0 and 1. If there is 1 threshold
(2 categories), the program fixes the value to 0.


Solutions
---------

The solutions are stored in `final_solutions`.

~~~~~{language=text caption="solutions"}
trait/effect level  solution        SD
   1   1         1          9.52944466          8.75831636
   1   1         2          9.85646244          8.76150641
   1   2         1         -9.88169090          8.75776616
   1   2         2        -10.30709508          8.74507553
   1   3         1         -0.05309676          0.21738782
   1   3         2          0.06929745          0.21682631
   1   3         3          0.03496753          0.21566398
   1   3         4         -0.08110327          0.22041841
~~~~~

$$
\begin{aligned}
P_{11} &= \Phi(t_1 - \hat{h}_1 - \hat{c}_2 - \hat{u}_1) = 0.758\\
P_{12} &= \Phi(t_2 - \hat{h}_1 - \hat{c}_2 - \hat{u}_1) - \Phi(t_1 - \hat{h}_1 - \hat{c}_2 - \hat{u}_1) = 0.197\\
P_{13} &= 1 - \Phi(t_2 - \hat{h}_1 - \hat{c}_2 - \hat{u}_1) = 0.044
\end{aligned}
$$

where $\Phi(x)$ is the cumulative density normal function e.g., `pnorm()` in R.
The reference values are $P_{11} = 0.800$, $P_{12} = 0.129$, and $P_{13} = 0.071$. The results are apparently
different from the textbook. Why? There are 2 possible reasons why the results don't match.

The first one, which is minor, is over-constraint equations. The author put 2
zero-constraint to the equations. Although the left-hand side (LHS) of the equations has very small 2
eigenvalues, it is not small enough to drop the rank of LHS. The problem is in the linear model.
The author put the same constraints to the corresponding linear model analysis but it is
inappropriate.

The second one is from fixed thresholds with $\sigma_e^2 = 1.0$. When the number of categories ($c$) is
2 i.e. binary traits, there is only 1 threshold and its value can be arbitrarily fixed. When $c = 3$,
we have 2 ways to parameterize the thresholds: 1) one threshold is fixed and another threshold is
estimated, or 2) both thresholds are fixed and $\sigma_e^2$ is estimated (i.e. $\sigma_e^2$ is no longer fixed to 1.0).
With the latter parameterization, we need to estimate $c-3$ threshold parameters in addition to $\sigma_e^2$.
THRGIBBS1F90 uses this parameterization, so we need appropriate $\sigma_e^2$ instead of 1.0 for
the fixed thresholds. In the above example, the residual variance was not appropriate. A question is
why this software implements the model in this way. In the variance component estimation using Gibbs sampling
for a threshold model with 3 or more categories (2 or more thresholds), the convergence rate for
a threshold parameter is very slow. The sampling of residual variance is a better strategy when 2 or
more thresholds are assumed in the model. See Sorensen et al. (1995) or Wang et al. (1997) for
the detailed discussion. Thus, it may happen that `OPTION fixed_var mean` is not such a good idea. You may explore this by yourself.


Reasonable solutions
--------------------

In this subsection, we will find ways to obtain the same solutions to the textbook.
First, we try CBLUPF90THR which is available from our web server.
This program supports the computation of 2 or more thresholds in a single-trait threshold model. [^3]

The program implements Hoeschele et al. (1995) which generalized Foulley et al. (1983)
and Janss and Foulley (1993) with some unpublished work by Richard Quaas (presented at a meeting of Beef Improvement Federation).

[^3]: Actually, it supports a multiple-trait model with one threshold trait and many linear traits.

The following results are from the program with the same parameter file with many iterations
enough to converge (100 rounds here).

~~~~~{language=text caption="solutions"}
trait/effect level  solution
  1  1       1     -0.8942
  1  1       2     -0.6168
  1  2       1      0.4014
  1  2       2      0.0425
  1  3       1     -0.0434
  1  3       2      0.0592
  1  3       3      0.0412
  1  3       4     -0.0660
~~~~~

The thresholds are $t_1 = -0.0550$ and $t_2 = 0.5748$. The difference between thresholds is
$t_2 - t_1 = 0.6298$ and it is the same as the reference analysis. With above solutions,
$P_{11} = 0.800$, $P_{12} = 0.130$, and $P_{13} = 0.070$. The results are nearly identical
to the reference values in the textbook.

Then, we try to run THRGIBBS1F90 with a different residual variance. Let's try $\sigma_e^2 = 3.0$. To
keep the same variance ratio, $\sigma_s^2$ should be 0.158 to be $\sigma_e^2/\sigma_s^2 = 19.0$.
The thresholds are fixed to $t_1 = 0.0$ and $t_2 = 1.0$. The final solutions from THRGIBBS1F90 are as follows.

~~~~~{language=text caption="solutions"}
trait/effect level  solution        SD
   1   1         1         16.34777283         15.17002602
   1   1         2         16.82596758         15.17639696
   1   2         1        -17.16324150         15.16948659
   1   2         2        -17.80476157         15.14659841
   1   3         1         -0.08323076          0.37743431
   1   3         2          0.10108613          0.37648625
   1   3         3          0.05924918          0.37371633
   1   3         4         -0.12015570          0.38254070
~~~~~

When $\sigma_e^2 \neq 1.0$, we should standardize the liability predictor with the residual standard deviation
before applying the cumulative normal function to calculate the probabilities. See the following
computations.

$$
\begin{aligned}
P_{11} &= \Phi\left( \frac{t_1 - \hat{h}_1 - \hat{c}_2 - \hat{u}_1}{\sigma_e} \right) = 0.813\\
P_{12} &= \Phi\left( \frac{t_2 - \hat{h}_1 - \hat{c}_2 - \hat{u}_1}{\sigma_e} \right) - \Phi\left( \frac{t_1 - \hat{h}_1 - \hat{c}_2 - \hat{u}_1}{\sigma_e} \right) = 0.116\\
P_{13} &= 1 - \Phi\left( \frac{t_2 - \hat{h}_1 - \hat{c}_2 - \hat{u}_1}{\sigma_e} \right) = 0.071
\end{aligned}
$$

Again, $\sigma_e$ is the standard deviation of residual variance ($\sqrt{\sigma_e^2}$)
because the formula is based on the standardization of the latent variable.
The probabilities are very similar to the reference results for all sires (p.229).
