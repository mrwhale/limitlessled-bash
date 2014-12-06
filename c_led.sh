#!/bin/bash

if [ -z $1 ]
then
        echo "You must enter a parameter:"
        echo "e.g. 'led.sh' 1 on #turns colour zone 1 on"
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
zone="$1"
command="$2"
param="$3"

##########
# Send Command Functions
##########
function sendCmd {      # Generic send any command the controller
        ctrl="\x55"
        cmd=$1
        echo -n -e "$cmd$ctrl" | nc -w 1 -u $ipaddress $portnum
}
function sendOnCommand {        # On command is also used to select zones
        onarray=("\x42" "\x45" "\x47" "\x49" "\x4B")
        standby="\00"
        sendCmd "${onarray[$zone]}$standby"
}
function selectZone {   # Select zone by sending standby cmd and sleep for a second
        sendOnCommand
        sleep 0
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
