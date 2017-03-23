function love.draw()
   local objects=objects
   local floor=math.floor
   local shadowOffsetX,shadowOffsetY=shadowOffsetX,shadowOffsetY
   local centerX,centerY=centerX,centerY
   local width,height=width,height
   
   --love.graphics.setCanvas(canvas1X)
   if graphicsScaleFactor~=1.0 then
      love.graphics.setCanvas(canvas2X)
      love.graphics.push()
      love.graphics.setColor(0,0,0,255)
      love.graphics.rectangle('fill',0,0,2*width,2*height)
   else
      love.graphics.setColor(0,0,0,255)
      love.graphics.rectangle('fill',0,0,2*width+2*borderX,2*height+2*borderY)
      love.graphics.translate(borderX,borderY)
   end

   love.graphics.scale(2,2)
   
   if displayingTitleScreen then
      drawTitleScreen()
   elseif displayingControls then
      drawControlScreen()
   else

      love.graphics.setColor(255,255,255,255)
      love.graphics.draw(background,0,0)
      -- draw the shadows first
      if drawShadows==true then
      
         love.graphics.setShader(shadowDitherShader)
         for k,obj in ipairs(objects) do
            if obj.image~=nil and obj.hasShadow then
               love.graphics.draw(obj.image, floor(obj.x-obj.halfwidth+shadowOffsetX), floor(obj.y-obj.halfheight)+ShadowOffsetY)
            end
         end
        
         love.graphics.setShader()
      end
      
      for k,obj in ipairs(objects) do
         if obj.image~=nil then
            love.graphics.draw(obj.image, floor(obj.x-obj.halfwidth), floor(obj.y-obj.halfheight))
         end
      end
      
      drawStatusBar()
      
      -- depending on state of game, we draw other messages
      if gameWon then
         drawWinScreen()
      end
      if gameLost then
         drawGameOverScreen()
      end
      if waitingForClick==true then
         love.graphics.setColor(255,255,255,255)
         --love.graphics.setColorMode("modulate")
         love.graphics.printf("Get ready for level "..currentLevel.."! (Press space or fire)", 0, centerY-25,width,"center")
         --love.graphics.setColorMode("replace")
      end
      if gameIsPaused==true then
         drawPauseScreen()      
      end
      if showFPS then
         love.graphics.print("FPS: "..tostring(love.timer.getFPS()),10,40)
         love.graphics.print("numPassengers: "..tostring(numPassengers),10,52)
         love.graphics.print("debugVariable: "..tostring(debugVariable),10,64)
      end
   end
   if graphicsScaleFactor==1 then
      --cover up the area above the top escape hole
      love.graphics.setColor(0,0,0,255)
      love.graphics.rectangle('fill',0,0,2*width,-borderY)
      love.graphics.scale(0.5,0.5)
      love.graphics.translate(-borderX,-borderY)
   else 
      love.graphics.setCanvas()
      love.graphics.pop()
      love.graphics.scale(graphicsScaleFactor,graphicsScaleFactor)
      love.graphics.setColor(0,0,0,255)
      love.graphics.rectangle('fill',0,0,2*width+2*borderX+1,2*height+2*borderY+1)
      love.graphics.setColor(255,255,255,255)
      canvas2X:setFilter("linear","linear")
      love.graphics.draw(canvas2X,borderX,borderY)
      love.graphics.scale(1.0/graphicsScaleFactor,1.0/graphicsScaleFactor)
   end
   -- draw the virtual gamepad directly to the screen
   if touching then
      -- virtual gamepad button coordinates i,j (1,1) top left, (3,3) bottom right
      love.graphics.setColor(255,255,255,128)
      local width = love.graphics.getWidth()
      local height = love.graphics.getHeight()
      local dPadButtonSizeX = dPadButtonSizeRel*width
      local dPadButtonSizeY = dPadButtonSizeX
      local dPadTopLeftX=0
      local dPadTopLeftY=height-3*dPadButtonSizeY
      local i=0
      local j=0
      --for i=0,2,1 do
      --   for j=0,2,1 do
      --      love.graphics.rectangle("line",dPadTopLeftX+i*dPadButtonSizeX,dPadTopLeftY+j*dPadButtonSizeY,dPadButtonSizeX,dPadButtonSizeY)
      --   end
      --end
      for i=0,3,1 do
      -- horizontal lines
         love.graphics.line(dPadTopLeftX+1,dPadTopLeftY+i*dPadButtonSizeY,dPadTopLeftX+3*dPadButtonSizeX-1,dPadTopLeftY+i*dPadButtonSizeY)
      -- vertical lines
         love.graphics.line(dPadTopLeftX+i*dPadButtonSizeX,dPadTopLeftY+1,dPadTopLeftX+i*dPadButtonSizeX,dPadTopLeftY+3*dPadButtonSizeY-1)
      end
      -- virtual firebutton rectangle
      local fireButtonSizeX = fireButtonSizeRel*width
      local fireButtonSizeY = fireButtonSizeX
      local fireButtonTopLeftX=width-fireButtonSizeX
      local fireButtonTopLeftY=height-fireButtonSizeY
      love.graphics.rectangle("line",fireButtonTopLeftX+i*fireButtonSizeX,fireButtonTopLeftY+j*dPadButtonSizeY,fireButtonSizeX,fireButtonSizeY)
   end
   --[[
   if gameWasPaused==true then
      love.graphics.print("Starting in: "..(timeToWaitAfterPause-timeSinceUnpausing).." s", centerX-50, centerY-5)
   end
   --]]
