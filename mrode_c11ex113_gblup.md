---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

GBLUP
=====

Model
-----

The SNP marker model is equivalent to a model, so-called GBLUP, under some assumptions. The model includes a genomic relationship matrix, $\mathbf{G}$. This matrix is calculated using SNP marker data. It is analog to the pedigree-based additive relationship matrix although there is an essential difference between the two matrices; see VanRaden (2008) for details. The $\mathbf{G}$ matrix may be defined in several ways but the best-known one is defined as
$$
\mathbf{G}=\frac{\mathbf{ZZ}'}{2\sum_j p_j(1-p_j)}
$$
where $\mathbf{Z}$ contains genotypes adjusted with allele frequency and $p_j$ is the allele frequency for marker $j$ (VanRaden 2008). When the number of genotypes is limited, the above $\mathbf{G}$ is most likely singular, and its inverse does not exist. To avoid this issue, we blend the above $\mathbf{G}$ with a numerator relationship matrix for genotyped animals ($\mathbf{A}_{22}$). Therefore, as long as we use this blending, the pedigree file is still needed. The formula of the blending is
$$
\mathbf{G}_w = w\mathbf{G}+(1-w)\mathbf{A}_{22}
$$
where $\mathbf{G}_w$ is the final (weighted) genomic relationship matrix and $w$ is a weight. When $\mathbf{A}_{22}$ is not available, $\mathbf{I}$ may be useful. An appropriate weight usually ranges from 0.80 to 0.99 depending on the profile of $\mathbf{G}$. This blending is expected to makes G be positive definite. The weighted matrix, $\mathbf{G}_{w}$, will be used as a genomic relationship matrix in prediction.

The system of mixed model equations is
$$
\left[
\begin{array}{ll}
\mathbf{X}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{X}'\mathbf{R}^{-1}\mathbf{W}\\
\mathbf{W}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{W}'\mathbf{R}^{-1}\mathbf{W}+\mathbf{G}_{w}/\sigma_u^2
\end{array}
\right]
\left[
\begin{array}{c}
\mathbf{\hat{b}}\\
\mathbf{\hat{u}}
\end{array}
\right]
=
\left[
\begin{array}{l}
\mathbf{X}'\mathbf{R}^{-1}\mathbf{y} \\
\mathbf{W}'\mathbf{R}^{-1}\mathbf{y} \\
\end{array}
\right]
$$
and $\sigma_u^2 = 35.241$ and $\sigma_e^2 = 245.0$. In the simplest case, only the general mean ($\mu$) is considered as the fixed effect, and $\hat{\mathbf{b}}$ reduces to $\hat{\mu}$.

BLUPF90 is designed for the single-step GBLUP model which has the inverse of a numerator relationship matrix ($\mathbf{A}^{-1}$). It means that the final equations should include $\mathbf{A}^{-1}$, which is not usually used in GBLUP. There are several ways to perform GBLUP with BLUPF90. Here I introduce you to a method that has the following 2 steps: 1) preparation of $\mathbf{G}^{-1}$ and 2) build and solve the equations.

In the former step, we can use the PREGSF90 program. This program accepts the same parameter file as BLUPF90. It calculates $\mathbf{G}^{-1}$ with various options and saves it to a file. BLUPF90 can read the file and use it to build the mixed model equations. BLUPF90 supports two file-formats for $\mathbf{G}_{w}^{-1}$: a text file and a binary file. The use of the text format is simpler especially for a small data set and easier to understand how to run GBLUP using BLUPF90. The use of the binary file is more efficient but you need a trick which mimics single-step GBLUP removing the pedigree relationship matrix. In this section, first, we will use the text format to demonstrate how $\mathbf{G}_{w}^{-1}$ can be calculated with PREGSF90 with an educational parameter file. Then, we move to the second approach using the binary file with a different parameter file.

