
in vec3 pos;
in vec3 dir;

uniform float time;

#define MAX_STEPS 100
#define MAX_DIST 100.
#define SURF_DIST .01

float GetDist(vec3 p) {
	vec4 s = vec4(0, 1.7, -1, .5);

  float sphereDist =  length(p-s.xyz)-s.w;
  float planeDist = p.y;

  float d = min(sphereDist, planeDist);
  return d;
}

float RayMarch(vec3 ro, vec3 rd) {
  float dO=0.;
  for(int i=0; i<MAX_STEPS; i++) {
    vec3 p = ro + rd*dO;
    float dS = GetDist(p);
    dO += dS;
    if(dO>MAX_DIST || dS<SURF_DIST) break;
  }
  return dO;
}

vec3 GetNormal(vec3 p) {
	float d = GetDist(p);
  vec2 e = vec2(.01, 0);

  vec3 n = d - vec3(
    GetDist(p-e.xyy),
    GetDist(p-e.yxy),
    GetDist(p-e.yyx));

  return normalize(n);
}

float GetLight(vec3 p) {
  vec3 lightPos = vec3(0, 5, 6);
  lightPos.xz += vec2(sin(time), cos(time))*2.;
  vec3 l = normalize(lightPos-p);
  vec3 n = GetNormal(p);

  float dif = clamp(dot(n, l), 0., 1.);
  float d = RayMarch(p+n*SURF_DIST*2., l);
  if(d<length(lightPos-p)) dif *= .1;

  return dif;
}

vec4 color(vec4 gcolor, sampler2D image, vec2 uv) {
  vec3 ro = pos;
  vec3 rd = normalize(dir);

  float d = RayMarch(ro, rd);
  vec3 p = ro + rd * d;

  float dif = GetLight(p);
  vec3 col = vec3(dif);

  return vec4(col,1.0);
}