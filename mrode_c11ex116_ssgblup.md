---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Single-step approach
====================

Model
-----

We consider the standard animal model
$$
\mathbf{y}=\mathbf{Xb}+\mathbf{Wu}+\mathbf{e}.
$$
If some animals are genotyped, their additive relationships are described with the genomic
relationship matrix ($\mathbf{G}$). When the genotyped and the non-genotyped animals are simultaneously
considered in the relationship matrix, the resulting matrix is $\mathbf{H}$. Its inverse falls into a simple form.
$$
\mathbf{H}^{-1}
=
\mathbf{A}^{-1}
+
\left[
\begin{array}{cc}
\mathbf{0}&\mathbf{0}\\
\mathbf{0}&\mathbf{G}^{-1}-\mathbf{A}_{22}^{-1}
\end{array}
\right]
$$
This $\mathbf{G}^{-1}$ is usually blended with the pedigree matrix ($\mathbf{G}^{-1}_{w}$ shown in the previous section). The system of mixed model equations is the same as
the standard animal model with $\mathbf{H}^{-1}$ instead of $\mathbf{A}^{-1}$:
$$
\left[
\begin{array}{ll}
\mathbf{X}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{X}'\mathbf{R}^{-1}\mathbf{Z}\\
\mathbf{Z}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{Z}'\mathbf{R}^{-1}\mathbf{Z}+\mathbf{H}^{-1}/\sigma_u^2
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
\mathbf{Z}'\mathbf{R}^{-1}\mathbf{y} \\
\end{array}
\right]
$$
where $\sigma_u^2 = 35.241$ and $\sigma_e^2 = 245.0$ in this case. BLUPF90 fully supports ssGBLUP with a
minimal description in the parameter file.


Files
-----

The data file is different from the previous ones (`data_mr11e.txt`).
The pedigree information is common to the previous analysis (`pedigree_mr11e.txt`).

The SNP marker file is unique for this analysis.

~~~~~{language=text caption="snp_mr11e.txt"}
 18 11010202210000000000000000000000000000000000000000
...
~~~~~

The corresponding cross-reference file is as follows.

~~~~~{language=text caption="snp_mr11e_XrefID.txt"}
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

The parameter file is shown as follows.

~~~~~{language=blupf90 caption="param_mr11e.txt"}
DATAFILE
data_mr11e.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
2
OBSERVATION(S)
6
WEIGHT(S)
5
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
pedigree_mr11e.txt
(CO)VARIANCES
35.241
OPTION SNP_file snp_mr11e.txt snp_mr11e_XrefID.txt
OPTION no_ quality_control
OPTION AlphaBeta 0.95 0.05
OPTION tunedG 0
OPTION thrStopCorAG 0.10
OPTION solv_method FSPAK
~~~~~

BLUPF90 (actually the embedded genomic routine) may stop because of the very low correlation between
diagonals from $\mathbf{G}$ and $\mathbf{A}_{22}$. The correlation should be usually high enough; otherwise, there may be
a problem in the quality of the genotypes or the pedigree. It is low in this case
due to the small data set. The option `thrStopCorAG` prevents the program from stopping from the low
correlation.


Solutions
---------

Unfortunately, the solutions are totally different from the reference values in the textbook (p.193).

~~~~~{language=text caption="solutions"}
trait/effect level  solution
   1   1         1          8.38509553
   1   2         1         -0.27072327
   1   2         2          2.90677899
   1   2         3         -0.27072327
   1   2         4          2.58838142
   1   2         5         -2.59488845
   1   2         6         -1.88195674
   1   2         7         -0.99299119
   1   2         8         -1.02617193
   1   2         9         -3.14377983
   1   2        10         -1.69066025
   1   2        11         -3.31615787
   1   2        12          0.81555256
   1   2        13          0.63918948
   1   2        14          4.85991512
   1   2        15          4.20216687
   1   2        16          6.46125192
   1   2        17         -1.79124924
   1   2        18         -0.39297755
   1   2        19          1.47720048
   1   2        20         -2.90484503
   1   2        21         -0.54144654
   1   2        22          0.89069967
   1   2        23         -2.54427924
   1   2        24         -0.10603281
   1   2        25          0.94047078
   1   2        26          3.65328640
~~~~~
