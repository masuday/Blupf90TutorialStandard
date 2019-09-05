---
title: Data preparation with RENUMF90
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Basic data preparation
======================

Basic usage of RENUMF90
-----------------------

### Why RENUMF90? ###

BLUPF90 accepts data and pedigree files containing only numerical expressions (integer or real values).
A group label should be integer starting from 1.
A raw data file usually contains characters (alphabets or symbols) for animals' ID or group code.
The characters should be replaced with numerical values before the analysis with BLUPF90 programs.
RENUMF90 performs such a job.
We call this process as *renumbering*.

### Trivial instruction file ###

RENUMF90 reads a parameter file, but it is totally different from the one used in BLUPF90.
Don't confuse 2 kinds of parameter files.
Here, to avoid the confusion, we will refer to the parameter file used in RENUMF90 as an *instruction file* in this tutorial.
This name is unofficial but easier to differentiate two kinds of parameter files.

To understand the behavior of RENUMF90, let's try a small example without pedigree.
Here we use a raw data file and an instruction file.
The raw data is a space-separated text file and contains 5 columns.

~~~~~{language=text caption="rawdata1.txt"}
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

We will create a parameter file for the following model.
$$
    y_{ijk} = A_{i} + S_{j} + \beta x_{ijk} + e_{ijk}
$$
This model is actually the same as one introduced in the previous chapter as a fixed effect model; The first column is animal ID, the next 2 columns are fixed cross-classified effects, and the third one is a fixed regression.
So, this example tries to produce a similar data set used before.

RENUMF90 will read the only necessary columns in the raw data-file, as described in the instruction file.
The following instruction file demonstrates the renumbering of column 2 and 3 as fixed cross-classified effects, column 4 as a covariate, and column 5 as a phenotype.
In this case, column 1 will not be used.

~~~~~{language=renumf90 caption="renum1.txt"}
DATAFILE
rawdata1.txt
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
~~~~~

Instruction file can also have comments, which starts with `#` as seen in the above example.

The instruction file looks like the parameter file for BLUPF90.
The file contains several pairs of keyword and value(s).
The file contains 6 keywords.
`EFFECT` can be repeated several times.
The following keywords are required in the minimal instruction file.

Keyword                          possible value    description
-----------------------          --------------    ------------------------------------------------
`DATAFILE`                       characters        The name of raw data-file to be processed.
`TRAITS`                         integer           A list of the position(s) of observation in the
                                                   data file.
`FIELDS_PASSED TO OUTPUT`        integer           A list of the position(s) of unchanged
                                                   columns in the data file. Empty value is
					           acceptable if not needed (just keep the line empty).
                                                   The columns will be passed through the renumbered file.
`WEIGHT(S)`                      integer           The position(s) for weight in the data file.
                                                   Empty value is acceptable if not needed.
`RESIDUAL_VARIANCE`              real value(s)     Residual (co)variances.
`EFFECT`                         (see below)       Description of an effect. Repeatable.

The `EFFECT` keyword can be repeated as many as you need.
The above instruction file contains 3 effects.
The `EFFECT` keyword has several values as follows.

Keyword       Position    effect type    data type
---------     --------    -----------    ---------
`EFFECT`      integer     `cross`        `alpha`
                                         `numer`
                          `cov`          (none)

In the above table, the position means the position(s) of group code (for class effect) or covariate (for regression) in the raw data-file.
You can choose one of two effect types (`cross` for cross-classified or `cov` for regression).
For cross-classified effects, you can also choose the data type: `alpha` if the column may contain alphabets, or `numer` if the column surely contains integer values only.
Following is an explanation for `EFFECT` block in the above instruction.

~~~~~{language=renumf90}
EFFECT
  2 cross alpha       # treat 2nd column as cross - classified effect ; assuming alphabets
EFFECT
  3 cross alpha       # treat 3rd column as cross - classified effect ; assuming alphabets
EFFECT
  4 cov               # treat 4th column as covariate
~~~~~

Note that, in this case, you can technically use `numer` instead of `alpha` in the second effect because this column contains integer values only.
We, nevertheless, recommend a user to always use `alpha` because it can accept any types of data including both alphabets and numbers.

### Resulting files ###

RENUMF90 asks you to type the name of the instruction file.
The program reads the original data, and it replaces the group labels with sequential, integer values.
Finally, this program generates 3 files, and each file has a fixed name.
If you have the existing file with the same name, the file will be replaced with a new one.

- `renf90.dat`: renumbered data file
- `renf90.par`: a suggested parameter file for BLUPF90
- `renf90.tables`: a correspondence table between the original code with a new integer value

Let's look into the inside of `renf90.dat`.

~~~~~{language=text}
 3.0 1 1 1.0
 2.0 1 2 1.0
 4.0 1 1 2.0
 6.0 2 2 2.0
 3.0 2 1 1.0
 6.0 2 2 2.0
 6.0 3 1 2.0
 6.0 3 2 1.0
 8.0 3 1 1.0
 4.0 3 2 2.0
~~~~~

