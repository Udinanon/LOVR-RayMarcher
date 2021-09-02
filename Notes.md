# ALL WE LEARNED
## help
https://app.slack.com/client/T59PJ1KCJ/C59QZ4V6Y

## ADB
we use adb, which is actually neat

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

- see if Canvases can be used for 2d animation/videos

- automate sync and grep woth vscode

- button to add vertices of sofa and other mobilia