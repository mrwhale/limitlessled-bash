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
    case $param in    
        "full")
            echo "You turned colour bulbs in zone $zone to full brightness"
            sendBrightCmd "10";;
        [0-9])
            echo "You turned colour bulbs in zone $zone to $param"
            sendBrightCmd "$param";;
        *)
            echo "You've done something wrong";;
    esac
}
function handleColor {
    echo "Attempting to change colour bulbs in zone $zone to $param"
    case $param in
    "white")
        sendWhiteCmd;;
    "purple")
        sendColorCmd "\x00";;
    "blue")
        sendColorCmd "\x20";;
    "red")
        sendColorCmd "\xb0";;
    "green")
        sendColorCmd "\x60";;
    "yellow")
        sendColorCmd "\x80";;
    "pink")
        sendColorCmd "\xC0";;
    "orange")
        sendColorCmd "\xA0";;
    *)
        echo "Colour $param isn't configured";;
    esac
}

##########
# Input Parsing
##########
case $command in
    "on"|"ON")
        handleOn;;
    "off"|"OFF")
        handOff;;
    "b"|"B")
        handleBrightness;;
    "c"|"C")
        handleColor;;
    *)
        echo "You've done something wrong";;
esac
