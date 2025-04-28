---
title: Data preparation with RENUMF90
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Animal model with pedigree file
===============================

Random effect specification
---------------------------

We consider a mixed model with 1 or more random effects. Note that, even adding random effects, the renumbered data file will be the same as those used one for the fixed effect model. Only differences when considering random effects in RENUMF90 are: 1) output parameter file contains statements for random effects and 2) pedigree or related files will be properly processed if needed.

First, we reconsider the previous example and assume the second effect ($S_j$) is random.
$$
y_{ijk} = A_{i} + S_{j} + \beta x_{ijk} + e_{ijk}
$$
The raw data file is the same as those used before but we change the name of the file.

~~~~~{language=text caption="rawdata2.txt"}
 ID006  A  1  1.0  3.0
 ID009  A  2  1.0  2.0
 ID012  A  1  2.0  4.0
 ID007  B  2  2.0  6.0
 ID010  B  1  1.0  3.0
 ID013  B  2  2.0  6.0
 ID008  C  1  2.0  6.0
 ID011  C  2  1.0  6.0
 ID014  C  1  1.0  8.0
 ID015  C  2  2.0  4.0
~~~~~

Assuming the residual variance $\sigma_{e}^{2} = 2.0$ and the random effect's variance $\sigma_{s}^{2} = 1.0$, the parameter file looks like:

~~~~~{language=renumf90 caption="renum2.txt"}
DATAFILE
rawdata2.txt
TRAITS
5
FIELDS_PASSED TO OUTPUT

WEIGHT(S)

RESIDUAL_VARIANCE
2.0
EFFECT           # 1st effect
2 cross alpha
EFFECT           # 2nd effect
3 cross alpha
RANDOM           ## treated as a random effect
diagonal
(CO)VARIANCES    ## its variance components
1.0
EFFECT           # 3rd effect
4 cov
~~~~~

This parameter file is also the same as those used before except we inserted 2 extra keywords and the corresponding values: the keyword `RANDOM` with the value `diagonal` and the keyword `(CO)VARIANCES` with the value 1.0 just after the definition of effect 2. Basically, RENUMF90 treats the effect as random if `RANDOM` places after the effect specification; otherwise, the effect is fixed. [^1]

[^1]: A tricky feature is to omit `(CO)VARIANCES`. If you do not put this keyword, RENUMF90 implicitly assumes the variance component is 1.0 by default. We highly recommend to use `(CO)VARIANCES` option to avoid the confusion.

This produces the data and parameter files equivalent to ones used in the previous chapter. You can confirm the generated files provides the same solutions as before.


Animal model
------------

### Raw data ###

RENUMF90 can handle an animal model with the same framework using `RANDOM` and other optional keywords to read a raw pedigree file. We can use the same data file as before. We duplicate the data file to another one with a different name.

~~~~~{language=text caption="rawdata3.txt"}
 ID006  A  1  1.0  3.0
 ID009  A  2  1.0  2.0
 ID012  A  1  2.0  4.0
 ID007  B  2  2.0  6.0
 ID010  B  1  1.0  3.0
 ID013  B  2  2.0  6.0
 ID008  C  1  2.0  6.0
 ID011  C  2  1.0  6.0
 ID014  C  1  1.0  8.0
 ID015  C  2  2.0  4.0
~~~~~

### Raw pedigree ###

The following is the raw pedigree which is corresponding to the pedigree shown in the previous chapter.

~~~~~{language=text caption="rawpedigree3.txt"}
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

The animal ID shares in both raw data and raw pedigree files. A raw pedigree with the following format is allowed for RENUMF90.

- It contains at least 3 columns, animal ID, sire ID, and dam ID, separated with 1 or more spaces. A tab is not allowed.
- Each ID can place any position. For example, animal ID can be in column 4.
- An unknown or missing parent must be `0`. Other expressions (like `00` or `00000` or `NA`) are not allowed as missing, and they will be recognized as real animals.
- You can also put the date of birth (year of birth) as an additional column. The information should be an integer value.
- Animals do not have to be ordered either chronologically nor alphabetically. Any random order is allowed.
- Although an animal appears in the sire or dam column, it is not necessarily in the animal column. Such an animal is assumed to have unknown parents (both sire and dam unknown).


### Parameter file ###

