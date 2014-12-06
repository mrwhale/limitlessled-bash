#!/bin/bash

if [ -z $1 ]
then
	echo "You must enter a parameter:"
	echo "e.g. 'led.sh' c 1 on #turns colour zone 1 one"
	exit "1"
fi

##########
# Config
##########
# Wifi controller information
ipaddress="10.1.1.23"
portnum="8899"

##########
# Input
##########
# Script parameters
zone="$1"
command="$2"
param="$3"

##########
# Helper functions
##########
# Generic send any command the controller
function sendCmd {
	ctrl="\x55"
    cmd=$1
	echo -n -e "$cmd$ctrl" >/dev/udp/$ipaddress/$portnum
}
# Select zone by sending standby cmd and sleep for a second
function selectZone {
    standby="\00"
	sendCmd "${onarray[$zone]}$standby"
	sleep 0.01
}

##########
# lightbulb type specific functions
##########
#white commands
onarray=("\x35" "\x38" "\x3D" "\x37" "\x32")
offarray=("\x39" "\x3B" "\x33" "\x3A" "\x36")
fullbrightarray=("\xB5\00" "\xB8\00" "\xBD\00" "\xB7\00" "\xB2\00")
nightarray=("\xB9\00" "\xBB\00" "\xB3\00" "\xBA\00" "\xB6\00")
#TODO add brightness commands for white
	
if [ $command = "b" ] || [ $command = "B" ]
then
	if [ $param = "night" ]
	then
		echo "You turned white bulbs in zone $zone to night-mode"
		selectZone
		sendCmd "${nightarray[$zone]}"
	elif [ $param = "full" ]
	then
		echo "You turned white bulbs in zone $zone to full brightness"
		selectZone
		sendCmd "${nightarray[$zone]}"
	elif [ $param = "up" ]
	then
		cmd="\x3C\00"
		echo "You turned white bulbs in zone $zone up 1 brightness"
		selectZone
		sendCmd "$cmd"
	elif [ $param = "down" ]
	then
		cmd="\x34\00"
		echo "You turned white bulbs in zone $zone down 1 brightness"
		selectZone
		sendCmd "$cmd"
	elif [ $param = "cool" ]
	then
		cmd="\x3f\00"
		echo "You cooled down white bulbs in zone $zone"
		selectZone
		sendCmd "$cmd"
		elif [ $param = "warm" ]
	then
		cmd="\x3e\00"
		echo "You warmed up white bulbs in zone $zone"
		selectZone
		sendCmd "$cmd"
	elif [ $param = "i" ]
	then
		echo "Press CTRL+C to exit interactive mode"
		echo "Make sure you have numlock ON when using numpad"
		for (( ; ; ))
		do
			read -s -n 1 var
			case $var in
			8)
				cmd="\x3C\00"
				echo "You turned white bulbs in zone $zone up 1 brightness"
				selectZone
				sendCmd "$cmd"
				;;
			2)
				cmd="\x34\00"
				echo "You turned white bulbs in zone $zone down 1 brightness"
				selectZone
				sendCmd "$cmd"
				;;
			4)
				cmd="\x3f\00"
				echo "You cooled down white bulbs in zone $zone"
				selectZone
				sendCmd "$cmd"
				;;
			6)
				cmd="\x3e\00"
				echo "You warmed up white bulbs in zone $zone"
				selectZone
				sendCmd "$cmd"
				;;
			*)
				echo "wrong key pressed"
			esac
		done
	else
		echo "You've done something wrong"
	fi
elif [ $command = "on" ] || [ $command = "ON" ]
then
	echo "You just turned white bulbs in zone $zone on"
	standby="\00"
	sendCmd "${onarray[$zone]}$standby"
elif [ $command = "off" ] || [ $command = "OFF" ]
then
	echo "You just turned white bulbs in zone $zone off"
	standby="\00"
	sendCmd "${offarray[$zone]}$standby"
else
	echo "You've done something wrong"
fi
