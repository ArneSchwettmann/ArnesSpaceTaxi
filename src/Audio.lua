function playSoundEffect(soundEffectName,panning,pitch,volume)
   local source=love.audio.newSource(soundEffects[soundEffectName], "static")
   local panning = panning or 0
   local pitch = pitch or 1.0
   local volume = volume or 1.0
   source:setPosition(panning,0,defaultAudioSourceZPos)
   source:setPitch(pitch)
   source:setVolume(volume)
   love.audio.play(source)
end

function playPassengerVoice(voiceType,toPlatform,panning,pitch,volume)
   local panning = panning or 0
   local pitch = pitch or 1.0
   local volume = volume or 1.0
   local voice={}
   voice.sources={}
   voice.sources[1]=love.audio.newSource(soundEffects[voiceType.."_pad"], "static")
   voice.sources[2]=love.audio.newSource(soundEffects[voiceType.."_"..tostring(toPlatform)],"static")
   voice.sources[3]=love.audio.newSource(soundEffects[voiceType.."_please"],"static")
   for i=1,3 do
      voice.sources[i]:setPosition(panning,0,defaultAudioSourceZPos)
      voice.sources[i]:setPitch(pitch)
      voice.sources[i]:setVolume(volume)
   end
   voice.currentSource=1
   love.audio.play(voice.sources[voice.currentSource])
   table.insert(passengerVoices,voice)
end

function updatePassengerVoices()
   for i=#passengerVoices,1,-1 do
      local voice=passengerVoices[i]
      if voice.sources[voice.currentSource]:isStopped() then
         if voice.currentSource==3 then
            table.remove(passengerVoices,i)
         else
            voice.currentSource=voice.currentSource+1
            love.audio.play(voice.sources[voice.currentSource])
         end
      end
   end
end
      
function playThrusterSoundEffect(playerNumber,panning)
   thrusterAudioSource[playerNumber]:setPosition(panning,0,defaultAudioSourceZPos)
   love.audio.play(thrusterAudioSource[playerNumber])
end

function stopThrusterSoundEffect(playerNumber)
   love.audio.stop(thrusterAudioSource[playerNumber])
end

function updateThrusterSoundEffect()
   local thrusterEngaged=false
   for i,obj in ipairs(objects) do
      if obj.type=="player" then
         if obj.fAppliedX~=0 or obj.fAppliedY~=0 then
            playThrusterSoundEffect(obj.playerNumber,2*(obj.x-centerX)/width)
         else
            stopThrusterSoundEffect(obj.playerNumber)
         end
      end      
   end
   for i,obj in ipairs(playersEscaped) do
      stopThrusterSoundEffect(obj.playerNumber)
   end
   for i,obj in ipairs(respawningPlayers) do
      stopThrusterSoundEffect(obj.playerNumber)
   end
end

function playRefuelingSoundEffect(panning)
   refuelingAudioSource:setPosition(panning,0,defaultAudioSourceZPos)
   love.audio.play(refuelingAudioSource)
end

function stopRefuelingSoundEffect()
   love.audio.stop(refuelingAudioSource)
end

function updateSoundEffects()
   updateThrusterSoundEffect()
   updatePassengerVoices()
end

function loadSoundEffects()
   local existingSoundEffects={
      "playerDestroyed",
      "passengerDestroyed",
      "passengerAppears",
      "player1Thrusters",
      "refueling",
      "roughLanding",
      "exitopen",
      "voice1Male_pad",
      "voice1Male_1",
      "voice1Male_2",
      "voice1Male_3",
      "voice1Male_4",
      "voice1Male_5",
      "voice1Male_6",
      "voice1Male_7",
      "voice1Male_8",
      "voice1Male_9",
      "voice1Male_10",
      "voice1Male_please",
      "voice1Male_thanks",
      "voice1Male_heytaxi",
      "voice1Male_ouch",
      "voice1Malechild_pad",
      "voice1Malechild_1",
      "voice1Malechild_2",
      "voice1Malechild_3",
      "voice1Malechild_4",
      "voice1Malechild_5",
      "voice1Malechild_6",
      "voice1Malechild_7",
      "voice1Malechild_8",
      "voice1Malechild_9",
      "voice1Malechild_10",
      "voice1Malechild_please",
      "voice1Malechild_thanks",
      "voice1Malechild_heytaxi",
      "voice1Malechild_ouch",
   }
   
   local dir=sndDir
   
   for i=1,#existingSoundEffects do
      soundEffects[existingSoundEffects[i]]=love.sound.newSoundData(dir..existingSoundEffects[i]..".ogg")
   end
   
   for i=1,maxNumPlayers do
      thrusterAudioSource[i]=love.audio.newSource(soundEffects["player1Thrusters"],"static")
      thrusterAudioSource[i]:setLooping(true)
   end
   
   refuelingAudioSource=love.audio.newSource(soundEffects["refueling"],"static")
   refuelingAudioSource:setLooping(true)
end

