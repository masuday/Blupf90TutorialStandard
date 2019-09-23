---
title: Practical genomic analysis
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

GWAS using the ssGBLUP framework
================================

The single-step GBLUP methodology has been extended to be capable of genome-wide association
study (GWAS). This is an iterative procedure with 2 steps: 1) prediction of GEBV with ssGBLUP
and 2) prediction of SNP marker effects based on the GEBV. Here we call this method ssGWAS.
The detailed algorithm was described by Wang et al. (2012).

Algorithm
---------

To describe the algorithm of ssGWAS, we use the notation made by Wang et al. (2012).
The notation may be different from the ones used in the previous chapters.
Do not be confused with the same symbols as before.

We assume $\mathbf{a}$ is a vector for breeding values for genotyped animals and $\mathbf{u}$ is a vector for SNP
marker effects. One is related to another with the following equation.
$$
\mathbf{a}=\mathbf{Zu}
$$
The variances of them can be written as
$$
\mathrm{var}(\mathbf{a}) = \mathbf{G}\sigma_a^2 \quad\text{and}\quad \mathrm{var}(\mathbf{Zu}) = \mathbf{ZDZ}'\sigma_u^2
$$
where $\mathbf{D}$ is a diagonal matrix of weights accounting for variances of SNP markers. This matrix is
usually assumed to be $\mathbf{I}$ in the regular ssGBLUP. Above 2 variances are identical, so we can derive
$$
\mathrm{var}(\mathbf{a}) = \mathrm{var}(\mathbf{Zu}) = \mathbf{G}\sigma_a^2 = \mathbf{ZDZ}'\sigma_u^2
$$
and this formula implies
$$
\mathbf{G}=\mathbf{ZDZ}'\frac{\sigma_u^2}{\sigma_a^2}=\mathbf{ZDZ}'\lambda
$$
where $\lambda=\sigma_u^2/\sigma_a^2$. According to the definition of $\mathbf{G}$, the variance ratio can be
$$
\lambda=\frac{\sigma_u^2}{\sigma_a^2}=\frac{1}{2\sum_j p_j(1-p_j)}.
$$
The prediction of breeding values $\hat{\mathbf{a}}$ is calculated with ssGBLUP. The prediction of SNP effects $\hat{\mathbf{u}}$ is also calculated with the best prediction.
$$
\begin{aligned}
\hat{\mathbf{u}} &= \mathrm{cov}(\mathbf{u},\mathbf{a}')\left[\mathrm{var}(\mathbf{a})\right]^{-1}\hat{\mathbf{a}}\\
 &= \lambda\mathbf{DZ}'\mathbf{G}^{-1}\hat{\mathbf{a}}\\
 &=	\mathbf{DZ}'(\mathbf{ZDZ}')^{-1}\hat{\mathbf{a}}
\end{aligned}
$$
With the prediction of an SNP effect, we can give weights to markers based on SNP solutions. The current default weight is as
in Wang et al. (2012):

$$
w_i = 2 p_i q_i \hat{u}_i^2.
$$

This may be used as a weight in $\mathbf{D}=\mathrm{diag}(w_i)$ after its scaling (see Wang et al., 2012). We restart the whole process
with this new $\mathbf{D}$. We can repeat the procedures until reasonable results are obtained.
However, this weighting scheme is not the most accurate and leads to unstable iterates. A well-tested
method for weights is VanRaden's "nonlinearA" (2008), which likely becomes the default.
$$
w_i = 1.125^{ \frac{|\hat{u}_i|}{\sqrt{var\hat{u}}} -2}
$$


The SNP effects can be used as the indirect prediction of GEBV based on $\mathbf{a} = \mathbf{Zu}$. At the end of
this section, we will demonstrate this approach.

Programs
--------

