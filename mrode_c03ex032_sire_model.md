---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Sire model
==========

Model
-----

Here we apply a sire model to the previous data.
The mathematical model is the same as the previous section but the individual genetic effect is replaced with the sire genetic effect.
In this model, we consider as if an observation belongs to the sire of the animal rather than to the animal itself. Additive
genetic variation is explained by sires. So, the sire variance is $\sigma_s^2 = 0.25\sigma_u^2 = 5$ and
the residual variance absorbs the remaining part of genetic variance and $\sigma_e^{2*}=0.75\sigma_u^2+\sigma_e^2=55$.
The phenotypic variance is the same (60) between the animal and sire models.

Files
-----

We can use the same data set shown in the previous section (`data_mr03b.txt`).
In this case, we use the 3rd column (sire ID) instead of the 1st column (animal ID) as an animal's
effect.

The pedigree file in sire model for BLUPF90 is different from the one used in the animal model.
This file (`pedigree_mr03b.txt`) contains 3 columns:

1. The ID for sire.
2. The ID for sire of the sire.
3. The ID for maternal grandsire (MGS) of the sire.

In this case, all MGS are unknown so the 3rd column should be 0 for all animals.

The parameter file is also altered. We put comments around lines to be changed.

~~~~~{language=blupf90 caption="param_mr03b.txt"}
DATAFILE
data_mr03b.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
2
OBSERVATION(S)
5
WEIGHT(S)

EFFECTS:
2 2 cross
3 4 cross               # 3rd column = sire effect; 4 sires
RANDOM_RESIDUAL VALUES  # residual variance
55.0
RANDOM_GROUP
2
RANDOM_TYPE             # type changed
add_sire
FILE
pedigree_mr03b.txt
(CO)VARIANCES           # sire variance
5.0
OPTION solv_method FSPAK
~~~~~

The value `add_sire` is a keyword for the sire model in BLUPF90. The pedigree file does not have sire 2
because it is missing, but the program doesn't care about it.

Solutions
---------

The solutions are following.

~~~~~{language=text caption="solutions"}
trait/effect level  solution
   1   1         1          4.33567107
   1   1         2          3.38198579
   1   2         1          0.02200220
   1   2         2          0.00000000
   1   2         3          0.01402640
   1   2         4         -0.04304180
~~~~~

The solution for sire ID 2 is 0.0. BLUPF90 always produces the solution 0.0 for such a missing level in
data and pedigree files. Otherwise, the solutions are identical to the textbook (pp.48).
