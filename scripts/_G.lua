----------------------------------------------------
-- Includes
----------------------------------------------------
package.path = package.path .. ';core\\lua\\?.lua'
package.cpath = package.cpath .. ';bin\\?.dll;..\\bin\\?.dll'

require "lua_extensions"
require "lfs"
bit = require "bit"

----------------------------------------------------
-- scripts\lib\
----------------------------------------------------
require "scripts.lib.utils"

----------------------------------------------------
-- Global Utils
----------------------------------------------------
function Class(name)
	this[name] = setmetatable({},{
		__index = getmetatable(_G).__index,
		__call = function(t,...)
			local o = setmetatable({},{__index=t}) 
			o:initialize(...)
			return o
		end
	})
	return function(...)
		local p = {...}
		this[name].inherited = p
		getmetatable(this[name]).__index=function(t,k)
			for i,v in ipairs(p) do 
				local ret = rawget(v,k)
				if (ret ~= nil) then
					return ret
				end
			end
			return getmetatable(_G).__index(_G,k)
		end
	end
end

local callbacks = {}
function CallbackRegister(name,func_or_userdata)
	if (func_or_userdata == nil) then 
		Msg("CallbackSet func_or_userdata is nil!")
		return
	end
	if not (callbacks[name]) then
		callbacks[name] = {}
	end
	callbacks[name][func_or_userdata] = true
end

function CallbackUnregister(name,func_or_userdata)
	if (callbacks[name]) then
		callbacks[name][func_or_userdata] = nil
	end
end

function CallbackSend(name,...)
	if (callbacks[name]) then
		for func_or_userdata,v in pairs(callbacks[name]) do 
			if (type(func_or_userdata) == "function") then 
				func_or_userdata(...)
			elseif (func_or_userdata[name]) then
				func_or_userdata[name](func_or_userdata,...)
			end
		end
	end
end

------------------------------------------------------------------
-- Event handlers
------------------------------------------------------------------
function ApplicationBegin()
	math.randomseed(os.time())
	
	gSettings = cIniFile("configs\\settings.ltx",true)
	if not (gSettings) then
		Msg("Error: configuration is missing for axr_lua_engine!")
		return
	end
	
	Msg("----------AXR Toolset by Alundaio----------")
	
	local node = "scripts\\"
	for file in lfs.dir(node) do
		if (file ~= ".." and file ~= ".") then
			local fullpath = node .. "\\" .. file
			local mode = lfs.attributes(fullpath,"mode")
			if (mode == "file") then
				local name = file:sub(0,-5)
				if (name ~= "_G" and _G[name] and _G[name].OnApplicationBegin) then 
					_G[name].OnApplicationBegin()
				end
			end
		end
	end
			
	CallbackSend("OnApplicationBeginEnd")
end

function ApplicationExit()
	CallbackSend("OnApplicationExit")
end

function GuiClose(id)
	CallbackSend("OnGuiClose",id)
end

function GuiScriptControlAction(hwnd,event,info)
	CallbackSend("OnScriptControlAction",hwnd,event,info)
end