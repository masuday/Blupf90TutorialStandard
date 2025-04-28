---
title: Data preparation with RENUMF90
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Multiple-trait models
=====================

Model
-----

For renumbering on a multiple-trait model, we still need a very similar instruction file to the single-trait model. Only differences include 1) a need to specify the model for each trait and 2) use of covariance matrix instead of a scalar value.

We will consider a two-trait model with equal design matrices, which means all traits have the same model. The mathematical model is
$$
\begin{aligned}
y_{ijk:1} &= A_{i:1} + S_{j:1} + \beta_{1} x_{ijk:1} + u_{k:1} + e_{ijk:1}\\
y_{ijk:2} &= A_{i:2} + S_{j:2} + \beta_{2} x_{ijk:2} + u_{k:2} + e_{ijk:2}
\end{aligned}
$$
where $y_{ijk:t}$ is a observation for trait $t$, $A_{i:t}$ is the fixed effect for trait $t$, $S_{i:t}$ is also the fixed effect for trait $t$, $\beta_{t}$ is the fixed regression coefficient for trait $t$, $x_{ijk:t}$ is a covariate for trait $t$, $u_{k:t}$ is the additive genetic effect for trait $t$, and $e_{ijk:t}$ is the random residual effect. The genetic ($\mathbf{G}_0$) and residual ($\mathbf{R}_0$) covariance matrices are
$$
\mathbf{G}_{0}
=
\left[
\begin{array}{rr}
0.50&-0.25\\
-0.25&1.00
\end{array}
\right]
\quad
\text{and}
\quad
\mathbf{R}_{0}
=
\left[
\begin{array}{rr}
2.0&1.0\\
1.0&1.5
\end{array}
\right]
$$


Required files
--------------

The raw data file is identical to the previous single-trait data except for the new column (trait 2) added. The data file should contain all required effects and observations for all traits.

~~~~~{language=text caption="rawdata5.txt"}
  ID006  A  1  1.0  3.0  4.5
  ID009  A  2  1.0  2.0  7.5
  ID012  A  1  2.0  4.0  3.5
  ID007  B  2  2.0  6.0 -0.5
  ID010  B  1  1.0  3.0  5.5
  ID013  B  2  2.0  6.0  1.5
  ID008  C  1  2.0  6.0 -1.5
  ID011  C  2  1.0  6.0  2.5
  ID014  C  1  1.0  8.0  0.5
  ID015  C  2  2.0  4.0  4.5
~~~~~

The pedigree file is also the same as those used the previous one.

~~~~~{language=text caption="rawpedigree5.txt"}
ID001        0         0
ID002        0         0
ID003        0         0
ID004        0         0
ID005        0         0
ID006        0         0
ID007    ID002     ID005
ID008    ID001     ID004
ID009    ID002     ID003
ID010    ID007     ID006
ID011    ID007     ID004
ID012    ID011     ID008
ID013    ID011     ID010
ID014    ID009     ID013
ID015    ID011     ID010
~~~~~

The instruction file for this two-trait model is as follows.

~~~~~{language=renumf90 caption="renum5.txt"}
DATAFILE
rawdata5.txt
TRAITS          # two-trait model: put 2 positions
5 6
FIELDS_PASSED TO OUTPUT

WEIGHT(S)

RESIDUAL_VARIANCE
2.0 1.0
1.0 1.5
EFFECT           # 1st effect fixed
2 2 cross alpha
EFFECT           # 2nd effect fixed
3 3 cross alpha
EFFECT           # 3rd effect fixed
4 4 cov
EFFECT           # 4th effect
1 1 cross alpha
RANDOM           ## treated as a random effect
animal
FILE             ## pedigree file
rawpedigree5.txt
FILE_POS         ## animal, sire and dam IDs, and two 0s
1 2 3 0 0
(CO)VARIANCES    ## its variance component
 0.50 -0.25
-0.25  1.00
~~~~~

For a multiple-trait model, you can check the following points in an instruction file. Incorrect description in these statements falls in the sudden stop of RENUMF90.

