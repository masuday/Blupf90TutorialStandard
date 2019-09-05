---
title: Introduction
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Differences with other software
===============================

It is better for a new user to know the differences between BLUPF90 programs and other software which you are familiar with.
We briefly introduce the differences for your understanding.

General differences
-------------------

### R and SAS ###

* BLUPF90 can handle really large data sets.
  BLUPF90 is most likely faster than R and SAS.
* BLUPF90 is not interactive software.
  A user should prepare a *parameter file* that describes the details of analysis (names of files, model, genetic parameters and options).
  The program simply reads the file and run a defined task.
* BLUPF90 is not a scripting language.
  The programs don't provide any features for data manipulations.
  All the editing should be done before invoking the program.
  The data file must contain all the information needed for the analysis.
* BLUPF90 can only read text files.
  Headers (or comments) are not allowed in the data or pedigree files.
  The items in a text file should be separated from one or more spaces.
* BLUPF90 shows the results on screen as well as text files.
* BLUPF90 accepts only integer values as levels of effects in the data and pedigree file, and real values as covariables and trait values.
  Alphabets or symbols should be replaced with integer code before the analysis.
  RENUMF90 helps this process.
* BLUPF90 has no window system.
  It is like a `Rscript`, a command line utility.
  Basically, the program runs on Command Prompt (or so-called 'DOS' window) in Windows, Terminal on macOS and various shell on Linux.
* BLUPF90 has no functions to perform hypothetical tests.
  Some programs show $-2\log L$ or similar statistics so you can manually perform a likelihood ratio test.

### ASREML ###

* BLUPF90 is free for research and academic purposes but has limited support from the development team.
* BLUPF90 supports Gibbs sampling.
* BLUPF90 covers linear mixed models and the threshold models.
  It doesn't have procedures for generalized linear models.
* BLUPF90 uses simple text format for data and pedigree files.
  No headers, no comments, no alphabets or symbols are allowed in the files.
  The edited data should be prepared by a user before the analysis.
* BLUPF90 has no comprehensive directives for the analysis.
  The parameter file contains minimal information including file names, model, variance components and options.
  BLUPF90 does not use labels to refer to the effects in the model description.
* BLUPF90 generates minimal output.


### WOMBAT ###

* In the data file for BLUPF90, observations for an animal taken at the same time should be basically listed in the same line.
  Multiple observations should be saved in the same line.
  The case, where observations from the same animals are stored in 2 or more lines, will be allowed only in repeated records or a special multiple-trait model (e.g. G-by-E analysis).
  In WOMBAT, each trait is on a different line.
* BLUPF90 does not compute by default the inbreeding coefficients.
  The inverse of the numerator relationship matrix ($\mathbf{A}^{-1}$) is created based on the non-inbred approach (i.e. Henderson's method pretending that there is no inbreeding).
  To consider inbreeding in $\mathbf{A}^{-1}$, a user should supply inbreeding coefficients as a special format to the pedigree file as additional information.
* BLUPF90 does not use labels to describe the model. Instead, the program directly uses the positions (columns) of effect identifiers.
* BLUPF90 does not create interaction effects in the program.
  It has no `*` description in the parameter file.
  Interactions should be prepared as cross-classified effects before the analysis.
* BLUPF90 accepts positive and negative reals as covariates, as opposed to WOMBAT which only accepts integers.
* WOMBAT has more options for maximization of the likelihood (Derivative Free, PX, reduced rank), whereas BLUPF90 has Bayesian estimation by Gibbs sampler.
* BLUPF90 programs support the threshold model. WOMBAT does not.



### VCE ###

* The data and pedigree files for BLUPF90 should not contain headers (or comments).
  The first row in the file must be a data line.
* BLUPF90 uses very simple parameter file that is not as readable as ones for VCE.
  BLUPF90 does not use labels to describe effects. The order of parameters in the file is fixed.
* Pedigree file contains the animal ID, sire ID, and dam ID as the first 3 columns for the animal model.
  The additional 4th column can be used as a special feature.
* BLUPF90 does not compute by default the inbreeding coefficients.
  The inverse of the numerator relationship matrix ($\mathbf{A}^{-1}$) is created based on non-inbred approach (i.e. Henderson's method pretending that there is no inbreeding).
  To consider inbreeding in $\mathbf{A}^{-1}$, a user should supply inbreeding coefficients as a special format to the pedigree file as additional information.

### DMU ###

* BLUPF90 directly reads the data and pedigree files i.e. a user does not have to run DMU1 type of software.
  Data preparation programs can be optionally used for a user's convenience.
* Parameter file (the same concept to driver file) contains model descriptions.
  BLUPF90 does not use labels to refer to effects.
* BLUPF90 does not care about data types (integer or real).
  All the data will be read as real values and converted into an appropriate type as needed.
* BLUPF90 prints minimal outputs on the screen.
  It does not create any log files.


Differences in purpose
----------------------

BLUPF90 is specialized for estimation of BLUE, prediction of BLUP, and estimation of variance components in the linear mixed model.
The assumption is that the user knows which fixed effects are influential to the phenotypes prior to the analysis.
This is the reason why the programs do not perform hypothetical testing for fixed effects.
The goodness of fit about random effects can be compared using $-2\log L$ which is available from the REML programs.

Difference in software design
-----------------------------

The philosophy of BLUPF90 programs is described in the official wiki and several publications.
The basic idea is to support general linear mixed models with minimal effort in programming.
Fortran 90 enables us to write and re-use the code easily. BLUPF90 is the primary software to demonstrate that this idea actually works well with one common code.
Other application programs have been derived from BLUPF90.

The current programs support genomic analyses, especially for single-step GBLUP.
Computing time has been greatly improved in REML, Gibbs sampling, and BLUP with iteration on data, using parallelization and optimized libraries.
The development team actively updates the programs to support a new idea and improve stability.

BLUPF90 programs use user-supplied information only.
It is intended so that the software is as simple as possible.
The programs do not generate any additional effects and covariates for the user's convenience.
For example, the program does not add the general mean as a fixed effect to the model although the model does not have any fixed effects.
In random regression models, the programs do not automatically generate covariates (e.g., Legendre polynomials and spline functions).
It reminds the user of which information is actually needed in the model.
