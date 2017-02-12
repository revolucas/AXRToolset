function OnApplicationBegin()
	MainMenu = cMainMenu()
	CallbackRegister("OnApplicationBeginEnd",OnApplicationBeginEnd)
end

function OnApplicationBeginEnd()
	MainMenu:Show(true)
end

function AddPluginButton(text,name,func,...)
	MainMenu:AddPluginButton(text,name,func,...)
end

-----------------------------------------------------------------
-- UI Class Definition
-----------------------------------------------------------------
Class "cMainMenu" (cUIBase)
function cMainMenu:initialize(id)
	self.inherited[1].initialize(self,id)
	self.plugins = {}
end

function cMainMenu:Reinit()
	self.inherited[1].Reinit(self)
	
	self.y = 75
	
	self:Gui("Add|Tab2|x0 y0 w1024 h720|%t_plugins^%t_settings")
	self:Gui("Tab|%t_plugins")
		self:Gui("Add|Text|x22 y695 w140 h20|v1.00.00")
		-- Buttons 
		-- register plugin buttons
		for name,t in spairs(self.plugins) do 
			self:Gui("Add|Button|gOnScriptControlAction x370 y%s w230 h20 v%s|%s",self.y,name,Language.translate(t.text))
			self.y = self.y + 25
		end
	
		-- GroupBox
		self:Gui("Add|GroupBox|x360 y50 w250 h660|%t_plugins_launcher")
		self:Gui("Add|GroupBox|x720 y50 w155|%t_lang")
		
		self:Gui("Add|Picture|gOnScriptControlAction x730 y70 vApplicationSelectEnglish|icons/english.png")
		self:Gui("Add|Picture|gOnScriptControlAction x765 y70 vApplicationSelectFrench|icons/french.png")
		self:Gui("Add|Picture|gOnScriptControlAction x800 y70 vApplicationSelectRussian|icons/russian.png")
		self:Gui("Add|Picture|gOnScriptControlAction x835 y70 vApplicationSelectSpanish|icons/spanish.png")	
		
	self:Gui("Tab|%t_settings")
	
		-- GroupBox
		self:Gui("Add|GroupBox|x10 y50 w510 h75|%t_gamedata %t_path")
		--self:Gui("Add|GroupBox|x10 y150 w510 h75|%t_lang")
	
		-- Buttons 
		self:Gui("Add|Button|gOnScriptControlAction x485 y80 w25 h20 vApplicationBrowseGamedata|...")
		self:Gui("Add|Button|gOnScriptControlAction x485 y680 w120 h20 vApplicationSaveSettings|%t_save_settings")
	
		-- Editbox 
		self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vApplicationGamedataPath|") -- Edit System.ltx
		
		--local langs = Language.ini:GetSections()
		--self:Gui("Add|DropDownList|gOnScriptControlAction x25 y180 w220 h30 R40 H300 vApplicationLanguage|"..table.concat(langs,"^"))
	
	self:Gui("Show|w1024 h720|AXR Toolset")
	GuiControl(self.ID,"","ApplicationGamedataPath",gSettings:GetValue("core","Gamedata_Path") or "")
	GuiControl(self.ID,"ChooseString","ApplicationLanguage",gSettings:GetValue("core","language") or "")
end 

function cMainMenu:AddPluginButton(text,name,func,...)
	self.plugins[name] = {text=text,f=func,p={...}}
end

