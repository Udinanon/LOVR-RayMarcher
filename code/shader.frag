
// Pass position fo the pixel
in vec3 pos;
// Pass direction of the pixel
in vec3 dir;

Constants {
    float time; // real time 
    float scale; // parameter
    vec3 viewOffset; // for flight
//uniform sampler2D palette;
};

#define MAX_STEPS 50
#define MAX_DIST 20.

#define SURF_DIST .003 // Could a low precisoin in the positon of the ray be the cause of the jagged lines?

#define ITER 5 // Iteration for the inefficent fractals

// return distance from a box at positon pBox, of size sizeBox from position p. No rotation 
float DEBox( vec3 p, vec3 pBox, vec3 sizeBox ){
  return length(max(abs(p - pBox) - sizeBox, 0.));
}

//return distacne from a sphere at pShpere, radius rSphere, position p
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

float DEInefficentPenroseTetrahedron(vec3 z){
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
    float modSpace = 3.; // size of the mod effect, meters
    // the mod effect starts from (0,0,0) and expands only in positive diretions
    float modOffset = modSpace/2.; //offset of the mod effect from 0,0,0.
    // the sphere being rendered has position (0,0,0), so an offset is necessary as negative values are removed by the mod
    p.xz = mod((p.xz),modSpace)-vec2(modOffset); // instance on xy-plane
    // the modulo space creates  anauseating movement effect AND inverts flight controls. WHY
    vec3 zero_pos = vec3(0., 0., 0.);
    vec3 sizeBox = vec3(.5);  
    float box = DEBox(p, zero_pos, sizeBox);
    float sphere = DESphere(p, zero_pos, .7);
    //float penrose = DEPenroseTetrahedron(p);
    return sphere;
    //return max(box, -sphere);
}

// Main RayMarch loop
vec2 RayMarch(vec3 origin, vec3 direction) {
    float distance=0.; // total distance 
    int i=0; //iternations
    // over GetDist function until
    for(i=0; i<MAX_STEPS; i++) {
        vec3 position = origin + direction * distance;    //get new DE center
        float displacement = GetDist(position);
        distance += displacement; // update distance

        // stop at max distance or if near enough other entity
        if(distance > MAX_DIST || abs(displacement) < SURF_DIST) break;
    }
    // Return number of steps and distance travelled as a pair of loats
    return vec2(float(i), distance);
}

// compute normal based on partial derivatives of the distance function
vec3 GetNormal(vec3 p) {
    // get distance at the point p
	float d = GetDist(p);
    // ofsset used to extract a simple partial derivative
    vec2 e = vec2(.001, 0);

    // compyte distances in positions very nearby p, subtract them from the orignal distacne
    vec3 n = d - vec3(
    GetDist(p-e.xyy),
    GetDist(p-e.yxy),
    GetDist(p-e.yyx));
    // the results is an approximation of the normal of the surface that was closest. 
    // normalize the result and return
    return normalize(n);
}

// used to cpute lighting effects
float GetLight(vec3 p) {
    
    vec3 lightPos = vec3(0, 0, 0);
    // rotate light
    lightPos.xz += vec2(sin(time), cos(time))*2.;
    // get positions of light and surface normal
    vec3 l = normalize(lightPos-p);
    vec3 n = GetNormal(p);

    // Basic phong model
    float dif = clamp(dot(n, l), 0., 1.);
    //float d = RayMarch(p+n*SURF_DIST*2., l);
    //if(d<length(lightPos-p)) dif *= .1;

    return dif;
}

// Main function 
vec4 lovrmain() {
    vec3 position = pos + viewOffset; // add flight controls
    vec3 direction = normalize(dir);

    vec2 raymarch_result = RayMarch(position, direction);
    float steps = raymarch_result.x;
    float dist = abs(length(raymarch_result.y)); 
    vec3 p = position + direction * dist;

    float dif = GetLight(p);
    vec3 col = vec3(dif);
    //col = vec3(1.);
    //float col = 1.0;
    col.b -= (float(steps)/float(MAX_STEPS));
    col.r -= float(dist)/float(MAX_DIST);
    //ivec2 texture_size = textureSize(palette, 0);
    //vec2 coords = vec2(0, 3.*dist/float(texture_size.y));
    //vec3 color = texture(palette, coords).xyz;
    //return vec4(1., 0., 1., 1.0);
    return vec4(vec3(col), 1.0);
}