end

function drawStatusBar()
   love.graphics.setFont(smallFont)
         --love.graphics.print("Player 1 on platform: "..tostring(objects[1].landedOnPlatform),10,80)
   for i=1,#playerReferences do
      xOffset=(i-1)*80
      yOffset=258
      love.graphics.setColor(80,80,80,255)
   
      love.graphics.rectangle("fill", xOffset, 252, 78, 46 )
   
--      love.graphics.setColor(255,255,255,255)

   
      love.graphics.setColor(200,200,255,255)
      --love.graphics.setColorMode("modulate")
      if i==5 then
         love.graphics.draw(liveImages[i],xOffset+4,254-2) -- was 20
      else
         love.graphics.draw(liveImages[i],xOffset+20,254-2)
      end
      if playerReferences[i].numLives>=0 then
         if i==5 then 
            love.graphics.print("x "..playerReferences[i].numLives,xOffset+28,255) -- was 44
         else
            love.graphics.print("x "..playerReferences[i].numLives,xOffset+44,255)
         end
         
         love.graphics.print("$ "..roundDollar(playerReferences[i].score),xOffset+4,266)
         --if playerReferences[i].tip>0 then
            love.graphics.print("Tip $ "..roundDollar(playerReferences[i].tip),xOffset+45,266)
         --end
         --love.graphics.print("Clients: "..passengersLeft,xOffset+4,277)
         love.graphics.print("Fuel ",xOffset+4,277)
         drawProgressBar(xOffset+22,278,50,6,playerReferences[i].fuel*100)
         
         if passengersLeft<=0 then
            love.graphics.printf("Go up!",xOffset,288,78,"center")         
         elseif playerReferences[i].passengerInside then
            love.graphics.printf("Pad "..playerReferences[i].passengerInside.targetPlatform..", please! ",xOffset,288,78,"center")         
         end
      else
         love.graphics.print("Dead",xOffset+25,277)
      end
      --love.graphics.setColorMode("replace")
   end
   love.graphics.setColor(0,0,0,255)
   love.graphics.rectangle("fill",width-30,254-2,30,12)
   love.graphics.setColor(200,200,255,255)
   love.graphics.draw(passengerLiveImage,width-30+2,254-1)
   love.graphics.print("x "..passengersLeft,width-30+14,255)
   
   love.graphics.setFont(bigFont)
end   
      
function drawTitleScreen()
      local floor=math.floor

      love.graphics.setColor(255,255,255,255)
      love.graphics.draw(background,0,0)
      if drawShadows==true then
         love.graphics.setShader(shadowDitherShader)
         love.graphics.draw(screens[1],0+shadowOffsetX,0+shadowOffsetY)
         love.graphics.setShader()
      end
      love.graphics.setColor(255,255,255,255)
      love.graphics.draw(screens[1],0,0)
      if drawShadows==true then
         love.graphics.setShader(shadowDitherShaderNoTexture)
         love.graphics.setColor(0,0,0,255)
         love.graphics.rectangle("fill", floor(centerX-150+shadowOffsetX), floor(centerY-3-45+75+shadowOffsetY), 300, 88 )
         love.graphics.setShader()
      end   
      love.graphics.setColor(255,255,255,255)
      love.graphics.rectangle("fill", floor(centerX-150), floor(centerY-3-45+75), 300, 88 )
      love.graphics.setColor(0,0,0,255)
      love.graphics.printf("Fire or 1,2,3,4,5 - Start 1-5 player", 0, centerY-7-32+75,width,"center")
      love.graphics.printf("c - Configure controls", 0, centerY-7-16+75,width,"center")
      love.graphics.printf("f - Toggle fullscreen", 0, centerY-7+75,width,"center")
      love.graphics.printf("t - Toggle scaling (fullscreen only)", 0, centerY-7+16+75,width,"center")
      love.graphics.printf("q - Quit", 0, centerY-7+32+75,width,"center")
end

