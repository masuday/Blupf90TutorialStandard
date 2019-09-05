---
title: Download and Installation
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Running a program in Linux and macOS
====================================

Command line software
---------------------

BLUPF90 programs are command line software.
The program reads a parameter file describing the name of data and pedigree files, the models, and covariance components used in the analysis.
It shows logs on screen and writes a file (or several files) for the results.
This is designed to be used on the shell with keyboard operations.

Here we assume a standard bash environment.
For macOS, all the operations will be done on Terminal.
No GUI (graphical user interface) will be used.

Installation
------------

The software does not need a special installation method.
Just download it from the official web site.
Then change the permission e.g. `chmod 755` or `chmod u+x` (easier to remember: _ch_ ange the _mod_ e adding (_+_) permission of e _x_ ecution to the _u_ ser).
You can move the program to your favorite directory which may be listed in the variable `PATH`.
If you don't have such a directory, you can create the directory.
Then you move the program there.

The following is an example of this process.

~~~~~{language=shell}
# 1. download a program; you can use another way like using curl.
wget http://nce.ads.uga.edu/html/projects/programs/Mac_OSX/new/blupf90

# 2. change the permission to executable
chmod 755 blupf90

# 3. make a directory for binaries if you don't have it.
mkdir ~/bin

# 4. move the program to the directory.
mv blupf90 ~/bin
~~~~~

You can use other software (e.g., `curl`) instead of `wget` to download a file.
If the above directory is not listed in the environmental variable `PATH`, add the directory to this variable.
You can check it with a command.

~~~~~{language=shell}
echo $PATH
~~~~~
If you find the directory, you don't have to do any extra task.
If you don't find, you can change the variable.
You can do this by typing the following command on your shell.

~~~~~{language=shell}
export PATH=~/bin:$PATH
~~~~~

If you have installed the program in another directory than `~/bin`, please put the correct path there.
This setting will disappear after log-out.
To execute this command on log-in, set the variable in `/.bash_profile`.
If you are unsure of this file, just open it with a text editor, then add the above command in the bottom of the file.
Do not forget to log-out once then log-in again because the setting file will be effective only on your log-in.


Running a program
-----------------

Move to the directory with all the required files (e.g. pedigree, data).
Just type the program name to invoke the software.
If you successfully run a program, it asks you the name of parameter file with a short message.

~~~~~{language=shell}
name of parameter file?
~~~~~

Here you type the name of parameter file with the keyboard.
Additional typing will be needed for Gibbs sampling programs.
The messages will be shown on screen (standard output), so you can capture them to a file.

~~~~~{language=shell}
# All messages are saved to a file.
# The program accepts key-in even nothing shown.
blupf90 > out.txt

# As above.
# Messages are shown and saved.
blupf90 | tee out.txt
~~~~~

Using a redirection, you can omit the key-in in the beginning of the program.

~~~~~{language=shell}
# one line input
echo parameter.txt | blupf90

# different way using a file
echo parameter.txt > input
blupf90 < input
~~~~~

The second method is useful for Gibbs sampling programs, which require several inputs.


Stop a program
--------------

If you stop the program immediately, hit 2 keys simultaneously: Ctrl and C.
For easier operation, you can keep pushing Ctrl and hit C.
The program immediately stops with some messages, and you can safely ignore such messages.
In some cases with multi-threaded computations, the program will be still running after receiving the STOP signal.
You can close the terminal, and the program completely stops.
