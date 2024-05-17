---@diagnostic disable: deprecated



-- run on boot of the program, where all the setup happes
function lovr.load()

  march_shader = lovr.graphics.newShader(lovr.filesystem.read("shader.vert"),lovr.filesystem.read("shader.frag"))
  flight = {
    viewOffset = lovr.math.newVec3(0, 0, 0),
    thumbstickDeadzone = 0.3,
    speed = 1
  }
  scale = 1.
  max_scale = 32

  --palette = lovr.graphics.newTexture("./Assets/Palette1.png")
  --shader:send("palette", palette)
  local width, height = lovr.headset.getDisplayDimensions()
  local layers = lovr.headset.getViewCount()
  canvas = {
    lovr.graphics.newTexture(width, height, layers, { mipmaps = false })
  }
end

-- runs at each dt interval, where you do input and physics
function lovr.update(dt)
--  shader:send('viewPos', {lovr.headset.getPosition("head")})
--  shader:send("time", lovr.timer.getTime())
end

-- called at each frame, managed draws and GPU calls
function lovr.draw(pass)
  --lovr.graphics.clear()
  --pass:sphere()
  --  pass:reset()
  --pass:sphere()
  --lovr.graphics.setShader()
  
  pass:setColor(1, 1, 1)
  pass:setShader(march_shader)
  pass:send('viewOffset', { flight.viewOffset:unpack() })
  pass:send("scale", scale)
  pass:send("time", 0.0)
  pass:plane(vec3(1, 0, 0))
end
