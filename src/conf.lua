function love.conf(t)
   -- set Window title
   t.title = "Arne's SpaceTaxi"
   t.author = "Arne Schwettmann"
   -- disable physics module to speed up loading time
   t.modules.physics = false
   -- ensure compatibility with Love 0.8.0 and Love 0.9.0
   --t.window=t.window or t.screen
   -- set window/screen flags
   --t.window.width = 0
   --t.window.height = 0
   --t.window.vsync=true
   --t.window.fullscreen=true
   --t.screen = nil
   --t.screen = t.screen or t.window
end
   
   
   
   