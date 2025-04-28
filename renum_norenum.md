---
title: Data preparation with RENUMF90
author: Andres Legarra
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...


What if I do not want to use RENUMF90?
=====================================

It happens that the user does not want to use RENUMF90. Common reasons for this are:

  - It is simulated data and it is already renumbered
  - I do my own renumbering and I want to use it
  - I have a complex model and I want better control on the recorded numbers

In the next section, we will give instructions on how the files should be coded. We will *not* give software but you may take a look [here](https://github.com/alegarra/yarp).

Main requirements of recoding for BLUPF90 programs
---------------------------------------------

  - Levels of effects should be coded with consecutive numbers. The order may be "natural" or not. For instance, if years in data are (2010, 2011, 2013, 2014) may be renumbered as (1,2,3,4) or (2,1,3,4).
  - The animal is another effect, so it has receive codes from 1 to the number of animals _in the pedigree file_ (this is usually greater than the number of animals in the data file).
  - The animal effect does not need to be renumbered in consecutive order (parents before offspring), but this order is a correct one and may be used. So, for instance, this renumbering is correct:

~~~{language=text caption="ped_kempthorne"}
  A 0 0
  B 0 0
  D A B
  E A D
  F B E
  Z A B
~~~

could be recoded as

~~~{language=text caption="ped_kempthorne_recoded"}
1 0 0 A 0 0
2 0 0 B 0 0
3 1 2 D A B
4 1 2 Z A B
5 1 3 E A D
6 2 5 F B E
~~~

(the last three columns are not needed but help the visualization).


Unknown parent groups
---------------------

However, if unknown parent groups (UPGs) are in the pedigree, things get more complicated. Assume that we have $n$ _real_ animals and $m$ UPGs. Animals have to be renumbered with codes from 1 to $n$, and UPGs have to be renumbered with codes from $n+1$ to $n+m$. In addition, because they do not have ancestors, the UPGs must not have a line on their own in the pedigree file for BLUPF90. In that way, BLUPF90 "knows" that a given number is a UPG and not an individual. For instance, in the previous example assume that UPGs are "unknown2000" and "unknown2004":

~~~{language=text caption="ped_kempthorne_unknown parent groups"}
  A unknown2000 unknown2000
  B unknown2000 unknown2004
  D A B
  E A D
  F B E
  Z A B
~~~

It should be recoded as follows.

~~~{language=text caption="ped_kempthorne_unknown parent groups_recoded"}
1 7 7 A unknown2000 unknown2000
2 7 8 B unknown2000 unknown2004
3 1 2 D A B
4 1 3 E A D
5 2 4 F B E
6 1 2 Z A B
~~~

Genotypes
---------

Genotypes should be coded as 0/1/2 for {AA, Aa, aa} and 5 for missing as described elsewhere in this tutorial, in a text format with fixed file. The first column of this file contains (possibly alphanumeric) identifiers for animals, for instance:

~~~{language=text caption="genotype_file"}
   A 120120202102111
   Z 121111202111010
~~~

The only important requirement is the creation of the cross-reference file (usually called `_XrefID`). This file contains the original ID and the new ID in the renumbered pedigree and data files. In the previous example it would be:

 ~~~{language=text caption="genotype_file_XrefID"}
  1  A
  6  Z
 ~~~

Overall mean
------------

BLUPF90 programs do _not_ include by default an overall mean !! If you need one, add it by yourself as a column of 1s in the data file
