precision highp float;
out vec3 pos;
out vec3 dir;
vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
  vec4 ray = vec4(lovrTexCoord * 2. - 1., -1., 1.);
  pos = -lovrView[3].xyz * mat3(lovrView);
  dir = transpose(mat3(lovrView)) * (inverse(lovrProjection) * ray).xyz;
  return vertex;
}