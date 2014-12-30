-- On the borders, the ball bounces elastically, and the player stops
function checkBorders()
   local objects=objects
   for k=#objects,1,-1 do
      if objects[k].type=="player" then
         local player=objects[k]
         if player.x<player.halfwidth then
            player.x = player.halfwidth
            player.vX = 0
         end
         if player.x>width-player.halfwidth then
            player.x=width-player.halfwidth
            player.vX = 0
         end
         if player.y<player.halfheight then
            if passengersLeft<=0 then 
               if player.y<-player.halfheight then
                  table.remove(objects,k)
                  table.insert(playersEscaped,1,player)
               end
            else
               player.y = 0+player.halfheight
               player.vY = 0
            end
         end
         if player.y>height-statusBarHeight-player.halfheight then
            player.y=height-player.halfheight
            player.vY = 0
         end
      end
   end
end

function resolveBGCollisions()
   local objects=objects
   for k=#objects,1,-1 do
      local obj=objects[k]
      if obj.type=="player" then
         resolveBGCollisionsForPlayer(obj)
      end
   end
end

function resolveBGCollisionsForPlayer(player)
   local xMin=math.floor(player.x-player.halfwidth)
   local xMax=math.floor(player.x+player.halfwidth)
   local yMin=math.floor(player.y-player.halfheight)
   local yMax=math.floor(player.y+player.halfheight)
   local maxLandingVelocity=maxLandingVelocity
   if player.gearIsDown==true and norm(player.vX,player.vY)<maxLandingVelocity and player.vY>=0 and player.landedOnPlatform==0 then
      -- check if we landed
      local firstRow=-1
      local lastMaskValue=-1
      for y=yMax,math.max(yMin,0)+1,-1 do
         local backgroundMaskRow=backgroundMask[y]
         local playerBitmapRow=player.bitmap[y-yMin]
   
         for x=xMin+1,xMax do
            -- are we checking the bottom of the landing gear?
            if firstRow==-1 and playerBitmapRow[x-xMin] then
               firstRow=y
            end
            if y==firstRow then
               if playerBitmapRow[x-xMin] then
                  if backgroundMaskRow[x]>=0 then
                     if lastMaskValue==-1 then 
                        lastMaskValue=backgroundMaskRow[x]
                     elseif lastMaskValue~=backgroundMaskRow[x] then
                        player.isDestroyed=true
                        return
                     end
                  elseif backgroundMaskRow[x]==-1 then
                     player.isDestroyed=true
                     return
                  end
               end
            elseif playerBitmapRow[x-xMin] and backgroundMaskRow[x]~=0 then 
               player.isDestroyed=true
               return
            end      
         end      
      end         
      if player.isDestroyed==false and lastMaskValue>0 then
         player.landedOnPlatform=lastMaskValue
         if norm(player.vX,player.vY)>roughLandingThreshold*maxLandingVelocity then
            roughLanding(player)
         end
         player.vY=0
         player.vX=0
         player.y=math.floor(player.y-0.5)
      end
   else
      for y=yMax,math.max(yMin,0)+1,-1 do
         local backgroundMaskRow=backgroundMask[y]
         local playerBitmapRow=player.bitmap[y-yMin]
      
         for x=xMin+1,xMax do
            if playerBitmapRow[x-xMin] and backgroundMaskRow[x]~=0 then
               player.isDestroyed=true
               return
            end
         end
      end
   end
end

function roughLanding(player)
   player.animType="roughLanding"
   player.animIsLoop=false
   player.animFrameNr=1
   playSoundEffect("roughLanding",2*(player.x-centerX)/width)
   player.tip=player.tip*roughLandingTipReductionFactor
end

-- This function ensures that anytime an object is inside of one another, it's position 
-- is reverted to the former one, to ensure this interprenetation never happens
-- this leads to better stacking behavior, but also creates nonlinearities (objects get stuck)
function resolveConstraints()
   local objects=objects
	local numObjects=table.getn(objects)
   for i=1,numObjects-1 do
		for j=i+1,numObjects do 
         local obj1=objects[i]         
         local obj2=objects[j]   
         if obj1.type~="brick" then
            if obj1.canScatterFrom[obj2.type] and
               obj2.canScatterFrom[obj1.type] then
               -- displace objects along the normal away from each other towards their former position
               if colliding(obj1,obj2) then
                  local orig_obj1_x,orig_obj1_y=obj1.x,obj1.y
						local orig_obj2_x,orig_obj2_y=obj2.x,obj2.y
						local normal_x,normal_y=findNormal(obj1,obj2)
                  local displacement_mag=(obj1.oldX-obj1.x)*normal_x+(obj1.oldY-obj1.y)*normal_y
                  obj1.x=obj1.x+displacement_mag*normal_x
                  obj1.y=obj1.y+displacement_mag*normal_y
                  displacement_mag=(obj2.oldX-obj2.x)*normal_x+(obj2.oldY-obj2.y)*normal_y
                  obj2.x=obj2.x+displacement_mag*normal_x
                  obj2.y=obj2.y+displacement_mag*normal_y
						-- if this didn't work, then displace objects by the full penetration distance
						---[[
                  if colliding(obj1,obj2) then
							obj1.x,obj1.y=orig_obj1_x,orig_obj1_y
							obj2.x,obj2.y=orig_obj2_x,orig_obj2_y
							local penetrationDistance=findPenetrationDistance(obj1,obj2,normal_x,normal_y)
							local massFactor=obj1.mass/(obj1.mass+obj2.mass)
							obj1.x=obj1.x-(1-massFactor)*penetrationDistance*normal_x
							obj1.y=obj1.y-(1-massFactor)*penetrationDistance*normal_y
							obj2.x=obj2.x+massFactor*penetrationDistance*normal_x
							obj2.y=obj2.y+massFactor*penetrationDistance*normal_y
						end
                  --]]
					end
            end
         end
      end
   end
end
