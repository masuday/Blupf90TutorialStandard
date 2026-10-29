---
title: Download and Installation
author: Yutaka Masuda
date: August 2026
subject: "Introduction to BLUPF90 suite programs"
tags: [introduction,tutorial]
...

Running a program in Linux and macOS
====================================

Command-line software
---------------------

BLUPF90 programs are command-line software. Each program reads a parameter file describing the names of the data and pedigree files, the model, and the covariance components used in the analysis. It displays log messages on the screen and writes one or more output files. These programs are designed to run in a shell environment with keyboard input.

Here, we assume a standard Bash environment. On macOS, all operations are performed in Terminal. No graphical user interface (GUI) is used.

**Note:** Currently, only Intel-based Macs are supported. Newer Macs with Apple M-series (ARM-based) CPUs are not supported.

Installation
------------

No special installation procedure is required. Simply download the program from the official website. Then, change its permissions using `chmod`, for example, `chmod 755` or `chmod u+x` (a helpful way to remember: _ch_ange the _mod_e to add execute permission _+x_ for the _u_ser). You can move the program to your preferred directory, which may already be listed in your `PATH` environment variable. If not, you can create such a directory and move the program there.

Here is an example:

~~~~~{language=shell}
# 1. Download the program. You can also use curl or another method.
# Note that, if it doesn't work, you should download it using a browser manually.
wget https://nce.ads.uga.edu/html/projects/programs/Linux/64bit/blupf90+

# 2. Change the permissions to make it executable.
chmod 755 blupf90+

# 3. Create a directory for binaries, if it doesn't exist.
mkdir ~/bin

# 4. Move the program to that directory.
mv blupf90+ ~/bin
~~~~~

You can use other tools, such as `curl`, instead of `wget` to download the file. If the directory (e.g., `~/bin`) is not listed in your `PATH` environment variable, you need to add it. Check the current `PATH` using:

~~~~~{language=shell}
echo $PATH
~~~~~

If your directory is listed, you are all set. If not, add it by typing:

~~~~~{language=shell}
export PATH=~/bin:$PATH
~~~~~

If the program is located in a different directory, replace `~/bin` with the correct path. This setting is temporary and will disappear when you log out. To make it permanent, add the command to your `.bash_profile`. If you are unsure how to do this, open `.bash_profile` with a text editor and add the line at the end. Log out and log back in for the change to take effect.

Installing dependencies on Ubuntu 24.04 (Intel MKL runtime)
------------------------------------------------------------

Starting in 2025, new BLUPF90 binaries are compiled with a recent Intel Fortran compiler (`ifx`) and linked against the Intel MKL (Math Kernel Library). Running these binaries on a machine that does not have the Intel MKL runtime libraries installed will fail with an error such as:

~~~~~{language=shell}
./blupf90+: error while loading shared libraries: libmkl_intel_lp64.so.2: cannot open shared object file: No such file or directory
~~~~~

This is *not* a file-permission or `PATH` problem it means the MKL shared libraries (`.so` files) that the program needs at runtime are missing from the system. The steps below describe how to install them on Ubuntu 24.04 (tested on Ubuntu 24.04 LTS, "noble").

### 1. Install the Intel MKL runtime via the official oneAPI APT repository

The BLUPF90 authors recommend installing the Intel Fortran Libraries (which include MKL) from Intel's own oneAPI distribution, rather than the older `libmkl-intel-lp64` package available in Ubuntu's `multiverse` repository. The Ubuntu package tends to be an older MKL release and may not match the ABI expected by the newest BLUPF90 binaries.

~~~~~{language=shell}
# Prerequisites
sudo apt update
sudo apt install -y gpg-agent wget

# Add Intel's GPG key and oneAPI APT repository
wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB | \
  gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" | \
  sudo tee /etc/apt/sources.list.d/oneAPI.list

sudo apt update

# Install just the MKL and Fortran runtime packages (much lighter than the full toolkit)
sudo apt install intel-oneapi-mkl intel-oneapi-runtime-fortran intel-oneapi-runtime-libs
~~~~~

This installs the libraries under `/opt/intel/oneapi/`.

### 2. Load the oneAPI environment

Intel provides a `setvars.sh` script that configures `LD_LIBRARY_PATH` (and other variables) so the dynamic linker can find the MKL libraries. Source it in your shell (add this line to `~/.bashrc` to make it permanent, or run it manually in each new session):

~~~~~{language=shell}
source /opt/intel/oneapi/setvars.sh
~~~~~

