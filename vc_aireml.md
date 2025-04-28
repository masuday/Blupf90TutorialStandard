---
title: Variance component estimation
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Restricted (residual) maximum likelihood with AIREMLF90 (BLUPF90+)
==================================================================

REML software
-------------

### REML algorithms

REML (Restricted/Residual Maximum Likelihood) is a widely used method for estimating variance components in animal breeding. Several algorithms are available for REML, and BLUPF90+ supports the following two:

- Average Information (AI) algorithm
- Expectation-Maximization (EM) algorithm

The AI algorithm (AI-REML) is an iterative method that requires initial values for the variance components. In the first iteration, the algorithm updates these values based on the provided starting point. In each subsequent iteration, new values are computed from the previous ones. After several iterations, the estimates are expected to converge to stable values. The EM algorithm (EM-REML) is another iterative method, but it uses a different computational approach. In theory, both algorithms should yield the same estimates of variance components. For more on the differences between these algorithms, see Misztal (2008).

BLUPF90+ now serves as a unified program that supports both algorithms for REML estimation. Previously, the BLUPF90 family included two separate programs: AIREMLF90 for AI-REML and REMLF90 for EM-REML. This tutorial still refers to these older programs. We will focus on the use of AIREMLF90, as it has long been the preferred tool for REML estimation and also provides (approximate) standard errors of genetic parameters. Additionally, AIREMLF90 can run the EM algorithm using an option specified in the parameter file.

### Notice for BLUPF90+ users

If you are using BLUPF90+, please replace AIREMLF90 (`airemlf90`) and REMLF90 (`remlf90`) with BLUPF90+ (`blupf90+`) throughout this tutorial. Additionally, to estimate variance components using the AI algorithm in BLUPF90+, you must include the following option in your parameter file:

~~~~~{language=blupf90 caption="variance component estimation (AI REML)"}
OPTION method VCE
~~~~~

Without this option, BLUPF90+ will not estimate variance components. Instead, it will default to solving the mixed model equations using the variance components provided. Including this option enables BLUPF90+ to operate in the same way as AIREMLF90. To switch to the EM algorithm (emulating REMLF90), add the following option to the parameter file, as explained in the subsequent section:

~~~~~{language=blupf90 caption="variance component estimation (EM REML)"}
OPTION method VCE
OPTION EM-REML 5000
~~~~~

Please refer to the official website and manual for a detailed explanation of variance component estimation in BLUPF90+.

Preparation
-----------

