#!/bin/bash
# find-and-do.sh
find /home/ -name 'timthumb.php' -type f -printf '%h\n' | while read line
do
#Remove the old thumb
rm -rf $line/timthumb.php
 
#Copy fixed thumb
cp timthumb-fix.php $line/timthumb.php
 
echo $line " done";
done