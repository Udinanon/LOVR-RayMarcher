//precision highp float;
out vec3 pos;
out vec3 dir;
vec4 lovrmain() {
  // Extract some form of X and Y coordinate for each pixel
  // Why `VertexIndex` ??
  float x = -1 + float((VertexIndex & 1) << 2);
  float y = -1 + float((VertexIndex & 2) << 1);
  // Normalie from [-1, 1] to [0, 1] and store in UV vector
  UV = vec2(x, y) * .5 + .5;
  // Take that back and use them for the Ray, now a (x, y, -1, 1)
  vec4 ray = vec4(UV * 2. - 1., -1., 1.);
  // Get the camera positon as a vec3 by taking the negative of the translation component and transforming it using the rotation component
  pos = -View[3].xyz * mat3(View);
  // combine the rotation component of the projection matrix and of the view and the ray to get the out direction
  // How?
  dir = transpose(mat3(View)) * (inverse(Projection) * ray).xyz;
  
  // why?
  return vec4(x, y, 1., 1.);
}


