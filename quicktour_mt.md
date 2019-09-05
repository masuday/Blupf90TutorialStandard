---
title: Quick tour of BLUPF90
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Trivial analyses for multiple-trait models
==========================================

BLUPF90 supports multiple-trait models with few modifications to a parameter file for the single-trait model.
In this section, we consider a simple multiple-trait model and introduce some extensions in a parameter file.

Basic elements
--------------

### Model description ###

We extend the single-trait animal-model shown in the previous section, but no genomics.
We will consider a 2-trait model with the same effects on both traits.
Also, we assume we have no missing observations.
A mathematical model for each trait can be written as follows.

$$
\begin{aligned}
y_{ijk:1} &= A_{i:1} + S_{j:1} + \beta x_{ijk:1} + u_{k:1} + e_{ijk:1}\\
y_{ijk:2} &= A_{i:2} + S_{j:2} + \beta x_{ijk:2} + u_{k:2} + e_{ijk:2}
\end{aligned}
$$

The mixed model can be written with a typical form introduced as before.
$$
\mathbf{y} = \mathbf{Xb} + \mathbf{Zu} + \mathbf{e}
$$
With matrix notation, this model can be expressed in 2 ways depending on the order of observations.

Ordering animals within trait:
  $\mathbf{y} = \left[\begin{array}{l|l}y_{1:1}, y_{2:1}, y_{3:1}, \cdots, y_{n:1} & y_{1:2}, y_{2:2}, y_{3:2}, \cdots, y_{n:2}\end{array}\right]$

Ordering traits within animal:
  $\mathbf{y} = \left[\begin{array}{l|l|l|l|l}y_{1:1}, y_{1:2} & y_{2:1}, y_{2:2} & y_{3:1}, y_{3:2} & \cdots & y_{n:1}, y_{n:2}\end{array}\right]$

This difference is not essential on conducting the analysis but you should recognize the difference when writing down the mathematical model in matrix notation.
Above two results in the different representation of mixed model equations even if the solutions are identical.
Because BLUPF90 programs use the latter, we will describe the model with this rule.

In this case, the variance of $\mathbf{y}$ is
$$
\mathrm{var}(\mathbf{y}) = \mathbf{Z}\left(\mathbf{A} \otimes \mathbf{G}_{0}\right)\mathbf{Z}' + \mathbf{I} \otimes \mathbf{R}_{0}
$$
where $\mathbf{G}_{0}$ is the genetic variance-covariance matrix among traits ($2 \times 2$ in this case), $\mathbf{R}_{0}$ is the residual variance-covariance matrix among traits (also $2 \times 2$ in this case), $\mathbf{I}$ is the identity matrix ($N \times N$; $N$ is the number of observations in a trait) and $\otimes$ is an operator for Kronecker product.
Elements of each covariance matrix and its inverse can be written as
$$
\begin{aligned}
\mathbf{G}_{0}
=
\left[
\begin{array}{ll}
\sigma_{g1}^{2}&\sigma_{g12}\\
\sigma_{g21}&\sigma_{g2}^{2}\\
\end{array}
\right]
\quad
\text{and}
\quad
\mathbf{G}_{0}^{-1}
=
\left[
\begin{array}{ll}
\sigma^{g1}&\sigma^{g12}\\
\sigma^{g21}&\sigma^{g2}\\
\end{array}
\right]\\
\mathbf{R}_{0}
=
\left[
\begin{array}{ll}
\sigma_{e1}^{2}&\sigma_{e12}\\
\sigma_{e21}&\sigma_{e2}^{2}\\
\end{array}
\right]
\quad
\text{and}
\quad
\mathbf{R}_{0}^{-1}
=
\left[
\begin{array}{ll}
\sigma^{e1}&\sigma^{e12}\\
\sigma^{e21}&\sigma^{e2}\\
\end{array}
\right].
\end{aligned}
$$

