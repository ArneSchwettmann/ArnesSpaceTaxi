function resolveDestroyed()
   local objects=objects
   
   --for i,obj in ipairs(objects) do
   for i=#objects,1,-1 do
      local obj=objects[i]
      if obj.isDestroyed==true then
         if obj.animType~="destroyed" then
            obj.animType="destroyed"
            obj.animFrameNr=1
            obj.animIsLoop=false
            obj.vX=0
            obj.vY=0
            obj.fAppliedX=0
            obj.fAppliedY=0
            obj.canCollideWith=createSet({})
            obj.canScatterFrom=createSet({})
            playSoundEffect(obj.type.."Destroyed",2*(obj.x-centerX)/width)
         elseif math.floor(obj.animFrameNr)>=animations[obj.subType][obj.animType].numFrames then
            -- the object is gone and destruction animation has finished
            -- update the game logic correspondingly
            if obj.type=="player" then
               obj.numLives=obj.numLives-1
               if obj.passengerInside then
                  numPassengers=numPassengers-1
                  obj.passengerInside=nil
                  obj.score = math.max(obj.score-passengerDeathPenalty,0) -- penalty for killing a passenger
               end
               -- is it bleak? Try to steal a life!
               if obj.numLives<=-1 then
                  -- steal a life from the player with the most lives
                  stealLife(obj)
               end
               -- stealing not successful
               if obj.numLives<=-1 then
                  table.remove(objects,i)
                  numPlayers=numPlayers-1
               else
                  table.insert(respawningPlayers,1,obj)
                  table.remove(objects,i)
               end
            elseif obj.type=="passenger" then
               table.remove(objects,i)
               numPassengers=numPassengers-1
            end
         end
      end
   end
end

function stealLife(player)
   local playerToStealFrom={}
   local maxLives=0
   for i,obj in ipairs(objects) do
      if obj.type=="player" and obj.numLives>0 and obj.numLives>maxLives then
         maxLives=obj.numLives
         playerToStealFrom=obj
      end
   end
   for i,obj in ipairs(playersEscaped) do
      if obj.numLives>0 and obj.numLives>maxLives then
         maxLives=obj.numLives
         playerToStealFrom=obj
      end
   end
   for i,obj in ipairs(respawningPlayers) do
      if obj.numLives>0 and obj.numLives>maxLives then
         maxLives=obj.numLives
         playerToStealFrom=obj
      end
   end
   if maxLives>0 then
      playerToStealFrom.numLives=playerToStealFrom.numLives-1
      player.numLives=player.numLives+1
   end
end