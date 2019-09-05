---
title: Quick tour of BLUPF90
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Trivial analyses for mixed models
=================================

In this section, we perform mixed model analyses using BLUPF90.
We start with a simple mixed model (random effects, unrelated to each other) and finally consider pedigree information.

If you perform the simple mixed model, BLUPF90 needs only 2 files (data and parameter file), which are the same as explained in the previous section.
If you consider pedigree, in addition to the data and the parameter file, a pedigree file has to be prepared.

A simple mixed model
--------------------

We assume the similar model described in the previous section and the second effect is now a
random effect as
$$
y_{ijk} = A_i + S_j + \beta x_{ijk} + e_{ijk}
$$
where $y_{ijk}$ is an observation, $A_i$ is a fixed effect, $S_j$ is a random effect, $\beta$ is a regression coefficient, $x_{ijk}$ is a covariate, and $e_{ij}$ is the residual effect.
The model in matrix notation will be 
$$
\mathbf{y} = \mathbf{Xb} + \mathbf{Zu} + \mathbf{e}
$$
where $\mathbf{y}$ is a vector of observations, $\mathbf{b}$ is a vector of fixed effects, $\mathbf{u}$ is a vector of random effects, $\mathbf{e}$ is a vector of residuals, $\mathbf{X}$ and $\mathbf{Z}$ are incidence matrices.
In a general form, we can write $\mathrm{var}(\mathbf{u}) = \mathbf{G}$^[This $\mathbf{G}$ does not mean the genomic relationship matrix. This is the traditional notation describing a covariance structure of random effects.] and $\mathrm{var}(\mathbf{e}) = \mathbf{R}$ and the mixed model equations should be
$$
\left[
\begin{array}{ll}
\mathbf{X}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{X}'\mathbf{R}^{-1}\mathbf{Z} \\
\mathbf{Z}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{Z}'\mathbf{R}^{-1}\mathbf{Z} + \mathbf{G}^{-1}
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
\mathbf{X}'\mathbf{R}^{-1}\mathbf{y} \\
\mathbf{Z}'\mathbf{R}^{-1}\mathbf{y}
\end{array}
\right].
$$


For simplicity, we here assume $\mathrm{var}(\mathbf{u}) = \mathbf{I}\sigma_s^2$ and $\mathrm{var}(\mathbf{e}) = \mathbf{I}\sigma_e^2$ so, the mixed model equations reduce to
$$
\left[
\begin{array}{ll}
\mathbf{X}'\mathbf{X}\sigma_e^{-2} & \mathbf{X}'\mathbf{Z}\sigma_e^{-2} \\
\mathbf{Z}'\mathbf{X}\sigma_e^{-2} & \mathbf{Z}'\mathbf{Z}\sigma_e^{-2} + \mathbf{I}\sigma_s^{-2}
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
\mathbf{X}'\mathbf{y}\sigma_e^{-2} \\
\mathbf{Z}'\mathbf{y}\sigma_e^{-2}
\end{array}
\right]
$$



The system of mixed model equations is often presented as
$$
\left[
\begin{array}{ll}
\mathbf{X}'\mathbf{X} & \mathbf{X}'\mathbf{Z} \\
\mathbf{Z}'\mathbf{X} & \mathbf{Z}'\mathbf{Z} + \mathbf{I}\lambda
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
\mathbf{X}'\mathbf{y} \\
\mathbf{Z}'\mathbf{y}
\end{array}
\right]
$$
where $\lambda=\sigma_e^2/\sigma_s^2$.
This model looks like a simple sire model with unrelated sires in animal breeding.


Note that BLUPF90 always creates the equations with $\mathbf{R}^{-1}$; $\lambda$ is never calculated.
Precisely, $1/\sigma_e^2$ is always calculated and accumulated to the left-hand side (LHS) and $1/\sigma_s^2$ is also added to LHS.
Basically, the program needs explicit values for variance components.
Here we assume $\sigma_s^2 = 1.0$ and $\sigma_e^2 = 2.0$.

We can use exactly the same data file shown before. The file name is altered just for our convenience.

~~~~~{language=text caption="data2.txt"}
3.0  1  1  1.0
2.0  1  2  1.0
4.0  1  1  2.0
6.0  2  2  2.0
3.0  2  1  1.0
6.0  2  2  2.0
6.0  3  1  2.0
6.0  3  2  1.0
8.0  3  1  1.0
4.0  3  2  2.0
~~~~~

