---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Animal model
============

Model
-----

<!--
Mrode (2014) considered the pre-weaning gain (WWG) as a target trait and applied the following
linear model to the trait.
$$
y_{ij} = p_i + a_j + e_{ij}
$$
where $y_{ij}$ is the observation of j-th calf of the i-th sex, $p_{i}$ is the fixed effect of the i-th sex, $a_j$ is the
random effect (additive genetic effect) of the j-th calf and $e_{ij}$ is the random error effect. Assume
that the genetic variance was $\sigma_u^2$ = 20 and the residual variance was $\sigma_e^2= 40$. This is a typical
animal model which have been already introduced in the previous chapter.
$$
\left[
\begin{array}{ll}
\mathbf{X}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{X}'\mathbf{R}^{-1}\mathbf{Z} \\
\mathbf{Z}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{Z}'\mathbf{R}^{-1}\mathbf{Z} + \mathbf{A}^{-1}/\sigma_u^{2}
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
\right]
$$
where $\mathbf{R} = \mathbf{I}\sigma_e^2$. BLUPF90 always create the equation with this formula. The textbook, however,
creates a simplified version of the equations with a variance ratio $\alpha=\sigma_e^2/\sigma_u^2$.
$$
\left[
\begin{array}{ll}
\mathbf{X}'\mathbf{X} & \mathbf{X}'\mathbf{Z} \\
\mathbf{Z}'\mathbf{X} & \mathbf{Z}'\mathbf{Z} + \alpha\mathbf{A}^{-1}
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
The two types of equations provide the identical solutions. In this section, first we build the equation
in a regular way with BLUPF90 (the first equation). Then we will demonstrate that BLUPF90 can
create the second type of equations.
-->

Mrode (2014) considered the pre-weaning gain (WWG) as a target trait, and he applied a linear mixed model to the trait with a fixed effect (sex), a random effect (animal), and the residual effect. Assume that the genetic variance was $\sigma_u^2$ = 20 and the residual variance was $\sigma_e^2= 40$. This is a typical animal model which have been already introduced in the previous chapter.

There are two possible systems of equations: 1) each variance component is explicitly involved in the equations, or 2) $\alpha$, the variance ratio, is used. Two systems of equations should result in the same solutions.

Files
-----

We now prepare the data file (`data_mr03a.txt`). It includes 5 observations just from 5 animals.

<!---
~~~~~{language=text caption="data_mr03a.txt"}
 4 1 1 0 4.5
 5 2 3 2 2.9
 6 2 1 2 3.9
 7 1 4 5 3.5
 8 1 3 6 5.0
~~~~~
~~~~~{language=text caption="data_mr03a.txt"}
 4 1 1 0 4.5
...
~~~~~
--->

The data file has 5 columns as follows. This is the exact copy of the original table in the textbook.

1. Animal ID (calves)
2. Sex (1 for male and 2 for female)
3. Sire ID
4. Dam ID
5. Observations (WWG, kg)

Column 3 and 4 are not actually used in this analysis.

A pedigree file is also prepared. The 1st column is animal ID, the 2nd column for sire ID and the 3rd column for dam ID.

<!--
~~~~~{language=text caption="pedigree_mr03a.txt"}
1 0 0
2 0 0
3 0 0
4 1 0
5 3 2
6 1 2
7 4 5
8 3 6
~~~~~
~~~~~{language=text caption="pedigree_mr03a.txt"}
1 0 0

...

8 3 6
~~~~~
-->

The parameter file is as follows. To obtain the exact solutions, we have `OPTION solve_method FSPAK`. With this option, we can calculate the reliability of a solution using the diagonal elements that is, prediction error variance (PEV)) of the inverse of the left-hand side of mixed model equations. Additional option `OPTION sol se` is needed to calculate PEV.

~~~~~{language=blupf90 caption="param_mr03a.txt"}
DATAFILE
data_mr03a.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
2
OBSERVATION(S)
5
WEIGHT(S)

EFFECTS:
2 2 cross
1 8 cross
RANDOM_RESIDUAL VALUES
40.0
RANDOM_GROUP
2
RANDOM_TYPE
add_animal
FILE
pedigree_mr03a.txt
(CO)VARIANCES
20.0
OPTION solv_method FSPAK
OPTION sol se
~~~~~

