---
title: Numerical examples from Mrode (2014)
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Inversion of the dominance matrix
=================================

Model
-----

A rapid algorithm to calculate $\mathbf{D}^{-1}$ (ignoring inbreeding) was developed by Hoeschele and VanRaden (1991). Their method was derived from the parental subclass effects $\mathbf{f}$ and its covariance matrix $\mathbf{F}$. The dominance effect is an interaction of genes, and the effect is inherited through the combination of parents and ancestors rather than through individuals. Therefore, the dominance variation can be described with the combination of ancestral animals. Here we just introduce the idea of parental subclasses. See the original paper or the textbook for the detailed algorithm for the inverse.


For an animal $i$, its dominance effect $d_i$ can be expressed as
$$
d_i = f_{S,D} + \varepsilon
$$
where $f_{S,D}$ is the expected dominance effect of many hypothetical fill-sibs from the sire $S$ and the dam $D$, and $\varepsilon$ is the Mendelian sampling deviation. We assume $\mathrm{var}( f_{S,D} ) = \sigma_f^2$ and it is equivalent to the dominance covariance among the full-sibs. So we can find $\sigma_f^2=0.25\sigma_d^2$ and $\mathrm{var}(\varepsilon)  = 0.75\sigma_d^2$. The parental dominance effect actually consists of several components:
$$
f_{S,D} = 0.50( f_{S, SD} + f_{S, DD} + f_{SS, D} + f_{DS, D}) - 0.25( f_{SS, SD} + f_{SS, DD} + f_{DS, SD} + f_{DS, DD}) + e
$$
where $SS$ and $SD$ refer to the sire and the dam of the sire, respectively, and $SD$ and $DD$ refer to the sire and the dam of the dam, respectively. We have to put a label on each combination of animals (subclass). A dominance pedigree file contains the labels on the above 8 subclass for each $f_{S,D}$. The vector $\mathbf{f}$ contains the parental dominance effects and its variance is
$$
\mathrm{var}(\mathbf{f}) = \mathbf{F}\sigma_f^2
$$
and its inverse is rapidly calculated using the dominance pedigree file. The final inverse $\mathbf{D}^{-1}$ is also calculated with $\mathbf{F}^{-1}$.

BLUPF90 calculates $\mathbf{F}^{-1}$ only. This matrix itself cannot be used to estimate individual dominance effect. However, $\mathbf{F}^{-1}$ is still useful to estimate the variance components. In this section, we will prepare the files as usual even we will not solve the mixed model equations.


Files
-----

<!--
First we prepare the dominance pedigree file. According to the textbook (p.213), there are 6 known
subclasses for parental dominance ($f_{S,D}$) to be considered in $\mathbf{F}$. The following table consists of the
selected elements of the table.

 Sire ($S$)     Dam ($D$)    $\phi$     Known parent subclasses
------------   -----------  --------    -----------------------
    6             8           1         2, 3, 6
    6             5           2         3, 6
    3             8           3         6
    3             4           4
    1             2           5
    3             5           6

The subclass is referred with the label ($\phi$). For example, $f_{6,8}$ is the subclass 1, $f_{6,5}$ is the subclass
2 and so on. The known parent subclasses are the components of the parental dominance. For
example, in the subclass 1 with $S = 6$ and $D = 8$, $f_{6,8}$ consists of the subclasses 2, 3 and 6. In this
case, the subclass 2 is $f_{6,5}$ that is $fS$, $DD$ for $f_{6,8}$. Similarly, the subclass 3 is $f_{3,8}$ that is $f_{SS,D}$ for $f_{6,8}$ and
the subclass 6 is $f_{3,5}$ that is $f_{SS,DD}$ for $f_{6,8}$. Based on the above equation, the subclass 1 can be
described as
$$
f_{6,8} = 0.50( f_{S,DD} + f_{SS,D} ) - 0.25 f_{SS,DD}
$$
and missing components are ignored because of no contribution for the results.
-->

The dominance pedigree file for BLUPF90 contains 10 columns.

1. Parental dominance subclass ($\phi$).
2. Subclass $S, SD$ (code:1)
3. Subclass $S, DD$ (code:2)
4. Subclass $SS, D$ (code:4)
5. Subclass $DS, D$ (code:8)
6. Subclass $SS, SD$ (code:16)
7. Subclass $SS, DD$ (code:32)
8. Subclass $DS, SD$ (code:64)
9. Subclass $DS, DD$ (code:128)
10. Sum of the code for nonempty subclasses.

If the subclass is unknown or empty, put 0. The last column contains an integer value from the summation of all the code number for nonempty subclasses. The final code should be ranging from 0 to 255. For example, in $\phi = 1$ that is, $f_{6,8}$, the final code is $2 + 4 + 32 = 38$. If the final code is 0, you can omit such a line.

The dominance pedigree file for this example is shown below.

~~~~~{language=text caption="dominance_mr12b.txt"}
1 0 2 3 0 0 6 0 0  38
2 0 0 6 0 0 0 0 0   4
3 0 6 0 0 0 0 0 0   2
~~~~~

The data file has to contain the parental subclass labels. The 4th column is the subclass label.

~~~~~{language=text caption="data_mr12b.txt"}
 5  2  17    5
...
~~~~~

The pedigree file is the same as the previous one (`pedigree_mr12b.txt`).

The parameter file is shown below.

~~~~~{language=blupf90 caption="param_mr12b.txt"}
DATAFILE
data_mr12b.txt
NUMBER_OF_TRAITS
1
NUMBER_OF_EFFECTS
3
OBSERVATION(S)
3
WEIGHT(S)

EFFECTS:
2  2 cross   # fixed effect
1 12 cross   # additive genetic
4  6 cross   # parental dominance
RANDOM_RESIDUAL VALUES
180.0
RANDOM_GROUP
2
RANDOM_TYPE
add_animal
FILE
pedigree_mr12b.txt
(CO)VARIANCES
90.0
RANDOM_GROUP
3
RANDOM_TYPE
par_domin
FILE
dominance_mr12b.txt
(CO)VARIANCES
20.0
OPTION solv_method FSPAK
~~~~~

With the keyword `par_domin`, BLUPF90 creates $\mathbf{F}^{-1}$ from the dominance pedigree file. Note that the parental subclass variance is one quarter of the dominance variance ($\sigma_f^2=\sigma_d^2/4 = 80/4 = 20$). The remaining variance goes into the residual variance ($120 + 60 = 180$).

You can run BLUPF90 with this parameter file. The solutions are similar in BLUE and BLUP for the additive effects compared with the previous results. The predictions for parental dominance are not equivalent to the previous results. In this analysis, we just consider the quarter of dominance variance through $\mathbf{F}^{-1}$. For the precise prediction of the dominance effects, a user should use the software that fully supports the dominance effect. As we mentioned before, however, the parameter file is still useful for variance component estimation with a dominance model.

What is the most efficient way to create a dominance pedigree file? A renumbering program RENDOMN supports generating the file. This program is based on the old design and different usage compared to RENUMF90. A solver supporting a dominance model is JAADOMN which is also old software. You can find the programs at <http://nce.ads.uga.edu/~ignacy/numpub/dominance/>.
