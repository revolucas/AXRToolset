local oUILTXQuickEdit = nil
function OnApplicationBegin()
	UIMainMenuWnd:AddPluginButton("LTX QuickEdit","UILTXQuickEditShow",GetAndShow)
end

function Get()
	if not (oUILTXQuickEdit) then 
		oUILTXQuickEdit = cUILTXQuickEdit("1")
		oUILTXQuickEdit.parent = UIMainMenuWnd
	end 
	return oUILTXQuickEdit
end

function GetAndShow()
	Get():Show(true)
end

cUILTXQuickEdit = Class{__includes={cUIBase}}
function cUILTXQuickEdit:init(id)
	cUIBase.init(self,id)
end

function cUILTXQuickEdit:Show(bool)
	cUIBase.Show(self,bool)
end 

function cUILTXQuickEdit:Create()
	cUIBase.Create(self)
end

function cUILTXQuickEdit:Reinit()
	cUIBase.Reinit(self)
	
	self.ltx = self.ltx or {}
	self.list = self.list or {}
	self.fields = self.fields or {}
	
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vUILTXQuickEditTab hwndUILTXQuickEditTab_H|Workspace 1^Workspace 2^Workspace 3^Workspace 4^Workspace 5")
	
	local filters = self:GetFilterList()
	for i=1,5 do
		self:Gui("Tab|Workspace "..i)
			self:Gui("Add|Text|x22 y49 w140 h20|Filter:")
			self:Gui("Add|DropDownList|gOnScriptControlAction x22 y69 w320 h30 R40 H300 vUILTXQuickEditSection%s|"..filters,i)
			self:Gui("Add|Text|x550 y75 w200 h20|Right-Click to Edit!")
			self:Gui("Add|ListView|gOnScriptControlAction x22 y109 w920 h440 grid cBlack +altsubmit -multi vUILTXQuickEditLV%s|section",i)
			
			self:Gui("Add|GroupBox|x22 y555 w530 h75|Working Directory")
			self:Gui("Add|Button|gOnScriptControlAction x495 y600 w30 h20 vUILTXQuickEditBrowsePath%s|...",i)
			self:Gui("Add|Edit|gOnScriptControlAction x30 y600 w450 h20 vUILTXQuickEditPath%s|",i)
			self:Gui("Add|Button|gOnScriptControlAction x485 y680 w90 h20 vUILTXQuickEditSaveSettings%s|Save Settings",i)
		GuiControl(self.ID,"","UILTXQuickEditPath"..i, gSettings:GetValue("ltx_quickedit","path"..i) or "")
	end
	self:Gui("Show|w1024 h720|LTX QuickEdit")

	LV("LV_Delete",self.ID)
	clear(self.list)
end

function cUILTXQuickEdit:OnGuiClose(idx) -- needed because it's registered to callback
	cUIBase.OnGuiClose(self,idx)
end 

function cUILTXQuickEdit:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("UILTXQuickEditTab") or "1"
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","UILTXQuickEditLV"..tab)) then
		local selected = ahkGetVar("UILTXQuickEditSection"..tab)
		if (selected == nil or selected == "") then 
			return 
		end
		if (event and string.lower(event) == "rightclick") then
			LVTop(self.ID,"UILTXQuickEditLV"..tab)
			local txt = LVGetText(self.ID,LVGetNext(self.ID,"0","UILTXQuickEditLV"..tab),"1")
			--Msg("event=%s LVGetNext=%s txt=%s",event,LVGetNext(self.ID,"0","UILTXQuickEditLV"..tab),txt)
			if (txt and txt ~= "" and not self.listItemSelected) then 
				self.listItemSelected = txt
				GetAndShowModify()
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
	end
end

function cUILTXQuickEdit:Gui(...)
	cUIBase.Gui(self,...)
end

function cUILTXQuickEdit:GetFilterList()
	local t = {}
	local function on_execute(path,fname)
		table.insert(t,fname)
	end
	recurse_subdirectories_and_execute("plugins\\ltx_quickedit\\filters",{"txt"},on_execute)
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
	
	local f = io.open("plugins\\ltx_quickedit\\filters\\"..selected,"rb")
	if not (f) then 
		return Msg("failed to open %s","plugins\\ltx_quickedit\\filters"..selected)
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
	
	local function on_execute(path,fname)
		local check_path = trim_directory(path)
		if (ignore_paths[check_path]) then 

		else
			--Msg(fname)
			if not (self.ltx[fname]) then 
				self.ltx[fname] = IniFile.New(path.."\\"..fname,true)
			end
			
			if (self.ltx[fname]) then
				local t = self.ltx[fname]:GetSections()
				for n=1,#t do
					for i=1,#self.fields do 
						local v = self.ltx[fname]:GetValue(t[n],self.fields[i])
						if (v) then
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
	
	recurse_subdirectories_and_execute(dir,{"ltx"},on_execute)
	
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
---------------------------------
cUILTXQuickEditModify = Class{__includes={cUIBase}}
function cUILTXQuickEditModify:init(id)
	cUIBase.init(self,id)
end

function cUILTXQuickEditModify:Show(bool)
	cUIBase.Show(self,bool)
end 

function cUILTXQuickEditModify:Create()
	cUIBase.Create(self)
end

function cUILTXQuickEditModify:Reinit()
	cUIBase.Reinit(self)
	
	self:Gui("+AlwaysonTop")
	self:Gui("Font|s10|Verdana")
	
	local wnd = UILTXQuickEdit.Get()
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
 
	self:Gui("Add|Button|gOnScriptControlAction x12 default vUIModifyAccept|Accept")
	self:Gui("Add|Button|gOnScriptControlAction x+4 vUIModifyCancel|Cancel")
	self:Gui("Show|center|Edit Values")
	self:Gui("Default")
end

function cUILTXQuickEditModify:OnGuiClose(idx) -- needed because it's registered to callback
	cUIBase.OnGuiClose(self,idx)
end 

function cUILTXQuickEditModify:Destroy()
	cUIBase.Destroy(self)
	
	UILTXQuickEdit.Get().listItemSelected = nil 
end

function cUILTXQuickEditModify:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback

	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("UILTXQuickEditTab") or "1"
		
	if (hwnd == GuiControlGet(self.ID,"hwnd","UIModifyAccept")) then
		local wnd = UILTXQuickEdit.Get()
		local list = assert(wnd.list[wnd.listItemSelected])
		local fname = list.fname
	
		assert(wnd.ltx[fname])
		
		for field,v in pairs(list) do 
			if (field ~= "fname") then
				local val = ahkGetVar("UIModifyEdit"..field)
				wnd.ltx[fname]:SetValue(wnd.listItemSelected,field,val)
			end
		end

		wnd.ltx[fname]:SaveExt()
		
		self:Show(false)
		
		wnd:FillListView(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIModifyCancel")) then
		self:Show(false)
	end
end

function cUILTXQuickEditModify:Gui(...)
	cUIBase.Gui(self,...)
end
------------------------
local oUILTXQuickEditModify = nil
function GetModify()
	if not (oUILTXQuickEditModify) then 
		oUILTXQuickEditModify = cUILTXQuickEditModify("2")
	end
	return oUILTXQuickEditModify
end

function GetAndShowModify()
	GetModify():Show(true)
end