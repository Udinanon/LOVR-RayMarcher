out vec3 pos;
vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
  //pos = lovrPosition.xyz; // gives poisiton relative to object cener in m, not relative to model size
  //pos = vertex.xyz; // apparenylt identical to lovrPosition
  pos = vec3(lovrModel * vertex); //gives 3d world position
  return projection * transform * vertex;
} 