We assume a mixed model:
$$
y_{ijk} = A_{i} + S_{j} + \beta x_{ijk} + u_{k} + e_{ijk}
$$
where $A_{i}$ and $S_{j}$ are fixed effects, $\beta$ is a fixed regression, $u_{k}$ is the additive genetic effect and $e_{ijk}$ is the random residual. The variances are assumed as $\sigma_{e}^2 = 2.0$ and $\sigma_u^2 = 0.5$. We add the statement `EFFECT` to the previous instruction as the additive genetic effect with the `RANDOM` keyword.

~~~~~{language=renumf90 caption="renum3.txt"}
DATAFILE
rawdata3.txt
TRAITS
5
FIELDS_PASSED TO OUTPUT

WEIGHT(S)

RESIDUAL_VARIANCE
2.0
EFFECT           # 1st effect fixed
2 cross alpha
EFFECT           # 2nd effect fixed
3 cross alpha
EFFECT           # 3rd effect fixed
4 cov
EFFECT           # 4th effect
1 cross alpha
RANDOM           ## treated as a random effect
animal
FILE             ## pedigree file
rawpedigree3.txt
FILE_POS         ## animal, sire and dam IDs, and two 0s
1 2 3 0 0
(CO)VARIANCES    ## its variance component
0.5
~~~~~

We can see two new keywords here.

- `FILE`: the name of the raw pedigree file.
    - `rawpedigree3.txt`
- `FILE_POS`: the position of IDs in the raw pedigree file; 5 items needed.
    - 1st item = the position of animal ID (1 for the 1st column)
    - 2nd item = the position of sire ID (2 for the 2nd column)
    - 3rd item = the position of dam ID (3 for the 3rd column)
    - 4th item = usually 0 (will be explained in the later section)
    - 5th item = usually 0 (will be explained in the later section)

Be careful of the order of keywords for random effects. RENUMF90 only accept the keywords properly ordered in instruction. In this example, the order should be:

1. `RANDOM`
2. `FILE`
3. `FILE_POS`
4. `(CO)VARIANCES`

We have many more keywords related to random effects. The keywords should be ordered to be read by RENUMF90. We will review the proper ordering later.


### Output files ###

After running RENUMF90, you can see some files in the same directory: `renf90.dat`, `renf90.par`, `renf90.tables`, and `renadd04.ped`. The last one is renumbered pedigree. Why 4? This 4 comes from the position of the effect in instruction; the additive genetic effect was defined as the 4th `EFFECT` statement. If your additive genetic effect is declared as the 6th effect, the name of the pedigree file will be `renadd06.ped`.

The renumbered pedigree file (`renadd04.ped`) contains 10 columns.

~~~~~{language=text}
1 7 5 1 0 2 1 0 0 ID015
13 0 0 3 0 0 0 0 2 ID004
11 0 0 3 0 0 0 0 1 ID005
2 0 0 3 0 0 1 0 1 ID006
3 12 11 1 0 2 1 2 0 ID007
4 14 13 1 0 2 1 0 1 ID008
5 3 2 1 0 2 1 0 2 ID010
6 12 15 1 0 2 1 1 0 ID009
7 3 13 1 0 2 1 3 0 ID011
8 7 4 1 0 2 1 0 0 ID012
14 0 0 3 0 0 0 1 0 ID001
9 7 5 1 0 2 1 0 1 ID013
12 0 0 3 0 0 0 2 0 ID002
10 6 9 1 0 2 1 0 0 ID014
15 0 0 3 0 0 0 0 1 ID003
~~~~~

