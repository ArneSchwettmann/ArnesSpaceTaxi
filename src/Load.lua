function love.load()
   debug=false
   debugVariable=0
   
   --all globals listed here
   
   infiniteMass=1e10
   oneOverSqrt2=0.70710678
   
   gfxDir="gfx/"
   sndDir="snd/"
   
   width = 400
   height = 300
   centerX = 200
   centerY = 125
   statusBarHeight=50
   
   touching = false
   -- gamepad touch button sizes as fraction of displaywidth
   dPadButtonSizeRel = 0.1
   fireButtonSizeRel = 0.3

   
   defaultAudioSourceZPos = 0.5 -- controls the amount of stereo panning, 0 is absolute only left/right, 1 is barely noticeable panning
   
   desktopWidth=0 -- fullscreen size, will be populated later
   desktopHeight=0 -- fullscreen size, will be populated later
   fullscreenWidth=0
   fullscreenHeight=0
   vSyncEnabled=false -- vsync limits the fps, can do more timesteps then
   borderX = 0 -- black border in fullscreen mode
   borderY = 0 -- black border in fullscreen mode
   fullscreen = false -- whether we are in fullscreen mode
   graphicsScaleFactor = 1.0 -- whether we are scaling the gfx in fullscreen
   
   showFPS = false -- display FPS?
     
   shadowOffsetX=8
   shadowOffsetY=8
   numPlayers=1
   maxNumPlayers=5
   
 	gameIsPaused = false
   gameWasPaused = true
   waitingForClick = false
   gameWon = false
   displayingTitleScreen = true
   displayingControlScreen = false
   
   timeSinceUnpausing=0
   timeToWaitAfterPause=0.025
   timeSinceLastFrame=0
	--timeSinceLastDraw=0
   numTimeStepsPerFrame = 1
   
   maxVelocity = 2000 -- not used
	minVelocity = 1/60 -- not used
   fuelConsumption = 0.0075 -- was 0.015 a bit too fast
   refuelSpeed = 0.2
   refuelCost = 30 -- cost for a full tank
   tipConsumption = 0.75
   initialTip = 25
   roughLandingTipReductionFactor = 0.5
   passengerDeathPenalty=0 -- no penalty
   
   maxLandingVelocity = 17.25
   roughLandingThreshold = 0.85
   thrusterForceMagnitude = 250
   
   numLevels=getNumLevels()
   passengersLeft=5
   currentLevel=0
   numPassengers=0
   timeSinceLastPassenger=0
   currentLevel=1
   objects={}
   resurrectingObjects={}
   animations={}
   soundEffects={}
   passengerVoices={}
   thrusterAudioSource={}
   refuelingAudioSource={}
   musicAudioSource={}
   screens={} -- title and win screens
   background={}
   backgroundMask={}
   passengerRespawnPoints={} -- coordinates where passengers can spawn
   playerRespawnPoints={} -- coordinates where players can spawn in free space
   playerReferences={} -- reference to alive and dead player objects by playernumber, only updated once a frame
   respawningPlayers={} -- queue of players trying to respawn, the last element in here is the first player to respawn
   liveImages={} -- an image for each player for the status bar, sorted by playerNumber
   passengerLiveImage={} -- same but for a passenger
   playersEscaped={} -- queue of player objects that have escaped the current level, the last element is the first player that escaped
   
   inputX={0,0,0,0,0}
   inputY={0,0,0,0,0}
   inputButton={false,false,false,false,false}
   oldInputButton={false,false,false,false,false}
   
   joysticks={}
   numJoysticks=0
   
   controls={
      1,
      2,
      3,
      4,
      5,
   }
   
   controlTypes={
      "Keyboard 1",
      "Keyboard 2",
      "Joystick 1",
      "Joystick 2",
      "Joystick 3",
      "Joystick 4",
      "Joystick 5",
   }

   objectTypes = {
      "player",
      "passenger",
      "forceField",
      "thruster",
   }
   objectSubTypes = {
      "player1NoGear",
      "player1Gear",
      "player1NoGearRight",
      "player1GearRight",
      "player2NoGear",
      "player2Gear",
      "player2NoGearRight",
      "player2GearRight",
      "player3NoGear",
      "player3Gear",
      "player3NoGearRight",
      "player3GearRight",
      "player4NoGear",
      "player4Gear",
      "player4NoGearRight",
      "player4GearRight",
      "player5NoGear",
      "player5Gear",
      "player5NoGearRight",
      "player5GearRight",
      "passenger1Male",
      "passenger1MaleRight",
      "oneOverRSquaredForceField",
      "constantForceField",
      "thruster",
   }
   animationTypes = {
      "none",
      "destroyed",
      "walking",
      "waving",
      "appearing",
      "roughLanding",
      "up",
      "facingLeftDown",
      "facingRightDown",
      "left",
      "right"
   }

   numPassengerOutfits=1
   numPassengerVoices=1
   passengerCharacters = {
      "Male",
      "Malechild",
   }

   -- initialize GFX mode
   love.window.setMode( 0, 0, {fullscreen=false, vsync=false, msaa=0} )
   local flags={}
   desktopWidth,desktopHeight,flags=love.window.getMode()
   fullscreen=flags.fullscreen
   vsyncEnabled=flags.vsync
   fsaa=flags.msaa
   initializeFullscreenMode()
   love.graphics.setDefaultFilter("nearest","nearest")
   if fullscreen then 
      toggleScaling()
   end
   
   --canvas1X=love.graphics.newCanvas(width,height)
   --canvas1X:setFilter("nearest","nearest")
   canvas2X=love.graphics.newCanvas(2*width,2*height)
   unpauseGame()
      
   -- check pixelShader support and define shaders for dithered shadows
   if true then
      drawShadows=true
      shadowDitherShader = love.graphics.newShader([[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
            vec4 pixelColor=vec4(0.0, 0.0, 0.0, Texel(texture, texture_coords).a);
            if ((mod(floor(screen_coords.x),4.0) <= 1.5 ) != (mod(floor(screen_coords.y),4.0) > 1.5)) 
               discard;
            return pixelColor;
        }
      ]])
      shadowDitherShaderNoTexture = love.graphics.newShader([[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
            vec4 pixelColor=vec4(0.0, 0.0, 0.0, 1.0);
            if ((mod(floor(screen_coords.x),4.0) <= 1.5 ) != (mod(floor(screen_coords.y),4.0) > 1.5)) 
               discard;
            return pixelColor;
        }
      ]])
   else
      drawShadows=false
   end
   
   -- load graphics
   --loadAnimationFrames()
   loadAnimationsFromTileMaps()
   loadScreens()
   loadBackgroundImages(currentLevel)
   loadLiveImages()
   
   -- set screenfont and color
	--local f = love.graphics.newFont(8)
   --love.graphics.setFont(f)
   --love.graphics.setBackgroundColor(255,255,255)
   local fontImg=love.graphics.newImage(gfxDir.."fonts/Taito8.png")
   fontImg:setFilter("nearest","nearest")
   bigFont = love.graphics.newImageFont(fontImg,
      " !#$%&'()*+,-.0123456789:;<=>?"..
      "ABCDEFGHIJKLMNOPQRSTUVWXYZ"..
      "[/]abcdefghijklmnopqrstuvwxyz", 1)

   local fontImg2=love.graphics.newImage(gfxDir.."fonts/TinyUnicode7.png")
   fontImg2:setFilter("nearest","nearest")
   smallFont = love.graphics.newImageFont(fontImg2,
" abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"..
"0123456789.,!?-+/():;%&`'*#=[]\\$",1)
   love.graphics.setFont(bigFont)
   love.graphics.setBackgroundColor(0,0,0)
   
   -- load sound effects
   loadSoundEffects()
   
   -- initialize joysticks
   joysticks = love.joystick.getJoysticks()
   numJoysticks = love.joystick.getJoystickCount();
   
   --pauseGame()
   titleScreen()
