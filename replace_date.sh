#!/bin/sh

if [ -z "$1" ]; then
   echo "usage: $0 date"
   exit 1
fi

# the current date
date=$1

# for the Markdown files
for mdfile in *.md; do
   echo $mdfile
   perl -i.bak -pe "s/^date: [A-Za-z, ]*[0-9]*$/date: $date/" $mdfile
done

# for the LaTeX file
echo tutorial_blupf90.tex
perl -i.bak -pe "s/^\\\\date.*$/\\\\date{$date}/" tutorial_blupf90.tex