The parameter file is shown below.

~~~~~{language=blupf90 caption="param2.txt"}
DATAFILE
data2.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
3
OBSERVATION(S)
1
WEIGHT(S)

EFFECTS:
2 3 cross
3 2 cross
4 1 cov
RANDOM_RESIDUAL VALUES
2.0
RANDOM_GROUP
2
RANDOM_TYPE
diagonal
FILE

(CO)VARIANCES
1.0
~~~~~

The first 7 keywords are the same as used in the fixed effect models.
To define the random effect, we use 4 extra keywords^[The common 7 keywords build the design-matrix parts in the mixed model equations i.e., $\mathbf{X}'\mathbf{X}$, $\mathbf{X}'\mathbf{Z}$, $\mathbf{Z}'\mathbf{X}$ and $\mathbf{Z}'\mathbf{Z}$. The additional 4 keywords provide the covariance structure, and $\mathbf{G}^{-1}$] just placed after the common keywords.

  1. `RANDOM GROUP` = showing which effect is random in the `EFFECTS` block
     - 2 for the second line (effect 2) in `EFFECTS` is the random effect
  2. `RANDOM_TYPE` = covariance structure
     - diagonal for identity covariance matrix i.e. diagonals only
  3. `FILE` = additional file for the covariance structure
     - empty for no information needed here
  4. `(CO)VARIANCES` = variance component $\sigma_s^2$
     - 1.0 for the variance

If you have 2 or more random effects (e.g., permanent environmental or maternal effect), you can add another extra 4 keywords to the parameter file.
We will see such a case later.
The solutions will be very different from the previous one which assumes effect 2 is a fixed effect.

~~~~~{language=text caption="solutions"}
trait/effect level  solution
   1   1         1      2.30434783
   1   1         2      4.26086957
   1   1         3      5.28260870
   1   2         1      0.17391304
   1   2         2     -0.17391304
   1   3         1      0.47826087
~~~~~

The solution file contains both BLUE for the fixed effects and BLUP for the random effects.
The first column is always 1 because it is a single-trait model; the 2nd column shows the effect number from 1 to 3; the 3rd column shows the level in each effect; the fourth column contains the solutions.
The first 3 solutions are for the effct 1 ($A_i$), the next 2 solutions for effect 2 ($S_j$) and the last 1 solution for the regression ($\beta$).
Details are: $\hat{A}_1 = 2.30$, $\hat{A}_2 = 4.26$, $\hat{A}_3 = 5.28$, $\hat{S}_1 = 0.17$, $\hat{S}_2 = -0.17$ and $\hat{\beta} = 0.48$.

The animal model
----------------

The animal model specifically refers to a mixed model with individual additive genetic effect as a random effect.
Genetic covariances between animals are considered with a numerator relationship matrix.
You need a pedigree file for this model.
In this section, we assume the same model above with additive genetic effects.
An animal has either one observation or no observation (where the animal is only in a pedigree file).
The mathematical model is the following:
$$
y_{ijk} = A_i + S_j + \beta x_k + u_k + e_{ijk}
$$
where $u_k$ is the additive genetic effect for an animal $k$.
Here we treat $S_j$ as a fixed effect.
The system of mixed model equations is
$$
\left[
\begin{array}{ll}
\mathbf{X}'\mathbf{X}\sigma_e^{-2} & \mathbf{X}'\mathbf{Z}\sigma_e^{-2} \\
\mathbf{Z}'\mathbf{X}\sigma_e^{-2} & \mathbf{Z}'\mathbf{Z}\sigma_e^{-2} + \mathbf{A}^{-1}\sigma_u^{-2}
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
\mathbf{X}'\mathbf{y}\sigma_e^{-2} \\
\mathbf{Z}'\mathbf{y}\sigma_e^{-2}
\end{array}
\right]
$$

where $\mathbf{A}$ is a numerator relationship matrix, $\sigma_u^2$ is the additive genetic variance,  and $\sigma_e^2$ is the residual variance.

We further extend the data table to add an animal's ID (code).
We show the actual data file to be used in this analysis.

~~~~~{language=text caption="data3.txt"}
  3.0  1  1  1.0   6
  2.0  1  2  1.0   9
  4.0  1  1  2.0  12
  6.0  2  2  2.0   7
  3.0  2  1  1.0  10
  6.0  2  2  2.0  13
  6.0  3  1  2.0   8
  6.0  3  2  1.0  11
  8.0  3  1  1.0  14
  4.0  3  2  2.0  15
