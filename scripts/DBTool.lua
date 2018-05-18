local type_dbs = {
	['2947ru'] = 'config',
	xdb = 'configs'
}
local DBChecks = {
	[1] = 'ai',
	[2] = 'anims',
	[3] = 'configs_temp', -- name generated in cUICoCDBTool:Reinit()
	[4] = 'scripts',
	[5] = 'xr',
	[6] = 'shaders',
	[7] = 'spawns',
	[8] = 'levels',
	[9] = 'sounds',
	[10] = 'textures',
	[11] = 'meshes',
	[12] = 'thms'
}
local outdir = {	
	["ai"] = "configs",
	["anims"] = "configs",
	["scripts"] = "configs",
	["xr"] = "configs",
	-- [folder_name] = "configs", -- name generated in ActionSubmit(tab)
	["spawns"] = "configs",
	["shaders"] = "configs",
	["meshes"] = "resources",
	["sounds"] = "sounds",
	["textures"] = "resources",
	["thms"] = "resources"
}
local data_for_levels = [[
[header]
auto_load = true
level_name = single ; former level name, now can be mod name
level_ver = 1.0 ; former level version, now can be mod version
entry_point = $fs_root$\gamedata\ ; do not change !
creator = "Team EPIC" ; creator's name
link = "forum.epicstalker.com" ; creator's link

[options] ; exclude files from compression with such extension
exclude_exts = *.ncb,*.sln,*.vcproj,*.old,*.rc,*.scc,*.vssscc,*.bmp,*.exe,*.cmd,*.bat,*.db,*.xdb,*.bak*,*.bmp,*.smf,*.uvm,*.prj,*.tga,*.txt,*.rtf,*.doc,*.log,*.*~*,*~*.*,*.rar,*.sfk,*.tmp,*.xr

[include_folders]
.\ = true

[exclude_folders]
ai\ = true 
anims\ = true
config\ = true
configs\ = true
;levels\ = true
meshes\ = true 
scripts\ = true 
shaders\ = true
sounds\ = true 
spawns\ = true
textures\ = true
]]

local data_for_textures = [[
[header]
auto_load = true
level_name = single ; former level name, now can be mod name
level_ver = 1.0 ; former level version, now can be mod version
entry_point = $fs_root$\gamedata\ ; do not change !
creator = "Team EPIC" ; creator's name
link = "forum.epicstalker.com" ; creator's link

[options] ; exclude files from compression with such extension
exclude_exts = *.ncb,*.sln,*.vcproj,*.old,*.rc,*.scc,*.vssscc,*.bmp,*.exe,*.cmd,*.bat,*.db,*.xdb,*.bak*,*.bmp,*.smf,*.uvm,*.prj,*.tga,*.txt,*.rtf,*.doc,*.log,*.*~*,*~*.*,*.rar,*.sfk,*.tmp,*.xr,*.thm

[include_folders]
.\ = true

[exclude_folders]
ai\ = true 
anims\ = true
config\ = true
configs\ = true
levels\ = true
meshes\ = true 
scripts\ = true 
shaders\ = true
sounds\ = true 
spawns\ = true
;textures\ = true
]]

local data_for_thms = [[
[header]
auto_load = true
level_name = single ; former level name, now can be mod name
level_ver = 1.0 ; former level version, now can be mod version
entry_point = $fs_root$\gamedata\ ; do not change !
creator = "Team EPIC" ; creator's name
link = "forum.epicstalker.com" ; creator's link

[options] ; exclude files from compression with such extension
exclude_exts = *.ncb,*.sln,*.vcproj,*.old,*.rc,*.scc,*.vssscc,*.bmp,*.exe,*.cmd,*.bat,*.db,*.xdb,*.bak*,*.bmp,*.smf,*.uvm,*.prj,*.tga,*.txt,*.rtf,*.doc,*.log,*.*~*,*~*.*,*.rar,*.sfk,*.tmp,*.xr

[include_files]
]]
---------------------------------------------------------
-- 
-----------------------------------------------------------------
function OnApplicationBegin()
	Application.AddPluginButton("t_plugin_db_tool","UICoCDBToolShow",GetAndShow)
end

