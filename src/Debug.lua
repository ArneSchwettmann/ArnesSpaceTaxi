function debugOutput()   
   -- debug output
   love.graphics.setColor(255,0,0,255)
   --love.graphics.line(playerCenter_x,playerCenter_y,playerCenter_x+forceOnBall_x*0.005,playerCenter_y+forceOnBall_y*0.005)
   love.graphics.setColor(0,0,0,255)
   --love.graphics.line(playerCenter_x,playerCenter_y,playerCenter_x+normal_x*50,playerCenter_y+normal_y*50)
   --love.graphics.print("Friction value: "..tostring(player.frictionCoeff), 10, 20)
   --love.graphics.print("Bat mass value: "..tostring(player.mass), 10, 30)  
   --love.graphics.print("BatForce: "..tostring(player.fAppliedX).." "..tostring(player.fAppliedY), 10, 40)
   love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 60, 40)
   
   if collision==true then
      love.graphics.print("collision", centerX-100, centerY-5)
   else 
      love.graphics.print("no collision", centerX-100, centerY-5)
   end
   if influence==true then
      love.graphics.print("influence", centerX-200, centerY-15)
   else 
      love.graphics.print("no influence", centerX-200, centerY-5)
   end
end
