Modules = {}
Scripts = {}

require'lua_extensions'
require'lfs'
Class = require'Class'
CallbackManager = require'CallbackManager'
require'Utils'
require'UIBase'

function CreateScriptIfNotExist(path,fname)
	
	-- we ignore because we want to require these modules instead
	local ignore = {
		["core\\_G.lua"] = true,
		["core\\luaCheck.lua"] = true,
		["core\\Class.lua"] = true,
		["core\\Utils.lua"] = true,
		["core\\CallbackManager.lua"] = true,
		["core\\UIBase.lua"] = true
	}
	
	-- should be plugin directory; removes 'lua\' in path
	local dir = trim_directory( get_path(path):sub(1,-2) )

	--Msg("path=%s dir=%s fname=%s",path,dir,fname)
	
	if (ignore[dir.."\\"..fname]) then 
		return 
	end
	
	package.path = package.path .. ";plugins\\"..dir.."\\lua\\?.lua"
	
	local name = fname:sub(1,-5)
	
	if (_G[name]) then 
		Msg("Error: %s namespace already used! path=%s",name,path)
		return
	else 
		_G[name] = {}
		local l = assert(loadfile(path.."\\"..fname))
		setfenv(l,_G[name])
		setmetatable(_G[name],{ __index = _G })
		Modules[dir] = l()
	end	
	
	if not (Scripts[dir]) then 
		Scripts[dir] = {}
	end
	
	Scripts[dir][name] = path
	
	Msg("Loaded %s.%s",dir,name)
end

function IterateScriptsForEach(functor_name,...)
	for plugin,t in pairs(Scripts) do
		for script,name in pairs(t) do
			--Msg("%s.%s[%s]",plugin,script,functor_name)
			if (_G[script] and _G[script][functor_name]) then 
				_G[script][functor_name]()
			end
		end
	end
end

function ApplicationExit()
	IterateScriptsForEach("OnApplicationExit")
	CallbackSend("OnApplicationExit")
end

function ApplicationBegin()
	gSettings = IniFile.New(".\\settings.ini",true)
	if not (gSettings) then
		Msg("Error: configuration is missing for axr_lua_engine!")
		return
	end

	UIMainMenuWnd = UIMain.cUIMain()
	IterateScriptsForEach("OnApplicationBegin")
	CallbackSend("OnApplicationBegin")
end

function GuiClose(idx)
	Msg("Real GuiClose %s",idx)
	CallbackSend("OnGuiClose",tostring(idx))
end