---
title: Download and Installation
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Running a program in Windows
============================

BLUPF90 programs do not provide a graphical window and instead run in a "DOS"-style interface. You should prepare a parameter file that describes the names of data and pedigree files, the model, and the variance components to be used in the analysis. You will be prompted to type the name of the parameter file. If you are already experienced with this type of software, you may skip this section.

We recommend using the standard (traditional) method for running the program. If you are not comfortable with the Windows command line interface, refer to the last subsection for a quicker method.

A basic procedure
-----------------

### If you have no experience running a command line program... ###

Running a command-line program is actually a frequently asked question. The standard method is to use the Command Prompt, or simply `cmd`, which is a console that accepts commands typed with a keyboard. You can also use PowerShell instead of Command Prompt; the procedure is the same.

There are many tutorials available on this topic:

- Command Prompt - How to Use Basic Commands  
  (<http://www.digitalcitizen.life/command-prompt-how-use-basic-commands>)
- How to use the Windows command line (DOS)  
  (<http://www.computerhope.com/issues/chusedos.htm>)
- How do I run a file from MS-DOS?  
  (<http://www.computerhope.com/issues/ch000598.htm>)
- Beginners Guide: Windows Command Prompt  
  (<http://www.pcstats.com/articleview.cfm?articleID=1723>)
- How to Open Command Prompt  
  (<http://pcsupport.about.com/od/commandlinereference/f/open-command-prompt.htm>)

### How to run the program ###

A basic procedure to run the program is as follows:

1. Download the program and save it in a folder.  
   (You may optionally add the folder to your system `PATH`. If you're unsure what this is, you can skip this step.)
2. Save the required files in the same folder.  
3. Open the Command Prompt and use the `cd` command to change to the folder's directory.  
4. Type the name of the program (e.g., `blupf90` or `blupf90.exe`) to launch it.  
5. When prompted, type the name of the parameter file. Some programs may ask for additional input.  
6. Wait for the analysis to complete.  
7. Check and collect the results.

If the program runs successfully, it will ask you for the name of the parameter file with the following prompt:

~~~~~{language=output}
 name of parameter file?
~~~~~

Here, type the parameter file name using the keyboard. Gibbs sampling programs will ask for additional input, which you can type as prompted.

### Save the output ###

If you want to save the output log (screen messages from the program), use redirection:

~~~~~{language=shell}
blupf90 > out.txt
~~~~~

This command will not display messages on the screen, but it will still accept input. You can type the parameter file name, and the program will run. The output will be saved in `out.txt`.

### Omit the typing ###

If you prefer not to type input manually, you can use redirection. Prepare a text file that contains the name of the parameter file:

~~~~~{language=text caption="in.txt"}
parameter.txt
~~~~~

Then run the program as follows:

~~~~~{language=shell}
blupf90 < in.txt > out.txt
~~~~~

This technique is useful for Gibbs sampling programs that require several inputs. You can write multiple lines in `in.txt` instead of typing them interactively.

### Stop the program ###

To stop the program immediately, press `Ctrl + C`. You can hold the `Ctrl` key and press `C` once. The program will stop immediately, and you can safely ignore the termination messages. In some cases involving multi-threaded computation, the program may continue running even after the stop signal. In that case, close the Command Prompt window to terminate it completely.

Quick run
---------

You can also run the program without using Command Prompt:

1. Save all required files in a folder.  
2. Download the program and place it in the same folder.  
3. Double-click the program; a black window will appear.  
4. Enter the parameter file name using the keyboard. If the program asks for additional input, type the answers.  
5. Wait for the analysis to finish. Do not close the window manually. It will close automatically when the analysis is complete.  
6. Check the output files, which will be saved in the same folder.

To save the screen output (e.g., to `out.txt`), download the following batch file (`run.bat`) and place it in the same folder. Open the file with Notepad, edit the program name as needed, and save it. Then double-click `run.bat`. A black window will open, and although nothing will appear on screen, you can type the parameter file name. The program will run silently, and the output will be saved in `out.txt`.

Running the program this way (by double-clicking) is not recommended because any error message will disappear when the window closes.

~~~~~{language=text caption="run.bat"}
blupf90 > out.txt
~~~~~

This method may not work in some cases due to hidden file extensions. We do not officially support this method.
