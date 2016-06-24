UITraderEditorWnd = nil
function OnApplicationBegin()
	UIMainMenuWnd:AddPluginButton("Trader Editor","UITraderEditorShow",GetAndShow)
end

function Get()
	if not (UITraderEditorWnd) then 
		UITraderEditorWnd = cUITraderEditor()
	end 
	return UITraderEditorWnd
end

function GetAndShow()
	Get():Show(true)
end

cUITraderEditor = Class{__includes={cUIBase}}
function cUITraderEditor:init()
	cUIBase.init(self)

	self.ltx = {}
	self.list = {}
end

function cUITraderEditor:Reinit()
	cUIBase.Reinit(self)
	
	self:Gui("Add, Tab2, x0 y0 w1024 h720 AltSubmit, Buy/Sell Editor")
	self:Gui("Tab, Buy/Sell Editor")
		local valid_sections = self:GetSectionList()
		self:Gui("Add, DropDownList, gOnScriptControlAction x22 y69 w320 h30 R40 H300 vUITraderEditorSection hwndUITraderEditorSection_H, "..valid_sections)

		self:Gui("Add, Text, x22 y49 w140 h20, Section:")
		self:Gui("Add, ListView, gOnScriptControlAction x22 y109 w820 h440 grid cBlack +altsubmit -multi vUITraderEditorLV1 hwndUITraderEditorLV1_H, file|buy_condition|sell_condition|buy_supplies1|buy_supplies2|buy_supplies3|buy_supplies4|buy_supplies5")
		self:Gui("Add, Text, x550 y75 w200 h20, Right-Click to Edit!")
	self:Gui("Show, w1024 h720, Trade Editor")
		
	LV("LV_Delete",self.ID)
	clear(self.list)
end

function cUITraderEditor:OnGuiClose(idx) -- needed because it's registered to callback
	cUIBase.OnGuiClose(self,idx)
end 

function cUITraderEditor:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	cUIBase.OnScriptControlAction(self,hwnd,event,info)
	if (hwnd == tonumber(ahkGetVar("UITraderEditorShow_H"))) then 
		self:Show(true)
	elseif (hwnd == tonumber(ahkGetVar("UITraderEditorLV1_H"))) then 
		local selected = trim(ahkGetVar("UITraderEditorSection"))
		if (selected == nil or selected == "") then 
			return 
		end		
		
		if (event == "RightClick") then
			local option = self.list[tonumber(info)]
			if (option and not self.listItemSelected) then
				self.listItemSelected = tonumber(info)
				UIModify.GetAndShow()
			end
		end
	elseif (hwnd == tonumber(ahkGetVar("UITraderEditorLV1Find_H"))) then 
		local text = ahkGetVar("UITraderEditorLV1Find")
	elseif (hwnd == tonumber(ahkGetVar("UITraderEditorSection_H"))) then 	
		self:Gui("Submit, NoHide")
		self:FillListView()
	end
end

function cUITraderEditor:GetSectionList()
	local item_list = Xray.get_item_sections_list()
	if (item_list) then 
		return item_list:GetKeysAsString("sections","|")
	end
	return ""
end

function cUITraderEditor:FillListView()
	LV("LV_Delete",self.ID)
	empty(self.list)

	local selected = trim(ahkGetVar("UITraderEditorSection"))
	if (selected == nil or selected == "") then 
		return 
	end
	
	local dir = gSettings:GetValue("core","Gamedata_Path")
	if not (dir) then 
		Msg("Error: Please set gamedata path in settings!")
		return 
	end 
	dir = dir .. "\\configs\\misc\\trade"
	
	local function on_execute(path,fname)
		if not (self.ltx[fname]) then 
			self.ltx[fname] = IniFile.New(path.."\\"..fname)
		end
		
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

		LV("LV_ADD",self.ID,"",fname,buy_cond,sell_cond, unpack(a))
			
		table.insert(self.list,{section=selected,path=path.."\\"..fname,buy_condition=buy_cond,sell_condition=sell_cond, buy_supplies=b})
	end
	
	recurse_subdirectories_and_execute(dir,{"ltx"},on_execute)
	LV("LV_ModifyCol",self.ID)
	LV("LV_ModifyCol",self.ID,"1","Sort CaseLocale")
	LV("LV_Modify",self.ID,LV("LV_GetCount"),"Vis")
end