limitlessled-bash
=================

Command line control over limitlessLED lights

I trolled the internet and only found snippets of stuff for limitless and command line linux,
so I decided to create a shell script myself. Primarily to run off my raspberry pi, but in theory can be used anywhere

I'm lazy, and this is my first commit, so its are all over the shop. Once the functionality is there I will clean everything up :)

This works with v3+ of the wifi bridge (when they changed it to port 8899 instead of 5000)

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
./led.sh [w,c] [0..4] [on,off,c,b] [up,down,1..10,red,blue,green,yellow,purple,night,full]

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
up - turn selected lights brightness up (use with [command] b)
down - turn selected lights brightness down (use with [command] b)
red - change the colour of the selected lights to red (use with [type] c, [command] c)
blue - change the colour of the selected lights to blue (use with [type] c, [command] c)
green - change the colour of the selected lights to green (use with [type] c, [command] c)
yellow - change the colour of the selected lights to yellow (use with [type] c, [command] c)
purple - change the colour of the selected lights to purple (use with [type] c, [command] c)
night - turn the selected lights to night mode (lowest brightness, use with [command] b)
full - turn the selected lights to full brightness (use with [command] b)
```


So this guy had the stepping stone for me:

http://smileytechadventures.blogspot.com.au/

He created a simple script to turn on/off white lights
