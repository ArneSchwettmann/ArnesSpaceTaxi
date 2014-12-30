function respawnPassenger()
   local numPlatforms=#passengerRespawnPoints
   if numPassengers<numPlayers and timeSinceLastPassenger>10 and passengersLeft>0 and numPassengers<passengersLeft then
      local i=math.random(1,numPlatforms)
      local j=math.random(1,numPlatforms)
      while i==j do
         j=math.random(1,numPlatforms)
      end
      -- is the source platform occupied by another passenger?
      local occupied=false
      for k,obj in ipairs(objects) do
         if obj.type=="passenger" and obj.sourcePlatform==i then
             occupied=true
         end
      end
      -- no get a new passenger ready to appear
      if occupied==false then
         local newPassenger=createPassenger(passengerRespawnPoints[i][1],passengerRespawnPoints[i][2],i,j)
         newPassenger.y=math.floor(newPassenger.y-newPassenger.halfheight)-1
         newPassenger.x=math.floor(newPassenger.x+newPassenger.halfwidth)
         -- check if it is ok to appear, or if a player is in the way
         freeToAppear=true
         for k,obj in ipairs(objects) do
            if obj.canCollideWith["passenger"] and colliding(obj,newPassenger) then
               freeToAppear=false
            end
         end
         if freeToAppear then
            appear(newPassenger)
            table.insert(objects,newPassenger)
            numPassengers=numPassengers+1
            timeSinceLastPassenger=0
         end
      end
   end
end

function resolvePickedUpPassengers()
   for i,obj1 in ipairs(objects) do
      if obj1.type=="passenger" and obj1.isDone==false and obj1.isDestroyed==false and obj1.animType~="appearing" then
         local playerWaiting=false
         local passenger=obj1
         for j,obj2 in ipairs(objects) do
            if obj2.type=="player" then
               local player=obj2
               if player.landedOnPlatform==passenger.sourcePlatform and not player.passengerInside then
                  walk(passenger,"right")
                  if passenger.x>=player.x then
                     player.passengerInside=passenger
                     passenger.isDestroyed=true
                     numPassengers=numPassengers+1
                     playPassengerVoice(passenger.voiceType,passenger.targetPlatform,2*(passenger.x-centerX)/width,
                     passenger.pitch)
                     
                     player.tip=initialTip
                  end
                  playerWaiting=true
               end
               if playerWaiting==false then
                  if passenger.x>passengerRespawnPoints[passenger.sourcePlatform][1]+passenger.halfwidth then
                     walk(passenger,"left")
                  else
                     stand(passenger)
                  end
               end
            end
         end
      end
   end
end

function walk(passenger,direction)
   if direction == "left" then 
      passenger.vX=-8
      passenger.isFacingLeft=true
   elseif direction == "right" then
      passenger.vX=8
      passenger.isFacingLeft=false
   end
   
   passenger.animType="walking"
   passenger.animIsLoop=true
   passenger.canCollideWith=createSet({})

end

function stand(passenger)
   passenger.vX=0
   passenger.isFacingLeft=false
   passenger.animType="waving"
   passenger.animIsLoop=true
   if passenger.hasYelled==false then
      playSoundEffect(passenger.voiceType.."_heytaxi",2*(passenger.x-centerX)/width,passenger.pitch)
      passenger.hasYelled=true
   end
   passenger.canCollideWith=createSet({"player"})
end

function appear(passenger)
   passenger.vX=0
   passenger.isFacingLeft=false
   passenger.animType="appearing"
   passenger.animIsLoop=false
   passenger.animFrameNr=1
   refreshImage(passenger)
   playSoundEffect("passengerAppears",2*(passenger.x-centerX)/width)
   passenger.canCollideWith=createSet({})
end
   
function resolveDeliveredPassengers()
   for i,obj in ipairs(objects) do
      if obj.type=="passenger" and obj.animType~="appearing" then
         local passenger=obj
         if passenger.isDone and passenger.isDestroyed==false then
            if passenger.x>=passengerRespawnPoints[passenger.targetPlatform][1]+passenger.halfwidth then
               walk(passenger,"left")
            else
               passenger.isDestroyed=true
               passengersLeft=passengersLeft-1
            end
         end
      elseif obj.type=="player" then
         local player=obj
         if player.passengerInside and player.landedOnPlatform==player.passengerInside.targetPlatform then
            local passenger=player.passengerInside
            passenger.x=player.x
            passenger.y=passengerRespawnPoints[passenger.targetPlatform][2]
            passenger.y=math.floor(passenger.y-passenger.halfheight)-1
            passenger.isDone=true
            passenger.isDestroyed=false
            table.insert(objects,passenger)
            appear(passenger)
            player.passengerInside=nil
            playSoundEffect(passenger.voiceType.."_thanks",2*(passenger.x-centerX)/width,passenger.pitch)
            
            player.score=player.score+player.tip
         end
      end
   end
end

