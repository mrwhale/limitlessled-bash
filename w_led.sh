#!/bin/bash

if [ -z $1 ]
then
	echo "You must enter a parameter:"
	echo "e.g. 'led.sh' 1 on #turns white zone 1 on"
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
# Send Command Functions
##########
function sendCmd { # Generic send any command the controller
	ctrl="\x55"
    cmd=$1
	echo -n -e "$cmd$ctrl" >/dev/udp/$ipaddress/$portnum
}
function sendOnCommand {	# On command is also used to select zones
	onarray=("\x35" "\x38" "\x3D" "\x37" "\x32")
	standby="\00"
	sendCmd "${onarray[$zone]}$standby"
}
function selectZone {	# Select zone by sending standby cmd and sleep for a second
	sendOnCommand
	sleep 0.01
}
function sendOffCommand {
	offarray=("\x39" "\x3B" "\x33" "\x3A" "\x36")
	standby="\00"
	sendCmd "${offarray[$zone]}$standby"
}

##########
# Input Handling Functions
##########
function handleOn {
	echo "You just turned white bulbs in zone $zone on"
	sendOnCommand	
}
function handleOff {
	echo "You just turned white bulbs in zone $zone off"
	sendOffCommand	
}
function handleBrightness {
	fullbrightarray=("\xB5\00" "\xB8\00" "\xBD\00" "\xB7\00" "\xB2\00")
	nightarray=("\xB9\00" "\xBB\00" "\xB3\00" "\xBA\00" "\xB6\00")	
	if [ $param = "night" ]
	then
		echo "You turned white bulbs in zone $zone to night-mode"
		selectZone
		sendCmd "${nightarray[$zone]}"
	elif [ $param = "full" ]
	then
		echo "You turned white bulbs in zone $zone to full brightness"
		selectZone
		sendCmd "${fullbrightarray[$zone]}"
	elif [ $param = "up" ]
	then
		echo "You turned white bulbs in zone $zone up 1 brightness"
		selectZone
		sendCmd "\x3C\00"
	elif [ $param = "down" ]
	then
		echo "You turned white bulbs in zone $zone down 1 brightness"
		selectZone
		sendCmd "\x34\00"
	elif [ $param = "cool" ]
	then
		echo "You cooled down white bulbs in zone $zone"
		selectZone
		sendCmd "\x3f\00"
	elif [ $param = "warm" ]
	then
		echo "You warmed up white bulbs in zone $zone"
		selectZone
		sendCmd "\x3e\00"
	else
		echo "You've done something wrong"
	fi		
}
function handleInteractive {
	echo "Press CTRL+C to exit interactive mode"
	echo "Make sure you have numlock ON when using numpad"
	for (( ; ; ))
	do
		read -s -n 1 var
		case $var in
		8)
			echo "You turned white bulbs in zone $zone up 1 brightness"
			selectZone
			sendCmd "\x3C\00"
			;;
		2)
			echo "You turned white bulbs in zone $zone down 1 brightness"
			selectZone
			sendCmd "\x34\00"
			;;
		4)
			echo "You cooled down white bulbs in zone $zone"
			selectZone
			sendCmd "\x3f\00"
			;;
		6)
			echo "You warmed up white bulbs in zone $zone"
			selectZone
			sendCmd "\x3e\00"
			;;
		*)
			echo "wrong key pressed"
		esac
	done
}

##########
# Input Parsing
##########
if [ $command = "on" ] || [ $command = "ON" ]
then
	handleOn
elif [ $command = "off" ] || [ $command = "OFF" ]
then
	handleOff
elif [ $command = "b" ] || [ $command = "B" ]
then
	if [ $param = "i" ]
	then
		handleInteractive
	else
		handleBrightness
	fi
else
	echo "You've done something wrong"
fi