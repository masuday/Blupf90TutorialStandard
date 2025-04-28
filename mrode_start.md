---
title: Various models shown in Mrode (2014)
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

In this chapter, we will see how BLUPF90 applies to a variety of models. We will look at various models in a standard textbook, *Linear Models for the Prediction of Animal Breeding Values*, written by Mrode (2014). We explain how to write a parameter file to handle a model in his book. We will not represent the content of data, pedigree, and genotype files. You can easily create these files if you have the book. We do not only solve the equations but do introduce new options and tricks useful for actual data analyses.

As mentioned in the Introduction, the textbook has been updated (now in its 4th edition), and a new author, Ivan Pocrnić, has joined. The title of the textbook has also been changed to "Linear Models for the Prediction of the Genetic Merit of Animals". This tutorial is based on the previous edition (3rd edition, published in 2014), and a full update of the tutorial will be made in the future. The numerical examples in the new textbook are (mostly) the same as before, so I believe this tutorial is still useful with the new edition, except for differences in chapter structure.

In addition, the computer programs have been updated to `blupf90+`. The parameter file format remains the same, so you can continue to use the previous parameter files with `blupf90+` without modification.
