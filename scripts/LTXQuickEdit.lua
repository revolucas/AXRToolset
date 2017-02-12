-----------------------------------------------------------------
-- 
-----------------------------------------------------------------
function OnApplicationBegin()
	Application.AddPluginButton("t_plugin_ltx_quick","UILTXQuickEditShow",GetAndShow)
end

UI = nil
function Get()
	if not (UI) then 
		UI = cUILTXQuickEdit("1")
		UI.parent = Application.MainMenu
	end 
	return UI
end

function GetAndShow()
	local _ui = Get()
	_ui:Show(true)
	return _ui
end

-----------------------------------------------------------------
-- UI Class Definition
-----------------------------------------------------------------

Class "cUILTXQuickEdit" (cUIBase)
function cUILTXQuickEdit:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUILTXQuickEdit:Show(bool)
	self.inherited[1].Show(self,bool)
end 

function cUILTXQuickEdit:Create()
	self.inherited[1].Create(self)
end

function cUILTXQuickEdit:Reinit()
	self.inherited[1].Reinit(self)
	
	self.ltx = self.ltx or {}
	self.list = self.list or {}
	self.fields = self.fields or {}
	
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vUILTXQuickEditTab hwndUILTXQuickEditTab_H|%t_workspace 1^%t_workspace 2^%t_workspace 3^%t_workspace 4^%t_workspace 5")
	
	local filters = self:GetFilterList()
	for i=1,5 do
		self:Gui("Tab|%t_workspace "..i)
			self:Gui("Add|Text|x22 y49 w140 h20|%t_filter:")
			self:Gui("Add|DropDownList|gOnScriptControlAction x22 y69 w320 h30 R40 H300 vUILTXQuickEditSection%s|"..filters,i)
			self:Gui("Add|ListView|gOnScriptControlAction x22 y109 w920 h440 grid cBlack +altsubmit -multi vUILTXQuickEditLV%s|%t_section",i)
			self:Gui("Add|Text|x400 y50 w200 h20|%t_pattern_matching:")
			self:Gui("Add|Edit|gOnScriptControlAction x400 y69 w150 h20 vUILTXQuickEditSearch%s|",i)
			self:Gui("Add|Button|gOnScriptControlAction x555 y69 w20 h20 vUILTXQuickEditSearchButton%s|>",i)
			
			self:Gui("Add|GroupBox|x22 y555 w530 h75|%t_working_directory")
			self:Gui("Add|Text|x560 y555 w230 h20|%t_click_to_edit")
			self:Gui("Add|Button|gOnScriptControlAction x495 y600 w30 h20 vUILTXQuickEditBrowsePath%s|...",i)
			self:Gui("Add|Edit|gOnScriptControlAction x30 y600 w450 h20 vUILTXQuickEditPath%s|",i)
			self:Gui("Add|Button|gOnScriptControlAction x485 y680 w201 h20 vUILTXQuickEditSaveSettings%s|%t_save_settings",i)
		GuiControl(self.ID,"","UILTXQuickEditPath"..i, gSettings:GetValue("ltx_quickedit","path"..i) or "")
	end
	self:Gui("Show|w1024 h720|%t_plugin_ltx_quick")

	LV("LV_Delete",self.ID)
	clear(self.list)
end

