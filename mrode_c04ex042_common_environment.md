---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Common environmental effects as random
======================================

Model
-----

In this example, the author considers a simple maternal model and the maternal effects ($c$) do not correlate to
each other.
The variance components include the animal genetic variance $\sigma_u^2=20$, the maternal variance $\sigma_c^2=15$, and the residual variance $\sigma_e^2=65$.

Files
-----

The data file (`data_mr04b.txt`) contains the whole table shown in the textbook (p.68).
Here is the explanation for each column.

1. Animal ID (piglet)
2. Sire ID
3. Dam ID
4. Sex (1=male and 2=female)
5. Weaning weight (kg)

Pedigree (`pedigree_mr04b.txt`) can be derived from the above data.

The parameter file should contain 2 random effects.

~~~~~{language=blupf90 caption="param_mr04b.txt"}
DATAFILE
data_mr04b.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
3
OBSERVATION(S)
5
WEIGHT(S)

EFFECTS: POSITIONS_IN_DATAFILE NUMBER_OF_LEVELS TYPE_OF_EFFECT  [EFFECT NESTED]
4  2 cross
1 15 cross
3  5 cross    # for maternal environmental effect
RANDOM_RESIDUAL VALUES
65.0
RANDOM_GROUP
2
RANDOM_TYPE
add_animal
FILE
pedigree_mr04b.txt
(CO)VARIANCES
20.0
RANDOM_GROUP
3
RANDOM_TYPE
diagonal
FILE

(CO)VARIANCES
15.0
OPTION solv_method FSPAK
~~~~~

Solutions
---------

The results are identical to the textbook.
