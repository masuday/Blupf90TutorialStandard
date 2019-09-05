---
title: Large-scale genetic evaluation
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Approximation of accuracy and reliability
=========================================

Algorithm
---------

Accuracy or reliability of EBV of an animal can be calculated from the prediction error variance (PEV) obtained from
the diagonal elements of the inverse of left-hand side (LHS) of the mixed model equations. The
diagonals can be calculated with the sparse inversion with FSPAK or YAMS for smaller
data set. As expected, the computation cost for the inverse is really high and the left-hand side has
to be in memory. So this direct method cannot be applied to a large scale genetic evaluation.

There are two major classes to approximate accuracy and reliability. One is to approximate
diagonal elements in LHS after absorbing the non-genetic effects. This element looks like the
effective number of records for an animal. The other approach focuses on the effective number of
progeny (daughters) originally derived from the selection index theory based on a progeny test. This approach
is especially useful for parents.

ACCF90 implements the first approach. The method was described by Strabel et al. (2001) and
Sanchez et al. (2008) who extended the idea by Miszal and Wiggans (1988) to more complicated models. The algorithm
is iterative because too many unknown variables are involved in the final equations to provide the
approximated diagonal elements. 

ACCF90GS supports ssGBLUP. The algorithm was described by Miszal et al. (2013) using
$\mathbf{G}^{-1}$ and $\mathbf{A}_{22}^{-1}$. This program works well for smaller data set.
For larger problems, now we are developing the method without explicit computation of $\mathbf{G}^{-1}$ and $\mathbf{A}_{22}^{-1}$.


Files
-----

We will use the following files for a 4-trait repeatability model.

- [`simdata_rep.txt`](https://github.com/Masuday/data/blob/master/tutorial/simdata_rep.txt) : data file
- [`simped.txt`](https://github.com/Masuday/data/blob/master/tutorial/simped.txt) : pedigree file

The parameter file includes several options for ACCF90.

~~~~~{language=blupf90 caption="accparam1.txt"}
DATAFILE
simdata_rep.txt
NUMBER_OF_TRAITS
4
NUMBER_OF_EFFECTS
5
OBSERVATION(S)
9 10 11 12
WEIGHT(S)

EFFECTS: POSITIONS_IN_DATAFILE NUMBER_OF_LEVELS TYPE_OF_EFFECT [ EFFECT NESTED ]
6 6 6 6   155 cross
7 7 7 7     2 cross
8 8 8 8    11 cross
1 1 1 1  4641 cross
1 1 1 1  4641 cross
RANDOM_RESIDUAL VALUES
 45.124  22.357  18.626  13.762
 22.357  44.210  22.690  18.016
 18.626  22.690  46.101  22.795
 13.762  18.016  22.795  45.274
RANDOM_GROUP
4
RANDOM_TYPE
add_animal
FILE
simped.txt
(CO)VARIANCES
 41.967  22.512  24.058  26.907
 22.512  17.489  19.738  24.257
 24.058  19.738  28.775  34.741
 26.907  24.257  34.741  56.668
RANDOM_GROUP
5
RANDOM_TYPE
diagonal
FILE

(CO)VARIANCES
 15.546  15.237  10.490  1.4105
 15.237  40.937  19.562  6.4840
 10.490  19.562  27.782  4.5379
 1.4105  6.4840  4.5379  2.4410
OPTION cg   1 1 1 1
OPTION anim 4 4 4 4
OPTION pe   5 5 5 5
OPTION acc_maxrounds 20
~~~~~

The options will be explained later. ACCF90 reads the solutions file. Run BLUPF90 (or
BLUPF90IOD2) with the above parameter file, and then, run ACCF90 with the same parameter file. The program creates the file `sol_and_acc`
as follows (the first 9 lines are shown).

~~~~~{language=text caption="solutions"}
trait/effect level  solution acc
   1   4         1         -3.43278933  0.8728
   2   4         1          1.63205564  0.8147
   3   4         1          1.86332893  0.8510
   4   4         1          5.42050028  0.9237
   1   4         2          1.35147071  0.8754
   2   4         2          1.75742269  0.8140
   3   4         2          6.60794020  0.8512
   4   4         2          5.09637833  0.9268
   1   4         3         -9.07606792  0.8820
~~~~~

This file is similar to `solutions` but the only estimated breeding values (EBV) are stored. The
last column is the reliability of EBV.


Options
-------

~~~~~{language=blupf90}
OPTION cg   [ position(s)]  # contemporary group effect
OPTION anim [ position(s)]  # additive genetic effect
OPTION pe   [ position(s)]  # PE effect
OPTION mat  [ position(s)]  # maternal genetic effect
OPTION hs   [ position(s)]  # herd by sire interaction effect
~~~~~

Each option defines the position(s) for the specific effect in the `EFFECT:` block. The positions
should be enumerated for all traits. If the effect is missing in a trait, put `0`. The first 2 options `cg`
and `anim` are mandatory and the others are optional. With the above example, the contemporary group
effect is the 1st effect in the `EFFECT:` block. Because the contemporary group effect is considered
in all 4 traits, we put four 1s as `cg 1 1 1 1`. Similarly, the additive genetic effect is defined as the
4th effect for all the traits so we put `animal 4 4 4 4`; the permanent environmental effect is the
5th effect for all the traits so we put `pe 5 5 5 5`.

~~~~~{language=blupf90}
OPTION acc_maxrounds n      # n = integer number
OPTION conv_crit x          # x = real small number
~~~~~

The first option defines the maximum number of iterations (the default is 10) and the second defines
the convergence criterion (the default is `1.0e-8`). The iterations stop when the program reaches
either criterion.

The program needs only a few iterations. Too many iterations would add bias
to the approximated reliability. The recommendation is to use the default convergence criterion.
The default number of iterations wouldn't be enough, and you should put a larger number to `acc_maxrounds`.

~~~~~{language=blupf90}
OPTION type x   # x = 1.0 or 0.5
~~~~~

This option defines the type of reliability. The final reliability will be calculated as $(R^2)^x$. The
default $x$ is 1.0 and it corresponds to $R^2$ (i.e. reliability). If you put $0.5$ to $x$, the output is $(R^2)^{0.5} = R$
i.e. accuracy. Traditionally, the beef industry has used the accuracy ($x$ is 0.5) and the dairy has used
the reliability ($x$ is 1.0). The default value is 1.0.

~~~~~{language=blupf90}
OPTION parent_avg
~~~~~

With this option, the program calculates the parent average for each animal. The values are saved
in the additional column in `sol_and_acc`.

~~~~~{language=blupf90}
OPTION original_id
~~~~~

This option puts the original ID (the 10th column in the renumbered pedigree file) to `sol_and_acc`.