Note that `setvars.sh` refuses to run twice in the same shell session unless you pass `--force`; this is expected behavior and not an error.

### 3. Check for missing libraries

Use `ldd` to confirm all shared libraries required by the binary are found:

~~~~~{language=shell}
ldd ./blupf90+ | grep "not found"
~~~~~

An empty result means everything was found. If some libraries are still reported as `not found`, keep reading.

### 4. Version mismatch between the binary and the installed MKL (`.so.2` vs `.so.3`)

The MKL shared library file names include a version number in the `SONAME` (e.g., `libmkl_intel_lp64.so.2`). This number changed between MKL releases: MKL 2025.x and earlier ship `.so.2`, while the APT `oneAPI` repository may install a newer release (e.g., 2026.x) that ships `.so.3` instead. If the BLUPF90 binary was compiled against an older MKL, `ldd` will keep reporting the `.so.2` files as missing even though the (renamed) libraries are present on disk, for example:

~~~~~{language=shell}
libmkl_intel_lp64.so.2 => not found
libmkl_intel_thread.so.2 => not found
libmkl_core.so.2 => not found
~~~~~

First, locate where the installed libraries actually are:

~~~~~{language=shell}
find /opt/intel/oneapi -name "libmkl_intel_lp64*"
find /opt/intel/oneapi -name "libmkl_core*"
~~~~~

If you find `.so.3` files but not `.so.2` (e.g., under `/opt/intel/oneapi/mkl/<version>/lib/`), you have two options:

**Option A - Install the exact older MKL version that ships `.so.2` (cleaner)**

~~~~~{language=shell}
apt-cache madison intel-oneapi-mkl
sudo apt install intel-oneapi-mkl=<version-that-ships-so.2>
~~~~~

**Option B - Create symbolic links (quick workaround, used in this tutorial)**

The classic MKL interface (LP64/BLAS/LAPACK) is normally binary-compatible across these releases, so linking the old file name to the new file generally works in practice:

~~~~~{language=shell}
cd /opt/intel/oneapi/mkl/<version>/lib
sudo ln -s libmkl_intel_lp64.so.3 libmkl_intel_lp64.so.2
sudo ln -s libmkl_core.so.3 libmkl_core.so.2
sudo ln -s libmkl_intel_thread.so.3 libmkl_intel_thread.so.2
sudo ldconfig
~~~~~

Replace `<version>` with the folder name found in the previous step (e.g., `2026.1`). After creating the links, re-run:

~~~~~{language=shell}
ldd ./blupf90+ | grep "not found"
~~~~~

An empty result confirms the program can now find all required libraries, and `./blupf90+` should start normally and prompt for the parameter file name.

**Note:** if you later update the `intel-oneapi-mkl` package to a new version, the version folder under `/opt/intel/oneapi/mkl/` may change and the symbolic links above will need to be re-created for the new folder.

Running a program
-----------------

Navigate to the directory that contains all the required files (e.g., the pedigree, data, and parameter files). Then, type the program name to start it. If the program launches successfully, you will see a message like:

~~~~~{language=shell}
name of parameter file?
~~~~~

At this prompt, type the name of the parameter file. Some programs, especially those that perform Gibbs sampling, require additional inputs. The messages will appear on the screen (standard output), and you can save them to a file using redirection:

~~~~~{language=shell}
# Save standard output to a file.
# The program still accepts input even if nothing is shown.
blupf90+ > out.txt

# Save standard output to a file while also displaying it on screen.
blupf90+ | tee out.txt
~~~~~

You can also avoid entering the initial input manually:

~~~~~{language=shell}
# Provide the parameter file name via echo.
echo parameter.txt | blupf90+

# Alternatively, use an input file.
echo parameter.txt > input
blupf90+ < input
~~~~~

The second method is especially useful for Gibbs sampling programs that require several lines of input.

Stop a program
--------------

To stop the program immediately, press `Ctrl + C`. For convenience, you can hold down `Ctrl` and tap `C`. The program will terminate immediately, and any resulting messages can be safely ignored. In some cases, especially during multithreaded computations, the program may continue running after receiving the stop signal. If that happens, simply close the terminal window to stop the program completely.

Does the program not start?
--------------

When you try to run the program, it may stop immediately with the following or a similar message.

~~~~~{language=shell}
blupf90+: error while loading shared libraries: libmkl_intel_lp64.so.2: cannot open shared object file: No such file or directory
~~~~~

This means that you need additional software on which the BLUPF90 programs depend. Please check the next section, "Additional Settings," or the official webpage of the University of Georgia.