We will use several programs to perform ssGWAS.

   1. RENUMF90: general preparation of data set.
   2. PREGSF90: quality control and creation of cleaned genotypes.
   3. BLUPF90: prediction of $\mathbf{a}$ with a weighted $\mathbf{G}$.
   4. POSTGSF90: prediction of $\mathbf{u}$ and a new weight $\mathbf{D}$.
   5. PREDF90 (Optional): computation of GEBV based on the predicted SNP effects and genotypes

The first 2 programs are needed only once in the very first step. If your data is well prepared, you
just run BLUPF90 and POSTGSF90 repeatedly. In this case, it is easier to understand for a user to
directly use BLUPF90 to create $\mathbf{G}$ and calculate the solutions of GEBV in the same program.

Numerical example
-----------------

### Files ###

We will use the similar numerical-examples used in the summer course at the UGA in 2012.
I made some corrections on the files.
The modified package is available at the author's repository.

   - `lab_gwas_mod2019.zip` at <https://github.com/masuday/data/blob/master/tutorial/examples/genomic_analysis/>

Download the zip package and extract it to your computer.
It has several files as follows.

- `phenotypes.txt` = observation data file
- `pedigree` = pedigree file
- `marker.geno.clean` = marker file
- `chrmap.txt` = chromosome map file
- `w` = the default weight file
- `renum.par` = instruction file for RENUMF90

The package also has two Bash scripts to automate the process in renumbering and ssGWAS.
I do not explain how it works -- you can try the following scripts after you finish reading all the content in the following sections.

- `run_renum.sh` = for renumbering, and for generating the parameter files
- `run_ssgwas.sh` = for iterative ssGWAS with BLUPF90 and POSTGSF90

The files have been created on Linux (or macOS), and some Windows editors may not show the content correctly because of the "return" code.
You can see some more files in the directory, but such files will not be used in this section.
We will start with RENUMF90 to prepare the data set.

Preparation
-----------

First, we run RENUMF90 to generate the required files. After renumbering, we can see `renf90.par`,
a template parameter file. We make 2 copies of this template; one is for BLUPF90 and another one
is for POSTGSF90. Here, we use `param_ssgwas1a.txt` as the parameter file for BLUPF90 and
`param_ssgwas1b.txt` for POSTGSF90. The parameter files are availabe at the author's Github repository:
<https://github.com/masuday/data/tree/master/tutorial>.

BLUPF90 will generate $\mathbf{G}$ with weights, supplied as a weight file (see the previous section). The
zip package contains a weight file (`w`), and the option in the parameter file refers to the weight file. Following is the whole
parameter file for BLUPF90.

~~~~~{language=blupf90 caption="param_ssgwas1a.txt"}
#
# This is for BLUPF90
#
DATAFILE
renf90.dat
NUMBER_OF_TRAITS
		  1
NUMBER_OF_EFFECTS
		  2
OBSERVATION(S)
 1
WEIGHT(S)

EFFECTS:
 2      1 cross
 3  15800 cross
RANDOM_RESIDUAL VALUES
0.50000
RANDOM_GROUP
	2
RANDOM_TYPE
add_animal
FILE
renadd02.ped
(CO)VARIANCES
0.50000
OPTION SNP_file marker.geno.clean
OPTION saveGInverse
OPTION weightedG w
~~~~~

POSTGSF90 needs to read $\mathbf{G}^{-1}$ generated with BLUPF90. It also needs a chromosome map
file because the program will predict each SNP effect. The following is the complete parameter file
for POSTGSF90.

~~~~~{language=blupf90 caption="param_ssgwas1b.txt"}
#
# This is for POSTGSF90
#
DATAFILE
renf90.dat
NUMBER_OF_TRAITS
		   1
NUMBER_OF_EFFECTS
		   2
OBSERVATION(S)
 1
WEIGHT(S)

EFFECTS:
2      1 cross
3  15800 cross
RANDOM_RESIDUAL VALUES
0.50000
RANDOM_GROUP
	2
RANDOM_TYPE
add_animal
FILE
renadd02.ped
(CO)VARIANCES
0.50000
OPTION SNP_file marker.geno.clean
OPTION readGInverse
OPTION weightedG w
OPTION chrinfo chrmap.txt
~~~~~

