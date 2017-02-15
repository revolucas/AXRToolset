-----------------------------------------------------------------
--
-----------------------------------------------------------------
function OnApplicationBegin()
	Application.AddPluginButton("t_plugin_lua_check","UILuaSyntaxCheckShow",GetAndShow)
end

UI = nil
function Get()
	if not (UI) then 
		UI = cUILuaSyntaxCheck("1")
		UI.parent = Application.MainMenu
	end 
	return UI
end

function GetAndShow()
	Get():Show(true)
end
-----------------------------------------------------------------
-- UI Class Definition
-----------------------------------------------------------------

Class "cUILuaSyntaxCheck" (cUIBase)
function cUILuaSyntaxCheck:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUILuaSyntaxCheck:Reinit()
	self.inherited[1].Reinit(self)
	
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vUILuaSyntaxCheckTab|LuaCheck 1^LuaCheck 2^LuaCheck 3^LuaCheck 4^LuaCheck 5^LuaCheck 6^LuaCheck 7^LuaCheck 8^LuaCheck 9^LuaCheck 10")
	for n=1,10 do
		self:Gui("Tab|LuaCheck "..n)
			-- GroupBox
			self:Gui("Add|GroupBox|x10 y50 w510 h75|Input Directory")
			
			-- Checkbox
			self:Gui("Add|CheckBox|x200 y58 w120 h20 %s vUILuaSyntaxBrowseRecur%s|%s",gSettings:GetValue("lua_syntax_check","check_browse_recur"..n,"") == "1" and "Checked" or "",n,"%t_recursive")
			
			-- Buttons 
			self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vUILuaSyntaxCheckBrowseInputPath%s|...",n)
			self:Gui("Add|Button|gOnScriptControlAction x485 y655 w201 h20 vUILuaSyntaxCheckSaveSettings%s|%t_save_settings",n)
			self:Gui("Add|Button|gOnScriptControlAction x485 y680 w201 h20 vUILuaSyntaxCheckExecute%s|%t_execute",n)
			
			-- Editbox 
			self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vUILuaSyntaxCheckInputPath%s|",n)
		
		GuiControl(self.ID,"","UILuaSyntaxCheckInputPath"..n, gSettings:GetValue("lua_syntax_check","path"..n) or "")
	end
	self:Gui("Show|w1024 h720|%t_plugin_lua_check")
end

function cUILuaSyntaxCheck:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUILuaSyntaxCheck:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self.inherited[1].OnScriptControlAction(self,hwnd,event,info)
	local tab = ahkGetVar("UILuaSyntaxCheckTab") or "1"
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","UILuaSyntaxCheckBrowseInputPath"..tab)) then
		local dir = FileSelectFolder("*"..(gSettings:GetValue("lua_syntax_check","path"..tab) or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UILuaSyntaxCheckInputPath"..tab,dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILuaSyntaxCheckExecute"..tab)) then
		self:ActionSubmit(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILuaSyntaxCheckSaveSettings"..tab)) then
		gSettings:SetValue("lua_syntax_check","path"..tab,ahkGetVar("UILuaSyntaxCheckInputPath"..tab) or "")
		gSettings:SetValue("lua_syntax_check","check_browse_recur"..tab,ahkGetVar("UILuaSyntaxCheckBrowseRecur"..tab))
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
		_INACTION = nil
		return 
	end 
	
	gSettings:SetValue("lua_syntax_check","path"..tab,input_path)
	gSettings:SetValue("lua_syntax_check","check_browse_recur"..tab,ahkGetVar("UILuaSyntaxCheckBrowseRecur"..tab))
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
	
	file_for_each(input_path,{"script","lua"},on_execute,ahkGetVar("UILuaSyntaxCheckBrowseRecur"..tab) ~= "1")
	
	Msg("Lua Syntax Check:= Finished!")
	
	_INACTION = false
end