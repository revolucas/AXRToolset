UITidierWnd = nil
function OnApplicationBegin()
	UIMainMenuWnd:AddPluginButton("LTX Tidier","UITidierShow",GetAndShow)
end

function Get()
	if not (UITidierWnd) then 
		UITidierWnd = cUITidier("1")
		UITidierWnd.parent = UIMainMenuWnd
	end 
	return UITidierWnd
end

function GetAndShow()
	Get():Show(true)
end

cUITidier = Class{__includes={cUIBase}}
function cUITidier:init(id)
	cUIBase.init(self,id)
end

function cUITidier:Reinit()
	cUIBase.Reinit(self)
	
	-- GroupBox
	self:Gui("Add|GroupBox|x10 y50 w510 h75|Input Path")
	self:Gui("Add|GroupBox|x10 y150 w510 h75|Output Path")
		
	-- Buttons 
	self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vUITidierBrowseInputPath|...")
	self:Gui("Add|Button|gOnScriptControlAction x485 y180 w30 h20 vUITidierBrowseOutputPath|...")
	self:Gui("Add|Button|gOnScriptControlAction x485 y680 w90 h20 vUITidierExecute|Tidy")
	
	-- Editbox 
	self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vUITidierInputPath|")
	self:Gui("Add|Edit|gOnScriptControlAction x25 y180 w450 h20 vUITidierOutputPath|")
	
	self:Gui("Show|w1024 h720|LTX Tidier")
	
	GuiControl(self.ID,"","UITidierInputPath", gSettings:GetValue("ltx_tidier","input_path") or "")
	GuiControl(self.ID,"","UITidierOutputPath", gSettings:GetValue("ltx_tidier","output_path") or "")
end

function cUITidier:OnGuiClose(idx) -- needed because it's registered to callback
	cUIBase.OnGuiClose(self,idx)
end 

function cUITidier:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	if (hwnd == GuiControlGet(self.ID,"hwnd","UITidierBrowseInputPath")) then
		local dir = FileSelectFolder("*"..(gSettings:GetValue("ltx_tidier","input_path") or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UITidierInputPath",dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITidierBrowseOutputPath")) then 
		local dir = FileSelectFolder("*"..(gSettings:GetValue("ltx_tidier","output_path") or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UITidierOutputPath",dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITidierExecute")) then
		self:Gui("Submit|NoHide")
		local i_path = ahkGetVar("UITidierInputPath")
		local o_path = ahkGetVar("UITidierOutputPath")	
		if (i_path and i_path ~= "" and o_path and o_path ~= "") then
			gSettings:SetValue("ltx_tidier","input_path",i_path)
			gSettings:SetValue("ltx_tidier","output_path",o_path)
			gSettings:Save()
			-- Run(target,working_directory)
			Run( strformat([["%s" "%s" "%s"]],ahkGetVar("A_WorkingDir")..[[\plugins\ltx_tidier\bin\LTXTidier.bat]],i_path,o_path), ahkGetVar("A_WorkingDir")..[[\plugins\ltx_tidier\bin\]] )
		else 
			MsgBox("LTX Tidier: Incorrect path setup! input=%s output=%s",i_path,o_path)
		end
	end
end