Solutions
---------

Invoking BLUPF90 with above parameter file, we immediately see the solution in the file solutions.

~~~~~{language=text caption="solutions"}
trait/effect level  solution          s.e.
   1   1         1          4.35850233          4.88082357
   1   1         2          3.40443010          5.66554023
   1   2         1          0.09844458          4.34094096
   1   2         2         -0.01877010          4.43664612
   1   2         3         -0.04108420          4.27297922
   1   2         4         -0.00866312          4.13608581
   1   2         5         -0.18573210          4.13814812
   1   2         6          0.17687209          4.20610397
   1   2         7         -0.24945855          4.20407502
   1   2         8          0.18261469          4.11029997
~~~~~

The solutions are identical to solutions shown in the textbook (pp.39). The above `s.e.` is the square root of diagonal elements of the inverse of the left-hand side. Note that the above `s.e.` is actually SEP (standard error of prediction) in the textbook (pp.45) not PEV. This happened because BLUPF90 created general mixed model equations explicitly containing $\sigma_e^2$ and $\sigma_u^2$ rather than the variance ratio $\alpha=\sigma_e^2/\sigma_u^2$. So we do not need to multiply extra $\sigma_e^2$ by the inverse element to obtain PEV. Below, we will demonstrate the same left-hand side shown in the textbook and confirm its inverse equals to results in the textbook.

Alternative parameter file
--------------------------

The textbook uses a simplified form of mixed model equations in the single-trait analysis. BLUPF90 can handle this form with a tricky (not recommended) way. In this form, only the variance ratio matters. The ratio is $\alpha=\sigma_e^2/\sigma_u^2=2.0$ and it is equivalent to assuming $\sigma_e^2=1.0$ and $\sigma_u^2=0.5$. The parameter file has these "equivalent" variance components.

~~~~~{language=blupf90 caption="param_mr03a1.txt"}
DATAFILE
data_mr03a.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
2
OBSERVATION(S)
5
WEIGHT(S)

EFFECTS:
2 2 cross
1 8 cross
RANDOM_RESIDUAL VALUES
1.0
RANDOM_GROUP
2
RANDOM_TYPE
add_animal
FILE
pedigree_mr03a.txt
(CO)VARIANCES
0.5
OPTION solv_method FSPAK
OPTION sol se
~~~~~

The solutions are the following.

~~~~~{language=text caption="solutions"}
trait/effect level  solution          s.e.
   1   1         1          4.35850233          0.77172597
   1   1         2          3.40443010          0.89580057
   1   2         1          0.09844458          0.68636303
   1   2         2         -0.01877010          0.70149535
   1   2         3         -0.04108420          0.67561734
   1   2         4         -0.00866312          0.65397259
   1   2         5         -0.18573210          0.65429867
   1   2         6          0.17687209          0.66504343
   1   2         7         -0.24945855          0.66472263
   1   2         8          0.18261469          0.64989549
~~~~~

This parameter file will provide the same solutions as before. An advantage of this method is to possibly reduce the numerical error because of $\sigma_e^2=1$, which does not add the noise to the equations. We square the `s.e.` to obtain a diagonal element of the inverse of the left-hand side matrix. You can calculate the reliability or accuracy of the estimated breeding value by hand.

For example, the diagonal element for animal 1 is $d_1 = 0.68636303^2 \approx 0.471$ which is the same as the reference value in the textbook (pp.45). The $\mathrm{PEV}$ for animal 1 is $\mathrm{PEV}_1 = d_i\sigma_e^2= 0.471 \times 40 = 18.84$. The standard error of prediction is $\mathrm{SEP}_1 = \sqrt{\mathrm{PEV}_1} = \sqrt{18.84} = 4.341$ which is also the same as the textbook. The reliability for animal 1 is $r^2 = 1 - \mathrm{SEP}^2 /\sigma_u^2 = 1 - \mathrm{PEV}/\sigma_u^2 = 1 - 18.84/20 = 0.058$. You can confirm that this rule is true for the other animals.
