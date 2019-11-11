---
title: Variance component estimation
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Advanced usage of AIREMLF90
===========================

Heterogeneous residual variances
--------------------------------

There is a situation where the residual variances vary over conditions. This is known as heterogeneous
 residual variances. There are 2 types of modeling for the heterogeneous residual variances in AIREMLF90.

1. The residual variance is related to a covariate. For example, the residual variance for body
   weight increase by age of a month. The residual variance can be described as a function of a
   covariate (age).
2. The residual variance differs by class. For example, in a test-day random-regression model,
   we usually assume different residual variance in each lactation stage. The residual variances
   are independent of each other.

Although AIREMLF90 is designed to handle the first case, the program can also handle the
second case with a trick. We will see both cases with a numerical example in REML.
GIBBS3F90 (and THRGIBBS3F90) supports the second case.


### Model ###

In this example, we asuume the following model:
$$
y_{ijkl} = F_{i} + S_{j} +Y_{k} + u_{l} + e_{ijkl}
$$
where $y_{ijkl}$ is the observation, $F_{i}$ , $S_j$, and $Y_k$ are the fixed effects, $u_l$ is the additive genetic effect and
$e_{ijkl}$ is the residual effect. The residual variance is defined as the following function
$$
\sigma_e^2 = \exp(b_0 + b_1 x_{ijkl})
$$
where $b_0$ and $b_1$ are the regression coefficients to account for the residual variance and $x_{ijkl}$ is the
covariate measured with the observation $y_{ijkl}$. The model is based on Foulley and Quaas (1995).
AIREMLF90 will estimate $b_0$ and $b_1$ with user-supplied $x_{ijkl}$.


### Data ###

In this section, we will use simulated files similar to the previous section. You can download the
files from Github.

