---
title: Introduction
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

About this tutorial
===================

General information
-------------------

This document explains how a model is described in a parameter file used with the BLUPF90 family programs, how data or pedigree files are prepared, and how genomic analyses perform with the programs.
So, this tutorial assumes that a reader has enough knowledge in linear mixed models and data manipulation techniques on a computer. Experiences with similar software will be very helpful to understand.

Features of BLUPF90 program are introduced in an introductory style.
Especially, the first section in each chapter will introduce essential features using a very simple example.
In the later sections, new ideas will come along with more practical examples.
We recommend that a reader not skip any sections even if it looks too elementary for the reader.

This tutorial is a complement of the official manual or wiki pages.
Because the official manual is more like a reference manual, you should find a specific topic written in concise words.
Also, if you want to know advanced topics or tricks, please check the manual.
Conversely, if you found something missing in the manual, this tutorial would help you understand the background.
If you have a question not covered with any of the manual, the official wiki and this tutorial, please ask somebody at Yahoo Group (`https://groups.yahoo.com/neo/groups/blupf90/info`).
We also have a Github repository for public discussion (`https://github.com/ABGG-UGA/blupf90-public`).
You may find the right answers from a historical log of this forum.

Examples in each section
------------------------

### Example data

In each section, I will give various examples to the reader.
The files are available at the author's Github repository (`https://github.com/masuday/data`).
The example in this tutorial is enclosed by a frame as shown below.

~~~~~{language=text caption="example.txt"}
1   1   2.5
2   1   1.8
3   1   4.2
4   1   2.2
5   1   3.6
~~~~~

### Parameter file for BLUPF90

Parameter files used in the BLUPF90 programs will be highlighted as follows.

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

Alternative parameter files used in RENUMF90 (we refer them to *instruction files* in this tutorial) will be shown as follows.

~~~~~{language=renumf90 caption="renum1.txt"}
# This is an example of renum-parameter file.
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

The output from the programs is encircled with a different format.

~~~~~{language=output}
 name of parameter file?
~~~~~

### Commands on shell

If you need to type a command in your shell (terminal or Command Prompt), the command line will be shown as follows.

~~~~~{language=shell}
./airemlf90 renf90.par
~~~~~


Disclaimer
----------

The disclaimer is taken from the MIT License, although this tutorial is distributed under the Creative Commons BY-NC-ND 4.0 International license.

> This tutorial is provided "as is", without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement.
> In no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the tutorial or the use or other dealings in the tutorial.

I wrote this documentation in Markdown with Pandoc's extension.
Pandoc generates the PDF file, and there may be typeset and layout issues.