UI = nil
function Get()
	if not (UI) then 
		UI = cUICoCDBTool("1")
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

Class "cUICoCDBTool" (cUIBase)
function cUICoCDBTool:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUICoCDBTool:Reinit()
	self.inherited[1].Reinit(self)
	
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vUICoCDBToolTab|%t_unpacker^%t_repacker 1^%t_repacker 2^%t_repacker 3^%t_repacker 4^%t_repacker 5^%t_repacker 6^%t_repacker 7^%t_repacker 8^%t_repacker 9^%t_repacker 10")
	self:Gui("Tab|%t_unpacker")
		-- GroupBox
		self:Gui("Add|GroupBox|x10 y50 w510 h75|%t_input_path")
		self:Gui("Add|GroupBox|x10 y150 w510 h75|%t_output_path")
		
		self:Gui("Add|CheckBox|x200 y58 w120 h20 %s vUICoCDBToolBrowseRecur|%s",gSettings:GetValue("dbtool","check_browse_recur","") == "1" and "Checked" or "","%t_recursive")
		
		-- Buttons 
		self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vUICoCDBToolBrowseInputPath|...")
		self:Gui("Add|Button|gOnScriptControlAction x485 y180 w30 h20 vUICoCDBToolBrowseOutputPath|...")
		self:Gui("Add|Button|gOnScriptControlAction x485 y655 w201 h20 vUICoCDBToolSaveSettings0|%t_save_settings")	
		self:Gui("Add|Button|gOnScriptControlAction x485 y680 w201 h20 vUICoCDBToolExecute|%t_execute")		
		
		-- Editbox 
		self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vUICoCDBToolInputPath|")
		self:Gui("Add|Edit|gOnScriptControlAction x25 y180 w450 h20 vUICoCDBToolOutputPath|")
		
		self:Gui("Add|DropDownList|gOnScriptControlAction x550 y80 vUICoCDBToolDBToolListDbTypeUnpack Choose%s|xdb^2947ru", gSettings:GetValue("dbtool","unpack_db_type") == '2947ru' and 2 or 1)
		
	GuiControl(self.ID,"","UICoCDBToolInputPath", gSettings:GetValue("dbtool","unpack_input_path") or "")
	GuiControl(self.ID,"","UICoCDBToolOutputPath", gSettings:GetValue("dbtool","unpack_output_path") or "")
	
	for tab=1,10 do
		self:Gui("Tab|%t_repacker "..tab)
			-- GroupBox
			self:Gui("Add|GroupBox|x10 y50 w510 h75|%t_unpacked_gamedata_path")
			self:Gui("Add|GroupBox|x10 y150 w510 h75|%t_output_path")
			self:Gui("Add|GroupBox|x10 y230 w510 h275|%t_compress_options")
			
			y = 245
			local pack_db_type = gSettings:GetValue("dbtool","pack_db_type"..tab)
			pack_db_type = pack_db_type ~= '' and pack_db_type or 'xdb'
			-- table.sort(DBChecks)
			for i=1,#DBChecks do
				local folder_name = i == 3 and type_dbs[pack_db_type] or DBChecks[i]
				self:Gui("Add|CheckBox|x50 y%s w100 h22 %s vUICoCDBToolCheck_%s_%s|%s",y,gSettings:GetValue("dbtool",strformat('check_%s_%s',i,tab)) == "1" and "Checked" or "",i,tab,folder_name)
				y = y + 20
			end
			
			self:Gui("Add|CheckBox|x550 y200 w100 h22 %s vUICoCDBToolCheck_%s_no_compress|-no_compress",gSettings:GetValue("dbtool",strformat('check_%s_no_compress',tab)) == "1" and "Checked" or "",tab)
			self:Gui("Add|CheckBox|x550 y222 w100 h22 %s vUICoCDBToolCheck_%s_fast|-fast",gSettings:GetValue("dbtool",strformat('check_%s_fast',tab)) == "1" and "Checked" or "",tab)
			
			-- Buttons 
			self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vUICoCDBToolBrowseInputPath%s|...",tab)
			self:Gui("Add|Button|gOnScriptControlAction x485 y180 w30 h20 vUICoCDBToolBrowseOutputPath%s|...",tab)
			self:Gui("Add|Button|gOnScriptControlAction x485 y655 w201 h20 vUICoCDBToolSaveSettings%s|%t_save_settings",tab)
			self:Gui("Add|Button|gOnScriptControlAction x485 y680 w201 h20 vUICoCDBToolExecute%s|%t_execute",tab)
			
			-- Editbox 
			self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vUICoCDBToolInputPath%s|",tab)
			self:Gui("Add|Edit|gOnScriptControlAction x25 y180 w450 h20 vUICoCDBToolOutputPath%s|",tab)
			
			self:Gui("Add|DropDownList|gOnScriptControlAction x550 y80 vUICoCDBToolDBToolListDbTypePack%s Choose%s|xdb^2947ru", tab, pack_db_type == '2947ru' and 2 or 1)
			
			local level_list_str, texture_list_str = "none", "none"
			local i_p = gSettings:GetValue("dbtool","path"..tab) or ""
			if (i_p ~= "") then
				local function get_level_list(path,dir)
					level_list_str = level_list_str .. "^" .. dir
				end
				directory_for_each(i_p.."\\levels",get_level_list)
				local function get_texture_list(path,dir)
					texture_list_str = texture_list_str .. "^" .. dir
				end
				directory_for_each(i_p.."\\textures",get_texture_list)
			end
			self:Gui("Add|DropDownList|gOnScriptControlAction x550 y250 vUICoCDBToolDBToolListLevel%s Choose1|%s",tab,level_list_str)
			self:Gui("Add|DropDownList|gOnScriptControlAction x550 y270 vUICoCDBToolDBToolListTexture%s Choose1|%s",tab,texture_list_str)
		
		GuiControl(self.ID,"","UICoCDBToolInputPath"..tab, gSettings:GetValue("dbtool","path"..tab) or "")
		GuiControl(self.ID,"","UICoCDBToolOutputPath"..tab, gSettings:GetValue("dbtool","output_path"..tab) or "")
	end
	self:Gui("Show|w1024 h720|%t_plugin_db_tool")
