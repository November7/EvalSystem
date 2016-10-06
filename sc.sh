#!/bin/bash

grep -vE '^(\s*$|#)' $1 | while read -r line ;
do
	#echo $(echo "$line") | awk '{print $1}'
	eval x=($line)
	echo "1: ${x[0]} 2: ${x[1]} 3: ${x[2]}"
done