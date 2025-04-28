---
title: Variance component estimation
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Gibbs sampling and post-Gibbs analysis
======================================

Gibbs sampling software
-----------------------

The BLUPF90 family now provides a single program, GIBBSF90+, for conducting Gibbs sampling for linear mixed models and threashold models. This software is currently recommended for all users. However, several Gibbs sampling programs were previously available in the BLUPF90 family. The following description is provided for reference.

In the past, users were encouraged to use GIBBS2F90 or THRGIBBS1F90 for linear mixed models. THRGIBBS1F90 supported both threshold and linear models and was typically faster than GIBBS2F90, especially for large datasets. GIBBS3F90 was useful in cases where heterogeneous residual variances by class were assumed. These programs differed in their capabilities and performance.

**Notice**: This tutorial was originally written using the older software, and THRGIBBS1F90 is used throughout the examples, even though threshold models are not applied. If you are using GIBBSF90+, you can simply replace THRGIBBS1F90 with GIBBSF90+ without any additional options.

Gibbs sampling is totally different from REML. We do not deal with the theoretical background of this technique here; see Sorensen and Gianola (2002) or Misztal (2008) for details. Roughly speaking, Gibbs sampling is a process to draw the posterior distribution out of the samples generated as random numbers based on information available at a specific point. In one round, the Gibbs sampler solves the mixed model equations with the current variance components and add a small random number (noise) to each solution. Then the sampler generates a covariance estimate as a random number based on the solutions. The samples of solutions and variance components in each round are not informative. Having many samples from many rounds repeated, we can figure the posterior distribution of a variance component as a histogram out of the samples. You can calculate the average of samples (posterior mean) as a point estimator of a variance component. You can also calculate the standard deviation of samples (posterior SD), which is corresponding to the standard error in a frequentist approach (for example, REML).

THRGIBBS1F90 assumes, by default, noninformative (also known as vague or flat) priors for location parameters as well as variance components. You can change the degree of belief in the prior distribution for each variance component using an option in the parameter file.

Gibbs sampling needs post-Gibbs analyses. This can be done with a separate software POSTGIBBSF90, or with manual processing by the user. The basic pipeline of Gibbs sampling analysis is that

1. use THRGIBBSF90 to generate samples for variance components and
2. use POSTGIBBSF90 to summarize the samples.

Both programs accept the same parameter file as BLUPF90 programs but ask you some additional questions to control the Gibbs sampler.


Preparation
-----------

In this section, we will use the same simulated files which have been already introduced in the previous section for REML.

