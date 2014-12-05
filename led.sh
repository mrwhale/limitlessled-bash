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
function colour {
	## RGBW bulb variables and commands
	onarray=("\x42" "\x45" "\x47" "\x49" "\x4B")
    function sendOnCommand {
        standby="\00"
        sendCmd "${onarray[$zone]}$standby"
    }
    
	offarray=("\x41" "\x46" "\x48" "\x4A" "\x4C")
    function sendOffCommand {
        standby="\00"
        sendCmd "${offarray[$zone]}$standby"
    }
    
    brightarray=("\x02" "\x04" "\x08" "\x0A" "\x0B" "\xD0" "\x10" "\x13" "\x16" "\x19" "\x1B")
    function sendBrightCmd {    
        selectZone
        bright="\x4E"
        cmd=$1
        sendCmd "$bright$cmd"
    }    
    
    declare -A colours=( ["purple"]="\x00" ["blue"]="\x20" ["red"]="\xb0" ["green"]="\x60" ["yellow"]="\x80" ["pink"]="\xC0" ["orange"]="\xA0" )
    function sendColorCmd {
        selectZone
        color="\x40"
        cmd=$1
        sendCmd "$color$cmd"
    }
    
    whitearray=("\xC2" "\xC5" "\xC7" "\xC9" "\xC9")
    function sendWhiteCmd {
        selectZone
        white="\00"
        cmd=$1
        sendCmd "$cmd$white"        
    }
    
    ## Input handling
    # Brightness
	if [ $command = "b" ] || [ $command = "B" ]
	then
		if [ $param = "full" ]
		then
			echo "You turned colour bulbs in zone $zone to full brightness"
			sendBrightCmd "${brightarray[18]}"
		elif [ $param -ge 0 -a $param -le 10 ]
		then
			echo "You turned colour bulbs in zone $zone to $param"
			sendBrightCmd "${brightarray[$param]}"
		else
			echo "You've done something wrong"
	fi
    # Color
	elif [ $command = "c" ] || [ $command = "C" ]
    then
		# Check to make sure that the colour specified in the array before trying
		isin=1
		if [ $param = "white" ]
		then
			echo "You just turned colour bulbs in zone $zone back to white"
			sendWhiteCmd "${whitearray[$zone]}"
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
				sendColorCmd "${colours[$param]}"
			else
				echo "Colour $param isn't configured"
			fi
		fi
        # On
		elif [ $command = "on" ] || [ $command = "ON" ]
		then
			echo "You just turned colour bulbs in zone $zone on" 
			sendOnCommand
        # Off
		elif [ $command = "off" ] || [ $command = "OFF" ]
		then
			echo "You just turned colour bulbs in zone $zone off"
			sendOffCommand
	else
		echo "You've done something wrong"
	fi
}

function white {   
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
