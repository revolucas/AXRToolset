--[[

Notes: When using LV functions make sure to switch to GUI ID that has the LV before using commands. For example
I couldn't figure out why LV commands weren't working while in the Modify UI. it's because I had to switch 
to GUI 0.
http://stackoverflow.com/questions/24002210/cannot-update-listview

--]]

local Checks = {}
local clipboard = {}
-----------------------------------------------------------------
-- 
-----------------------------------------------------------------
function OnApplicationBegin()
	Application.AddPluginButton("Level Viewer","UILevelViewerShow",GetAndShow)
end

UI = nil
function Get()
	if not (UI) then 
		UI = cUILevelViewer("1")
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
Class "cUILevelViewer" (cUIBase)
function cUILevelViewer:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUILevelViewer:Show(bool)
	self.inherited[1].Show(self,bool)
end 

function cUILevelViewer:Create()
	self.inherited[1].Create(self)
end

function cUILevelViewer:Reinit()
	self.inherited[1].Reinit(self)
	
	self.lvl = self.lvl or {}
	self.list = self.list or {}
	self.shaders = {}
	
	local tabs = {"Level Shaders"}
	
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vUILevelViewerTab hwndUILevelViewerTab_H|%s",table.concat(tabs,"^"))
	
	for i=1,#tabs do
		local i_s = tostring(i)
		if (i == 1) then 
			local filters = table.concat({"All"},"^")
			self:Gui("Tab|%s",tabs[i])
				self:Gui("Add|Text|x550 y75 w230 h20|%t_click_to_edit")
				
				-- ListView 
				self:Gui("Add|ListView|gOnScriptControlAction x22 y109 w920 h440 grid cBlack +altsubmit -multi vUILevelViewerLV%s|",i)
				
				-- GroupBox
				self:Gui("Add|GroupBox|x22 y555 w530 h75|%t_working_directory")
				
				self:Gui("Add|DropDownList|gOnScriptControlAction x22 y69 w320 h30 R40 H300 vUILevelViewerSection%s|"..filters,i)
				
				-- Buttons 
				self:Gui("Add|Button|gOnScriptControlAction x495 y600 w30 h20 vUILevelViewerBrowsePath%s|...",i)
				self:Gui("Add|Button|gOnScriptControlAction x485 y680 w90 h20 vUILevelViewerSaveSettings%s|%t_save_settings",i)
				
				-- Editbox 
				self:Gui("Add|Edit|gOnScriptControlAction x30 y600 w450 h20 vUILevelViewerPath%s|",i)
				
			GuiControl(self.ID,"","UILevelViewerPath"..i, gSettings:GetValue("level_viewer","path"..i) or "")
		end
	end

	self:Gui("Show|w1024 h720|Level Viewer")

	LV("LV_Delete",self.ID)
	clear(self.list)
end

