---
title: Practical genomic analysis
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Tuning and input/output of relationship matrices
================================================

Stability of single-step GBLUP depends on the characteristic of $\mathbf{H}^{-1}$ , which contains $\mathbf{G}^{-1}$ and $\mathbf{A}_{22}^{-1}$.
We have several ways to adjust $\mathbf{G}$ and $\mathbf{G}^{-1}$ to obtain reasonable results in the genomic analysis.
There are also several options to harmonize between $\mathbf{G}^{-1}$ and $\mathbf{A}_{22}^{-1}$. We will introduce the ideas as
well as the options needed.


Construction of $\mathbf{G}$
----------------------------

~~~~~{language=blupf90}
OPTION whichfreq x
~~~~~

This option defines which type of allele frequency is used to calculate $\mathbf{Z}$. The argument `x` could
be 0 = use of the user-supplied file (see below), 1 = fixed value (0.5) and 2 = the current allele
frequency calculated from the marker data (default). With the argument 0, the file name is supplied
with the following option:

~~~~~{language=blupf90}
OPTION FreqFile x
~~~~~

where `x` is the name of the file for allele frequency. The format of this file is explained in the previous
section.


Blending
--------

~~~~~{language=blupf90}
OPTION AlphaBeta a b
OPTION GammaDelta c d
~~~~~

These options define `a` as $\alpha$, `b` as $\beta$, `c` as $\gamma$, and `d` as $\delta$ used in the blending $\alpha\mathbf{G}+\beta\mathbf{A}_{22}^{-1}+\gamma\mathbf{I}+\delta\mathbf{11}'$.
The default values are $\alpha = 0.95$, $\beta = 0.05$, $\gamma = 0$, and $\delta = 0$. We usually use a restriction as $\alpha + \beta = 1$,
but the program will not check this restriction.


The original $\mathbf{G}$ matrix is completely updated (rewritten) by the blended $\mathbf{G}$. After the blending,
we cannot retrieve the original elements in non-blended $\mathbf{G}$.


Tuning
------

~~~~~{language=blupf90}
OPTION tunedG x
~~~~~

This option defines the method to tune $\mathbf{G}$ up. The tuning scales $\mathbf{G}$ to $\mathbf{A}_{22}$. 
This tuning is a separate step from blending. In real population,
most genotypes are from the recent generations but the pedigree comes from long generations. The
situation would cause the incompatibility between $\mathbf{G}$ and $\mathbf{A}_{22}$ due to different amount of information
accounting for changes in allele frequency. The tuning tries to make $\mathbf{G}$ compatible with $\mathbf{A}_{22}$ by
applying a single regression equation. See Chen et al. (2011), Vitezica et al. (2011), and Christensen et al. (2012) for details.

The possible argument `x` is as follows.

- 0 = no scaling
- 1 = $\mathrm{mean}\left(\left[\mathrm{diag}(\mathbf{G})\right]\right) = 1$ and $\mathrm{mean}\left(\left[\mathrm{offdiag}(\mathbf{G})\right]\right) = 0$
- 2 = $\mathrm{mean}\left(\left[\mathrm{diag}(\mathbf{G})\right]\right) = \mathrm{mean}\left(\left[\mathrm{diag}(\mathbf{A}_{22})\right]\right)$ and $\mathrm{mean}\left(\left[\mathrm{offdiag}(\mathbf{G})\right]\right) = \mathrm{mean}\left(\left[\mathrm{offdiag}(\mathbf{A}_{22})\right]\right)$ (default)
- 3 = $\mathrm{mean}\left(\mathbf{G}\right) = \mathrm{mean}\left(\mathbf{A}_{22}\right)$
- 4 = Adjustement with the 1st method described as in Powell et al. (2010) or Vitezica et al. (2011). This is very similar to (2).


Scaling the inverse matrices
----------------------------

Additional scaling may be needed for $\mathbf{G}^{-1}$ and $\mathbf{A}_{22}^{-1}$ to achieve the maximum predictive ability in
GEBV for young animals. The scaling factors $\tau$ and $\omega$ are used for this purpose.
$$
\mathbf{H}^{-1}
=
\mathbf{A}^{-1}
+
\left[
\begin{array}{cc}
\mathbf{0}&\mathbf{0}\\
\mathbf{0}&\tau\mathbf{G}^{-1}-\omega\mathbf{A}_{22}^{-1}
\end{array}
\right]
$$

In the ideal situation, $\tau = 1$ and $\omega = 1$. The scaling would solve some issues if there are issues
including incomplete pedigree and unqualified genotypes.

