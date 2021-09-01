# ALL WE LEARNED

## ADB
we use adb, which is actually neat

connect via usb, give permission adn give adb permission

    $ adb tcpip 5555
    restarting in TCP mode port: 5555
    $ adb connect <ip>:5555
    connected to 192.168.1.193:5555

and you're wireless!
If your program contains print statements, you can view them with:

    adb logcat | grep -i lovr


## LOVR and LODR
LOVR is the base, LODR give hotswapping, making it possible to almost litteraly code on the fly


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

- button to add vertices of 