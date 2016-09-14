_AXRTOOLSET_METATABLE_ = {}
local _G = _G
----------------------------------------------------
-- INCLUDES
----------------------------------------------------
require "lua_extensions"
require "lfs"
Marshal = require "marshal"
Class = require "middleclass"
require "utils"
require "inifile"

----------------------------------------------------
-- Global Utils
----------------------------------------------------
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
--------------------------------------------------------------
-- Setup the Environment (Do last because setfenv no longer in global namespace)
--------------------------------------------------------------
 
function ProcessFileIfExist(path,fname)
	if not (path) then 
		return
	end
	local new_t = {}
	local env = setmetatable(new_t, {__index=_AXRTOOLSET_METATABLE_})
	local l = loadfile(path.."\\"..fname, 't', env)
	if (l) then
		l()
		return setmetatable(env, {__index=_AXRTOOLSET_METATABLE_})
	end
end

function auto_load(t,k)
	local result = rawget(_G,k)-- or rawget(t,k)
	if (result) then
		return result
	end
	
	if not(t and k and type(t) == "table" and type(k) == "string") then 
		return
	end
	
	local path
	local fname = k .. ".lua"
	local function on_execute(fs_path,fs_fname)
		if (fs_fname == fname) then 
			path = fs_path
			return
		end
	end
	
	recurse_subdirectories_and_execute("scripts",{"lua"},on_execute)
	
	local v = ProcessFileIfExist(path,fname)
	if (v) then
		rawset(t,k,v)
	end
	return v
end 

do
    setmetatable(_AXRTOOLSET_METATABLE_, {__index = auto_load})
	_G._G = _AXRTOOLSET_METATABLE_
	setfenv(1,_AXRTOOLSET_METATABLE_)
	
	assert(loadfile("scripts\\_G.lua", 't', _AXRTOOLSET_METATABLE_))()
	
	ApplicationBegin()
end