~~~~~

In the data file, animal ID starts with 6; it means animals 1 to 5 have no observation so, they are not included in the data file.
The order of animal ID is totally arbitrary, and you don't have to order the animals chronologically.

We show the pedigree file below.
Pedigree information consists of 3 columns: animal ID, its sire's ID, and its dam's ID.
If an animal's parent is unknown (missing), you should put `0`.
The following is the pedigree in this analysis.

~~~~~{language=text caption="pedigree3.txt"}
  1   0   0
  2   0   0
  3   0   0
  4   0   0
  5   0   0
  6   0   0
  7   2   5
  8   1   4
  9   2   3
 10   7   6
 11   7   4
 12  11   8
 13  11  10
 14   9  13
 15  11  10
~~~~~

The individual ID should be an integer value, and it corresponds to one in the data file.
If your data has non-integer animal IDs, you can use the RENUMF90 program to replace the characters with integer values in both pedigree and data.
You don't have to records the ID is chronological order.
Also, you don't need to sort the ID in this file.

The basic format of the parameter file is the same as the previous one.
We assume $\sigma_a^2 = 0.5$ and $\sigma_e^2 = 2.0$.

~~~~~{language=blupf90 caption="param3.txt"}
DATAFILE
data3.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
4
OBSERVATION(S)
1
WEIGHT(S)

EFFECTS:
2  3 cross
3  2 cross
4  1 cov
5 15 cross
RANDOM_RESIDUAL VALUES
2.0
RANDOM_GROUP
4
RANDOM_TYPE
add_animal
FILE
pedigree3.txt
(CO)VARIANCES
0.5
~~~~~

There are 6 modifications in this file compared to the previous one.

  1. `NUMBER_OF_EFFECTS` = Because the additive genetic effect is added, the number of effects should be incremented.
        - The total number of effects is 4.
  2. `EFFECTS:` = The added effect is in the 4th row.
        - `5` for the position of ID in the data file, 15 for the total number of animals (in the pedigree), and `cross` for cross-classified effect.
  3. `RANDOM_GROUP` = It represents which effect is random in `EFFECTS:`
        - The 4th effect in the block is a random effect.
  4. `RANDOM_TYPE` = covariance structure
        - `add_animal` for additive genetic effect
  5. `FILE` = pedigree file
        - `pedigree4.txt`
  6. `(CO)VARIANCES` = the variance component of this random effect
        - $\sigma_{a}^{2}=0.5$

Now you can run BLUPF90 and obtain the solutions.

~~~~~{language=text caption="solutions"}
trait/effect level  solution
   1   1         1      0.20259645
   1   1         2      2.21996461
   1   1         3      3.16680208
   1   2         1      2.27537292
   1   2         2      1.71160538
   1   3         1      0.52442755
   1   4         1     -0.03487115
   1   4         2      0.08280493
   1   4         3      0.03843921
   1   4         4      0.04492008
   1   4         5      0.04436203
   1   4         6     -0.17565609
   1   4         7      0.10794668
   1   4         8     -0.02984646
   1   4         9      0.09906236
   1   4        10     -0.25282594
   1   4        11      0.15622415
   1   4        12      0.10874296
   1   4        13      0.16426465
   1   4        14      0.34296714
   1   4        15     -0.25707431
~~~~~

The solution file contains both BLUE for the fixed effects and BLUP for the random effects.
The first column is always 1 because it is a single-trait model; the 2nd column shows the effect number from 1 to 4; the 3rd column shows the level in each effect; the fourth column contains the solutions.
The first 3 solutions are for effect 1 ($A_i$), the next 2 solutions for effect 2 ($S_j$), the next 1 solution for the regression ($\beta$) and the remaining 15 solutions for the additive genetic effect i.e., estimated breeding values ($u_k$).
Details are: $\hat{A}_1 = 0.203$, $\hat{A}_2 = 2.220$, $\hat{A}_3 = 3.167$, $\hat{S}_1 = 2.275$, $\hat{S}_2 = 1.711$, $\hat{\beta} = 0.524$, $\hat{u}_1 = -0.035$, $\hat{u}_2 = 0.083$, $\hat{u}_3 = 0.038$, and so on.


More than 1 random effect
-------------------------