Note that the method introduced here may seem to be complicated. This is because we will not use RENUMF90 here. When using the renumbering tool, GBLUP will be performed easily. In the later chapter, we will see how RENUMF90 simply prepares the files required in pure GBLUP.


Common files
------------

In both approaches, we will use the common marker file and the cross-reference file. The SNP file is as follows.

~~~~~{language=text caption="snp_mr11c.txt"}
13 20110002120000000000000000000000000000000000000000
...
26 10110201000000000000000000000000000000000000000000
~~~~~

The format of the SNP file is described in the previous chapter. The textbook uses only 10 SNP markers but the above file contains 50 markers. The extra 40 markers are padding because BLUPF90 cannot read fewer than 50 markers. All animals have the genotype 0 for the extra markers so the markers do not provide any information. The resulting $\mathbf{G}$ is the same as using only the first 10 markers.

The accompanying cross-reference file is also needed. This file relates the ID for genotyped animals and the order of animals in the marker file. The detailed explanation is also available in the previous chapter.

~~~~~{language=text caption="snp_mr11c_XrefID.txt"}
13 13
14 14
15 15
16 16
17 17
18 18
19 19
20 20
21 21
22 22
23 23
24 24
25 25
26 26
~~~~~

The first approach with a text file for G-inverse
-------------------------------------------------

### For PREGSF90 ###

To obtain the text file to have $\mathbf{G}^{-1}_{w}$ using PREGSF90, we use the data file (`data_mr11c1.txt`) as before except for the last column for genotyped animals with different coding. Note that the data file is not really read by PREGSF90 but we need it, because the program checks whether the data file is present or not.

~~~~~{language=text caption="data_mr11c1.txt"}
 13  0  0  1 558  9.0  0.00179211 1
...
 20 14  9  1 103  4.8  0.00970874 8
~~~~~

1. The original animal ID
2. The original sire ID
3. The original dam ID
4. general mean
5. EDC
6. Observation (Fat DYD)
7. 1/EDC
8. new ID for genotyped animals (in the order of the marker file - _this is important_)

The key is the 8-th column. This approach needs a new ID corresponding to the order in the marker file. For example, animal 13 appears in the 1st row in the marker file, and it has 1 as a new ID. Later, we will see the details of the new ID.

The pedigree file (`pedigree_mr11c1.txt`) contains all the animals with and without genotypes. The program creates a subset of relationship matrix ($\mathbf{A}_{22}$) only for genotyped animals.

The parameter file for PREGSF90 is the same as BLUPF90.

~~~~~{language=blupf90 caption="preparam_mr11c1.txt"}
#
# Approach 1: creates a text G - Inverse file with PREGSF90
#
DATAFILE
data_mr11c1.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
2
OBSERVATION(S)
6
WEIGHT(S)
7
EFFECTS:
4  1 cross
1 26 cross
RANDOM_RESIDUAL VALUES
245.0
RANDOM_GROUP
2
RANDOM_TYPE
add_animal
FILE
pedigree_mr11c1.txt
(CO)VARIANCES
35.25
OPTION SNP_file snp_mr11c.txt snp_mr11c_XrefID.txt
OPTION no_quality_control
OPTION AlphaBeta 0.99 0.01
OPTION tunedG 0
OPTION saveAscii
OPTION saveG
OPTION saveGInverse
OPTION createGimA22i 0
~~~~~

The purpose of PREGSF90 is to create a text file with the elements of $\mathbf{G}_{w}$. By default, PREGSF90 tries to manipulate $\mathbf{G}_{w}$ in many ways. The options change the behavior of PREGSF90. Note that the options are case-sensitive. Simple explanations for the options are available:

