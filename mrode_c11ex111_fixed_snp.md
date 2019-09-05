---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Fixed effect model for SNP effects
==================================

Model
-----

In this section, the author tries to estimate individual SNP effect as a fixed effect based on 8 reference
animals that have both genotype and phenotype (fat DYD). Only 3 SNP markers are considered in this
small example. We also consider the regular additive genetic (polygenic) effects. The model is
$$
y_{i} = \mu + \sum_{k=1}^{3}z_{ik} g_{k} + u_{i} + e_{i}
$$
where $y_i$ is an observation for animal $i$, $\mu$ is the general mean, $z_{ik}$ is $k$-th weighted marker genotype
for the animal i.e. the $(i,k)$ element in the $\mathbf{Z}$ matrix (see VanRaden, 2008), $g_k$ is the $k$-th fixed SNP
effect, $u_i$ is the additive genetic (polygenic) effect, and $e_i$ is the residual effect. We can consider
more animals in pedigree.
The variance components are $\sigma_u^2= 35.241$ and $\sigma_e^2 = 245.0$.


Files
-----

In this model, the elements of $\mathbf{Z}$ are used as covariates so they should be saved in the data file.
The data file contains the first 3 columns of $\mathbf{Z}$; see p.181 in the textbook. Also, the weight used in this
analysis is actually the inverse of EDC so the values should be calculated and stored in the data file.

~~~~~{language=text caption="data_mr11a.txt"}
 13  0  0  1 558  9.0  0.00179211   1.357 -0.357  0.286
...
~~~~~

The data file (`data_mr11a.txt`) has 10 columns.

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

The pedigree file includes all 26 animals. Animal 1 to 12 have missing parents.

The parameter file for the weighted analysis is shown below.

~~~~~{language=blupf90 caption="param_mr11a.txt"}
DATAFILE
data_mr11a.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
5
OBSERVATION(S)
6
WEIGHT(S)
7
EFFECTS:
 4  1 cross   # general mean
 8  1 cov     # SNP effect 1
 9  1 cov     # SNP effect 2
10  1 cov     # SNP effect 3
 1 26 cross   # additive genetic ( polygenic ) effect
RANDOM_RESIDUAL VALUES
245.0
RANDOM_GROUP
5
RANDOM_TYPE
add_animal
FILE
pedigree_mr11a.txt
(CO)VARIANCES
35.241
OPTION solv_method FSPAK
~~~~~

If you conduct the unweighted analysis, remove 7 from the WEIGHT(S) section.


Solutions
---------

In the weighted analysis, the solutions are the same as the textbook
(p.181). The estimate of the general mean is different but I believe this is a typo in the textbook.
