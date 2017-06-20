-----------------------------------------------------------------
-- 
-----------------------------------------------------------------
function OnApplicationBegin()
	Application.AddPluginButton("t_plugin_lua_help","UILuaHelpShow",GetAndShow)
end

UI = nil
function Get()
	if not (UI) then 
		UI = cUILuaHelp("1")
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

Class "cUILuaHelp" (cUIBase)
function cUILuaHelp:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUILuaHelp:Reinit()
	self.inherited[1].Reinit(self)
	
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vUILuaHelpTab|%t_plugin_lua_help")
	self:Gui("Tab|%t_plugin_lua_help")
		-- GroupBox
		self:Gui("Add|GroupBox|x10 y50 w510 h75|%t_input_path")
		self:Gui("Add|GroupBox|x10 y150 w510 h75|%t_output_path")
		
		self:Gui("Add|CheckBox|x200 y58 w120 h20 %s vUILuaHelpBrowseRecur|%s",gSettings:GetValue("luahelp","check_browse_recur","") == "1" and "Checked" or "","%t_recursive")
		
		-- Buttons 
		self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vUILuaHelpBrowseInputPath|...")
		self:Gui("Add|Button|gOnScriptControlAction x485 y180 w30 h20 vUILuaHelpBrowseOutputPath|...")
		self:Gui("Add|Button|gOnScriptControlAction x485 y655 w201 h20 vUILuaHelpSaveSettings0|%t_save_settings")	
		self:Gui("Add|Button|gOnScriptControlAction x485 y680 w201 h20 vUILuaHelpExecute|%t_execute")		
		
		-- Editbox 
		self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vUILuaHelpInputPath|")
		self:Gui("Add|Edit|gOnScriptControlAction x25 y180 w450 h20 vUILuaHelpOutputPath|")
		
	GuiControl(self.ID,"","UILuaHelpInputPath", gSettings:GetValue("luahelp","unpack_input_path") or "")
	GuiControl(self.ID,"","UILuaHelpOutputPath", gSettings:GetValue("luahelp","unpack_output_path") or "")
	
	self:Gui("Show|w1024 h720|%t_plugin_lua_help")
end

function cUILuaHelp:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUILuaHelp:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self.inherited[1].OnScriptControlAction(self,hwnd,event,info)
	if (hwnd == GuiControlGet(self.ID,"hwnd","UILuaHelpBrowseInputPath")) then
		local dir = FileSelectFolder("*"..(gSettings:GetValue("luahelp","unpack_input_path") or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UILuaHelpInputPath",dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILuaHelpBrowseOutputPath")) then 
		local dir = FileSelectFolder("*"..(gSettings:GetValue("luahelp","unpack_output_path") or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UILuaHelpOutputPath",dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILuaHelpExecute")) then
		ActionSubmit()
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UILuaHelpSaveSettings0")) then
		local input_path = ahkGetVar("UILuaHelpInputPath")
		local output_path = ahkGetVar("UILuaHelpOutputPath")
		
		gSettings:SetValue("luahelp","unpack_input_path",input_path)
		gSettings:SetValue("luahelp","unpack_output_path",output_path)
		gSettings:Save()
	end
end

local output_table = {}
_INACTION = nil
function ActionSubmit()
	if (_INACTION) then 
		MsgBox("Already performing an action")
		return 
	end 
	
	local input_path = ahkGetVar("UILuaHelpInputPath")
	if (input_path == nil or input_path == "") then 
		MsgBox("Incorrect Path!")
		return 
	end 
	
	local output_path = ahkGetVar("UILuaHelpOutputPath")
	if (output_path == nil or output_path == "") then 
		MsgBox("Incorrect Output Path!")
		return 
	end 	
	
	_INACTION = true
	
	gSettings:SetValue("luahelp","check_browse_recur",ahkGetVar("UILuaHelpBrowseRecur"))
	gSettings:SetValue("luahelp","path",input_path)
	gSettings:SetValue("luahelp","output_path",output_path)
	gSettings:Save()
	
	if not (directory_exists(output_path)) then
		os.execute('MD "'..output_path..'"')
	end
	
	clear(output_table)
	
	local function on_execute(path,fname)
		parse_file(path,fname,path.."\\"..fname)
	end 
	
	Msg("\nLua Help:= Starting!")
	
	file_for_each(input_path,{"cpp"},on_execute,ahkGetVar("UILuaHelpBrowseRecur") ~= "1")
	
	table.sort(output_table)
	local f = io.open(output_path.."\\luahelper.txt","wb")
	if (f) then
		f:write(table.concat(output_table,"\n"))
		f:close()
	end
	
	Msg("\nLua Help:= Finished!")
	
	_INACTION = false
end

function parse_file(path,fname,fullpath)
	local namespace = ""
	local block_started = false	
	for line in io.lines(fullpath) do
		line = trim(line)
		if (line ~= "") then
			if (startsWith(line, "module(L")) then
				local s = line:match([["(.-)"]])
				if (s and s ~= "") then
					namespace = s
				end
				block_started = true
			elseif (startsWith(line,"instance")) then
				local s = line:match([[<(.-)>]])
				if (s and s ~= "") then 
					namespace = s
					block_started = true
				end
			elseif (block_started == false and startsWith(line,"[")) then
				block_started = true
			elseif (block_started and (startsWith(line,"];") or startsWith(line,"}")) ) then 
				block_started = false
				namespace = ""
			else
				if (startsWith(line,"class_")) then 
					local s = line:match([["(.-)"]])
					if (s and s ~= "") then
						namespace = s
					end
				elseif (startsWith(line,"def")) then
					local s = line:match([["(.-)"]])
					if (s and s ~= "") then
						local method
						if (string.find(line,"def_readonly")) then
							if (namespace ~= "") then
								method = namespace .. "." .. s
							else 
								method = "_G."..s
							end
						elseif (string.find(line,"def_readwrite")) then
							if (namespace ~= "") then
								method = namespace .. "." .. s
							else 
								method = "_G."..s
							end
						else 
							if (namespace ~= "") then
								method = namespace .. "." .. s .. "()"
							else 
								method = "_G.".. s .. "()"
							end
						end
						Msg(method)
						table.insert(output_table,method)
					end				
				elseif (startsWith(line,".def")) then 
					local s = line:match([["(.-)"]])
					if (s and s ~= "") then
						local method
						if (string.find(line,"def_readonly")) then
							if (namespace ~= "") then
								method = namespace .. "." .. s
							else 
								method = "_G."..s
							end
						elseif (string.find(line,"def_readwrite")) then
							if (namespace ~= "") then
								method = namespace .. "." .. s
							else 
								method = "_G."..s
							end
						else 
							if (namespace ~= "") then
								method = namespace .. ":" .. s .. "()"
							else 
								method = "_G.".. s .. "()"
							end
						end
						Msg(method)
						table.insert(output_table,method)
					end
				end
			end
		end
	end
end