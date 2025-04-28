---
title: Introduction
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Short introduction to BLUPF90 programs
======================================

What is BLUPF90?
----------------

BLUPF90 is the name of the software. It is also the name of a collection of programs derived from BLUPF90. In the latter case, we will refer to it as the *BLUPF90 family* or *BLUPF90 programs*. A concise description can also be found on the official wiki at the University of Georgia (<http://nce.ads.uga.edu/wiki/doku.php>).

>    BLUPF90 family of programs is a collection of software in Fortran 90/95 for mixed  
>    model computations in animal breeding. The goal of the software is to be as simple as  
>    with a matrix package and as efficient as in a programming language.

The BLUPF90 program creates and solves mixed model equations. It supports various models including the animal model, maternal model, and random regression model with multiple traits. The BLUPF90 family includes several programs for variance component estimation using REML and Gibbs sampling with various models. The set of programs is available on the official website (<http://nce.ads.uga.edu>) and can be freely used for academic or research purposes.

Why BLUPF90?
------------

BLUPF90 has several advantages over similar software for users: simplicity, stability, and active development. For programmers, the internal structure is documented in a course note (<https://nce.ads.uga.edu/wiki/doku.php?id=courses>), and the working source code is available, so a developer can modify the program to support new ideas.

We will now look at its advantages from a user's point of view.

### Simplicity ###

The program's behavior is very simple. Every BLUPF90 program reads a parameter file, which describes the names of data and pedigree files, models, and (initial) variance components to be used in the analysis. The parameter file is a short text file containing a few pairs of keywords and values to describe the information. It is concise but capable of specifying general models. Once you learn how to write a parameter file, you can perform very complicated analyses with the program.

Each program saves the solutions of the mixed model equations (e.g., EBV) to a file. Estimated variance components are also saved to files permanently.

### Stability ###

The programs have been tested by many researchers since their public release around 2000. They are now stable enough to be used for routine genetic evaluation at the national level. The team at the University of Georgia heavily uses the programs for their research.

### Active development ###

The programs are continuously maintained by the UGA team. New features are added to incorporate new methodologies and to improve usability and computing time. The programs fully support single-step genomic BLUP (ssGBLUP); GWAS can be performed within the ssGBLUP framework.

### Speed ###

We have been optimizing the programs for speed, not only by using multithreaded libraries (MKL) but also through detailed optimization of fundamental subroutines. The current version is remarkably faster than older versions, especially in REML and Gibbs sampling.

Is it easy?
-----------

Yes, it is. But the learning process is not always easy. There may be several hurdles to learning how to use the BLUPF90 programs in actual research. This is the flip side of its simplicity.

* Limited documentation. The official website hosts a manual for the programs (<http://nce.ads.uga.edu/wiki/doku.php>). The official wiki also provides various information about the software. However, documentation, especially for beginners, is not fully available in the existing resources.
* Data manipulation. This is not a specific disadvantage of BLUPF90 but is common to similar software. The BLUPF90 family focuses on mixed model analyses and does not provide a data manipulation framework like R or SAS. Since the programs use text files as input, some text processing may be needed. You should prepare data and pedigree files in a specific format and check for erroneous records before running the programs.
* Pre-processing. Every program accepts only numerical values to maintain simplicity in programming. If your data or pedigree file contains characters (letters or symbols), you must replace them with integer codes before analysis. One of the programs, RENUMF90, can perform this task. For field or commercial data, you will need to run RENUMF90 before using BLUPF90.

The purpose of this tutorial is to provide such documentation with many examples.
