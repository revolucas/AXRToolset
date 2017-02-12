-----------------------------------------------------------------
--
-----------------------------------------------------------------
function OnApplicationBegin()
	Application.AddPluginButton("t_plugin_trader_edit","UITraderEditorShow",GetAndShow)
end

UI = nil
function Get()
	if not (UI) then 
		UI = cUITraderEditor("1")
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
Class "cUITraderEditor" (cUIBase)
function cUITraderEditor:initialize(id)
	self.inherited[1].initialize(self,id)

	self.ltx = {}
	self.list = {}
end

function cUITraderEditor:Show(bool)
	self.inherited[1].Show(self,bool)
end 

function cUITraderEditor:Create()
	self.inherited[1].Create(self)
end

function cUITraderEditor:Reinit()
	self.inherited[1].Reinit(self)
	
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vUITraderEditorTab hwndUITraderEditorTab_H|%t_buy_sell_editor^%t_death_config_editor")
	self:Gui("Tab|%t_buy_sell_editor")
		local valid_sections = self:GetSectionList()
		self:Gui("Add|Text|x22 y49 w140 h20|%t_section:")
		self:Gui("Add|DropDownList|gOnScriptControlAction x22 y69 w320 h30 R40 H300 vUITraderEditorSection1|"..valid_sections)
		self:Gui("Add|Text|x550 y75 w200 h20|Right-Click to Edit!")
		self:Gui("Add|ListView|gOnScriptControlAction x22 y109 w920 h440 grid cBlack +altsubmit -multi vUITraderEditorLV1|file^buy_condition^sell_condition^buy_supplies1^buy_supplies2^buy_supplies3^buy_supplies4^buy_supplies5")
	self:Gui("Tab|%t_death_config_editor")
		self:Gui("Add|Text|x22 y49 w140 h20|%t_section:")
		self:Gui("Add|DropDownList|gOnScriptControlAction x22 y69 w320 h30 R40 H300 vUITraderEditorSection2|"..valid_sections)	
		self:Gui("Add|Text|x550 y75 w265 h30|%t_click_to_edit")
		self:Gui("Add|ListView|gOnScriptControlAction x22 y109 w920 h440 grid cBlack +altsubmit -multi vUITraderEditorLV2|file^keep_items^item_count^base^stalker^bandit^killer^dolg^freedom^army^monolith^csky^ecolog")
	self:Gui("Show|w1024 h720|%t_plugin_trader_edit")
	self:Gui("Default")
		
	LV("LV_Delete",self.ID)
	clear(self.list)
end

function cUITraderEditor:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUITraderEditor:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback

	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("UITraderEditorTab") or "1"
		
	if (hwnd == GuiControlGet(self.ID,"hwnd","UITraderEditorLV"..tab)) then
		local selected = trim(ahkGetVar("UITraderEditorSection"..tab))
		if (selected == nil or selected == "") then 
			return 
		end		
		
		if (event == "RightClick") then
			LVTop(self.ID,"UITraderEditorLV"..tab)
			local row = LVGetNext(self.ID,"0","UITraderEditorLV"..tab)
			local txt = LVGetText(self.ID,row,"1")
			if (txt and txt ~= "" and not self.listItemSelected) then
				self.listItemSelected = txt
				GetAndShowModify().modify_row = row
			end
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITraderEditorSection"..tab)) then 	
		self:FillListView(tab)
	end
end

function cUITraderEditor:Gui(...)
	self.inherited[1].Gui(self,...)
end

function cUITraderEditor:GetSectionList()
	local item_list = Xray.get_item_sections_list()
	if (item_list) then 
		return item_list:GetKeysAsString("sections","^")
	end
	return ""
end

