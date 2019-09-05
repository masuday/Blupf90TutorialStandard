---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Animal model with unknown parent groups
=======================================

Short introduction to unknown parent groups
-------------------------------------------

Unknown parent groups (as known as genetic groups or phantom groups) are one of the less-understood concepts in animal breeding. We
usually assume the mean breeding value in a base population is 0. The average breeding value
by generation or birth year will increase (or decrease) by selection. If we have complete pedigree back
to the base population, the complete phenotype used as the selection criterion and an appropriate
model to describe the factors for observation, the mixed model can provide an unbiased prediction of
breeding values for all animals. But the reality is different. One of the biggest challenges is incomplete
pedigree. Many young animals may have no pedigree information in a population undergoing
selection. In this case, it is an incorrect assumption that unknown parents belong to the base
population. Under the selection, younger animals have significantly higher (or lower) genetic base
so their parents should have a nonzero average of breeding values.

The genetic group can partially solve this problem. A genetic group looks like a real animal. We
assign a group to unknown parents that are expected to have the same genetic level. A group to
be assigned to parents in the younger generation should be different from a group for older parents
because of different genetic levels. In addition to generation (or birth year), the group may also be
defined by sex, a region of origin, and the selection path.
Because the group is a proxy of the base animal, every real animal is a descendant
of genetic groups.

The groups are likely treated as fixed effects. The expectation of breeding value of the base animals is no longer 0, and it will be replaced with
BLUE for the group effect. Therefore, the final prediction of breeding value for an animal is a
mixture of BLUE for the group effect and BLUP for the breeding value. In spite of this complication,
the mixed model equations with groups are surprisingly simple and look like one from the standard animal model.
For theoretical background, see the textbook in addition to Westell and Van Vleck (1987)
and Quaas (1988) for details.

Model
-----

