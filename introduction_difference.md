---
title: Introduction
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Differences with other software
===============================

It is helpful for new users to understand how BLUPF90 programs differ from other software they may be familiar with. We briefly introduce these differences for your understanding.

General differences
-------------------

### R and SAS ###

* BLUPF90 can handle very large datasets. It is likely to be faster than R and SAS.
* BLUPF90 is not interactive software. Users must prepare a *parameter file* that describes the details of the analysis (file names, model, genetic parameters, and options). The program simply reads the file and performs the defined task.
* BLUPF90 is not a scripting language. The programs do not provide any features for data manipulation. All editing must be done before running the program. The data file must include all information required for the analysis.
* BLUPF90 can only read text files. Headers (or comments) are not allowed in the data or pedigree files. Items in a text file should be separated by one or more spaces.
* BLUPF90 shows the results on screen and writes them to text files.
* BLUPF90 accepts only integer values as effect levels in the data and pedigree files, and real values as covariates and trait values. Alphabets or symbols must be replaced with integer codes before analysis. RENUMF90 can assist with this process.
* BLUPF90 has no graphical interface. It is similar to `Rscript`, a command-line utility. The program runs on Command Prompt (also called the 'DOS' window) in Windows, Terminal in macOS, and various shells in Linux.
* BLUPF90 does not provide functions for hypothesis testing. Some programs show $-2\log L$ or similar statistics, which users can use to manually perform likelihood ratio tests.

### ASREML ###

* BLUPF90 is free for research and academic purposes, but it offers limited support from the development team.
* BLUPF90 supports Gibbs sampling.
* BLUPF90 supports linear mixed models and threshold models. It does not support generalized linear models.
* BLUPF90 uses simple text formats for data and pedigree files. Headers, comments, alphabets, or symbols are not allowed in these files. The user must prepare the edited data before analysis.
* BLUPF90 does not offer comprehensive directives for analysis. The parameter file contains minimal information such as file names, model, variance components, and options. BLUPF90 does not use labels to refer to effects in the model description.
* BLUPF90 produces minimal output.

### WOMBAT ###

* In BLUPF90 data files, observations for an animal taken at the same time should be listed in the same line. Multiple observations must be saved in one line. Storing observations from the same animal in multiple lines is allowed only in repeated records or special multi-trait models (e.g., G-by-E analysis). In WOMBAT, each trait is recorded on a separate line.
* BLUPF90 does not compute inbreeding coefficients by default. The inverse of the numerator relationship matrix ($\mathbf{A}^{-1}$) is created using a non-inbred approach (i.e., Henderson's method, assuming no inbreeding). To consider inbreeding in $\mathbf{A}^{-1}$, users must supply inbreeding coefficients in a special format in the pedigree file.
* BLUPF90 does not use labels to describe the model. Instead, it refers directly to the column positions of effect identifiers.
* BLUPF90 does not create interaction effects. It does not support `*` notation in parameter files. Interactions must be prepared as cross-classified effects before analysis.
* BLUPF90 accepts both positive and negative real numbers as covariates, whereas WOMBAT accepts only integers.
* WOMBAT has more options for maximizing the likelihood (e.g., Derivative-Free, PX, reduced-rank methods), while BLUPF90 supports Bayesian estimation via Gibbs sampling.
* BLUPF90 supports the threshold model. WOMBAT does not.

### VCE ###

* BLUPF90 data and pedigree files must not contain headers or comments. The first row must be a data line.
* BLUPF90 uses a very simple parameter file format, which is not as human-readable as that used in VCE. It does not use labels for effects. The parameter order in the file is fixed.
* The pedigree file must contain animal ID, sire ID, and dam ID as the first three columns for the animal model. A fourth column can be added as a special feature.
* BLUPF90 does not compute inbreeding coefficients by default. The inverse of the numerator relationship matrix ($\mathbf{A}^{-1}$) is generated using a non-inbred approach (i.e., Henderson's method). Users who wish to consider inbreeding must provide inbreeding coefficients in a special format in the pedigree file.

### DMU ###

* BLUPF90 directly reads data and pedigree files; users do not need to run a DMU1-type program. Data preparation programs can be used optionally for user convenience.
* The parameter file (similar to a driver file) contains model descriptions. BLUPF90 does not use labels for effects.
* BLUPF90 does not differentiate between data types (integer or real). All data are read as real values and internally converted as needed.
* BLUPF90 prints minimal output to the screen. It does not create log files.

Differences in purpose
----------------------

BLUPF90 is specialized for estimating BLUE, predicting BLUP, and estimating variance components in linear mixed models. It assumes that the user knows which fixed effects influence the phenotypes prior to the analysis. This is why the programs do not perform hypothesis testing for fixed effects. The goodness-of-fit for random effects can be evaluated using $-2\log L$, which is provided by the REML programs.

Difference in software design
-----------------------------

The philosophy of the BLUPF90 programs is described in the official wiki and several publications. The basic idea is to support general linear mixed models with minimal programming effort. Fortran 90 makes it easy to write and reuse code. BLUPF90 is the main software that demonstrates this idea, and many other programs have been derived from it.

The current programs support genomic analyses, especially for single-step GBLUP. Computation time has been significantly improved in REML, Gibbs sampling, and BLUP with iteration on data, using parallelization and optimized libraries. The development team continues to actively update the programs to implement new ideas and improve stability.

BLUPF90 programs rely entirely on user-supplied information. This is intentional, to keep the software as simple as possible. The programs do not automatically create additional effects or covariates for convenience. For example, the general mean is not automatically added as a fixed effect if the model has none. In random regression models, the programs do not generate covariates (e.g., Legendre polynomials or spline functions) automatically. This reminds users of the information actually required in the model.
