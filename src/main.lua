require("InitializeLevel")
require("CreationFunctions")
require("GameLoop")
require("Auxiliary")
require("Input")
require("Debug")
require("Draw")
require("BordersAndConstraints")
require("ResolveDestroyed")
require("RespawnPlayers")
require("Load")
require("GameLogic")
require("Normals")
require("Colliding")
require("Penetrating")
require("ScreenModes")
require("Passengers")
require("Audio")
require("TileMaps")

function love.update(dt)
   --effect:send("time", t)
   
   if gameIsPaused or waitingForClick or gameWon or gameLost or displayingTitleScreen or displayingControls then
      if waitingForClick then
         for i=1,numPlayers do
            dummy1,dummy2,inputButton[i]=getInputPlayer(i)
            if inputButton[i] then
               waitingForClick=false
            end
         end
      end
      return
   end
   
   if gameWasPaused==true then
      getInputPlayer(1)
      timeSinceUnpausing=timeSinceUnpausing+dt
      if timeSinceUnpausing>=timeToWaitAfterPause then
         gameWasPaused=false
         timeSinceUnpausing=0
      end
      return
   end
   
   for i,obj in ipairs(objects) do
      if obj.type=="player" then
         local j=obj.playerNumber
         oldInputButton[j]=inputButton[j]
         inputX[j],inputY[j],inputButton[j]=getInputPlayer(j)
      end
   end
   
   for i=1,numTimeStepsPerFrame do
      evolve(dt/numTimeStepsPerFrame)
   end

   resolveDestroyed()
   
   resolveDeliveredPassengers()
   resolvePickedUpPassengers()
   
   respawnPassenger()
   
   respawnPlayers()
   
   updateFuel(dt)
   updateTip(dt)
  
   updateSoundEffects()
   updateThrusters()

   resolveExitOpening()
   checkGoal()
   
   
   timeSinceLastPassenger=timeSinceLastPassenger+dt
   timeSinceLastFrame=timeSinceLastFrame+dt
   if timeSinceLastFrame>=1/60 then
      updateAnimationFrames()
      timeSinceLastFrame=0
   end

   updatePlayerReferences()
end

function evolve(dt)
   local objects=objects
   
   for i,obj in ipairs(objects) do
      if obj.type=="player" and obj.isDestroyed==false then
         local playerNumber=obj.playerNumber
         obj.fAppliedX=inputX[playerNumber]
         obj.fAppliedY=inputY[playerNumber]
         if obj.gearIsDown then 
            obj.fAppliedX=0 
         end
         if obj.landedOnPlatform>0 then
            obj.fAppliedY=math.min(inputY[playerNumber],0)
            obj.fAppliedX=0
         end
         if obj.landedOnPlatform>0 and obj.fAppliedY<0 then
            obj.landedOnPlatform=0
         end
         if obj.fAppliedX > 0 then
            obj.isFacingLeft=false
         elseif obj.fAppliedX < 0 then
            obj.isFacingLeft=true
         end  
         if inputButton[playerNumber] and not oldInputButton[playerNumber] then
            toggleGear(obj)
            obj.landedOnPlatform=0
         end
         if obj.fuel<=0 then
            obj.fAppliedX=0
            obj.fAppliedY=0
         end
      else
         obj.fAppliedX = 0
         obj.fAppliedY = 0
      end
      obj.fImpulseX = 0
      obj.fImpulseY = 0
   end
   
   -- trial step to check if there will be a collision
   for i,obj in ipairs(objects) do
      obj.oldVX=obj.vX
      obj.oldVY=obj.vY
      obj.oldX=obj.x
      obj.oldY=obj.y
   end
   takeTimeStep(dt)

   --checkBorders()
   resolveCollisions(dt)
   
   for i,obj in ipairs(objects) do
      obj.vX=obj.oldVX
      obj.vY=obj.oldVY
      obj.x=obj.oldX
      obj.y=obj.oldY
   end
   
   takeTimeStep(dt)
   checkBorders()
   resolveBGCollisions()
   
   -- artificially change object's positions to prevent interpenetration
   --resolveConstraints()   
end

function resolveCollisions(dt)         
   local objects=objects
   
	local numObjects=table.getn(objects)
   for i=1,numObjects-1 do
		for j=i+1,numObjects do 
         local obj1=objects[i]         
         local obj2=objects[j]   
         if obj1.type~="passenger" and 
            obj1.canCollideWith[obj2.type] and 
            obj2.canCollideWith[obj1.type]
         then 
            if colliding(obj1,obj2) then
               if obj1.canScatterFrom[obj2.type] and
               obj2.canScatterFrom[obj1.type] then
                  updateScatteringForces(obj1,obj2,dt)
               end
               if obj1.type=="forceField" and obj1.influences[obj2.type] then
                  resolveInfluences(obj1,obj2,dt)
               end
               resolveCollisionEffects(obj1,obj2)
            end
         end
      end
   end
end

