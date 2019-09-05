---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Joint analysis of quantitative and binary traits
================================================

Model
-----

We can consider a 2-trait model with one threshold trait and one continuous trait. When we use Gibbs
sampling to draw the posterior distribution for a location parameter, we can simply obtain a solution
as the posterior mean. However, once we try to calculate the solutions without Gibbs sampling, the
resulting equations become nonlinear and a complicated strategy is needed to solve the equations.
See Wang et al. (1997) for detailed discussion. For the threshold trait, the solutions obtained with
anyways should be converted differently as the regular threshold model. The author cited
Foulley et al. (1983) and explains how to do it.

In this section, we will simply use THRGIBBS1F90 to draw the posterior mean for a location
parameter. In this example, we have only 1 threshold, so the program fixes the threshold to 0 and
the residual variance to 1.0.

File
----

The data file is from Foulley et al. (1983) and shown below.

~~~~~{language=text caption="data_mr13b.txt"}
1 1 1 1 41.0 1
1 1 1 1 37.5 1
1 1 1 2 41.5 1
1 1 2 2 40.0 1
1 1 2 2 43.0 1
1 1 2 2 42.0 1
1 1 2 2 35.0 1
2 1 1 2 46.0 1
2 1 1 2 40.5 1
2 1 2 2 39.0 1
1 2 1 1 41.4 1
1 2 1 1 43.0 2
1 2 2 2 34.0 1
1 2 2 1 47.0 2
1 2 2 1 42.0 1
2 2 2 1 44.5 1
2 2 2 1 49.0 1
1 3 1 1 41.6 1
2 3 1 1 36.0 1
2 3 1 2 42.7 1
2 3 2 2 32.5 1
2 3 2 2 44.4 1
2 3 2 1 46.0 1
1 4 2 1 47.0 2
1 4 2 2 51.0 2
1 4 2 2 39.0 1
2 4 1 1 44.5 1
1 5 1 1 40.5 1
1 5 1 2 43.5 1
1 5 2 1 42.5 1
1 5 2 1 48.8 2
1 5 2 1 38.5 1
1 5 2 1 52.0 1
1 5 2 2 48.0 1
2 5 1 2 41.0 1
2 5 1 1 50.5 2
2 5 2 1 43.7 2
2 5 2 1 51.0 2
1 6 1 2 51.6 2
1 6 1 1 45.3 2
1 6 1 2 36.5 1
1 6 2 1 50.5 1
1 6 2 1 46.0 2
1 6 2 1 45.0 1
1 6 2 2 36.0 1
2 6 1 2 43.5 1
2 6 1 2 36.5 1
~~~~~

This file contains 6 columns.

1. Heifer origin
2. Sire ID
3. Season
4. Sex (1=male and 2=female)
5. BW (body weight)
6. CD (calving difficulty)

The pedigree file contains a sire, sire of the sire, and the maternal grand-sire.

~~~~~{language=text caption="pedigree_mr13b.txt"}
1 0 0
2 0 0
3 1 0
4 2 1
5 3 2
6 2 3
~~~~~

As the author mentions, we should use the corrected genetic parameters ($\mathbf{G}_{c}$) as shown on p.235.
The residual variance is 1.0 for CD and 20.0 for BW, and the residual covariance is 2.0527
because the residual correlation is 0.459. The parameter file is as follows. In
our case, we exchange the order of traits i.e. the trait 1 is CD and the trait 2 is BW.

~~~~~{language=blupf90 caption="param_mr13b.txt"}
DATAFILE
data_mr13b.txt
NUMBER_OF_TRAITS
2
NUMBER_OF_EFFECTS
4
OBSERVATION(S)
6 5
WEIGHT(S)

EFFECTS:      # l=H+M+E+s+e
1 1 2 cross   # origin
3 3 2 cross   # season
4 4 2 cross   # sex
2 2 6 cross   # sire
RANDOM_RESIDUAL VALUES
1.0000 2.0527
2.0527 20.000
RANDOM_GROUP
4
RANDOM_TYPE
add_sire
FILE
pedigree_mr13b.txt
(CO)VARIANCES
0.0300 0.0302
0.0302 0.7178
OPTION cat 2 0
OPTION fixed_var mean
~~~~~

Run THRGIBBS1F90 to draw 20,000 enough samples (saved in every 10 steps) and discard the
first 10,000 samples as burn-in. You can see the following solutions.

~~~~~{language=text caption="solutions"}
trait/effect level  solution        SD
   1   1         1         31.68328943          8.14595680
   2   1         1        169.99014434         40.28879171
   1   1         2         31.39648971          8.19080303
   2   1         2        170.59358068         40.25222186
   1   2         1          5.79121444         11.84634633
   2   2         1        -41.86423776         40.85833310
   1   2         2          5.81766544         11.83550515
   2   2         2        -40.61954962         40.79757133
   1   3         1        -37.80144849          6.85003521
   2   3         1        -84.56393688         42.77593912
   1   3         2        -38.97895373          6.85779916
   2   3         2        -87.77970197         42.74683265
   1   4         1         -0.07369834          0.17245459
   2   4         1         -0.26275007          0.75528469
   1   4         2          0.04477009          0.17053692
   2   4         2          0.10034538          0.80205603
   1   4         3         -0.04892810          0.16824589
   2   4         3         -0.19454123          0.80070554
   1   4         4          0.04296839          0.17226439
   2   4         4          0.16601219          0.80871849
   1   4         5          0.02241590          0.16946856
   2   4         5          0.33065415          0.78077812
   1   4         6          0.03339339          0.17470579
   2   4         6          0.16620116          0.78877094
~~~~~

The estimated values are close to the reference values (p.237). The small difference comes from a
limited number of observations. If you put zero-constraints on the fixed effects, you may obtain
more similar values as in the textbook.

Just for comparison, we show the results from CBLUP90THR with the same files shown above.
The estimated threshold is $-0.0198$ with 100 rounds.

~~~~~{language=text caption="solutions"}
trait/effect level  solution
  1  1       1     -1.0100
  2  1       1     54.1493
  1  1       2     -1.2648
  2  1       2     54.7189
  1  2       1      0.3162
  2  2       1    -16.9395
  1  2       2      0.3255
  2  2       2    -15.6956
  1  3       1      0.3685
  2  3       1      6.3608
  1  3       2     -0.7128
  2  3       2      3.1574
  1  4       1     -0.0601
  2  4       1     -0.2699
  1  4       2      0.0387
  2  4       2      0.0690
  1  4       3     -0.0499
  2  4       3     -0.2158
  1  4       4      0.0418
  2  4       4      0.1376
  1  4       5      0.0172
  2  4       5      0.2843
  1  4       6      0.0322
  2  4       6      0.1358
~~~~~
