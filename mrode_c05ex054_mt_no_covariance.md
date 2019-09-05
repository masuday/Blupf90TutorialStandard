---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Multiple-trait model with no environmental covariance
=====================================================

Model
-----

Assuming a 2-trait model, there is a situation where some animals are recorded only in one trait
and the other animals are recorded only in another trait. In other words, no animals have
observations for both traits. This situation also happens when evaluating genotype by environment
(G by E) effects. Animals in the environment 1 don't have records in environment 2, and vice versa.
In this case, we should assume that the residual covariance is exactly zero.

The author assumes dual-purpose sires in cattle. The male and female calves are raised in
different feeding systems. Male calves are recorded for yearling weight and females for fat yield.
The genetic covariance is nonzero but the residual covariance is zero.
Note that the results from BLUPF90 must be different from the values in the textbook.


Files
-----

The data set (`data_mr05d.txt`) is shown in the textbook at p.85.
Animal 4 can be omitted in the data file because it has no observations.

1. Animal ID (Calf)
2. Sex (1=male and 2=female)
3. Sire ID
4. Dam ID
5. HYS
6. Yearling weight (kg)
7. Fat yield (kg)

The pedigree is from the above data set.

The parameter file should be the following.

~~~~~{language=blupf90 caption="param_mr05d.txt"}
DATAFILE
data_mr05d.txt
NUMBER_OF_TRAITS
2
NUMBER_OF_EFFECTS
2
OBSERVATION(S)
6 7
WEIGHT(S)

EFFECTS:
5 5 3 cross
1 1 17 cross
RANDOM_RESIDUAL VALUES
77.0  0.0
 0.0 70.0
RANDOM_GROUP
2
RANDOM_TYPE
add_animal
FILE
pedigree_mr05d.txt
(CO)VARIANCES
43.0 18.0
18.0 30.0
OPTION solv_method FSPAK
~~~~~

Solutions
---------

The solutions are different from the textbook.

~~~~~{language=text caption="solutions"}
trait/effect level  solution
   1   1         1        412.26462367
   2   1         1        194.02892921
   1   1         2        276.21351695
   2   1         2        204.76619557
   1   1         3          0.00000000
   2   1         3        161.66294167
   1   2         1         -3.36497774
   2   2         1          1.25823921
   1   2         2         -1.48909004
   2   2         2          3.77372023
   1   2         3          4.23664594
   2   2         3         -1.68697171
   1   2         4         -6.93946803
   2   2         4         -1.57147632
   1   2         5         -5.01220042
   2   2         5         -2.09813041
   1   2         6          5.01220042
   2   2         6          2.09813041
   1   2         7          2.13678047
   2   2         7          3.56130079
   1   2         8         -4.27356095
   2   2         8         -7.12260158
   1   2         9        -12.16152864
   2   2         9         -3.09074655
   1   2        10         -8.26284566
   2   2        10         -1.26033550
   1   2        11          5.83581177
   2   2        11          3.77631522
   1   2        12         12.63228129
   2   2        12          3.55770600
   1   2        13          1.52268184
   2   2        13          5.97107079
   1   2        14         -4.29201845
   2   2        14        -11.52738822
   1   2        15         -1.87022083
   2   2        15          0.01073376
   1   2        16          4.29035684
   2   2        16         11.99499708
   1   2        17          2.68411368
   2   2        17          1.66338290
~~~~~
