

-- run on boot of the program, where all the setup happes
function lovr.load()
  -- prepare for the color wheel thing
  color = {0, 1, 1, 1}
  -- this runs the physics, here we also set some global constants
  world = lovr.physics.newWorld()
  world:setLinearDamping(.01)
  world:setAngularDamping(.005)
  -- generate the floor, Kinematic means infinite mass kinda
  world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)
  -- cubes are the wireframe, boxes the physical ones
  boxes = {}
  cubes = {}
end

-- runs at each dt interval, where you do input and physics
function lovr.update(dt)
  -- update physics, like magic
  world:update(dt)
  -- if right hand trigger is pressed
  if lovr.headset.wasPressed("right", 'trigger') then
    -- create cube there with color and shift it slightly
    local th_x, th_y = lovr.headset.getAxis('right', 'thumbstick')
    local x, y, z, angle, ax, ay, az = lovr.headset.getPose("right")
    local curr_color = shallowCopy(color)
    local cube = {["pos"] = {x, y, z, .10, angle, ax, ay, az}, ["color"] = curr_color}
    color[1] = color[1]+2
    print(color[1])
    print(curr_color[1])
    -- the th_x gives us multiple cube sizes
    if th_x >= 0.75 then
      cube["pos"][4]=.20
      table.insert(cubes, cube)
    elseif th_x <= -0.75 then
      cube["pos"][4]=.05
      table.insert(cubes, cube)
    else 
      table.insert(cubes, cube)
    end
  end 

  -- if left trigger is pressed
  if lovr.headset.wasPressed("left", "trigger") then
    -- generate a physics box there
    local x, y, z = lovr.headset.getPosition("left")
    local box = world:newBoxCollider(x, y, z, .10)
    -- the velocity thing feels weird but tehre is no headset.getAccelleration
    -- maybe making a custom function but eh
    local vx, vy, vz = lovr.headset.getVelocity("left")
    box:setLinearVelocity(vx, vy, vz)
    table.insert(boxes, box)
  end

  -- when both grips are pressed, kinda finnicky but ok
  if lovr.headset.wasPressed("left", 'grip') then
      if lovr.headset.wasPressed("right", 'grip') then
        -- remove all boxes and cubes
        cubes = {}
        boxes = {}
    end 
  end
end

-- this draws obv
function lovr.draw()
  -- draw white spheres for the hands
  for i, hand in ipairs(lovr.headset.getHands()) do
    local position = vec3(lovr.headset.getPosition(hand))
    local hand_quat = quat(lovr.headset.getOrientation(hand))
    
    lovr.graphics.setColor(1, 1, 1)
    lovr.graphics.sphere(position, .01)

    lovr.graphics.setColor(1, 0, 0)
    local x_axis = lovr.math.newVec3(0, 0, -1)
    x_axis = hand_quat:mul(x_axis)
    lovr.graphics.line(position, position + x_axis * .05)

    lovr.graphics.setColor(0, 1, 0)
    local x_axis = lovr.math.newVec3(-1, 0, 0)
    x_axis = hand_quat:mul(x_axis)
    lovr.graphics.line(position, position + x_axis * .05)

    lovr.graphics.setColor(0, 0, 1)
    local x_axis = lovr.math.newVec3(0, -1, 0)
    x_axis = hand_quat:mul(x_axis)
    lovr.graphics.line(position, position + x_axis * .05)

  end

  -- draw the boxes
  for i, box in ipairs(boxes) do
    local x, y, z = box:getPosition()
    lovr.graphics.cube('fill', x, y, z, .1, box:getOrientation())
  end

  -- draw the cubes
  for i, cube in ipairs(cubes) do
    cube_color=cube["color"]
    position=cube["pos"]
---@diagnostic disable-next-line: deprecated
    local r, g, b, a=HSVToRGB(unpack(cube_color))
    lovr.graphics.setColor(r, g, b, a)
---@diagnostic disable-next-line: deprecated
    lovr.graphics.cube("line", unpack(position))
  end
end

-- utility function for the rainbow thing
function HSVToRGB(h, s, v, a)
  local c = v*s
  local x = c*(1-math.abs((h/60)%2-1))
  local m = v-c
  h = h % 360
  if h < 60 then
    return c, x, 0, a
  elseif h < 120 then
    return x, c, 0, a
  elseif h < 180 then
    return 0, c, x, a
  elseif h < 240 then
    return 0, x, c, a
  elseif h < 300 then
    return x, 0, c, a
  else
    return c, 0, x, a
  end
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