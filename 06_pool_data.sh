#!/bin/bash 
FILES=$(find ./ -type f -name "ChIP*.bw")
for f in $FILES
do
  cp $f ./all_data
done