You can see the difference between the original and renumbered files.
The order of lines (rows) are preserved but the order of columns is different.
Each column has integer values or real (numerical) values.
RENUMF90 change the column order as the following rules.

  1. First, observations: RENUMF90 doesn't change the values.
      - column 1: a single-trait model is assumed and the 1st column is for observations.
  2. Second, effects: the order is determined with the order of `EFFECT` statements in the instruction file.
      - column 2 for effect 1 (corresponding to the 2nd column in the original file).
      - column 3 for effect 2 (3rd column in the original file).
      - column 4 for effect 3 (4th column in the original file).
  3. Last, passed columns: RENUMF90 adds the columns specified in `FIELDS_PASSED TO OUTPUT` keyword in instruction. It doesn't change the content in anyway so, the passed columns may have alphabets and symbols.
      - no additional columns in this case: we didn't set any values for this keyword.

Class variables for effect 1 and 2 (column 2 and 3) are successfully replaced with integer values.
For effect 1, A is replaced with `1`, B with `2` and C with `3`.
For effect 2, 1 is `1` and 2 is `2`.
The correspondence is saved in `renf90.tables`.

~~~~~{language=text}
 Effect group 1 of column 1 with 3 levels, effect # 1
 Value    #    consecutive number
A 3 1
B 3 2
C 4 3
 Effect group 2 of column 1 with 2 levels, effect # 2
 Value    #    consecutive number
1 5 1
2 5 2
~~~~~

In this case, each `Effect group` hash 3 columns: 1st for the original group code, 2nd for the number of times the code occurred in the input, and 3rd for the replaced integer value.

RENUMF90 kindly generates a parameter file for BLUPF90.

~~~~~{language=blupf90}
# BLUPF90 parameter file created by RENF90
DATAFILE
 renf90.dat
NUMBER_OF_TRAITS
		   1
NUMBER_OF_EFFECTS
		   3
OBSERVATION(S)
	1
WEIGHT(S)

EFFECTS: POSITIONS_IN_DATAFILE NUMBER_OF_LEVELS TYPE_OF_EFFECT[EFFECT NESTED]
  2         3 cross
  3         2 cross
  4 1 cov
RANDOM_RESIDUAL VALUES
   1.0000
~~~~~

This looks like perfect for you to use it in BLUPF90, and the program will run the analysis successfully.
In this parameter file, the model description is inherited from the instruction file.
For example, the above instruction contains 3 effects so `renf90.par` also contains 3 effects corresponding to the description in instruction.
Note that the `EFFECTS:` line is followed by extra words (`POSITIONS_IN_DATAFILE` etc.), but it is no problem for BLUPF90.

Running BLUPF90 with this renf90.par will produce the same solutions as described before.
A reader can confirm the fact with these files.

Optional features in RENUMF90
-----------------------------

RENUMF90 specifically accepts some options with an additional line beginning with `OPTION` at the end of the instruction file.
Following options are available.

- `OPTION alpha_size ` $n$: change the size of character fields (maximum number of letters in a column with alpha specification) to $n$.
- `OPTION max_string_readline ` $n$: change the size of the record length (maximum number of letters in a line) to $n$.
- `OPTION max_field_readline ` $n$: change the maximum number of fields (columns) in a line to $n$.

The $n$ above is replaced with an actual integer value.
See the examples.

~~~~~{language=renumf90}
OPTION max_string_readline 2048
~~~~~

If the option is not usable in RENUMF90, the program simply passes it through `renf90.par`.
So, you can put some `OPTION` lines, which will be used in BLUPF90, in instruction, and you will obtain a perfect parameter file with desired options for your analysis.
See the following example.

~~~~~{language=renumf90 caption="renum1a.txt"}
DATAFILE
rawdata1.txt
TRAITS
5
FIELDS_PASSED TO OUTPUT

WEIGHT(S)

RESIDUAL_VARIANCE
1.0
EFFECT
2 cross alpha   # 1st effect
EFFECT
3 cross alpha   # 2nd effect
EFFECT
4 cov           # 3rd effect
OPTION max_string_readline 2048
OPTION alpha_size 40
OPTION solv_method FSPAK
~~~~~

The first 2 options will be taken by RENUMF90, but the last one will be passed through the output file `renf90.par`.


What is the best practice?
--------------------------

Suppose you have to perform many analyses with the same data but different models.
How many times do you run RENUMF90? Basically, there are 2 solutions.

1. In every analysis, rewrite the instruction and run RENUMF90. Then just use the generated `renf90.par`.
2. First, prepare the instruction with maximal models and run RENUMF90. Then, every time, copy the generated `renf90.par` to the new file and modify it to fit a model.

The better solution can depend on your situation.
If you have a relatively small data set and the analysis will not take a long time, the first approach could be applicable.
If your data is large enough and the analysis will take time, the second option is the only efficient way.
Also, in some cases, the generated `renf90.par` is incomplete.
The second approach is more general and it is the use case that the development team assumes.


Summary
-------
- RENUMF90 reads a parameter file, which is totally different from one for BLUPF90. We call it the instruction file (or, simply instruction) in this chapter.
- RENUMF90 replaces alphabets or symbols with integer values which BLUPF90 can use. This process is called *renumbering*.
- RENUMF90 generates a renumbered data file, a table file, and a template parameter file for BLUPF90.
- RENUMF90 generates a template parameter file which parameters are inherited from the instruction file.
- An instruction file consists of pairs of keyword and values. The file can have the comments with the `#` syntax.
- RENUMF90 passes option lines in instruction to `renf90.par`.
- If you use the same data with different analyses, a possible way is to run RENUMF90 once and modify the generated renf90.par to fit a model you should use.