We often meet a model with more than 1 random effect such as repeatability model (additive genetic + permanent environmental [PE] effect) or maternal effect model (direct + maternal + maternal PE effect).
BLUPF90 supports such a complicated model.
We assume the same animal model described above except for $S_j$ as random:
$$
y_{ijk} = A_i + S_j +\beta x_k + u_k + e_{ijk}
$$
where $S_j$ and $u_k$ are random effects.
To perform the analysis, we can use the same data file and the pedigree file.
We assume that the two random effects $S_{j}$ and $u_{k}$ are not related to each other and $\sigma_s^2 = 1.0$, $\sigma_u^2 = 0.5$ and $\sigma_e^2 = 2.0$.
We need to modify the parameter file to include additional random effect.

~~~~~{language=blupf90 caption="param3a.txt"}
DATAFILE
data3.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
4
OBSERVATION(S)
1
WEIGHT(S)

EFFECTS:
2  3 cross
3  2 cross
4  1 cov
5 15 cross
RANDOM_RESIDUAL VALUES
2.0
RANDOM_GROUP
4
RANDOM_TYPE
add_animal
FILE
pedigree3.txt
(CO)VARIANCES
0.5
RANDOM_GROUP
2
RANDOM_TYPE
diagonal
FILE

(CO)VARIANCES
1.0
~~~~~

We just a set of 4 keywords (`RANDOM_GROUP`, `RANDOM_TYPE`, `FILE` and `(CO)VARIANCES`) to the last parameter file for the additional random effect $S_{j}$.
In other words, such 4 keywords are optional; you can add the 4 keywords as you include one more random effect if the effects are unrelated to each other.

If the random effects are correlated with each other, you should use a different way.
This happens in a maternal effect model (direct and maternal genetic effect) and random regression model (random regression coefficients).
Multiple-trait model is also another story.
We do not explain such cases here but we will consider them in later chapters.

The solutions are shown below.

~~~~~{language=text caption="solutions"}
trait/effect level  solution
   1   1         1      2.27101829
   1   1         2      4.24566929
   1   1         3      5.21524118
   1   2         1      0.18586035
   1   2         2     -0.18586066
   1   3         1      0.49101139
   1   4         1     -0.01963655
   1   4         2      0.06556686
   1   4         3      0.02911205
   1   4         4      0.04793111
   1   4         5      0.03646405
   1   4         6     -0.15943505
   1   4         7      0.08747653
   1   4         8     -0.00548994
   1   4         9      0.07644881
   1   4        10     -0.24829955
   1   4        11      0.13527276
   1   4        12      0.12002543
   1   4        13      0.15461713
   1   4        14      0.33690598
   1   4        15     -0.27372367
~~~~~

The order of the solutions is the same as the previous animal model but the effect 2 is now a random effect.
The order of the solutions is determined using `EFFECTS:` block in the parameter file.
So even if you add more random effects, the order will not be changed.


Remarks
-------

BLUPF90 builds the mixed model equations simply following the parameter file.
Even if your parameter file has no fixed effect (i.e., it has random effects only), the program doesn't add any fixed effect to the model.
Without any fixed effects, the solutions may be nonsense.
If you want to perform a random effect model with the general mean, you should prepare an additional column containing 1 in the data file and describe it as a fixed effect in the parameter file.

In the animal model with `add_animal`, BLUPF90 doesn't consider inbreeding; $\mathbf{A}^{-1}$ is constructed with Henderson's method ignoring inbreeding.
BLUPF90 supports $\mathbf{A}^{-1}$ with inbreeding but the program doesn't calculate the inbreeding coefficients.
The user should calculate the inbreeding coefficients and put them into the pedigree file with a special format.
With this special pedigree file and the use of `add_an_upginb` (instead of `add_animal`), the inbreeding will be successfully incorporated.
RENUMF90 can prepare such a pedigree file.


Summary
-------

 - BLUPF90 supports linear mixed models with 1 or more random effects.
 - BLUPF90 needs 3 text files: data, pedigree and parameter files.
 - A pedigree file is needed if you conduct genetic analyses.
 - The pedigree file should contain 3 columns: animal ID, sire ID, and dam ID. The ID must be an integer value.
 - To define a random effect, add 4 keywords (`RANDOM_GROUP`, `RANDOM_TYPE`, `FILE` and `(CO)VARIANCES`) and the corresponding values to the parameter file.
 - The order of the solutions depends on the `EFFECTS:` block in the parameter file.
 - You should manually add the general mean if you use a random effect model.
 - With `add_animal`, inbreeding is ignored in the calculation of $\mathbf{A}^{-1}$.
