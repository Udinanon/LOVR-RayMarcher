precision highp float;
out vec3 pos;
out vec3 dir;
vec4 lovrmain() {
  vec4 ray = vec4(UV * 2. - 1., -1., 1.);
  pos = -View[3].xyz * mat3(View);
  dir = transpose(mat3(View)) * (inverse(Projection) * ray).xyz;
  return DefaultPosition;
}