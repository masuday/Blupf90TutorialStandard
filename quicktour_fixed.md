---
title: Quick tour of BLUPF90
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Trivial analyses for fixed models
=================================

This section describes the basic design and essential elements of BLUPF90 programs.
We will explain how to prepare a data file and how to describe a parameter file using simple fixed effect models.
Most of the basic ideas will be introduced here and you can expand to more complicated models.

We use the BLUPF90 program here.
BLUPF90 quickly solves mixed model equations and save the solutions to a file.
This program also solves the least square equations (i.e., normal equations) for fixed effect models.
Other programs for variance component estimation (e.g., AIREMLF90 and GIBBSF90) also accepts the same parameter file.

BLUPF90 needs at least 2 files: a data file and a parameter file.
The data file contains observations and related information (animal ID, age, sex, month, and so on).
The parameter file defines the model, the name of the data file, genetic and non-genetic variance components, and optionally the name of the pedigree file.
The files should be prepared by a user.
Here we start with a linear fixed model with 1 class variable; this is equivalent to 1-way ANOVA (with unbalanced data).


One-way ANOVA model
-------------------

### Model ###

First, we describe the statistical model for the 1-way ANOVA:
$$
y_{ij} = A_{i} + e_{ij}
$$
where $y_{ij}$ is an observation, $A_{i}$ is a fixed effect, and $e_{ij}$ is the residual effect.
The corresponding matrix notation is
$$
\mathbf{y} = \mathbf{Xb} + \mathbf{e}
$$
and the system of generalized least-squares equations is
$$
\mathbf{X}'\mathbf{R}^{-1}\mathbf{X}\mathbf{\hat{b}} = \mathbf{X}'\mathbf{R}^{-1}\mathbf{y}
$$
where $\mathbf{R} = \mathrm{var}(\mathbf{e}) = \mathrm{var}(\mathbf{y})$.
We actually assume $\mathbf{R} = \mathbf{I}\sigma_{e}^{2}$ with a residual variance $\sigma_{e}^{2}$, so the above equations reduce to ordinary normal equations: $\mathbf{X}'\mathbf{X}\mathbf{\hat{b}} = \mathbf{X}'\mathbf{y}$.
The purpose of this example is to solve the equations with BLUPF90.
The program doesn’t perform any hypothetical tests.

### Data ###

In this analysis, we need at least 2 information: 1) observations and 2) code to distinguish the level of a class.
Following table shows an actual data set with 10 observations.

Observation     Group
-----------     -----
        3.0        A1
        2.0        A1
        4.0        A1
        6.0        A2
        3.0        A2
        6.0        A2
        6.0        A3
        6.0        A3
        8.0        A3
        4.0        A3

The first column represents observations, and the second column has the group code.
You can put any positive or negative observations to the data file.
You can use any numerical values for observations except for 0.
By default, the program treats 0 as a missing code.
If you want to use an arbitrary number including 0 as a measurement, see the Remarks section below to correctly handle such a case.

In BLUPF90, the user should prepare the data set as a text file in columns separated by spaces, with the same number of columns in every line.
If you use other software like R and SAS, you should save the data as a text file.
Almost any software can export the data to a text file.
Do not forget to replace the symbolic, missing code (like `NA` or `.`) with a numeric value which BLUPF90 treats as missing.

Here we can write down the data file.
You can put any file name.
We save the following 7 lines as a file `data0.txt`.

~~~~~{language=text caption="data0.txt"}
3.0   1
2.0   1
4.0   1
6.0   2
3.0   2
6.0   2
6.0   3
6.0   3
8.0   3
4.0   3
~~~~~

This file shows the rules in a data file used with BLUPF90.
The data is a space-separated format with several columns as supported in much statistical software.
No headers are allowed.
The file should contain numerical expressions only.
We will explain the acceptable data format later.

### Parameter file ###

A parameter file to run this analysis is something like:

~~~~~{language=blupf90 caption="param0.txt"}
DATAFILE
data0.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
1
OBSERVATION(S)
1
WEIGHT(S)

EFFECTS:
2 3 cross
RANDOM_RESIDUAL VALUES
1.0
~~~~~

