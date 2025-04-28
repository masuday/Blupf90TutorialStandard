---
title: Introduction
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Update to BLUPF90+/GIBBSF90+ programs
=====================================

Since 2022, the BLUPF90 programs have been reorganized, and some programs have been unified. This tutorial is still useful for the new software because the updated versions retain the same functionalities as the previous ones. Here, I would like to briefly outline the differences between the old and new programs. For more details, please refer to the WCGALP proceedings (Lourenco et al., 2022).

BLUPF90+
--------

- The programs `blupf90`, `remlf90`, and `airemlf90` have been unified into `blupf90+`.
    - The default behavior of `blupf90+` is the same as that of `blupf90`, i.e., building and solving the system of mixed model equations using data and variance components specified in the user-supplied parameter file.
    - The `blupf90+` program can estimate variance components by REML using the option `OPTION method VCE` in the parameter file.
    - You can switch the algorithm from AI (Average Information) to EM (Expectation-Maximization) by using the option `OPTION EM-REML`.
- `blupf90+` now supports more options to improve usability.
- The UGA group has discontinued support and development of the old programs (`blupf90`, `airemlf90`, and `remlf90`) because `blupf90+` is compatible with and can fully replace them.

GIBBSF90+
---------

- The Gibbs-sampling programs, including `gibbs2f90`, `gibbs3f90`, `thrgibbs1f90`, and others, have been unified into `gibbsf90+`.
    - The default behavior of `gibbsf90+` is the same as that of `thrgibbs1f90`, i.e., estimating variance components via Gibbs sampling under a linear model (or a threshold model with an option).
    - The usage and options are the same as those in `thrgibbs1f90` or other Gibbs-sampling programs.
- The UGA group has discontinued support and development of the old Gibbs-sampling programs because `gibbsf90+` is compatible with and can fully replace them.

This tutorial
-------------

The descriptions in this tutorial are based on the old programs, but most of the content should still be applicable to the new ones. In the text, readers can simply replace the old program names with the new ones as shown below.

| Old program in the text | New program name | Additional option         |
|-------------------------|------------------|----------------------------|
| `blupf90`               | `blupf90+`       | none                       |
| `airemlf90`             | `blupf90+`       | `OPTION method VCE`       |
| `remlf90`               | `blupf90+`       | `OPTION method VCE`       |
|                         |                  | `OPTION EM-REML 5000`     |
| Gibbs sampling programs | `gibbsf90+`      | none                       |
