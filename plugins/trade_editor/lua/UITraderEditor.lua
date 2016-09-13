local oUITraderEditor = nil
function OnApplicationBegin()
	UIMainMenuWnd:AddPluginButton("Trader Editor","UITraderEditorShow",GetAndShow)
end

function Get()
	if not (oUITraderEditor) then 
		oUITraderEditor = cUITraderEditor("1")
		oUITraderEditor.parent = UIMainMenuWnd
	end 
	return oUITraderEditor
end

function GetAndShow()
	Get():Show(true)
end

cUITraderEditor = Class{__includes={cUIBase}}
function cUITraderEditor:init(id)
	cUIBase.init(self,id)

	self.ltx = {}
	self.list = {}
end

function cUITraderEditor:Show(bool)
	cUIBase.Show(self,bool)
end 

function cUITraderEditor:Create()
	cUIBase.Create(self)
end

function cUITraderEditor:Reinit()
	cUIBase.Reinit(self)
	
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vUITraderEditorTab hwndUITraderEditorTab_H|Buy/Sell Editor^Death Config")
	self:Gui("Tab|Buy/Sell Editor")
		local valid_sections = self:GetSectionList()
		self:Gui("Add|Text|x22 y49 w140 h20|Section:")
		self:Gui("Add|DropDownList|gOnScriptControlAction x22 y69 w320 h30 R40 H300 vUITraderEditorSection1|"..valid_sections)
		self:Gui("Add|Text|x550 y75 w200 h20|Right-Click to Edit!")
		self:Gui("Add|ListView|gOnScriptControlAction x22 y109 w920 h440 grid cBlack +altsubmit -multi vUITraderEditorLV1|file^buy_condition^sell_condition^buy_supplies1^buy_supplies2^buy_supplies3^buy_supplies4^buy_supplies5")
	self:Gui("Tab|Death Config")
		self:Gui("Add|Text|x22 y49 w140 h20|Section:")
		self:Gui("Add|DropDownList|gOnScriptControlAction x22 y69 w320 h30 R40 H300 vUITraderEditorSection2|"..valid_sections)	
		self:Gui("Add|Text|x550 y75 w200 h20|Right-Click to Edit!")
		self:Gui("Add|ListView|gOnScriptControlAction x22 y109 w920 h440 grid cBlack +altsubmit -multi vUITraderEditorLV2|file^keep_items^item_count^base^stalker^bandit^killer^dolg^freedom^army^monolith^csky^ecolog")
	self:Gui("Show|w1024 h720|Trade Editor")
	self:Gui("Default")
		
	LV("LV_Delete",self.ID)
	clear(self.list)
end

function cUITraderEditor:OnGuiClose(idx) -- needed because it's registered to callback
	cUIBase.OnGuiClose(self,idx)
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
			local txt = LVGetText(self.ID,LVGetNext(self.ID,"0","UITraderEditorLV"..tab),"1")
			if (txt and txt ~= "" and not self.listItemSelected) then
				self.listItemSelected = txt
				GetAndShowModify()
			end
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITraderEditorSection"..tab)) then 	
		self:FillListView(tab)
	end
end

function cUITraderEditor:Gui(...)
	cUIBase.Gui(self,...)
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
				self.ltx[fname] = IniFile.New(path.."\\"..fname,true)
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
		
		recurse_subdirectories_and_execute(dir.."\\configs\\misc\\trade",{"ltx"},on_execute)
	else
		-- death configs 
		local fname = "death_generic.ltx"
		if not (self.ltx[fname]) then 
			self.ltx[fname] = IniFile.New(dir.."\\configs\\misc\\"..fname,true)
		end
		if (self.ltx[fname]) then 
		
			local keep_items = self.ltx[fname]:GetValue("keep_items",selected)
			local item_count = self.ltx[fname]:GetValue("item_count",selected)
			
			LV("LV_ADD",self.ID,"",fname,keep_items,item_count)
			self.list[fname] = {section=selected,path=dir.."\\configs\\misc\\"..fname,keep_items=keep_items,item_count=item_count}
		end
		
		local fname = "death_items_by_communities.ltx"
		if not (self.ltx[fname]) then 
			self.ltx[fname] = IniFile.New(dir.."\\configs\\misc\\"..fname,true)
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
------------------------------------------
cUIModify = Class{__includes={cUIBase}}
function cUIModify:init(id)
	cUIBase.init(self,id)
