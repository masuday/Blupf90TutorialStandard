---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Mixed linear model for computing SNP effects
============================================

Model
-----

When we have many SNP markers, we can expect that almost all the additive genetic variation can be captured by the markers. In this case, the marker effects should be random because of too many effects to be estimated compared with the number of observations. With the random marker model, we might not need the polygenic effect. In this example, the author assumes the following model:
$$
y_{i} = \mu + \sum_{k=1}^{m}z_{ik} g_{k} + u_{i} + e_{i} = \mathbf{1}\mu + \mathbf{Zu} + \mathbf{e}
$$
where $y_i$ is the observation of animal $i$, $\mu$ is the general mean, $m$ is the number of markers to be considered, $z_{ik}$ is the $k$-th weighted marker genotype of the animal that is the $(i,k)$ element in $\mathbf{Z}$, $g_k$ is the $k$-th fixed SNP effectm, and $e_i$ is the residual effect. The system of mixed model equations is
$$
\left[
\begin{array}{ll}
\mathbf{X}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{X}'\mathbf{R}^{-1}\mathbf{Z}\\
\mathbf{Z}'\mathbf{R}^{-1}\mathbf{X} & \mathbf{Z}'\mathbf{R}^{-1}\mathbf{Z}+\mathbf{I}/\sigma_g^2
\end{array}
\right]
\left[
\begin{array}{c}
\mathbf{\hat{b}}\\
\mathbf{\hat{g}}
\end{array}
\right]
=
\left[
\begin{array}{l}
\mathbf{X}'\mathbf{R}^{-1}\mathbf{y} \\
\mathbf{Z}'\mathbf{R}^{-1}\mathbf{y} \\
\end{array}
\right].
$$
The residual variance was shown as $\sigma_e^2 = 245.0$ in the textbook. The marker variance ($\sigma_g^2$) can be estimated based on the additive genetic variance ($\sigma_u^2$) using  $\sigma_u^2/\left[2\sum p_j(1-p_j)\right]$ where $p_j$ is the allele frequency for marker $j$. In this example, the author uses the latter equation and shows $2\sum p_j(1-p_j) = 3.5383$ so the variance components are $\sigma_g^2 = 35.242/3.5382 = 9.96$.


Files
-----

The data file (`data_mr11b.txt`) now contains 10 columns from $\mathbf{Z}$ (p.184).

1. Animal ID
2. Sire ID
3. Dam ID
4. General mean
5. EDC
6. Phenotype (Fat DYD)
7. Weight = inverse of EDC
8. Covariate for SNP 1
9. Covariate for SNP 2
10. Covariate for SNP 3
11. Covariate for SNP 4
12. Covariate for SNP 5
13. Covariate for SNP 6
14. Covariate for SNP 7
15. Covariate for SNP 8
16. Covariate for SNP 9
17. Covariate for SNP 10

We can use the same pedigree defined as before (`pedigree_mr11b.txt`).

The parameter file contains 10 SNP effects.

~~~~~{language=blupf90 caption="param_mr11b.txt"}
DATAFILE
data_mr11b.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
11
OBSERVATION(S)
6
WEIGHT(S)
7
EFFECTS:
 4  1 cross   # general mean
 8  1 cov     # SNP effect 1
 9  1 cov     # SNP effect 2
10  1 cov     # SNP effect 3
11  1 cov     # SNP effect 4
12  1 cov     # SNP effect 5
13  1 cov     # SNP effect 6
14  1 cov     # SNP effect 7
15  1 cov     # SNP effect 8
16  1 cov     # SNP effect 9
17  1 cov     # SNP effect 10
RANDOM_RESIDUAL VALUES
245.0
RANDOM_GROUP
2 3 4 5 6 7 8 9 10 11
RANDOM_TYPE
diagonal
FILE

(CO)VARIANCES
9.96 0 0 0 0 0 0 0 0 0
0 9.96 0 0 0 0 0 0 0 0
0 0 9.96 0 0 0 0 0 0 0
0 0 0 9.96 0 0 0 0 0 0
0 0 0 0 9.96 0 0 0 0 0
0 0 0 0 0 9.96 0 0 0 0
0 0 0 0 0 0 9.96 0 0 0
0 0 0 0 0 0 0 9.96 0 0
0 0 0 0 0 0 0 0 9.96 0
0 0 0 0 0 0 0 0 0 9.96
OPTION solv_method FSPAK
~~~~~

In the above parameter file, we defined 10 SNP effects as a group of random effects. The covariances among the effects are 0 so all the SNP effects are independent to each other. This description is equivalent to separately define each SNP effect (that is 10 `RANDOM_GROUP` blocks). A user can confirm that these 2 parameter files produce the same results.


Solutions
---------

We should carefully look at the results shown in the textbook (p.185). The solutions from the weighted analysis seem inaccurate. The solutions come from the analysis with EDC (column 5) and the results are not correct. The correct weight is the inverse of EDC (column 7), and the following solutions in our analysis should be correct.

~~~~~{language=text caption="solutions"}
trait/effect level  solution
   1   1         1          9.12440501
   1   2         1          0.00004355
   1   3         1         -0.00440133
   1   4         1          0.00439876
   1   5         1         -0.00104827
   1   6         1          0.00048476
   1   7         1          0.00229457
   1   8         1          0.00000000
   1   9         1         -0.00000000
   1  10         1          0.00179833
   1  11         1         -0.00125140
~~~~~

Unweighted results are also shown.

~~~~~{language=text caption="solutions"}
trait/effect level  solution
   1   1         1          9.94392543
   1   2         1          0.08702093
   1   3         1         -0.31079216
   1   4         1          0.26246003
   1   5         1         -0.08027711
   1   6         1          0.11020813
   1   7         1          0.13908022
   1   8         1         -0.00000000
   1   9         1          0.00000000
   1  10         1         -0.06069044
   1  11         1         -0.01580233
~~~~~