function updateScatteringForces(obj1,obj2,dt)         
   local normal_x,normal_y=findNormal(obj1,obj2)
   --- friction force by player on ball due to rubbing with player, perpendicular to surface normal
   
   -- Elastic Collision force, projected on the normal
   -- Eqns from http://farside.ph.utexas.edu/teaching/301/lectures/node76.html inelastic 1D collision
   -- extension for elastic: replace a factor of 2.00 with 1+cR, where restitution is the coefficient of restitution
   -- bettween the two objects, which goes from 1 (elastic) to 0 (inelastic)
   --factor=obj2.mass*2.00*obj1.mass/(obj2.mass+obj1.mass)/dt
   
   local cR=obj1.restitution[obj2.type]
   local factor=obj2.mass*(1.0+cR)*obj1.mass/(obj2.mass+obj1.mass)/dt
   
   local forceOn2_x=factor*(obj1.vX-obj2.vX)
   local forceOn2_y=factor*(obj1.vY-obj2.vY)
   local forceOn2_mag=(forceOn2_x*normal_x+forceOn2_y*normal_y)
   if forceOn2_mag>0 then 
      forceOn2_x=forceOn2_mag*normal_x
      forceOn2_y=forceOn2_mag*normal_y
      if obj2.mass < infiniteMass then
         obj2.fImpulseX = obj2.fImpulseX+forceOn2_x
         obj2.fImpulseY = obj2.fImpulseY+forceOn2_y 
         obj2.vX = obj2.vX+(forceOn2_x*dt)/obj2.mass
         obj2.vY = obj2.vY+(forceOn2_y*dt)/obj2.mass 
      end
      if obj1.mass < infiniteMass then
         obj1.fImpulseX = obj1.fImpulseX-forceOn2_x
         obj1.fImpulseY = obj1.fImpulseY-forceOn2_y
         obj1.vX = obj1.vX-(forceOn2_x*dt)/obj1.mass
         obj1.vY = obj1.vY-(forceOn2_y*dt)/obj1.mass 
      end
   end
end


function resolveInfluences(obj1,obj2,dt)
   if obj1.subType=="oneOverRSquaredForceField" then
      local r_x=obj2.x-obj1.x
      local r_y=obj2.y-obj1.y
      local absR=math.sqrt(r_x*r_x+r_y*r_y)
      if absR>2 then
         local forceOn2_x=obj1.fieldStrength*r_x/(absR*absR)
         local forceOn2_y=obj1.fieldStrength*r_y/(absR*absR)
         obj2.fImpulseX = obj2.fImpulseX+forceOn2_x-obj1.frictionCoeff*obj2.vX
         obj2.fImpulseY = obj2.fImpulseY+forceOn2_y-obj1.frictionCoeff*obj2.vY
      end
   elseif obj1.subType=="constantForceField" then
      local r_x=obj2.x-obj1.x
      local r_y=obj2.y-obj1.y
      local absR=math.sqrt(r_x*r_x+r_y*r_y)
      if absR>2 then
         local forceOn2_x=obj1.fieldStrength*r_x/(absR)
         local forceOn2_y=obj1.fieldStrength*r_y/(absR)
         obj2.fImpulseX = obj2.fImpulseX+forceOn2_x-obj1.frictionCoeff*obj2.vX
         obj2.fImpulseY = obj2.fImpulseY+forceOn2_y-obj1.frictionCoeff*obj2.vY
      end
   end
end 

function resolveCollisionEffects(obj1,obj2)
   if obj1.type=="player" and obj2.type=="player" then
      obj1.isDestroyed=true
      obj2.isDestroyed=true
   end
   if obj1.type=="passenger" and obj2.type=="player" then
      local tempobject={}
      tempObject=obj1
      obj1=obj2
      obj2=tempObject
   end
   if obj1.type=="player" and obj2.type=="passenger" then
      local passenger=obj2
      local player=obj1
   --   if passenger.animType=="waving" then
         playSoundEffect(passenger.voiceType.."_ouch",2*(passenger.x-centerX)/width,passenger.pitch)
         passenger.isDestroyed=true
   --   end
   end
 end

