cUILuaSyntaxCheck = Class{__includes={cUIBase}}
function cUILuaSyntaxCheck:init(id)
	cUIBase.init(self,id)
end

function cUILuaSyntaxCheck:Reinit()
	cUIBase.Reinit(self)
	
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vUILuaSyntaxCheckTab|LuaCheck 1^LuaCheck 2^LuaCheck 3^LuaCheck 4^LuaCheck 5^LuaCheck 6^LuaCheck 7^LuaCheck 8^LuaCheck 9^LuaCheck 10")
	for n=1,10 do
		self:Gui("Tab|LuaCheck "..n)
			-- GroupBox
			self:Gui("Add|GroupBox|x10 y50 w510 h75|Input Directory")
			
			-- Buttons 
			self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vUILuaSyntaxCheckBrowseInputPath%s|...",n)
			self:Gui("Add|Button|gOnScriptControlAction x485 y655 w90 h20 vUILuaSyntaxCheckSaveSettings%s|Save Settings",n)
			self:Gui("Add|Button|gOnScriptControlAction x485 y680 w90 h20 vUILuaSyntaxCheckExecute%s|Check",n)
			
			-- Editbox 
			self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vUILuaSyntaxCheckInputPath%s|",n)
		
		GuiControl(self.ID,"","UILuaSyntaxCheckInputPath"..n, gSettings:GetValue("lua_syntax_check","path"..n) or "")
	end
	self:Gui("Show|w1024 h720|Lua Syntax Check")
end

function cUILuaSyntaxCheck:OnGuiClose(idx) -- needed because it's registered to callback
	cUIBase.OnGuiClose(self,idx)
end 

function cUILuaSyntaxCheck:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("UILuaSyntaxCheckTab") or "1"
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","UILuaSyntaxCheckBrowseInputPath"..tab)) then
		local dir = FileSelectFolder("*"..(gSettings:GetValue("lua_syntax_check","path"..tab) or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UILuaSyntaxCheckInputPath"..tab,dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILuaSyntaxCheckExecute"..tab)) then
		self:Gui("Submit|NoHide")
		self:ActionSubmit(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILuaSyntaxCheckSaveSettings"..tab)) then
		gSettings:SetValue("lua_syntax_check","path"..tab,ahkGetVar("UILuaSyntaxCheckInputPath"..tab) or "")
		gSettings:Save()
	end
end

_INACTION = nil
function cUILuaSyntaxCheck:ActionSubmit(tab)
	if (_INACTION) then 
		MsgBox("Already performing an action")
		return 
	end 
	
	_INACTION = true
	
	local input_path = ahkGetVar("UILuaSyntaxCheckInputPath"..tab)
	if (input_path == nil or input_path == "") then 
		MsgBox("Incorrect Path!")
		return 
	end 
	
	gSettings:SetValue("lua_syntax_check","path"..tab,input_path)
	gSettings:Save()
		
	local working_directory = ahkGetVar("A_WorkingDir").."\\bin\\"
	local luac = working_directory.."luac5.1.exe"
	
	local dir = trim_directory(input_path)
	local parent_dir = get_path(input_path)
	
	Msg("Lua Syntax Check:= working...")
	
	local outFilePath = 'LuaCheck.out'
    local logFilePath = 'LuaCheck.log'
		
	local function on_execute(path,fname)
		if not (fname == "lua_help.script") then
			RunWait( strformat([["%s" -p "%s"]],luac,path.."\\"..fname), working_directory )
		end
	end
	
	recurse_subdirectories_and_execute(input_path,{"script","lua"},on_execute)
	
	Msg("Lua Syntax Check:= Finished!")
	
	_INACTION = false
end
------------------------------------------------
local oUILuaSyntaxCheck = nil
function OnApplicationBegin()
	UIMainMenuWnd:AddPluginButton("Lua Syntax Check","UILuaSyntaxCheckShow",GetAndShow)
end

function Get()
	if not (oUILuaSyntaxCheck) then 
		oUILuaSyntaxCheck = cUILuaSyntaxCheck("1")
		oUILuaSyntaxCheck.parent = UIMainMenuWnd
	end 
	return oUILuaSyntaxCheck
end

function GetAndShow()
	Get():Show(true)
end