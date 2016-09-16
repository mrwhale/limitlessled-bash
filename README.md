limitlessled-bash
=================

Command line control over limitlessLED lights (Also includes other bulbs under other names such as Milight, easyBulb, futlight)

I trolled the internet and only found snippets of stuff for limitless and command line linux,
so I decided to create a bash script myself. Primarily to run off my raspberry pi, but in theory can be used anywhere

So while I'm at my desk, I don't have to reach for my phone anymore. Just Alt+tab to my terminal and away I go

This works with v3+ of the wifi bridge (when they changed it to port 8899 instead of 5000)

Added the ability to name the zones instead of using numbers
ie
```bash
./led.sh c kitchen on
```
will turn the kitchen zone on (which in this example is zone 1. You still have to specify colour or white bulbs

## Setup
Open the script, change the ipaddress to either the IP address of the wifi controller, or the broadcast address of your LAN, save, make sure its executable, and your ready to go

## Usage
basic command is in this format: ./led.sh [type] [zone] [command] [param]
```bash
./led.sh w 1 on
```
-This will turn on zone 1 white lights
```bash
./led.sh c 0 off
```
-This will turn ALL RGBW lights off (I use 0 for global)
```bash
./led.sh w 1 b up
```
-This will turn the brightness up 1 for zone 1 white lights


All possible commands
```bash
./led.sh [type] [zone] [command] [param]

./led.sh [w,c] [0..4] [on,off,c,b] [up,down,1..10,cool,warm,full,night,red,blue,green,yellow,purple,orange,pink,white]

[type]
c - to choose the colour (RGBW) bulbs
w - to choose the white bulbs

[zone]
0 - global zone
1 - zone 1
2 - zone 2
3 - zone 3
4 - zone 4

[command]
on - turn selected lights on
off - turn selected lights off
c - choose colour of lights (use with [type] c)
b - choose brightness of the lights selected

[param]
Because of how it works, use up/down with white bulbs and 1..10 for RGBW bulb brightness
up - turn selected lights brightness up (use with [type] w, [command] b)
down - turn selected lights brightness down (use with [type] w, [command] b)
warm - warm the selected white light up 1
cool - cool the selected white light down 1
night - turn the selected lights to night mode (lowest brightness, use with [command] b)
full - turn the selected lights to full brightness (use with [command] b)
i - Enter interactive mode. can press keys to change brightness/warmth of white lights without having to enter a new cli command. Use with white lights only (use with [type] w, [command] b)
1..10 - turns selected RGBW lights brightness to coressponding value (2 = 20% etc)(use with [type] c, [command] b)
red - change the colour of the selected lights to red (use with [type] c, [command] c)
blue - change the colour of the selected lights to blue (use with [type] c, [command] c)
green - change the colour of the selected lights to green (use with [type] c, [command] c)
yellow - change the colour of the selected lights to yellow (use with [type] c, [command] c)
purple - change the colour of the selected lights to purple (use with [type] c, [command] c)
white - change the selected zone back to white (use with [type] c,[command] c)
```

So this guy had the stepping stone for me:

http://smileytechadventures.blogspot.com.au/

He created a simple script to turn on/off white lights
