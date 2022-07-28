---@diagnostic disable: deprecated



-- run on boot of the program, where all the setup happes
function lovr.load()
  -- this runs the physics, here we also set some global constants
  world = lovr.physics.newWorld()
  world:setLinearDamping(.01)
  world:setAngularDamping(.005)
  -- generate the floor, Kinematic means infinite mass kinda
  world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)
  -- cubes are the wireframe, boxes the physical ones
  walls = 0
  --used to track if buttons were pressed
  State = {["A"] = false, ["B"] = false, ["X"] = false, ["Y"] = false}
  function State:isNormal()
    -- check uf no state is normal
    return (not State["A"] and not State["B"] and not State["X"] and not State["Y"])
  end

  block = lovr.graphics.newShaderBlock('uniform', {
    lightPos = { 'vec4', 2 }
  }, { usage = 'static' })
  light_pos = vec3(0.0, 1.0, 0.0)
  local positions = {}
  positions[1] = {1.0, light_pos:unpack()}
  positions[2] = {1.0, 1.0, 5.0, 1.0}
  --for i = 3, 10 do
    --positions[i] = lovr.math.vec4(0.0)
  --end
  block:send("lightPos", positions)

  shader = lovr.graphics.newShader([[
    out vec3 pos;
    vec4 position(mat4 projection, mat4 transform, vec4 vertex) {
      //pos = lovrPosition.xyz; // gives poisiton relative to object cener in m, not relative to model size
      //pos = vertex.xyz; // apparenylt identical to lovrPosition
      pos = vec3(lovrModel * vertex); //gives 3d world position
      return projection * transform * vertex;
    } ]],
    [[
  in vec3 pos;
  uniform float time;
    vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) {
      //vec3 zeroed_pos = (pos+1.)/2.; 
      //vec3 zeroed_pos = (pos+0.5); // normalizes verterx coords as they are [-0.5 0.5]
      vec3 newPos = vec3(ceil(sin(50.*pos)-0.707)); // helps visualize coords thta can go beyong [0.0 1.0]
      
      //return vec4(uv.x, uv.y, 0.0, 1.0);
      //return vec4(pos.x, pos.y, pos.z,1.0);
      return vec4(newPos.x, newPos.y, newPos.z,1.0);
    }
  ]])
  shader:send('ambience', { 0.01, 0.0, 0.01, 1.0 })
  --light_table = { {1.0, 1.0, 1.0, 1.}, {1.0, 1.0, 5.0, 1.0} }
  --shader:send("lightPos", light_table)
  
  --shader:sendBlock("lightBlock", block)
  shader:send("lightColor", {0.2, 0.2, 0.2, })
end

-- runs at each dt interval, where you do input and physics
function lovr.update(dt)
  -- update physics, like magic
  world:update(dt)
  if walls == 0 then
      local width, depth = lovr.headset.getBoundsDimensions()
      world:newBoxCollider(width/2, 2, 0, 0.1, 4, depth):setKinematic(true)
      world:newBoxCollider(-width/2, 2, 0, 0.1, 4, depth):setKinematic(true)
      world:newBoxCollider(0, 2, depth/2, width, 4, 0.1):setKinematic(true)
      world:newBoxCollider(0, 2, -depth/2, width, 4, 0.1):setKinematic(true)
      walls = 1
  end

  if State:isNormal() then
    if lovr.headset.wasPressed("right", 'trigger') then
 

    end 

    -- if left trigger is pressed
    if lovr.headset.wasPressed("left", "trigger") then
    end
  end
 
  if lovr.headset.wasPressed("right", "a") then
    State["A"] = not State["A"]
  end
  if lovr.headset.wasPressed("right", "b") then
    State["B"] = not State["B"]
  end
end

-- this draws obv
function lovr.draw()
  -- draw white spheres for the hands
  for i, hand in ipairs(lovr.headset.getHands()) do
    local position = vec3(lovr.headset.getPosition(hand))
    local hand_quat = quat(lovr.headset.getOrientation(hand))

    local x_axis = lovr.math.newVec3(-1, 0, 0)
    local y_axis = lovr.math.newVec3(0, -1, 0)
    local z_axis = lovr.math.newVec3(0, 0, -1)
    x_axis = hand_quat:mul(x_axis)
    y_axis = hand_quat:mul(y_axis)
    z_axis = hand_quat:mul(z_axis)
    lovr.graphics.setColor(1, 0, 0)
    lovr.graphics.line(position, position + z_axis * .05)
    lovr.graphics.setColor(0, 1, 0)
    lovr.graphics.line(position, position + x_axis * .05)
    lovr.graphics.setColor(0, 0, 1)
    lovr.graphics.line(position, position + y_axis * .05)
    if State.isNormal() then
      lovr.graphics.setColor(1, 1, 1)
      lovr.graphics.sphere(position, .01)


    elseif State["A"] then
      lovr.graphics.setColor(1, 0, 0)
      lovr.graphics.sphere(position, .01)
        
    elseif State["B"] then
      lovr.graphics.setColor(1, 1, 1)
      lovr.graphics.sphere(position, .01)

      if hand == "hand/right" then
        lovr.graphics.setColor(1, 1, 1)
        lovr.graphics.setShader(shader)
        --shader:send("lightPos", { 0.0, 1.0, 0.0 })
        lovr.graphics.cube("fill", position, 0.2, hand_quat)
        lovr.graphics.setShader()
      end
    end
  end

 
  -- draw axes
  lovr.graphics.setColor(0, 1, 0)
  lovr.graphics.line(0, 0, 0, 1, 0, 0)
  lovr.graphics.setColor(0, 0, 1)
  lovr.graphics.line(0, 0, 0, 0, 1, 0)
  lovr.graphics.setColor(1, 0, 0)
  lovr.graphics.line(0, 0, 0, 0, 0, 1)

  local width, height = lovr.headset.getBoundsDimensions()
  lovr.graphics.setColor(0.1, 0.1, 0.11)
  lovr.graphics.box("line", 0, 0, 0, width, .05, height)

  lovr.graphics.setColor(1, 1, 1)
  lovr.graphics.box("line", width/2, 2, 0, 0.1, 4, height)
  lovr.graphics.box("line", -width/2, 2, 0, 0.1, 4, height)
  lovr.graphics.box("line", 0, 2, height/2, width, 4, 0.1)
  lovr.graphics.box("line", 0, 2, -height/2, width, 4, 0.1)
end

-- useful as LUA does the Python thing of not copying stuff
function shallowCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end