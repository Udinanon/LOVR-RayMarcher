# ALL WE LEARNED
## Links
LOVR
https://lovr.org/docs/Getting_Started
https://github.com/bjornbytes/lovr
https://twitter.com/bjornbytes
https://app.slack.com/client/T59PJ1KCJ/C59QZ4V6Y
ADB
https://www.automatetheplanet.com/wp-content/uploads/2019/08/Cheat_sheet_ADB.pdf



## ADB
we use adb, which is actually neat

use 
    adb devices -l 
to identify all connected devices

connect via usb, give permission adn give adb permission

    $ adb tcpip 5555
    restarting in TCP mode port: 5555
    $ adb connect <ip>:5555
    connected to 192.168.1.193:5555

and you're wireless!

to udapte the  code use

    adb push --sync <local-path>/. /sdcard/Android/data/org.lovr.app/files

and for LODR

    adb push --sync <local-path>/. /sdcard/Android/data/org.lovr.hotswap/files/.lodr


If your program contains print statements, you can view them with:

    adb logcat | grep -i lovr

or even bettter 
    
    adb logcat -s LOVR

### More commands

to list all files in folder use
    adb shell ls <folder>
like
    adb shell ls /sdcard/Android/data/org.lovr.hotswap/files/.lodr

## Controller

No support is availabe on Android rght now. only on windows through the lovr-joystick library

## LOVR and LODR
LOVR is the base, LODR give hotswapping, making it possible to almost litteraly code on the fly

## Lua
lua-users.org/files/wiki_insecure/users/thomasl/luarefv51.pdf
https://stackoverflow.com/questions/53990332/how-to-get-an-actual-copy-of-a-table-in-lua


## want
- i want a class/functipojn that gives me all pressed buttons and joystick positions
can0t find anything specific un the docs

DeviceButton 

    Buttons on an input device.
    Value	Description
    trigger	The trigger button.
    thumbstick	The thumbstick.
    touchpad	The touchpad.
    grip	The grip button.
    menu	The menu button.
    a	The A button.
    b	The B button.
    x	The X button.
    y	The Y button.
    proximity	The proximity sensor on a headset.


- automate sync and grep woth vscode

- button to add vertices of sofa and other mobilia

## Math

Quaternions are cool but i need to wathc some more 3b1b now
They represent rotations, so they have also an axis of rotation 
you can also multiply a 3d vector by them and rotate it, if you mmultiply a cooridnate vector you get that vector rotated by that quaternion, or inversly that direction in the coordinate system define by the quaternion. Magic

## Theater
 
### 2D Images
planes are much comfier than boxes and don't need cubemaps
Canvases can render 3d things in a different place, project them onside the canvas and display as a  texture. Neat
using graphics.fill we can also just push a Image inside. this image is streched
we use a blank Image, paste our content, fill the canvas woith it and use that maybe

I want to then test some basics in moving the box around, maybe the pointer library could be useful
netflix screeen is pretty easy and good, but i wnat to project this on the vo correctly i think

perhaps more interesting content would help us
### moar
next is loading images from interesting sources

then we could test some audio reproduction

The end goal is a 3D media room with mobile seating and screen and some basic media selection and playback control
Should handle both video audio and images, from local sources and maybe something more

## Graphics
rendering tetures on 2d objects needs shaders, which is shit
BUT we can use canvases to generate the textures, apply the caonvas to a Material and then we don0t need them!
better

printing single color blobs didn0t work, maybe writing them to disk will be better
this can be done with
    lovr.filesystem.write("whatever.txt", blob)
and then 
    adb pull /sdcard/Android/data/org.lovr.hotswap/files/whatever.txt

local points = lovr.headset.getBoundsGeometry() returns an ungodly number of points

the standard shader admits only onem light source


## rotations
planes have defalt normal towards 0, 0, 1
idea 1: get direction between head and left hand and sue that for the center, easy to aim and to adjust, always normal to vision field
how the fuck do unpack work

## Comicbook

### design
A0-1-2-3-4-5 sheet in right hand
no phisycs, floats or is held
Button to switch to landscape for large pages
script to unfold complicated folder structure into a single comic for the program to handle
rotation correction whole in hand? maybe centered to head? some form of smoothing!?!

### controller
Index spwns and despawns
Middle holds, toggle
AB to switch pages
LS to try cycle sizes
Stick for rotation?

### tech
how do i read zip files - i think i can't natively so images it is
or i need jpeg folders


yeah, can we make a file explorer too?
we can start with a basic grid one and think about it later 

canvases work but image is dark, need to investigate
volumes would be nices but need cubemapping
rotation is needed
grab works, need to center image in plane 


## LuaJIT-requests


https://github.com/LPGhatguy/luajit-request
include needed
    local request = require("luajit-request")

### lua-cJson

i hate it cause i have to compile it and i don0t htink i can make it actually work oh god
i'll have to ask the guy on slack
### e6


favorites are accesible with login
posts=requests.get(BASE_URL+"/favorites.json",params={"limit":"300"},  headers=header)

print(len(posts.json()["posts"]))
sleep(2)

favourites can be found through tags, they don't require login
there exists a rndom function not documented

can request posts with any tag, cnlcuding favourites without login
https://e621.net/posts.json?tags=fav:colev0

posts = requests.get(BASE_URL+"/posts/random.json",
                    params={"tags": "fav:Mr_Bones4Smash"},  headers=HEADER).content
USERNAME = "Mr_Bones4Smash"
posts = requests.get(BASE_URL+"/posts.json",
                    params={"tags": "fav:"+USERNAME}, headers=HEADER).json()
posts = requests.get(BASE_URL+"/posts.json",params={"tags":"hells_angels"}, headers=HEADER).json()
pprint(posts["posts"][0])





## Simple ideas
simple graph visual in 3d
ping pong ball and racket
some experiemtns with shaders