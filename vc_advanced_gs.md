---
title: Variance component estimation
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Advanced features in Gibbs sampling programs
============================================

Heterogeneous residual variances
--------------------------------

GIBBS3F90 supports heterogeneous residual variances defined by a class. Here
we will demonstrate an analysis with the heterogeneity in residual variance.

### Files ###

We use the same data and pedigree file as before.

- [`simdata2.txt`](https://github.com/Masuday/data/blob/master/tutorial/simdata2.txt) : data file
- [`simped2.txt`](https://github.com/Masuday/data/blob/master/tutorial/simped2.txt) : pedigree file

The pedigree file contains 3 columns: animal, sire, and dam. The data file has 12 columns as
described below.

Column Item          type      description
------ ---------     -------   ----------------------------------
1      Animal ID     integer   Same as in pedigree (4641 animals)
2      Sire ID       integer   Same as in pedigree
3      Dam ID        integer   Same as in pedigree
4      Weight        real      Not used here
5      Mu            integer   All 1: not used here
6      Farm          integer   Class effect (155 levels)
7      Sex           integer   Class effect (2 levels)
8      Year          integer   Class effect (11 levels)
9      Obs. 1        real      Phenotype for trait 1
10     Obs. 2        real      Phenotype for trait 2
11     Obs. 3        real      Phenotype for trait 3
12     Obs. 4        real      Phenotype for trait 4
13     Covariate     real      Not used
14     Class         integer   Heterogeneous residual class

The 14th column contains the heterogeneous-residual-variance class (3 levels) which is used in
this section.

The parameter file has 1 option to define the heterogeneous residual class.

~~~~~{language=blupf90 caption="gibbs2.txt"}
DATAFILE
simdata2.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
4
OBSERVATION(S)
9
WEIGHT(S)
4
EFFECTS:
 6   155 cross
 7     2 cross
 8    11 cross
 1  4641 cross
RANDOM_RESIDUAL VALUES
100
RANDOM_GROUP
4
RANDOM_TYPE
add_animal
FILE
simped2.txt
(CO)VARIANCES
100
OPTION hetres_int 14 3
~~~~~

The option has 2 arguments.

- `OPTION hetres_int` = defines the heterogeneous residual class with 2 values: 1) the position
  of the class in the data file and 2) the maximum level in the class.

In this case, we specify that the 14th column has 3 levels.

With 20,000 samples (saved each 10 samples) with 10,000 burn-in, the following results can be
found.

~~~~~{language=output}
 ave G
   39.845
 SD G
	3.9917
 ave R
	72.313
 SD R
	3.9497
 ave R
   78.248
 SD R
   4.4558
 ave R
  80.646
 SD R
   4.3320
~~~~~

There are 3 `ave_R` (and `SD_R`) blocks. The first one corresponds to the variance in heterogeneous
level 1, the second line for level 2 and so on. Compare the above estimates to the results
from AIREMLF90 shown in the previous section.


Restart the sampling
--------------------

After the sampling, you would find more samples are needed. The Gibbs sampling programs
support to restart the sampling from the end point of the previous run. Any Gibbs samplers in
recent BLUPF90 programs support this feature.

When the Gibbs sampler finishes sampling, 4 files will be created. To continue the sampling, all the
files are required.

- `binary_final_solutions` = Posterior means and SDs for location parameters
- `last_solutions` = The last samples for location parameters
- `fort.99` = Values needed for DIC
- `gibbs_samples` = Sampled variance components

If you want to restart the sampling, you have to add an option to the parameter file.
It needs the number of samples drawn in the previous run. If you had 10000 samples, the option should be

~~~~~{language=blupf90}
OPTION cont 10000
~~~~~

where 10000 is the number of samples obtained previously. Run the Gibbs sampler with a parameter
file with the above option, and the program restarts the sampling (from 10001 in the example).


Extraction of solutions from binary final solutions
---------------------------------------------------

The file `binary_final_solutions` contains the posterior mean of a location parameter (i.e. a
solution of "fixed" or "random" effect). This file is saved as a non-text format. The following Fortran
program can extract the solutions and print them to a file `final_solutions.txt`. You can compile
the program using a Fortran compiler (like GFortran) and run it in a directory where the binary final solutions are. The output format
is equivalent to BLUPF90 with `OPTION sol_se`.

~~~~~{language=Fortran caption="\url{binsol_to_textsol.f90}"}
program binsol_to_textsol
	implicit none
	integer :: io, t, e, l
	double precision :: v, sol, se
	open(10, file='binary_final_solutions', form='unformatted', &
		status='old', iostat=io)
	if(io /= 0) stop
	open(20, file='final_solutions.txt')
	write(20,'(" trait / effect level solution               s.e.")')
	do
		read(10, iostat=io) t,e,l,sol,se
		if(io /= 0) exit
		write(20, '(2i4,i10,2f20.8)') t,e,l,sol,se
	end do
	close(10)
	close(20)
end program binsol_to_textsol
~~~~~

Output of POSTGIBBSF90
----------------------

The POSTGIBBSF90 program shows many diagnoses for the Gibbs samples. Here we just show
the basic ideas for the information.

- `MCE` = Monte Carlo error, corresponding to the ''standard error'' of the posterior mean of a
  parameter ($\hat{\mu}-\mu$).
- `Mean` = Posterior mean of a parameter.
- `HPD` = High probability density within 95%, close idea to ''95% confidence interval'' in frequentist approach.
- `Effective sample size` = Number of samples after deducting auto-correlation among
  samples.
- `Median` = Posterior median of a parameter.
- `Mode` = Posterior mode of a parameter; just an approximation.
- `Independent chain size`
- `PSD` = Posterior standard deviation of a parameter.
- `Mean` = the same as above.
- `PSD Interval (95%)` = Lower and upper bounds of Mean $\pm$ 1.96PSD.
- Geweke diagnostic = Convergence diagnosis; could be converged if this is $< 1.0$ (according
  to the official manual, this is almost useless because this is $< 1.0$ in almost all cases).
- `Autocorrelations` = Lag-correlations with lag 1, 10 and 50; calculated for the saved samples.
- `Independent # batches` = The effective number of blocks after deducting the auto-correlation
  among samples.
