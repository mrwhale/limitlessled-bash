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
# Colour (RGBW) light bulbs
##########
function colour {
    ##########
    # Send Command Functions
    ##########
    function sendCmd {      # Generic send any command the controller
        ctrl="\x55"
        cmd=$1
	# Try sending to /dev/udp, if that fails use netcat
	echo -n -e "$cmd$ctrl" >/dev/udp/$ipaddress/$portnum || echo -n -e "$cmd$ctrl" | nc -w 1 -u $ipaddress $portnum
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
            handleOff;;
        "b"|"B")
            handleBrightness;;
        "c"|"C")
            handleColor;;
        *)
            echo "You've done something wrong";;
    esac
}

##########
# Dual white light bulbs
##########
function white {
    ##########
    # Send Command Functions
    ##########
    function sendCmd {      # Generic send any command the controller
        ctrl="\x55"
        cmd=$1
	# Try sending to /dev/udp, if that fails use netcat
        echo -n -e "$cmd$ctrl" >/dev/udp/$ipaddress/$portnum || echo -n -e "$cmd$ctrl" | nc -w 1 -u $ipaddress $portnum
    }    
    function sendOnCommand {    # On command is also used to select zones
        onarray=("\x35" "\x38" "\x3D" "\x37" "\x32")
        standby="\00"
        sendCmd "${onarray[$zone]}$standby"
    }
    function selectZone {    # Select zone by sending standby cmd and sleep for a second
        sendOnCommand
        sleep 0
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
            handleOff;;
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
}

case $type in
    "c"|"C")
        colour;;
    "w"|"W")
        white;;
    *)
        echo "You've done something wrong";;
esac
