---
title: Introduction
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

About this tutorial
===================

General information
-------------------

This document explains how to describe a model in a parameter file used with the BLUPF90 family of programs, how to prepare data and pedigree files, and how to perform genomic analyses with the programs. This tutorial assumes that the reader has sufficient knowledge of linear mixed models and data manipulation techniques on a computer. Experience with similar software will also be helpful for understanding the contents.

Features of the BLUPF90 program are introduced in an introductory style. In particular, the first section of each chapter presents essential features using a very simple example. Later sections introduce new concepts through more practical examples. We recommend that readers do not skip any sections, even if they seem too elementary.

This tutorial complements the official manual and wiki pages. Because the official manual serves more as a reference, it presents each topic concisely. For advanced topics or technical tricks, please refer to the manual. Conversely, if you find that something is missing in the manual, this tutorial may help you understand the background. If you have a question that is not addressed in the manual, the wiki, or this tutorial, please ask someone in the Yahoo Group (`https://groups.yahoo.com/neo/groups/blupf90/info`). You may find answers in the historical discussion logs of the forum.

Examples in each section
------------------------

### Example data

In each section, I will provide various examples for the reader. The files are available at the author's GitHub repository (`https://github.com/masuday/data`). Examples in this tutorial are enclosed in a frame, as shown below.

~~~~~{language=text caption="example.txt"}
1   1   2.5
2   1   1.8
3   1   4.2
4   1   2.2
5   1   3.6
~~~~~

### Parameter file for BLUPF90

Parameter files used in the BLUPF90 programs are highlighted as follows.

~~~~~{language=blupf90 caption="param0.txt"}
# This is a BLUPF90 parameter file.
DATAFILE
data0.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
1
OBSERVATION(S)
1
WEIGHT(S)

EFFECTS:
2 3 cross
RANDOM_RESIDUAL VALUES
1.0
~~~~~

### Parameter file for renumbering by RENUMF90

Alternative parameter files used in RENUMF90 (referred to as *instruction files* in this tutorial) are shown as follows.

~~~~~{language=renumf90 caption="renum1.txt"}
# This is an example of a renum-parameter file.
DATAFILE
rawdata1.txt
TRAITS
5
FIELDS_PASSED TO OUTPUT

WEIGHT(S)

RESIDUAL_VARIANCE
1.0
EFFECT          # 1st effect
2 cross alpha
EFFECT          # 2nd effect
3 cross alpha
EFFECT          # 3rd effect
4 cov
~~~~~

### Output

The output from the programs is shown in a different format.

~~~~~{language=output}
 name of parameter file?
~~~~~

### Commands on shell

If you need to type a command in your shell (terminal or Command Prompt), the command line is shown as follows.

~~~~~{language=shell}
./airemlf90 renf90.par
~~~~~


Disclaimer
----------

The following disclaimer is based on the MIT License, although this tutorial is distributed under the Creative Commons BY-NC-ND 4.0 International license.

> This tutorial is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.
> In no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the tutorial or the use or other dealings in the tutorial.

I wrote this documentation in Markdown using Pandoc extensions. The PDF file is generated using Pandoc, so there may be typesetting or layout issues.

TODO
----

These changes can be made in the next edition.

- Fully revise the descriptions to support the new programs `blupf90+` and `gibbsf90+`.
- Fully revise the chapters related to Dr. Mrode's textbook. The textbook has been updated (now in its 4th edition, "Linear Models for the Prediction of the Genetic Merit of Animals"), and a new author, Ivan Pocrnić, has joined. The numerical examples are now freely available online, and the revised chapters will make use of these materials.
- Add additional explanations on the usage of other programs, such as `idsolf90`.
