in vec3 pos;
in vec3 dir;

uniform float time;
uniform float scale;
uniform vec3 viewOffset;
uniform sampler2D palette;

#define MAX_STEPS 50
#define MAX_DIST 10.
#define SURF_DIST .003 // Could a low precisoin in the posotion of the ray be the cause of the jagged lines?
#define SPONGE_ITER 5

float sdBox( vec3 p, vec3 b )
{
  vec3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float GetDist(vec3 p) {
   float d = sdBox(p,vec3(1.0));

   float s = 1.;
   for( int m=0; m<SPONGE_ITER; m++ )   {
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

vec2 RayMarch(vec3 ro, vec3 rd) {
    float dO=0.; // total distance 
    int i=0; //iternations
    for(i=0; i<MAX_STEPS; i++) {
        vec3 p = ro + rd*dO;    //get new DE center
        float dS = GetDist(p/scale)*scale;
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
    vec3 ro = pos + viewOffset;
    vec3 rd = normalize(dir);

    vec2 tmp = RayMarch(ro, rd);
    float steps = tmp.x;
    float dist = abs(length(tmp.y)); 
    //vec3 p = ro + rd * d;

    //float dif = GetLight(p);
    //vec3 col = vec3(dif);
    float col = 1.0;
    col -= 1.3 * (float(steps)/float(MAX_STEPS));
    col -= float(dist)/float(MAX_DIST);
    if (dist > MAX_DIST-2.){
        return vec4(vec3(.0), 1.);
    }
    ivec2 texture_size = textureSize(palette, 0);
    vec2 coords = vec2(0, 3.*dist/float(texture_size.y));
    vec3 color = texture(palette, coords).xyz;
    return vec4(color,1.0);
}