Column 1 is for renumbered animal ID, column 2 for sire ID and column 3 for dam ID. The remaining columns contain additional information. The last (10th) column is the original ID. Many of them are actually ignored in BLUPF90. [^2] The official manual explains the meaning of each column.

 1. animal number (from 1)
 2. parent 1 number or unknown parent group number for parent 1
 3. parent 2 number or unknown parent group number for parent 2
 4. 3 minus number of known parents
 5. known or estimated year of birth (0 if not provided)
 6. number of known parents (parents might be eliminated if not contributing; if animal has genotype 10+number of know parents
 7. number of records
 8. number of progeny (before elimination due to other effects) as parent 1
 9. number of progeny (before elimination due to other effects) as parent 2
10. original animal id

The conversion table for animal ID is not saved in `renf90.tables`. The correspondence can be found only in the renumbered pedigree file (column 1 and 10).

[^2]: The 4th column will be used if you put certain options in the parameter file. We do not explain such options here.


### Test run with the renumbered data ###

You can run BLUPF90 with the generated parameter file and obtain the solutions of the equation. The analysis mimics the previous one in the previous chapter so the results should be identical (without numerical error). You will find the BLUE is the same and the estimated breeding values (BLUP) are also the same but the order of animals are different. The following is a combination of previous ones (left) and the current ones (right).

~~~~~{language=text}
1   1         1          0.20259644    1   1         1          0.20259637
1   1         2          2.21996461    1   1         2          2.21996452
1   1         3          3.16680208    1   1         3          3.16680200
1   2         1          2.27537292    1   2         1          2.27537284
1   2         2          1.71160537    1   2         2          1.71160529
1   3         1          0.52442755    1   3         1          0.52442750
1   4         1         -0.03487115    1   4         1         -0.25707432
1   4         2          0.08280493    1   4         2         -0.17565610
1   4         3          0.03843921    1   4         3          0.10794666
1   4         4          0.04492008    1   4         4         -0.02984647
1   4         5          0.04436203    1   4         5         -0.25282594
1   4         6         -0.17565609    1   4         6          0.09906235
1   4         7          0.10794667    1   4         7          0.15622415
1   4         8         -0.02984646    1   4         8          0.10874295
1   4         9          0.09906236    1   4         9          0.16426464
1   4        10         -0.25282594    1   4        10          0.34296713
1   4        11          0.15622415    1   4        11          0.04436204
1   4        12          0.10874296    1   4        12          0.08280494
1   4        13          0.16426465    1   4        13          0.04492008
1   4        14          0.34296714    1   4        14         -0.03487115
1   4        15         -0.25707431    1   4        15          0.03843922
~~~~~

This is because of the different order of animals in the pedigree file between 2 datasets. RENUMF90 orders pedigree animals as follows.

   1. First, the program assigns smaller numbers to animals with the record(s). The order of animals are unpredictable (that is not following the order found in the data file).
   2. Then, the program assigns larger numbers to animals found only in pedigree.


Note that RENUMF90 doesn't order the pedigree animals chronologically (that is, from oldest to youngest). No options are available to order the animals chronologically. The above rules are from the simplification of implementation, but it is useful for fitting the permanent environmental effect in the repeatability model.

Usually, you will combine the solutions (estimated breeding values) with the original animal ID. This can be done with several ways for example, Linux (Unix) tools, database management systems, statistical languages like R, even Microsoft Excel.


More than 1 random effect
-------------------------

As the last demonstration of RENUMF90 in this section, let us assume that the effect $S_j$ is also random as well as $u_k$ in the above model. The variance components are $\sigma_e^2 = 2.0$, $\sigma_s^2 = 1.0$, and $\sigma_u^2 = 0.5$. A suggested instruction file is as follows.

~~~~~{language=renumf90 caption="renum3a.txt"}
DATAFILE
rawdata3.txt
TRAITS
5
FIELDS_PASSED TO OUTPUT

WEIGHT(S)

RESIDUAL_VARIANCE
2.0
EFFECT             # 1st effect fixed
2 cross alpha
EFFECT             # 2nd effect fixed
3 cross alpha
RANDOM             ## treated as a random effect
diagnonal
(CO)VARIANCES      ## its variance component
1.0
EFFECT             # 3rd effect fixed
4 cov
EFFECT             # 4th effect
1 cross alpha
RANDOM             ## treated as a random effect
animal
FILE               ## pedigree file
rawpedigree3.txt
FILE_POS           ## animal, sire and dam IDs with two 0s
1 2 3 0 0
(CO)VARIANCES      ## its variance component
0.5
~~~~~

This is a combination of the first and second examples in this section. You can easily figure it out how each statement works.


Summary
-------

- RENUMF90 treats the effect with the `RANDOM` keyword as a random effect.
- The `RANDOM` keyword may require other keywords.
- If a random effect doesn't need the pedigree, just put `RANDOM` and `(CO)VARIANCES` only.
- If a random effect needs the pedigree, put `RANDOM`, `FILE`, `FILE_POS`, and `(CO)VARIANCES` in this order.
- A raw pedigree-file should contain at least 3 columns: animal ID, sire ID, and dam ID. The order of columns is arbitrary.
- The renumbered pedigree-file has a name as `renaddnn.ped` where `nn` is the position of this effect in instruction.
- The renumbered pedigree file has 10 columns including the original ID. The renumbered ID will not be in `renf90.tables`.
- The animals with records have smaller numbers than animals found only in pedigree.
- RENUMF90 supports more than 1 random effects.
