---
title: Data preparation with RENUMF90
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Advanced usage of RENUMF90
==========================

In this section, we will introduce some advanced features in RENUMF90. We commonly use the following raw data and pedigree file. The files come from the multiple-trait model shown in the previous chapter.

~~~~~{language=text caption="rawdata9.txt"}
  ID006  A  1  1.0  3.0  4.5
  ID009  A  2  1.0  2.0  7.5
  ID012  A  1  2.0  4.0  3.5
  ID007  B  2  2.0  6.0 -0.5
  ID010  B  1  1.0  3.0  5.5
  ID013  B  2  2.0  6.0  1.5
  ID008  C  1  2.0  6.0 -1.5
  ID011  C  2  1.0  6.0  2.5
  ID014  C  1  1.0  8.0  0.5
  ID015  C  2  2.0  4.0  4.5
~~~~~

The pedigree file is as follows.

~~~~~{language=text caption="rawpedigree9.txt"}
 ID001      0      0
 ID002      0      0
 ID003      0      0
 ID004      0      0
 ID005      0      0
 ID006      0      0
 ID007  ID002  ID005
 ID008  ID001  ID004
 ID009  ID002  ID003
 ID010  ID007  ID006
 ID011  ID007  ID004
 ID012  ID011  ID008
 ID013  ID011  ID010
 ID014  ID009  ID013
 ID015  ID011  ID010
~~~~~

Combined effects
----------------

RENUMF90 can treat a field as a combination of the existing fields. This is useful when an interaction effect is incorporated. The keyword `COMBINE` performs this feature. The following example is from the previous section and the keyword is added.

~~~~~{language=renumf90 caption="renum9a.txt"}
COMBINE
6 2 3
DATAFILE
rawdata9.txt
TRAITS
5
FIELDS_PASSED TO OUTPUT

WEIGHT(S)

RESIDUAL_VARIANCE
1.0
EFFECT          # 1st effect
2 cross alpha
EFFECT          # 2nd effect
3 cross alpha
EFFECT          # 3rd effect
4 cov
EFFECT          # interaction effect 1 x 2
6 cross alpha
~~~~~

The `COMBINE` statement should be used as follows.

- `COMBINE` must appear at the beginning of the instruction file (before `DATAFILE`).
- At least 2 values are needed; The 2nd or later values will be combined into 1 field. The field can be referred to as the first value.
- In this case, `6 2 3` means that columns 2 and 3 are combined into column 6 (that is, creating a new column, 6, as a combination of 2 and 3).
- You can use any number in the first value even if your data file doesn't have such a column.
- You can repeat the `COMBINE` statement.
- The combined field can be used in the `EFFECT` statement.

You can run RENUMF90 and check `renf90.tables`. Column 2 and 3 are successfully combined into one effect (group 4).

~~~~~{language=text}
 Effect group 1 of column 1 with 3 levels , effect # 1
 Value    #    consecutive number
A 3 1
B 3 2
C 4 3
 Effect group 2 of column 1 with 2 levels , effect # 2
 Value    #    consecutive number
1 5 1
2 5 2
 Effect group 4 of column 1 with 6 levels , effect # 4
 Value    #    consecutive number
A1 2 1
A2 1 2
B1 1 3
B2 2 4
C1 2 5
C2 2 6
~~~~~

Pedigree manipulation
---------------------

RENUMF90 prunes the pedigree. By default, the program traces back 3-generation (up to great-grandsires and dams) from the animals with phenotype or genotype. The number of generations back can be changed with the option `PED_DEPTH`, which should place just after `SNP_FILE` (or `FILE_POS` if no genetic markers are used). The following statements define 10 generations to be traced.

~~~~~{language=renumf90}
PED_DEPTH
10
~~~~~

If you put a large number (like 100), you can consider all ancestors to be traced back from the current animals. If you put 0, RENUMF90 tries to include all animals found in the raw pedigree file even if the pedigree animals are not related to the animals with phenotype or genotype.


Animal model options
--------------------

RENUMF90 supports the permanent environmental (PE) effect and the maternal genetic (MG) and the maternal environmental (MPE) effects as additional random effects in the animal model using the `OPTIONAL` keyword. The following is a parameter file with maximal options (PE, MG, and MPE).

~~~~~{language=renumf90 caption="renum9b.txt"}
DATAFILE
rawdata9.txt
TRAITS
5
FIELDS_PASSED TO OUTPUT

WEIGHT(S)

RESIDUAL_VARIANCE
1.0
EFFECT          # 1st effect
2 cross alpha
EFFECT          # 2nd effect
3 cross alpha
EFFECT          # 3rd effect
4 cov
EFFECT          # 4th effect = animal
1 cross alpha
RANDOM
animal
OPTIONAL
pe mat mpe
FILE
rawpedigree9.txt
(CO)VARIANCES
1.0 0.2
0.2 0.3
(CO)VARIANCES_PE
1.5
(CO)VARIANCES_MPE
0.5
~~~~~