- `SNP_file` = Invoking the genomic routine. It needs 2 values in this case: the name of the marker file and the name of the cross-reference file.
- `no_quality_control` = Turns off the quality control process to remove unqualified markers and genotyped animals. In this example, we will use all the markers and genotyped animals.
- `AlphaBeta` = Defines weight $w$. This option has 2 values: $\alpha=w$ and $\beta=1-w$. In this example, we put $w = 0.99$ which is implicitly used by the author.
- `tunedG` = Controls the tuning method for $\mathbf{G}_w$. It tries to adjust the scale of $\mathbf{G}$ to $\mathbf{A}_{22}$ using a method described by Chen et al. (2011). This tuning is _a different step as blending_. The argument 0 turns off the adjustment (that is uses $\mathbf{G}_{w}$ ).
- `saveAscii` = Uses the text format for a file to save $\mathbf{G}_{w}^{-1}$. Without this option, the program saves the matrix to a binary file (a machine-readable file).
- `saveG` = Saves $\mathbf{G}_w$ to a file. The file name will be `G`. Actually, you do not have to put this option in this analysis. We just use it as an educational purpose to see the actual values in $\mathbf{G}_{w}$.
- `saveGInverse` = Saves $\mathbf{G}_{w}^{-1}$ to a file. The file name will be `Gi`.
- `createGimA22i` = Turns off the calculation of $\mathbf{G}_{w}^{-1}-\mathbf{A}_{22}$ which is required in single-step GBLUP. You do not have to put this option in this small example because the computing cost is negligible. Turning off this option is important for a large-size problem in GBLUP.

We have more than 100 options just for PREGSF90. Many of them are implemented for experimental purposes and unused. We will demonstrate such options in the later chapter. In this section, a user can just recognize that there are plenty of options for PREGSF90, but only a few options may be essential for the regular use in genomic prediction.

You can run PREGSF90 with the above parameter file. You can see the basic statistics for $\mathbf{G}_{w}$ on the screen. Also, you will find that some files are created.

- `Gen_call_rate` = Empty in this case. Just ignore it.
- `freq.count` = Allele frequency for each marker. The values should be the same as the textbook (see p.181).
- `sum2pq` = $2\sum_j p_j(1-p_j)$
- `G` = Elements in $\mathbf{G}_w$. The values are slightly different from the textbook (p.186) because the textbook values are from the pure $\mathbf{G}$ (not blended with $\mathbf{A}_{22}$). You can find the same values as the textbook when you put `OPTION AlphaBeta 1.0 0.0`, but the program cannot calculate its inverse because it is singular.
- `Gi` = Elements in $\mathbf{G}_{w}^{-1}$. Only the diagonals and the upper triangular elements are stored.

Among the above files, only `Gi` is required in the analysis with BLUPF90. The first 5 rows and the last 5 rows in this file are as follows.

    1 1 36.374112147756
    1 2 -27.980861774302
    2 2 88.270926666258
    1 3 -8.255548353247
    2 3 31.300275470378
    ...
    10 14 2.733882533018
    11 14 6.555679888597
    12 14 5.120296531692
    13 14 4.504947248223
    14 14 6.133181220876

The first 2 integers are the row and column indices for the element. Note that the maximum row and column ID is 14 because the rank of this matrix ($\mathbf{G}_{w}^{-1}$) is 14. So the row/column index does not directly refer to the animal's ID. PREGSF90 internally re-assigns IDs for genotyped animals as the consecutive order of animals in the marker file. For example, row 1 and column 1 (the first line in the above file) corresponds to the relationship between animal 13 and 13 (that is, the diagonal for the animal 13) because the animal 13 appears the first in the marker file (animal 13 = new ID 1). The row 1 and column 2 (the second line) is for the relationships between animal 13 and 14 because the animal 14 appears secondly in the marker file (animal 14 = new ID 2). Therefore, we should use the new ID to refer to genotyped animals.

We have already prepared the data file with the new ID (the 8th column). BLUPF90 can read the new column as an animal ID.


### For BLUPF90 ###

The parameter file for BLUPF90 is shown below.

~~~~~{language=blupf90 caption="param_mr11c1.txt"}
DATAFILE
data_mr11c1.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
2
OBSERVATION(S)
6
WEIGHT(S)

