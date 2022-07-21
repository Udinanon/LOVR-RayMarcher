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

  shader = lovr.graphics.newShader([[
    out vec3 FragmentPos;
    out vec3 Normal;

    vec4 position(mat4 projection, mat4 transform, vec4 vertex) 
    { 
        Normal = lovrNormal * lovrNormalMatrix; // normal vector corrected for global model position
        FragmentPos = vec3(lovrModel * vertex); // global vertex position
        return projection * transform * vertex; 
    }
  ]], 
    [[
    uniform vec4 ambience;  
    uniform vec4 lightColor;
    uniform vec3 lightPos;

    in vec3 Normal;
    in vec3 FragmentPos;
    
    vec4 color(vec4 graphicsColor, sampler2D image, vec2 uv) 
    {    
        //diffuse
        vec3 norm = normalize(Normal);
        vec3 lightDir = normalize(lightPos - FragmentPos); // unit vector of vertex-light  
        float diff = max(dot(norm, lightDir), 0.0); // represent how exposes the fragment is
        vec4 diffuse = diff * lightColor; //apply to color
                        
        vec4 baseColor = graphicsColor * texture(image, uv); // get potential texture            
        return baseColor * (ambience + diffuse); //apply ligth and ambiance
    }
  ]])
  shader:send('ambience', { 0.01, 0.0, 0.01, 1.0 })
    
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
        lovr.graphics.sphere( position, 0.1, hand_quat)
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