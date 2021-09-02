-- idk what this actually dose, it doesn0t really work
--[[ function lovr.load()
  models = {
      left = lovr.headset.newModel('hand/left'),
      right = lovr.headset.newModel('hand/right')
  }
end ]]

function shallowcopy(orig)
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

function lovr.load()
  color = {0, 1, 1, 1}
  world = lovr.physics.newWorld()
  world:setLinearDamping(.01)
  world:setAngularDamping(.005)
  world:newBoxCollider(0, 0, 0, 50, .05, 50):setKinematic(true)
  boxes = {}
  cubes = {}
end

function lovr.update(dt)
  world:update(dt)

  if lovr.headset.wasPressed("right", 'trigger') then
    local th_x, th_y = lovr.headset.getAxis('right', 'thumbstick')
    local x, y, z, angle, ax, ay, az = lovr.headset.getPose("right")
    local curr_color = shallowcopy(color)
    local cube = {["pos"] = {x, y, z, .10, angle, ax, ay, az}, ["color"] = curr_color}
    color[1] = color[1]+2
    print(color[1])
    print(curr_color[1])
    
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

  if lovr.headset.wasPressed("left", "trigger") then
    local x, y, z = lovr.headset.getPosition("left")
    local box = world:newBoxCollider(x, y, z, .10)
    local vx, vy, vz = lovr.headset.getVelocity("left")
    box:setLinearVelocity(vx, vy, vz)
    table.insert(boxes, box)
  end

  if lovr.headset.wasPressed("left", 'grip') then
      if lovr.headset.wasPressed("right", 'grip') then
        cubes={}
    end 
  end
end

function lovr.draw()
  for i, hand in ipairs(lovr.headset.getHands()) do
    local position = vec3(lovr.headset.getPosition(hand))
    local direction = quat(lovr.headset.getOrientation(hand)):direction()
    lovr.graphics.setColor(1, 1, 1)
    lovr.graphics.sphere(position, .01)
    
  end

  for i, box in ipairs(boxes) do
    local x, y, z = box:getPosition()
    lovr.graphics.cube('fill', x, y, z, .1, box:getOrientation())
  end

  for i, cube in ipairs(cubes) do
    cube_color=cube["color"]
    position=cube["pos"]
    local r, g, b, a=HSVToRGB(unpack(cube_color))
    lovr.graphics.setColor(r, g, b, a)
    lovr.graphics.cube("line", unpack(position))
  end
end

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