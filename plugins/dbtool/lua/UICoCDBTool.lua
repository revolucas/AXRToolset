local DBChecks = {"ai","anims","configs","scripts","xr","shaders","spawns","levels","sounds","textures","meshes"}

UICoCDBToolWnd = nil
function OnApplicationBegin()
	UIMainMenuWnd:AddPluginButton("DB Tool","UICoCDBToolShow",GetAndShow)
end

function Get()
	if not (UICoCDBToolWnd) then 
		UICoCDBToolWnd = cUICoCDBTool("1")
		UICoCDBToolWnd.parent = UIMainMenuWnd
	end 
	return UICoCDBToolWnd
end

function GetAndShow()
	Get():Show(true)
end

cUICoCDBTool = Class{__includes={cUIBase}}
function cUICoCDBTool:init(id)
	cUIBase.init(self,id)
end

function cUICoCDBTool:Reinit()
	cUIBase.Reinit(self)
	
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vUICoCDBToolTab|Unpacker^Repacker 1^Repacker 2^Repacker 3^Repacker 4^Repacker 5^Repacker 6^Repacker 7^Repacker 8^Repacker 9^Repacker 10")
	self:Gui("Tab|Unpacker")
		-- GroupBox
		self:Gui("Add|GroupBox|x10 y50 w510 h75|Input Path (Recursive)")
		self:Gui("Add|GroupBox|x10 y150 w510 h75|Output Path")
		
		-- Buttons 
		self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vUICoCDBToolBrowseInputPath|...")
		self:Gui("Add|Button|gOnScriptControlAction x485 y180 w30 h20 vUICoCDBToolBrowseOutputPath|...")
		self:Gui("Add|Button|gOnScriptControlAction x485 y680 w90 h20 vUICoCDBToolExecute|Unpack")		
		
		-- Editbox 
		self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vUICoCDBToolInputPath|")
		self:Gui("Add|Edit|gOnScriptControlAction x25 y180 w450 h20 vUICoCDBToolOutputPath|")
		
	GuiControl(self.ID,"","UICoCDBToolInputPath", gSettings:GetValue("dbtool","unpack_input_path") or "")
	GuiControl(self.ID,"","UICoCDBToolOutputPath", gSettings:GetValue("dbtool","unpack_output_path") or "")
	
	for n=1,10 do
		self:Gui("Tab|Repacker "..n)
			-- GroupBox
			self:Gui("Add|GroupBox|x10 y50 w510 h75|Unpacked Gamedata")
			self:Gui("Add|GroupBox|x10 y150 w510 h75|Output Path")
			self:Gui("Add|GroupBox|x10 y230 w510 h275|Compress Options")
			
			y = 245
			table.sort(DBChecks)
			for i=1,#DBChecks do
				self:Gui("Add|CheckBox|x50 y%s w100 h22 %s vUICoCDBToolCheck%s%s|%s",y,gSettings:GetValue("dbtool","check_"..DBChecks[i]..n) == "1" and "Checked" or "",DBChecks[i],n,DBChecks[i])
				y = y + 20
			end
			
			-- Buttons 
			self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vUICoCDBToolBrowseInputPath%s|...",n)
			self:Gui("Add|Button|gOnScriptControlAction x485 y180 w30 h20 vUICoCDBToolBrowseOutputPath%s|...",n)
			self:Gui("Add|Button|gOnScriptControlAction x485 y680 w90 h20 vUICoCDBToolExecute%s|Make DBs",n)
			
			-- Editbox 
			self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vUICoCDBToolInputPath%s|",n)
			self:Gui("Add|Edit|gOnScriptControlAction x25 y180 w450 h20 vUICoCDBToolOutputPath%s|",n)
		
		GuiControl(self.ID,"","UICoCDBToolInputPath"..n, gSettings:GetValue("dbtool","path"..n) or "")
		GuiControl(self.ID,"","UICoCDBToolOutputPath"..n, gSettings:GetValue("dbtool","output_path"..n) or "")
	end
	self:Gui("Show|w1024 h720|DB Tool")
end

function cUICoCDBTool:OnGuiClose(idx) -- needed because it's registered to callback
	cUIBase.OnGuiClose(self,idx)
end 

