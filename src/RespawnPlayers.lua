function respawnPlayers()
   if #respawningPlayers>0 then
      for i=#respawningPlayers,1,-1 do
         local player=respawningPlayers[i]
         local defaultValues=createPlayer(centerX,centerY,1)
         player.isFacingLeft=defaultValues.isFacingLeft
         player.animType=defaultValues.animType
         player.animFrameNr=defaultValues.animFrameNr
         player.isDestroyed=defaultValues.isDestroyed
         player.canScatterFrom=defaultValues.canScatterFrom
         player.restitution=defaultValues.restitution
         player.canCollideWith=defaultValues.canCollideWith
         player.passengerInside=defaultValues.passengerInside
         player.landedOnPlatform=defaultValues.landedOnPlatform
         player.vX = defaultValues.vX
         player.vY = defaultValues.vY
         player.fAppliedX = defaultValues.fAppliedX
         player.fAppliedY = defaultValues.fAppliedY
         player.fImpulseX = defaultValues.fImpulseX
         player.fImpulseY = defaultValues.fImpulseY
         player.fX = defaultValues.fX
         player.fY = defaultValues.fY
         player.tip = defaultValues.tip
         if player.fuel <= 0 then
            player.fuel = defaultValues.fuel
         end
         local occupied=true
         local j=0
         local trialPos_x,trialPos_y
         while occupied==true and j<#passengerRespawnPoints+#playerRespawnPoints do
            j=j+1
            if j<=#passengerRespawnPoints then
               player.gearIsDown=true
            else
               player.gearIsDown=false
            end
            player.subType=getPlayerSubTypeString(player)
            refreshImage(player)
            local bottomRow=findBottomRow(player)
            if j<=#passengerRespawnPoints then
               trialPos_x=math.floor(passengerRespawnPoints[j][1]+player.halfwidth+5)
               trialPos_y=math.floor(passengerRespawnPoints[j][2]-0.5*bottomRow)
               --it starts landing: bump it into the platform a bit in case of zero gravity
               player.vY=1
            else
               trialPos_x=playerRespawnPoints[j-#passengerRespawnPoints][1]
               trialPos_y=passengerRespawnPoints[j-#passengerRespawnPoints][2]
               player.vY=0
            end
            player.x=trialPos_x
            player.y=trialPos_y
            
            occupied=false
            for k=1,#objects do
               if objects[k].type=="player" and objects[k].canCollideWith["player"] and colliding(player,objects[k]) then
                  occupied=true
               end
            end
         end
         if occupied==false then
            table.insert(objects,1,player)
            table.remove(respawningPlayers,i)
         end
      end
   end
end

function findBottomRow(player)
   local bottomRow=-1
   for y=player.height,1,-1 do
      local playerBitmapRow=player.bitmap[y]

      for x=1,player.width do
         -- have we found the bottom of the landing gear?
         if bottomRow==-1 and playerBitmapRow[x] then
            bottomRow=y
         end
      end
   end
   return bottomRow
end