-- run on boot of the program, where all the setup happes
function lovr.load()
  lovr.graphics.setTimingEnabled(true)
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
  --lovr.graphics.setShader()
  
  pass:cube()
  pass:setShader(march_shader)
  pass:send('viewOffset', { flight.viewOffset:unpack() })
  pass:send("scale", scale)
  pass:send("time", lovr.timer.getTime())
  pass:setColor(1, 1, 1, 0)
  pass:plane()

  stats = pass:getStats()
  print('GPU Stats:')
  for k, v in pairs(stats) do
    print(k, v)
  end
  print(('Rendering in %f milliseconds'):format(stats.gpuTime * 1e3))
end
