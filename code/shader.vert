//precision highp float;
out vec3 pos;
out vec3 dir;
vec4 lovrmain() {
  float x = -1 + float((VertexIndex & 1) << 2);
  float y = -1 + float((VertexIndex & 2) << 1);
  UV = vec2(x, y) * .5 + .5;
  vec4 ray = vec4(UV * 2. - 1., -1., 1.);
  pos = -View[3].xyz * mat3(View);
  dir = transpose(mat3(View)) * (inverse(Projection) * ray).xyz;
  return vec4(x, y, 1., 1.);
}