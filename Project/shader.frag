in vec3 pos;
uniform vec3 viewPos;
uniform float time;
vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
    //vec3 newPos = vec3(ceil(sin(50.*pos)-0.707)); // helps visualize coords that can go beyong [0.0 1.0]
    float depth1 = pow(distance(pos, viewPos), 4.);
    float depth2 = pow(distance(pos, viewPos), 4.5);
    float depth3 = pow(distance(pos, viewPos), 5.);

    return vec4(depth1, depth2, depth3, 1.0);
}