function Get()
	if not (UIModifyWnd) then 
		UIModifyWnd = cUIModify()
	end
	return UIModifyWnd
end

function GetAndShow()
	Get():Show(true)
end

cUIModify = Class{__includes={cUIBase}}
function cUIModify:init()
	cUIBase.init(self)
end

function cUIModify:Reinit()
	cUIBase.Reinit(self)
	
	self:Gui("+AlwaysonTop")
	self:Gui("Font, s10, Verdana")
	
	local wnd = UITraderEditor.Get()
	local list = wnd.list[wnd.listItemSelected]
	local fname = trim_directory(list.path)
	
	self:Gui("Add, Text, w300 h30, "..fname)
	Gui(self.ID..":Add","Edit","w300 h30 vUIModifyEdit1", list.buy_condition)
	Gui(self.ID..":Add","Edit","w300 h30 vUIModifyEdit2", list.sell_condition)
	
	local cnt = 3
	for sec,v in pairs(list.buy_supplies) do 
		Gui(self.ID..":Add","Edit","w300 h30 vUIModifyEdit"..cnt,v)
		cnt = cnt + 1
	end
 
	self:Gui("Add, Button, gOnScriptControlAction x12 default hwndUIModifyAccept_H, Accept")
	self:Gui("Add, Button, gOnScriptControlAction x+4 hwndUIModifyCancel_H, Cancel")
	self:Gui("Show, center, Edit Values")
end

function cUIModify:OnGuiClose(idx) -- needed because it's registered to callback
	cUIBase.OnGuiClose(self,idx)
end 

function cUIModify:Destroy()
	cUIBase.Destroy(self)
	
	UITraderEditor.Get().listItemSelected = nil 
end

function cUIModify:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	cUIBase.OnScriptControlAction(self,hwnd,event,info)
	if (hwnd == tonumber(ahkGetVar("UIModifyAccept_H"))) then
		self:Gui("Submit, NoHide")
		
		local wnd = UITraderEditor.Get()
		local list = assert(wnd.list[wnd.listItemSelected])
		local fname = trim_directory(list.path)
		
		assert(wnd.ltx[fname])
		
		local buy_cond= wnd.ltx[fname]:GetValue("trader","buy_condition")
		wnd.ltx[fname]:SetValue(buy_cond,list.section,ahkGetVar("UIModifyEdit1"))
		
		local sell_cond= wnd.ltx[fname]:GetValue("trader","sell_condition")
		wnd.ltx[fname]:SetValue(sell_cond,list.section,ahkGetVar("UIModifyEdit2"))
		
		local cnt = 3
		for sec,v in pairs(list.buy_supplies) do 
			wnd.ltx[fname]:SetValue(sec,list.section,ahkGetVar("UIModifyEdit"..cnt))
			cnt = cnt + 1
		end
		
		wnd.ltx[fname]:SaveExt()
		
		self:Show(false)
		
		wnd:FillListView()
	elseif (hwnd == tonumber(ahkGetVar("UIModifyCancel_H"))) then
		self:Show(false)
	end
end

