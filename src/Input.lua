
function getInputPlayer(playerNumber)
   local xInput,yInput=0,0
   local buttonInput=false
   local inputForceMagnitude=thrusterForceMagnitude
   
   --player 1 responds to touch events also
   if playerNumber==1 and touching then
      -- deal with virtual gamepad touch events
      local touches = love.touch.getTouches()
      for i, id in ipairs(touches) do
         local x, y = love.touch.getPosition(id)
         local width = love.graphics.getWidth()
         local height = love.graphics.getHeight()
         -- relative (square) button size
         local dPadButtonSizeX = dPadButtonSizeRel*width
         local dPadButtonSizeY = dPadButtonSizeX
         -- top left coordinate of virtual gamepad
         local dPadTopLeftX=0
         local dPadTopLeftY=height-3*dPadButtonSizeY
         -- virtual gamepad button coordinates i,j (1,1) top left, (3,3) bottom right
         local i = math.ceil((x-dPadTopLeftX)/dPadButtonSizeX)
         local j = math.ceil((y-dPadTopLeftY)/dPadButtonSizeY)
         if i>=1 and i<=3 and j>=1 and j<=3 then
            xInput = i-2
            yInput = j-2
         end
         local fireButtonSizeX = fireButtonSizeRel*width
         local fireButtonSizeY = fireButtonSizeX
         -- large virtual firebutton on the bottom right
         local fireButtonTopLeftX=width-fireButtonSizeX
         local fireButtonTopLeftY=height-fireButtonSizeY
         if x>=fireButtonTopLeftX and x<=fireButtonTopLeftX+fireButtonSizeX 
          and y>=fireButtonTopLeftY and y<=fireButtonTopLeftY+fireButtonSizeY
          then
            buttonInput = true
         end
      end
   end
   -- normal controls
   if controlTypes[controls[playerNumber]]=="Keyboard 1" then
      if love.keyboard.isDown("left") then
         xInput = -1     
      end
      if love.keyboard.isDown("right") then
         xInput = 1
      end
      if love.keyboard.isDown("right") and love.keyboard.isDown("left") then
         xInput = 0
      end
      if love.keyboard.isDown("up") then
         yInput = -1    
      end
      if love.keyboard.isDown("down") then
         yInput = 1
      end
      if love.keyboard.isDown("up") and love.keyboard.isDown("down") then
         yInput = 0
      end
      if love.keyboard.isDown("rshift") then
         buttonInput=true
      end
   elseif controlTypes[controls[playerNumber]]=="Keyboard 2" then
      if love.keyboard.isDown("a") then
         xInput = -1     
      end
      if love.keyboard.isDown("d") then
         xInput = 1
      end
      if love.keyboard.isDown("a") and love.keyboard.isDown("s") then
         xInput = 0
      end
      if love.keyboard.isDown("w") then
         yInput = -1    
      end
      if love.keyboard.isDown("s") then
         yInput = 1
      end
      if love.keyboard.isDown("w") and love.keyboard.isDown("s") then
         yInput = 0
      end
      if love.keyboard.isDown("lshift") then
         buttonInput=true
      end
   else 
      local joystickNum=controls[playerNumber]-2
      local joyXInput,joyYInput = 0,0
      if ( joystickNum <= numJoysticks ) then
         local joystick = joysticks[joystickNum]
         local numButtons = joystick:getButtonCount()
         if joystick:getAxisCount()>=1 then
            joyXInput,joyYInput = joystick:getAxes()
            io.write(joyXInput)
         end
         if joystick:getHatCount()>=1 then
            local hatDirection = joystick:getHat(1)
            if hatDirection == 'u' then
                joyYInput = -1
                joyXInput = 0
            elseif hatDirection == 'd' then
                joyYInput = 1
            elseif hatDirection == 'l' then
                joyXInput = -1
            elseif hatDirection == 'r' then
                joyXInput = 1
            elseif hatDirection == 'ld' then
                joyXInput = -1
                joyYInput = 1
            elseif hatDirection == 'lu' then
                joyXInput = -1
                joyYInput = -1
            elseif hatDirection == 'rd' then
                joyXInput = 1
                joyYInput = 1
            elseif hatDirection == 'ru' then
                joyXInput = 1
                joyYInput = -1
            end 
         end
         if numButtons>0 then
            if anyButtonPressed(joystick, numButtons) then
               buttonInput=true
            end
         end
         if joyXInput > 0.25 then 
            xInput = 1 
         elseif joyXInput < -0.25 then
            xInput = -1
         else
            xInput = 0
         end
         if joyYInput > 0.25 then 
            yInput = 1 
         elseif joyYInput < -0.25 then
            yInput = -1
         else
            yInput = 0
         end
      end
   end
   return xInput*inputForceMagnitude,yInput*inputForceMagnitude,buttonInput
