#!/bin/bash

# This file is managed by Puppet

# Takes two directory paths containing audit reports as arguments
# Will compare the two reports and report any differences, ignoring
# the first three lines of the report which are expected to change

if [ "$#" -ne 2 ]
then
   echo "Usage : compare_audit.sh <dir1> <dir2>"
   exit 1
fi

dir1="$1"
dir2="$2"

if [ ! -d $dir1 ]
then
   echo "$dir1 does not exist"
   exit 1
fi

if [ ! -d $dir2 ]
then
   echo "$dir2 does not exist"
   exit 1
fi

while read -r line
do
   #echo "$line"
   if echo $line | egrep -q "^Files.*differ$"
   then
      #test diff while ignoring first three lines which will always differ
      file1=`echo $line | cut -d' ' -f2`
      file2=`echo $line | cut -d' ' -f4`
      diff <(sed '1,3d' $file1) <(sed '1,3d' $file2) || echo "$file1 and $file2 differ!"
   else
      echo $line
   fi
done < <(diff -qr $dir1 $dir2)
