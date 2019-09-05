Introduction to BLUPF90 suite programs
======================================

Written by Yutaka Masuda

Quick links
-----------

- [Index](./index.md)
- [PDF documentation](https://github.com/masuday/Blupf90TutorialStandard/releases)

How can I build the documentation?
----------------------------------

You need the following tools.

- [Pandoc](https://pandoc.org/) v2.5.0 or later
- pdfLaTeX
- Make and Bash

Simply type the `make` command in the repository on Bash, and the programs generate a PDF file in `pdf/` and HTML files in `html/`.

~~~~~
make
~~~~~

To cleanup, run `make` with the argument.

~~~~~
make clean
~~~~~

How can I modify the note?
--------------------------

### Simple way

1. Make a fork of this repository in your account.
2. Modify the file online; select the file, edit it, and commit it.
3. After the edit, make a _pull request_.
4. Wait the response.

### Another way

1. Make a branch.
2. Modify the files and commit it.
3. Make a pull request.
