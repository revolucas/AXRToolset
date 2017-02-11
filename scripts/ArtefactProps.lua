-----------------------------------------------------------------
--
-----------------------------------------------------------------
function OnApplicationBegin()
	Application.AddPluginButton("t_plugin_artefact_prop","UIArtefactPropsShow",GetAndShow)
end

---------------------------------------------------------------------------
UI = nil
function Get()
	if not (UI) then 
		UI = cUIArtefactProps("1")
		UI.parent = Application.MainMenu
	end 
	return UI
end

function GetAndShow()
	Get():Show(true)
end
-----------------------------------------------------------------
-- UI Class Definition
-----------------------------------------------------------------

Class "cUIArtefactProps" (cUIBase)
function cUIArtefactProps:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUIArtefactProps:Reinit()
	self.inherited[1].Reinit(self)
	
	-- GroupBox
	--self:Gui("Add|GroupBox|x10 y50 w510 h75|Unpacked Gamedata")
		
	-- Buttons 
	--self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vUIArtefactPropsBrowseInputPath|...")
	self:Gui("Add|Button|gOnScriptControlAction x485 y680 w150 h20 vUIArtefactPropsExecute|%t_execute")
	
	-- Editbox 
	--self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vUIArtefactPropsInputPath|")
	
	self:Gui("Show|w1024 h720|%t_plugin_artefact_prop")
	
	GuiControl(self.ID,"","UIArtefactPropsInputPath", gSettings:GetValue("artefact_props","input_path") or "")
end

function cUIArtefactProps:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUIArtefactProps:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	if (hwnd == GuiControlGet(self.ID,"hwnd","UIArtefactPropsBrowseInputPath")) then
		local dir = FileSelectFolder("*"..(gSettings:GetValue("artefact_props","input_path") or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UIArtefactPropsInputPath",dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIArtefactPropsExecute")) then
		self:Gui("Submit|NoHide")
		local i_path = gSettings:GetValue("core","Gamedata_Path")-- ahkGetVar("UIArtefactPropsInputPath")
		if (i_path and i_path ~= "") then
			gSettings:SetValue("artefact_props","input_path",i_path)
			gSettings:Save()
			cUIArtefactProps:Arte(i_path)
		else 
			MsgBox("Artefact Properties: Incorrect path setup! Check settings tab!",i_path)
		end
	end
end

function cUIArtefactProps:Arte(i_path)
	local str = ""
	
	local item_list = Xray.get_item_sections_list()
	if not (item_list) then 
		Msg("artefact_props:= error!")
		return 
	end 
	
	local function addTab(s,n)
		local l = string.len(s)
		for i=1,n-l do
			s = s .. " "
		end
		return s
	end
	
	local t = item_list:GetKeys("sections")
	local immunities = {"burn_immunity","radiation_immunity","telepatic_immunity","chemical_burn_immunity","shock_immunity","wound_immunity","fire_wound_immunity","strike_immunity","explosion_immunity"}
	local params = {"health_restore_speed","satiety_restore_speed","power_restore_speed","bleeding_restore_speed","radiation_restore_speed","psy_health_restore_speed","additional_inventory_weight","additional_inventory_weight2","degrade_rate"}
	
	Msg("artefact_props:= Discovering artefact sections...")
	for section,v in pairs(t) do
		if (Xray.IsArtefact(section)) then
			local inv_name = Xray.system_ini():GetValue(section,"inv_name") or section
			str = str .. strformat([[[%s]	; "%s"]],section,self:translate_string(inv_name,i_path)) .. "\n"
			
			for i=1,#params do 
				local v = Xray.system_ini():GetValue(section,params[i],2) or 0
				if (v ~= 0) then
					str = str .. "    " .. addTab(params[i],40) .. " = " .. v .. "\n"
				end
			end
			
			local imm_sec = Xray.system_ini():GetValue(section,"hit_absorbation_sect")
			if (imm_sec) then
				for i=1,#immunities do 
					local v = Xray.system_ini():GetValue(imm_sec,immunities[i],2) or 0
					if (v ~= 0) then
						str = str .. "    " .. addTab(immunities[i],40) .. " = " .. v .. "\n"
					end
				end
			end
			str = str .. "\n"
		end
	end
	Msg("artefact_props:= Finished! (check logs\\artefact_props.txt)")
	
	local f = io.open("logs\\artefact_props.txt","wb+")
	if (f) then 
		f:write(str)
		f:close()
	end
end

local translated_list = nil
function cUIArtefactProps:translate_string(string_name,gamedata_path)
	if (translated_list) then 
		return translated_list[string_name] or string_name
	end 
	
	translated_list = {}
	
	local f = io.open(gamedata_path.."\\configs\\text\\eng\\st_items_artefacts.xml","rb")
	if (f) then
		local data = f:read("*all")
		if (data) then
			for st_name,text in string.gmatch(data,[[id="([%w_%.]*)".-<text>(.-)</text>]]) do
				translated_list[st_name] = text
			end
		end
		f:close()
	end
	
	return translated_list[string_name] or string_name
end