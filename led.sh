#!/bin/bash

if [ -z $1 ]
then
    echo "You must enter a parameter:"
    echo "e.g. 'led.sh' c 1 on #turns colour zone 1 one"
    exit "1"
fi
# Wifi controller information
ipaddress="10.1.1.23"
portnum="8899"

# Script parameters
type="$1"
zone="$2"
command="$3"
param="$4"

#Colour array
declare -A colours=( ["purple"]="\x40\xF0\x55" ["blue"]="\x40\x10\x55" ["red"]="\x40\xb0\x55" ["green"]="\x40\x60\x55" ["yellow"]="\x40\x80\x55" ["pink"]="\x40\xC0\x55" ["orange"]="\x40\xA0\x55" )

function colour {
	#RGBW bulb Commands
	onarray=("\x42\00\x55" "\x45\00\x55" "\x47\00\x55" "\x49\00\x55" "\x4B\00\x55")
	offarray=("\x41\00\x55" "\x46\00\x55" "\x48\00\x55" "\x4A\00\x55" "\x4C\00\x55")
	# Array for white commands
	whitearray=("\xC2\00\x55" "\xC5\00\x55" "\xC7\00\x55" "\xC9\00\x55" "\xC9\00\x55")

	#TODO add brightness

        if [ $command = "b" ] || [ $command = "B" ]
        then
                echo "brightness"
	elif [ $command = "c" ] || [ $command = "C" ]
	then
		isin=1
		for i in "${!colours[@]}"
		do
        		if [ "$i" = "$param" ]
        		then
                		isin=0
        		fi
  		done

		if [ "$isin" -eq "0" ]
		then
			echo "You just changed colour bulbs in zone $zone to $param"
			echo -n -e "${onarray[$zone]}" >/dev/udp/$ipaddress/$portnum
			sleep 0.01
			echo -n -e "${colours[$param]}" >/dev/udp/$ipaddress/$portnum
		else
			echo "Colour $param isn't configured"
		fi
        elif [ $command = "on" ] || [ $command = "ON" ]
        then
                echo "You just turned colour bulbs in zone $zone on" 
                echo -n -e "${onarray[$zone]}" >/dev/udp/$ipaddress/$portnum
        elif [ $command = "off" ] || [ $command = "OFF" ]
        then
                echo "You just turned colour bulbs in zone $zone off"
                echo -n -e "${offarray[$zone]}" >/dev/udp/$ipaddress/$portnum
	elif [ $command = "white" ]
	then
		echo "You just turned colour bulbs in zone $zone back to white"
		echo -n -e "${onarray[$zone]}" >/dev/udp/$ipaddress/$portnum
		sleep 0.01
		echo -n -e "${whitearray[$zone]}" >/dev/udp/$ipaddress/$portnum
	else
		echo "You've done something wrong"
        fi
}

function white {
	#white commands
	onarray=("\x35\00\x55" "\x38\00\x55" "\x3D\00\x55" "\x37\00\x55" "\x32\00\x55")
	offarray=("\x39\00\x55" "\x3B\00\x55" "\x33\00\x55" "\x3A\00\x55" "\x36\00\x55")
	#TODO add brightness commands for white

	if [ $command = "b" ] || [ $command = "B" ]
	then
		echo "brightness"
	elif [ $command = "on" ] || [ $command = "ON" ]
	then
		echo "You just turned white bulbs in zone $zone on"
		echo -n -e "${onarray[$zone]}" >/dev/udp/$ipaddress/$portnum
	elif [ $command = "off" ] || [ $command = "OFF" ]
	then
		echo "You just turned white bulbs in zone $zone off"
		echo -n -e "${offarray[$zone]}" >/dev/udp/$ipaddress/$portnum
	else
		echo "You've done something wrong"
	fi
}

if [ $type = "c" ] || [ $type = "C" ]
then
	colour
elif [ $type = "w" ] || [ $type = "W" ]
then
	white
else
	echo "You've done something wrong"
fi