end

function loadBackgroundImages(levelNumber)
   local dir=gfxDir.."backgrounds/"
   background=love.graphics.newImage(dir.."BG_"..levelNumber..".png")
   backgroundMask=createBGMask(dir.."BG_"..levelNumber.."_Mask.png")
   backgroundExit=love.graphics.newImage(dir.."BG_"..levelNumber.."_Exit.png")
   backgroundExitMask=createBGMask(dir.."BG_"..levelNumber.."_Exit_Mask.png")
end

function createBGMask(imgFileName)
   local mask={}
   local imageData=love.image.newImageData(imgFileName)
   local imgWidth=imageData:getWidth()
   local imgHeight=imageData:getHeight()
   local platformColors={
   {255,0,0},
   {0,255,0},
   {0,0,255},
   {0,255,255},
   {255,0,255},
   {255,255,255},
   {128,0,0},
   {0,128,0},
   {0,0,128},
   {128,0,128},
   {128,128,0},
   {128,128,128}
   }
   local respawnColors={
   {200,0,0},
   {0,200,0},
   {0,0,200},
   {0,200,200},
   {200,0,200},
   {200,200,200},
   {100,0,0},
   {0,100,0},
   {0,0,100},
   {100,0,100},
   {100,100,0},
   {100,100,100}
   }
   local fuelColor={192,0,0}
   local wallColor={0,0,0}
   
   local r,g,b,a
   for y=1,imgHeight do
      local row={}
      mask[y]=row
      for x=1, imgWidth do
         local r,g,b,a=imageData:getPixel(x-1,y-1)
         row[x]=0
         if a>0 then
            if r==wallColor[1] and g==wallColor[2] and b==wallColor[3] then
               row[x]=-1
            elseif r==fuelColor[1] and g==fuelColor[2] and b==fuelColor[3] then
               row[x]=255
            else
               for i=1,#platformColors do
                  if r==platformColors[i][1] and g==platformColors[i][2] and b==platformColors[i][3] then
                     row[x]=i
                     if passengerRespawnPoints[i]==nil then
                        local point={x,y}
                        passengerRespawnPoints[i]=point
                     end
                  end
               end
               for i=1,#respawnColors do
                     if r==respawnColors[i][1] and g==respawnColors[i][2] and b==respawnColors[i][3] then
                     row[x]=0
                     if playerRespawnPoints[i]==nil then
                        local point={x,y}
                        playerRespawnPoints[i]=point
                     end
                  end
               end
            end
         end
      end
   end
   return mask