AIREMLF90 uses the same parameter file as BLUPF90 uses. AIREMLF90 reads the variance components as initial values (starting values) from the parameter file. In this section, we will use simulated files that have more observations than before. You can download the files from Github (<https://github.com/masuday/data>).

- [`simdata.txt`](https://github.com/masuday/data/blob/master/tutorial/simdata.txt) : data file
- [`simped.txt`](https://github.com/masuday/data/blob/master/tutorial/simped.txt) : pedigree file

The pedigree file contains three columns: animal, sire, and dam. The data file has 12 columns as described below.

Column       Item           type       description
------       ---------      -------    ----------------------------------
1            Animal ID      integer    Same as in pedigree (4641 animals)
2            Sire ID        integer    Same as in pedigree
3            Dam ID         integer    Same as in pedigree
4            Weight         real       Not used here
5            Mu             integer    All 1: not used here
6            Farm           integer    Class effect (155 levels)
7            Sex            integer    Class effect (2 levels)
8            Year           integer    Class effect (11 levels)
9            Obs. 1         real       Phenotype for trait 1
10           Obs. 2         real       Phenotype for trait 2
11           Obs. 3         real       Phenotype for trait 3
12           Obs. 4         real       Phenotype for trait 4


Single-trait analysis
---------------------

### Model ###

We here consider the following animal model:
$$
y_{ijkl} = F_{i} + S_{j} +Y_{k} + u_{l} + e_{ijkl}
$$
where $y_{ijkl}$ is an observation, $F_i$ is the fixed farm effect, $S_j$ is the fixed sex effect, $Y_k$ is the fixed year effect, $u_l$ is the additive genetic effect, and $e_{ijkl}$ is the random residual effect. The purpose of this analysis is to estimate the additive genetic variance ($\sigma_u^2$) and the residual variance ($\sigma_e^2$).

### Parameter file ###

Let us start with a single-trait analysis for phenotype 1 (column 9). The model contains farm, sex, and year as fixed cross-classified effects and the additive genetic effect as a random effect. Place the following parameter file to a directory with the data and pedigree files. Although this parameter file is for variance component estimation, it looks like the same as those used used by BLUPF90.

~~~~~{language=blupf90 caption="aireml1.txt"}
DATAFILE
simdata.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
4
OBSERVATION(S)
9
WEIGHT(S)
4
EFFECTS:
 6   155 cross
 7   2 cross
 8   11 cross
 1   4641 cross
RANDOM_RESIDUAL VALUES
100
RANDOM_GROUP
4
RANDOM_TYPE
add_animal
FILE
simped.txt
(CO)VARIANCES
100
~~~~~

The variance components in the parameter file will be used as the initial values ($\sigma_e^2 = 100$ and $\sigma_u^2 = 100$) in AI REML.


### Intermediate estimates ###

Running AIREMLF90 with the above parameter file, the program reports the intermediate estimates in the current round. AI REML is an iterative method --- the variance estimates will change in each round and the updated values are expected to approach the final estimates. After some rounds, when the change is very small, we can consider the values converge on the estimates. We show the messages from the first round.

~~~~~{language=output}
-2 logL =   34141.8991194978       : AIC =   34145.8991194978
 In round            1 convergence = 0.240696612717812
 delta convergence =  40.9948020571449
new R
   50.924
new G
   67.087
~~~~~

Some information is available.

- `-2logL` = negative twice of the restricted likelihood with the current variance components (along with BLUE and BLUP).
- `AIC` = $-2\log L + 2p$ where $p$ is the number of unique variance components
- `convergence` = the current convergence indicator (see below)
- `delta convergence` = another convergence indicator
- `new R` = updated residual variance ($\sigma_e^2$)
- `new G` = updated genetic variance ($\sigma_u^2$)

In each round, the program computes two convergence indicators. One convergence indicator ($C$) is calculated as
$$
C=\frac{\sum_{i}(\theta_{i}-\theta^{*}_{i})^2}{\sum_{i}\theta_{i}^2}
$$
where $\theta_i$ is the current estimate of $i$-th variance component and $\theta^{*}_{i}$ is the previous estimate of $i$-th variance component. This criterion is also used in REMLF90. The other indicator, called the delta convergence ($C_{\Delta}$), is calculated as
$$
C_{\Delta}=\frac{\sum_{i}|\theta_{i}-\theta^{*}_{i}|}{n}
$$
where $n$ is the number of unique (co)variance components. This indicator represents the average absolute change across the estimates.

The iteration stops if $C<\varepsilon$ or $C_{\Delta}<\sqrt{\varepsilon}$ where $\varepsilon$ is the convergence criterion and its default is $\varepsilon=10^{-12}$ (`1.0E-12`). When one indicator approaches the criterion, the other one usually approaches the criterion as well.


### Final estimates ###

If either of convergence indicators meets the criterion, the iteration stops and the final estimates will be shown on the screen. For the current data and initial values, we need 8 rounds to converge.

~~~~~{language=output}
-2 logL =   33423.4510659485         : AIC =  33427.4510659485
 In round            8 convergence = 3.476428650201818E-015
 delta convergence = 1.835758207312910E-006
new R
   62.691
new G
   38.538
solutions stored in file : "solutions"

Final Estimates
Genetic variance(s) for effect 4
  38.538
Residual variance(s)
  62.691
inverse of AI matrix (Sampling Variance)
  13.471       -6.7551
 -6.7551        6.5499
Correlations from inverse of AI matrix
  1.0000     -0.71914
 -0.71914     1.0000
SE for G
  3.6703
SE for R
  2.5593
~~~~~

The program ends with `Final Estimates` showing the variance estimates at convergence. The same information will be saved in the file `airemlf90.log`. The final estimates are $\hat{\sigma}_u^2 = 38.538$ and $\hat{\sigma}_e^2 = 62.691$ so that the heritability estimates is $\hat{h^2} = 0.3807$. The program does not show the heritability by default, and the user should calculate it manually.

The program saves the solutions of mixed model equations with the recent variance estimates in file "solutions". Note that the solutions do not come from the last variance estimates but one round before the convergence. In this example, the solutions are from the variance estimates in round 7. When the algorithm works well and converges correctly, the last variance estimates are almost the same as those used the previous estimates, so the difference between the two solutions is negligible. If the convergence trajectory fluctuated, two solutions could be distant. In such a case, the variance estimates themselves are unreliable. At the end of this section, we will consider convergence problems.


### Approximated standard error ###

The approximated standard error (sampling variance) for a variance estimate is available from the inverse of the AI matrix. Suppose a parameter vector is $\theta$ and the AI matrix is $\mathcal{I}(\theta)$, the sampling variance of
$\hat{\theta}$ is
$$
\mathrm{var}(\hat{\theta}) = \left[\mathcal{I}(\theta)\right]^{-1}
$$
where $\left[\mathcal{I}(\theta)\right]^{-1}$ is the inverse of the AI matrix. In this example, $\theta=\left[\begin{array}{ll}\sigma_u^2&\sigma_e^2\end{array}\right]'$. The square root of the diagonal of $\left[\mathcal{I}(\theta)\right]^{-1}$ are shown as the `SE for G` ($\sqrt{13.471}$) and `SE for R` ($\sqrt{6.5499}$) in the last lines of output.

Unfortunately, the program does not calculate the standard error of the heritability. You can still calculate the approximated standard error of a function of variance components (for example heritability) with the delta method by hand. See the documentation on the official wiki (<http://nce.ads.uga.edu/html/projects/AI_SE_revised.pdf>) for details. Here we just show a way of the calculation of the standard error for heritability estimates. The heritability estimate is 0.3807. Using the approximation, the standard error is
$$
\begin{aligned}
\mathrm{SE}\left(h^2\right)&=\left(\frac{h^2}{\sigma_u^2}\right)\left[ (1-h^2)^2\mathrm{var}(\hat{\sigma}_u^2)-2(1-h^2)h^2\mathrm{cov}(\hat{\sigma}_u^2,\hat{\sigma}_e^2)+(h^2)^2\mathrm{var}(\hat{\sigma}_e^2) \right]\\
&=\left(\frac{0.3807}{38.54}\right)\left[ (1-0.3807)^2\times 13.471-2(1-0.3807)\times 0.3807\times (-6.755)+(0.3807)^2\times 6.550 \right]\\
&=0.007
\end{aligned}
$$

Another way to evaluate the S.E. for the heritability estimate was the Monte-Carlo method suggested by Meyer and Houle (2013). You can find a do-it-yourself description of the method at (<http://artadia.blogspot.fr/2016/05/standard-error-of-variance-components.html>). AIREMLF90 can conduct this method with an option. You can add the following line to the bottom of the parameter file and run AIREMLF90.

~~~~~{language=blupf90}
OPTION se_covar_function h2 G_4_4_1_1/(G_4_4_1_1+R_1_1)
~~~~~

This option has 2 arguments: label and formula. The label can contain arbitrary characters. The formula describes an objective function for which the standard error should be calculated ($\sigma_u^2/(\sigma_u^2 + \sigma_e^2$ ) in this case). The formula is described using special labels for variance components. For an genetic covariance component, use `G_effect1_effect2_trait1_trait2`; and for a residual covariance, use `R_trait1_trait2`. In this single-trait case, the genetic variance $\sigma_u^2$ is defined as the effect 4 in the parameter file so we refer $\sigma_u^2$ as `G_4_4_1_1`. Similarly, we refer $\sigma_e^2$ as `R_1_1`. Any spaces are not allowed in the formula. See the manual for details on this option.

After the main iterations, the program calculates an approximated standard error using a Monte-Carlo technique of Meyer and Houle. In this case, you can see the following output on the screen.

~~~~~{language=output}
h2  - Function : g_4_4_1_1/(g_4_4_1_1+r_1_1)
  Mean :  0.38070
  Sample Mean :   0.38014
  Sample SD :   0.30140E-01
 elapsed time    1.098833
~~~~~

In the output, `Sample Mean` should be almost identical to the estimate. `Sample SD` is seen as an approximated
standard error, which is 0.03 (`0.30140E-01` is $0.30140 \times 10^{-1}$ that is 0.03014).

Don't worry if you have forgotten to add the option to the parameter file. You can prepare a parameter file with the option `se_covar_function` and the variance components at convergence. Running AIREMLF90 again, and the program will stop within 1 or 2 rounds and it will calculate the approximated standard error of the parameter.


Convergence problems
--------------------

The AI algorithm does not guarantee the convergence. Sometimes you couldn't meet the convergence in 2 ways:

- Divergence. The estimates suddenly jump to nonsense values and the program stops.
- Slow. The estimates hardly change and the program takes many rounds (several hundred or more).

The problems come from several reasons.

1. Mistakes in the parameter file, data, and/or pedigree.
2. Wrong initial values.
3. A too complicated model with a limited amount of observations and/or pedigree.
4. Too many variance components to be estimated.

If your files are correct and the initial values do not solve the issues, change your model to be simplified.

AIREMLF90 tries to correct nonsense estimates using a technique described by Jensen at al. (1996). The method blends the AI matrix from the regular algorithm ($\mathcal{I}_{\mathrm{AI}}$) with the AI matrix from the EM algorithm ($\mathcal{I}_{\mathrm{EM}}$) that is $\mathcal{I}(\theta)= (1-w)\mathcal{I}_{\mathrm{AI}} + w\mathcal{I}_{\mathrm{EM}}$ with a weight $w$. If $w = 1$, the algorithm is equivalent to the regular EM algorithm, which always provides estimates within their parameter space. If an estimate is not positive definite (that is nonsense value), AIREMLF90 sets a small $w$, blends two AI matrices, and recalculates the estimates with the modified AI matrix. The program repeats this blending increasing $w$ until the estimates make sense. AIREMLF90 gives up this process after 5 trials (in the end, $w$ is 1 or similar value) and prints a message.

~~~~~{language=output}
*** Warning *** corrected Covariance Matrix 5 times
~~~~~

In such a case, the estimates may be nonsense.

The blending is a band-aid method and successful only when the AI matrix is accidentally singular. If the blending happens every round, you can still obtain estimates but you need much more rounds to converge.

EM-REML algorithm
-----------------

The EM (expectation-maximization) REML algorithm is much more stable than the AI algorithm and very robust to poor initial estimates. Also, it can provide a good starting point for the AI algorithm. However, it is _much_ slower, that is, it needs more rounds to converge. For some very complex problems, only the EM REML may converge.

You can run the EM algorithm using AIREMLF90 by using the option:


~~~~~{language=blupf90}
OPTION EM-REML 10
~~~~~

where 10 (or any integer value) is the number of iterations with EM REML prior to switching to AI REML. If you want a "pure" EM REML, then set the number to a very large value like 10000.

Constraints on variance components
----------------------------------

The user may hope to fix some variance components fixed (constant) through the iterations. Although AIREMLF90 does not support such a general constraint on variance components, the program supports to force some variance components to be 0. This is useful when such variance components will never be included in the model or when some covariance components should be 0 in a complicated model. When the initial variance component is 0, this component never changes throughout the iterations. For example, the following parameter file forces the direct and maternal genetic covariance fix to be 0.

~~~~~{language=blupf90}
DATAFILE
renf90.dat
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
4
OBSERVATION(S)
6
WEIGHT(S)

EFFECTS:
 4  3 cross
 5  2 cross
 1 14 cross  # direct genetic effect
 3 14 cross  # maternal genetic effect
RANDOM_RESIDUAL VALUES
350.0
RANDOM_GROUP
3 4
RANDOM_TYPE
add_animal
FILE
renadd01.ped
(CO)VARIANCES  # fixed to be zero for covariance
150  0
 0  90
~~~~~

When the initial values have 0, AIREMLF90 excludes such variance components from the estimation process. Precisely, AIREMLF90 does not put such parameters to the AI matrix, and therefore, the excluded parameters will not be calculated in any way. One hand, you may expect a faster computation and a stable convergence because fewer parameters will be estimated. On the other hand, if the constraint variance component is not really zero, the other estimates may be biased.

Note that, when the estimate is out of the parameter space and AIREMLF90 fails to fix it by the AI-EM combination, some variances would accidentally become 0. Once it happens, those variances will not be back to non-zero. It is not because of the constraint mentioned above. This is simply bacause the information needed in variance estimation will be lost if the variance is 0.

Summary
-------

- AIREMLF90 calculates REML estimates of variance components.
- AIREMLF90 accepts the same parameter file as BLUPF90 and sets the variance components as initial values.
- The final estimates are shown on screen and saved in the file `airemlf90.log`.
- The solutions are also calculated using covariance estimates in one round before the convergence.
- There are 2 methods to approximate the standard error of a genetic parameter.
- AIREMLF90 does not guarantee the convergence even if it tries to make the estimates be in the parameter space.
- If diverged, use a simpler model.
- For complex problems, you can use the EM algorithm with AIREMLF90.
- If the intial variance component is 0, it will be fixed to be 0 throughout the iterations.
