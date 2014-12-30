function collidingForTwoRectangles(obj1,obj2)   
   local leftrightoverlap = math.min(obj2.y+obj2.halfheight,obj1.y+obj1.halfheight)-math.max(obj2.y-obj2.halfheight,obj1.y-obj1.halfheight)
   local bottomtopoverlap = math.min(obj2.x+obj2.halfwidth,obj1.x+obj1.halfwidth)-math.max(obj2.x-obj2.halfwidth,obj1.x-obj1.halfwidth)
      return leftrightoverlap>0 and bottomtopoverlap>0
end

function collidingForTwoBitmasks(obj1,obj2)
   -- I need to find the overlap rectangle window and check each pixel
   local collisionHappens=false
   local max=math.max
   local min=math.min
   local floor=math.floor
   local xOffset1=max(0,obj2.x-obj2.halfwidth-(obj1.x-obj1.halfwidth))
   local xOffset2=max(0,obj1.x-obj1.halfwidth-(obj2.x-obj2.halfwidth))
   local yOffset1=max(0,obj2.y-obj2.halfheight-(obj1.y-obj1.halfheight))
   local yOffset2=max(0,obj1.y-obj1.halfheight-(obj2.y-obj2.halfheight))
   local leftrightoverlap = min(obj2.x+obj2.halfwidth,obj1.x+obj1.halfwidth)-max(obj2.x-obj2.halfwidth,obj1.x-obj1.halfwidth)
   local bottomtopoverlap = min(obj2.y+obj2.halfheight,obj1.y+obj1.halfheight)-max(obj2.y-obj2.halfheight,obj1.y-obj1.halfheight)
   xOffset1=floor(xOffset1)
   xOffset2=floor(xOffset2)
   yOffset1=floor(yOffset1)
   yOffset2=floor(yOffset2)
   leftrightoverlap=floor(leftrightoverlap)
   bottomtopoverlap=floor(bottomtopoverlap)
   for y=1,bottomtopoverlap do
      local bitmap1Row=obj1.bitmap[y+yOffset1]
      local bitmap2Row=obj2.bitmap[y+yOffset2]
      for x=1,leftrightoverlap do
         if bitmap1Row[x+xOffset1] and bitmap2Row[x+xOffset2] then
            collisionHappens=true
            y=bottomtopoverlap
            x=leftrightoverlap
         end
      end
   end
   return collisionHappens
end
      
function colliding(obj1,obj2)
   local collisionHappens=false
   if obj1.shape=="irregular" and obj2.shape=="irregular" then
      local boundingBoxesCollide=collidingForTwoRectangles(obj1,obj2)
         if boundingBoxesCollide==false then
            collisionHappens=false
         else
            collisionHappens=collidingForTwoBitmasks(obj1,obj2)
         end
   end
   return collisionHappens
end

--[[   
   if obj1.shape=="rectangle" and obj2.shape=="rectangle" then
      collisionHappens=collidingForTwoRectangles(obj1,obj2)
   elseif obj1.shape=="circle" and obj2.shape=="circle" then
      collisionHappens = norm(obj2.x-obj1.x,obj2.y-obj1.y) < obj1.halfwidth+obj2.halfwidth
   elseif obj1.shape=="circle" and obj2.shape=="rectangle" or
   obj1.shape=="rectangle" and obj2.shape=="circle" then
      -- quick check: if the bounding rectangles do not even overlap -> no collision, return
      local boundingBoxesCollide=collidingForTwoRectangles(obj1,obj2)
      if boundingBoxesCollide==false then
         collisionHappens=false
      -- if not, we have to do more checks
      else
         local circ,rect
         if obj1.shape=="circle" then
            circ,rect=obj1,obj2
         else
            circ,rect=obj2,obj1
         end
         -- do they really collide just like two rectangles?
         if (circ.x < rect.x+rect.halfwidth and circ.x > rect.x-rect.halfwidth) or 
         (circ.y < rect.y+rect.halfheight and circ.y > rect.y-rect.halfheight) then
            collisionHappens = boundingBoxesCollide
         -- if not, then find the closest corner and check whether the distance is smaller than the radius of the circle
         else
            local x_dist=math.min(math.abs(circ.x-(rect.x-rect.halfwidth)),math.abs(circ.x-(rect.x+rect.halfwidth)))
            local y_dist=math.min(math.abs(circ.y-(rect.y-rect.halfheight)),math.abs(circ.y-(rect.y+rect.halfheight)))
               collisionHappens = norm(x_dist,y_dist)<circ.halfwidth
         end
      end
   end
   --]]