You can read this file as follows.

- The `OPTIONAL` keyword places just after the `EFFECT` defining additive genetic effect.
- Possible values are `pe` for the animal's permanent environmental effect, `mat` for the maternal genetic effect, and `mpe` for the maternal environmental effect. They are optional; you can use only the options you want.
- If you put `mat`, you should put a genetic covariance matrix including direct and maternal genetic effects at `(CO)VARIANCES`. For a single-trait model, the rank of the covariance matrix should be 2; for a $t$ trait model, the rank should be $2t$. See *RENUMF90 Cheat Sheet* for details. Without `mat`, you just put a direct genetic variance (for a single-trait model) or a covariance matrix (for a multiple-trait model).
- If you put `pe`, you should put a permanent-environmental variance (for a single-trait model) or a covariance matrix (for a multiple-trait model) at `(CO)VARIANCES_PE`. Otherwise, you can omit `(CO)VARIANCES_PE`.
- If you put `mpe`, you should put a maternal permanent-environmental variance (for a single-trait model) or a covariance matrix (for a multiple-trait model) at `(CO)VARIANCES_MPE`. Otherwise, you can omit `(CO)VARIANCES_MPE`.


Definition of unknown parent groups (UPGs)
------------------------------------------

RENUMF90 can assign UPGs to unknown parents. There are 2 ways to do this but here we just introduce the one approach (because of its simplicity). The following keyword generates UPGs.

~~~~~{language=renumf90}
UPG_TYPE
in_pedigrees
~~~~~

The option should be just after `PED_DEPTH`. With this option, RENUMF90 interprets a negative sire (or dam) ID as a UPG.
So you should prepare different columns for sires and dams which contain negative integers for unknown animals instead of 0. Also, all the real animals should be in the pedigree file with the standard ID (other than negative integers).

The following is a simple example of UPGs. The 4th column is for sires with groups (1 and 2) and the 5th column is for dams with groups (3 and 4). You can specify column 4 (instead of 2) as the sire and column 5 (instead of 3) as the dam with the `FILE_POS` keyword.

~~~~~{language=text caption="rawpedigree9c.txt"}
 ID001      0      0     -1     -4
 ID002      0      0     -2     -3
 ID003      0      0     -1     -3
 ID004      0      0     -2     -3
 ID005      0      0     -2     -4
 ID006      0      0     -1     -3
 ID007  ID002  ID005  ID002  ID005
 ID008  ID001  ID004  ID001  ID004
 ID009  ID002  ID003  ID002  ID003
 ID010  ID007  ID006  ID007  ID006
 ID011  ID007  ID004  ID007  ID004
 ID012  ID011  ID008  ID011  ID008
 ID013  ID011  ID010  ID011  ID010
 ID014  ID009  ID013  ID009  ID013
 ID015  ID011  ID010  ID011  ID010
~~~~~

The instruction file can be as follows.

~~~~~{language=renumf90 caption="renum9c.txt"}
DATAFILE
rawdata9.txt
TRAITS
5
FIELDS_PASSED TO OUTPUT

WEIGHT(S)

RESIDUAL_VARIANCE
1.0
EFFECT          # 1st effect
2 cross alpha
EFFECT          # 2nd effect
3 cross alpha
EFFECT          # 3rd effect
4 cov
EFFECT          # 4th effect = animal
1 cross alpha
RANDOM
animal
FILE
rawpedigree9c.txt
FILE_POS        #  positions of animal, sire, dam, 0, 0
1 4 5 0 0
UPG_TYPE
in_pedigrees
(CO)VARIANCES
1.0
~~~~~

The resulting pedigree file is as follows. You have only 15 real animals but there are the codes greater than 15 (between 16 and 19) in the sire and dam columns. These numbers greater than the number of real animals represent UPGs.

~~~~~{language=text}
1 7 5 1 0 2 1 0 0 ID015
13 17 18 3 0 0 0 0 2 ID004
11 17 19 3 0 0 0 0 1 ID005
2 16 18 3 0 0 1 0 1 ID006
3 12 11 1 0 2 1 2 0 ID007
4 14 13 1 0 2 1 0 1 ID008
5 3 2 1 0 2 1 0 2 ID010
6 12 15 1 0 2 1 1 0 ID009
7 3 13 1 0 2 1 3 0 ID011
8 7 4 1 0 2 1 0 0 ID012
14 16 19 3 0 0 0 1 0 ID001
9 7 5 1 0 2 1 0 1 ID013
12 17 18 3 0 0 0 2 0 ID002
10 6 9 1 0 2 1 0 0 ID014
15 16 18 3 0 0 0 0 1 ID003
~~~~~

Considering inbreeding coefficients in $\mathbf{A}^{-1}$
------------------------------------------------------