- [`simdata.txt`](https://github.com/Masuday/data/blob/master/tutorial/simdata.txt) : data file
- [`simped.txt`](https://github.com/Masuday/data/blob/master/tutorial/simped.txt) : pedigree file

The parameter file is the same shown in the previous section. Here we put a different name on this file.

~~~~~{language=blupf90 caption="gibbs1.txt"}
DATAFILE
simdata.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
4
OBSERVATION(S)
9
WEIGHT(S)
4
EFFECTS:
 6     155 cross
 7     2 cross
 8     11 cross
 1     4641 cross
RANDOM_RESIDUAL VALUES
100
RANDOM_GROUP
4
RANDOM_TYPE
add_animal
FILE
simped.txt
(CO)VARIANCES
100
~~~~~

The variance components in the parameter file will be used as initial values but the impact of the values on the results will be small. So you can put any values on the parameter file.


Sampling strategy
-----------------

Invoking THRGIBBSF90, the program asks you the name of the parameter file.

~~~~~{language=output}
 * Start thrgibbs1f90 ........04-03-2016            12 h 12 m 36 s 173
 name of parameter file?
~~~~~

After typing the name, then the program will ask you another question.

~~~~~{language=output}
 number of samples and length of burn-in
~~~~~

You should input 2 integer numbers here.

- The total number of samples to be generated.
- The number of burn-in; the first samples to be discarded.

The 2 numbers should be separated with space or newline (that is Enter key). The number of burn-in should be smaller than the total number of samples. If you are not sure about the number of burn-in, just put 0. After the sampling, you can manually discard any number of burn-in samples using a tool, POSTGIBBSf90. If you generate 5,000 samples and discard the first 1,000 samples as burn-in, you can key-in as follows (no commas are allowed).

~~~~~{language=shell}
5000 1000
~~~~~

You will be asked one more question.

~~~~~{language=output}
 Give n to store every n-th sample ? (1 means store all samples )
~~~~~

You should put one integer number here.

- The size of the interval to save the samples.

For example, if you want to save the sample every 10 rounds, type 10 here.

~~~~~{language=shell}
 10
~~~~~

If you want to save all the samples, type `1` instead. After this, the program starts sampling.

What is the appropriate number of sampling? What is the best interval? The answer depends on the model and data. We will consider this question later in this section.


Constraints on variance components
----------------------------------

As explained previously in the AI REML section, the program supports to force some variance components to be 0. When the initial variance component is 0, this component never changes throughout the iterations. See the previous section to see the example of the initial values with 0.

There is the difference between AIREMLF90 and THRGIBBS1F90 (and the other Gibbs samplers) on the constraints. Whereas AIREMLF90 never computes the estimates of the constraint variance components, the Gibbs samplers actually calculate all variance components, and then, replace the target parameters with 0. It means that the Gibbs samplers have the same computing cost on the constraints as the non-constraint case.

The same as AIREMLF90, THRGIBBS1F90 tries to fix the estimated variance components which are out of the parameter space. During this process, some variances may become 0. Again, the same as those used AIREMLF90, once it happens, such variances may never come back to non-zero values simply because no information is available to estimate the variance parameters. If you see such accidental zeros during the iterations, it implies that your model is suboptimal or, the amount of data is not enough to estimate the variance components.

Results shown on screen
-----------------------

### Intermediate results ###

During the sampling, the program always prints the sampled variances in each round.

~~~~~{language=output}
		  5000   rounds
G
	 36.27
R
	 62.00
~~~~~

### Final posterior mean and SD ###

The program actually calculates the sampled solutions in each round as well. At the end of sampling, the program shows several statistics on screen. You do not always need all the information. We break it down here.

~~~~~{language=output}
elapsed time per iteration     6.7236428 E -03 : total                  33.61821
* End of iteration04 -03 -2016 12 h 27 m 05 s 101
ave G
  39.03
SD G
  3.579
ave R
  62.58
SD R
  2.506
~~~~~

- `ave G and SD G`: Posterior mean and SD for $\sigma_u^2$. Average and standard deviation of saved samples after removing burn-in.
- `ave R and SD R`: Posterior mean and SD for $\sigma_e^2$. Average and standard deviation of saved samples after removing burn-in.


### Final status of sampling ###

These are not essential for a regular analysis.

~~~~~{language=output}
* Last seeds = 2101474043 1031647242
* Number of samples kept =          4000
solutions stored in binary file : " last_solutions "
~~~~~

- `Last seeds`: Seeds of random number generator. Usually, the values are not crucial.
- `Number of samples kept`: The total number of samples after burn-in.
- `solutions stored in a binary file: "last_solutions"`: The last sampled solutions are stored in `last_solutions`. Usually, the file is not essential.


### DIC and related information ###

DIC (Deviance Information Criterion) can be used to compare 2 or more models like AIC (smaller is better). In each round, the program calculates partial information to form the DIC. In a general notation, we can write a likelihood function as $\log L(\theta)$ with parameters $\theta$. In above mode, we assume that N is the number of observations and $\hat{\sigma}_{e[k]}^2$ (that is $\hat{\theta}_k$) is a sampled residual variance in round $k$ after burn-in, a deviance $D_k$ in round $k$ is defined as
$$
D_k = -2\log L(\hat{\theta}_k) = -2\sum_{i=1}^{N}\left[C+\frac{\hat{e}_i^2}{\hat{\sigma}_{e[k]}^2}\right]
$$
where $C$ is $\log(2\pi\hat{\sigma}_{e[k]}^2)$ and $\hat{e}_i$ s a observed residual for observation $i$ (that is $y - \hat{y}$ : observation minus sampled solutions). With $m$ samples after burn-in, $\bar{D}$, an estimate of the expectation of $D$, is defined as
$$
\bar{D}=\frac{\sum_{k=1}^{m}D_k}{m}
$$
Similar statistics are also calculated with posterior mean of $\sigma_e^2$. We calculate the posterior deviance $D(\bar{\theta})$ using above formula for $D_k$ except $\hat{\sigma}_{e[k]}^2$ (that is $\hat{\theta}_k$) is replaced with its posterior mean $\hat{\sigma}_{e}^2$ that is $\hat{\theta}$ as follows
$$
D(\bar{\theta})=-2\log L(\hat{\theta})=-2\sum_{i=1}^{N}\left[C+\frac{\hat{e}_i^2}{\hat{\sigma}_{e}^2}\right]
$$
These statistics are calculated using the samples stored after burn-in. THRGIBBSF90 prints the following quantity as DIC.
$$
\mathrm{DIC}=2\bar{D}-D(\bar{\theta})
$$
THRGIBBS1F90 saves every $D_k$ to a file `fort.99`.

The output is corresponding to the above formulas.

~~~~~{language=output}
****************************************
***************** DIC ******************
****************************************
detR      62.5820466970185
# stored samples                400
D-bar     32364.1379063698
D(theta-bar)  30968.7777134920
DIC = 2*D-bar - D (theta-bar) =   33759.4980992475
Effective number of parameters =    1395.36019287775
solutions stored in file : "binary_final_solutions"
* End program04-03-2016 12 h 27 m 06 s 001
~~~~~

- `detR`: Determinant of posterior mean of the residual covariance matrix ($|\mathbf{R}_{0}|$ in the general case and $|\sigma_e^2|$ in this case).
- `# stored samples`: The in geneal number of samples saved in a file ($m$ above).
- `D-bar`: $\bar{D}$
- `D(theta-bar)`: $D(\bar{\theta})$
- `DIC = 2*D-bar - D(theta-bar)`: $2\bar{D}-D(\bar{\theta})$
- `Effective number of parameters`: $\bar{D} - D(\bar{\theta})$
- `solutions stored in file: "binary_final_solutions"`: posterior means for sampled solutions after burn-in.

The estimated genetic variance is $\hat{\sigma}_u^2 = 39.03 (\pm 3.579)$ and the
estimated residual variance is $\hat{\sigma}_e^2 = 62.58 (\pm 2.506)$. If you believe the numbers of samples and burn-in
are appropriate, you can use the above posterior mean and SD as the final results. Otherwise, and in most cases, you should run POSTGIBBSF90 to perform the post-Gibbs analyses to confirm the numbers of samples and burn-in were enough to draw posterior statistics for variance parameters.


Generated files
---------------

THRGIBBSF90 generates several files including the following.

- `gibbs_samples`: Samples of variance components in specific rounds after burn-in.
- `fort.99`: Deviance in specific rounds after burn-in.
- `last_solutions`: The last sampled solutions saved in a binary form.
- `binary_final_solutions`: Posterior means for sampled solutions from specific rounds after burn-in saved in binary form.

The samples and calculated statistics are based on samples in every $n$ rounds after burn-in, where $n$ is an interval which you type-in at the beginning of the program.

The file `gibbs_samples` will be used by POSTGIBBSF90 to run post-Gibbs analyses. The number of samples stored in this file depends on your initial answers. For example, using 5,000 samples with 1,000 burn-in and 10 sample intervals, the file will have 400 samples that is $(5000 - 1000)/10$. The second file `fort.99` is optional and it will be used in the post-Gibbs analyses. The `last_solutions` file is useful to continue the analysis from the last round; you do not usually have to see the inside of this file. The last file `binary_final_solutions` contains samples of solutions for "fixed" and "random" effects. You may want to see the solutions but it is not a text file. In the next section, we will consider the advanced techniques including the extraction of solutions from this file.


Post Gibbs analyses
-------------------

### Invoking POSTGIBBSF90 ###

POSTGIBBSF90 performs post-Gibbs analyses reading the parameter file, `gibbs_samples`, and `fort.99`. You have to run POSTGIBBSF90 in a directory where you have these files. Invoking the program, it prints the following message.

~~~~~{language=output}
 name of parameter file?
~~~~~

Type in the name of the parameter file used in this analysis. Then the program checks if `gibbs_samples` was really generated from the parameter file. If success, you will see the information about the total number of saved samples.

~~~~~{language=output}
 POST-GIBBSF90 3.06
  # parameters in gibbs_samples =                          2
 Read           400 samples from round                         1010   to       5000
~~~~~

Then, POSTGIBBSF90 asks you another question.

~~~~~{language=output}
 Burn-in?
~~~~~

It is a tricky question. You should *not* input the same number what you typed at the beginning of THRSIBBS1F90. The burn-in samples were already discarded. This question asks you the number of *additional* samples to discard as burn-in. The answer is

- `0` if you do not discard any more samples as burn-in,
- Or, any integer number if you need to discard additional samples as burn-in.

After this, you will be asked the last question.

~~~~~{language=output}
 Give n to read every n-th sample? (1 means read all samples)
~~~~~

Before typing `1` to keep all the samples, please wait for a moment. This question asks you the number of intervals (thinnings) that you entered when you ran THRGIBBSf90. If you want to keep all the samples you have drawn, you have to put the same number as you put before. Or, you can input a multiple of the original number. For example, in this case, you can input 10, 20, 30 and so on, because the original interval was 10. If you type an inappropriate number, the program will stop with a suspicious message.

Post statistics
---------------

We will see the following table with many statistics when we input `0` as burn-in and `10` as steps in our example.

~~~~~{language=widetext}
# samples after burn-in =         400
# samples after burn-in used =         400

                          ********   Monte Carlo Error by Time Series   ********
 Pos. eff1 eff2 trt1 trt2        MCE        Mean             HPD             Effective       Median        Mode      Independent
                                                        Interval (95%)       sample size                             chain size
   1    4    4    1    1      0.36091       39.035       32.030       45.270         98.1         39.060       39.175            6
   2    0    0    1    1      0.19923       62.582       57.640       67.440        157.8         62.640       63.362            4

                          ********   Posterior Standard Deviation   ********
 Pos. eff1 eff2 trt1 trt2        PSD        Mean             PSD             Geweke            Autocorrelations      Independent
                                                        Interval (95%)       diagnostic   lag: 1       10       50    # batches
   1    4    4    1    1       3.5788       39.035       32.020       46.049        -0.09      0.660   -0.076    0.017        66
   2    0    0    1    1       2.5062       62.582       57.670       67.494         0.09      0.406   -0.023    0.070       100
~~~~~

The output has 2 main tables. Each table contains statistics for each variance components. Variance components can be identified with the columns `Pos. eff1 eff2 trt1 trt2`.

- `Pos.` is the position index of a parameter.
- `eff1` and `eff2` are the effects in which the variance defined. Without maternal genetic effect or random regressions, `eff1` equals `eff2`.
- `trt1` and `trt2` are corresponding traits. In a single-trait model, `trt1` equals `trt2`.

In this case, we have 2 variances; one ($\sigma_{u}^{2}$) is the genetic variance defined as the 4th effect and the other one is the residual variance ($\sigma_e^2$). This is from a single-trait model, so the trait number should be 1. Finally we find the position 1 is for $\sigma_u^2$ and the position 2 is for $\sigma_e^2$.

As you see, this program displays plenty of information. We just pick essential numbers only. The rest of the items will be covered with the next section.

- `Mean`: Posterior mean.
- `HPD Interval (95%)`: High posterior density interval with 95%.
- `Median`: Posterior median.
- `Mode`: Posterior mode. It would provide a better estimate than posterior mean if the posterior distribution is highly skewed.
- `Independent chain size`: The "effective" number of samples after adjusting autocorrelations among samples.
- `PSD`: Posterior standard deviation.
- `Autocolletations`: Lag-correlation between 2 samples with a specific interval.

This table shows several point-estimates including posterior mean, median, and mode. A reasonable estimate depends on its skewness of the posterior distribution. If the distribution is highly skewed and the mean is apart from the mode, the posterior mode or median could be a better choice. Note that the mode is just approximated from 50 interval classes.

High posterior density interval (HPD95) is often cited statistics to evaluate the accuracy of the parameters. This is a kind of interval estimates of a parameter. The values are the lower and upper bounds by cutting off the sorted samples at the top 2.5% largest and the bottom 2.5% smallest values.

You can evaluate a sufficient interval for samples to be saved using Independent chain size and Autocorrelations. Two adjacent samples are usually highly correlated because the next sample is drawn based on the current one. When the correlation is still high between distant samples, the dependency-level is also high and the absolute values of the samples should be very similar. It simply means the samples do not provide much information about the posterior distribution. The autocorrelation indicates how many intervals between samples we need to achieve the zero-correlation. The independent chain size corresponds to the number of independent samples that can be seen as independent. If the independent chain size is 3, the statistics (that is posterior mean and SD) are equivalently calculated using only 3 independent samples, and obviously, this is too small. This indicates
whether you need more samples or not.


### Time-series plot and histogram ###

After showing the above table, the program waits for your key-in with the following message.

~~~~~{language=output}
 Choose a graph for samples (= 1) or histogram (= 2); or exit (= 0)
~~~~~

POSTGIBBSF90 can draw a time-series plot or histogram of samples. It uses external software `Gnuplot` to show the graph. So, to obtain the plot, you have to have Gnuplot in your system. You can type `1` to draw time-series plot, or `2` to draw the histogram for samples. Type `0` to quit the program.

The time series plot visually indicates whether the length of burn-in or total sampling is enough or not. If the initial samples seem to still keep the initial values, you would need more burn-in. If the samples stayed longer in a specific value-range, the posterior mean does not represent the entire samples, and you should draw more samples. The histogram provides a visual image of the posterior distribution. Usually, it is a one-peak distribution but skewed (with long right tail) more or less. If your distribution has 2 peaks or very flat, you should check the parameter file for human error,
or draw more samples.


Output files from POSTGIBBSF90
------------------------------

POSTGIBBSF90 creates 7 files which are derived from the post-Gibbs statistics described above.

- `postout`: The same content which is shown on screen.
- `postind`: Relation of a position index to a variance component.
- `postmean`: Posterior means shown in a user-friendly format.
- `postmeanCorr`: Posterior means for correlations shown in a user-friendly format.
- `postsd`: Posterior standard deviations.
- `fort.998`: $\log L$ calculated from the file `fort.99`
- `postgibbs_samples`: The final samples after removing burn-in and applying thinning.

The `postout` file contains precise statistics from the post-Gibbs analysis. You can check the position index with `postind`. A series of files contains posterior means and SDs for variance components. The file `fort.998` contains $\log L$ needed for the computation of Bayes factor.

The file `postgibbs_samples` is useful especially if you calculate other statistics by yourself. It contains samples after burn-in. The content looks like the following.

~~~~~{language=text}
1    1010    2   35.60       64.26
2    1020    2   36.98       63.53
3    1030    2   30.92       66.49
4    1040    2   34.93       65.60
5    1050    2   37.38       63.26
~~~~~

The meaning of each column is:

- Column 1: the sequential number for saved samples.
- Column 2: the actual round in which each sample was drawn.
- Column 3: the number of parameters.
- Column 4 or later: actual samples ordered by the position index.


Post-Gibbs Analysis for arbitrary function of variance components
-----------------------------------------------------------------

A frequently-asked question is how to compute the posterior distribution of the heritability or the genetic correlation, a function of variance components. There are two ways to perform the post-Gibbs analysis on it.

### Using the file postgibbs samples

The first option is simpler if you are familiar with scripting. From the file `postgibbs_samples`, you can easily draw a graph and calculate additional statistics. For instance, you may compute, at each sample, the _sample_ of the heritability as a function of the samples of the variance components. The code in R would be something like this.


~~~r
a=read.table("postgibbs_samples",header=FALSE)
# tell what each thing is
colnames(a)=c("i","iter","varu","vare")
a$h2=a$varu/(a$varu+a$vare)
hist(a$h2)
~~~

In this way, you describe the posterior distribution of $h^2$ from the samples of variance components. This procedure can be done for _any_ function of the variance components, for instance, genetic correlations. More sophisticated analysis can be done with R package 'boa'.

### Using an option in the parameter file

The second option is to use the option `se_covar_function` in a parameter file. The user can define the function of variance components in the option line, and POSTGIBBSF90 calculates a sample of the function in each sampling round. The program displays all pos-Gibbs statistics on the screen as the standard variance components.

The usage of this option was explained in the previous section for AIREMLF90. See the section for details.


Remarks
-------

You must not run 2 Gibbs-sampling programs in the same directory at the same time. One program will overwrite `gibbs_samples` generated by the other programs. If you want to share the data and pedigree files in multiple jobs, make a separate directory (or folder) and create a copy of the files (or, make a symbolic link to the file)

There are several options for THRGIBBSF90. For example, one is for continuous sampling with already finished results (starting sampling from the last round in the previous run). Another one can put the degree of belief for prior information. Please see the manual for details.

There are many Gibbs sampling programs in BLUPF90 family. The difference is in their implementation.

- GIBBSF90: initial program; no longer distributed
- GIBBS1F90: much faster in multiple-trait models
- GIBBS2F90: faster in convergence for models with correlated effects (for example maternal model or random regression models).
- GIBBS3F90: derived from GIBBS2; supporting heterogeneous residual variances; a little bit slower than GIBBS2.
- THRGIBBS1F90: derived from GIBBS2; supporting threshold models; supporting huge dense matrices; faster than GIBBS2 especially for large data set; required more memory than GIBBS2.
- THRGIBBS3F90: derived from THRGIBBS1; supporting heterogeneous residual variances.

Actually, recent improvements were done for GIBBS2F90 and THRGIBBS1F90. So we recommend a user to use these two programs if you are not interested in heterogeneous residual variances.


Summary
-------

- GIBBSF90+ is recommended. Previously, THRGIBBS1F90 or GIBBS2F90 was recommended.
- THRGIBBS1F90 can perform Gibbs sampling both with the regular linear mixed models and the threshold models.
- THRGIBBS1F90 needs the numbers of total samples and burn-ins, and the interval for samples to be saved.
- THRGIBBS1F90 saves the samples to the file `gibbs_samples`.
- POSTGIBBSF90 reads `gibbs_samples` and calculates post-Gibbs statistics.
- POSTGIBBSF90 creates many files containing the statistics.
- You can check whether the initial settings are suitable or not from the output.
- You can conduct post-analyses on a function of variance components with the file `postgibbs_samples` by yourself, or using the option `se_covar_function` by POSTGIBBSF90.
- If the initial variance component is 0, it will be fixed to be 0 throughout the iterations.
