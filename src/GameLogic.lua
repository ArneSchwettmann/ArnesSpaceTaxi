function startGame()
      currentLevel=1
      gameWon=false
      gameLost=false
      initializeLevel(currentLevel)
      displayingTitleScreen = false
      waitForClick()
      unpauseGame()
end

function titleScreen()
      displayingTitleScreen=true
end

function updatePlayerReferences()
   for i,obj in ipairs(objects) do
      if obj.type=="player" then
         if obj.playerNumber==1 then
            playerReferences[1]=obj
         elseif obj.playerNumber==2 then
            playerReferences[2]=obj
         elseif obj.playerNumber==3 then
            playerReferences[3]=obj
         elseif obj.playerNumber==4 then
            playerReferences[4]=obj
         elseif obj.playerNumber==5 then
            playerReferences[5]=obj
         end
      end
   end
end
   
function continueGame()
      gameWon=false
      gameLost=false
      local oldPassengersLeft=passengersLeft
      initializeLevel(currentLevel)
      unpauseGame()
end

function checkGoal()
   if #playersEscaped>=numPlayers and numPlayers>0 then
      currentLevel=currentLevel+1
      if currentLevel>numLevels then
         won()
         currentLevel=numLevels
      else
         initializeLevel(currentLevel)
         waitForClick()
      end
   elseif numPlayers<=0 then
         lost()
   end
end

function lost()
   if gameLost==false then
      gameLost=true
   end
   
end

function won()
   if gameWon==false then
      gameWon=true
      --createFiftyBalls()
   end
end
     
function pauseGame()
   gameIsPaused = true
   love.mouse.setVisible(true)
   love.mouse.setGrabbed(false)
end

function waitForClick()
   waitingForClick = true
   gameWasPaused = true
end

function unpauseGame()
	gameIsPaused = false
   gameWasPaused = true
	love.mouse.setGrabbed(true)
	love.mouse.setVisible(false)
	love.mouse.setPosition(centerX,centerY)
end

function love.focus(f)
  if not f then
    -- lost focus
    pauseGame()
  else
    -- gained focus
    -- unpauseGame()
  end
end

function toggleGear(player)
   player.gearIsDown=not player.gearIsDown
end

function love.quit()
  print("Thanks for playing! Come back soon!")
end