Kronecker product is not a regular product.
Consult the following examples:
$$
\mathbf{A}\otimes\mathbf{G}_{0}
=
\left[
\begin{array}{llll}
a_{11}\mathbf{G}_{0}&a_{12}\mathbf{G}_{0}&\cdots&a_{1n}\mathbf{G}_{0}\\
a_{21}\mathbf{G}_{0}&a_{22}\mathbf{G}_{0}&\cdots&a_{2n}\mathbf{G}_{0}\\
\vdots&\cdots&\ddots&\vdots\\
a_{n1}\mathbf{G}_{0}&a_{n2}\mathbf{G}_{0}&\cdots&a_{nn}\mathbf{G}_{0}\\
\end{array}
\right]
\quad
\text{and}
\quad
\mathbf{I}\otimes\mathbf{R}_{0}
=
\left[
\begin{array}{llll}
\mathbf{R}_{0}&\mathbf{0}&\cdots&\mathbf{0}\\
\mathbf{0}&\mathbf{R}_{0}&\cdots&\mathbf{0}\\
\vdots&\vdots&\ddots&\vdots\\
\mathbf{0}&\mathbf{0}&\cdots&\mathbf{R}_{0}\\
\end{array}
\right]
$$
where $n$ is the number of pedigree animals and $a_{ij}$ is the $i$th row and the $j$th column element of $\mathbf{A}$.
In the latter equation, $\mathbf{R}_{0}$ is repeated $N$ times on diagonal.

The system of mixed model equations is
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
\right].
$$
This may look very different from a typical description for some people.
But, again, the form of the equations don't affect the solutions.

### Required files ###

In this 2-trait model, we need 2 columns for observations (one for the trait 1 and the other one for trait 2).
Also, we need the columns for effects in each trait.
We assume the same model in both traits.
We can share the same columns for the effects in the data file.

As an example, we extend the data used in the previous animal model analysis.

~~~~~{language=text caption="data5.txt"}
  3.0   4.5  1  1  1.0   6
  2.0   7.5  1  2  1.0   9
  4.0   3.5  1  1  2.0  12
  6.0  -0.5  2  2  2.0   7
  3.0   5.5  2  1  1.0  10
  6.0   1.5  2  2  2.0  13
  6.0  -1.5  3  1  2.0   8
  6.0   2.5  3  2  1.0  11
  8.0   0.5  3  1  1.0  14
  4.0   4.5  3  2  2.0  15
~~~~~

The pedigree file is the same as the previous one.
Here we changed the file name with the same content.

~~~~~{language=text caption="pedigree5.txt"}
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

The parameter file also looks like very similar to the previous one except it describes covariance matrices and a model for each trait.
We assume $\sigma_{g1}^2=0.5$, $\sigma_{g12}=-0.25$, and $\sigma_{g2}^{2}=1.0$ for genetic (co)variances and $\sigma_{e1}^{2}=2.0$, $\sigma_{e12} = 1.0$, and $\sigma_{e2} = 1.5$ for residual (co)variances.

~~~~~{language=blupf90 caption="param5.txt"}
DATAFILE
data5.txt
NUMBER_OF_TRAITS
2
NUMBER_OF_EFFECTS
4
OBSERVATION(S)
1 2
WEIGHT(S)

EFFECTS:
3 3 3 cross
4 4 2 cross
5 5 1 cov
6 6 15 cross
RANDOM_RESIDUAL VALUES
2.0 1.0
1.0 1.5
RANDOM_GROUP
4
RANDOM_TYPE
add_animal
FILE
pedigree5.txt
(CO)VARIANCES
 0.50 -0.25
-0.25  1.00
~~~~~

For a multiple-trait mode, we should carefully describe the following values.

- `NUMBER_OF_TRAITS` = appropriate number of traits
    - `2`: two-trait model
- `OBSERVATION(S)` = enumerate the positions of observations in the data file
    - `1 2`: the first and second columns; `1` for trait 1 and `2` for trait 2.
