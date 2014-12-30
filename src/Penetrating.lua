function findPenetrationDistanceForTwoRectangles(obj1,obj2,normal_x,normal_y)   
   local min=math.min
   local max=math.max
   local abs=math.abs

   local penetrationDistance=0
   local bottomtopoverlap = min(obj2.y+obj2.halfheight,obj1.y+obj1.halfheight)-max(obj2.y-obj2.halfheight,obj1.y-obj1.halfheight)
   local leftrightoverlap = min(obj2.x+obj2.halfwidth,obj1.x+obj1.halfwidth)-max(obj2.x-obj2.halfwidth,obj1.x-obj1.halfwidth)
	penetrationDistance=abs(leftrightoverlap*normal_x+bottomtopoverlap*normal_y)
	return penetrationDistance
end

function findPenetrationDistance(obj1,obj2,normal_x,normal_y)
   local penetrationDistance=0
	if obj1.shape=="rectangle" and obj2.shape=="rectangle" then
      penetrationDistance=findPenetrationDistanceForTwoRectangles(obj1,obj2,normal_x,normal_y)
   elseif obj1.shape=="circle" and obj2.shape=="circle" then
      penetrationDistance=(obj1.halfwidth+obj2.halfwidth)-norm(obj2.x-obj1.x,obj2.y-obj1.y)
   elseif obj1.shape=="circle" and obj2.shape=="rectangle" or
   obj1.shape=="rectangle" and obj2.shape=="circle" then
		local circ,rect
		if obj1.shape=="circle" then
			circ,rect=obj1,obj2
		else
			circ,rect=obj2,obj1
		end
		-- do they really collide just like two rectangles?
		if (circ.x < rect.x+rect.halfwidth and circ.x > rect.x-rect.halfwidth) or 
		(circ.y < rect.y+rect.halfheight and circ.y > rect.y-rect.halfheight) then
			penetrationDistance = findPenetrationDistanceForTwoRectangles(obj1,obj2,normal_x,normal_y)
		-- if not, then find the closest corner and check whether the distance is smaller than the radius of the circle
		else
			local min=math.min
         local max=math.max
         local abs=math.abs
         local x_dist=min(abs(circ.x-(rect.x-rect.halfwidth)),abs(circ.x-(rect.x+rect.halfwidth)))
			local y_dist=min(abs(circ.y-(rect.y-rect.halfheight)),abs(circ.y-(rect.y+rect.halfheight)))
			penetrationDistance = circ.halfwidth-norm(x_dist,y_dist)
		end
	end
   return penetrationDistance
end



--[[
-- test for penetration, this is just a quick check, not used

function penetration()
	local numObjects=table.getn(objects)
   local penetrationHappens=false
   for i=1,numObjects-1 do
		for j=i+1,numObjects do 
         local obj1=objects[i]         
         local obj2=objects[j]   
         if obj1.canScatterFrom[obj2.type] and
               obj2.canScatterFrom[obj1.type]
         then 
            if penetrating(obj1,obj2) then
                  penetrationHappens=true
               end
         end
      end
   end
   return penetrationHappens
end

function penetratingForTwoRectangles(obj1,obj2)   
   local leftrightoverlap = math.min(obj2.y+obj2.halfheight,obj1.y+obj1.halfheight)-math.max(obj2.y-obj2.halfheight,obj1.y-obj1.halfheight)
   local bottomtopoverlap = math.min(obj2.x+obj2.halfwidth,obj1.x+obj1.halfwidth)-math.max(obj2.x-obj2.halfwidth,obj1.x-obj1.halfwidth)
      return leftrightoverlap>1 and bottomtopoverlap>1
end

function penetrating(obj1,obj2)
   local collisionHappens=false
   if obj1.shape=="rectangle" and obj2.shape=="rectangle" then
      collisionHappens=penetratingForTwoRectangles(obj1,obj2)
   elseif obj1.shape=="circle" and obj2.shape=="circle" then
      collisionHappens = norm(obj2.x-obj1.x,obj2.y-obj1.y) < obj1.halfwidth+obj2.halfwidth
   elseif obj1.shape=="circle" and obj2.shape=="rectangle" or
   obj1.shape=="rectangle" and obj2.shape=="circle" then
      -- quick check: if the bounding rectangles do not even overlap -> no collision, return
      local boundingBoxesCollide=penetratingForTwoRectangles(obj1,obj2)
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
               collisionHappens = norm(x_dist,y_dist)<circ.halfwidth-1
         end
      end
   end
   return collisionHappens
end
--]]