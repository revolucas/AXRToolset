function OnApplicationBegin()
	FileRemoveDir("temp","1")
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
		self:Gui("Add|Text|x22 y695 w140 h20|v"..string.format("%1d.%01d.%02d",unpack(SOFTWARE_VERSION)))
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
		
		self:Gui("Add|Button|gOnScriptControlAction x745 y110 vApplicationCheckUpdates|%t_check_updates")
		
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
	self.inherited[1].OnScriptControlAction(self,hwnd,event,info)
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","ApplicationBrowseGamedata")) then 
		local dir = FileSelectFolder("*"..(gSettings:GetValue("core","Gamedata_Path") or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","ApplicationGamedataPath",dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ApplicationCheckUpdates")) then 
		local txt = URLDownloadToVar("https://raw.githubusercontent.com/revolucas/AXRToolset/master/scripts/lib/version.lua")
		if (txt and txt ~= "") then 
			local ver = assert(loadstring(txt))()
			if not ver then
				return Msg("Failed to get version")
			end
 			if (ver[1] ~= SOFTWARE_VERSION[1] and ver[2] ~= SOFTWARE_VERSION[2] ~= ver[3] > SOFTWARE_VERSION[3]) then
				local version_name = string.format("%1d.%01d.%02d",unpack(ver))
				
				local mb = cUIMsgBox("9",Language.translate("t_update_yes_no"),Language.translate("t_update_available").. " v" .. version_name,function()
					local working_directory = ahkGetVar("A_WorkingDir")
					local root = trim_directory(working_directory)
					lfs.mkdir("temp")
					DownloadFile("https://github.com/revolucas/AXRToolset/archive/master.zip","temp\\"..version_name..".zip",true,true)
					if (file_exists(working_directory.."\\temp\\"..version_name..".zip")) then
						gSettings:Save(nil,true,"configs\\settings.ltx.bak")
						local cp = working_directory .. "\\bin\\7za.exe"
						RunWait( strformat('%s x %s -y -aoa -o"%s"',cp,"temp\\"..version_name..".zip",working_directory.."\\temp\\"), working_directory)
						Run( strformat('robocopy /s /move "%s" "%s"',working_directory.."\\temp\\AXRToolset-master",working_directory),working_directory)
						GoSub("OnExit")
					else
						MsgBox(strformat(Language.translate("t_update_fail_download")))
					end
				end)
				
				mb:Show(true)
			else
				MsgBox(Language.translate("t_no_update_available"))
			end
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
	-------------- copies dxta out of textures folder to output
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
	---------------- Applies fat fix omf
	--[[
	local ltx = cIniFile("debug_visual.ltx")
	local ipath = "E:\\STALKER\\Games\\COP_COC_db_converter\\unpacked\\meshes\\actors"
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
				elseif (ogf.motion_refs ~= "") then 
					if not (string.find(ogf.motion_refs,"actors\\tolstyak_animation")) then
						ogf.motion_refs = ogf.motion_refs .. ",actors\\tolstyak_animation"
					end
				else 
					MsgBox(strformat("%s doesn't have motion_refs2? Can this be right?",fname))
				end
			end
		end
	end
		
	file_for_each(ipath,{"ogf"},on_execute)
	Msg("done")
	--]]
	--[[
	local tpath = "E:\\STALKER\\Games\\COP_COC_db_converter\\unpacked\\textures"
	local ipath = "E:\\STALKER\\Games\\COP_COC_db_converter\\unpacked\\meshes\\monsters"
	lfs.mkdir("E:\\STALKER\\Games\\COP_COC_db_converter\\unpacked\\textures\\monsters")
	local function on_execute(path,fname,fullpath)
		local relative_path = trim_ext("monsters"..trim_final_backslash(string.gsub(fullpath,escape_lua_pattern(ipath),"")))
		local ogf = cOGF(fullpath)
		if (ogf) then
			Msg("scanning...%s",fname)
			for i,child in ipairs(ogf.children) do 
				if (child.texture) then
					local tfullpath = tpath.."\\"..child.texture
					child.texture = "monsters\\"..trim_directory(child.texture)
					if (file_exists(tfullpath..".dds")) then 
						Msg("moving...%s",tfullpath..".dds")
						RunWait(strformat('robocopy "%s" "%s" %s /MOV',get_path(tfullpath..".dds"),tpath.."\\monsters",trim_directory(tfullpath..".dds")))
					end
					if (file_exists(tfullpath..".thm")) then
						local thm = cTHM(tfullpath..".thm")
						if (thm and thm.params.bump_name and file_exists(tpath.."\\"..thm.params.bump_name..".dds")) then
							local bump_path = tpath.."\\"..thm.params.bump_name
							thm.params.bump_name = "monsters\\"..trim_directory(thm.params.bump_name)
							thm:save()
							Msg("moving...%s",bump_path..".dds")
							RunWait(strformat('robocopy "%s" "%s" %s /MOV',get_path(bump_path..".dds"),tpath.."\\monsters",trim_directory(bump_path..".dds")))
							if (file_exists(bump_path..".thm")) then
								RunWait(strformat('robocopy "%s" "%s" %s /MOV',get_path(bump_path..".thm"),tpath.."\\monsters",trim_directory(bump_path..".thm")))
							end
							if (file_exists(bump_path.."#.dds")) then
								Msg("moving...%s",bump_path.."#.dds")
								RunWait(strformat('robocopy "%s" "%s" %s /MOV',get_path(bump_path.."#.dds"),tpath.."\\monsters",trim_directory(bump_path.."#.dds")))
							end
						end
						Msg("moving...%s",tfullpath..".thm")
						RunWait(strformat('robocopy "%s" "%s" %s /MOV',get_path(tfullpath..".thm"),tpath.."\\monsters",trim_directory(tfullpath..".thm")))
					end
				end
			end
			ogf:save()
		end
	end
		
	file_for_each(ipath,{"ogf"},on_execute)
	Msg("done")
	--]]
	-- rename act_specnaz_glass to act_stalker_head_glass_02
	--[[
	local tpath = "E:\\STALKER\\Games\\COP_COC_db_converter\\unpacked\\textures"
	local ipath = "E:\\STALKER\\Games\\COP_COC_db_converter\\unpacked\\meshes\\actors"
	lfs.mkdir("E:\\STALKER\\Games\\COP_COC_db_converter\\unpacked\\textures\\monsters")
	local function on_execute(path,fname,fullpath)
		Msg(fname)
		local ogf = cOGF(fullpath)
		if (ogf) then
			local found = false
			for i,child in ipairs(ogf.children) do 
				if (child.texture and child.texture == "act\\act_specnaz_glass") then
					child.texture = "act\\act_stalker_head_glass_02"
					found = true
				end
			end
			if (found) then
				Msg("%s replacing texture",fname)
				ogf:save()
			end
		end
	end
		
	file_for_each(ipath,{"ogf"},on_execute)
	Msg("done")
	--]]
end
