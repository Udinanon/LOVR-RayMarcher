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


  shader = lovr.graphics.newShader(lovr.filesystem.read("shader.vert"),lovr.filesystem.read("shader.frag"))
  flight = {
    viewOffset = lovr.math.newVec3(0, 0, 0),
    thumbstickDeadzone = 0.3,
    speed = 1
  }
  shader:send('viewOffset', {flight.viewOffset:unpack()})
  scale = 1.
  max_scale = 32
  shader:send("scale", scale)
  shader:send("time", 0.0)

  palette = lovr.graphics.newTexture("./Assets/Palette1.png")
  shader:send("palette", palette)
  State["B"] = true
end

-- runs at each dt interval, where you do input and physics
function lovr.update(dt)
  shader:send('viewPos', {lovr.headset.getPosition("head")})
  shader:send("time", lovr.timer.getTime())
  local eye_pos = vec3(lovr.headset.getViewPose(1));
  shader:send("eye0", { eye_pos })
  eye_pos = vec3(lovr.headset.getViewPose(2));
  shader:send("eye1", { eye_pos })

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
  if State["B"] then
    local x, y = lovr.headset.getAxis('right', 'thumbstick')
    local direction = quat(lovr.headset.getOrientation("head")):direction()
    if math.abs(x) > flight.thumbstickDeadzone then
      local strafeVector = quat(-math.pi / 2, 0, 1, 0):mul(vec3(direction))
      flight.viewOffset:add(strafeVector * x * flight.speed * dt)
    end
    if math.abs(y) > flight.thumbstickDeadzone then
      flight.viewOffset:add(direction * y * flight.speed * dt)
    end
    shader:send('viewOffset', {flight.viewOffset:unpack()})
  end
  if lovr.headset.wasPressed("right", "a") then
    State["A"] = not State["A"]
    scale = scale * 2 
    if scale > max_scale then
      scale = 1
    end
    shader:send("scale", scale)
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


    elseif State["B"] then
      lovr.graphics.setColor(1, 1, 1)
      lovr.graphics.sphere(position, .01)

      if hand == "hand/right" then
        lovr.graphics.setColor(1, 1, 1)
        lovr.graphics.setShader(shader)
        --shader:send("lightPos", { 0.0, 1.0, 0.0 })
        --lovr.graphics.cube("fill", position, 0.2, hand_quat)
        print(lovr.headset.getViewPose(1))
        print(vec3(lovr.headset.getViewPose(1)))
        local eye_pos = vec3(lovr.headset.getViewPose(1));

        shader:send("eye0", { eye_pos })
        eye_pos = vec3(lovr.headset.getViewPose(2));
        shader:send("eye1", { eye_pos})
        print(lovr.headset.getViewCount())
        lovr.graphics.clear()
        lovr.graphics.fill()
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