# ALL WE LEARNED
## Links
### LOVR
https://lovr.org/docs/Getting_Started
https://github.com/bjornbytes/lovr
https://app.slack.com/client/T59PJ1KCJ/C59QZ4V6Y

## ADB
info can be found at 

https://developer.android.com/studio/command-line/adb
https://www.automatetheplanet.com/wp-content/uploads/2019/08/Cheat_sheet_ADB.pdf
https://developer.oculus.com/documentation/native/android/ts-adb/

use 

    adb devices -l 
to identify all connected devices


connect via usb, give permission adn give adb permission

    $ adb tcpip 5555
    restarting in TCP mode port: 5555
    $ adb connect <ip>:5555
    connected to 192.168.1.193:5555

and you're wireless!

to update the code use

    adb push --sync <local-path>/. /sdcard/Android/data/org.lovr.app/files

and for LODR

    adb push --sync <local-path>/. /sdcard/Android/data/org.lovr.hotswap/files/.lodr


If your program contains print statements, you can view them with:

    adb logcat | grep -i lovr

or even better 
    
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


### Performance 
we can access the VrApi via ADB using 

    adb logcat -s VrApi
which we can use to read various datapoints onthe state of the device

https://developer.oculus.com/documentation/native/android/po-per-frame-gpu/
https://developer.oculus.com/documentation/native/android/ts-logcat-stats/


We can also read GPU performance deatils using

    adb shell ovrgpuprofiler -m

https://developer.oculus.com/documentation/native/android/ts-ovrgpuprofiler/


performance profiling might want to keep in mind that the CPU and GPU of Ocuulus devices dynamically handle the workload
https://developer.oculus.com/documentation/native/android/mobile-power-overview/


OVRMetrics is also a powerful tool to access realtime perfromance information while inside the device, using an overlay or reporting results to CSV
It can be accessed via the Unknown Resources panel or via some ADB commands 

https://developer.oculus.com/documentation/native/android/ts-ovrmetricstool/
https://developer.oculus.com/documentation/native/android/ts-ovr-best-practices/


There are even more methods and tols to track real time performance
https://developer.oculus.com/documentation/native/android/po-book-performance/

## Controller

No support is availabe on Android rght now. only on windows through the lovr-joystick library

## LOVR and LODR
LOVR is the base, LODR give hotswapping, making it possible to almost litteraly code on the fly

## Lua
lua-users.org/files/wiki_insecure/users/thomasl/luarefv51.pdf
https://stackoverflow.com/questions/53990332/how-to-get-an-actual-copy-of-a-table-in-lua



## Math

They represent rotations, so they have also an axis of rotation 
you can also multiply a 3d vector by them and rotate it, if you multiply a coordinate vector you get that vector rotated by that quaternion, or inversly that direction in the coordinate system define by the quaternion.

mat4 for rototranslations are "column-major 4x4 homogeneous transformation matrices"

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
Acooridng to the Devs, Mat4 and Vec3 are different to other datatypes and so some need to be unpacked and some don't

The shader can also be used on the entire eye image by more complex usage of canvases

Shaders can (and probably should) be loaded from files


### Vertex
this shader computes the 3d geometrical properties of the model, having access to parameters such as vertex position, transform matrices for the view camera, the projection matrix and more

the default is 
``` glsl
    vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
    return vertex;
    }
```

values can be exfiltrated to the Fragment shader by declating a `out <type> <name>` variable and defining them in the shader code

some of the available values are 
```glsl 
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
```glsl
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
```glsl
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


### 3D Shaders
So shaders that fully cover the rendering process, not passing by the normal lover.graphincs code but do the entire work themselves

To achieve this we need the shader to fully cover the user UI and eyes.
This is acheived by:
1. define a vertex shader with `return vertex` so that n geometry transofmration is applied
2. render the scene in the fragment shader, passing info from the vertex if needed
3. in lovr, activate the shader 
4. run `lovr.graphics.fill()` 
5. remove the shader

We probably also want the exact diection and position of the pixels we'll be filling in, for that:
``` glsl
out vec3 pos;
out vec3 dir;
vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
  vec4 ray = vec4(lovrTexCoord * 2. - 1., -1., 1.);
  pos = -lovrView[3].xyz * mat3(lovrView);
  dir = transpose(mat3(lovrView)) * (inverse(lovrProjection) * ray).xyz;
  return vertex;
}
```
passes bith values to the fragment shader from the vertex one 
source: https://ifyouwannabemylovr.slack.com/archives/C59QZ4V6Y/p1659160201503029

This allows us to do custom rendering techniques like 

#### Ray Marching 
A rendering technique that's marches from the pixels backwards inside the scene.
useful for some effects seen in some videos like 
https://www.youtube.com/watch?v=PGtv-dBi2wE
https://www.youtube.com/watch?v=Cp5WWtMoeKg
https://www.youtube.com/watch?v=svLzmFuSBhk
https://www.youtube.com/watch?v=SdNb7-I1TtA

These include 3D fractals and some other cool stuff

The core point is ray marching algorithms that take the geometry and march the rays inside it, whcih is done in the fragment shader 

some codes for simole geometres can be found at https://www.shadertoy.com/view/wdf3zl
http://blog.hvidtfeldts.net/index.php/2011/08/distance-estimated-3d-fractals-iii-folding-space/
https://iquilezles.org/articles/

## Rotations
planes have defalt normal towards 0, 0, 1
idea 1: get direction between head and left hand and sue that for the center, easy to aim and to adjust, always normal to vision field
how the fuck do unpack work

## To Do
 - study GLSL define functions
 - can we make a LIDAR example
 - ping pong ball and racket
 - do some basic ffi for high performance code (?)
 - get someone to compile the requests library for you 


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