function cMainMenu:OnScriptControlAction(hwnd,event,info)
	if (hwnd == "") then 
		return 
	end 
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","ApplicationBrowseGamedata")) then 
		local dir = FileSelectFolder("*"..(gSettings:GetValue("core","Gamedata_Path") or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","ApplicationGamedataPath",dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ApplicationSaveSettings")) then 
		self:Gui("Submit|NoHide")
		gSettings:SetValue("core","Gamedata_Path",ahkGetVar("ApplicationGamedataPath"))
		--gSettings:SetValue("core","language",ahkGetVar("ApplicationLanguage"))
		gSettings:Save()
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ApplicationSelectEnglish")) then 
		self:Gui("Submit|NoHide")
		gSettings:SetValue("core","language","english")
		gSettings:Save()
		MainMenu:Destroy()
		MainMenu:Create()
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ApplicationSelectFrench")) then
		self:Gui("Submit|NoHide")
		gSettings:SetValue("core","language","french")
		gSettings:Save()
		MainMenu:Destroy()
		MainMenu:Create()
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ApplicationSelectRussian")) then
		self:Gui("Submit|NoHide")
		gSettings:SetValue("core","language","russian")
		gSettings:Save()
		MainMenu:Destroy()
		MainMenu:Create()
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ApplicationSelectSpanish")) then
		self:Gui("Submit|NoHide")
		gSettings:SetValue("core","language","spanish")
		gSettings:Save()
		MainMenu:Destroy()
		MainMenu:Create()
	end
	
	for name,t in pairs(self.plugins) do 
		if (t.f and hwnd == GuiControlGet(self.ID,"hwnd",name)) then
			t.f(unpack(t.p),hwnd,event,info)
		end
	end
end

function cMainMenu:OnGuiClose(idx)
	GoSub("OnExit")
end

function cMainMenu:Show(bool)
	self.inherited[1].Show(self,bool)
	--[[
	local xml = cXmlFile(gSettings:GetValue("core","Gamedata_Path").."\\configs\\gameplay\\character_desc_general.xml")

	for i=1,xml:GetCount("specific_character") do 
		if (xml:FindNext("specific_character","id")) then
			local node = xml.ptr -- remember so we can go back to this node for next iteration
			if (xml:FindNext("community")) then
				local faction = xml:GetContent()
				if (xml:FindNext("supplies")) then 
					local supply_str = xml:GetContent()
					Msg(supply_str)

				end
			end
			xml.ptr = node -- go back to parent
		end
	end
	--]]
	--xml:Save()
	--[[
	local i_p = "E:\\STALKER\\Games\\COP_COC_db_converter\\unpacked\\textures"
	local o_p = "E:\\STALKER\\Games\\COP_COC_db_converter\\dxt1a"
	
	local function on_execute(path,fname)
		local full_path = path.."\\"..fname
		local dds = cDDS(full_path)
		if (dds and dds:PixelFormatIsDXT1()) then
			Msg("checking for 1-bit alpha %s",fname)
			if (dds:HasAlpha()) then
				local relative_path = trim_final_backslash(string.gsub(path,escape_lua_pattern(i_p),""))
				RunWait( strformat([ [xcopy "%s" "%s" /y /i /q /c] ],i_p.."\\"..trim_ext(relative_path).."\\"..trim_ext(fname)..".thm",o_p..relative_path.."\\") , working_directory )
				RunWait( strformat([ [xcopy "%s" "%s" /y /i /q /c] ],i_p.."\\"..trim_ext(relative_path).."\\"..fname,o_p..relative_path.."\\") , working_directory )
			end
		end
	end
	file_for_each(i_p,{"dds"},on_execute)
	--]]
--[[ 	local ltx = cIniFile("debug_visual.ltx")
	local ipath = [ [E:\STALKER\Games\COP_COC_db_converter\unpacked\meshes\actors] ]
	local function on_execute(path,fname,fullpath)
		local relative_path = trim_ext("actors"..trim_final_backslash(string.gsub(fullpath,escape_lua_pattern(ipath),"")))
		if (ltx:GetValue("visual_at_cursor",relative_path)) then
			local ogf = cOGF(fullpath)
			if (ogf) then
				Msg(fname)
				local found = false
				if (ogf.motion_refs2) then
					for i,v in ipairs(ogf.motion_refs2) do
						if (v == "actors\\tolstyak_animation") then
							found = true 
						end
					end
					if not (found) then
						table.insert(ogf.motion_refs2,"actors\\tolstyak_animation")
						ogf:save()
					end
				else 
					MsgBox(strformat("%s doesn't have motion_refs2? Can this be right?",fname))
				end
			end
		end
	end
		
	file_for_each(ipath,{"ogf"},on_execute) ]]
end