end

function cUICoCDBTool:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUICoCDBTool:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self.inherited[1].OnScriptControlAction(self,hwnd,event,info)
	local tab = ahkGetVar("UICoCDBToolTab") or "1"
	
	if (tab == "1") then 
		if (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolBrowseInputPath")) then
			local dir = FileSelectFolder("*"..(gSettings:GetValue("dbtool","unpack_input_path") or ""))
			if (dir and dir ~= "") then
				GuiControl(self.ID,"","UICoCDBToolInputPath",dir)
			end
		elseif (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolBrowseOutputPath")) then 
			local dir = FileSelectFolder("*"..(gSettings:GetValue("dbtool","unpack_output_path") or ""))
			if (dir and dir ~= "") then
				GuiControl(self.ID,"","UICoCDBToolOutputPath",dir)
			end
		elseif (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolExecute")) then
			ActionUnpack()
		elseif (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolSaveSettings0")) then
			gSettings:SetValue("dbtool","check_browse_recur",ahkGetVar("UICoCDBToolBrowseRecur"))
			gSettings:SetValue("dbtool","unpack_input_path", ahkGetVar("UICoCDBToolInputPath"))
			gSettings:SetValue("dbtool","unpack_output_path", ahkGetVar("UICoCDBToolOutputPath"))
			gSettings:SetValue("dbtool","unpack_db_type", ahkGetVar("UICoCDBToolDBToolListDbTypeUnpack"))
			gSettings:Save()
		end
	else 
		tab = tostring(tonumber(tab) - 1)
		if (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolBrowseInputPath"..tab)) then
			local dir = FileSelectFolder("*"..(gSettings:GetValue("dbtool","path"..tab) or ""))
			if (dir and dir ~= "") then
				GuiControl(self.ID,"","UICoCDBToolInputPath"..tab,dir)
				
				local level_list_str, texture_list_str = "none", "none"
				local i_p = dir
				if (i_p ~= "") then
					local function get_level_list(path,dir)
						level_list_str = level_list_str .. "|" .. dir
					end
					directory_for_each(i_p.."\\levels",get_level_list)
					local function get_texture_list(path,dir)
						texture_list_str = texture_list_str .. "|" .. dir
					end
					directory_for_each(i_p.."\\textures",get_texture_list)
				end
			
				GuiControl(self.ID,"","UICoCDBToolDBToolListLevel"..tab, "|")
				GuiControl(self.ID,"","UICoCDBToolDBToolListTexture"..tab, "|")
				GuiControl(self.ID,"","UICoCDBToolDBToolListLevel"..tab, level_list_str)
				GuiControl(self.ID,"","UICoCDBToolDBToolListTexture"..tab, texture_list_str)
				GuiControl(self.ID,"Choose","UICoCDBToolDBToolListLevel"..tab, 1)
				GuiControl(self.ID,"Choose","UICoCDBToolDBToolListTexture"..tab, 1)
			end
		elseif (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolBrowseOutputPath"..tab)) then 
			local dir = FileSelectFolder("*"..(gSettings:GetValue("dbtool","output_path"..tab) or ""))
			if (dir and dir ~= "") then
				GuiControl(self.ID,"","UICoCDBToolOutputPath"..tab,dir)
			end
		elseif (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolDBToolListDbTypePack"..tab)) then
			GuiControl(self.ID,"",strformat('UICoCDBToolCheck_%s_%s',3,tab),type_dbs[ahkGetVar("UICoCDBToolDBToolListDbTypePack"..tab)])
		elseif (hwnd == GuiControlGet(self.ID,"hwnd","vUICoCDBToolDBToolListLevel"..tab)) then 
		
		elseif (hwnd == GuiControlGet(self.ID,"hwnd","vUICoCDBToolDBToolListTexture"..tab)) then  
		
		elseif (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolExecute"..tab)) then
			ActionSubmit(tab)
		elseif (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolSaveSettings"..tab)) then
			for i=1,#DBChecks do
				local bool = ahkGetVar("UICoCDBToolCheck_"..i..'_'..tab)
				gSettings:SetValue("dbtool",strformat('check_%s_%s',i,tab),bool)
			end
			gSettings:SetValue("dbtool","path"..tab,ahkGetVar("UICoCDBToolInputPath"..tab) or "")
			gSettings:SetValue("dbtool","output_path"..tab,ahkGetVar("UICoCDBToolOutputPath"..tab) or "")
			gSettings:SetValue("dbtool","pack_db_type"..tab, ahkGetVar("UICoCDBToolDBToolListDbTypePack"..tab))
			gSettings:Save()
		end
	end
end

local function check_out_folder(output_path)
	if not (directory_exists(output_path)) then
		-- Msg(strformat('DB Tool:= create %s', output_path))
		os.execute('MD "'..output_path..'"')
	end
end

local function remove_files(node,file,fullpath,name)
	if (name) then
		local fname = trim_ext(file)
		if (fname == name) then 
			Msg(strformat('DB Tool:= remove %s', fullpath))
			os.remove(fullpath)
			return
		end
		return
	end
	Msg(strformat('DB Tool:= remove %s', fullpath))
	os.remove(fullpath)		
end

local function remove_by_match(node,file,fullpath,name)
	if (string.find(file, name)) then
		Msg(strformat('DB Tool:= remove %s', fullpath))
		os.remove(fullpath)
	end
end

_INACTION = nil
function ActionSubmit(tab)
	if (_INACTION) then 
		MsgBox("Already performing an action")
		return 
	end 
	
	local input_path = ahkGetVar("UICoCDBToolInputPath"..tab)
	if (input_path == nil or input_path == "") then 
		MsgBox("Incorrect Path!")
		return 
	end 
	
	local output_path = ahkGetVar("UICoCDBToolOutputPath"..tab)
	if (output_path == nil or output_path == "") then 
		MsgBox("Incorrect Output Path!")
		return 
	end 	
	
	_INACTION = true
	
	-- self:OnScriptControlAction(GuiControlGet(self.ID,"hwnd","UICoCDBToolSaveSettings"..tab),'Normal',0)
	for i=1,#DBChecks do
		local bool = ahkGetVar("UICoCDBToolCheck_"..i..'_'..tab)
		gSettings:SetValue("dbtool",strformat('check_%s_%s',i,tab),bool)
	end
	gSettings:SetValue("dbtool",strformat('check_%s_no_compress',tab),ahkGetVar("UICoCDBToolCheck_"..tab.."_no_compress"))
	gSettings:SetValue("dbtool",strformat('check_%s_fast',tab),ahkGetVar("UICoCDBToolCheck_"..tab.."_fast"))
	gSettings:SetValue("dbtool","path"..tab,input_path)
	gSettings:SetValue("dbtool","output_path"..tab,output_path)
	gSettings:SetValue("dbtool","pack_db_type"..tab, ahkGetVar("UICoCDBToolDBToolListDbTypePack"..tab))
	gSettings:Save()
	
	check_out_folder(output_path)
	Sleep(1000)
	
	local config_dir = ahkGetVar("A_WorkingDir")..strformat([[\configs\compress\%s\]], ahkGetVar("UICoCDBToolDBToolListDbTypePack"..tab))
	local working_directory = ahkGetVar("A_WorkingDir")..[[\bin\]]
	local cp = working_directory.."xrCompress.exe"
	local dir = trim_directory(input_path)
	local parent_dir = get_path(input_path)
	local check_clear_out, level_directories, texture_directories = {}, {}, {}
	outdir[type_dbs[ahkGetVar("UICoCDBToolDBToolListDbTypePack"..tab)]] = "configs"
	
	local single_level_select = ahkGetVar("UICoCDBToolDBToolListLevel"..tab)
	local single_texture_select = ahkGetVar("UICoCDBToolDBToolListTexture"..tab)
	
	Msg("DB Tool:= working...")
	
	-- create compress_*.ltx for levels
	if (gSettings:GetValue("dbtool",'check_8_'..tab) == "1") then
		file_for_each(config_dir, {"ltx"}, remove_by_match, true, 'compress_levels_')
		Sleep(1000)
		local function generate_level_options1(path,dir)
			level_directories[dir] = true
		end
		directory_for_each(input_path.."\\levels",generate_level_options1)
		local function generate_level_options2(dir)
			local data = data_for_levels
			
			for k,v in pairs(level_directories) do 
				if (k ~= dir) then
					data = data .. "\nlevels\\" .. k .. "\\ = true"
				end
			end
			local output_file = io.open(config_dir.."compress_levels_"..dir..".ltx","wb+")
			if (output_file) then
				output_file:write(data)
				output_file:close()
			end	
		end
		for k,v in pairs(level_directories) do 
			generate_level_options2(k)
		end
	end
	
	-- create compress_*.ltx for textures
	if (gSettings:GetValue("dbtool",'check_10_'..tab) == "1") then
		file_for_each(config_dir, {"ltx"}, remove_by_match, true, 'compress_textures_')
		Sleep(1000)
		local ignore_list_data = ""
		local i_o = input_path.."\\"
		local function generate_ignore_list(node,file,fullpath)
			local relative_file_path = trim(string.sub(node,i_o:len()+1)) .. "\\" .. file
			ignore_list_data = ignore_list_data .. relative_file_path .. "\n"
		end
		file_for_each(input_path.."\\textures", {"dds","ogm","seq"}, generate_ignore_list, true)
		local function generate_texture_options1(path,dir)
			texture_directories[dir] = true
		end
		directory_for_each(input_path.."\\textures",generate_texture_options1)
		local function generate_texture_options2(dir)
			local data = data_for_textures
			for k,v in pairs(texture_directories) do 
				if (k ~= dir) then
					data = data .. "\ntextures\\" .. k .. "\\ = true"
				end
			end
			
			data = data .. "\n[exclude_files]\n" .. ignore_list_data
			
			local output_file = io.open(config_dir.."compress_textures_"..dir..".ltx","wb+")
			if (output_file) then
				output_file:write(data)
				output_file:close()
			end
		end
		for k,v in pairs(texture_directories) do 
			generate_texture_options2(k)
		end
		
		-- for base directory
		local data = data_for_textures
		for k,v in pairs(texture_directories) do 
			data = data .. "\ntextures\\" .. k .. "\\ = true"
		end
		
		data = data .. "\n[include_files]\n" .. ignore_list_data
		
		local output_file = io.open(config_dir.."compress_textures.ltx","wb+")
		if (output_file) then
			output_file:write(data)
			output_file:close()
		end
	end
	
	-- create compress_*.ltx for thms
	if (gSettings:GetValue("dbtool",'check_12_'..tab) == "1") then
		file_for_each(config_dir, {"ltx"}, remove_by_match, true, 'compress_thms')
		Sleep(1000)
		
		local i_o = input_path.."\\"
		local function generate_thm_file_list(node,file,fullpath)
			local relative_file_path = trim(string.sub(node,i_o:len()+1)) .. "\\" .. file
			data_for_thms = data_for_thms .. relative_file_path .. "\n"
		end
		
		file_for_each(input_path.."\\textures", {"thm"}, generate_thm_file_list)

		local output_file,err = io.open(config_dir.."compress_thms.ltx","wb+")
		if not (err) then
			output_file:write(data_for_thms)
			output_file:close()
		end
	end
	
	_G.lfs_ignore_exact_ext_match = true
	-- ???
	file_for_each(parent_dir, {"db"}, remove_files, true)
	Sleep(1000)
	
	local function create_output(name,out, pack_levels)
		local pltx = pack_levels and "compress_levels_"..name..".ltx" or "compress_"..name..".ltx"
		--local nocompress = pack_levels and (ahkGetVar("UICoCDBToolDBToolListDbTypePack"..tab) == '2947ru') and '-nocompress' or ''	-- It required for levels SoC ??
		local nocompress = gSettings:GetValue("dbtool",'check_'..tab.."_no_compress") == "1" and "-nocompress" or ""
		local fast = gSettings:GetValue("dbtool",'check_'..tab.."_fast") == "1" and "-fast" or ""
		local cmdline = strformat([["%s" "%s" -ltx %s %s %s]],cp,input_path,pltx,nocompress,fast)
		Msg(strformat('DB Tool:= Start compression for structure %s %s\ncmdline: %s', ahkGetVar("UICoCDBToolDBToolListDbTypePack"..tab), name, cmdline))
		local function temp_move(_in, _out)
			if (ahkGetVar("UICoCDBToolDBToolListDbTypePack"..tab) == '2947ru') and (name ~= 'config') then
				local collect = {'game.graph', 'resource.h', 'stalkergame.inf'}
				for k, v in pairs(collect) do
					os.rename(strformat('%s\\%s', _in, v), strformat('%s\\%s', _out, v))
					Sleep(1000)
					os.remove(strformat('%s\\%s', _in, v))
				end
			end
		end
		temp_move(input_path, config_dir)	-- stupid hack for structure SoC, because stupid xrCompressor
		RunWait(cmdline, config_dir)
		temp_move(config_dir, input_path)
		Msg('\n')

		lfs.mkdir(out)
		
 		if not check_clear_out[name] then
			_G.lfs_ignore_exact_ext_match = true
			-- ???
			file_for_each(out, {"db"}, remove_files, true, name, pack_levels)
			check_clear_out[name] = true
			Sleep(1000)
		end
		
		local db_id = 0
		local function rename_pack_in_db(node,file,fullpath)
			os.rename(fullpath, ahkGetVar("UICoCDBToolDBToolListDbTypePack"..tab) == '2947ru' and strformat('%s\\%s%s.xdb', out, name, db_id) or strformat('%s\\%s.db%s', out, name, db_id))
			db_id = db_id + 1
		end
		if (file_exists(parent_dir.."\\"..dir..".db1") or file_exists(parent_dir.."\\"..dir..".pack_#1")) then
			_G.lfs_ignore_exact_ext_match = true
			file_for_each(parent_dir, {"db","pack_#"}, rename_pack_in_db, true)
		else
			os.rename(strformat('%s\\%s.db0', parent_dir, dir), ahkGetVar("UICoCDBToolDBToolListDbTypePack"..tab) == '2947ru' and strformat('%s\\%s.xdb', out, name) or strformat('%s\\%s.db', out, name))
			os.rename(strformat('%s\\%s.pack_#0', parent_dir, dir), ahkGetVar("UICoCDBToolDBToolListDbTypePack"..tab) == '2947ru' and strformat('%s\\%s.xdb', out, name) or strformat('%s\\%s.db', out, name))
		end
	end 
	
	for i=1,#DBChecks do
		local chk = gSettings:GetValue("dbtool",strformat('check_%s_%s',i,tab))
		if (chk == nil or chk == "1") then
			if i == 8 then
				if (single_level_select and level_directories[single_level_select]) then 
					create_output(single_level_select,output_path.."\\maps",true)
				else
					for k,v in spairs(level_directories) do 
						create_output(k,output_path.."\\maps",true)
					end
				end
			elseif (i == 10) then
				create_output("textures",output_path.."\\resources")
				if (single_texture_select and texture_directories[single_texture_select]) then 
					create_output("textures_"..single_texture_select,output_path.."\\resources")
				else
					for k,v in spairs(texture_directories) do
						create_output("textures_"..k,output_path.."\\resources")
					end
				end
			else
				local folder_name = i == 3 and type_dbs[ahkGetVar("UICoCDBToolDBToolListDbTypePack"..tab)] or DBChecks[i]
				create_output(folder_name,outdir[folder_name] and output_path.."\\"..outdir[folder_name] or output_path)
			end
		end
	end
	
	Sleep(2000)
	file_for_each(config_dir, {"ltx"}, remove_by_match, true, 'compress_levels_')
	Sleep(1000)
	
	Msg("DB Tool:= Finished!")
	
	_INACTION = false
end

function ActionUnpack()
	if (_INACTION) then 
		MsgBox("Already performing an action")
		return 
	end 
	
	local input_path = ahkGetVar("UICoCDBToolInputPath")
	if (input_path == nil or input_path == "") then 
		MsgBox("Incorrect Path!")
		return 
	end 
	
	local output_path = ahkGetVar("UICoCDBToolOutputPath")
	if (output_path == nil or output_path == "") then 
		MsgBox("Incorrect Output Path!")
		return 
	end 	
	
	_INACTION = true
	
	gSettings:SetValue("dbtool","check_browse_recur",ahkGetVar("UICoCDBToolBrowseRecur"))
	gSettings:SetValue("dbtool","unpack_input_path",input_path)
	gSettings:SetValue("dbtool","unpack_output_path",output_path)
	gSettings:SetValue("dbtool","unpack_db_type", ahkGetVar("UICoCDBToolDBToolListDbTypeUnpack"))
	gSettings:Save()
	
	check_out_folder(output_path)
	
	local working_directory = ahkGetVar("A_WorkingDir")..[[\bin\]]
	local cp = working_directory .. "converter.exe"
	local type_unpack_dbs = ahkGetVar("UICoCDBToolDBToolListDbTypeUnpack")
	local patches = {}
	
	Msg("DB Tool:= Unpacking...")
	
	local function on_execute(path,fname,fullpath)
		if (string.find(fname,"patch")) then -- do patches last!
			patches[#patches + 1] = path.."\\"..fname
		else
			-- Run(target,working_directory)
			-- converter.exe -unpack -xdb %%f -dir .\unpacked
			Msg("Unpacking %s",fname)
			RunWait( strformat([["%s" -unpack -%s "%s" -dir "%s"]],cp,type_unpack_dbs,path.."\\"..fname,output_path), working_directory )
		end
	end 
	
	_G.lfs_ignore_exact_ext_match = true
	-- ???
	if (input_path:sub(-3) == ".db" or string.find(input_path:sub(-4),".db")) then
		on_execute(get_path(input_path),trim_directory(input_path),input_path)
	else
		file_for_each(input_path,{"db"},on_execute,ahkGetVar("UICoCDBToolBrowseRecur") ~= "1")
	end
	
	table.sort(patches)
	for i=1,#patches do
		Msg("Unpacking %s", trim_directory(patches[i]))
		RunWait( strformat([["%s" -unpack -%s "%s" -dir "%s"]],cp,type_unpack_dbs,patches[i],output_path), working_directory )
	end
	
	Msg("DB Tool:= Unpacking Finished!")
	
	_INACTION = false
end
