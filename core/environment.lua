do
	setmetatable(_G, {__index=function(t,k)
		if (k == "this") then 
			return t 
		end
		
		local result = rawget(_G,k)
		if (result ~= nil) then
			return result
		end
		
		local chunk = loadfile("scripts\\classes\\"..k..".lua")
		if (chunk) then
			local status, err = pcall(chunk)
			if (err) then
				Msg(err)
			end
			return rawget(_G,k)
		end
		
		chunk = loadfile("scripts\\"..k..".lua")
		if (chunk) then
			local env = setmetatable({},getmetatable(_G))
			setfenv(chunk,env)
			local status, err = pcall(chunk)
			if (err) then 
				Msg(err)
			else
				rawset(_G,k,env)
				return env
			end
		end
	end})
	
	local chunk, errormsg = loadfile("scripts\\_G.lua")
	if (errormsg) then 
		error(errormsg)
	elseif (chunk) then
		local status, err = pcall(chunk)
		if (err) then 
			MsgBox(err)
		end
	end
	
	ApplicationBegin()
end