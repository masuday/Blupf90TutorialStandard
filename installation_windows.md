---
title: Download and Installation
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Running a program in Windows
============================

BLUPF90 programs don't show a graphical window, and the software looks like a "DOS"-style
program.
You should prepare a parameter file to describe the name of data and pedigree files, the model and variance components to be used in the analysis.
You will type in the name of the parameter file on the screen.
If you have some experience with such software, you can skip this section.

We recommend that readers use the standard (traditional) way to run the program.
If you aren't really interested in a command line interface in Windows, just check the last subsection.
We provide a quick way to use the program.

A basic procedure
-----------------

### If you have no experience to run a command line program... ###

The running a command-line program is actually a FAQ.
The formal way is to use the Command Prompt or simply cmd.
This is a simple console to accept commands typed with a keyboard.
You can see several tutorials on this topic.

- Command Prompt - How to Use Basic Commands
  (<http://www.digitalcitizen.life/command-prompt-how-use-basic-commands>)
- How to use the Window command line (DOS) (<http://www.computerhope.com/issues/chusedos.htm>)
- How do I run a file from MS-DOS? (<http://www.computerhope.com/issues/ch000598.htm>)
- Beginners Guides: Windows Command Prompt (<http://www.pcstats.com/articleview.cfm?articleID=1723>)
- How To Open Command Prompt (<http://pcsupport.about.com/od/commandlinereference/f/open-command-prompt.htm>)

### How to run the program ###

A basic procedure to run the program is the following:

  1. Download the program and store it to a folder.
     You can add a folder to `PATH` (if you are unsure of `PATH`, just ignore this step).
  2. Save the needed files into a folder (If you are unsure of `PATH`, the downloaded program should be placed in the same folder).
  3. Open the Command Prompt window and change directory to the folder with the cd command.
  4. Type the name of a program (e.g. `blupf90` or `blupf90.exe`) to invoke the software.
  5. Type the name of the parameter file. Some programs would ask you to type in additional information.
  6. Wait for finishing the analysis.
  7. Collect the results.

If you successfully run a program, it asks you the name of parameter file with a short message.

~~~~~{language=output}
 name of parameter file?
~~~~~

Here you type the name of parameter file with a keyboard.
The Gibbs sampling programs will ask you additional questions.
You can also type the answers there.

### Save the output ###

If you want to save the output log (screen messages out of the program), please use the redirection.

~~~~~{language=shell}
blupf90 > out.txt
~~~~~

With this command, nothing shows, but it accepts key types.
You can type the name of the parameter file, and it runs.
The output is going to the file `out.txt`.

### Omit the typing ###

If you don't like to type-in, you can also use the redirection.
You prepare a text file with the name of the parameter file:

~~~~~{language=text caption="in.txt"}
parameter.txt
~~~~~

Let's say this file is `in.txt` then you can invoke the program.

~~~~~{language=shell}
blupf90 < in.txt > out.txt
~~~~~

This technique is useful for Gibbs sampling programs that need several key-in at the beginning of the program.
You can write several lines in in.txt instead directly typing-in.

### Stop the program ###

If you stop the program immediately, hit 2 keys simultaneously: Ctrl and C. For easier operation, you can keep pushing Ctrl and hit C. The program immediately stops with some messages, and you can safely ignore them. In some cases with multi-threaded computations, the program will be still running after receiving the STOP signal.
You can close the Command Prompt, and the program completely stops.


Quick run
---------

You can run the program without Command Prompt.

  1. Save all required files in a folder.
  2. Download the program and store it to the same folder.
  3. Double click the program. A black window is popping up.
  4. Input the name of parameter file in the black window using the keyboard. If the program asks you more questions, type the answers.
  5. Wait for finishing the analysis. Don't close the black window. When the analysis ends, the windows will automatically disappear.
  6. Check the results. The program saves the results as files in the same directory.

If you want to save the screen (`output.log`), download the following file (`run.bat`) and save it in the folder.
Then open this file with Notepad and rewrite the name of the program as you like and save it.
Double click the run.bat.
Although a black window appears and nothing will show in the window, you can type the name of the parameter file.
The program implicitly runs and all the output is going to `out.txt`.

Running the program double-clicking on it is less recommended than the Command Line because if there is any error the window will close automatically and the error may not be read by the user.

~~~~~{language=text caption="run.bat"}
blupf90 > out.txt
~~~~~

This procedure may not work in some cases.
The reason will be due to the hidden-extension stuff. We don't support this method at all.