function cUILTXQuickEdit:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUILTXQuickEdit:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self.inherited[1].OnScriptControlAction(self,hwnd,event,info)
	local tab = ahkGetVar("UILTXQuickEditTab") or "1"
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","UILTXQuickEditLV"..tab)) then
		local selected = ahkGetVar("UILTXQuickEditSection"..tab)
		if (selected == nil or selected == "") then 
			return 
		end
		if (event and string.lower(event) == "rightclick") then
			LVTop(self.ID,"UILTXQuickEditLV"..tab)
			local row = LVGetNext(self.ID,"0","UILTXQuickEditLV"..tab)
			local txt = LVGetText(self.ID,row,"1")
			--Msg("event=%s LVGetNext=%s txt=%s",event,LVGetNext(self.ID,"0","UILTXQuickEditLV"..tab),txt)
			if (txt and txt ~= "" and not self.listItemSelected) then 
				self.listItemSelected = txt
				GetAndShowModify().modify_row = row
			end
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILTXQuickEditSection"..tab)) then 	
		self:FillListView(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILTXQuickEditBrowsePath"..tab)) then
		local dir = FileSelectFolder("*"..(gSettings:GetValue("ltx_quickedit","path"..tab) or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UILTXQuickEditPath"..tab,dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILTXQuickEditSaveSettings"..tab)) then
		local path = ahkGetVar("UILTXQuickEditPath"..tab)
		if (path and path ~= "") then
			gSettings:SetValue("ltx_quickedit","path"..tab,path)
			gSettings:Save()
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILTXQuickEditSearchButton"..tab)) then
		local selected = trim(ahkGetVar("UILTXQuickEditSection"..tab))
		if (selected and selected ~= "") then
			self:FillListView(tab)
		end
	end
end

function cUILTXQuickEdit:Gui(...)
	self.inherited[1].Gui(self,...)
end

function cUILTXQuickEdit:GetFilterList()
	local t = {}
	local function on_execute(path,fname)
		table.insert(t,fname)
	end
	file_for_each("configs\\filters",{"txt"},on_execute)
	return table.concat(t,"^")
end

function cUILTXQuickEdit:FillListView(tab)
	LVTop(self.ID,"UILTXQuickEditLV"..tab)
	LV("LV_Delete",self.ID)
	empty(self.list)
	empty(self.fields)

	local selected = trim(ahkGetVar("UILTXQuickEditSection"..tab))
	if (selected == nil or selected == "") then 
		return Msg("FillListView error selected is %s",selected)
	end
	
	local dir = ahkGetVar("UILTXQuickEditPath"..tab)
	if (dir == nil or dir == "") then
		return MsgBox("Please select a valid working directory")
	end
	
	local f = io.open("configs\\filters\\"..selected,"rb")
	if not (f) then 
		return Msg("failed to open %s","configs\\filters"..selected)
	end 

	local data = f:read("*all")
	f:close()

	self.fields = str_explode(data,"\n")
	
	table.sort(self.fields)
	
	for i=1,200 do 
		LV("LV_DeleteCol",self.ID,"2")
	end
	for i=1,#self.fields do 
		LV("LV_InsertCol",self.ID,tostring(i+1),"",self.fields[i])
	end 
	
	LV("LV_ModifyCol",self.ID,"1","AutoHdr")
	
	local ignore_paths = {
		["environment"] = true,
		["fog"] = true,
		["weathers"] = true,
		["weather_effects"] = true,
		["ambients"] = true,
		["ambient_channels"] = true,
	}
	
	local search_str = trim(ahkGetVar("UILTXQuickEditSearch"..tab))
	local function on_execute(path,fname)
		local check_path = trim_directory(path)
		if (ignore_paths[check_path]) then 

		else
			--Msg(fname)
			if not (self.ltx[fname]) then 
				self.ltx[fname] = cIniFile(path.."\\"..fname,true)
			end
			
			if (self.ltx[fname]) then
				local t = self.ltx[fname]:GetSections()
				for n=1,#t do
					for i=1,#self.fields do 
						local v = self.ltx[fname]:GetValue(t[n],self.fields[i])
						if (v) then
							if (search_str == nil or search_str == "" or t[n]:match(search_str)) then
								if not (self.list[t[n]]) then
									self.list[t[n]] = {}
									self.list[t[n]].fname = fname
								end
								self.list[t[n]][self.fields[i]] = v
							end
						end
					end
				end
			end
		end
	end
	
	file_for_each(dir,{"ltx"},on_execute)
	
	for k,t in pairs(self.list) do
		local a = {}
		for i=1,#self.fields do
			local v = t[self.fields[i]] or ""
			table.insert(a,v)
		end
		LV("LV_ADD",self.ID,"",k,unpack(a))
	end
			
	LV("LV_ModifyCol",self.ID,"1","Sort CaseLocale")
	LV("LV_ModifyCol",self.ID,"1","AutoHdr")

	for i=1,#self.fields do
		LV("LV_ModifyCol",self.ID,tostring(i+1),"AutoHdr")
	end
end
-----------------------------------------------------------------
-- Modify UI
-----------------------------------------------------------------
UI2 = nil
function GetModify()
	if not (UI2) then 
		UI2 = cUILTXQuickEditModify("2")
	end
	return UI2
end

function GetAndShowModify()
	local _ui = GetModify()
	_ui:Show(true)
	return _ui
end
-----------------------------------------------------------------
-- UI Modify Class Definition
-----------------------------------------------------------------
Class "cUILTXQuickEditModify" (cUIBase)
function cUILTXQuickEditModify:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUILTXQuickEditModify:Show(bool)
	self.inherited[1].Show(self,bool)
end 

function cUILTXQuickEditModify:Create()
	self.inherited[1].Create(self)
end

function cUILTXQuickEditModify:Reinit()
	self.inherited[1].Reinit(self)
	
	self:Gui("+AlwaysonTop")
	self:Gui("Font|s10|Verdana")
	
	local wnd = Get()
	if (wnd.listItemSelected == nil) then 
		return Msgbox("An error has occured. listItemSelected = nil!")
	end
	
	local list = wnd.list[wnd.listItemSelected]
	
	if not (list) then 
		return Msgbox("An error has occured. list = nil!")
	end
	
	local fname = list.fname
	
	self:Gui("Add|Text|w300 h30|%s",fname)
	
	local tab = ahkGetVar("UILTXQuickEditTab")

	local y = 35
	for field,v in pairs(list) do 
		if (field ~= "fname") then
			self:Gui("Add|Text|x5 y%s w300 h30|%s",y,field)
			self:Gui("Add|Edit|x200 y%s w800 h30 vUIModifyEdit%s|%s",y,field,v)
			y = y + 30
		end
	end
 
	self:Gui("Add|Button|gOnScriptControlAction x12 default vUIModifyAccept|%t_accept")
	self:Gui("Add|Button|gOnScriptControlAction x+4 vUIModifyCancel|%t_cancel")
	self:Gui("Show|center|%t_edit_values")
	self:Gui("Default")
end

function cUILTXQuickEditModify:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUILTXQuickEditModify:Destroy()
	self.inherited[1].Destroy(self)
	
	Get().listItemSelected = nil 
end

function cUILTXQuickEditModify:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self.inherited[1].OnScriptControlAction(self,hwnd,event,info)
	local tab = ahkGetVar("UILTXQuickEditTab") or "1"
		
	if (hwnd == GuiControlGet(self.ID,"hwnd","UIModifyAccept")) then
		local wnd = Get()
		local list = assert(wnd.list[wnd.listItemSelected])
		local fname = list.fname
	
		assert(wnd.ltx[fname])
		
		for field,v in pairs(list) do 
			if (field ~= "fname") then
				local val = trim(ahkGetVar("UIModifyEdit"..field))
				wnd.ltx[fname]:SetValue(wnd.listItemSelected,field,val)
				list[field] = val
			end
		end

		wnd.ltx[fname]:SaveExt()

		local a = {}
		for i=1,#wnd.fields do 
			local v = list[wnd.fields[i]] or ""
			table.insert(a,v)
		end
		
		LVTop(wnd.ID,"UILTXQuickEditLV"..tab)
		LV("LV_Modify",wnd.ID,self.modify_row,"",wnd.listItemSelected,unpack(a))
		
		self:Show(false)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIModifyCancel")) then
		self:Show(false)
	end
end

function cUILTXQuickEditModify:Gui(...)
	self.inherited[1].Gui(self,...)
end