function cUILevelViewer:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUILevelViewer:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("UILevelViewerTab") or "1"
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","UILevelViewerLV"..tab)) then
		local selected = ahkGetVar("UILevelViewerSection"..tab)
		if (selected == nil or selected == "") then 
			return 
		end
		if (event and string.lower(event) == "rightclick") then
			LVTop(self.ID,"UILevelViewerLV"..tab)
			local row = LVGetNext(self.ID,"0","UILevelViewerLV"..tab)
			local txt = LVGetText(self.ID,row,"1")
			--Msg("event=%s LVGetNext=%s txt=%s",event,LVGetNext(self.ID,"0","UILevelViewerLV"..tab),txt)
			if (txt and txt ~= "" and not self.listItemSelected) then 
				self.listItemSelected = txt
				GetAndShowModify(tab).modify_row = row
			end
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILevelViewerSection"..tab)) then 	
		self:FillListView(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILevelViewerBrowsePath"..tab)) then
		local dir = FileSelectFolder("*"..(gSettings:GetValue("level_viewer","path"..tab) or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UILevelViewerPath"..tab,dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILevelViewerSaveSettings"..tab)) then
		local path = ahkGetVar("UILevelViewerPath"..tab)
		if (path and path ~= "") then
			gSettings:SetValue("level_viewer","path"..tab,path)
			gSettings:Save()
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILevelViewerExecute"..tab)) then
		self:Gui("Submit|NoHide")
		if (self["ActionExecute"..tab]) then
			self["ActionExecute"..tab](self,tab)
		else 
			Msg("cUILevelViewer:%s doesn't exist!","ActionExecute"..tab)
		end
	end
end

function cUILevelViewer:Gui(...)
	self.inherited[1].Gui(self,...)
end

function get_relative_path(str,path)
	return trim(string.sub(path,str:len()+1))
end

_INACTION = nil

function cUILevelViewer:FillListView(tab,selected,dir,skip)
	LVTop(self.ID,"UILevelViewerLV"..tab)
	LV("LV_Delete",self.ID)
	
	if not (skip) then
		empty(self.list)
	end

	local selected = trim(ahkGetVar("UILevelViewerSection"..tab))
	if (selected == nil or selected == "") then 
		return Msg("FillListView error selected is %s",selected)
	end
	
	local dir = ahkGetVar("UILevelViewerPath"..tab)
	if (dir == nil or dir == "") then
		return MsgBox("Please select a valid working directory")
	end
	
	for i=1,200 do 
		LV("LV_DeleteCol",self.ID,"1")
	end
			
	self["FillListView"..tab](self,tab,selected,dir,skip)
	
	LV("LV_ModifyCol",self.ID,"1","Sort CaseLocale")
	LV("LV_ModifyCol",self.ID,"1","AutoHdr")

	for i=1,200 do
		LV("LV_ModifyCol",self.ID,tostring(i+1),"AutoHdr")
	end
end

function level_for_each(node,func,...)
	local stack = {}
	local deepest
	while not deepest do
		if (node) then
			for file in lfs.dir(node) do
				if (file ~= ".." and file ~= ".") then
					local fullpath = node .. "\\" .. file
					local mode = lfs.attributes(fullpath,"mode")
					if (mode == "file") then
						if (file == "level") then
							func(node,file,fullpath,...)
						end
					elseif (mode == "directory") then
						if not (file_exists(fullpath.."\\.ignore")) then
							table.insert(stack,fullpath)
						end
					end
				end
			end
		end

		if (#stack > 0) then
			node = stack[#stack]
			stack[#stack] = nil
		else
			deepest = true
		end
	end
end

function cUILevelViewer:FillListView1(tab,selected,dir,skip)
	local fields = {"filename"}
	for i=1,#fields do 
		LV("LV_InsertCol",self.ID,tostring(i),"",fields[i])
	end 

	LV("LV_ModifyCol",self.ID,"1","AutoHdr")
	
	local function on_execute(path,fname,fullpath)
		self.list[fullpath] = fname
	end
	
	level_for_each(dir,on_execute)
	
	for k,v in pairs(self.list) do
		LV("LV_ADD",self.ID,"",k)
	end
end
-----------------------------------------------------------------
-- Modify UI
-----------------------------------------------------------------
UI2 = nil
UI3 = nil
function GetModify(tab)
	if (tab == "1") then
		if not (UI2) then 
			UI2 = cUILevelViewerModify("2")
		end
		return UI2
	end
end

function GetAndShowModify(tab)
	local _ui = GetModify(tab)
	_ui:Show(true)
	return _ui
end
-----------------------------------------------------------------
-- UI Modify Class Definition
-----------------------------------------------------------------
--------------------------------------------------------------------------
-- Modify2 (tab3)
--------------------------------------------------------------------------
Class "cUILevelViewerModify" (cUIBase)
function cUILevelViewerModify:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUILevelViewerModify:Show(bool)
	self.inherited[1].Show(self,bool)
end 

function cUILevelViewerModify:Create()
	self.inherited[1].Create(self)
end

function cUILevelViewerModify:Reinit()
	self.inherited[1].Reinit(self)
	
	--self:Gui("+AlwaysonTop")
	self:Gui("+0x200000")
	self:Gui("Font|s10|Verdana")
	
	local wnd = Get()
	if (wnd.listItemSelected == nil) then 
		return Msgbox("An error has occured. listItemSelected = nil!")
	end
	
	local fullpath = wnd.listItemSelected
	if not (wnd.list[fullpath]) then 
		return
	end
	
	local fname = wnd.list[fullpath]
	Msg("loading...%s",fullpath)
	
	wnd.lvl[fullpath] = wnd.lvl[fullpath] or cLevel(fullpath)
	Msg("done!")
	
	self:Gui("Add|Text|w1000 h30 center|%s",fname)

	local x,y = 100,35
	
	local lvl = wnd.lvl[fullpath]
	if (#lvl.shaders > 50) then 
		if not (self.ignore_warning) then
			MsgBox(strformat("Level has too many shaders to display (%s). Use 'Export' to *.txt",#lvl.shaders))
		else
			MsgBox(Language.translate("t_import_success"))
			self.ignore_warning = false
		end
	else
		if (lvl["shaders"]) then
			self:Gui("Add|Text|x5 y%s w300 h30|shaders",y)
			for i=2,#lvl.shaders do 
				self:Gui("Add|Edit|x%s y%s w300 h30 vUILevelViewerModifyEdit2shaders%s|%s",x,y,i,lvl.shaders[i])
				if (i % 2 == 0) then 
					x = 400
				else
					x = 100
					y = y + 30
				end
			end
		end
		y = y + 30
	end
	self:Gui("Add|Button|gOnScriptControlAction x10 y%s w100 h20 default vUILevelViewerModifyAccept2|%t_accept",y)
	self:Gui("Add|Button|gOnScriptControlAction x110 y%s w100 h20 vUILevelViewerModifyCancel2|%t_cancel",y)
	self:Gui("Add|Button|gOnScriptControlAction x210 y%s w100 h20 vUILevelViewerModifyImport2|%t_import",y)
	self:Gui("Add|Button|gOnScriptControlAction x310 y%s w100 h20 vUILevelViewerModifyExport2|%t_export",y)
	self:Gui("Show|center|%t_edit_values")
	self:Gui("Default")
end

function cUILevelViewerModify:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUILevelViewerModify:Destroy()
	self.inherited[1].Destroy(self)
	
	Get().listItemSelected = nil 
end

function cUILevelViewerModify:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback

	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("UILevelViewerTab") or "1"
		
	if (hwnd == GuiControlGet(self.ID,"hwnd","UILevelViewerModifyAccept2")) then
		local wnd = Get()
		local fullpath = wnd.listItemSelected
		local lvl = wnd.lvl[fullpath]
		if not (lvl and lvl.shaders) then
			Msg("lvl is nil %s",fullpath)
			return
		end
			
		if (#wnd.shaders > 0) then
			clear(lvl.shaders)
			table.insert(lvl.shaders,1,"")
			for i=1,#wnd.shaders do 
				local v = trim(wnd.shaders[i])
				if (v and v ~= "") then
					table.insert(lvl.shaders,wnd.shaders[i])
				end
			end
			clear(wnd.shaders)
		else
			local val
			local t = {}
			for i=2,#lvl.shaders do
				val = ahkGetVar("UILevelViewerModifyEdit2shaders"..i)
				if (val and val ~="") then
					val = trim(val)
					if (val ~= "") then
						table.insert(t,val)
					end
				end
			end
			lvl.shaders = t
		end
		
		Msg("saving...")
		lvl:save()
		Msg("done!")

		LVTop(wnd.ID,"UILevelViewerLV"..tab)
		LV("LV_Modify",wnd.ID,self.modify_row,"",wnd.listItemSelected)
		
		self:Show(false)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILevelViewerModifyCancel2")) then
		self:Show(false)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILevelViewerModifyImport2")) then
		local f = FileSelectFile("3","","Import shader data","*.ltx")
		if (f and f ~= "") then
			local ltx = cIniFile(f,true)
			if not (ltx) then
				Msg("failed to import %s",f)
				return 
			end
			local wnd = Get()
			local fullpath = wnd.listItemSelected
			local lvl = wnd.lvl[fullpath]
			if not (lvl) then
				Msg("lvl is nil %s",fullpath)
				return
			end
			clear(wnd.shaders)
			local shaders = ltx:GetKeys("shaders")
			for k,v in pairs(shaders) do
				table.insert(wnd.shaders,k)
			end
			wnd.lvl[fullpath] = nil
			self.ignore_warning = true
			Msg("reloading GUI")
			self:Gui("Destroy")
			self:Reinit()
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILevelViewerModifyExport2")) then
		local f = FileSelectFile("S26","level_shaders.ltx","Import shader data","*.ltx")
		if (f and f ~= "") then
			local ltx = cIniFile(f,true)
			ltx.root = {}
			if not (ltx) then
				Msg("failed to export %s",f)
				return 
			end
			local wnd = Get()
			local fullpath = wnd.listItemSelected
			local lvl = wnd.lvl[fullpath]
			if not (lvl) then
				Msg("lvl is nil %s",fullpath)
				return
			end
			for i=2,#lvl.shaders do 
				ltx:SetValue("shaders",lvl.shaders[i],"")
			end
			ltx:Save()
		end		
	end
end

function cUILevelViewerModify:Gui(...)
	self.inherited[1].Gui(self,...)
end