By default, RENUMF90 creates a pedigree file which will result in $\mathbf{A}^{-1}$ without inbreeding. To put inbreeding coefficients in $\mathbf{A}^{-1}$, you have to generate a special, renumbered pedigree-file by RENUMF90 using the `INBREEDING` keyword.[^1] This keyword should be placed after `UPG_TYPE`.

[^1]: Technically, the alternative, renumbered pedigree-file has the same as those used the standard one except for the 4th column. In the alternative pedigree, the 4th column has a special 4-digit integer (inb/upg code) which combines the inbreeding coefficients and the number of missing parents. Although the user can manually calculate the code, this process may be complicated, and I recommend the user to use RENUMF90 to generate the pedigree file with such a code.

The basic usage of this option is shown below.

~~~~~{language=renumf90}
INBREEDING
pedigree
~~~~~

You should put the literal word `pedigree` here (you shouldn't replace it with the pedigree file name). With this option, RENUMF90 calculates inbreeding coefficients with Meuwissen and Luo (1992) based on the pedigree to be saved in the file `renaddxx.ped` which has been possibly pruned by some generations (see `PED_DEPTH` for details).

If you want to supply pre-calculated inbreeding coefficients stored in a file, use the different option. Assuming your file is `inb.txt`, the following option can be used.

~~~~~{language=renumf90}
INBREEDING
file inb.txt
~~~~~

The file is a space-separated text file with 2 columns: 1) the original animal ID and 2) inbreeding coefficient (ranging from 0 to 1).

The following example uses the pedigree option.

~~~~~{language=renumf90 caption="renum9d.txt"}
DATAFILE
rawdata9.txt
TRAITS
5
FIELDS_PASSED TO OUTPUT

WEIGHT(S)

RESIDUAL_VARIANCE
1.0
EFFECT          # 1st effect
2 cross alpha
EFFECT          # 2nd effect
3 cross alpha
EFFECT          # 3rd effect
4 cov
EFFECT          # 4th effect = animal
1 cross alpha
RANDOM
animal
FILE
rawpedigree9.txt
INBREEDING
pedigree
(CO)VARIANCES
1.0
~~~~~

The resulting pedigree file `renadd04.ped` has the inb/upg code in the 4th column.

~~~~~{language=text caption="renadd04.ped"}
1 7 5 2000 0 2 1 0 0 ID015
13 0 0 1000 0 0 0 0 2 ID004
11 0 0 1000 0 0 0 0 1 ID005
2 0 0 1000 0 0 1 0 1 ID006
3 12 11 2000 0 2 1 2 0 ID007
4 14 13 2000 0 2 1 0 1 ID008
5 3 2 2000 0 2 1 0 2 ID010
6 12 15 2000 0 2 1 1 0 ID009
7 3 13 2000 0 2 1 3 0 ID011
8 7 4 2000 0 2 1 0 0 ID012
14 0 0 1000 0 0 0 1 0 ID001
9 7 5 2000 0 2 1 0 1 ID013
12 0 0 1000 0 0 0 2 0 ID002
10 6 9 2133 0 2 1 0 0 ID014
15 0 0 1000 0 0 0 0 1 ID003
~~~~~

Looking at the 4th column, when an animal has non-inbred parents, the value should be 1000 with unknown parents, 1333 with one parent unknown, or 2000 with known parents. Animal 10 (ID014) has inbred parents so the inb/upg code is different from the other animals.


Order of keywords
-----------------

The keywords used in the instruction file should be ordered following the manual. We show the exact order of keywords supported by RENUMF90.

Keyword               optional    possible values
-------------------   ---------   --------------------------------------------------------------------
`COMBINE`             optional    definition of new field as a combination of existing fields
`DATAFILE`            mandatory   name of raw data file
`TRAITS`              mandatory   positions of observations in the raw data file
`FIELDS_PASSED`       mandatory   positions of items in the raw data file to be passed to `renf90.dat`
`WEIGHT(S)`           mandatory   positions of weights in the raw data file
`RESIDUAL_VARIANCE`   mandatory   residual covariance matrix
`EFFECT`              mandatory   effect description
`NESTED`              optional    positions of nested covariates
`RANDOM`              optional    declaration of random effect
`FILE`                optional    name of raw pedigree file
`FILE_POS`            optional    positions of animal ID, sire ID and dam ID
`SNP_FILE`            optional    name of SNP marker file
`PED_DEPTH`           optional    the maximum generation back from animals with phenotype or genotype
`GEN_INT`             optional    generation interval to set unknown parent groups (UPG)
`REC_SEX`             optional    check if records are found in specific sex
`UPG_TYPE`            optional    UPG specification
`INBREEDING`          optional    create pedigree file with inbreeding
`RANDOM_REGRESSION`   optional    put covariates for random regressions
`RR_POSITION`         optional    positions of covariates for random regressions
`(CO)VARIANCES`       optional    covariance components
`(CO)VARIANCES_PE`    optional    covariance components for animal's PE effects
`(CO)VARIANCES_MPE`   optional    covariance components for maternal PE effects
`OPTION`              optional    option parameters
