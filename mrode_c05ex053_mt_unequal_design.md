---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Multiple-trait model with unequal design matrix
===============================================

Model
-----

When each trait has a different model, the design matrices are unequal. Even in this case, the
matrix notation of the model and the mixed model equations are the same described as before.

BLUPF90 can handle a multiple-trait model with unequal design matrices in 2 ways. Both
approaches provide the same results so the difference is only from a user's preference [^1].

[^1]: Gibbs sampling programs accept only 1 way out of 2 ways.

Files
-----

The data are shown in the textbook at p.81, as a file `data_mr05c.txt`.
This contains 2 different class effects and each trait takes an alternative one.

1. Animal ID (Cow)
2. Sire ID
3. Dam ID
4. HYS 1 (for Fat yield 1)
5. HYS 2 (for Fat yield 2)
6. Fat yield 1
7. Fat yield 2

The pedigree (`pedigree_mr05c.txt`) is from the previous example.

First, we show a parameter file to handle the unequal design matrices in one way.

~~~~~{language=blupf90 caption="param_mr05c.txt"}
DATAFILE
data_mr05c.txt
NUMBER_OF_TRAITS
2
NUMBER_OF_EFFECTS
2
OBSERVATION(S)
6 7
WEIGHT(S)

EFFECTS:
4 5 2 cross
1 1 8 cross
RANDOM_RESIDUAL VALUES
65.0 27.0
27.0 70.0
RANDOM_GROUP
2
RANDOM_TYPE
add_animal
FILE
pedigree_mr05c.txt
(CO)VARIANCES
35.0 28.0
28.0 30.0
OPTION solv_method FSPAK
~~~~~

Look at the first line in `EFFECT:` which refers to 2 different columns; column 4
for trait 1 and column 5 for trait 2. So you can put different effects together into the single statement.
You should put the maximum number of levels among effects enumerated in this statement. For
example, in this case, the maximum level in column 4 is 2 and the maximum number of level in
column 5 is also 2 --- so you can put 2 as the representative number of levels.


Solutions
---------

This is identical to the textbook shown in p.82.


Another parameter file
----------------------

BLUPF90 supports a different way to handle unequal design matrices. Consult the following
parameter file with the same data and pedigree files.

~~~~~{language=blupf90 caption="param_mr05c1.txt"}
DATAFILE
data_mr05c.txt
NUMBER_OF_TRAITS
2
NUMBER_OF_EFFECTS
3
OBSERVATION(S)
6 7
WEIGHT(S)

EFFECTS:
4 0 2 cross
0 5 2 cross
1 1 8 cross
RANDOM_RESIDUAL VALUES
65.0 27.0
27.0 70.0
RANDOM_GROUP
3
RANDOM_TYPE
add_animal
FILE
pedigree_mr05c.txt
(CO)VARIANCES
35.0 28.0
28.0 30.0
OPTION solv_method FSPAK
~~~~~

In this parameter file, the fixed effect for each trait is separately defined. The column number will
be 0 for a trait which doesn't need the effect. In this case, the first line describes the effect $HYS_1$
and only the first trait needs this effect (so you should put 0 to the second trait). Note that the Gibbs
sampling programs (including GIBBS2F90 and THRGIBBS1F90) accept only this style.

You can immediately find the results are identical to the previous ones.
Some effects ($HYS_1$ for trait 2 and $HYS_2$ for trait 1) are not estimated because they are not defined
in the parameter file.
