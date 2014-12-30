function createSet (list)
      local set = {}
      for _, l in ipairs(list) do set[l] = true end
      return set
end

function deepCopy(orig)
   local orig_type=type(orig)
   local copy
   if orig_type=='table' then
      copy={}
      for orig_key,orig_value in next, orig, nil do
         copy[deepCopy(orig_key)]=deepCopy(orig_value)
      end
      setmetatable(copy, deepCopy(getmetatable(orig)))
   else
      copy=orig
   end
   return copy
end

function norm(x,y)
   return math.sqrt(x*x+y*y)
end

function roundDollar(x)
   return (math.floor(x*1)/1)
end