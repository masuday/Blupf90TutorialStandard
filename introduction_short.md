---
title: Introduction
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Short introduction to BLUPF90 programs
======================================

What is BLUPF90?
----------------

BLUPF90 is the name of the software.
Also, it is the name of a collection of programs derived from BLUPF90.
In the latter case, we will refer it to *BLUPF90 family* or *BLUPF90 programs*.
A concise description is also found at the official wiki at the University of Georgia (<http://nce.ads.uga.edu/wiki/doku.php>).

>    BLUPF90 family of programs is a collection of software in Fortran 90/95 for mixed
>  model computations in animal breeding. The goal of the software is to be as simple as
>  with a matrix package and as efficient as in a programming language.

The BLUPF90 program creates and solves the mixed model equations.
It supports various models including animal model, maternal model and random regression model with multiple traits.
The BLUPF90 family has several programs for variance component estimation using REML and Gibbs sampling with various models.
The set of programs is available at the official website (<http://nce.ads.uga.edu>) and you can freely use it for academic or research
purposes.

Why BLUPF90?
------------

BLUPF90 has several advantages over similar software for users: simplicity, stability and active development.
For programmers, the internal structure is documented in a course note (<http://nce.ads.uga.edu/wiki/doku.php?id=course_information_-_uga_2018>) and the working source code is available; so a developer can modify the program to support new ideas.

We will see the advantage in a user's point of view.

### Simplicity ###

The program's behavior is very simple.
Every BLUPF90 program reads a parameter file, which describes the name of data and pedigree files, models and (initial) variance components to be used in the analysis.
The parameter file is a short text file and it has a few pairs of keywords and values to describe the information.
The parameter file is concise but capable of general models.
Once you learn how to write a parameter file, you can perform very complicated analyses with the program.

Every program saves the solutions of the mixed model equations (e.g., EBV) to a file.
Estimated variance components are also saved in files permanently.

### Stability ###

The programs have been tested by many researchers since its public release around 2000.
The programs are now stable enough to be used in a routine genetic evaluation at the national level.
The team at the University of Georgia heavily uses the programs for their research.

### Active development ###

The programs are continuously maintained by the UGA team.
New features are added to the existing software to incorporate a new methodology and to improve the usability and the computing time.
The programs fully support single-step genomic BLUP (ssGBLUP); GWAS can be done with the ssGBLUP framework.

### Speed ###

We have been optimizing the programs in terms of speed not only using multithreaded libraries (MKL) but also with detailed optimization in fundamental subroutines.
The current version is remarkably faster than the old version, especially in REML and Gibbs sampling.

Is it easy?
-----------

Yes, it is.
But the learning process is not always easy.
There might be several hurdles to learn how to use BLUPF90 programs in actual research.
It is the opposite side of the advantage.

* A little documentation.
  The official website hosts a manual for the programs (<http://nce.ads.uga.edu/wiki/doku.php>).
  The official wiki also provides various information about the software.
  But, documentation, especially for learners, is not fully available in the existing resources.
* Data manipulation.
  This is not a specific disadvantage in BLUPF90 but in much similar software.
  BLUPF90 family focuses on mixed model analyses so it doesn't provide any data manipulation framework as R and SAS do.
  The programs use text files as a common format so a few text manipulation can be needed.
  You should prepare data and pedigree with a specific format and check erroneous records in the files before running the programs.
* Pre-process.
  Every program accepts numerical values only because of keeping simplicity in the programming.
  If your data or pedigree file contains characters (alphabets or symbols), you should replace the characters with integer code before the analysis.
  One of the programs, RENUMF90, can perform this editing.
  With field or commercial data, you will have to run RENUMF90 before BLUPF90.

The purpose of this tutorial is to provides such documentation with many examples.