end

function createBitmap(image)
   local bitmap={}
   local imageData={}
   if image.typeOf ~= nil then
      imageData=image
   else
      imageData=love.image.newImageData(image)
   end
   local imgWidth=imageData:getWidth()
   local imgHeight=imageData:getHeight()
   local r,g,b,a
   for y=1,imgHeight do
      local row={}
      bitmap[y]=row
      for x=1, imgWidth do
         local r,g,b,a=imageData:getPixel(x-1,y-1)
         if a>0 then
            row[x]=true
         else
            row[x]=false
         end
      end
   end
   return bitmap
end


function loadScreens()
   local dir=gfxDir
   screens[1]=love.graphics.newImage(dir.."titleScreen.png")
   screens[2]=love.graphics.newImage(dir.."winScreen.png")
   screens[3]=love.graphics.newImage(dir.."gameOverScreen.png")
end

function getNumLevels()
   local dir=gfxDir.."backgrounds/"
   local levelNumber=0
   local fileExists=true
   while fileExists do
      if love.filesystem.exists(dir.."BG_"..tostring(levelNumber+1)..".png") and love.filesystem.exists(dir.."BG_"..tostring(levelNumber+1).."_Mask.png") and love.filesystem.exists(dir.."BG_"..tostring(levelNumber+1).."_Exit.png") and love.filesystem.exists(dir.."BG_"..tostring(levelNumber+1).."_Exit_Mask.png") then
         levelNumber=levelNumber+1
      else
         fileExists=false
      end
   end
   return levelNumber
end
      
function loadLiveImages()
   for i=1,maxNumPlayers do
      liveImages[i]=animations["player"..i.."NoGear"]["none"].images[1]
   end
   passengerLiveImage=animations["passenger1Male"]["none"].images[1]
end