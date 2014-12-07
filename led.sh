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
ipaddress="192.168.1.165"
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
	echo -n -e "$cmd$ctrl" | nc -w 1 -u $ipaddress $portnum
}

##########
# lightbulb type specific functions
##########
function colour {
    ##########
    # Send Command Functions
    ##########    
    function sendOnCommand {	# On command is also used to select zones
        onarray=("\x42" "\x45" "\x47" "\x49" "\x4B")
        standby="\00"
        sendCmd "${onarray[$zone]}$standby"
    }
    function selectZone {	# Select zone by sending standby cmd and sleep for a second
        sendOnCommand
        sleep 0.01
    }    
    function sendOffCommand {
        offarray=("\x41" "\x46" "\x48" "\x4A" "\x4C")
        standby="\00"
        sendCmd "${offarray[$zone]}$standby"
    }
    function sendBrightCmd {
        brightarray=("\x02" "\x04" "\x08" "\x0A" "\x0B" "\xD0" "\x10" "\x13" "\x16" "\x19" "\x1B")					
        selectZone
        bright="\x4E"
        cmd="${brightarray[$1]}"
        sendCmd "$bright$cmd"
    }
    function sendColorCmd {
        selectZone
        color="\x40"
        cmd=$1
        sendCmd "$color$cmd"
    }
    function sendWhiteCmd {
        whitearray=("\xC2" "\xC5" "\xC7" "\xC9" "\xC9")
        selectZone
        white="\00"
        cmd="${whitearray[$zone]}"
        sendCmd "$cmd$white"        
    }	
    
    ##########
    # Input Handling Functions
    ##########
    function handleOn {
        echo "You just turned colour bulbs in zone $zone on" 
        sendOnCommand	
    }
    function handleOff {
        echo "You just turned colour bulbs in zone $zone off"
        sendOffCommand	
    }
    function handleBrightness {
        if [ $param = "full" ]
        then
            echo "You turned colour bulbs in zone $zone to full brightness"
            sendBrightCmd "18"
        elif [ $param -ge 0 -a $param -le 10 ]
        then
            echo "You turned colour bulbs in zone $zone to $param"
            sendBrightCmd "$param"
        else
            echo "You've done something wrong"
        fi	
    }
    function handleColor {
        # Check to make sure that the colour specified in the array before trying
        isin=1
        if [ $param = "white" ]
        then
            echo "You just turned colour bulbs in zone $zone back to white"
            sendWhiteCmd
        else
            declare -A colours=( ["purple"]="\x00" ["blue"]="\x20" ["red"]="\xb0" ["green"]="\x60" ["yellow"]="\x80" ["pink"]="\xC0" ["orange"]="\xA0" )
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
    # Brightness
    elif [ $command = "b" ] || [ $command = "B" ]
    then
        handleBrightness
    # Color
    elif [ $command = "c" ] || [ $command = "C" ]
    then
        handleColor
    else
        echo "You've done something wrong"
    fi    
}

function white {
    ##########
    # Send Command Functions
    ##########    
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
    function sendNightCommand {
        nightarray=("\xB9\00" "\xBB\00" "\xB3\00" "\xBA\00" "\xB6\00")	
        selectZone
        sendCmd "${nightarray[$zone]}"	
    }
    function sendFullBrightCommand {
        fullbrightarray=("\xB5\00" "\xB8\00" "\xBD\00" "\xB7\00" "\xB2\00")
        selectZone
        sendCmd "${fullbrightarray[$zone]}"
    }
    function sendBrightDimCommand {
        brightDim=$1
        selectZone
        sendCmd "$brightDim\00"
    }
    function sendCoolWarmCommand {
        coolWarm=$1
        selectZone
        sendCmd "$coolWarm\00"
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
        if [ $param = "night" ]
        then
            echo "You turned white bulbs in zone $zone to night-mode"
            sendNightCommand
        elif [ $param = "full" ]
        then
            echo "You turned white bulbs in zone $zone to full brightness"
            sendFullBrightCommand
        elif [ $param = "up" ]
        then
            echo "You turned white bulbs in zone $zone up 1 brightness"
            sendBrightDimCommand "\x3C"
        elif [ $param = "down" ]
        then
            echo "You turned white bulbs in zone $zone down 1 brightness"
            sendBrightDimCommand "\x34"
        elif [ $param = "cool" ]
        then
            echo "You cooled down white bulbs in zone $zone"
            sendCoolWarmCommand "\x3f"
        elif [ $param = "warm" ]
        then
            echo "You warmed up white bulbs in zone $zone"
            sendCoolWarmCommand "\x3e"
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
                sendBrightDimCommand "\x3C"
                ;;
            2)
                echo "You turned white bulbs in zone $zone down 1 brightness"
                sendBrightDimCommand "\x34"
                ;;
            6)
                echo "You warmed up white bulbs in zone $zone"
                sendCoolWarmCommand "\x3e"
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
