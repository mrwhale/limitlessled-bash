limitlessled-bash
=================

Command line control over limitlessLED lights

I trolled the internet and only found snippets of stuff for limitless and command line linux,
so I decided to create a shell script myself. Primarily to run off my raspberry pi, but in theory can be used anywhere

I'm lazy, and this is my first commit, so my coding practices/standards are all over the shop. Once the functionality is there I will clean everything up :)

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
./led.sh [w,c] [0..4] [on,off,c,b] [up,down,1..10,red,blue,green,yellow,purple]
```

I will add references and thanks in when I can find the websites I got inspiration from :)
