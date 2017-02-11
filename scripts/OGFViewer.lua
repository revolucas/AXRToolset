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
	Application.AddPluginButton("t_plugin_ogf_viewer","UIOGFViewerShow",GetAndShow)
end

UI = nil
function Get()
	if not (UI) then 
		UI = cUIOGFViewer("1")
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
Class "cUIOGFViewer" (cUIBase)
function cUIOGFViewer:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUIOGFViewer:Show(bool)
	self.inherited[1].Show(self,bool)
end 

function cUIOGFViewer:Create()
	self.inherited[1].Create(self)
end

function cUIOGFViewer:Reinit()
	self.inherited[1].Reinit(self)
	
	self.ogf = self.ogf or {}
	self.list = self.list or {}
	
	local tabs = {"OGF Editor"}
	
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vUIOGFViewerTab hwndUIOGFViewerTab_H|OGF Editor")
	
	for i=1,#tabs do
		local i_s = tostring(i)
		if (i == 1) then 
			local filters = table.concat({"All"},"^")
			self:Gui("Tab|%s",Language.translate(tabs[i]))
				self:Gui("Add|Text|x550 y75 w265 h30|%t_click_to_edit")
				
				-- ListView 
				self:Gui("Add|ListView|gOnScriptControlAction x22 y109 w920 h440 grid cBlack +altsubmit -multi vUIOGFViewerLV%s|",i)
				
				-- GroupBox
				self:Gui("Add|GroupBox|x22 y555 w530 h75|%t_working_directory")
				
				self:Gui("Add|DropDownList|gOnScriptControlAction x22 y69 w320 h30 R40 H300 vUIOGFViewerSection%s|"..filters,i)
				
				-- Buttons 
				self:Gui("Add|Button|gOnScriptControlAction x495 y600 w30 h20 vUIOGFViewerBrowsePath%s|...",i)
				self:Gui("Add|Button|gOnScriptControlAction x485 y680 w201 h20 vUIOGFViewerSaveSettings%s|%t_save_settings",i)
				
				-- Editbox 
				self:Gui("Add|Edit|gOnScriptControlAction x30 y600 w450 h20 vUIOGFViewerPath%s|",i)
				
			GuiControl(self.ID,"","UIOGFViewerPath"..i, gSettings:GetValue("ogf_viewer","path"..i) or "")
		end
	end
	
	self:Gui("Show|w1024 h720|%t_plugin_ogf_viewer")

	LV("LV_Delete",self.ID)
	clear(self.list)
end