function cUITraderEditor:FillListView(typ)
	typ = tostring(typ)
	LVTop(self.ID,"UITraderEditorLV"..typ)
	LV("LV_Delete",self.ID)
	empty(self.list)

	local selected = trim(ahkGetVar("UITraderEditorSection"..typ))
	if (selected == nil or selected == "") then 
		return 
	end
	
	local dir = gSettings:GetValue("core","Gamedata_Path")
	if not (dir) then 
		Msg("Error: Please set gamedata path in settings!")
		return 
	end 

	if (typ == "1") then
		local function on_execute(path,fname)
			if not (self.ltx[fname]) then 
				self.ltx[fname] = cIniFile(path.."\\"..fname,true)
			end
			
			if (self.ltx[fname]) then
				local buy_cond= self.ltx[fname]:GetValue("trader","buy_condition")
				buy_cond = self.ltx[fname]:GetValue(buy_cond,selected)
				
				local sell_cond = self.ltx[fname]:GetValue("trader","sell_condition")
				sell_cond = self.ltx[fname]:GetValue(sell_cond,selected)
				
				local buy_supp = self.ltx[fname]:GetValue("trader","buy_supplies")
				
				local t,a,b = {},{},{}
				if (buy_supp and buy_supp ~= "") then
					t = Xray.parse_condlist(buy_supp)
					
					table.sort(t)
					
					for i=1,#t do 
						local v = self.ltx[fname]:GetValue(t[1],selected) or ""
						table.insert(a,v)
						b[t[i]] = v
					end
				end

				LV("LV_ADD",self.ID,"",fname,buy_cond,sell_cond,unpack(a))
					
				self.list[fname] = {section=selected,path=path.."\\"..fname,buy_condition=buy_cond,sell_condition=sell_cond,buy_supplies=b}
			end
		end
		
		file_for_each(dir.."\\configs\\misc\\trade",{"ltx"},on_execute)
	else
		-- death configs 
		local fname = "death_generic.ltx"
		if not (self.ltx[fname]) then 
			self.ltx[fname] = cIniFile(dir.."\\configs\\misc\\"..fname,true)
		end
		if (self.ltx[fname]) then 
		
			local keep_items = self.ltx[fname]:GetValue("keep_items",selected)
			local item_count = self.ltx[fname]:GetValue("item_count",selected)
			
			LV("LV_ADD",self.ID,"",fname,keep_items,item_count)
			self.list[fname] = {section=selected,path=dir.."\\configs\\misc\\"..fname,keep_items=keep_items,item_count=item_count}
		end
		
		local fname = "death_items_by_communities.ltx"
		if not (self.ltx[fname]) then 
			self.ltx[fname] = cIniFile(dir.."\\configs\\misc\\"..fname,true)
		end
		if (self.ltx[fname]) then 
			local v = {}
			local t = {"base","stalker","bandit","killer","dolg","freedom","army","monolith","csky","ecolog"}
			for i=1,#t do 
				v[t[i]] = self.ltx[fname]:GetValue(t[i],selected)
			end 
			
			LV("LV_ADD",self.ID,"",fname,"","",v.base,v.stalker,v.bandit,v.killer,v.dolg,v.freedom,v.army,v.monolith,v.csky,v.ecolog)
			self.list[fname] = {section=selected,path=dir.."\\configs\\misc\\"..fname,base=v.base,stalker=v.stalker,bandit=v.bandit,killer=v.killer,dolg=v.dolg,freedom=v.freedom,army=v.army,monolith=v.monolith,csky=v.csky,ecolog=v.ecolog}
		end
	end
	
	LV("LV_ModifyCol",self.ID,"1","Sort CaseLocale")
	for i=1,16 do
		LV("LV_ModifyCol",self.ID,tostring(i),"AutoHdr")
	end
end
-----------------------------------------------------------------
-- Modify UI 
-----------------------------------------------------------------
UI2 = nil
function GetModify()
	if not (UI2) then 
		UI2 = cUITraderEditorModify("2")
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
Class "cUITraderEditorModify" (cUIBase)
function cUITraderEditorModify:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUITraderEditorModify:Show(bool)
	self.inherited[1].Show(self,bool)
end 

function cUITraderEditorModify:Create()
	self.inherited[1].Create(self)
end

function cUITraderEditorModify:Reinit()
	self.inherited[1].Reinit(self)
	
	self:Gui("+AlwaysonTop")
	self:Gui("Font|s10|Verdana")
	
	local wnd = Get()
	local list = wnd.list[wnd.listItemSelected]
	if not (list) then 
		return 
	end
	local fname = trim_directory(list.path)
	
	self:Gui("Add|Text|w300 h30|%s",fname)
	
	local tab = ahkGetVar("UITraderEditorTab")
	if (tab == "1") then
		local y = 35
		self:Gui("Add|Text|x5 y%s w300 h30|%s",y,"buy_condition")
		self:Gui("Add|Edit|x200 y%s w300 h30 vUIModifyEdit1|%s",y,list.buy_condition)
		y = y + 30
		self:Gui("Add|Text|x5 y%s w300 h30|%s",y,"sell_condition")
		self:Gui("Add|Edit|x200 y%s w300 h30 vUIModifyEdit2|%s",y,list.sell_condition)
		y = y + 30
		
		local cnt = 3
		for sec,v in pairs(list.buy_supplies) do 
			self:Gui("Add|Text|x5 y%s w300 h30|%s",y,sec)
			self:Gui("Add|Edit|x200 y%s w300 h30 vUIModifyEdit%s|%s",y,cnt,v)
			cnt = cnt + 1
			y = y + 30
		end
	else 
		local t
		if (fname == "death_generic.ltx") then 
			t = {"keep_items","item_count"}
		else 
			t = {"base","stalker","bandit","killer","dolg","freedom","army","monolith","csky","ecolog"}
		end
		
		local y = 35
		for i=1,#t do 
			self:Gui("Add|Text|x5 y%s w300 h30|%s",y,t[i])
			self:Gui("Add|Edit|x200 y%s w300 h30 vUIModifyEdit%s|%s",y,i,list[t[i]])
			y = y + 30
		end
	end
 
	self:Gui("Add|Button|gOnScriptControlAction x12 default vUIModifyAccept|%t_accept")
	self:Gui("Add|Button|gOnScriptControlAction x+4 vUIModifyCancel|%t_cancel")
	self:Gui("Show|center|%t_edit_values")
	self:Gui("Default")