function takeTimeStep(dt)
   local objects=objects
   local norm=norm
   local minVelocity=minVelocity
   local maxVelocity=maxVelocity
   
   for i=1,table.getn(objects) do
      local obj=objects[i]
      
      if obj.mass>=infiniteMass or obj.isDestroyed then
         obj.fX=0
         obj.fY=0
      elseif obj.type=="player" and obj.landedOnPlatform>0 then

         obj.fX = obj.fAppliedX + obj.fImpulseX - 
               obj.frictionCoeff * obj.vX
               
         obj.fY = obj.fAppliedY + obj.fImpulseY - 
               obj.frictionCoeff * obj.vY
               
      else
         obj.fX = obj.fAppliedX + obj.fImpulseX - 
            obj.frictionCoeff * obj.vX + 
            obj.mass * obj.gravityX
      
         obj.fY = obj.fAppliedY + obj.fImpulseY - 
            obj.frictionCoeff * obj.vY + 
            obj.mass * obj.gravityY
      end
      
      obj.vX = obj.vX + 1/obj.mass * obj.fX * dt
         
      obj.vY = obj.vY + 1/obj.mass * obj.fY * dt

      --obj.fY = obj.fY - obj.fImpulseY

      --obj.fX = obj.fX - obj.fImpulseX
      
      local velocity=norm(obj.vX,obj.vY)
      if velocity>maxVelocity then
         --obj.vY=obj.vY/velocity*maxVelocity
         --obj.vX=obj.vX/velocity*maxVelocity
      elseif velocity<minVelocity then
         --obj.vX=0
         --obj.vY=0
      end

      obj.x = obj.x + obj.vX * dt
      obj.y = obj.y + obj.vY * dt 
   end
end

function updateAnimationFrames()
   local objects=objects
   local animations=animations
   
   for i,obj in ipairs(objects) do
      if obj.animType~="none" then
         local numFrames=animations[obj.subType][obj.animType].numFrames
         if numFrames==0 then 
            return 
         else
            obj.animFrameNr=obj.animFrameNr+obj.animSpeed
         end
         if math.floor(obj.animFrameNr)>numFrames then
            obj.animFrameNr=1
            if obj.animIsLoop==false then                              
               obj.animType="none"
            end
         end
      end
      if obj.type == "player" then
         obj.subType=getPlayerSubTypeString(obj)
      elseif obj.type == "passenger" then
         obj.subType=getPassengerSubTypeString(obj)
      end
      refreshImage(obj)
   end
end


function refreshImage(obj)
      obj.image=animations[obj.subType][obj.animType].images[math.floor(obj.animFrameNr)]
      obj.bitmap=animations[obj.subType][obj.animType].bitmaps[math.floor(obj.animFrameNr)]
      obj.width = obj.image:getWidth()
      obj.height = obj.image:getHeight()
      obj.halfwidth = 0.5*obj.width
      obj.halfheight = 0.5*obj.height
end

function updateFuel(dt)
   local abs=math.abs
   local max=math.max
   local min=math.min
   local somebodyIsRefueling=false
   for i,obj in ipairs(objects) do
      if obj.type=="player" then
         local player=obj
         player.fuel=max(0, player.fuel-abs(player.fAppliedX/thrusterForceMagnitude*fuelConsumption)*dt-abs(player.fAppliedY/thrusterForceMagnitude*fuelConsumption)*dt)
         if player.landedOnPlatform==255 then
            if player.fuel<1 and player.score>0 then
               somebodyIsRefueling=true
               playRefuelingSoundEffect(2*(player.x-centerX)/width)
               local refuelAmount = min(1-player.fuel,refuelSpeed*dt)
               if player.score >= refuelAmount*refuelCost then 
                  player.fuel = player.fuel + refuelAmount
                  player.score = player.score - refuelAmount*refuelCost
               else
                  player.fuel = player.fuel+player.score/refuelCost
                  player.score = 0
               end
            end
         end
      end
   end
   if somebodyIsRefueling==false then
      stopRefuelingSoundEffect()
   end
end

function updateTip(dt)
   local max=math.max
   for i,obj in ipairs(objects) do
      if obj.type=="player" then
         local player=obj
         if player.passengerInside then
            player.tip = max(player.tip - tipConsumption*dt,0)
         else
            player.tip=0
         end
      end
   end
end


function updateThrusters(dt)
   for i,obj in ipairs(objects) do
      if obj.type=="player" then
         local player=obj
         local thruster1=player.thruster1
         local thruster2=player.thruster2
         
         local offsetX=math.floor((player.halfwidth-thruster1.halfwidth))
         local offsetY=math.floor((player.halfheight-thruster1.halfheight))
         
         thruster1.x=offsetX+math.floor(player.x-player.halfwidth)+thruster1.halfwidth
         thruster1.y=offsetY+math.floor(player.y-player.halfheight)+thruster1.halfheight
         thruster2.x=thruster1.x
         thruster2.y=thruster1.y
         if player.fAppliedX>0 then
            thruster1.animType="right"
         elseif player.fAppliedX<0 then
            thruster1.animType="left"
         else
            thruster1.animType="none"
            thruster1.animFrameNr=1
         end
         if player.fAppliedY>0 then
            if player.isFacingLeft then
               thruster2.animType="facingLeftDown"
            else
               thruster2.animType="facingRightDown"
            end
         elseif player.fAppliedY<0 then
            thruster2.animType="up"
         else
            thruster2.animType="none"
            thruster2.animFrameNr=1
         end
      end
   end
end

function resolveExitOpening()
   if passengersLeft<=0 and background~=backgroundExit then
      background=backgroundExit
      backgroundMask=backgroundExitMask
      playSoundEffect("exitopen")
   end
end