### Iterative run and Manhattan plot ###

First, we run BLUPF90 with the parameter file `param_ssgwas1a.txt` following by running POSTGSF90
with the different parameter file `param_ssgwas1b.txt`. POSTGSF90 creates several files.

- `snp_sol` = Solution for SNP markers (i.e. $\mathbf{u}$). It has 7 columns.

     1. Trait
     2. Effect
     3. SNP number
     4. Chromosome
     5. Position
     6. SNP solution ($\hat{u}_i$) . From this column you can compute weights yourself.
     7. Weight ($d_i$) (see the official manual for what is the default method to get this value)


- `chrsnp` = Used in the Manhattan plot. It has 6 columns.

     1. Trait
     2. Effect
     3. % of variance explained by adjacent SNPs
     4. SNP number
     5. Chromosome
     6. Position

<!--
By default, POSTGSF90 does not create the `dgv` file.
The option `OPTION snp_effect_dgv` will create this file.

- `dgv` = Direct genomic values for genotyped animal. It has 5 columns.

     1. Trait
     2. Effect
     3. Animal ID
     4. DGV (direct genomic value) = $-\sum_{j\neq i}g^{ij}\hat{u}_{j}\Big/g^{ii}$; see Lourenco et al. (2015).
     5. PP (pedigree prediction) = $-\sum_{j\neq i}a_{22}^{ij}\hat{u}_{j}\Big/a_{22}^{ii}$; see Lourenco et al. (2015).
-->

- `snp_pred` = Used in the program to predict GEBV based on the SNP effects. A user doesn't
        have to know the exact format.


- `Sft1e2.gnuplot` and `Sft1e2.R` = Scripts to draw Manhattan plots with Gnuplot and R.
        Each script reads `chrsnp`.

What we need in the next round is the 7th column in `snp_sol`. This column should be extracted
and saved in the file `w` (this file is updated with new values). Once `w` is updated, rerun BLUPF90
and POSTGSF90. Repeat the process enough times. In this example, we just repeat 3 times.

This iterative process can be automated using a script. In Linux and macOS X, a bash shell script
is common to use. In Windows, a traditional batch-file is useful but some free software is needed to
extract the 7th column of the file. We don't explain such techniques here. You can see bash scripts in
the same directory as the data files in the zip package. The scripts will tell you how to run the programs repeatedly.

After 3 rounds, we can draw the Manhattan plot with the script. Using R, you will see the
following figure. According to this graph, there is a large SNP effect on chromosome 1.

We arbitrarily decide to repeat the process 3 times here.
Although 2 or 3 iterations can be good enough, the optimal number of iterations for prediction should be different by data.
In some cases, only the first round (no iterations) may produce the best result.
Please find a suitable method for your data by yourself.

### Indirect prediction of GEBV based on SNP effects ###

Once you find the SNP effects, another program PREDF90 can calculate indirect GEBV from the
SNP effects based on the equation $\mathbf{\hat{a}} = \mathbf{Z\hat{u}}$. This program reads the marker file and `snp_pred`,
generated with POSTGSF90. Run the program, and see the following message.

~~~~~{language=output}
 name of genotype file?
~~~~~

Different from other software, it needs the name of the marker file. Type the name of genotype file
in here. The program immediately calculates the indirect GEBV for genotyped animals.

PREDF90 creates a file of SNP predictions. It has 3 columns.

   1. Animal ID
   2. Call rate
   3. Indirect prediction of GEBV (based on $\mathbf{\hat{a}} = \mathbf{Z\hat{u}}$).


In other words, the prediction for an animal is the sum, according to its genotypes, of the estimated SNP effects, as
estimated in the overall ssGBLUP analyses.
This approach is useful especially in a case where there are many young genotyped animals but
many of them shouldn't be included in ssGBLUP analysis because these are _interim_ analysis between two full
genomic evaluations or for other reasons.
