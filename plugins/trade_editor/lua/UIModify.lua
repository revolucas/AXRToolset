function Get()
	if not (UIModifyWnd) then 
		UIModifyWnd = cUIModify("2")
	end
	return UIModifyWnd
end

function GetAndShow()
	Get():Show(true)
end

cUIModify = Class{__includes={cUIBase}}
function cUIModify:init(id)
	cUIBase.init(self,id)
end

function cUIModify:Reinit()
	cUIBase.Reinit(self)
	
	self:Gui("+AlwaysonTop")
	self:Gui("Font|s10|Verdana")
	
	local wnd = UITraderEditor.Get()
	local list = wnd.list[wnd.listItemSelected]
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
	
	UITraderEditor.Get().listItemSelected = nil 
end

function cUIModify:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	if (hwnd == GuiControlGet(self.ID,"hwnd","UIModifyAccept")) then
		self:Gui("Submit|NoHide")
		local tab = ahkGetVar("UITraderEditorTab")
		
		local wnd = UITraderEditor.Get()
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

