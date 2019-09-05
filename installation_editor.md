---
title: Download and Installation
author: Yutaka Masuda
date: September 2019
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Setup a text editor
===================

### What is the text editor?

BLUPF90 programs use various text files.
A text file contains only characters (basic alphabet, numbers, and symbols).
Microsoft Word can read a text file but it is too heavy to edit the file.
A text editor is a category of software specialized to edit a text file.
A text editor usually supports many functions useful for the edit.
Some of them can open a very large text file.

### Well-known text editors

Typical text editors include *Notepad* (Windows), *TextEdit* (macOS), and *vi*, *Emacs*, and *nano* (Linux/Unix).
They are the default editor in each system but you can install the other editors for your convenience.
Especially in Windows, Notepad has too few features to be of practical use.
There are so many free text editors developed in Windows as well as the other systems.

Here we show several well-known, free, text editors.
Some editors are multi-platform supporting Linux, macOS, and Windows.
You can test each editor and choose your favorite one.

- Notepad++ (<https://notepad-plus-plus.org>) for Windows
- SciTE (<http://www.scintilla.org/SciTE.html>) for Windows
- Atom (<https://atom.io>) for all platforms
- Visual Studio Code (<https://code.visualstudio.com>) for all platforms

Several websites maintain a list of text editors.
A page in Wikipedia (<https://en.wikipedia.org/wiki/Comparison_of_text_editors>) is one of them.
It may help you to find your favorite.

### Edit a file over network

You may need to work with the programs remotely (you access a server over the internet and run the program on the server).
In that case, there are several ways to edit text files.
We assume the remote server is running Linux (or Unix-like environment).

 1. Use an editor on the server (perhaps vi or Emacs). You edit a file on a terminal window.
 2. Use an editor on the server but show the window on your system with X forwarding (perhaps GEdit or similar GUI editor). The editor looks working on your local computer but is actually working on the server; the editor can read and write a file on the server directly. A web site (<http://pdc-amd01.poly.edu/Xhowto.html>) explains a setting to do this.
 3. Use a local editor which can access a file on the server remotely. A few editors provide such a feature.
