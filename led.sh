#!/bin/bash 

if [ -z "$1" ] ; then 
    echo "You must enter a parameter: "  
    echo "  e.g. .\led.sh c 1 on #turns colour zone 1 one "
    exit 1 
fi 


type="$1"
zone="$2"
command="$3"
param="$4"

function colour {
	ipaddress="10.1.1.23" 
	portnum="8899"
	#Colour Commands
	allcon="\x35\00\x55" 
	allcoff="\x39\00\x55" 
	zone1con="\x38\00\x55" 
	zone1coff="\x3B\00\x55" 
	zone2con="\x3D\00\x55" 
	zone2coff="\x33\00\x55" 
	zone3con="\x37\00\x55" 
	zone3coff="\x3A\00\x55" 
	zone4con="\x32\00\x55" 
	zone4coff="\x36\00\x55"
	#TODO add brightness and colour commands
	
	
}

function white {
	ipaddress="10.1.1.23" 
	portnum="8899"
	#white commands
	on0="\x35\00\x55" 
	off0="\x39\00\x55" 
	on1="\x38\00\x55" 
	off1="\x3B\00\x55" 
	on2="\x3D\00\x55" 
	off2="\x33\00\x55" 
	on3="\x37\00\x55" 
	off3="\x3A\00\x55" 
	on4="\x32\00\x55" 
	off4="\x36\00\x55" 
	#TODO add brightness commands for white
	zone="$1"
	command="$2"
	param="$3"
	if [ $command = "b" ] || [ $command = "B" ]
	then
		echo "brightness"
	elif [ $command = "on" ] || [ $command = "ON" ]
	then
		echo "on"
		cmd=on$zone
		echo $cmd
		eval cmd=\$$cmd
		echo -n -e "$cmd" >/dev/udp/"$ipaddress"/"$portnum"
	elif [ $command = "off" ] || [ $command = "OFF" ]
	then
		echo "off"
		cmd=off$zone
		echo $cmd
		eval cmd=\$$cmd
		echo -n -e "$cmd" >/dev/udp/"$ipaddress"/"$portnum"
	fi	
	
}

if [ $type = "c"] || [ $type = "C" ]
then
	echo "you want to turn colour lights"
	colour $zone $command $param	
elif [ $type = "w" ] || [ $type = "W" ]
then
	echo "you want to turn white"
	white $zone $command $param
fi