function drawControlScreen()
   local floor=math.floor

      love.graphics.setColor(255,255,255,255)
      love.graphics.draw(background,0,0)
      if drawShadows==true then
         love.graphics.setShader(shadowDitherShaderNoTexture)
         love.graphics.setColor(0,0,0,255)
         love.graphics.rectangle("fill", floor(centerX-150+shadowOffsetX), floor(centerY-115+shadowOffsetY), 300, 230 )
         love.graphics.setShader()
      end   
      love.graphics.setColor(255,255,255,255)
      love.graphics.rectangle("fill", floor(centerX-150), floor(centerY-115), 300, 230 )
      love.graphics.setColor(0,0,0,255)
      love.graphics.printf("CONTROL CONFIGURATION", centerX-150, centerY-3-100,300,"center")
      love.graphics.printf("1 - P1 Controls: "..controlTypes[controls[1]], centerX-150, centerY-3-70,300,"center")
      love.graphics.printf("2 - P2 Controls: "..controlTypes[controls[2]], centerX-150, centerY-3-50,300,"center")
      love.graphics.printf("3 - P3 Controls: "..controlTypes[controls[3]], centerX-150, centerY-3-30,300,"center")
      love.graphics.printf("4 - P4 Controls: "..controlTypes[controls[4]], centerX-150, centerY-3-10,300,"center")
      love.graphics.printf("5 - P5 Controls: "..controlTypes[controls[5]], centerX-150, centerY-3+10,300,"center")
       love.graphics.printf("Keyboard1 = arrow keys + right shift", centerX-150, centerY-3+80,300,"center")
      love.graphics.printf("Keyboard2 = w a s d + left shift", centerX-150, centerY-3+100,300,"center")
      love.graphics.printf("q - Return to Title Menu", centerX-150, centerY-3+40,300,"center")
      
end



function drawPauseScreen()
   local floor=math.floor
   
   if drawShadows==true then
      love.graphics.setShader(shadowDitherShaderNoTexture)
      love.graphics.setColor(0,0,0,255)
      love.graphics.rectangle("fill", floor(centerX-125+shadowOffsetX), floor(centerY-40+shadowOffsetY), 250, 80 )
      love.graphics.setShader()
   end   
   love.graphics.setColor(255,255,255,255)
   love.graphics.rectangle("fill", floor(centerX-125), floor(centerY-40), 250, 80 )
   love.graphics.setColor(0,0,0,255)
   love.graphics.printf("Paused! Press p to continue", 0, centerY-4,width,"center")
end

function drawWinScreen()
   local floor=math.floor
   
   love.graphics.setColor(255,255,255,255)
   if drawShadows==true then
      love.graphics.setShader(shadowDitherShader)
      love.graphics.draw(screens[2],0+shadowOffsetX,0+shadowOffsetY)
      love.graphics.setShader()
   end
   love.graphics.draw(screens[2],0,0)
   
   if drawShadows==true then
      love.graphics.setShader(shadowDitherShaderNoTexture)
      love.graphics.setColor(0,0,0,255)
      love.graphics.rectangle("fill", floor(centerX-150+shadowOffsetX), floor(centerY+80-40+shadowOffsetY), 300, 80 )
      love.graphics.setShader()
   end   
   love.graphics.setColor(255,255,255,255)
   love.graphics.rectangle("fill", floor(centerX-150), floor(centerY+80-40), 300, 80 )
   love.graphics.setColor(0,0,0,255)
   love.graphics.printf("Congratulations, you won!", 0, centerY-5+80-15,width,"center")   
   love.graphics.printf("Press q to restart!", 0, centerY-5+80+15,width,"center")   
end

function drawGameOverScreen()
   local floor=math.floor

   love.graphics.setColor(255,255,255,255)
   if drawShadows==true then
      love.graphics.setShader(shadowDitherShader)
      love.graphics.draw(screens[3],0+shadowOffsetX,0+shadowOffsetY)
      love.graphics.setShader()
   end
   love.graphics.draw(screens[3],0,0)
   
   if drawShadows==true then
      love.graphics.setShader(shadowDitherShaderNoTexture)
      love.graphics.setColor(0,0,0,255)
      love.graphics.rectangle("fill", floor(centerX-100+shadowOffsetX), floor(centerY+75-40+shadowOffsetY), 200, 80 )
      love.graphics.setShader()
   end   
   love.graphics.setColor(255,255,255,255)
   love.graphics.rectangle("fill", floor(centerX-100), floor(centerY+75-40), 200, 80 )
   love.graphics.setColor(0,0,0,255)
   love.graphics.printf("Press q to restart", 0, centerY-5+75,width,"center")
end

function drawProgressBar(x,y,width,height,percent)
   local r,g,b,a = love.graphics.getColor()
   love.graphics.setColor(0,0,64,255)
   love.graphics.rectangle("fill",x,y,width,height)
   love.graphics.setColor(r,g,b,a)
   love.graphics.rectangle("fill",x+1,y+1,math.floor((width-2)*percent/100),height-2)
   love.graphics.setColor(r,g,b,a)
end
   



   
   --love.graphics.setColor(0,0,0,255)
   --love.graphics.rectangle('fill',0,0,fullscreenWidth,fullscreenHeight)
   
   --love.graphics.setCanvas(canvas2X)
   
   --multiple canvasses are too slow
   --love.graphics.push()
   --love.graphics.scale(2,2)
   --love.graphics.setColor(255,255,255,255)
   --love.graphics.draw(canvas1X,0,0)
   --scale more if needed
   