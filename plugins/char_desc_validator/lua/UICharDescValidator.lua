local ValidateTags = {
	["name"] = false,
	["icon"] = false,
	["map_icon"] = false,
	["bio"] = false,
	["class"] = false,
	["community"] = false,
	["terrain_sect"] = false,
	["money"] = false,
	["rank"] = false,
	["reputation"] = false,
	["visual"] = false,
	["snd_config"] = false,
	["supplies"] = false,
	["start_dialog"] = false,
	["actor_dialog"] = false
}

-------------------------------------
UICharDescValidWnd = nil
function OnApplicationBegin()
	UIMainMenuWnd:AddPluginButton("CharDesc Validator","UICharDescValidShow",GetAndShow)
end

function Get()
	if not (UICharDescValidWnd) then 
		UICharDescValidWnd = cUICharDescValid("1")
		UICharDescValidWnd.parent = UIMainMenuWnd
	end 
	return UICharDescValidWnd
end

function GetAndShow()
	Get():Show(true)
end

cUICharDescValid = Class{__includes={cUIBase}}
function cUICharDescValid:init(id)
	cUIBase.init(self,id)
end

function cUICharDescValid:Reinit()
	cUIBase.Reinit(self)
	
	-- GroupBox
	self:Gui("Add|GroupBox|x10 y50 w510 h75|Character Description's Directory")
	
	for tag,v in spairs(ValidateTags) do
		self:Gui("Add|CheckBox|x175 w100 h25 %s vUICharDescValidTag%s|%s",gSettings:GetValue("char_desc_validator",tag) == "1" and "Checked" or "",tag,tag)
	end
		
	self:Gui("Add|GroupBox|x10 y118 w510 h475|Validate tags")
	
	-- Buttons 
	self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vUICharDescValidBrowseInputPath|...")

	self:Gui("Add|Button|gOnScriptControlAction x485 y680 w90 h20 vUICharDescValidExecute|Validate")
	
	-- Editbox 
	self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vUICharDescValidInputPath|")

	
	self:Gui("Show|w1024 h720|CharDesc Validator")
	
	GuiControl(self.ID,"","UICharDescValidInputPath", gSettings:GetValue("char_desc_validator","path") or "")
end

function cUICharDescValid:OnGuiClose(idx) -- needed because it's registered to callback
	cUIBase.OnGuiClose(self,idx)
end 

function cUICharDescValid:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	if (hwnd == GuiControlGet(self.ID,"hwnd","UICharDescValidBrowseInputPath")) then
		local dir = FileSelectFolder("*"..(gSettings:GetValue("char_desc_validator","path") or ""))
		GuiControl(self.ID,"","UICharDescValidInputPath",dir)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UICharDescValidExecute")) then
		self:Gui("Submit|NoHide")
		OnValidate()
	end
end

function OnValidate()
	local path = ahkGetVar("UICharDescValidInputPath")
	if (path == nil or path == "") then 
		MsgBox("Incorrect Path!")
		return 
	end 
	
	local tags = {}
	for tag,v in pairs(ValidateTags) do
		local bool = ahkGetVar("UICharDescValidTag"..tag)
		gSettings:SetValue("char_desc_validator",tag,bool)
		if (bool == "1") then 
			tags[tag] = false
		end
	end
	
	gSettings:SetValue("char_desc_validator","path",path)
	gSettings:Save()
		
	local function on_execute(path,fname)
		if (string.find(fname,"character_desc")) then
			xml = XmlFile.LoadFile(path.."\\"..fname)
			if (xml) then
				for index,node in pairs(xml.ChildNodes) do
					if (type(node) == "table") then

						-- Check if all specific_character nodes for mandatory child nodes
						for k,child in pairs(node.ChildNodes) do
							if (type(child) == "table") then
								if (tags[child.Name] == false) then
									tags[child.Name] = true
								end
							end
						end

						-- Validate that all nodes by tag names exist
						for k,v in pairs(tags) do
							if (v == false) then
								Msg("%s - missing <%s>",node.Attributes.id,k)
							end
							-- reset for next loop
							tags[k] = false
						end
					end
				end
			end
		end
	end 
	
	recurse_subdirectories_and_execute(path,{"xml"},on_execute)
	
	Msg("CharDesc Validator:= Finished!")
end