function cUICoCDBTool:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("UICoCDBToolTab") or "1"
	
	if (tab == "1") then 
		if (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolBrowseInputPath")) then
			local dir = FileSelectFolder("*"..(gSettings:GetValue("dbtool","unpack_input_path") or ""))
			GuiControl(self.ID,"","UICoCDBToolInputPath",dir)
		elseif (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolBrowseOutputPath")) then 
			local dir = FileSelectFolder("*"..(gSettings:GetValue("dbtool","unpack_output_path") or ""))
			GuiControl(self.ID,"","UICoCDBToolOutputPath",dir)
		elseif (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolExecute")) then
			self:Gui("Submit|NoHide")
			ActionUnpack()
		end
	else 
		tab = tostring(tonumber(tab) - 1)
		if (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolBrowseInputPath"..tab)) then
			local dir = FileSelectFolder("*"..(gSettings:GetValue("dbtool","path") or ""))
			GuiControl(self.ID,"","UICoCDBToolInputPath",dir)
		elseif (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolBrowseOutputPath"..tab)) then 
			local dir = FileSelectFolder("*"..(gSettings:GetValue("dbtool","output_path") or ""))
			GuiControl(self.ID,"","UICoCDBToolOutputPath",dir)
		elseif (hwnd == GuiControlGet(self.ID,"hwnd","UICoCDBToolExecute"..tab)) then
			self:Gui("Submit|NoHide")
			ActionSubmit(tab)
		end
	end
end

_INACTION = nil
function ActionSubmit(tab)
	if (_INACTION) then 
		MsgBox("Already performing an action")
		return 
	end 
	
	_INACTION = true
	
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
	
	for i=1,#DBChecks do 
		local bool = ahkGetVar("UICoCDBToolCheck"..DBChecks[i]..tab)
		gSettings:SetValue("dbtool","check_"..DBChecks[i]..tab,bool)
	end 
	
	gSettings:SetValue("dbtool","path"..tab,input_path)
	gSettings:SetValue("dbtool","output_path"..tab,output_path)
	gSettings:Save()
		
	local working_directory = ahkGetVar("A_WorkingDir")..[[\plugins\dbtool\bin\]]
	local cp = working_directory.."xrCompress.exe"
	local dir = trim_directory(input_path)
	local parent_dir = get_path(input_path)
	
	Msg("DB Tool:= working...")
	
	local compress = {"ai","anims","configs","scripts","xr","shaders","spawns"}
	
	-- create compress_*.ltx for levels
	local level_directories = {}
	local function generate_level_options(path,dir)
		local data = strformat([[
[header]
auto_load = true
level_name = single ; former level name, now can be mod name
level_ver = 1.0 ; former level version, now can be mod version
entry_point = $fs_root$\gamedata\ ; do not change !
creator = "Team EPIC" ; creator's name
link = "forum.epicstalker.com" ; creator's link

[options] ; exclude files from compression with such extension
exclude_exts = *.ncb,*.sln,*.vcproj,*.old,*.rc,*.scc,*.vssscc,*.bmp,*.exe,*.db,*.bak*,*.bmp,*.smf,*.uvm,*.prj,*.tga,*.txt,*.rtf,*.doc,*.log,*.~*,*.rar,*.sfk

[include_folders]
levels\%s = true

[exclude_folders]
textures = true
ai = true
anims = true
configs = true
;levels = true
meshes = true
scripts = true
shaders = true
sounds = true
spawns = true
]],dir)
		local output_file = io.open(working_directory.."compress_levels_"..dir..".ltx","wb+")
		if (output_file) then
			output_file:write(data)
			output_file:close()
			level_directories[dir] = true
		end
	end 

	
	-- create compress_*.ltx for textures
	local texture_directories = {}
	local function generate_textures_options(path,dir)
		local data = strformat([[
[header]
auto_load = true
level_name = single ; former level name, now can be mod name
level_ver = 1.0 ; former level version, now can be mod version
entry_point = $fs_root$\gamedata\ ; do not change !
creator = "Team EPIC" ; creator's name
link = "forum.epicstalker.com" ; creator's link

[options] ; exclude files from compression with such extension
exclude_exts = *.ncb,*.sln,*.vcproj,*.old,*.rc,*.scc,*.vssscc,*.bmp,*.exe,*.db,*.bak*,*.bmp,*.smf,*.uvm,*.prj,*.tga,*.txt,*.rtf,*.doc,*.log,*.~*,*.rar,*.sfk

[include_folders]
textures\%s = true

[exclude_folders]
;textures = true
ai = true
anims = true
configs = true
levels = true
meshes = true
scripts = true
shaders = true
sounds = true
spawns = true
]],dir)
		local output_file = io.open(working_directory.."compress_textures_"..dir..".ltx","wb+")
		if (output_file) then
			output_file:write(data)
			output_file:close()
			texture_directories[dir] = true
		end
	end 
	
	
	-- create compress_*.ltx for sounds
	local sounds_directories = {}
	local function generate_sounds_options(path,dir)
		local data = strformat([[
[header]
auto_load = true
level_name = single ; former level name, now can be mod name
level_ver = 1.0 ; former level version, now can be mod version
entry_point = $fs_root$\gamedata\ ; do not change !
creator = "Team EPIC" ; creator's name
link = "forum.epicstalker.com" ; creator's link

[options] ; exclude files from compression with such extension
exclude_exts = *.ncb,*.sln,*.vcproj,*.old,*.rc,*.scc,*.vssscc,*.bmp,*.exe,*.db,*.bak*,*.bmp,*.smf,*.uvm,*.prj,*.tga,*.txt,*.rtf,*.doc,*.log,*.~*,*.rar,*.sfk

[include_folders]
sounds\%s = true

[exclude_folders]
textures = true
ai = true
anims = true
configs = true
levels = true
meshes = true
scripts = true
shaders = true
;sounds = true
spawns = true
]],dir)
		local output_file = io.open(working_directory.."compress_sounds_"..dir..".ltx","wb+")
		if (output_file) then
			output_file:write(data)
			output_file:close()
			sounds_directories[dir] = true
		end
	end 
	
	local meshes_directories = {}
	-- create compress_*.ltx for textures
	local function generate_meshes_options(path,dir)
		local data = strformat([[
[header]
auto_load = true
level_name = single ; former level name, now can be mod name
level_ver = 1.0 ; former level version, now can be mod version
entry_point = $fs_root$\gamedata\ ; do not change !
creator = "Team EPIC" ; creator's name
link = "forum.epicstalker.com" ; creator's link

[options] ; exclude files from compression with such extension
exclude_exts = *.ncb,*.sln,*.vcproj,*.old,*.rc,*.scc,*.vssscc,*.bmp,*.exe,*.db,*.bak*,*.bmp,*.smf,*.uvm,*.prj,*.tga,*.txt,*.rtf,*.doc,*.log,*.~*,*.rar,*.sfk

[include_folders]
meshes\%s = true

[exclude_folders]
textures = true
ai = true
anims = true
configs = true
levels = true
;meshes = true
scripts = true
shaders = true
sounds = true
spawns = true
]],dir)
		local output_file = io.open(working_directory.."compress_meshes_"..dir..".ltx","wb+")
		if (output_file) then
			output_file:write(data)
			output_file:close()
			meshes_directories[dir] = true
		end
	end 
	
	if (gSettings:GetValue("dbtool","check_levels"..tab) == "1") then
		directory_for_each(input_path.."\\levels",generate_level_options)
	end
	
	if (gSettings:GetValue("dbtool","check_textures"..tab) == "1") then
		directory_for_each(input_path.."\\textures",generate_textures_options)
		local data = [[
[header]
auto_load = true
level_name = single ; former level name, now can be mod name
level_ver = 1.0 ; former level version, now can be mod version
entry_point = $fs_root$\gamedata\ ; do not change !
creator = "Team EPIC" ; creator's name
link = "forum.epicstalker.com" ; creator's link

[options] ; exclude files from compression with such extension
exclude_exts = *.ncb,*.sln,*.vcproj,*.old,*.rc,*.scc,*.vssscc,*.bmp,*.exe,*.db,*.bak*,*.bmp,*.smf,*.uvm,*.prj,*.tga,*.txt,*.rtf,*.doc,*.log,*.~*,*.rar,*.sfk

[include_folders]
textures = true

[exclude_folders]
;textures = true
ai = true
anims = true
configs = true
levels = true
meshes = true
scripts = true
shaders = true
sounds = true
spawns = true
]]
		for k,v in pairs(texture_directories) do 
			data = data .. "\ntextures\\" .. k .. " = true"
		end

		local output_file = io.open(working_directory.."compress_textures_default.ltx","wb+")
		if (output_file) then
			output_file:write(data)
			output_file:close()
			texture_directories["textures_default"] = true
		end
	end

	if (gSettings:GetValue("dbtool","check_sounds"..tab) == "1") then
		directory_for_each(input_path.."\\sounds",generate_sounds_options)
		local data = [[
[header]
auto_load = true
level_name = single ; former level name, now can be mod name
level_ver = 1.0 ; former level version, now can be mod version
entry_point = $fs_root$\gamedata\ ; do not change !
creator = "Team EPIC" ; creator's name
link = "forum.epicstalker.com" ; creator's link

[options] ; exclude files from compression with such extension
exclude_exts = *.ncb,*.sln,*.vcproj,*.old,*.rc,*.scc,*.vssscc,*.bmp,*.exe,*.db,*.bak*,*.bmp,*.smf,*.uvm,*.prj,*.tga,*.txt,*.rtf,*.doc,*.log,*.~*,*.rar,*.sfk

[include_folders]
sounds = true

[exclude_folders]
ai = true
anims = true
configs = true
levels = true
meshes = true
scripts = true
shaders = true
;sounds = true
spawns = true
textures = true
]]
		for k,v in pairs(sounds_directories) do 
			data = data .. "\nsounds\\" .. k .. " = true"
		end

		local output_file = io.open(working_directory.."compress_sounds_default.ltx","wb+")
		if (output_file) then
			output_file:write(data)
			output_file:close()
			sounds_directories["sounds_default"] = true
		end
	end
	
	if (gSettings:GetValue("dbtool","check_meshes"..tab) == "1") then
		directory_for_each(input_path.."\\meshes",generate_meshes_options)
		local data = [[
[header]
auto_load = true
level_name = single ; former level name, now can be mod name
level_ver = 1.0 ; former level version, now can be mod version
entry_point = $fs_root$\gamedata\ ; do not change !
creator = "Team EPIC" ; creator's name
link = "forum.epicstalker.com" ; creator's link

[options] ; exclude files from compression with such extension
exclude_exts = *.ncb,*.sln,*.vcproj,*.old,*.rc,*.scc,*.vssscc,*.bmp,*.exe,*.db,*.bak*,*.bmp,*.smf,*.uvm,*.prj,*.tga,*.txt,*.rtf,*.doc,*.log,*.~*,*.rar,*.sfk

[include_folders]
meshes = true

[exclude_folders]
ai = true
anims = true
configs = true
levels = true
;meshes = true
scripts = true
shaders = true
sounds = true
spawns = true
textures = true
]]
		for k,v in pairs(meshes_directories) do 
			data = data .. "\nmeshes\\" .. k .. " = true"
		end

		local output_file = io.open(working_directory.."compress_meshes_default.ltx","wb+")
		if (output_file) then
			output_file:write(data)
			output_file:close()
			meshes_directories["meshes_default"] = true
		end
	end
	
	local outdir = {	
		["ai"] = "config",
		["anims"] = "config",
		["scripts"] = "config",
		["xr"] = "config",
		["configs"] = "config",
		["spawns"] = "config",
		["shaders"] = "config",
		["meshes"] = "resource",
		["meshes_default"] = "resource",
		["sounds"] = "sound",
		["sounds_default"] = "sound",
		["textures"] = "resource",
		["textures_default"] = "resource"
	}
	
	os.remove(parent_dir.."\\"..dir..".pack_#0")
	os.remove(parent_dir.."\\"..dir..".pack_#1")
	os.remove(parent_dir.."\\"..dir..".pack_#2")
	os.remove(parent_dir.."\\"..dir..".pack_#3")
	os.remove(parent_dir.."\\"..dir..".pack_#4")
	os.remove(parent_dir.."\\"..dir..".pack_#5")
	os.remove(parent_dir.."\\"..dir..".pack_#6")
	os.remove(parent_dir.."\\"..dir..".pack_#7")
	os.remove(parent_dir.."\\"..dir..".pack_#8")
				
				
	local function create_output(name,fname,out,prefix)
	
		local pltx = prefix and "compress_"..prefix.."_"..name..".ltx" or "compress_"..name..".ltx"
		
		RunWait( strformat([["%s" "%s" -ltx %s]],cp,input_path,pltx), working_directory )

		lfs.mkdir(out)
		
		os.remove(out.."\\"..fname..".db")
		os.remove(out.."\\"..fname..".db0")
		os.remove(out.."\\"..fname..".db1")
		os.remove(out.."\\"..fname..".db2")
		os.remove(out.."\\"..fname..".db3")
		os.remove(out.."\\"..fname..".db4")
		os.remove(out.."\\"..fname..".db5")
		os.remove(out.."\\"..fname..".db6")
		os.remove(out.."\\"..fname..".db7")
		os.remove(out.."\\"..fname..".db8")

		if (file_exists(parent_dir.."\\"..dir..".pack_#1")) then
			os.rename(parent_dir.."\\"..dir..".pack_#0",out.."\\"..fname..".db0")
			os.rename(parent_dir.."\\"..dir..".pack_#1",out.."\\"..fname..".db1")
			os.rename(parent_dir.."\\"..dir..".pack_#2",out.."\\"..fname..".db2")
			os.rename(parent_dir.."\\"..dir..".pack_#3",out.."\\"..fname..".db3")
			os.rename(parent_dir.."\\"..dir..".pack_#4",out.."\\"..fname..".db4")
			os.rename(parent_dir.."\\"..dir..".pack_#5",out.."\\"..fname..".db5")
			os.rename(parent_dir.."\\"..dir..".pack_#6",out.."\\"..fname..".db6")
			os.rename(parent_dir.."\\"..dir..".pack_#7",out.."\\"..fname..".db7")
			os.rename(parent_dir.."\\"..dir..".pack_#8",out.."\\"..fname..".db8")
		else
			os.rename(parent_dir.."\\"..dir..".pack_#0",out.."\\"..fname..".db")
		end
	end 
	
	for i=1,#compress do 
		local chk = gSettings:GetValue("dbtool","check_"..compress[i]..tab)
		if (chk == nil or chk == "1") then
			create_output(compress[i],compress[i],outdir[compress[i]] and output_path.."\\"..outdir[compress[i]] or output_path)
		end
	end
	
	if (gSettings:GetValue("dbtool","check_meshes"..tab) == "1") then
		for k,v in pairs(meshes_directories) do 
			create_output(k,"meshes_"..k,output_path.."\\resource","meshes")
		end
	end
	
	if (gSettings:GetValue("dbtool","check_sounds"..tab) == "1") then
		for k,v in pairs(sounds_directories) do 
			create_output(k,"sounds_"..k,output_path.."\\sound","sounds")
		end 
	end
	
	if (gSettings:GetValue("dbtool","check_textures"..tab) == "1") then
		for k,v in pairs(texture_directories) do 
			create_output(k,"textures_"..k,output_path.."\\resource","textures")
		end 
	end
	
	if (gSettings:GetValue("dbtool","check_levels"..tab) == "1") then
		for k,v in pairs(level_directories) do 
			create_output(k,k,output_path.."\\maps","levels")
		end
	end
	
	Msg("DB Tool:= Finished!")
	
	_INACTION = false
end


function ActionUnpack()
	if (_INACTION) then 
		MsgBox("Already performing an action")
		return 
	end 
	
	_INACTION = true
	
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
	
	gSettings:SetValue("dbtool","unpack_input_path",input_path)
	gSettings:SetValue("dbtool","unpack_output_path",output_path)
	gSettings:Save()
		
	local working_directory = ahkGetVar("A_WorkingDir")..[[\plugins\dbtool\bin\]]
	local cp = working_directory .. "converter.exe"
	
	local patches = {}
	local function on_execute(path,fname)
		--Msg("%s\\%s",path,fname)
		if (string.find(fname,"patch")) then -- do patches last!
			table.insert(patches,path.."\\"..fname)
		else
			-- Run(target,working_directory)
			-- converter.exe -unpack -xdb %%f -dir .\unpacked
			RunWait( strformat([["%s" -unpack -xdb "%s" -dir "%s"]],cp,path.."\\"..fname,output_path), working_directory )
			Msg("unpacked %s",fname)
		end
	end 
	
	Msg("DB Tool:= Unpacking...")
	
	recurse_subdirectories_and_execute(input_path,{"db","db0","db1","db2","db3","db4","db5","db6","db7","db8","db9","db10"},on_execute)
	
	for i=1,#patches do 
		RunWait( strformat([["%s" -unpack -xdb "%s" -dir "%s"]],cp,patches[i],output_path), working_directory )
		Msg("unpacked %s", trim_directory(patches[i]))
	end
	
	Msg("DB Tool:= Unpacking Finished!")
	
	_INACTION = false
end
