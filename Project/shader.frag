precision lowp float; //no significant effect on jagged lines issue
in vec3 pos;
in vec3 dir;

uniform float time;

#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .005 // Could a low precisoin in the posotion of the ray be the cause of the jagged lines?

float GetDist(vec3 p) {
    vec3 pSphere = vec3(0.4, 0.4, 0.4);
    float modSpace, modOffset   , rSphere;
    rSphere = 0.4; //used by the DE code of the sphere, seems to be the sphere's radius
    modSpace = 1.; // size of the mod effect, meters
    // the mod effect starts from (0,0,0) and expands only in positive diretions
    modOffset = .0; //offset of the mod effect from 0,0,0.
    // the sphere being rendered has position (0,0,0), so an offset is necessary as negative values are removed by the mod
    p.xyz = mod((p.xyz),modSpace)-vec3(modOffset); // instance on xy-plane
    vec3 cBox = vec3(.4, .4, .4);
    vec3 sizeBox = vec3(.3,.3,.3);  
    float DEBox = length(max(abs(p - cBox) - sizeBox, 0.)); // Box DE
    float DESphere = length(p - pSphere.xyz) - rSphere; // sphere DE
    return DESphere;
}

vec2 RayMarch(vec3 ro, vec3 rd) {
    float dO=0.; // total distance 
    int i=0; //iternations
    for(i=0; i<MAX_STEPS; i++) {
        vec3 p = ro + rd*dO;    //get new DE center
        float dS = GetDist(p);
        float random = 1. - ((fract(sin(dot(rd.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123)+1.)/10.); // random 1. - [.0, .2]
        dO += dS*random; // update distance
        // the random parameters seems to help with the banding issue, which has not been determined yet
        if(dO>MAX_DIST || abs(dS)<SURF_DIST) break;
    }
    return vec2(float(i), dO);
}

vec3 GetNormal(vec3 p) {
	float d = GetDist(p);
    vec2 e = vec2(.001, 0);

    vec3 n = d - vec3(
    GetDist(p-e.xyy),
    GetDist(p-e.yxy),
    GetDist(p-e.yyx));

    return normalize(n);
}

float GetLight(vec3 p) {
    vec3 lightPos = vec3(0, 0, 0);
    lightPos.xz += vec2(sin(time), cos(time))*2.;
    vec3 l = normalize(lightPos-p);
    vec3 n = GetNormal(p);

    float dif = clamp(dot(n, l), 0., 1.);
    //float d = RayMarch(p+n*SURF_DIST*2., l);
    //if(d<length(lightPos-p)) dif *= .1;

    return dif;
}

vec4 color(vec4 gcolor, sampler2D image, vec2 uv) {
    vec3 ro = pos;
    vec3 rd = normalize(dir);

    vec2 tmp = RayMarch(ro, rd);
    float steps = tmp.x;
    float dist = abs(length(tmp.y)); 
    //vec3 p = ro + rd * d;

    //float dif = GetLight(p);
    //vec3 col = vec3(dif);
    float col = 1.0 - float(steps)/float(MAX_STEPS);
    col -= float(dist)/float(MAX_DIST);
    return vec4(vec3(col),1.0);
}