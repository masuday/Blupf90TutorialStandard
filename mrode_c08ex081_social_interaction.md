---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Social interaction effects
==========================

Model
-----

When an animal is raised with a few other animals in a limited space (e.g., a pen or cage), there is
social interaction (e.g., competition) among the animals. The animal's phenotype will be affected
with its own genetic and environmental effects as well as the competitors' contributions. The
competitors' effects look like environmental contributions to the animal. This structure is similar to
the maternal animal model introduced in the previous section. Some of the competitors' contributions
can come from genes carried by the competitors and the rest comes from non-genetic factors.
The genetic component can be correlated with the animal's direct genetic effect. A statistical model
should include a complicated covariance structure.

In this example, we have 3 pens and each pen has 3 animals ($n = 3$).
See the textbook for detailed formulation.

The model contains sex as the fixed effect; the direct and associative genetic
effects, pen (group), and common environmental (full-sibs) effects as random effects. The author
assume $n = 3$ and $\sigma_g^2 = 12.12$ (group variance), $\sigma_e^2 = 60.6$ (the original residual variance),
$\sigma_e^{2*} =60.6 - 12.12 = 48.48$ (the final residual variance), $\sigma_c^2 = 12.5$ (common environmental variance)
and
$$
\mathbf{G}_{0}
=
\left[
\begin{array}{ll}
25.70&2.25\\
2.25&3.60
\end{array}
\right].
$$


Files
-----

The data set is shown in p.125 (`data_mr08a.txt`).
We added 3 columns as competitors' ID.

~~~~~{language=text caption="data_mr08a.txt"}
 7 1 4 1 1  5.50   8  9  1
 8 1 4 1 2  9.80   7  9  1
...
~~~~~

Each column has the following information.

   1. Animal ID
   2. Sire ID
   3. Dam ID
   4. Pen (group)
   5. Sex (1=male and 2=female)
   6. Growth rate (10$\times$g/day)
   7. ID of competitor 1 in the same pen
   8. ID of competitor 2 in the same pen
   9. Half-sib code (common environment)

The pedigree is derived from the data set.

The parameter file looks like a maternal animal model. See the textbook and make sure the order of effects is correct (p.126).

~~~~~{language=text caption="param_mr08a.txt"}
DATAFILE
data_mr08a.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
6
OBSERVATION(S)
6
WEIGHT(S)

EFFECTS:
 5  2 cross  # sex
 1 15 cross  # direct genetic
 7  0 cross  # associative genetic 1
 8 15 cross  # associative genetic 2
 9  3 cross  # common environmental
 4  3 cross  # random group (pen)
RANDOM_RESIDUAL VALUES
48.48
RANDOM_GROUP
2 3
RANDOM_TYPE
add_animal
FILE
pedigree_mr08a.txt
(CO)VARIANCES
25.7 2.25
2.25 3.60
RANDOM_GROUP
5
RANDOM_TYPE
diagonal
FILE

(CO)VARIANCES
12.5
RANDOM_GROUP
6
RANDOM_TYPE
diagonal
FILE

(CO)VARIANCES
12.12
OPTION solv_method FSPAK
~~~~~

The parameter file is tricky. The 3rd effect in `EFFECTS:` is defined with 0 levels. This works
with the 4th effect to put two elements on the same row in the incidence matrix $\mathbf{Z}_S$ (see p.126).
Each statement in `EFFECTS` can put only one element on a row of the system of mixed model equations. If we define an effect with
0 levels, this effect is not recognized as a new effect and combined with the next effect. In this
case, the 3rd effect is successfully processed but the offset address is not incremented, so the 4th
effect will be put the same row in $\mathbf{Z}_S$.

We can see what is going on processing the data with those 2 statements (effect 3 and 4). Consider
the first line in the data file.

     7   1   4   1    1   5.50    8   9   1

The 2 statements perform:

- to read the 7th column (the value is 8); and to put 1 (because of cross effect) on column 8 in the 1st
  row in $\mathbf{Z}_S$.
- to read the 8th column (the value is 9); and to put 1 (because of cross effect) on column 9 in the 1st
  row in $\mathbf{Z}_S$.

The resulting row in $\mathbf{Z}_S$ is
$$
\left[
\begin{array}{ccccccccccccccc}
0& 0& 0& 0& 0& 0& 0& 1& 1& 0& 0& 0& 0& 0& 0
\end{array}
\right].
$$

The textbook omits the first 8 columns in $\mathbf{Z}_S$. So above row is identical to the textbook.
Next, we consider the 2nd line in the data file.

    8     1   4   1   2   9.80     7   9   1

The 2 statements perform:

- to read the 7th column (the value is 7); and to put 1 (because of cross effect) on column 7 in the 1st
  row in $\mathbf{Z}_S$.
- to read the 8th column (the value is 9); and to put 1 (because of cross effect) on column 9 in the 1st
  row in $\mathbf{Z}_S$.
The resulting row in $\mathbf{Z}_S$ is
$$
\left[
\begin{array}{ccccccccccccccc}
    0& 0& 0& 0& 0& 0& 1& 0& 1& 0& 0& 0& 0& 0& 0
\end{array}
\right].
$$
This is identical to the 2nd row in $\mathbf{Z}_{S}$ in the textbook.

The specification of `RANDOM_TYPE` is also tricky. In the first `RANDOM_GROUP`, we only specify the
effect 2 and 3. Effect 4 should be omitted because it is the same effect as effect 3. Also, BLUPF90 accepts only
consecutive effects in `RANDOM_GROUP` so we put 2 and 3 here.


Solutions
---------

The solutions are very similar to the values in the textbook (p.126).