end

function cUITraderEditorModify:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUITraderEditorModify:Destroy()
	self.inherited[1].Destroy(self)
	
	Get().listItemSelected = nil 
end

function cUITraderEditorModify:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	if (hwnd == GuiControlGet(self.ID,"hwnd","UIModifyAccept")) then
		self:Gui("Submit|NoHide")
		local tab = ahkGetVar("UITraderEditorTab")
		
		local wnd = Get()
		local list = assert(wnd.list[wnd.listItemSelected])
		local fname = trim_directory(list.path)
	
		if not (wnd.ltx[fname]) then 
			Msg("Error with cUITraderEditorModify")
			return
		end

		if (tab == "1") then
			local a = {}
			local t = {wnd.ltx[fname]:GetValue("trader","buy_condition"),wnd.ltx[fname]:GetValue("trader","sell_condition")}
			
			local v = trim(ahkGetVar("UIModifyEdit1")) or ""
			wnd.ltx[fname]:SetValue(t[1],list.section,v)
			list.buy_condition = v
			table.insert(a,v)
			
			v = trim(ahkGetVar("UIModifyEdit2")) or ""
			wnd.ltx[fname]:SetValue(t[2],list.section,v)
			list.sell_condition = v
			table.insert(a,v)
			
			local cnt = 3
			for sec,t in pairs(list.buy_supplies) do 
				local v = trim(ahkGetVar("UIModifyEdit"..cnt)) or ""
				wnd.ltx[fname]:SetValue(sec,list.section,v)
				list.buy_supplies[sec] = v
				table.insert(a,v)
				cnt = cnt + 1
			end
			
			LVTop(self.ID,"UITraderEditorLV1")
			LV("LV_Modify",wnd.ID,self.modify_row,"",fname,unpack(a))
		else 
			if (fname == "death_generic.ltx") then
				local t = {"keep_items","item_count"}
				for i=1,#t do
					local v = trim(ahkGetVar("UIModifyEdit"..i))
					wnd.ltx[fname]:SetValue(t[i],list.section,v)
					list[t[i]] = v
				end
				
				LVTop(self.ID,"UITraderEditorLV1")
				LV("LV_Modify",wnd.ID,self.modify_row,"Col2",wnd.ltx[fname]:GetValue(t[1],list.section) or "")
				LV("LV_Modify",wnd.ID,self.modify_row,"Col3",wnd.ltx[fname]:GetValue(t[2],list.section) or "")
			elseif (fname == "death_items_by_communities.ltx") then 
				local t = {"base","stalker","bandit","killer","dolg","freedom","army","monolith","csky","ecolog"}
				for i=1,#t do
					local v = trim(ahkGetVar("UIModifyEdit"..i))
					wnd.ltx[fname]:SetValue(t[i],list.section,v)
					list[t[i]] = v
				end
				LVTop(self.ID,"UITraderEditorLV1")
				LV("LV_Modify",wnd.ID,self.modify_row,"Col4",wnd.ltx[fname]:GetValue(t[1],list.section) or "")
				LV("LV_Modify",wnd.ID,self.modify_row,"Col5",wnd.ltx[fname]:GetValue(t[2],list.section) or "")
				LV("LV_Modify",wnd.ID,self.modify_row,"Col6",wnd.ltx[fname]:GetValue(t[3],list.section) or "")
				LV("LV_Modify",wnd.ID,self.modify_row,"Col7",wnd.ltx[fname]:GetValue(t[4],list.section) or "")
				LV("LV_Modify",wnd.ID,self.modify_row,"Col8",wnd.ltx[fname]:GetValue(t[5],list.section) or "")
				LV("LV_Modify",wnd.ID,self.modify_row,"Col9",wnd.ltx[fname]:GetValue(t[6],list.section) or "")
				LV("LV_Modify",wnd.ID,self.modify_row,"Col10",wnd.ltx[fname]:GetValue(t[7],list.section) or "")
				LV("LV_Modify",wnd.ID,self.modify_row,"Col11",wnd.ltx[fname]:GetValue(t[8],list.section) or "")
				LV("LV_Modify",wnd.ID,self.modify_row,"Col12",wnd.ltx[fname]:GetValue(t[9],list.section) or "")
				LV("LV_Modify",wnd.ID,self.modify_row,"Col13",wnd.ltx[fname]:GetValue(t[10],list.section) or "")
			end
		end
		
		wnd.ltx[fname]:SaveExt()
		
		self:Show(false)
		
		--wnd:FillListView(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIModifyCancel")) then
		self:Show(false)
	end
end

function cUITraderEditorModify:Gui(...)
	self.inherited[1].Gui(self,...)
end