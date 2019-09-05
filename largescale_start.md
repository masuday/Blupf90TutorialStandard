---
title: Large-scale genetic evaluation
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Actual genetic evaluation often handles a large data set. Although the specific program `blupf90` can read quite large
data and pedigree files ( for instance 1 million animals depending on the available memory), it will fail in a large-scale analysis with tens of millions of individuals.
Some special software is available for such
a purpose with a special contract with the development team at UGA. A member of our team can
access and test the software supporting the large data set. In this chapter, we will explain the usage
of the programs for large-scale genetic evaluations.
