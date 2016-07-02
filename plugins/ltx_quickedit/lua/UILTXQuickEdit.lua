UILTXQuickEditWnd = nil
function OnApplicationBegin()
	UIMainMenuWnd:AddPluginButton("LTX QuickEdit","UILTXQuickEditShow",GetAndShow)
end

function Get()
	if not (UILTXQuickEditWnd) then 
		UILTXQuickEditWnd = cUILTXQuickEdit("1")
		UILTXQuickEditWnd.parent = UIMainMenuWnd
	end 
	return UILTXQuickEditWnd
end

function GetAndShow()
	Get():Show(true)
end

cUILTXQuickEdit = Class{__includes={cUIBase}}
function cUILTXQuickEdit:init(id)
	cUIBase.init(self,id)
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
		
		if (event == "RightClick") then
			LVTop(self.ID,"UILTXQuickEditLV"..tab)
			local txt = LVGetText(self.ID,info,"1")
			if (txt and txt ~= "" and not self.listItemSelected) then 
				self.listItemSelected = txt
				UILTXQuickEditModify.GetAndShow()
			end
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILTXQuickEditSection"..tab)) then 	
		self:FillListView(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILTXQuickEditBrowsePath"..tab)) then
		local dir = FileSelectFolder("*"..(gSettings:GetValue("ltx_quickedit","path"..tab) or ""))
		GuiControl(self.ID,"","UILTXQuickEditPath"..tab,dir)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILTXQuickEditSaveSettings"..tab)) then
		local path = ahkGetVar("UILTXQuickEditPath"..tab)
		if (path and path ~= "") then
			gSettings:SetValue("ltx_quickedit","path"..tab,path)
			gSettings:Save()
		end
	end
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
	
	local function on_execute(path,fname)
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
	
	recurse_subdirectories_and_execute(dir,{"ltx"},on_execute)
	
	for k,t in pairs(self.list) do
		local a = {}
		for i=1,#self.fields do
			table.insert(a,t[self.fields[i]] or "")
		end
		LV("LV_ADD",self.ID,"",k,unpack(a))
	end
			
	LV("LV_ModifyCol",self.ID,"1","Sort CaseLocale")
	LV("LV_ModifyCol",self.ID,"1","AutoHdr")

	for i=1,#self.fields do
		LV("LV_ModifyCol",self.ID,tostring(i+1),"AutoHdr")
	end
end