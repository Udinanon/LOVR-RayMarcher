in vec3 pos;
in vec3 dir;

uniform float time;
uniform float scale;
uniform vec3 viewOffset;
uniform sampler2D palette;

#define MAX_STEPS 50
#define MAX_DIST 10.
#define SURF_DIST .003 // Could a low precisoin in the posotion of the ray be the cause of the jagged lines?
#define ITER 5

float DEBox( vec3 p, vec3 pBox, vec3 sizeBox ){
  return length(max(abs(p - pBox) - sizeBox, 0.));
}

float DESphere(vec3 p, vec3 pSphere, float rSphere){
    return length(p - pSphere.xyz) - rSphere;
}

float DEInefficentMergerSponge(vec3 p){ // inefficent but valid merger sponge
    float s = 1.;
    float d = 0.;
    for(int m=0; m<ITER; m++ ){
        vec3 a = mod( p*s, 2.)-1.;
        s *= 3.0;
        vec3 r = abs(1.0 - 3.0*abs(a));
        float da = max(r.x,r.y);
        float db = max(r.y,r.z);
        float dc = max(r.z,r.x);
        float c = (min(da,min(db,dc))-1.0)/s;
        d = max(d,c);
    }
    return d;
}

float DEInefficentPenroseTetrahedron(vec3 z)
{
    float r;
    vec3 Offset = vec3(0.5);
    float Scale = 2.;
    int n = 0;
    while (n < ITER) {
       if(z.x+z.y<0.) z.xy = -z.yx; // fold 1
       if(z.x+z.z<0.) z.xz = -z.zx; // fold 2
       if(z.y+z.z<0.) z.zy = -z.yz; // fold 3	
       z = z*Scale - Offset*(Scale-1.0);
       n++;
    }
    return (length(z) ) * pow(Scale, -float(n));
}

float GetDist(vec3 p) {
    float modSpace = 1.; // size of the mod effect, meters
    // the mod effect starts from (0,0,0) and expands only in positive diretions
    float modOffset = modSpace/2.; //offset of the mod effect from 0,0,0.
    // the sphere being rendered has position (0,0,0), so an offset is necessary as negative values are removed by the mod
    p.xyz = mod((p.xyz),modSpace)-vec3(modOffset); // instance on xy-plane
    // the modulo space creates  anauseating movement effect AND inverts flight controls. WHY
    vec3 zero_pos = vec3(0., 0., 0.);
    vec3 sizeBox = vec3(.5);  
    float box = DEBox(p, zero_pos, sizeBox);
    float sphere = DESphere(p, zero_pos, .7);
    //float penrose = DEPenroseTetrahedron(p);
    return max(box, -sphere);
}

vec2 RayMarch(vec3 ro, vec3 rd) {
    float dO=0.; // total distance 
    int i=0; //iternations
    for(i=0; i<MAX_STEPS; i++) {
        vec3 p = ro + rd*dO;    //get new DE center
        float dS = GetDist(p);
        //float random = 1. - ((fract(sin(dot(rd.xy,vec2(12.9898,78.233)))*43758.5453123)+1.)/10.); // random 1. - [.0, .2]
        //ds *= random; // add random component
        dO += dS; // update distance
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
    ro += viewOffset; // add flight controls
    vec3 rd = normalize(dir);

    vec2 tmp = RayMarch(ro, rd);
    float steps = tmp.x;
    float dist = abs(length(tmp.y)); 
    //vec3 p = ro + rd * d;

    //float dif = GetLight(p);
    //vec3 col = vec3(dif);
    float col = 1.0;
    col -= (float(steps)/float(MAX_STEPS));
    col -= float(dist)/float(MAX_DIST);

    //ivec2 texture_size = textureSize(palette, 0);
    //vec2 coords = vec2(0, 3.*dist/float(texture_size.y));
    //vec3 color = texture(palette, coords).xyz;
    return vec4(vec3(col), 1.0);
}