---
title: Download and Installation
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Additional settings
===================

The BLUPF90 programs may use a lot of memory especially when the data set is large and a genomic model is applied.
The big memory-consumption often results in a program crash with the error *segmentation fault* (or *bus error*).
A segmentation fault occurs when a program tries to access an inappropriate memory area or to access it with an abnormal way.
Note that this error may happen even if your computer has a lot of free memory.
The operating system (Linux, macOS, or Windows) has a limitation of memory consumption by a program.
Strictly, the system limits the amount of memory called *stack*, and our programs consume a lot of stack memory to get the maximum performance.

It is a common error with a big data set, you may hit it when you update the program (i.e., when using a new version) with the same files used as before.
A small modification in the code may change the memory-management strategy in the program.

You can remove the limitation or increase the stack size.
The following settings are always recommended even if you do not hit this issue.
The details are also available on our website: <http://nce.ads.uga.edu/wiki/doku.php?id=faq.segfault>.

Increase stack size
-------------------

This setting is required in Linux and macOS.
First, type the following command in your shell (terminal).

~~~~~{language=shell}
ulimit
~~~~~

If it shows `unlimited`, the configuration looks good.
If you see a number (like 8192), probably it is a problem.
This number is the stack size and it should be *unlimited*.
To change the size, type the following command before running our programs.

~~~~~{language=shell}
ulimit -s unlimited
~~~~~

You can put this command at the end of `.bash_profile` in your home directory.
In this way, you can load this setting whenever you log-in this system.


Increase stack size for OpenMP
------------------------------

There is a separate setting to define stack size for OpenMP.
This value is unrelated to the system stack size explained above.
You can use an environment variable for the stack size.

### Linux and macOS

Please type the following command in your shell.

~~~~~{language=shell}
echo $OMP_STACKSIZE
~~~~~

If it shows nothing, it may be a problem. Even if you have a number with a unit (like 4M for 4 megabytes), it may be small.
By default, this value is 4M, and most likely it is too small.
Please type the following command before running our program.
Do not put any spaces around `=`.

~~~~~{language=shell}
export OMP_STACKSIZE=64M
~~~~~

This put 64 megabytes to stack size.
If the program still stops with the same error, please increase the number gradually (like 128M, 192M, and so on).
A too big value will consume a lot of memory because each thread can use this amount of memory.
It is hard to tell what is suitable for the user; it is system-dependent.

If you want to change it temporarily (one-time-run), you can put it to the command line when you run the program (no export).
In this way, you can find a reasonable setting empirically.

~~~~~{language=shell}
OMP_STACKSIZE=64M ./blupf90
~~~~~

As `ulimit`, you can save it in `.bash_profile`.


### Windows

You can set the environment variable OMP_STACKSIZE in Command Prompt (for a temporary change) or Control Panel/system-configuration page (for the permanent change).
To see the current stack size for OpenMP, you can type the following command in Command Prompt.

~~~~~{language=shell}
set %OMP_STACKSIZE%
~~~~~

To put the value to this variable, type the following command (64 megabytes in this case).

~~~~~{language=shell}
set OMP_STACKSIZE=64M
~~~~~

If you close this window, the setting is lost.
So, you have to run BLUPF90 programs in this session just after typing this command.
If you make this permanent, use the Control Panel. For details, please search the keywords like `windows, environment, variable`
on the Internet by search engines.

The stack size for OpenMP should be the number plus unit like 64M for 64 megabytes.
First, try 64M, and if you still see the problem, increase the number to 128M or more.
The too big number will consume a lot of memory because each thread can use this amount of memory.
The suitable value is up to your computer, so please find it empirically.