The mixed model with unknown-parernt groups can be written as follows
$$
\mathbf{y} = \mathbf{Xb} + \mathbf{ZQg} + \mathbf{Zu} + \mathbf{e}
$$
where $\mathbf{Q}$ is a matrix relates the groups to descendant animals and $\mathbf{g}$ is the fixed effect for groups.
We are interested in $\mathbf{u^*}=\mathbf{u} + \mathbf{Qg}$, i.e., the prediction of breeding value
of the individual adjusted by the group effect accounting for the non-zero expectation of base breeding values.
Assuming a single-trait model, the resulting system of mixed model equations is
$$
\left[
\begin{array}{lll}
\mathbf{X}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{X}'\mathbf{R}^{-1}\mathbf{Z} \\
\mathbf{Z}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{Z}'\mathbf{R}^{-1}\mathbf{Z} + \mathbf{A}_{nn}^{-1}/\sigma_u^{2} & \mathbf{A}_{np}^{-1}/\sigma_u^{2}\\
\mathbf{0}&\phantom{\mathbf{Z}'\mathbf{R}^{-1}\mathbf{Z}+\,\,}\mathbf{A}_{pn}^{-1}/\sigma_u^{2} & \mathbf{A}_{pp}^{-1}/\sigma_u^{2}
\end{array}
\right]
\left[
\begin{array}{l}
\mathbf{\hat{b}}\\
\mathbf{\hat{u}^*}
\\
\mathbf{\hat{g}}\\
\end{array}
\right]
=
\left[
\begin{array}{l}
\mathbf{X}'\mathbf{R}^{-1}\mathbf{y} \\
\mathbf{Z}'\mathbf{R}^{-1}\mathbf{y} \\
\mathbf{0}
\end{array}
\right]
$$
and
$$
\mathbf{A}^{-1}
=
\left[
\begin{array}{ll}
\mathbf{A}_{nn}^{-1} & \mathbf{A}_{np}^{-1} \\
\mathbf{A}_{pn}^{-1} & \mathbf{A}_{pp}^{-1}
\end{array}
\right]
$$
where subscript $n$ in $\mathbf{A}^{-1}$ is for real animals and the subscript $p$ is for genetic groups.
This $\mathbf{A}^{-1}$ can be calculated with Henderson's rule with a small extension (Quaas, 1988). BLUPF90 supports the groups in
a regular framework. The BLUPF90 papers prefer to use unknown parent groups (UPG) rather than phantom parents or genetic groups.

Files
-----

We can use the same data file as before (`data_mr03d.txt`).
The pedigree file (`pedigree_mr03d.txt`) has to contain a group code instead of 0 (unknown parent).
The pedigree file must contain 4 columns.

1. Animal ID (1 or larger integer).
2. Sire ID. Can contain a group code.
3. Dam ID. Can contain a group code.
4. Missing parent status: 1 = both parents known, 2 = one parent known and 3 = both parents
   unknown.

A group code must be larger than the last ID for real animals. In this example, because we have 8 real animals,
codes 9 and 10 should be
unknown parent codes. In this example, we have 10 "animals" (actually 8 actual animals + 2 UPG) in the pedigree. The 4th
column is needed to calculate the Mendelian sampling variance for each animal in the program.

The parameter file is also similar to the previous one. You should make 2 changes.

~~~~~{language=blupf90 caption="param_mr03d.txt"}
DATAFILE
data_mr03d.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
2
OBSERVATION(S)
5
WEIGHT(S)

EFFECTS:
2 2 cross
1 10 cross       # change the number of animals to 10 including groups
RANDOM_RESIDUAL VALUES
40.0
RANDOM_GROUP
2
RANDOM_TYPE      # use upg = unknown parent groups
add_an_upg
FILE
pedigree_mr03d.txt
(CO)VARIANCES
20.0
OPTION solv_method FSPAK
~~~~~

Solutions
---------

We will have the following solutions with the above files.

~~~~~{language=text caption="solutions"}
trait/effect level  solution
   1   1         1          4.35899605
   1   1         2          3.21434490
   1   2         1          0.33201730
   1   2         2          0.17597293
   1   2         3          0.13611581
   1   2         4         -0.16882873
   1   2         5          0.00000000
   1   2         6          0.37131040
   1   2         7         -0.23933070
   1   2         8          0.33117127
   1   2         9          1.09907877
   1   2        10         -0.66967475
~~~~~

Do you think these values are very different from the ones in the textbook? The left-hand side of mixed
model equations is not full-rank; the groups are treated as fixed so the model contains 2 fixed class
effects. We should calculate the contrast (the difference between the solutions) to obtain a unique
solution. For example, the difference in breeding values for animal 1 and 2 ($u_1 - u_2$) is 0.156; it is
consistent between this example and the textbook.

In the textbook, the author puts the zero-constraint to the group 1 (corresponding to animal 9
here) but BLUPF90 puts the constraint on the animal 5. BLUPF90 automatically detects
linear-dependency in the equations and puts a constraint to any columns and rows as soon as it finds it necessary. To
make a zero-constraint on the animal 9 in BLUPF90, replace 9 with 0 in the pedigree file and run
BLUPF90 with the same parameter file. You will obtain the following results.

~~~~~{language=text caption="solutions"}
trait/effect level  solution
   1   1         1          5.45807483
   1   1         2          4.31342367
   1   2         1         -0.76706148
   1   2         2         -0.92310585
   1   2         3         -0.96296296
   1   2         4         -1.26790750
   1   2         5         -1.09907877
   1   2         6         -0.72776838
   1   2         7         -1.33840948
   1   2         8         -0.76790750
   1   2         9          0.00000000
   1   2        10         -1.76875353
~~~~~

Be aware that the numerical error is large because of the very small data set. Considering the rounding
error, those values are at a similar level to the textbook.

This analysis provides us caution about the solutions of breeding values from unknown parent
groups. Depending on methods or constraints, we obtain the infinite number of solutions because
there is a dependency between the group effect and the other fixed effects. The raw solutions have
already included the group effects, so 
we should look at the difference between the two solutions for comparison. A better way to express the breeding value
is to adjust it with the average of animals with a similar condition. For example, in dairy cattle, the
estimated breeding value is adjusted with the average of breeding values for cows born in a specific
year. Such a reference population is called a genetic base. In a population undergoing selection, the
average breeding value is continuously increasing (or decreasing) so the genetic base should be
revised every few years.

One more caution must be given. When using UPG, the square root of the prediction error variance in the
solution file (available by `OPTION sol se`) will be nonsense. This is because the prediction is a combination
of BLUE and BLUP ($\mathbf{Qg}+\mathbf{u}$) and the corresponding element of the inverse of the left-hand side
matrix does not give the prediction error variance. If you want to have PEV of the breeding value, you have to
use a workaround --- just to use the non-UPG model for the PEV computation.