- `TRAITS`: Enumerate the positions of observations in the data file. If you have 2 traits, you should put 2 numbers (positions) here.
- `RESIDUAL_VARIANCE`: Put a residual covariance matrix here. The whole matrix is needed (all upper, lower, and diagonal elements).
- `EFFECT`: Enumerate the position of effects for each trait in the data file; then put the effect type (and data type). For example, with a two-trait model, first, you should put 2 numbers (for positions of effects for trait 1 and 2), 1 keyword (`cross` or `cov`) and, possibly, data type (`numer` or `alpha`) if the data type is `cross`.
- `(CO)VARIANCES`: Put a covariance matrix here. The whole matrix is needed.

Run RENUMF90 with the above files, and you can see the parameter file configured with the two-trait model.


Missing observations
--------------------

You can include missing observations in the data file. RENUMF90 does not distinguish the real and the missing observations; the program just read the raw data and just pass the observation to the renumbered file. Although RENUMF90 doesn't care about missing observations, BLUPF90 cares about the values. So the generated parameter file (`renf90.par`) should include an option to define the missing code. You can write the following option in the instruction file, and RENUMF90 passes it to `renf90.par`.

~~~~~{language=blupf90}
OPTION missing -999
~~~~~

This example defines an observation with the value `-999` as a missing code. The default is 0 (that is if you do not define any missing code, the program assumes 0 as missing).

Note that RENUMF90 still recognizes 0 as a missing observation in the computations of the basic statistics (for example average and standard deviation) just for your information. In this case, the statistics may be inaccurate but all the files are correctly renumbered.

Different models across traits (Unequal design matrices)
--------------------------------------------------------

Now we consider a multiple-trait model which has different mathematical models across traits. It is typically called a model with unequal design matrices. Let us see the following two-trait model.
$$
\begin{aligned}
y_{ijk:1} &= A_{i:1} + \phantom{S_{j:1} + } \beta_1 x_{ijk:1} + u_{k:1} + e_{ijk:1}\\
y_{ijk:2} &= A_{i:2} + S_{j:2} + \beta_{2} x_{ijk:2} + u_{k:2} + e_{ijk:2}
\end{aligned}
$$
In this model, the $S_{j:1}$ is missing for trait 1. To support it with RENUMF90, you can just change a line in the previous instruction file.

~~~~~{language=renumf90}
EFFECT                  # 2nd effect fixed
0 3 cross alpha
~~~~~

The position `0` means that this effect will not be included in the model for this trait.

We further consider the following two-trait model.
$$
\begin{aligned}
y_{ijk:1} &= A_{i:1} \phantom{+ S_{j:1} } + \beta_1 x_{ijk:1} + u_{k:1} + e_{ijk:1}\\
y_{ijk:2} &= \phantom{A_{i:2} + } S_{j:2} + \beta_{2} x_{ijk:2} + u_{k:2} + e_{ijk:2}
\end{aligned}
$$
In this case, $S_{j:1}$ is missing for trait 1 and $A_{i:2}$ is missing for trait 2. Applying the above principle to this case, you can figure out the following solution (just showing a piece of instruction file).

~~~~~{language=renumf90}
EFFECT                  # 1st effect fixed
2 0 cross alpha
EFFECT                  # 2nd effect fixed
0 3 cross alpha
~~~~~

Above statements are easy to understand which effects are missing for a particular trait.


There is another way to handle such a model. You can combine above 2 `EFFECT` lines into 1 as follows.

~~~~~{language=renumf90}
EFFECT                  # 1st and 2nd effects fixed
2 3 cross alpha
~~~~~

This statement may be useful when the different effects are considered as similar types of effects. For example, in dairy cattle, a contemporary group effect (like HYS: herd-year-season) is commonly included in the model for production traits but the definition should be different across parities. HYS in the 1st lactation and HYS in the 2nd lactation are different but considered as similar effects. With this compact definition, memory requirements would reduce. If you are confused with this notation, you do not have to use the compact statement.


Summary
-------

- RENUMF90 supports multiple-trait models.
- Carefully describe `TRAITS`, `RESIDUAL_VARIANCE`, `EFFECT` and `(CO)VARIANCES` in an instruction file.
- `TRAIT` has the same number of entries to the number of traits.
- Covariance matrix should be wholly stated.
- `EFFECT` describes the position of effect in each trait.
- Missing observations are passed to `renf90.dat`. You can use `OPTION missing` to the instruction file to change the code for missing observations.
- RENUMF90 supports a multiple-trait model with unequal design matrices.
