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
				UIModify.GetAndShow()
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