The parameter file is described as pairs of keyword and value(s).
For example, the first line `DATAFILE` is a keyword and the next line `data.txt` is the corresponding value.
The value(s) should be placed in the next line to the keyword.
The keyword must start from the 1st position in a line (i.e., no leading spaces).
The value can have leading spaces at the beginning of a line.
The above example is a minimal one.
We need at least 7 keywords in every parameter file even some values are empty.
Following is a detailed explanation of the above parameter file.

  1. `DATAFILE` = the name of the data file
     - `data.txt` in this case
  2. `NUMBER_OF_TRAITS`
     - `1` for a single-trait model
  3. `NUMBER_OF_EFFECTS` = number of effects except residual
     - `1` for the fixed effect (only 1 effect in this model except residual)
  4. `OBSERVATION(S)` = position of observation in the data file
     - `1` for the 1st column
  5. `WEIGHT(S)` = position of weight in the data file [^1]
     - There is no weight but empty line must be there.
  6. `EFFECTS:` = description of the model (`2 3 cross`; see below)
     - `2` for the position of group code [2nd column in the data file]
     - `3` for the maximum level [the columns has 1 or 2 or 3; so the maximum is 3]
     - `cross` for the cross-classified effect
  7. `RANDOM_RESIDUAL VALUES` = residual variance $\sigma_e^2$
     - `1.0`; this value doesn't affect the results in this case (see the normal equations).

The `EFFECTS:` block describes the model and its style is different from other software.
In this case, this block has only 1 line because the model has only 1 effect except for residual.
If you have more effects in the model, you can add the description for each effect.

