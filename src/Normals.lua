function findNormalForTwoRectangles(obj1,obj2)
   local min=math.min
   local max=math.max

   local normal_x,normal_y
   -- setup normals for collisions between rectangular obj2 and rectangular obj1
   local bottomtopoverlap = min(obj2.y+obj2.halfheight,obj1.y+obj1.halfheight)-max(obj2.y-obj2.halfheight,obj1.y-obj1.halfheight)
   local leftrightoverlap = min(obj2.x+obj2.halfwidth,obj1.x+obj1.halfwidth)-max(obj2.x-obj2.halfwidth,obj1.x-obj1.halfwidth)
	local previousbottomtopoverlap = min(obj2.oldY+obj2.halfheight,obj1.oldY+obj1.halfheight)-max(obj2.oldY-obj2.halfheight,obj1.oldY-obj1.halfheight)
   local previousleftrightoverlap = min(obj2.oldX+obj2.halfwidth,obj1.oldX+obj1.halfwidth)-max(obj2.oldX-obj2.halfwidth,obj1.oldX-obj1.halfwidth)
	local horizontalCollision=leftrightoverlap*previousleftrightoverlap<0 
	local verticalCollision=bottomtopoverlap*previousbottomtopoverlap<0
	-- already colliding earlier? Use shortest overlap to find normal!
   if horizontalCollision==false and verticalCollision==false then
		if leftrightoverlap <= bottomtopoverlap then
			horizontalCollision=true
		end
		if bottomtopoverlap <= leftrightoverlap then
			verticalCollision=true
		end
	end
	-- colliding on the corner?
   if horizontalCollision and verticalCollision then
      if obj2.y+obj2.halfheight>obj1.y+obj1.halfheight then
         normal_y=oneOverSqrt2
      else
         normal_y=-oneOverSqrt2
      end
		if obj2.x+obj2.halfwidth>=obj1.x+obj1.halfwidth then
         normal_x=oneOverSqrt2
      else
         normal_x=-oneOverSqrt2
      end
	elseif horizontalCollision then
      if obj2.x+obj2.halfwidth>=obj1.x+obj1.halfwidth then
         normal_x,normal_y=1,0
      else
         normal_x,normal_y=-1,0
      end
   elseif verticalCollision then
      if obj2.y+obj2.halfheight>obj1.y+obj1.halfheight then
         normal_x,normal_y=0,1
      else
         normal_x,normal_y=0,-1
      end
   end
   return normal_x,normal_y
end

function findNormalForTwoCircles(obj1,obj2)
   local normal_x
   local normal_y
   --normal points from object 1 center to object 2 center
   normal_x=obj2.x-obj1.x
   normal_y=obj2.y-obj1.y
   local norm=norm(normal_x,normal_y)
   normal_x=normal_x/norm
   normal_y=normal_y/norm
   return normal_x,normal_y
end


function findNormal(obj1,obj2)
   local normal_x,normal_y
   
   if obj1.shape=="rectangle" and obj2.shape=="rectangle" then
      normal_x, normal_y = findNormalForTwoRectangles(obj1,obj2)
   
   elseif obj1.shape=="circle" and obj2.shape=="circle" then
      normal_x, normal_y = findNormalForTwoCircles(obj1,obj2)
   
   elseif obj1.shape=="irregular" or obj2.shape=="irregular" then
      normal_x, normal_y = findNormalForTwoCircles(obj1,obj2)

   elseif obj1.shape=="circle" and obj2.shape=="rectangle" or
   obj1.shape=="rectangle" and obj2.shape=="circle" then
      
      local circ, rect
      if obj1.shape=="circle" then
         circ,rect=obj1,obj2
      else
         circ,rect=obj2,obj1
      end
      -- Does the circle center lie within the horizontal area or the vertical extend of the rectangle?
      -- if yes, it collides as if the circle was a rectangle
      
      if (circ.x < rect.x+rect.halfwidth and circ.x > rect.x-rect.halfwidth) or 
         (circ.y < rect.y+rect.halfheight and circ.y > rect.y-rect.halfheight) then
         normal_x, normal_y = findNormalForTwoRectangles(rect,circ)
      else
      -- it collides by hitting one of the corners of the rectangle. Find the closest corner and calculate distance to circle center
         -- horizontally closest corner
         local abs=math.abs
         if abs(circ.x-(rect.x+rect.halfwidth))<abs(circ.x-(rect.x-rect.halfwidth)) then
            normal_x=circ.x-(rect.x+rect.halfwidth)
         else 
            normal_x=circ.x-(rect.x-rect.halfwidth)
         end
         -- vertical: is it closer to the top side?
         if abs(circ.y-(rect.y+rect.halfheight))<abs(circ.y-(rect.y-rect.halfheight)) then
            normal_y=circ.y-(rect.y+rect.halfheight)
         else
            -- no -> bottom right corner of rectangle collides
            normal_y=circ.y-(rect.y-rect.halfheight)
         end
      end
      --normal should point towards obj2, I calculated it to point towards the circle, so invert it if needed
      if obj1.shape=="circle" then
         normal_y=-1*normal_y
         normal_x=-1*normal_x
      end
      local norm=norm(normal_x,normal_y)
      normal_x=normal_x/norm
      normal_y=normal_y/norm
   end
   return normal_x,normal_y
end