- [`simdata2.txt`](https://github.com/Masuday/data/blob/master/tutorial/simdata2.txt) : data file
- [`simped2.txt`](https://github.com/Masuday/data/blob/master/tutorial/simped2.txt) : pedigree file

The pedigree file contains 3 columns: animal, sire, and dam. The data file has 12 columns as
described below.

Column  Item           type      description
------  ---------      -------   ----------------------------------
1       Animal ID      integer   Same as in pedigree (4641 animals)
2       Sire ID        integer   Same as in pedigree
3       Dam ID         integer   Same as in pedigree
4       Weight         real      Not used here
5       Mu             integer   All 1: not used here
6       Farm           integer   Class effect (155 levels)
7       Sex            integer   Class effect (2 levels)
8       Year           integer   Class effect (11 levels)
9       Obs. 1         real      Phenotype for trait 1
10      Obs. 2         real      Phenotype for trait 2
11      Obs. 3         real      Phenotype for trait 3
12      Obs. 4         real      Phenotype for trait 4
13      Covariate      real      Related to residual variance
14      Class          integer   (Used in the next subsection)

Column 13 contains a real value as a covariate.
In this artificial data, the residual variance is expected to be larger as the covariate becomes larger.
The 14th column contains the heterogeneous-residual-variance class (3 levels), and it
will be used in the next subsection.


### Parameter file ###

The following parameter file is used.

~~~~~{language=blupf90 caption="aireml2.txt"}
DATAFILE
simdata2.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
4
OBSERVATION(S)
9
WEIGHT(S)
4
EFFECTS:
 6  155 cross
 7    2 cross
 8   11 cross
 1 4641 cross
RANDOM_RESIDUAL VALUES
100
RANDOM_GROUP
4
RANDOM_TYPE
add_animal
FILE
simped2.txt
(CO)VARIANCES
100
OPTION hetres_pos 13
OPTION hetres_pol 4.5 0.5
~~~~~

The options define the model for heterogeneous residual variances.

- `OPTION hetres_pos` = the position of covariate $x$ in the data file. Intercept $b_0$ is implicitly considered in
  the program.
- `OPTION hetres_pol` = the starting values for $b_{0}$ and $b_{1}$.
     - You should supply the values for all coefficients including intercept.
	 - In this example, the initial value will be $\exp(4.5 + 0.5) = 148.4$ for $x = 1$.

In the above case, we define only 1 regression coefficient in `hetres_pos` but the program adds the
intercept. If you put 2 numbers in `hetres_pos` and also put 2 initial values in `hetres_pol`, the
program doesn't add the intercept. In such a case, the model doesn't contain any intercept but does
contain user-supplied covariates only.

Note that these options do not work with `OPTION EM-REML`.
The current version of AIREMLF90 will tell you this limitation when the program meets this condition.

### Results ###

You can run AIREMLF90 with the above parameter file. The following output will be shown.

~~~~~{language=output}
Final Estimates
 Genetic variance(s) for effect  4
   39.384
 new R
		   1 -th trait:           1 -th coefficient =   4.25520168650538
		   1 -th trait:           2 -th coefficient =  5.886409914144559E-002
 inverse of AI matrix (Sampling Variance)
   16.773     -0.12514      0.77591E-02
 -0.12514      0.41370E-02 -0.16778E-02
  0.77591E-02 -0.16778E-02  0.10722E-02
 Correlations from inverse of AI matrix
   1.0000     -0.47507      0.57858E-01
 -0.47507       1.0000     -0.79664
  0.57858E-01 -0.79664       1.0000
 SE for G
   4.0955
 SE for R
  0.64319E-01
~~~~~

The output shows $\hat{b}_0 = 4.2552$ and $\hat{b}_1 = 0.058864$. This corresponds to
$\hat{\sigma}_e^2 = \exp(4.26 + 0.0589 \times 0.5) = 72.9$ for $x = 0.5$, $\hat{\sigma}_e^2 = \exp(4.26 + 0.0589 \times 1.5) = 77.4$
for $x = 1.5$ and $\sigma_e^2 = \exp(4.26 + 0.0589 \times 2.5) = 82.0$ for $x = 2.5$.

One drawback of this analysis is that the calculations of the standard error for the residual variance
are not easy. The AI matrix contains information for $\hat{b}_0$ and $\hat{b}_1$ (the last 2 rows/columns).


### Another modeling by class ###

The heterogeneous residual variances are accounted for by class. We assume 3 levels in the class.
The 14th column in the above data contains the level for each observation. AIREMLF90 doesn't
directly accept the level number, and we should convert it to a different format.

Having 3 levels is equivalent to defining 3 regression coefficients without intercept. We now
assume the following parameterization without intercept.
$$
\sigma_e^2 = \exp(b_1 x_1 + b_2 x_2 + b_3 x_3 )
$$

If the observation has the residual variance level 1, we have $x_1 = 1$, $x_2 = 0$, and $x_3 = 0$. For the level 2,
$x_1 = 0$, $x_2 = 1$, and $x_3 = 0$ and for the level 3, $x_1 = 0$, $x_2 = 0$, and $x_3 = 1$. We need 3 covariate with 1
or 0. We add 3 extra columns to the rightmost of the data file.

- tutorials:`simdata2a.txt`: extended data file

The first 10 rows are shown below.

~~~~~{language=text caption="simdata2a.txt"}
  1       0       0 1.00   1    67   1   1    85.0     0.0    92.1    91.0  0.46  1   1 0 0
  2       0       0 0.98   1   144   1   1   115.2   103.9    94.8    90.6  1.52  2   0 1 0
  3       0       0 1.04   1    92   1   1    93.0   107.4   114.9   107.0  0.00  1   1 0 0
  4       0       0 0.97   1    26   1   1    84.0    91.8    93.7   107.1  0.61  1   1 0 0
  5       0       0 0.96   1    83   1   1   100.9    87.9    88.9    91.5  0.55  1   1 0 0
  6       0       0 0.99   1    62   1   1    69.8    71.5    69.3     0.0  0.88  1   1 0 0
  7       0       0 0.97   1    40   1   1   101.2     0.0    92.1    88.6  0.27  1   1 0 0
  8       0       0 1.07   1    82   1   1    77.4    72.7    84.1   105.2  1.69  2   0 1 0
  9       0       0 1.01   1    71   1   1   107.8    87.0    97.8    76.0  2.89  3   0 0 1
 10       0       0 0.95   1   114   1   1    94.4   100.5   103.8    89.8  1.26  2   0 1 0
~~~~~

The column 15, 16 and 17 contains 1 or 0. In column 15, it is 1 if the level is 1, otherwise 0.
In column 16, it is 1 if the level is 2, otherwise 0. In column 17, it is 1 if the level is 3,
otherwise 0. With this data file, the parameter file is as follows.

~~~~~{language=blupf90 caption="aireml2a.txt"}
DATAFILE
simdata2a.txt
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
 7     2 cross
 8    11 cross
 1  4641 cross
RANDOM_RESIDUAL VALUES
100
RANDOM_GROUP
4
RANDOM_TYPE
add_animal
FILE
simped2.txt
(CO)VARIANCES
100
OPTION hetres_pos 15 16 17
OPTION hetres_pol 4.5 4.5 4.5
~~~~~

The results from the above parameter file are shown here.

~~~~~{language=output}
Final Estimates
 Genetic variance(s) for effect  4
   39.296
 new R
		   1 -th trait:           1 -th coefficient =   4.28231169726656
		   1 -th trait:           2 -th coefficient =   4.36065608258819
		   1 -th trait:           3 -th coefficient =   4.38963108448880
 inverse of AI matrix (Sampling Variance)
   16.735     -0.11982     -0.11288     -0.10685
 -0.11982      0.32743E-02  0.75391E-03  0.69459E-03
 -0.11288      0.75391E-03  0.31352E-02  0.67693E-03
 -0.10685      0.69459E-03  0.67693E-03  0.29536E-02
 Correlations from inverse of AI matrix
   1.0000     -0.51184     -0.49281     -0.48059
 -0.51184       1.0000      0.23530      0.22335
 -0.49281      0.23530       1.0000      0.22245
 -0.48059      0.22335      0.22245       1.0000
 SE for G
   4.0909
 SE for R
  0.57221E-01
~~~~~

The estimate for the level 1 is $\hat{\sigma}_e^2 = \exp(4.28) = 72.2$, for the level 2, $\hat{\sigma}_e^2 = \exp(4.36) = 78.3$ and
for the level 3, $\hat{\sigma}_e^2 = \exp(4.39) = 80.6$. These values are very similar to the previous results from
a regression parameterization i.e. $\exp(b_0 + b_1 x)$ for $x = 0.5$, $1.5$, and $2.5$.


### Remarks ###

The methods explained here will not work well for multiple-trait models or complicated models
with many variance components.

Likelihood Ratio Test
---------------------

REML methods allow statistical testing of variance components. For instance, imagine that we have to choose one of two competing models:

  - model 1 _not_ including the maternal permanent environmental effect
  - model 2 _including_ maternal permanent effects.

The Likelihood Ratio Test (LRT) checks if the extra random effect, with associated variance
component gives a better fit of the model, against not fitting it. The model _without_ the extra random effect
is the _null_ ($H_0$) model versus the model _with_ the extra random effect, which is the alternative model ($H_1$).
Then the difference between the two, which is a positive number, is an LRT statistic which follows a mixture of $\chi^2$ distributions.
The theory of the LRT can be found in standard books and a nice description is in Sorensen & Gianola book.

Output of AIREMLF90 under $H_0$ is $x=-2logL$ ; output under $H_1$ is $y=-2logL$. These are positive numbers, so the smaller the better;
always $y<x$ as $H_1$ is a more complex (so more likely) model. The trick resides in knowing if $x-y$ is "big enough".
The LRT statistic is $LRT=x-y$, which is a statistic distributed as $\chi^2$. For one variance component, the p-value is (in R) :

~~~{language=r}
pchisq(x-y,1,lower.tail=FALSE)/2
~~~

Classical applications of LRT in quantitative genetics include testing $h^2 > 0$ or testing of QTL effects.
An application for association analysis for a multi-allelic gene is (<http://dx.doi.org/10.3168/jds.2013-6570>).

### Example for test of heritability in dairy sheep

I tested if genetic effects ($\mathbf{u}$) should be fit in an old data set from dairy sheep (80,000 records, 50,000 animals in pedigree) with a model including permanent
($\sigma^2_p$), genetic ($\sigma^2_p$) and residual ($\sigma^2_e$) variances.

Under the complete model H1 ($\mathbf{y=Xb+Zu+Zp+e}$)  ) we have in the (last lines of) the output of AIREMLF90 :

~~~
-2logL =        825227.48
~~~

Then we run the reduced model H0 with a parameter file that will _not_ include the genetic effect ($\mathbf{y=Xb+Zp+e}$) we have:

~~~
 -2logL =    828095.614456413
~~~

then the test in R is:

~~~{language=R}
pchisq(828095.614456413-825227.48,1,lower.tail=FALSE)/2

[1] 0
~~~


the p-value is so small that we cannot see the difference from 0. We can take the log, then transform to a scale of $-\log_{10}(\mathrm{p-value})$, a scale typically used in GWAS:

~~~{language=R}
pval=pchisq(828095.614456413-825227.48,1,lower.tail=FALSE,log.p=TRUE)/2
> pval
[1] -719.137
-log10(exp(pval))
[1] 312.3172
~~~

So, the p-value is $p<10^{-312}$, the evidence against $H_0$ is very strong and we should accept that there is genetic variance in this data set.
