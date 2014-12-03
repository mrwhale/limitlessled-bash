#!/bin/bash

if [ -z $1 ]
then
    echo "You must enter a parameter:"
    echo "e.g. 'led.sh' c 1 on #turns colour zone 1 one"
    exit "1"
fi

type="$1"
zone="$2"
command="$3"
param="$4"
ipaddress="10.1.1.23"
portnum="8899"

function colour {
	#Colour Commands
	on0="\x42\00\x55"
	off0="\x41\00\x55"
	on1="\x45\00\x55"
	off1="\x46\00\x55"
	on2="\x47\00\x55"
	off2="\x48\00\x55"
	on3="\x49\00\x55"
	off3="\x4A\00\x55"
	on4="\x4B\00\x55"
	off4="\x4C\00\x55"
	white0="\xC2\00\x55"
	white1="\xC5\00\x55"
	white2="\xC7\00\x55"
	white3="\xC9\00\x55"
	white4="\xC9\00\x55"
	purple="\x40\xFF\x55"
	#TODO add brightness and colour command

        if [ $command = "b" ] || [ $command = "B" ]
        then
                echo "brightness"
	elif [ $command = "c" ] || [ $command = "C" ]
	then
		echo "You just changed colour zone $zone to $param"
		cmd=on$zone
		cmd2=$param
		eval cmd=\$$cmd
		eval cmd2=\$$cmd2
		echo $cmd
		echo $cmd2
		echo -n -e "$cmd" >/dev/udp/$ipaddress/$portnum
		sleep 0.01
		echo -n -e "$cmd2" >/dev/udp/$ipaddress/$portnum
        elif [ $command = "on" ] || [ $command = "ON" ]
        then
                echo "You just turned colour zone $zone on"
                cmd=on$zone
                eval cmd=\$$cmd
                echo -n -e "$cmd" >/dev/udp/$ipaddress/$portnum
        elif [ $command = "off" ] || [ $command = "OFF" ]
        then
                echo "You just turned colour zone $zone off"
                cmd=off$zone
                eval cmd=\$$cmd
                echo -n -e "$cmd" >/dev/udp/$ipaddress/$portnum
	elif [ $command = "white" ]
	then
		echo "You just turned colour zone $zone back to white"
		cmd2=white$zone
		cmd=on$zone
		eval cmd=\$$cmd
		eval cmd2=\$$cmd2
		echo -n -e "$cmd" >/dev/udp/$ipaddress/$portnum
		sleep 0.01
		echo -n -e "$cmd2" >/dev/udp/$ipaddress/$portnum
	else
		echo "You've done something wrong"
        fi
}

function white {
	#white commands
	on0="\x35\00\x55"
	off0="\x39\00\x55"
	on1="\x38\00\x55"
	off1="\x3B\00\x55"
	on2="\x3D\00\x55"
	off2="\x33\00\x55"
	on3="\x37\00\x55"
	off3="\x3A\00\x55"
	on4="\x32\00\x55"
	off4="\x36\00\x55"
	#TODO add brightness commands for white

	if [ $command = "b" ] || [ $command = "B" ]
	then
		echo "brightness"
	elif [ $command = "on" ] || [ $command = "ON" ]
	then
		echo "You just turned white zone $zone on"
		cmd=on$zone
		eval cmd=\$$cmd
		echo -n -e "$cmd" >/dev/udp/$ipaddress/$portnum
	elif [ $command = "off" ] || [ $command = "OFF" ]
	then
		echo "You just turned white zone $zone off"
		cmd=off$zone
		eval cmd=\$$cmd
		echo -n -e "$cmd" >/dev/udp/$ipaddress/$portnum
	else
		echo "You've done something wrong"
	fi
}

if [ $type = "c" ] || [ $type = "C" ]
then
	echo "you want to turn colour lights"
	colour
elif [ $type = "w" ] || [ $type = "W" ]
then
	#echo "you want to turn white"
	white
else
	echo "You've done something wrong"
fi
