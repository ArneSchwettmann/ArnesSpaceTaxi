-- Object order: forceField,player,passenger
function initializeLevel(levelNr)
   background={}
   backgroundMask={}
   passengerRespawnPoints={}
   playerRespawnPoints={}
   loadBackgroundImages(levelNr)
   timeSinceLastPassenger=50

   if levelNr==1 then
      objects={}
      playerReferences={}
      respawningPlayers={}
      playersEscaped={}
      for i=1,numPlayers do
         local player=createPlayer(centerX,centerY,i)
         table.insert(respawningPlayers,1,player)
         table.insert(objects,player.thruster1)
         table.insert(objects,player.thruster2)
      end
   else
      for i=#objects,1,-1 do
         if objects[i].type=="player" then
            table.insert(playersEscaped,1,objects[i])
            table.remove(objects,i)
         end
      end
      objects={}
      for i=#playersEscaped,1,-1 do
         table.insert(respawningPlayers,1,playersEscaped[i])
         table.insert(objects,playersEscaped[i].thruster1)
         table.insert(objects,playersEscaped[i].thruster2)
         table.remove(playersEscaped,i)
      end
   end
   --[[
   for i,player in ipairs(respawningPlayers) do
      if levelNr==2 then
         player.gravityY=0
         player.gravityX=0
      else
         player.gravityY=20
         player.gravityX=0
      end
   end
   --]]
   passengersLeft=5+numPlayers
   --passengersLeft=1
   numPassengers=0
   respawnPlayers()
   updatePlayerReferences()
end
   --[[
   resurrectingObjects={}
   --]]