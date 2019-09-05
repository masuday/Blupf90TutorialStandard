---
title: Large-scale genetic evaluation
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

REML estimation with large data
===============================

Background
----------

In typical REML computations, there are several bottlenecks. First, the exact solutions of the
mixed model equations with the current variance components are needed. This means we should
use Gaussian elimination or similar methods (direct methods). The Cholesky factorization is often
employed to solve the equations. The LHS of mixed model equations generally contains many zero
elements, and the matrix is sparse. Although we can hold only the nonzero elements to
save the memory, very complicated operations are needed for the factorization.

Secondly, the REML algorithms use the first derivative of the restricted log-likelihood, which
contains the selected elements of the inverse of LHS. In the animal model, the derivative contains
the following trace term:
$$
\mathrm{tr}(\mathbf{A}^{-1}\mathbf{C}^{uu})
$$
where $\mathbf{A}^{-1}$ is the inverse of the numerator relationship matrix and $\mathbf{C}^{uu}$ is the submatrix of the
inverse of the left-hand side (LHS) of the mixed model equations corresponding to the solutions
for the additive genetic effect ($\hat{\mathbf{u}}$). Simply speaking, the REML equations require the inverse of the
LHS. The inverse of a sparse matrix is usually dense (non-sparse). You can easily imagine that its
computational and storage costs are extremely high.

In this calculation, we don't actually need the whole inverse. We just need the selected elements
of the inverse corresponding to non-zero elements in the original $\mathbf{C}$. The selected subset is called
sparse inverse in animal breeding literature. An algorithm, so-called Takahashi algorithm, can
calculate the sparse inverse. This algorithm updates the Cholesky factor of the LHS.

FSPAK is a successful computer package to perform sparse operations including the factorization
and sparse inversion for the LHS of mixed model equations. This package is the default solver
in REMLF90 and AIREMLF90 (and BLUPF90 with `OPTION solv_method FSPAK`). It is still
useful for small equations although the back-end subroutines were written more than 20 years ago.
Unfortunately, the old design is inefficient in larger equations with many dense blocks. For
example, a multiple-trait model (or random regression/maternal model) contains many (genetic and
residual) covariance matrices in the equations. Although each covariance matrix is small, the small
matrices are combined into large dense blocks during the sparse operations. This is more typical
of a genomic model including the (inverse of) genomic relationship matrix, that is large and
dense.

YAMS is a replacement of FSPAK. This package implements several
advanced algorithms, including the supernodal factorization and the inverse multifrontal approach,
to efficiently handle the dense blocks in the sparse matrix. YAMS intensively uses BLAS and
LAPACK. For technical details,
see Masuda et al. (2014) and Masuda et al. (2015).

AIREMLF90 especially implements several options to accelerate the computation and stabilize
the estimation process. Here we also introduce the options.


Files
-----

We will use the following files.

- [`simdata_rep.txt`](https://github.com/Masuday/data/blob/master/tutorial/simdata_rep.txt) : data file
- [`simped.txt`](https://github.com/Masuday/data/blob/master/tutorial/simped.txt) : pedigree file

We will use a 4-trait repeatability model with the parameter file.

~~~~~{language=blupf90 caption="complicatedparam1.txt"}
DATAFILE
simdata_rep.txt
NUMBER_OF_TRAITS
4
NUMBER_OF_EFFECTS
5
OBSERVATION(S)
9 10 11 12
WEIGHT(S)

EFFECTS: POSITIONS_INDATAFILE NUMBER_OF_LEVELS TYPE_OF_EFFECT  [ EFFECT NESTED ]
6 6 6 6   155 cross
7 7 7 7     2 cross
8 8 8 8    11 cross
1 1 1 1  4641 cross
1 1 1 1  4641 cross
RANDOM_RESIDUAL VALUES
100 80 80 80
80 100 80 80
80 80 100 80
80 80 80 100
RANDOM_GROUP
4
RANDOM_TYPE
add_animal
FILE
simped.txt
(CO)VARIANCES
100 80 80 80
80 100 80 80
80 80 100 80
80 80 80 100
RANDOM_GROUP
5
RANDOM_TYPE
diagonal
FILE

(CO)VARIANCES
100 80 80 80
80 100 80 80
80 80 100 80
80 80 80 100
OPTION use_yams
OPTION EM-REML 10
~~~~~

Here we put 2 options.

~~~~~{language=blupf90}
OPTION use_yams
~~~~~

This option switches the sparse library from FSPAK to YAMS. If the program has multi-threaded
BLAS and LAPACK, the computations will be parallelized.
This option is also effective in BLUPF90 in a combination with `OPTION solv_method FSPAK` --- it
will use YAMS instead of FSPAK.

~~~~~{language=blupf90}
OPTION EM-REML n   # default :0
~~~~~

This option forces the program performs EM REML (equivalent to REMLF90) in the first n rounds. The default is 0 i.e. no EM
rounds are performed and AI rounds start from round 1. For complicated models, AI REML often diverges in
the first round. Although this option can give a remedy for this situation, it doesn't always prevent
the program from diverging.

We have several more options to accelerate the computations.

~~~~~{language=blupf90}
OPTION fact_once x
~~~~~

This option avoids the re-calculation of the Cholesky factor. It saves the Cholesky factor in
temporary memory (if `x` is `memory`) or a temporary file (if `x` is `file`). If you have enough memory, `memory`
is preferable because of its faster computations.

~~~~~{language=blupf90}
OPTION approx_loglike
~~~~~

This skips the computation of the exact log-likelihood. If you don't need the exact value, we
recommend using this option for speed-up.


Results
-------

The following results will be available in 17 rounds.

~~~~~{language=output}
 new R
   45.124       22.357       18.626       13.762
   22.357       44.210       22.690       18.016
   18.626       22.690       46.101       22.795
   13.762       18.016       22.795       45.274
 new G
   41.967       22.512       24.058       26.907
   22.512       17.489       19.738       24.257
   24.058       19.738       28.775       34.741
   26.907       24.257       34.741       56.668
 new G
   15.546       15.237       10.490       1.4105
   15.237       40.937       19.562       6.4840
   10.490       19.562       27.782       4.5379
   1.4105       6.4840       4.5379       2.4410
~~~~~

You can try alternative parameter file without `use_yams` and `EM-REML`. Without YAMS, the
computations will be slow. Without EM-REML, the estimates diverge in the 1st round. You can
also try `fact_once` and `approx_loglike`. Although you will not be sure that the options
accelerate the computations in this small example, it surely reduces the computing time for a larger
analysis.