function cUIOGFViewer:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUIOGFViewer:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("UIOGFViewerTab") or "1"
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","UIOGFViewerLV"..tab)) then
		local selected = ahkGetVar("UIOGFViewerSection"..tab)
		if (selected == nil or selected == "") then 
			return 
		end
		if (event and string.lower(event) == "rightclick") then
			LVTop(self.ID,"UIOGFViewerLV"..tab)
			local row = LVGetNext(self.ID,"0","UIOGFViewerLV"..tab)
			local txt = LVGetText(self.ID,row,"1")
			--Msg("event=%s LVGetNext=%s txt=%s",event,LVGetNext(self.ID,"0","UIOGFViewerLV"..tab),txt)
			if (txt and txt ~= "" and not self.listItemSelected) then 
				self.listItemSelected = txt
				GetAndShowModify(tab).modify_row = row
			end
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIOGFViewerSection"..tab)) then 	
		self:FillListView(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIOGFViewerBrowsePath"..tab)) then
		local dir = FileSelectFolder("*"..(gSettings:GetValue("ogf_viewer","path"..tab) or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UIOGFViewerPath"..tab,dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIOGFViewerSaveSettings"..tab)) then
		local path = ahkGetVar("UIOGFViewerPath"..tab)
		if (path and path ~= "") then
			gSettings:SetValue("ogf_viewer","path"..tab,path)
			gSettings:Save()
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIOGFViewerExecute"..tab)) then
		self:Gui("Submit|NoHide")
		if (self["ActionExecute"..tab]) then
			self["ActionExecute"..tab](self,tab)
		else 
			Msg("cUIOGFViewer:%s doesn't exist!","ActionExecute"..tab)
		end
	end
end

function cUIOGFViewer:Gui(...)
	self.inherited[1].Gui(self,...)
end

function get_relative_path(str,path)
	return trim(string.sub(path,str:len()+1))
end

_INACTION = nil

function cUIOGFViewer:FillListView(tab,selected,dir,skip)
	LVTop(self.ID,"UIOGFViewerLV"..tab)
	LV("LV_Delete",self.ID)
	
	if not (skip) then
		empty(self.list)
	end

	local selected = trim(ahkGetVar("UIOGFViewerSection"..tab))
	if (selected == nil or selected == "") then 
		return Msg("FillListView error selected is %s",selected)
	end
	
	local dir = ahkGetVar("UIOGFViewerPath"..tab)
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

function cUIOGFViewer:FillListView1(tab,selected,dir,skip)
	local fields = {"filename"}
	for i=1,#fields do 
		LV("LV_InsertCol",self.ID,tostring(i),"",fields[i])
	end 

	LV("LV_ModifyCol",self.ID,"1","AutoHdr")
	
	local function on_execute(path,fname)
		self.list[fname] = path.."\\"..fname
	end
	
	recurse_subdirectories_and_execute(dir,{"ogf"},on_execute)
	
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
			UI2 = cUIOGFViewerModify("2")
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
Class "cUIOGFViewerModify" (cUIBase)
function cUIOGFViewerModify:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUIOGFViewerModify:Show(bool)
	self.inherited[1].Show(self,bool)
end 

function cUIOGFViewerModify:Create()
	self.inherited[1].Create(self)
end

function cUIOGFViewerModify:Reinit()
	self.inherited[1].Reinit(self)
	
	--self:Gui("+AlwaysonTop")
	self:Gui("Font|s10|Verdana")
	
	local wnd = Get()
	if (wnd.listItemSelected == nil) then 
		return Msgbox("An error has occured. listItemSelected = nil!")
	end
	
	local fname = wnd.listItemSelected
	if not (wnd.list[fname]) then 
		return
	end
	
	wnd.ogf[fname] = wnd.ogf[fname] or cOGF(wnd.list[fname])

	if not (wnd.ogf[fname]) then
		Msg("failed to load %s",fname)
		return
	end 

	local params = wnd.ogf[fname]:params()
	
	self:Gui("Add|Text|w1000 h30 center|%s",fname)
	self:Gui("Add|Text|x5 y35 w700 h30|Source: %s",params.source_file)
	self:Gui("Add|Text|x5 y65 w700 h30|Build: %s",params.build_name)
	self:Gui("Add|Text|x5 y95 w700 h30|Created by: %s",params.create_name)
	self:Gui("Add|Text|x5 y125 w700 h30|Modified by:%s",params.modif_name)

	
	local y = 125+35
	for _,field in ipairs({"texture","shader","motion_refs","motion_refs2","lod_path","userdata","bones"}) do
		if (params[field] and params[field] ~= "") then
			self:Gui("Add|Text|x5 y%s w300 h30|Skeleton %s",y,field)
			if (field == "userdata") then
				self:Gui("Add|Edit|x200 y%s w800 h30 vUIOGFViewerModifyEdit2%s|%s",y,field,params[field])
			else
				self:Gui("Add|Edit|x200 y%s w800 h30 vUIOGFViewerModifyEdit2%s|%s",y,field,params[field])
			end
			y = y + 30
		end

		if (wnd.ogf[fname].children) then
			for i,child in ipairs(wnd.ogf[fname].children) do 
				local child_params = child:params()
				if (child_params[field] and child_params[field] ~= "") then
					self:Gui("Add|Text|x5 y%s w300 h30|Mesh%s %s",y,i,field)
					if (field == "userdata") then
						self:Gui("Add|Edit|x200 y%s w800 h30 vUIOGFViewerModifyEdit2_child%s_%s|%s",y,i,field,child_params[field])
					else
						self:Gui("Add|Edit|x200 y%s w800 h30 vUIOGFViewerModifyEdit2_child%s_%s|%s",y,i,field,child_params[field])
					end
					y = y + 30
				end
			end
		end
	end
 
	self:Gui("Add|Button|gOnScriptControlAction x12 default vUIOGFViewerModifyAccept2|%t_accept")
	self:Gui("Add|Button|gOnScriptControlAction x+4 vUIOGFViewerModifyCancel2|%t_cancel")
	--self:Gui("Add|Button|gOnScriptControlAction x+4 vUIOGFViewerModifyOpenDDS2|%t_open .DDS")
	--self:Gui("Add|Button|gOnScriptControlAction x+4 vUIOGFViewerModifyCopy2|%t_copy")
	--self:Gui("Add|Button|gOnScriptControlAction x+4 vUIOGFViewerModifyPaste2|%t_paste")
	self:Gui("+Resize +MaxSize1000x800 +0x200000")
	self:Gui("Show|center|%t_edit_values")
	self:Gui("Default")
end

function cUIOGFViewerModify:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUIOGFViewerModify:Destroy()
	self.inherited[1].Destroy(self)
	
	Get().listItemSelected = nil 
end

function cUIOGFViewerModify:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback

	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("UIOGFViewerTab") or "1"
		
	if (hwnd == GuiControlGet(self.ID,"hwnd","UIOGFViewerModifyAccept2")) then
		local wnd = Get()
		local fname = wnd.listItemSelected
		local ogf = wnd.ogf[fname]
		if not (ogf) then 
			Msg("ogf is nil %s",fname)
			return
		end
		local val
		for _,field in ipairs({"texture","shader","motion_refs","motion_refs2","lod_path","userdata"}) do
			val = ahkGetVar("UIOGFViewerModifyEdit2"..field)
			if (ogf[field]) then
				if (field == "motion_refs2" or field == "bones") then 
					ogf[field] = str_explode(val,",")
				else
					ogf[field] = trim(val)
				end
			end

			if (ogf.children) then
				for i,child in ipairs(ogf.children) do 
					val = ahkGetVar("UIOGFViewerModifyEdit2_child"..i.."_"..field)
					if (val and child[field]) then
						if (field == "motion_refs2" or field == "bones") then
							child[field] = val ~= "" and str_explode(val,",") or {}
						else
							child[field] = trim(val)
						end
					end
				end
			end
		end

		ogf:save()
		
		LVTop(wnd.ID,"UIOGFViewerLV"..tab)
		LV("LV_Modify",wnd.ID,self.modify_row,"",wnd.listItemSelected)
		
		self:Show(false)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIOGFViewerModifyCancel2")) then
		self:Show(false)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIOGFViewerModifyOpenDDS2")) then 
		local wnd = Get()
		local fname = wnd.listItemSelected
		local list = assert(wnd.list[fname])
		local full_path = list[1].."\\"..fname
		
		os.execute(strformat([[start "" "%s"]],full_path))
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIOGFViewerModifyCopy2")) then
		local wnd = Get()
		local fname = wnd.listItemSelected
		local list = assert(wnd.list[fname])
		local ogf_path = list[1].."\\"..list[2]
		
		local t = wnd.ogf[ogf_path].params
		for k,v in pairs(t) do
			clipboard[k] = v
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIOGFViewerModifyPaste2")) then
		local wnd = Get()
		local fname = wnd.listItemSelected
		local list = assert(wnd.list[fname])
		local ogf_path = list[1].."\\"..list[2]
		for k,v in pairs(clipboard) do 
			wnd.ogf[ogf_path].params[k] = v
		end
		
		local selected = fname
		self:Show(false)
		wnd.listItemSelected = fname
		self:Show(true)
	end
end

function cUIOGFViewerModify:Gui(...)
	self.inherited[1].Gui(self,...)
end