end       

function anyButtonPressed(joystick,numButtons)
	local returnValue=false
	if numButtons>0 then 
		for i=1,numButtons do
			if joystick:isDown(i) then
				returnValue=true
			end
		end
	end
	return returnValue
end

function love.gamepadpressed(joystick, button)
   -- press fire on title screen to start single player game with joystick controls
   if (displayingTitleScreen
    and button ~= "dpup" 
    and button ~= "dpdown" 
    and button ~= "dpleft" 
    and button ~= "dpright") then  
      for i=1,#joysticks,1 do
         if joysticks[i]:getID()==joystick:getID() then
            -- set first player to the joystick that was pressed and start game
            controls[1]=i+2
            numPlayers=1
            startGame()
         end
      end
   end
end

function love.keypressed(key, scancode, isrepeat)
   if displayingTitleScreen then 
      if key == 'q' then
         love.event.quit()
      elseif key == '1' then
         numPlayers=1
         startGame()
      elseif key == '2' then
         numPlayers=2
         startGame()
      elseif key == '3' then
         numPlayers=3
         startGame()
      elseif key == '4' then
         numPlayers=4
         startGame()
      elseif key == '5' then
         numPlayers=5
         startGame()
      elseif key == 'c' then
         displayingControls = true
         displayingTitleScreen = false
      end
   end
   if displayingControls then 
      if key == '1' then
         cycleControls(1)
      elseif key == '2' then
         cycleControls(2)
      elseif key == '3' then
         cycleControls(3)
      elseif key == '4' then
         cycleControls(4)
      elseif key == '5' then
         cycleControls(5)
      elseif key == 'q' then
         displayingControls = false
         displayingTitleScreen = true
      end
      
   elseif key == 'q' then
      titleScreen()
   end
   if key == 'p' then
      if gameIsPaused == false then
         pauseGame()
      else
         unpauseGame()
      end
   elseif key == 'y' then
      won()
   elseif key == 'n' then
      if currentLevel>1 then
         currentLevel=currentLevel-1
         initializeLevel(currentLevel)
      end
   elseif key == 'b' then
      if currentLevel<numLevels then
         currentLevel=currentLevel+1
         initializeLevel(currentLevel)
         waitForClick()
      end
   elseif key == 'h' then
      if love.graphics.getSupported("pixeleffect") then
         drawShadows=not drawShadows
      end
   elseif key == "space" then
         waitingForClick=false
   --elseif key == 'c' and gameLost==true then
   --   continueGame()
   elseif key == 'f' then
     cycleScreenModes()
   elseif key == 't' then
     toggleScaling()
   elseif key == 'o' then
      showFPS= not showFPS
   end
end

function cycleControls(playerNumber)
   controls[playerNumber]=controls[playerNumber]+1
   if controls[playerNumber]>#controlTypes then
      controls[playerNumber]=1
   end
end

function love.mousepressed(x, y, button, istouch)
   if gameIsPaused==false and waitingForClick and button == 1 then
      waitingForClick=false
   end
   if istouch then
      touching = true
   else
      touching = false
   end
   if displayingTitleScreen then 
      if button == 1 then
         numPlayers=1
         startGame()
      end
   elseif gameLost then
      if button == 1 then
         titleScreen()
      end
   end
end