
function getInputPlayer(playerNumber)
   local xInput,yInput=0,0
   local buttonInput=false
   local inputForceMagnitude=thrusterForceMagnitude
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
      if love.joystick.isOpen(joystickNum) then
			local numButtons = love.joystick.getNumButtons( joystickNum )
			if love.joystick.getNumAxes(joystickNum)>=1 then
            joyXInput,joyYInput = love.joystick.getAxes(joystickNum)
			end
			if love.joystick.getNumHats(joystickNum)>=1 then
				local hatDirection = love.joystick.getHat(joystickNum, 1)
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
            if anyButtonPressed(joystickNum, numButtons ) then
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

function anyButtonPressed(joystickNum,numButtons)
	local returnValue=false
	if numButtons>0 then 
		for i=1,numButtons do
			if love.joystick.isDown( joystickNum, i ) then
				returnValue=true
			end
		end
	end
	return returnValue
end
	
function love.keypressed(key, unicode)
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
      if love.graphics.isSupported("pixeleffect") then
         drawShadows=not drawShadows
      end
   elseif key == ' ' then
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