EFFECTS:
4  1 cross
8 14 cross  # new ID (renumbered only for genotyped animals)
RANDOM_RESIDUAL VALUES
245.0
RANDOM_GROUP
2
RANDOM_TYPE
user_file
FILE
Gi
(CO)VARIANCES
35.25
OPTION solv_method FSPAK
~~~~~

We use the keyword `user_file` to read the text file for $\mathbf{G}_{w}^{-1}$ With this keyword, we do not need the marker file anymore. BLUPF90 simply read the file and put the elements into the equations. Run BLUPF90 with the parameter file, and you will find the results. The solutions look very similar to the values in the textbook (p.185; GBLUP).


Second approach with a binary file for G-inverse
------------------------------------------------

The parameter file for PREGSF90 is very similar to the previous one.

~~~~~{language=blupf90 caption="preparam_mr11c2.txt"}
DATAFILE
data_mr11c1.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
2
OBSERVATION(S)
6
WEIGHT(S)

EFFECTS:
4  1 cross
1 26 cross
RANDOM_RESIDUAL VALUES
245.0
RANDOM_GROUP
2
RANDOM_TYPE
add_animal
FILE
pedigree_mr11c1.txt
(CO)VARIANCES
35.25
OPTION SNP_file snp_mr11c.txt snp_mr11c_XrefID.txt
OPTION no_quality_control
OPTION AlphaBeta 0.99 0.01
OPTION tunedG 0
#OPTION saveAscii
#OPTION saveG
OPTION saveGInverse
OPTION createGimA22i 0
~~~~~

The only differences between this parameter file and the previous one are options. We remove (actually comment out) the two options. With this parameter file, the G-inverse file (`Gi`) is saved as a binary format readable only for the computer. Also, we do not need a file, `G`. Run PREGSF90 with this parameter file, and you can see the very similar output on the screen.

With this approach, we trick BLUPF90 as if the single-step GBLUP was applied. In this analysis, we shouldn't use the pedigree file. The prepared $\mathbf{G}_{w}^{-1}$ is already blended with $\mathbf{A}_{22}$ so we do not need the pedigree file. We just prepare a dummy, empry pedigree file. This file contains 26 lines, which is the same number of lines as the original pedigree.

~~~~~{language=text caption="pedigree_mr11c2.txt"}
0 0 0
...
0 0 0
~~~~~

We need the data, (empty) pedigree, marker and cross-reference files as well as `Gi` for the analysis with BLUPF90. The parameter file for BLUPF90 is slightly different from one for PREGSF90.

~~~~~{language=blupf90 caption="param_mr11c2.txt"}
DATAFILE
data_mr11c1.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
2
OBSERVATION(S)
6
WEIGHT(S)

EFFECTS:
4  1 cross
1 26 cross  # use the original ID
RANDOM_RESIDUAL VALUES
245.0
RANDOM_GROUP
2
RANDOM_TYPE
add_animal
FILE
pedigree_mr11c2.txt
(CO)VARIANCES
35.25
OPTION SNP_file snp_mr11c.txt snp_mr11c_XrefID.txt
OPTION readGimA22i Gi
OPTION solv_method FSPAK
~~~~~

This parameter file is for single-step GBLUP. In this case, the pedigree file is empty, and $\mathbf{A}^{-1}=\mathbf{0}$. The program will read `Gi` instead of creating $\mathbf{G}_{w}^{-1}$ and $\mathbf{A}_{22}$ with the second option (`OPTION readGimA22i`). The program reads $\mathbf{G}_{w}^{-1}$, and it performs GBLUP.

Run BLUPF90 with the parameter file, and you can find the solutions that are identical to approach 1. You can see many warnings (`Animal Id equal to Sire/Dam Id - relationships removed !!`) because we use a trick which never happens in the regular single-step GBLUP.

Again, the approaches demonstrated here require some manual operations. In the later chapter, we will see an automatic approach to perform GBLUP using RENUMF90 and BLUPF90.