end

function cUIModify:Show(bool)
	cUIBase.Show(self,bool)
end 

function cUIModify:Create()
	cUIBase.Create(self)
end

function cUIModify:Reinit()
	cUIBase.Reinit(self)
	
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
		self:Gui("Add|Edit|w300 h30 vUIModifyEdit1|%s",list.buy_condition)
		self:Gui("Add|Edit|w300 h30 vUIModifyEdit2|%s",list.sell_condition)
		
		local cnt = 3
		for sec,v in pairs(list.buy_supplies) do 
			self:Gui("Add|Edit|w300 h30 vUIModifyEdit%s|%s",cnt,v)
			cnt = cnt + 1
		end
	else 
		local t
		if (fname == "death_generic.ltx") then 
			t = {"keep_items","item_count"}
		else 
			t = {"base","stalker","bandit","killer","dolg","freedom","army","monolith","csky","ecolog"}
		end
		
		for i=1,#t do 
			self:Gui("Add|Edit|w300 h30 vUIModifyEdit%s|%s",i,list[t[i]])
		end
	end
 
	self:Gui("Add|Button|gOnScriptControlAction x12 default vUIModifyAccept|Accept")
	self:Gui("Add|Button|gOnScriptControlAction x+4 vUIModifyCancel|Cancel")
	self:Gui("Show|center|Edit Values")
	self:Gui("Default")
end

function cUIModify:OnGuiClose(idx) -- needed because it's registered to callback
	cUIBase.OnGuiClose(self,idx)
end 

function cUIModify:Destroy()
	cUIBase.Destroy(self)
	
	Get().listItemSelected = nil 
end

function cUIModify:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	if (hwnd == GuiControlGet(self.ID,"hwnd","UIModifyAccept")) then
		self:Gui("Submit|NoHide")
		local tab = ahkGetVar("UITraderEditorTab")
		
		local wnd = Get()
		local list = assert(wnd.list[wnd.listItemSelected])
		local fname = trim_directory(list.path)
	
		assert(wnd.ltx[fname])

		if (tab == "1") then
			local t = {wnd.ltx[fname]:GetValue("trader","buy_condition"),wnd.ltx[fname]:GetValue("trader","sell_condition")}
			for i=1,#t do
				local v = ahkGetVar("UIModifyEdit"..i) or ""
				wnd.ltx[fname]:SetValue(t[i],list.section,v)
			end
			local cnt = 3
			for sec,t in pairs(list.buy_supplies) do 
				local v = ahkGetVar("UIModifyEdit"..cnt)
				wnd.ltx[fname]:SetValue(sec,list.section,v)
				cnt = cnt + 1
			end
		else 
			if (fname == "death_generic.ltx") then
				local t = {"keep_items","item_count"}
				for i=1,#t do
					local v = ahkGetVar("UIModifyEdit"..i)
					if (v and v ~= "") then
						wnd.ltx[fname]:SetValue(t[i],list.section,v)
					end
				end
			elseif (fname == "death_items_by_communities.ltx") then 
				local t = {"base","stalker","bandit","killer","dolg","freedom","army","monolith","csky","ecolog"}
				for i=1,#t do
					local v = ahkGetVar("UIModifyEdit"..i)
					if (v and v ~= "") then
						wnd.ltx[fname]:SetValue(t[i],list.section,v)
					end
				end
			end
		end
		
		wnd.ltx[fname]:SaveExt()
		
		self:Show(false)
		
		wnd:FillListView(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIModifyCancel")) then
		self:Show(false)
	end
end

function cUIModify:Gui(...)
	cUIBase.Gui(self,...)
end
-------------------------------------------------
local oUIModify = nil
function GetModify()
	if not (oUIModify) then 
		oUIModify = cUIModify("2")
	end
	return oUIModify
end

function GetAndShowModify()
	GetModify():Show(true)
end