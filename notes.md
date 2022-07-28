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

to list all files in folder use
    adb shell ls <folder>
like
    adb shell ls /sdcard/Android/data/org.lovr.hotswap/files/.lodr

to get a remote screenshot we can use
    adb exec-out screencap -p > Screenshots/screen_$(date +'%Y-%m-%d-%X').png


From here
https://android.stackexchange.com/questions/7686/is-there-a-way-to-see-the-devices-screen-live-on-pc-through-adb/154328#154328
we get a ADB command to get a fluid, although delayed, video stream
    adb exec-out screenrecord --output-format=h264 - |   ffplay -framerate 60 -probesize 32 -sync video  -


we can launch any app via adb, with
    adb shell monkey -p  <Package name> 1
with LODR being `org.lovr.hotswap`

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

mat4 for rototranslations are "column-major 4x4 homogeneous transformation matrices"

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

## Shaders
Shaders are  compex topic, funadmental for 3D rendering, but can be sued also for parallel high performance comuptations and for basic texturing

THe system uses a `shader = lovr.graphics.newShader([[]],[[]])` funxtion that reads raw GLSL and compiles a shader
this can then be loaded by `lovr.graphics.setShader(shader)`
Theis sader will dictate using the Verted and Fragment shaders the properties and color fo pixels rendered using this shader

all shaders can access `uniform <type> <name>` values, given by LOVR with `shader:send(<name>, <value>)`

shaders can also use ShaderBlocks to pass back and forthh more types of data, including arrays 
the code here is more complex, so make reference to https://lovr.org/docs/v0.15.0/lovr.graphics.newShaderBlock and https://lovr.org/docs/v0.15.0/ShaderBlock
a doubt is the vact that vec3 seems to need to be unpacked, but mat4 seem to be easily passed along

The shader can also be used on the entire eye image by more complex usage of canvases

### Vertex
this shader computes the 3d geometrical properties of the model, having access to parameters such as vertex position, transform matrices for the view camera, the projection matrix and more

the default is 
``` lua
    vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
    return vertex;
    }
```

values can be exfiltrated to the Fragment shader by declating a `out <type> <name>` variable and defining them in the shader code

some of the available values are 
```lua 
in vec3 lovrPosition; // The vertex position in meters, relative to the model itself
in vec3 lovrNormal; // The vertex normal vector
in vec2 lovrTexCoord;
in vec4 lovrVertexColor;
in vec3 lovrTangent;
in uvec4 lovrBones;
in vec4 lovrBoneWeights;
in uint lovrDrawID;
out vec4 lovrGraphicsColor;
uniform mat4 lovrModel; // 4x4 matrix with model world coords and rotation
uniform mat4 lovrView;
uniform mat4 lovrProjection;
uniform mat4 lovrTransform; // Model-View matrix
uniform mat3 lovrNormalMatrix; // Inverse-transpose of lovrModel
uniform mat3 lovrMaterialTransform;
uniform float lovrPointSize;
uniform mat4 lovrPose[48];
uniform int lovrViewportCount;
uniform int lovrViewID;
const mat4 lovrPoseMatrix; // Bone-weighted pose
const int lovrInstanceID; // Current instance ID
```

we also have the default function inputs of `mat4 projection, mat4 transform, vec4 vertex`

we can extract the vertex world position with 
```lua
pos = vec3(lovrModel * vertex); //gives 3d world position
```

### Fragment
The fragment shader renders the pixel itself, getting the input from the Geometry Shader and computing from that, tetxures, diffuse and emissive texttures, and other factors the color of the pixel

this is gthe default fragment shader
```lua
vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
  return graphicsColor * lovrDiffuseColor * lovrVertexColor * texture(image, uv);
}
```
with `uv` being the 2D coords of gthe face being rendered, normlaized in a [0.0 1.0] range

the standard header is 
```lua
in vec2 lovrTexCoord;
in vec4 lovrVertexColor;
in vec4 lovrGraphicsColor;
out vec4 lovrCanvas[gl_MaxDrawBuffers];
uniform float lovrMetalness;
uniform float lovrRoughness;
uniform vec4 lovrDiffuseColor;
uniform vec4 lovrEmissiveColor;
uniform sampler2D lovrDiffuseTexture;
uniform sampler2D lovrEmissiveTexture;
uniform sampler2D lovrMetalnessTexture;
uniform sampler2D lovrRoughnessTexture;
uniform sampler2D lovrOcclusionTexture;
uniform sampler2D lovrNormalTexture;
uniform samplerCube lovrEnvironmentTexture;
uniform int lovrViewportCount;
uniform int lovrViewID;
```

we can access shared values from the Vertex Shader with `in <type> <name>`



## Rotations
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


