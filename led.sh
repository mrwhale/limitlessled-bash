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
#Colour array
declare -A colours=( ["purple"]="\x40\xF0\x55" ["blue"]="\x40\x10\x55" ["lightblue"]="\x40\x20\x55" ["red"]="\x40\xb0\x55" ["green"]="\x40\x60\x55" ["yellow"]="\x40\x80\x55" ["pink"]="\x40\xC0\x55" ["orange"]="\x40\xA0\x55" )

##########
# Helper functions
##########
# Generic send any command the controller
function sendCmd {
	cmd=$1
	echo -n -e "$cmd" >/dev/udp/$ipaddress/$portnum
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
	onarray=("\x42\00\x55" "\x45\00\x55" "\x47\00\x55" "\x49\00\x55" "\x4B\00\x55")
	offarray=("\x41\00\x55" "\x46\00\x55" "\x48\00\x55" "\x4A\00\x55" "\x4C\00\x55")
	# Array for white commands
	whitearray=("\xC2\00\x55" "\xC5\00\x55" "\xC7\00\x55" "\xC9\00\x55" "\xC9\00\x55")
	brightarray=("\x4E\x02\x55" "\x4E\x04\x55" "\x4E\x08\x55" "\x4E\x0A\x55" "\x4E\x0B\x55" "\x4E\xD0\x55" "\x4E\x10\x55" "\x4E\x13\x55" "\x4E\x16\x55" "\x4E\x19\x55" "\x4E\x1B\x55")

	if [ $command = "b" ] || [ $command = "B" ]
	then
		if [ $param = "full" ]
		then
			echo "You turned colour bulbs in zone $zone to full brightness"
			selectZone
			cmd="\x4E\x3B\x55"
			sendCmd $cmd
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
	onarray=("\x35\00\x55" "\x38\00\x55" "\x3D\00\x55" "\x37\00\x55" "\x32\00\x55")
	offarray=("\x39\00\x55" "\x3B\00\x55" "\x33\00\x55" "\x3A\00\x55" "\x36\00\x55")
	fullbrightarray=("\xB5\00\x55" "\xB8\00\x55" "\xBD\00\x55" "\xB7\00\x55" "\xB2\00\x55")
	nightarray=("\xB9\00\x55" "\xBB\00\x55" "\xB3\00\x55" "\xBA\00\x55" "\xB6\00\x55")

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
   	                sendCmd "${fullbrightarray[$zone]}"
		elif [ $param = "up" ]
		then
			echo "You turned white bulbs in zone $zone up 1 brightness"
			selectZone
			cmd="\x3C\00\x55"
			sendCmd "$cmd"
		elif [ $param = "down" ]
		then
    	                echo "You turned white bulbs in zone $zone down 1 brightness"
          	        selectZone
			cmd="\x34\00\x55"
			sendCmd "$cmd"
        	elif [ $param = "cool" ]
		then
	                echo "You cooled down white bulbs in zone $zone"
	                selectZone
			cmd="\x3f\00\x55"
	                sendCmd "$cmd"
	        elif [ $param = "warm" ]
		then
	                echo "You warmed up white bulbs in zone $zone"
	                selectZone
			cmd="\x3e\00\x55"
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
	           		        echo "You turned white bulbs in zone $zone up 1 brightness"
		                        selectZone
					cmd="\x3C\00\x55"
	              		        sendCmd "$cmd"
					;;
				2)
	                	        echo "You turned white bulbs in zone $zone down 1 brightness"
            		        	selectZone
					cmd="\x34\00\x55"
		                        sendCmd "$cmd"
					;;
				4)
	                        	echo "You cooled down white bulbs in zone $zone"
	            		        selectZone
					cmd="\x3f\00\x55"
		                        sendCmd "$cmd"
					;;
				6)
        	                	echo "You warmed up white bulbs in zone $zone"
	                    		selectZone
					cmd="\x3e\00\x55"
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