~~~~~{language=blupf90}
OPTION TauOmega t w
~~~~~

These options define `t` as $\tau$ and `w` as $\omega$ in above equation. The default values are $\tau = 1$ and $\omega = 1$.

The original inverses ($\mathbf{G}^{-1}$ and $\mathbf{A}_{22}^{-1}$) are completely replaced (rewritten) with the scaled ones
($\tau\mathbf{G}^{-1}$ and $\omega\mathbf{A}_{22}^{-1}$). After the scaling, we cannot retrieve the non-scaled elements in $\mathbf{G}^{-1}$ and $\mathbf{A}_{22}^{-1}$.

Output options
--------------

A relationship matrix and its inverse generated with the genomic module can be saved in a file. By
default, the format is binary which the software can efficiently read, but a human cannot easily read. If
you really want to save the matrix as text format, the following option is useful.

~~~~~{language=blupf90}
OPTION saveAscii
~~~~~

The format is space-separate text. It has 3 columns per line: 1) row number, 2) column number
and 3) element value. This text file can be used as a user-supplied relationship matrix in BLUPF90
with the `user_file` keyword. If you need the maximum efficiency, do not use this option --- it will
be slow in operation.

The following options are available to output matrices. The options are case-sensitive so be
careful to write them.

~~~~~{language=blupf90}
OPTION saveA22         # save A22 to a file 'A22'
OPTION saveA22Inverse  # save A22-inverse to a file 'A22i'
OPTION saveG           # save G to a file 'G'
OPTION saveG all       # save all intermediate G
OPTION saveGInverse    # save G-inverse to a file 'Gi'
~~~~~

You can't change the name of the file for each matrix. If you put `OPTION saveG_all`, the program
will save all the intermediate status of $\mathbf{G}$:

- `Gini` = Initial matrix i.e. $\mathbf{G} \leftarrow \mathbf{ZZ}'/k$.
- `G_Alpha_Beta` = Blended matrix with $\mathbf{A}_{22}$ i.e. $\mathbf{G} \leftarrow \alpha\mathbf{G} + \beta\mathbf{A}_{22}$.
- `G_gamma` = Blended matrix with $\mathbf{I}$ i.e. $\mathbf{G} \leftarrow \mathbf{G} + \gamma\mathbf{I}$.
- `G_delta` = Blended matrix with $\mathbf{11}'$ i.e. $\mathbf{G} \leftarrow \mathbf{G} + \delta\mathbf{11}'$.
- `G_suggest` = Tuned matrix.
- `G` = The final matrix.

We should mention that the options saveGInverse and saveA22Inverse save the scaled matrices
with $\tau$ and $\omega$. This would be a serious problem if you read the matrices from the files.


Input options
-------------

The program can read the matrices from files. In this case, the program does not calculate the matrix
from the marker file or the pedigree file. If you read an inverse matrix from a file, the program could skip
creating the original matrix. By default, the program reads only a binary file; with option `OPTION saveAscii` [^1],
the programs read a text file. The following options are available.

~~~~~{language=blupf90}
OPTION readA22 file          # read A22                        [ default : 'A22']
OPTION readA22Inverse file   # read A22-inverse                [ default : 'A22i']
OPTION readG file            # read G                          [ default : 'G']
OPTION readGInverse file     # read G-inverse                  [ default: 'Gi']
OPTION readGimA22i file      # read (G-inverse - A22-inverse ) [ default: 'GimA22i']
~~~~~

[^1]: Yes, use `OPTION saveAscii`, because `OPTION readAscii` does not exist.

If you specify the name of the file, the program reads the file supplied. If you omit the name of
the file, the program tries to read the default file shown above. For example, you can use the following
option to read $\mathbf{G}^{-1}$ saved in `Gi`.

~~~~~{language=blupf90}
OPTION readGi
~~~~~

Or you can supply the name of file like this.

~~~~~{language=blupf90}
OPTION readGi condition1.Gi
~~~~~

There is a critical specification to be recognized by a user for the options `readGInverse` and
`readA22Inverse`. After reading the matrix, the program scales the matrix with $\tau$ or $\omega$. It means
that if you have already scaled the matrix before saving it to a file and you read the matrix from the
file, the program scales the matrix again without any warnings or messages. Without knowing this
fact, the results would be nonsense.

A better practice is as follows.

1. Create and save the relationship matrix without the scaling factor($\tau$ or $\omega$) i.e. the default
      values: $\tau = 1$ and $\omega = 1$.
2. When reading the file, the scaling factors can be specified.

This strategy is really important to perform the analysis many times with different $\tau$ and $\omega$ parameters.
