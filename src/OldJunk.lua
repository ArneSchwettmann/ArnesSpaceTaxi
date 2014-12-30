
--- old junk
   --[[
   -- This contact force pair is artificial, but prevents the sticking of objects due to constraints (during stacking. I do not fully understand this yet)
   -- Contact force pair, obj2 on obj1 
   if (obj2.fX*normal_x+obj2.fY*normal_y)<=0 then
      fContact_mag=(obj2.fX*normal_x+obj2.fY*normal_y)
      fContact_x=fContact_mag*normal_x
      fContact_y=fContact_mag*normal_y
      obj1.fAppliedX=obj1.fAppliedX+fContact_x
      obj1.fAppliedY=obj1.fAppliedY+fContact_y
      obj2.fAppliedX=obj2.fAppliedX-fContact_x
      obj2.fAppliedY=obj2.fAppliedY-fContact_y
   end
   -- Contact force pair, obj1 on obj2 
   if (obj1.fX*normal_x+obj1.fY*normal_y)>=0 then
      fContact_mag=(obj1.fX*normal_x+obj1.fY*normal_y)
      fContact_x=fContact_mag*normal_x
      fContact_y=fContact_mag*normal_y
      obj2.fAppliedX=obj2.fAppliedX+fContact_x
      obj2.fAppliedY=obj2.fAppliedY+fContact_y
      obj1.fAppliedX=obj1.fAppliedX-fContact_x
      obj1.fAppliedY=obj1.fAppliedY-fContact_y
   end 
   --]]

   --[[
   factor=(1.0+cR)/(obj2.mass+obj1.mass)
   
   local deltaV2_x=factor*(obj1.vX-obj2.vX)
   local deltaV2_y=factor*(obj1.vY-obj2.vY)
   local deltaV2_mag=(deltaV2_x*normal_x+deltaV2_y*normal_y)
   if deltaV2_mag<=0 then 
      deltaV2_mag=0 
   end   
   deltaV2_x=deltaV2_mag*normal_x
   deltaV2_y=deltaV2_mag*normal_y
   if obj2.mass < infiniteMass then
      obj2.vX = obj2.vX+obj1.mass*deltaV2_x
      obj2.vY = obj2.vY+obj1.mass*deltaV2_y 
   end
   if obj1.mass < infiniteMass then
      obj1.vX = obj1.vX-obj2.mass*deltaV2_x
      obj1.vY = obj1.vY-obj2.mass*deltaV2_y   
   end
   --]]

--adaptive timestep this does not work well with many balls, the timestep becomes too small, and the program slows
-- down to a crawl
--[[
function adaptiveEvolve(dt)
   -- optionally: take small steps instead of one big one to increase accuracy of collisions
   local stepTime=dt
   local currentTime=0

   while currentTime<dt do
      
      for i,obj in ipairs(objects) do
         if obj.type=="player" then
            obj.fAppliedX=inputX
            obj.fAppliedY=inputY
         else
            obj.fAppliedX = 0
            obj.fAppliedY = 0
         end
      end
  
      for i,obj in ipairs(objects) do
         obj.oldVX=obj.vX
         obj.oldVY=obj.vY
         obj.oldX=obj.x
         obj.oldY=obj.y
         obj.oldFx=obj.fAppliedX
         obj.oldFY=obj.fAppliedY
      end
      takeTimeStep(stepTime)
      if penetration() and stepTime>0.002 then
         for i,obj in ipairs(objects) do
            obj.VX=obj.oldVX
            obj.VY=obj.oldVY
            obj.x=obj.oldX
            obj.y=obj.oldY
         end
         stepTime=stepTime/2
      else 
         resolveCollisions(stepTime)
   
         for i,obj in ipairs(objects) do
            obj.VX=obj.oldVX
            obj.VY=obj.oldVY
            obj.x=obj.oldX
            obj.y=obj.oldY
         end
   
         takeTimeStep(stepTime)
         checkBorders()
         -- artificially change object's positions to prevent interpenetration
         resolveConstraints()

         currentTime=currentTime+stepTime
         stepTime=dt-currentTime
      end
   end
end
--]]