- `EFFECTS:` = enumerate the positions of effect, the number of levels and the effect type
    - `3 3 3 cross`: the position of effect 1 for trait 1 (`3`); the position of effect 1 for trait 2 (`3`); the number of levels (`3`); effect type (`cross`)
    - `4 4 2 cross`: the position of effect 2 for trait 1 (`4`); the position of effect 2 for trait 2 (`4`); the number of levels (`2`); effect type (`cross`)
    - `5 5 1 cov`: the position of effect 3 for trait 1 (`5`); the position of effect 3 for trait 2 (`5`); the number of levels (`3`); effect type (`cov`)
    - `6 6 15 cross`: the position of effect 4 for trait 1 (`6`); the position of effect 4 for trait 2 (`6`); the number of levels (`15`); effect type (`cross`)
- `RANDOM RESIDUAL VALUES` = residual covariance matrix
    - full $2 \times 2$ matrix; total 4 elements should be here.
- `(CO)VARIANCES` = genetic covariance matrix
    - full $2 \times 2$ matrix; total 4 elements should be here.

You should be careful to write the `EFFECT:` block.
With 2-trait model, each statement has to have 4 elements; the first 2 for the positions of effect for each trait in the data file, the next 1 for the number of levels and the last 1 for effect type.
If you run a model with $n$ traits, the first $n$ elements should be the positions of effects for each trait.

Residual and genetic covariance matrices should be fully described i.e., all upper, diagonal, and lower elements.
The lines including a covariance matrix can't accept comments.


Resulting solutions
-------------------

Running BLUPF90 with above parameter file, the solutions file contains are following.

~~~~~{language=text caption="solutions"}
trait/effect level  solution
   1   1         1      0.19990999
   2   1         1      5.43362035
   1   1         2      2.30088577
   2   1         2      2.42229505
   1   1         3      3.21493025
   2   1         3      1.78930980
   1   2         1      2.31093239
   2   2         1      2.25555489
   1   2         2      1.76148927
   2   2         2      3.88944218
   1   3         1      0.54865198
   2   3         1     -2.42030677
   1   4         1     -0.02253416
   2   4         1     -0.04249548
   1   4         2      0.10792661
   2   4         2     -0.13113037
   1   4         3     -0.02682949
   2   4         3      0.09896514
   1   4         4      0.03164894
   2   4         4     -0.02495242
   1   4         5      0.13475233
   2   4         5     -0.23009750
   1   4         6     -0.22496602
   2   4         6      0.32971990
   1   4         7      0.25609198
   2   4         7     -0.41070894
   1   4         8     -0.01797409
   2   4         8     -0.07622271
   1   4         9      0.01371895
   2   4         9      0.08288296
   1   4        10     -0.84143020
   2   4        10      1.63889151
   1   4        11      0.19804880
   2   4        11     -0.20028530
   1   4        12      0.03355559
   2   4        12      0.06720834
   1   4        13      0.10550434
   2   4        13      0.07202442
   1   4        14      0.52502266
   2   4        14     -0.66337381
   1   4        15     -1.00156891
   2   4        15      2.01449847
~~~~~

This is long because every effect was considered in both traits.
The format is the same as the previous one except for the first column containing 1 or 2.
You can obtain 2 solutions, for trait 1 and trait 2, in every effect.
For example, estimated breeding values for animal 13 are 0.1055 for trait 1 and 0.0702 for trait 2.

For your information, the order of solutions in the file is the same as in memory.
It is corresponding to the matrix notation described before.


Remarks
-------

You can put a missing observation in the data file.
The missing value is `0` by default but you can change the value with an option `OPTION missing`.
The missing code is an integer value (positive or negative).
At least 1 trait has a real observation.
In other words, missing-in-all-traits is not allowed.

The program supports different models in different traits (unequal design matrices).
You can put 0 as a position in `EFFECT:` block if the trait doesn't the effect.
At least 1 trait has to have a non-zero position.
We will see such models in the later chapter.

Single-step GBLUP is supported in the multiple-trait model.
You can add `OPTION SNP_file` to perform such a model.


Summary
-------

- BLUPF90 supports multiple-trait models.
- The same data and pedigree files to a single-trait case can be used.
- Parameter file should be modified to fit the multiple-trait model.
- In the `EFFECT:` block, each statement should have $n$ positions of effects for $n$ trait model.
- Missing values are allowed. The default is 0 and you can change the missing code with an option.
- Each trait may have a different model i.e., different effects.
