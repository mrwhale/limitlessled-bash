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
type="$1"
zone="$2"
command="$3"
param="$4"

##########
# Global constants
##########
#Constant bits
ctrl="\x55"
#Colour array
declare -A colours=( ["purple"]="\x40\x00" ["blue"]="\x40\x20" ["red"]="\x40\xb0" ["green"]="\x40\x60" ["yellow"]="\x40\x80" ["pink"]="\x40\xC0" ["orange"]="\x40\xA0" )

##########
# Helper functions
##########
# Generic send any command the controller
function sendCmd {
	cmd=$1
	echo -n -e "$cmd$ctrl" >/dev/udp/$ipaddress/$portnum
}
# Select zone by sending standby cmd and sleep for a second
function selectZone {
	sendCmd "${onarray[$zone]}"
	sleep 0.01
}

##########
# lightbulb type specific functions
##########
function colour {
	#RGBW bulb Commands
	onarray=("\x42\00" "\x45\00" "\x47\00" "\x49\00" "\x4B\00")
	offarray=("\x41\00" "\x46\00" "\x48\00" "\x4A\00" "\x4C\00")
	# Array for white commands
	whitearray=("\xC2\00" "\xC5\00" "\xC7\00" "\xC9\00" "\xC9\00")
	brightarray=("\x4E\x02" "\x4E\x04" "\x4E\x08" "\x4E\x0A" "\x4E\x0B" "\x4E\xD0" "\x4E\x10" "\x4E\x13" "\x4E\x16" "\x4E\x19" "\x4E\x1B")
	#TODO add brightness
		
		if [ $command = "b" ] || [ $command = "B" ]
		then
		if [ $param = "full" ]
		then
			cmd="\x4E\x3B"
			echo "You turned colour bulbs in zone $zone to full brightness"
			selectZone
			sendCmd "$cmd"
		elif [ $param -ge 0 -a $param -le 10 ]
		then
			echo "You turned colour bulbs in zone $zone to $param"
			selectZone
			sendCmd "${brightarray[$param]}"
		else
			echo "You've done something wrong"
		fi
	elif [ $command = "c" ] || [ $command = "C" ]
	then
		# Check to make sure that the colour specified in the array before trying
		isin=1
		if [ $param = "white" ]
		then
			echo "You just turned colour bulbs in zone $zone back to white"
            selectZone
			sendCmd "${whitearray[$zone]}"
		else
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
				selectZone
				sendCmd "${colours[$param]}"
			else
				echo "Colour $param isn't configured"
			fi
		fi
		elif [ $command = "on" ] || [ $command = "ON" ]
		then
			echo "You just turned colour bulbs in zone $zone on" 
			sendCmd "${onarray[$zone]}"
		elif [ $command = "off" ] || [ $command = "OFF" ]
		then
			echo "You just turned colour bulbs in zone $zone off"
			sendCmd "${offarray[$zone]}"
	else
		echo "You've done something wrong"
		fi
}

function white {
	#white commands
	onarray=("\x35\00" "\x38\00" "\x3D\00" "\x37\00" "\x32\00")
	offarray=("\x39\00" "\x3B\00" "\x33\00" "\x3A\00" "\x36\00")
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
		sendCmd "${onarray[$zone]}"
	elif [ $command = "off" ] || [ $command = "OFF" ]
	then
		echo "You just turned white bulbs in zone $zone off"
		sendCmd "${offarray[$zone]}"
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
