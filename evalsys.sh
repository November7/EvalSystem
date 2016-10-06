#!/bin/bash

#author: Marcin Kowalski
#version: 0.1
#build: 2016.1003

#################################################################
#																#
#  checkUser -u -id -gid -p -s									#
#  checkUser --user --user-id --group-id --path --shell			#
#  return 1 if user exist with options, otherwise 0				#
#																#
#################################################################

exec 2> /dev/null

function checkUser
{
	while [[ $# -gt 1 ]]
	do
		i="$1"
		case $i in
			-u|--user)
			user=$2
			shift
			;;
			-id|--user-id)
			id=$2
			shift
			;;
			-gid|--group-id)
			gid=$2
			shift
			;;
			-p|--path)
			path=$2
			shift
			;;
			-s|--shell)
			shell=$2
			shift
			;;                    
			*)
			(>&2 echo "unknown option")
			;;
        esac
        shift
    done
	
	line=$(getent passwd "$user")	
 	
 	echo $(($(echo "$line" | wc -l) && 
		$(echo "$line" | cut -d: -f3 | grep "$id" -c) &&
		$(echo "$line" | cut -d: -f4 | grep "$gid" -c) && 
 		$(echo "$line" | cut -d: -f6 | grep "$path" -c) && 
 		$(echo "$line" | cut -d: -f7 | grep "$shell" -c)))
 	
}
#######################################

function checkFile
{
	echo $(cat "$1" | grep "$2" -c)	
}

#######################################


function checkInt
{
	while [[ $# -gt 1 ]]
	do
		i="$1"
		case $i in
			-i|--interface)
			interface=$2
			shift
			;;
			-a|--address)
			address=$2
			shift
			;;
			-m|--netmask)
			netmask=$2
			shift
			;;
			-g|--gateway)
			gateway=$2
			shift
			;;
			-d|--dns)
			dns=$2
			shift
			;;                    
			*)
			(>&2 echo "unknown option")
			;;
        esac
        shift
    done
	
	#..............
	
}

#userId Student 1000

#zm=$(parseFile /etc/passwd 1000)
#echo $zm

zm=$(checkUser -u "root" -s /bin/sh)
echo $zm

# parsing file given as first argument of this script...

grep -vE '^(\s*$|#)' $1 | while read -r line ;
do	
	eval x=($line)
	#echo "1: ${x[0]} 2: ${x[1]} 3: ${x[2]}"
done