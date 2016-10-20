#!/bin/bash

# author: Marcin Kowalski
# version: 1.0
# build: 1610.18

#--------------------------------------------------------------------------------
#	
#  checkUser -u -id -gid -p -s									
#  checkUser --user --user-id --group-id --path --shell		
#  return 1 if user exist with options, otherwise 0				
#						
#--------------------------------------------------------------------------------

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
			-id|--user-id)id=$2
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

#---------------------------------- parseFile ------------------------------------
# usage: parseFile <file> <param> <value> <subvalue>
 
function parseFile
{
	if [ $(cat "$1" | grep -vE '^(\s*$|#)' | grep "$2" | grep "$3" | grep "$4" -c) -gt 0 ]; then 
		echo 1
	else 
		echo 0
	fi
}

#------------------------------- checkDHCPHost -----------------------------------
#usage checkDHCPHost <name> <hardware ethernet> <param> <value>
 
function checkDHCPHost
{
	if [ $(cat /etc/dhcp/dhcpd.conf | grep -vE '^(\s*$|#)' | awk " /host\s*$1/ {flag=1; next} /}/{flag=0} flag {print}" | grep -C 10 -E "hardware ethernet\s*$2" | grep "$3\s*$4" -c) -gt 0 ]; then 
		echo 1
	else 
		echo 0
	fi
}

#---------------------------------- checkInt -------------------------------------

function checkInt
{
	while [[ $# -gt 1 ]]
	do
		case $1 in
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
			*)
				(>&2 echo "unknown option")
				;;
		esac
		shift
	done
	line=$(ifconfig $interface)	
	echo $(($(echo $line | wc -l) &&
	$(echo $line | grep "inet addr:$address" -c) &&
	$(echo $line | grep "Mask:$netmask" -c) && 
	$(netstat -r | grep "default" | grep "$gateway" | grep "$address" | grep "$interface" -c)))
	
}

#---------------------------------- check DHCP leases ----------------------------

function checkDHCPleases
{
	awk " /lease $1/ {flag=1; next} /}/{flag=0} flag {print}" /var/lib/dhcp/dhcpd.leases | grep "hardware ethernet $2" -c
}

#------------------------------- isInstalled -------------------------------------

function isInstalled
{
	apt-cache policy $1 | grep Zainstalowana | grep -vE 'brak' -c
}

#---------------------------------- Consts ---------------------------------------

RED='\033[0;31m'
GRN='\033[0;32m'
NC='\033[0m' # No Color

#---------------------------------------------------------------------------------

if [ $# -lt 1 ];
 then exit
fi

# exec 2> /dev/null

#----------------------------------- Vars ----------------------------------------

pts=0
total=0

#---------------------------------------------------------------------------------


#clear
printf "%s\n" "-------------------------------------------------------"
printf "%s\n" "Automatyczny system oceniania."
printf "%s\n" "-------------------------------------------------------"

while read -r line 
do	
	eval part=($line)	
	if [ ${#part[@]} -eq 3 ]; then
		printf "%-50s" "${part[0]}:"
		point=`eval "${part[1]}"`
	
		if [ $point -eq 1 ]; then 
			printf "${GRN}[OK]\n${NC}"
			pts=$(($pts+${part[2]}))
		else 
			printf "${RED}[FAIL]\n${NC}" 
		fi
		total=$(($total+${part[2]}))
	else
		printf "%-50s\n" "${part[0]}"
	fi        
	
	
done < <(grep -vE '^(\s*$|#)' $1)

printf "%s\n" "-------------------------------------------------------"
grade=`bc <<< "scale=2; 100*$pts/$total"`
printf "Uzyskałeś: %d na %d punktów czyli %s%%\n" $pts $total $grade

#------------------------------------ END ----------------------------------------
