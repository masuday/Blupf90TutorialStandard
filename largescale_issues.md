---
title: Large-scale genetic evaluation
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Issues in a large scale analysis
================================

Recent computers can finish genetic evaluations or variance component estimation within a practical time although we use a relatively large data set and a complicated model which weren't handled in the past. Even with modern computers, a genetic evaluation is a challenge both in computing time and required memory. BLUPF90, AIREMLF90, and GIBBSF90 programs are designed to store the system of mixed model equations (MME) in memory and they could be capable of 1 million pedigree animals in a single-trait model. This is not enough with a large-scale analysis including more animals and effects.

There are several issues to be solved in large-scale genetic evaluation.

- The solution of the mixed model equations.
- Calculation of accuracy or reliability of individual EBV.
- Estimation of variance components.

The mixed model equations will be too large to be stored in memory in the large analysis. So we need a trick to solve the equations without explicit creation of the equations. In this case, we cannot directly calculate the inverse of the left-hand side of the equations, and the prediction error variance of EBV of an animal is not available. Even if the mixed model equations are small enough to fit the memory, the computational cost for the inverse is extremely high, and therefore, this calculation is often impractical in many cases. We usually use subsets of the whole data for variance component estimation. But still, the computation takes a really long time and never finishes if the data is large or the model is complicated.

We have several options for large-scale analysis. The BLUP90IOD2 program supports the iteration on data technique. This technique is combined with an iterative method for solving the equations. The algorithm partially builds the equations during reading the data and pedigree file and indirectly update the solutions. When we have read through the files, we have also completed one round of iteration. BLUP90IOD2 implements Preconditioned Conjugate Gradient (PCG) as the iterative method. See Tsuruta et al. (2001) for details.

The ACCF90 program approximates the accuracy or reliability of EBV for an animal. This program creates approximated elements in the left-hand side matrix for each animal. After collecting all the information, the program inverts the elements to obtain the approximated prediction-error variance (PEV). This is an iterative method but the convergence will be met quickly. The basic idea is from Misztal and Wiggans (1988) and Strabel et al. (2001).

AI REML is a primary choice of methods for variance component estimation. A typical computation in AI REML contains the inversion of the left-hand side of mixed model equations. The FSPAK package quickly calculates selected elements of the inverse needed for AI REML. It can still do a good job for a small-scale analysis, but it is out of business for the large-scale analysis. The package was written more than 20 years ago and its fundamental routine was written in the early 1980s. The new package, YAMS (Yet Another MME Solver), could remove the bottleneck. Although the results from YAMS are compatible with the previous software, YAMS supports parallel computing or other modern techniques that is highly efficient computations. Now AIREMLF90 and REMLF90 can use YAMS with an option. See Masuda et al. (2014) and Masuda et al. (2015) for details.
