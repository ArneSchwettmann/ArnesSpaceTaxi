function createPlayer(x,y,playerNumber)
	local player = {}
   player.type="player"
   player.gearIsDown=false
   player.passengerInside=nil
   player.isFacingLeft=true
   player.playerNumber=playerNumber
   player.numLives=3
   player.fuel=1
   player.score=0
   player.tip=0
   player.landedOnPlatform=0
   player.thruster1 = createThruster(x,y)
   player.thruster2 = createThruster(x,y)
   player.subType=getPlayerSubTypeString(player)
   player.image = animations[player.subType]["none"].images[1]
   player.bitmap = animations[player.subType]["none"].bitmaps[1]
   player.animSpeed = 1/2
   player.width = player.image:getWidth()
   player.height = player.image:getHeight()
   player.halfwidth = 0.5*player.width
   player.halfheight = 0.5*player.height
   player.hasShadow = false
   player.x = x
   player.y = y
   player.vX = 0
   player.vY = 0
   player.fAppliedX = 0
   player.fAppliedY = 0
   player.fImpulseX = 0
   player.fImpulseY = 0
   player.fX = 0
   player.fY = 0
   player.mass = 5
   player.frictionCoeff = 0
   player.gravityX = 0
   player.gravityY = 20
   player.oldX = x
   player.oldY = y
   player.oldVX = 0
   player.oldVY = 0
   player.oldFX = 0
   player.oldFY = 0
   player.shape="irregular"
   player.canScatterFrom=createSet({"passenger"})
   player.restitution={["passenger"]=0.3}
   player.canCollideWith=createSet({"player","passenger"})
   player.animType="none"
   player.animFrameNr=1
   player.animIsLoop=false
   player.isDestroyed=false
   return player
end

function createPassenger(x,y,sourcePlatform,targetPlatform)
	local passenger = {}
   passenger.type="passenger"
   passenger.sourcePlatform=sourcePlatform
   passenger.targetPlatform=targetPlatform
   passenger.outfit=math.random(1,numPassengerOutfits)
   passenger.character=passengerCharacters[math.random(1,#passengerCharacters)]
   passenger.voiceNr=math.random(1,numPassengerVoices)
   passenger.isDone=false
   passenger.isFacingLeft=false
   passenger.subType=getPassengerSubTypeString(passenger)
   passenger.image = animations[passenger.subType]["none"].images[1]
   passenger.bitmap = animations[passenger.subType]["none"].bitmaps[1]
   passenger.voiceType=getPassengerVoiceTypeString(passenger)
   passenger.animSpeed=1/3.0
   passenger.width = passenger.image:getWidth()
   passenger.height = passenger.image:getHeight()
   passenger.halfwidth = 0.5*passenger.width
   passenger.halfheight = 0.5*passenger.height
   passenger.hasShadow = false
   passenger.pitch = math.random()/2.0+0.75
   passenger.hasYelled=false
   passenger.x = x
   passenger.y = y
   passenger.vX = 0
   passenger.vY = 0
   passenger.fAppliedX = 0
   passenger.fAppliedY = 0
   passenger.fImpulseX = 0
   passenger.fImpulseY = 0
   passenger.fX = 0
   passenger.fY = 0
   passenger.mass = infiniteMass
   passenger.frictionCoeff = 0
   passenger.gravityX = 0
   passenger.gravityY = 0
   passenger.oldX = x
   passenger.oldY = y
   passenger.oldVX = 0
   passenger.oldVY = 0
   passenger.oldFX = 0
   passenger.oldFY = 0
   passenger.shape="irregular"
   passenger.canScatterFrom=createSet({"player"})
   passenger.restitution={["player"]=0.3}
   passenger.canCollideWith=createSet({"player"}) -- only collides when waving!
   passenger.animType="none"
   passenger.animFrameNr=1
   passenger.animIsLoop=false
   passenger.isDestroyed=false
   return passenger
end

function createThruster(x,y)
	local thruster = {}
   thruster.type="thruster"
   thruster.isFacingLeft=false
   thruster.subType="thruster"
   thruster.image = animations[thruster.subType]["none"].images[1]
   thruster.animSpeed=1/2
   thruster.width = thruster.image:getWidth()
   thruster.height = thruster.image:getHeight()
   thruster.halfwidth = 0.5*thruster.width
   thruster.halfheight = 0.5*thruster.height
   thruster.hasShadow = false
   thruster.x = x
   thruster.y = y
   thruster.vX = 0
   thruster.vY = 0
   thruster.fAppliedX = 0
   thruster.fAppliedY = 0
   thruster.fImpulseX = 0
   thruster.fImpulseY = 0
   thruster.fX = 0
   thruster.fY = 0
   thruster.mass = infiniteMass
   thruster.frictionCoeff = 0
   thruster.gravityX = 0
   thruster.gravityY = 0
   thruster.oldX = x
   thruster.oldY = y
   thruster.oldVX = 0
   thruster.oldVY = 0
   thruster.oldFX = 0
   thruster.oldFY = 0
   thruster.shape="irregular"
   thruster.canScatterFrom=createSet({})
   thruster.restitution={}
   thruster.canCollideWith=createSet({})
   thruster.animType="none"
   thruster.animFrameNr=1
   thruster.animIsLoop=true
   thruster.isDestroyed=false
   return thruster
end

function getPlayerSubTypeString(player)
   local subTypeString=player.type..tostring(player.playerNumber)
   if not player.gearIsDown then
      subTypeString=subTypeString.."No"
   end
   subTypeString=subTypeString.."Gear"
   if not player.isFacingLeft then
      subTypeString=subTypeString.."Right"
   end
   return subTypeString
end

function getPassengerSubTypeString(passenger)
   local subTypeString=passenger.type..passenger.outfit..passenger.character
   if not passenger.isFacingLeft then
      subTypeString=subTypeString.."Right"
   end
   return subTypeString
end

function getPassengerVoiceTypeString(passenger)
   local voiceTypeString="voice"..passenger.voiceNr..passenger.character
   return voiceTypeString
end

   
function createForceField(x, y, subType, radius)
   local forceField={}
   forceField.type="forceField"
   forceField.subType=subType
   forceField.image = nil
   forceField.width = 2*radius
   forceField.height = 2*radius
   forceField.halfwidth = 1*radius
   forceField.halfheight = 1*radius
   forceField.hasShadow = false
   forceField.x = x
   forceField.y = y
   forceField.vX = 0
   forceField.vY = 0
   forceField.fAppliedX = 0
   forceField.fAppliedY = 0
   forceField.fImpulseX = 0
   forceField.fImpulseY = 0
   forceField.fX = 0
   forceField.fY = 0
   forceField.mass = infiniteMass
   forceField.frictionCoeff = 0.1
   forceField.gravityX = 0
   forceField.gravityY = 0
   forceField.oldX = x
   forceField.oldY = y
   forceField.oldVX = 0
   forceField.oldVY = 0   
   forceField.oldFX = 0
   forceField.oldFY = 0
   forceField.isVisible = true
   forceField.shape="circle"
   forceField.canScatterFrom=createSet({})
   forceField.restitution=0
   forceField.canCollideWith=createSet({"ball"})
   forceField.influences=createSet({"ball"})
   forceField.animType="none"
   forceField.animFrameNr=1
   forceField.animIsLoop=false
   forceField.fieldStrength=-100
   return forceField
end
