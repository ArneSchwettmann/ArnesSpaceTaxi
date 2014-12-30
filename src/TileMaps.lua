function loadAnimationsFromTileMaps()
   local animations=animations
 
   local tileMaps= {
      "player1",
      "player2",
      "player3",
      "player4",
      "player5",
      "passenger1",
      "thrusters",
   }
   -- animations I have so far with numFrames. For "destroyed" anims, the last frame should be duplicated to ensure
   -- it is shown
   -- the table contains type, subtype and numFrames
   local tileMapContents={}
   
   for i=1,maxNumPlayers do
      tileMapContents["player"..i] = {  
      {"player"..i.."NoGear","none",1},
      {"player"..i.."NoGear","destroyed",8},
      {"player"..i.."NoGearRight","none",1},
      {"player"..i.."NoGearRight","destroyed",8},
      {"player"..i.."Gear","none",1},
      {"player"..i.."Gear","destroyed",8},
      {"player"..i.."GearRight","none",1},
      {"player"..i.."GearRight","destroyed",8},
      {"player"..i.."Gear","roughLanding",6},
      {"player"..i.."GearRight","roughLanding",6},
      }
   end

   tileMapContents["passenger1"] = {
      {"passenger1Male","none",1},
      {"passenger1Male","destroyed",5},
      {"passenger1Male","appearing",5},
      {"passenger1Male","waving",2},
      {"passenger1Male","walking",2},
      {"passenger1MaleRight","none",1},
      {"passenger1MaleRight","destroyed",5},
      {"passenger1MaleRight","appearing",5},
      {"passenger1MaleRight","waving",2},
      {"passenger1MaleRight","walking",2},
      {"passenger1Malechild","none",1},
      {"passenger1Malechild","destroyed",5},
      {"passenger1Malechild","appearing",5},
      {"passenger1Malechild","waving",2},
      {"passenger1Malechild","walking",2},
      {"passenger1MalechildRight","none",1},
      {"passenger1MalechildRight","destroyed",5},
      {"passenger1MalechildRight","appearing",5},
      {"passenger1MalechildRight","waving",2},
      {"passenger1MalechildRight","walking",2},
   }   
   
   tileMapContents["thrusters"] = {
      {"thruster","left",2},
      {"thruster","right",2},
      {"thruster","facingLeftDown",2},
      {"thruster","facingRightDown",2},
      {"thruster","up",2},
      {"thruster","none",1},
   }
   
   for _,tileMapName in pairs(tileMaps) do
      loadFramesFromTileMap(tileMapName,tileMapContents[tileMapName],animations,gfxDir)
   end
end

function loadFramesFromTileMap(tileMapName,animationList,animations,dir)
   local tileMap=love.image.newImageData(gfxDir..tileMapName..".png")
   local xMin,xMax,yMin,yMax=0,0,0,0
   local x,y=0,0
   local rowHeight=0
   local gridR,gridG,gridB,gridA=tileMap:getPixel(x,y)
   local animNr=1
   local frameNr=1
   local v=animationList[animNr][1]
   local v2=animationList[animNr][2]
   animations[v]={}
   animations[v][v2]={}
   local anim=animations[v][v2]
   anim.numFrames=0
   anim.images={}
   anim.bitmaps={}
            
   while animNr<=#animationList do
      y=y+1
      x=x+1
      if x>tileMap:getWidth()-1 then
         y=y+rowHeight+1
         x=1
         xMin=1
         rowHeight=0
      end
      
      r,g,b,a=tileMap:getPixel(x,y)
      --end of an animation is marked by a four pixel vertical gridline
      if r==gridR and g==gridG and b==gridB and a==gridA then
         if animNr==#animationList then
               return
         else   
            animNr=animNr+1
            v=animationList[animNr][1]
            v2=animationList[animNr][2]
            if animations[v]==nil then
               animations[v]={}
            end
            animations[v][v2]={}
            anim=animations[v][v2]
            anim.numFrames=0
            anim.images={}
            anim.bitmaps={}
            frameNr=1
            x=x+3
         end
      end
      xMin=x
      r=nil
      while not (r==gridR and g==gridG and b==gridB and a==gridA) do
         x=x+1
         if x>tileMap:getWidth()-1 then
               y=y+rowHeight+1
               x=1
               xMin=1
               rowHeight=0
         else
            r,g,b,a=tileMap:getPixel(x,y)
         end
      end
      xMax=x-1
      x=xMax
      yMin=y
      r,g,b,a=tileMap:getPixel(x,y)
      a=nil
      while not (r==gridR and g==gridG and b==gridB and a==gridA) do
         y=y+1
         r,g,b,a=tileMap:getPixel(x,y)
      end
      yMax=y-1
      if yMax-yMin+1>rowHeight then
         rowHeight=yMax-yMin+1
      end
      local imageData=love.image.newImageData(xMax-xMin+1,yMax-yMin+1)
      imageData:paste(tileMap,0,0,xMin,yMin,xMax-xMin+1,yMax-yMin+1)
      
      anim.images[frameNr] = love.graphics.newImage(imageData)
      anim.bitmaps[frameNr] = createBitmap(imageData)
      anim.numFrames=anim.numFrames+1

      frameNr=frameNr+1
      x=xMax+1
      y=yMin-1
   end
   
   for i=1,maxNumPlayers do
      animations["player"..i.."NoGear"]["roughLanding"]=deepCopy(animation["player"..i.."Gear"]["roughLanding"])
      animations["player"..i.."NoGearRight"]["roughLanding"]=deepCopy(animation["player"..i.."GearRight"]["roughLanding"])
   end
   
end   
