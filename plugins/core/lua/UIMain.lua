cUIMain = Class{}
function cUIMain:init()
	self.plugins = {}
	self.ID = "1"
	self.ID_ITR = 1
	
	self.y = 75
	
	self:Gui("Add, Tab2, x0 y0 w1024 h720, Plugins|Settings")
	self:Gui("Tab, Plugins")
	
		-- GroupBox
		self:Gui("Add, GroupBox, x360 y50 w250 h660, Plugins Launcher")
	
	self:Gui("Tab, Settings")
	
		-- Buttons 
		self:Gui("Add, Button, gOnScriptControlAction x485 y80 w25 h20 hwndUIMainBrowseGamedata_H, ...")
		self:Gui("Add, Button, gOnScriptControlAction x485 y680 w90 h20 hwndUIMainSaveSettings_H, Save Settings")
	
		-- Editbox 
		self:Gui("Add, Edit, gOnScriptControlAction x25 y80 w450 h20 vUIMainGamedataPath hwndUIMainGamedataPath_H, ") -- Edit System.ltx
		
	self:Gui("Show, w1024 h720, AXR ToolSet")
	
	-- Register Callbacks 
	CallbackRegister("OnUIMainMenuSettingsSaved",self.OnUIMainMenuSettingsSaved,self)
	CallbackRegister("OnApplicationBegin",self.OnApplicationBegin,self)
end

function cUIMain:Gui(str)
	local p = str_explode(str,",")
	p[1] = self.ID .. ":" .. p[1]
	Gui(unpack(p))
end

function cUIMain:GetID()
	self.ID_ITR = self.ID_ITR + 1 
	return tostring(self.ID_ITR)
end

function cUIMain:AddPluginButton(text,name,func,...)
	self:Gui("Tab, Plugins")
	self:Gui( strformat("Add, Button, gOnScriptControlAction x370 y%s w230 h20 hwnd%s_H, %s",self.y,name,text))
	self.y = self.y + 25
	self.plugins[name] = {f=func, p={...}}
end

function cUIMain:OnScriptControlAction(hwnd,event,info)
	if (hwnd == nil or hwnd == "") then 
		return 
	end 
	
	CallbackSend("OnScriptControlAction",hwnd,event,info)

	if (hwnd == tonumber(ahkGetVar("UIMainBrowseGamedata_H"))) then 
		local dir = FileSelectFolder()
		GuiControl("","UIMainGamedataPath",dir)
	elseif (hwnd == tonumber(ahkGetVar("UIMainSaveSettings_H"))) then 
		self:Gui("Submit, NoHide")
		CallbackSend("OnUIMainMenuSettingsSaved")
	elseif (hwnd == tonumber(ahkGetVar("UIMainGamedataPath_H"))) then  
		--local text = ahkGetVar("UIMainGamedataPath")
	end
	
	for name,t in pairs(self.plugins) do 
		if (t.f and hwnd == tonumber(ahkGetVar(name.."_H"))) then
			t.f(unpack(t.p),hwnd,event,info)
		end
	end
end

function cUIMain:OnUIMainMenuSettingsSaved()
	gSettings:SetValue("core","Gamedata_Path",ahkGetVar("UIMainGamedataPath"))
	gSettings:Save()
end

function cUIMain:OnApplicationBegin()
	GuiControl("","UIMainGamedataPath", gSettings:GetValue("core","Gamedata_Path") or "")
end