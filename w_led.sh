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
function sendCmd { # Generic send any command the controller
    ctrl="\x55"
    cmd=$1
    echo -n -e "$cmd$ctrl" | nc -w 1 -u $ipaddress $portnum
}
function sendOnCommand {    # On command is also used to select zones
    onarray=("\x35" "\x38" "\x3D" "\x37" "\x32")
    standby="\00"
    sendCmd "${onarray[$zone]}$standby"
}
function selectZone {    # Select zone by sending standby cmd and sleep for a second
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
    case $param in
        "night")
            echo "You turned white bulbs in zone $zone to night-mode"
            sendNightCommand;;
        "full")
            echo "You turned white bulbs in zone $zone to full brightness"
            sendFullBrightCommand;;
        "up")
            echo "You turned white bulbs in zone $zone up 1 brightness"
            sendBrightDimCommand "\x3C";;
        "down")
            echo "You turned white bulbs in zone $zone down 1 brightness"
            sendBrightDimCommand "\x34";;
        "cool")
            echo "You cooled down white bulbs in zone $zone"
            sendCoolWarmCommand "\x3f";;
        "warm")
            echo "You warmed up white bulbs in zone $zone"
            sendCoolWarmCommand "\x3e";;
        *)
            echo "You've done something wrong"    
    esac
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
            sendBrightDimCommand "\x3C";;
        2)
            echo "You turned white bulbs in zone $zone down 1 brightness"
            sendBrightDimCommand "\x34";;
        4)
            echo "You cooled down white bulbs in zone $zone"
            sendCoolWarmCommand "\x3f";;
        6)
            echo "You warmed up white bulbs in zone $zone"
            sendCoolWarmCommand "\x3e";;
        *)
            echo "wrong key pressed"
        esac
    done
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
        if [ $param = "i" ]
        then
            handleInteractive
        else
            handleBrightness
        fi;;
    *)
        echo "You've done something wrong";;
esac