[^1]: `WEIGHT` does not mean the physical weight (i.e., in kg or pounds). It means the importance that we attach to this particular record.
For instance, a weight of 10 may indicate that the measure was taken 10 times. See [wikipedia](https://en.wikipedia.org/wiki/Weight_function).

### Running a program ###

You can save the data file and parameter file in the same folder (directory) and run BLUPF90.
When the program is invoked, it prints a message on the screen and waits for key-in.

~~~~~{language=output}
 name of parameter file?
~~~~~

When you supply the name of parameter file `param1.txt`, the program reads the parameters, builds and solves the equations, and writes the solutions to a file.

What will happen if you give a wrong name of parameter file or your parameter file has erroneous statements?
In both cases, an error message is shown and the program stops.
Possible results are:

- Nonexistent parameter file: The message could be `forrtl: severe (24): end-of-file during read....`.
- Wrong description in the parameter file: A massage depends on the situation. Modify the parameter file as the message says.

### Computations ###

After running the program, you can find a file `solutions` after the computations.
This is also a text file and it contains the following lines.

~~~~~{language=text caption="solutions"}
trait/effect level  solution
    1   1         1      3.00000000
    1   1         2      5.00000000
    1   1         3      6.00000000
~~~~~

Ignoring the first line as a header, we have 3 lines with 4 columns and the 4th column has the solutions.
The first solution ($3.0$) can be interpreted as it is for trait 1, effect 1, and level (group) 1.
The second ($5.0$) is for trait 1, effect 1, and level (group) 2.
The third ($6.0$) is for trait 1, effect 2, and level (group) 3.
With mathematical notations, $\hat{A}_1 = 3.0$, $\hat{A}_2 = 5.0$, and $\hat{A}_3 = 6.0$.
The solution is actually within-class average because we employed a 1-way model with an assumption of homogeneous residual variance.



Fixed effect model
------------------

We consider another fixed model with more effects with the same data set.
The model has 1 additional class effect and 1 regression coefficient as
$$
y_{ijk} = A_i + S_j + \beta x_{ijk} + e_{ijk}
$$
where $y_{ijk}$ is an observation, $A_i$ is a fixed effect, $S_i$ is another fixed effect, $\beta$ is a regression coefficient, $x_{ijk}$ is a covariate, and $e_{ij}$ is the residual effect.
The matrix notation and the covariance structure are the same as the previous one.
We will use the same data as before but there are some additional columns.

Observation      Group1       Group2     $x$
-----------      ------       ------     ---
        3.0          A1           S1     1.0
        2.0          A1           S2     1.0
        4.0          A1           S1     2.0
        6.0          A2           S2     2.0
        3.0          A2           S1     1.0
        6.0          A2           S2     2.0
        6.0          A3           S1     2.0
        6.0          A3           S2     1.0
        8.0          A3           S1     1.0
        4.0          A3           S2     2.0

The data file contains 4 columns in this case.

~~~~~{language=text caption="data1.txt"}
3.0  1  1  1.0
2.0  1  2  1.0
4.0  1  1  2.0
6.0  2  2  2.0
3.0  2  1  1.0
6.0  2  2  2.0
6.0  3  1  2.0
6.0  3  2  1.0
8.0  3  1  1.0
4.0  3  2  2.0
~~~~~

The parameter file is also similar to the previous one but we need extra entries for additional 2 effects.

~~~~~{language=blupf90 caption="param1.txt"}
DATAFILE
data1.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
3
OBSERVATION(S)
1
WEIGHT(S)

EFFECTS:
2 3 cross
3 2 cross
4 1 cov
RANDOM_RESIDUAL VALUES
1.0
~~~~~

What is the difference? The only difference is in `NUMBER_OF_EFFECTS` and `EFFECTS:`.
Because the model has 3 effects (2 for class, 1 for regression), we have changed the value in `NUMBER_OF_EFFECTS`, and `EFFECTS:` needs 3 lines.
Note that the 3rd effect is regression and its description is different from the previous 2 cross-classified effects.
Following is a detailed explanation.

 - *Effect 1*: `2 3 cross` = group code in the column 2 in data; maximum level 3; cross-classified effect
 - *Effect 2*: `3 2 cross` = group code in the column 3 in data; maximum level 2; cross-classified effect
 - *Effect 3*: `4 1 cov` = covariate in the column 4 in data; number of coefficient 1; regression

BLUPF90 refer the first effect to *effect 1*, the second to *effect 2*, and so on.
The order is kept in the solutions file.

Running the program with the parameter file, you can find the following result.

~~~~~{language=text caption="solutions"}
trait/effect level  solution
    1   1         1      0.22500000
    1   1         2      2.22500000
    1   1         3      3.22500000
    1   2         1      2.27500000
    1   2         2      1.77500000
    1   3         1      0.50000000
~~~~~

The program provides 6 estimates; top 3 for the first effect, next 2 for the second effect, the bottom 1 for the last effect.
With mathematical notations, $\hat{A}_1 = 0.225$, $\hat{A}_2 = 2.225$, and $\hat{A}_3 = 3.225$, $\hat{S}_1 = 2.275$, $\hat{S}_2 = 1.775$, and $\hat{\beta} = 0.500$.
This is a single trait model, so the first column is always 1.
The second column contains the effect number from the order of items in `EFFECTS:` in the parameter file.

Note that this system of equation is not full-rank, so the estimate is one of infinite numbers of solutions.
BLUPF90 doesn't support arbitrary constraints to solve the equations.
Although the estimates can look different from ones with other software, the contrasts from an estimable function will be consistent.


Options to control the program
------------------------------

BLUPF90 and related programs can change the behavior with an option.
The option should be written in a parameter file as an additional line at the bottom of the file.
There are many options and the official manual explains them.
Here we just show a typical option line.
We use an option which changes the method of solving mixed model equations from the default PCG (preconditioned conjugate gradient) to the direct method using the FSPAK subroutine.

~~~~~{language=blupf90}
OPTION solv_method FSPAK
~~~~~

The option-line starts with the capital `OPTION` followed by a keyword (option name) and additional information (if needed).
In the above case, the option name is `solv_method` and additional information is `FSPAK`.
Be careful to write an option because BLUPF90 distinguishes capital and small letters in the option-line and fails if the name or information is wrong.

The modified parameter file with this option looks like as follows.

~~~~~{language=blupf90 caption="param1a.txt"}
DATAFILE
data1.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
3
OBSERVATION(S)
1
WEIGHT(S)

EFFECTS:
2 3 cross
3 2 cross
4 1 cov
RANDOM_RESIDUAL VALUES
1.0
OPTION solv_method FSPAK
~~~~~

With this parameter file, BLUPF90 successfully works but prints different messages on the screen.
The solutions are also different from the previous ones because the equations have no unique solutions.

~~~~~{language=text caption="solutions"}
trait/effect level  solution
    1   1         1      2.50000000
    1   1         2      4.50000000
    1   1         3      5.50000000
    1   2         1      0.00000000
    1   2         2     -0.50000000
    1   3         1      0.50000000
~~~~~

You can still see the consistency in a linear combination of the solutions.
For example, $\hat{A}_1 + \hat{S}_1 + \hat{\beta} = 3.0$ in both cases.


Comment lines in parameter file
-------------------------------

A parameter file can contain comments, which will be ignored by the program.
A comment is a small memorandum to keep additional information in a parameter file.
A comment starts with the character `#` and the program ignores any characters between `#` and the end of the line.
The following example works as the previous parameter file.

~~~~~{language=blupf90 caption="param1b.txt"}
#
# This is an example parameter file for a fixed effect model.
# Solving method: FSPAK
#
DATAFILE
data1.txt # write the name of data file here
NUMBER_OF_TRAITS
1 # single trait model
NUMBER_OF_EFFECTS
3 # A, S, b
OBSERVATION(S)
1
WEIGHT(S)

EFFECTS:   # y = A + S + b*x + e
2 3 cross  # effect A
3 2 cross  # effect S
4 1 cov    # regression
RANDOM_RESIDUAL VALUES # any values okay
1.0
# added options
OPTION solv_method FSPAK
~~~~~

This example shows how comments are ignored.
You can write comments almost anywhere in a parameter file.
There is one exception; you don't write a comment in lines for variance components.
If a comment is with the variance component, the program stops with an error.

A comment line is a useful feature so we will put comments on a parameter file in the later chapters.


Remarks
-------

In real-life applications, you may have the data file with alphabets or symbols (alpha-numerics).
Even when a class variable is an integer value, it may not start from 1 and may end in a huge value (like 2087654512).
Before the analysis, you should edit the files to conform to the requirements of the program.
RENUMF90 is a data preparation tool and it replaces alphabets or large numbers to sequential numbers starting from 1.
Besides limited situations (e.g., simulated data or data renumbered by other means), you should usually use RENUMF90 to prepare and check the files.

By default, an observation (a trait) with value 0 (or similar numerical expression i.e. 0.0) is recognized as a missing observation.
Similarly, an effect level read as 0 is treated as missing information. This means that that effect is ignored for that particular record.
For the single-trait model, the missing observation makes little sense, except in rare circumstances like cross-validation or automatic repeated analysis (i.e., dozens of univariate analysis from the same, already recorded, file).
Missing effect is also an abnormal assumption.
So you should avoid 0 in the data.
If your observation has a real 0 record, you can make the program treat this value as a regular observation by adding an `OPTION` statement as follows:

~~~~~{language=blupf90}
OPTION missing -999
~~~~~

The missing option switches the missing value recognized in BLUPF90 from `0` to `-999`.
The value is treated as an integer. No real values will be accepted.

How do we put the interaction among effects commonly found in a 2-way ANOVA ($y = A + B + A \times B + e$)?
To do this, we should prepare all the effects $A$, $B$, and $A \times B$ in the data file.
BLUPF90 does not generate $A \times B$ from the effects $A$ and $B$.
Also, BLUPF90 does not support automatic generation of nested effects.
All interactions or nested effects should be prepared as class effects in the data file.
RENUMF90, a data preparation software, can help to generate such effects.
One exception is regressions nested in a class variable, which is supported by BLUPF90; we will mention this model in a context of random regressions.


Summary
-------

 - BLUPF90 supports linear mixed models.
 - BLUPF90 needs 2 text files: a data file and a parameter file.
 - BLUPF90 creates equations based on the files, solve the equations, and save the solutions to a file.
 - The data file is a space-separated file containing integer or real numbers.
 - Parameter file should be prepared with a specific form.
 - Order of solutions depends on the description of a parameter file.
 - BLUPF90 can change its behavior with options supplied in the bottom of a parameter file.
 - A comment starts with `#` and ends at the end of the line. A comment is totally ignored by a program.
 - Observation or effect 0 means missing. If you really want to use 0 as an observation, change the missing code with the option `missing`.
