function ApplicationBegin()
	gSettings = cIniFile:new(".\\settings.ini",true)
	if not (gSettings) then
		Msg("Error: configuration is missing for axr_lua_engine!")
		return
	end
	
	Msg("----------AXR Toolset by Alundaio----------")
	
	-- Execute OnApplicationBegin for every script that has it
	local autoload_modules = {}
	local function on_execute(fs_path,fs_fname)
		-- note calling _G[name] triggers ProcessIfNotExist and will loadfile all *.lua automatically where each script has it's own namescape
		local name = fs_fname:sub(0,-5)
		if (name ~= "_G" and _G[name] and _G[name].OnApplicationBegin) then 
			table.insert(autoload_modules,name)
		end
	end
	
	recurse_subdirectories_and_execute("scripts",{"lua"},on_execute)
	
	-- We only want to trigger the function call AFTER all scripts are processed
	for i=1,#autoload_modules do 
		_G[autoload_modules[i]].OnApplicationBegin()
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