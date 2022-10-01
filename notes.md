# Notes
## Links
### LOVR
https://lovr.org/docs/Getting_Started
https://github.com/bjornbytes/lovr
https://app.slack.com/client/T59PJ1KCJ/C59QZ4V6Y

## ADB
More infod about ADB can be found at:
 - [Official ADB Docs](https://developer.android.com/studio/command-line/adb)
 - [ADB CheatSheet](https://www.automatetheplanet.com/wp-content/uploads/2019/08/Cheat_sheet_ADB.pdf)
 - [Coulus ADB Docs](https://developer.oculus.com/documentation/native/android/ts-adb/)
### Useful Commands
To identify all connected devices use 

    adb devices -l 

To go wireless:
connect via usb, give permission adn give adb permission

    $ adb tcpip 5555
    restarting in TCP mode port: 5555
    $ adb connect <ip>:5555
    connected to 192.168.1.193:5555


To update the code use

    adb push --sync <local-path>/. /sdcard/Android/data/org.lovr.app/files

or for LODR

    adb push --sync <local-path>/. /sdcard/Android/data/org.lovr.hotswap/files/.lodr


If your program contains print statements, you can view them with:

    adb logcat | grep -i lovr

or even better 
    
    adb logcat -s LOVR


To list all files in a folder use

    adb shell ls <folder>
like

    adb shell ls /sdcard/Android/data/org.lovr.hotswap/files/.lodr


To get a remote screenshot use

    adb exec-out screencap -p > Screenshots/screen_$(date +'%Y-%m-%d-%X').png


From [here](https://android.stackexchange.com/questions/7686/is-there-a-way-to-see-the-devices-screen-live-on-pc-through-adb/154328#154328) we get a ADB command to get a fluid, although delayed, video stream

    adb exec-out screenrecord --output-format=h264 - |   ffplay -framerate 60 -probesize 32 -sync video  -


we can launch any app via adb, with

    adb shell monkey -p  <Package name> 1
with LODR being `org.lovr.hotswap` and LOVR being `org.lovr.app`


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


OVRMetrics is also a powerful tool to access realtime perfromance information while inside the device, using an overlay or reporting results to CSV. 
It can be accessed via the Unknown Resources panel or via some ADB commands 

https://developer.oculus.com/documentation/native/android/ts-ovrmetricstool/

https://developer.oculus.com/documentation/native/android/ts-ovr-best-practices/


There are even more methods and tols to track real time performance

https://developer.oculus.com/documentation/native/android/po-book-performance/

## Controller

No support is availabe on Android rght now. only on windows through the lovr-joystick library

## LOVR and LODR
These two versions are basically the same, with LODR being an official fork with hotswapping support, making for an even faster development cycle. No need to restart LOVR, LODR detects that the project files changed and restart automatically. 

Or you can just add the restart to your adb command


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
the code here is more complex, so make reference to the [New Shader Block Docs](https://lovr.org/docs/v0.15.0/lovr.graphics.newShaderBlock) and [Shader Block Docs](https://lovr.org/docs/v0.15.0/ShaderBlock)
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
```glsl
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
So shaders that fully cover the rendering process, not passing by the normal lovr.graphics code but do the entire work themselves

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
passes both values to the fragment shader from the vertex one.
[code source](https://ifyouwannabemylovr.slack.com/archives/C59QZ4V6Y/p1659160201503029)

This allows us to do custom rendering techniques like 

#### Ray Marching 
A rendering technique that marches rays from the pixels inside the scene.
Useful for some effects seen in some videos like 
 - [Ray Marching for Dummies!](https://www.youtube.com/watch?v=PGtv-dBi2wE)
 - [Coding Adventure: Ray Marching](https://www.youtube.com/watch?v=Cp5WWtMoeKg)
 - [How to Make 3D Fractals](https://www.youtube.com/watch?v=svLzmFuSBhk)
 - [Ray marching In a nutshell - Signed Distance Function](https://www.youtube.com/watch?v=SdNb7-I1TtA)

These include 3D fractals and some other cool stuff

The merger sponge was very inefficent due to inefficencies and not using the recursive space.
This means that more efficent fractals are perfectly possible, we just need to use a better method

Wathcnig the code generated by PySpace, the idea is great, you can generate the needed glsl code on the fly with python, but the results are not fast enough on my laptop and i think the same will happen on the Headset, the code has options to be rendered not in live to make videos, so that's probably how he made the videos. Or maybe using a powerful GPU it could be done?

Union: min(a, b)
Intersect: max(a, b)
DIfference: max(a, -b)

some codes for simple geometres can be found at 
 - https://www.shadertoy.com/view/wdf3zl
 - http://blog.hvidtfeldts.net/index.php/2011/08/distance-estimated-3d-fractals-iii-folding-space/
 - https://iquilezles.org/articles/

## Network
### LuaJIT-requests

The [Libary](https://github.com/LPGhatguy/luajit-request) rlises upon libcurl, which needs to be compiled and added to the plugin folder of the APK file before installing, in `lib/arm64-v8a`

```lua
    request = require("luajit-request")
```

it supports GET and POST, file streams, custom headers and more

Documentation is sacrce and the est way is just reading the `init.lua` file to understand how to pass arguments.

You might also want to look up [HTTP specifications](https://developer.mozilla.org/en-US/docs/Web/HTTP) to correctly build the header 

User agent is passed via a custom header component:
```lua
    local head_table ={}
    head_table["User-Agent"]="MyUserAgent/0.1"
    local response = request.send(URL, { headers = head_table })
```

### JSON
Lua is not batteries included, so we need a JSON parsing library.

The fastest is [Lua-cJSON](https://github.com/bjornbytes/lua-cjson) which is a compiled plugin based on a C library, faster but also needs to be added to the APK.

For pure Lua we have [luanjson](https://github.com/grafi-tt/lunajson) and [json.lua](https://github.com/rxi/json.lua), both valid and quite efficent, with no need to compile or inject libraries, and fast enough for simple website API access
