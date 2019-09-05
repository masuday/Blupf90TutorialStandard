---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Breeding values with marker information
=======================================

Models
------

In this example, the author assumes one known genetic marker with the polygenic effect for a trait.
The genetic marker accounts for a certain level of genetic variance. Covariances among animals
in terms of the additive effects of the marker alleles can be represented as the marker covariance
matrix ($\mathbf{G}_v$). Fernando and Grossman (1989) suggested a method to calculate $\mathbf{G}^{-1}_v$ directly from the
pedigree list and genotypes.

In this example, the author assumes a model with the additive genetic (polygenic) effect,
the additive genetic effect due to genetic markers, and the random residual effect.
The author uses a pre-calculated $\mathbf{G}_v$ to estimate the partial breeding values explained by the marker.
Also, the model includes the additive genetic relationship matrix ($\mathbf{A}_u$) which accounts for the
"residual" polygenic effect. The mixed model equations are
$$
\left[
\begin{array}{lll}
\mathbf{X}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{X}'\mathbf{R}^{-1}\mathbf{Z} & \mathbf{X}'\mathbf{R}^{-1}\mathbf{W}\\
\mathbf{Z}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{Z}'\mathbf{R}^{-1}\mathbf{Z} + \mathbf{A}_{u}^{-1}/\sigma_u^{2} & \mathbf{Z}'\mathbf{R}^{-1}\mathbf{W}\\
\mathbf{W}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{W}'\mathbf{R}^{-1}\mathbf{Z} & \mathbf{W}'\mathbf{R}^{-1}\mathbf{W} + \mathbf{G}_{v}^{-1}/\sigma_v^{2}\\
\end{array}
\right]
\left[
\begin{array}{c}
\mathbf{\hat{b}}\\
\mathbf{\hat{u}}\\
\mathbf{\hat{v}}
\end{array}
\right]
=
\left[
\begin{array}{l}
\mathbf{X}'\mathbf{R}^{-1}\mathbf{y} \\
\mathbf{Z}'\mathbf{R}^{-1}\mathbf{y} \\
\mathbf{W}'\mathbf{R}^{-1}\mathbf{y}
\end{array}
\right]
$$
The variance components are $\sigma_u^2=0.30$, $\sigma_v^2= 0.05$, and $\sigma_e^2 = 0.60$.


We need to overcome several issues to conduct the analysis. First, BLUPF90 has no function to
calculate $\mathbf{G}_{v}^{-1}$. Instead, the program should read a user-supplied file containing the elements of
$\mathbf{G}^{-1}_{v}$. Second, the animals in the pedigree are highly inbred. By default, BLUPF90 ignores inbreeding
coefficients when calculating $\mathbf{A}^{-1}$. To consider inbreeding on $\mathbf{A}^{-1}$, a user should put an additional
column to the pedigree file, and accordingly modify the parameter file.


Files
-----

The data file is prepared as shown in p.159 (`data_mr10a.txt`).
The marker effects are inserted into columns 5 and 6.

~~~~~{language=text caption="data_mr10a.txt"}
  1 1 0 0  1  2  6.8
...
~~~~~

1. Animal ID (calf)
2. Sex (1=male and 2=female)
3. Sire ID
4. Dam ID
5. Paternal QTL allele
6. Maternal QTL allele
7. Post weaning weight (kg)

Now we prepare the pedigree file with the additional 4th column to consider inbreeding coefficients
for $\mathbf{A}^{-1}$.

The first 3 columns are animal ID, sire ID, and dam ID as usual. The 4th column is an inb/upg code
exclusively used in the BLUPF90 family. The code is a 4-digit integer. It is calculated as
$$
\mathrm{inb/upg code}=\frac{4000}{(1+m_s)(1-F_s)+(1+m_d)(1-F_d)}
$$
where $m_s$ is 0 if its sire is known or 1 if the sire is unknown; $m_d$ is 0 if its dam is known or 1 if the
dam is unknown; $F_s$ is the inbreeding coefficient of the sire; and $F_d$ is the inbreeding coefficient of
the dam. If the sire (or dam) is unknown, $F_s$ (or $F_d$) is 0. In this case, the inbreeding coefficient of
animal 4 is 0.25 (and animal 5 for 0.375 but this value is not used here). The inb/upg code ($c$) for
each animal is
$$
\begin{aligned}
c_1 &= 4000/[(1 + 1)(1 - 0) + (1 + 1)(1 - 0)] = 1000\\
c_2 &= 4000/[(1 + 1)(1 - 0) + (1 + 1)(1 - 0)] = 1000\\
c_3 &= 4000/[(1 + 0)(1 - 0) + (1 + 0)(1 - 0)] = 2000\\
c_4 &= 4000/[(1 + 0)(1 - 0) + (1 + 0)(1 - 0)] = 1000\\
c_5 &= 4000/[(1 + 0)(1 - 0.25) + (1 + 0)(1 - 0)] = 2285.7 \approx 2286.
\end{aligned}
$$
RENUMF90 calculates the code and prepares an appropriate pedigree file using the `INBREEDING` keyword.
See the manual for details.

The inverse of marker genetic matrix ($\mathbf{G}_{v}^{-1}$; p.164) is prepared as the following text file.

~~~~~{language=text caption="userinverse_mr10a.txt"}
  1  1  5.556
  1  2  1.000
  1  5 -5.000
...
  8  9 -0.663
  9  9  6.630
 10 10  5.556
~~~~~

The file contains 3 columns: row index, column index and the value (or column index, row index,
and the value). BLUPF90 supports a symmetric matrix as a user-supplied inverse of relationship
matrix, so the program needs only upper- or lower-diagonal elements as well as the diagonal
elements. The above file contains elements in and above the diagonal. Note that elements with a value of 0 do not need to be provided,
which is handy when the matrix is sparse.

The parameter file should be as follows.

~~~~~{language=blupf90 caption="param_mr10a.txt"}
DATAFILE
data_mr10a.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
4
OBSERVATION(S)
7
WEIGHT(S)

EFFECTS:
2  2 cross    # fixed effect
1  5 cross    # additive genetic effect
5  0 cross    # paternal QTL effect
6 10 cross    # maternal QTL effect ( total 10 levels combined with paternal effect )
RANDOM_RESIDUAL VALUES
0.60
RANDOM_GROUP
2
RANDOM_TYPE   # considering inbreeding
add_an_upginb
FILE
pedigree_mr10a.txt
(CO)VARIANCES
0.30
RANDOM_GROUP
4
RANDOM_TYPE   # reading the user-supplied file
user_file
FILE          # its file name
userinverse_mr10a.txt
(CO)VARIANCES
0.05
OPTION solv_method FSPAK
~~~~~

We should be careful to describe the parameter file in terms of the following information.

- `EFFECTS`: Use of the "level 0" technique. The incidence matrix for the QTL marker effects, $\mathbf{W}$,
  contains two 1s per row. A trick can do this. See the social interaction model for the detailed
  explanation. Also, there are 10 levels combining paternal and maternal QTL effects.
- `RANDOM_TYPE` for the additive genetic effect: Use of `add_an_upginb`. The pedigree file
  contains the 4th column which indicates the inb/upg code. With this keyword, BLUPF90 can
  read the column and build $\mathbf{A}^{-1}$ with inbreeding. Even if we don't put any unknown parent
  groups in this analysis, the keyword should be `add_an_upginb`.
- `RANDOM_TYPE` for the marker effect: Use of user file to read the user-supplied file. The
  name of the file should also be supplied at FILE section.


Solutions
---------

The solutions are identical to the textbook (p.166).
