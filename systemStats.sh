#! /usr/bin/
# CREATED BY: You already know who it is
# Date Created: 5/10/2021
# Version 1

# Designed to  gather system statistics.

AUTHOR="Joel"
VERSION="2"
RELEASED="5TH OCTOBER, 2021"

# Display  help message

USAGE(){
	echo -e $1
	echo -e "\n Usage: systemStats [-t temperature] [-i ipv4 address] [-c cpu usage]"
	echo -e "\t\t [v version]"
	echo -e "\t\t For More information see man systemStats"


}


# check for arguments (error checking)
if [ $# -lt 1 ];then
	USAGE "Not enough arguments"
	exit 1
elif [ $# -gt 3 ];then
	USAGE "Too many arguments supplied"
	exit 1
elif [[ ( $1 == '-h') || ( $1 == '--help')]];then
	USAGE "Help"
	exit 1
fi

# frequently scripts are written so that arguments can be passed in any order using 'flags'
# With  the flags method, some of the arguments can be made mandatory or optional
# a:b (a is mandatory , b is optional) abc is all optional

while getopts ctiv OPTION 
do
case ${OPTION}
in
i) IP=$(ifconfig wlan0 | grep -w inet | awk '{print$2}') 
	echo ${IP};;
c) USAGE=$(grep -w 'cpu' /proc/stat | awk '{usage=($2+$3+$4+$6+$7+$8)*100/($2+$3+$4+$5+$6+$7+$8)}
					   {free=($5)*100/($2+$3+$4+$5+$6+$7+$8)}
					    END {printf "Used CPU: %.2f%%\n", usage}
					    	{printf "Free CPU: %.2f%%\n", free} ')
	echo ${USAGE};;
t) TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
	echo ${TEMP} "need to divide by thousand...";;
v) echo -e "systemStats:\n\t Version: ${VERSION} Released: ${RELEASED} Author: ${AUTHOR}";;

esac
done

#end of script
