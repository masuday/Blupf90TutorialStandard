---
title: Download and Installation
author: Yutaka Masuda
date: April 2025
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Setup a text editor
===================

### What is a text editor?

BLUPF90 programs use various text files. A text file contains only characters (basic alphabet, numbers, and symbols). While Microsoft Word can open text files, it is too heavy and not suitable for editing them. A text editor is a type of software specialized for editing text files. Text editors usually offer many features that are useful for editing, and some can open very large files.

### Well-known text editors

Common text editors include *Notepad* (Windows), *TextEdit* (macOS), and *vi*, *Emacs*, or *nano* (Linux/Unix). These are the default editors on each system, but you can install other editors for convenience. Notepad, in particular, has too few features to be practical in many cases. There are many free, powerful text editors available for Windows and other platforms.

Below are several well-known and free text editors. Some of them are multi-platform and support Linux, macOS, and Windows. Try a few and choose the one that suits you best:

- Notepad++ (<https://notepad-plus-plus.org>) — Windows only  
- SciTE (<http://www.scintilla.org/SciTE.html>) — Windows  
- Visual Studio Code (<https://code.visualstudio.com>) — All platforms

There are also comparison lists of text editors maintained online. For example, the Wikipedia article (<https://en.wikipedia.org/wiki/Comparison_of_text_editors>) may help you find your favorite. Lastly, if you prefer very traditional, professional editors, consider using `vi` or `Emacs`.

### Editing files over a network

You may need to run the programs on a remote server (e.g., accessing a Linux machine over the internet). In such cases, there are several ways to edit text files. Here, we assume the remote server is running Linux (or a Unix-like environment).

1. **Use a text-based editor on the server** (e.g., `vi` or `Emacs`).  
   You edit the file directly in the terminal window.

2. **Use a graphical editor on the server with X forwarding** (e.g., GEdit).  
   The editor appears to run on your local machine but is actually running on the server. It can directly read and write files on the server. A guide is available here: <http://pdc-amd01.poly.edu/Xhowto.html>

3. **Use a local editor that can access remote files**.  
   Some advanced editors (such as `Visual Studio Code`) support editing files over SSH or SFTP.
