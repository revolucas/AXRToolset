function Get()
	if not (UIModifyWnd) then 
		UIModifyWnd = cUILTXQuickEditModify("2")
	end
	return UIModifyWnd
end

function GetAndShow()
	Get():Show(true)
end

cUILTXQuickEditModify = Class{__includes={cUIBase}}
function cUILTXQuickEditModify:init(id)
	cUIBase.init(self,id)
end

function cUILTXQuickEditModify:Reinit()
	cUIBase.Reinit(self)
	
	self:Gui("+AlwaysonTop")
	self:Gui("Font|s10|Verdana")
	
	local wnd = UILTXQuickEdit.Get()
	local list = wnd.list[wnd.listItemSelected]
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
			local val = ahkGetVar("UIModifyEdit"..field)
			wnd.ltx[fname]:SetValue(wnd.listItemSelected,field,val)
		end

		wnd.ltx[fname]:SaveExt()
		
		self:Show(false)
		
		wnd:FillListView(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIModifyCancel")) then
		self:Show(false)
	end
end

