local Checks = {}

-----------------------------------------------------------------
--
-----------------------------------------------------------------
function OnApplicationBegin()
	Application.AddPluginButton("t_plugin_image_magick","ImageMagickShow",GetAndShow)
end
---------------------------------------------------------------------------
UI = nil
function Get()
	if not (UI) then 
		UI = cImageMagick("1")
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

Class "cImageMagick" (cUIBase)
function cImageMagick:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cImageMagick:Reinit()
	self.inherited[1].Reinit(self)
	
	local tabs = {Language.translate("t_directory"),Language.translate("t_single_files")}
	Checks["1"] = {"t_copy_thm","t_only_with_mipmaps"}
	Checks["2"] = {"t_copy_thm"}
	
	-- below will be automated based on above tab definition and checks
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vImageMagickTab|%s",table.concat(tabs,"^"))
	
	for i=1,#tabs do
		local i_s = tostring(i)
		
		self:Gui("Tab|%s",tabs[i])
			self:Gui("Add|Text|x270 y365 w300 h40 cBlue vImageMagickLink2%s gOnScriptControlAction|%t_click_for_tut",i)
			self:Gui("Add|Text|x555 y75 w300 h40 cBlue vImageMagickLink%s gOnScriptControlAction|1. %t_command_line_tut",i)
			self:Gui("Add|Text|x555 y120 w300 h40|2. %t_image_magic_tut",i)
			self:Gui("Add|Text|x555 y175 w300 h40|3. %t_image_magic_cons")
			-- GroupBox
			self:Gui("Add|GroupBox|x10 y50 w510 h75|%s",i==1 and "%t_input_path" or "%t_single_files")
			self:Gui("Add|GroupBox|x10 y150 w510 h75|%t_output_path (%t_optional)")
			self:Gui("Add|GroupBox|x10 y250 w510 h75|%t_command_line_options")
			self:Gui("Add|GroupBox|x10 y350 w510 h75|%t_pattern_matching")
			self:Gui("Add|GroupBox|x550 y50 w450 h275|")
			
			if (Checks[i_s]) then
				local y = 445
				--table.sort(Checks[i_s])
				for n=1,#Checks[i_s] do
					self:Gui("Add|CheckBox|x50 y%s w250 h22 %s vImageMagickCheck%s%s|%s",y,gSettings:GetValue("ImageMagick","check_"..Checks[i_s][n]..i_s,"") == "1" and "Checked" or "",Checks[i_s][n],i_s,Language.translate(Checks[i_s][n]))
					y = y + 20
				end
			end
			
			if (i==1) then
				self:Gui("Add|CheckBox|x200 y58 w120 h20 %s vImageMagickBrowseRecur%s|%s",gSettings:GetValue("ImageMagick","check_browse_recur"..i_s,"") == "1" and "Checked" or "",i,"%t_recursive")
			end
			
			-- Buttons
			self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vImageMagickBrowseInputPath%s|...",i)
			self:Gui("Add|Button|gOnScriptControlAction x485 y180 w30 h20 vImageMagickBrowseOutputPath%s|...",i)
			self:Gui("Add|Button|gOnScriptControlAction x485 y655 w201 h20 vImageMagickSaveSettings%s|%t_save_settings",i)	
			self:Gui("Add|Button|gOnScriptControlAction x485 y680 w201 h20 vImageMagickExecute%s|%t_execute",i)
			
			-- Editbox
			self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vImageMagickInputPath%s|",i)
			self:Gui("Add|Edit|gOnScriptControlAction x25 y180 w450 h20 vImageMagickOutputPath%s|",i)
			self:Gui("Add|Edit|gOnScriptControlAction x25 y280 w450 h20 vImageMagickMogrify%s|",i)
			self:Gui("Add|Edit|gOnScriptControlAction x25 y380 w450 h20 vImageMagickSearch%s|",i)
			
		GuiControl(self.ID,"","ImageMagickInputPath"..i, gSettings:GetValue("ImageMagick","input_path"..i) or "")
		GuiControl(self.ID,"","ImageMagickOutputPath"..i, gSettings:GetValue("ImageMagick","output_path"..i) or "")
		GuiControl(self.ID,"","ImageMagickMogrify"..i, gSettings:GetValue("ImageMagick","command_line"..i) or "")
		GuiControl(self.ID,"","ImageMagickSearch"..i, gSettings:GetValue("ImageMagick","search_pattern"..i) or "")
	end
	self:Gui("Show|w1024 h720|%t_plugin_image_magick")
end

function cImageMagick:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cImageMagick:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self.inherited[1].OnScriptControlAction(self,hwnd,event,info)
	local tab = ahkGetVar("ImageMagickTab") or "1"
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","ImageMagickBrowseInputPath"..tab)) then
		if (tab == "1") then
			local dir = FileSelectFolder("*"..(gSettings:GetValue("ImageMagick","input_path"..tab) or ""))
			if (dir and dir ~= "") then
				GuiControl(self.ID,"","ImageMagickInputPath"..tab,dir)
			end
		else 
			local f = FileSelectFile("M3","","Select one or more images","*.dds")
			if (f and f ~= "") then
				f = f:gsub("\n","|")
				GuiControl(self.ID,"","ImageMagickInputPath"..tab,f)
			end
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ImageMagickBrowseOutputPath"..tab)) then 
		local dir = FileSelectFolder("*"..(gSettings:GetValue("ImageMagick","output_path"..tab) or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","ImageMagickOutputPath"..tab,dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ImageMagickExecute"..tab)) then
		self:ActionExecute(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ImageMagickSaveSettings"..tab)) then
		local input_path = ahkGetVar("ImageMagickInputPath"..tab)
		local output_path = ahkGetVar("ImageMagickOutputPath"..tab)
	
		gSettings:SetValue("ImageMagick","input_path"..tab,input_path)
		gSettings:SetValue("ImageMagick","output_path"..tab,output_path)
		gSettings:SetValue("ImageMagick","command_line"..tab,trim(ahkGetVar("ImageMagickMogrify"..tab)))
		gSettings:SetValue("ImageMagick","search_pattern"..tab, trim(ahkGetVar("ImageMagickSearch"..tab)))
		gSettings:SetValue("ImageMagick","check_browse_recur"..tab,ahkGetVar("ImageMagickBrowseRecur")..tab)
		gSettings:Save()
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ImageMagickLink"..tab)) then 
		Run("http://www.imagemagick.org/script/convert.php")
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","ImageMagickLink2"..tab)) then 
		Run("http://wowwiki.wikia.com/wiki/Pattern_matching")
	end
end

_INACTION = nil
function cImageMagick:ActionExecute(tab)
	if (_INACTION) then 
		MsgBox("Already performing an action")
		return 
	end
	
	local input_path = trim(ahkGetVar("ImageMagickInputPath"..tab))
	if (input_path == nil or input_path == "") then 
		MsgBox("Incorrect Path!")
		return 
	end
	
	local output_path = trim(ahkGetVar("ImageMagickOutputPath"..tab))

	if (Checks[tab]) then
		for i=1,#Checks[tab] do 
			local bool = ahkGetVar("ImageMagickCheck"..Checks[tab][i]..tab)
			gSettings:SetValue("ImageMagick","check_"..Checks[tab][i]..tab,bool)
		end
	end
	
	gSettings:SetValue("ImageMagick","input_path"..tab,input_path)
	gSettings:SetValue("ImageMagick","output_path"..tab,output_path)
	gSettings:SetValue("ImageMagick","check_browse_recur"..tab,ahkGetVar("ImageMagickBrowseRecur")..tab)
	gSettings:Save()
	
	_INACTION = true
	
	self["ActionExecute"..tab](self,tab,input_path,output_path)
	
	_INACTION = false
end

function cImageMagick:ActionExecute1(tab,input_path,output_path)
	Msg("ImageMagick:= Working...")

	local search_pattern = trim(ahkGetVar("ImageMagickSearch"..tab))
	gSettings:SetValue("ImageMagick","search_pattern"..tab,search_pattern)
	
	local user_command_line_options = trim(ahkGetVar("ImageMagickMogrify"..tab))
	gSettings:SetValue("ImageMagick","command_line"..tab,user_command_line_options)
	gSettings:Save()
	
	local working_directory = ahkGetVar("A_WorkingDir")..[[\bin\ImageMagick\]]
	local cp = working_directory

	if (output_path == "") then
		output_path = input_path
	end
	
	local use_mogrify = input_path == output_path
	if (use_mogrify) then
		cp = cp .. "mogrify.exe"
	else
		lfs.mkdir(output_path)
		cp = cp .. "convert.exe"
	end
	
	local copy_thm = ahkGetVar("ImageMagickCheck"..Checks[tab][1]..tab) == "1"
	local remip_only = ahkGetVar("ImageMagickCheck"..Checks[tab][2]..tab) == "1"

	local function on_execute(path,fname,full_path)
		if (search_pattern == nil or search_pattern == "" or string.match(full_path,search_pattern)) then
			local skip = false
			local dds = cDDS(full_path)
			if (remip_only) then 
				if (dds) then 
					skip = not (bit.band(DDSD_MIPMAPCOUNT,dds.dwFlags) == DDSD_MIPMAPCOUNT)
				end
			end
			local command_line_options = ""
			local output_format = dds and (dds.pixel_format.dwFourCC == "DXT5" and "dxt5" or  dds.pixel_format.dwFourCC == "DXT3" and "dxt5" or dds.pixel_format.dwFourCC == "DXT1" and "dxt1") or nil
			if (output_format) then
				command_line_options = user_command_line_options .. " -define dds:compression="..output_format.." "
				if (output_format == "dxt1" and dds:HasAlpha()) then 
					skip = true
					Msg("DXT1a not supported skipping image")
				end
			end
				
			if not (skip) then
				local local_path = trim_final_backslash(output_path..string.gsub(full_path,escape_lua_pattern(input_path),""))
				
				lfs.mkdir(get_path(local_path))
				
				Msg("%s converting",local_path)
				
				if (use_mogrify) then
					RunWait( strformat([["%s" %s "%s"]],cp,command_line_options,local_path) , working_directory )
				else
					RunWait( strformat([["%s" "%s" %s "%s"]],cp,full_path,command_line_options,local_path) , working_directory )
				end
				
				if (copy_thm) then
					RunWait( strformat([[xcopy "%s" "%s" /y /i /q /c]],trim_ext(full_path)..".thm",get_path(local_path)) , working_directory )
				end
			end
		end
	end
	
	file_for_each(input_path,{"dds"},on_execute,ahkGetVar("ImageMagickBrowseRecur"..tab) ~= "1")
	
	Msg("ImageMagick:= Finished!")
end

function cImageMagick:ActionExecute2(tab,input_path,output_path)
	Msg("ImageMagick:= Working...")

	local search_pattern = trim(ahkGetVar("ImageMagickSearch"..tab))
	gSettings:SetValue("ImageMagick","search_pattern"..tab,search_pattern)
	
	local user_command_line_options = trim(ahkGetVar("ImageMagickMogrify"..tab))
	gSettings:SetValue("ImageMagick","command_line"..tab,user_command_line_options)
	gSettings:Save()
	
	local working_directory = ahkGetVar("A_WorkingDir")..[[\bin\ImageMagick\]]
	local cp = working_directory
	
	local file_list = str_explode(input_path,"|")
	
	input_path = file_list[1]
	
	if (output_path == "") then
		output_path = input_path
	end
	
	local use_mogrify = input_path == output_path
	if (use_mogrify) then
		cp = cp .. "mogrify.exe"
	else
		lfs.mkdir(output_path)
		cp = cp .. "convert.exe"
	end
	
	local copy_thm = ahkGetVar("ImageMagickCheck"..Checks[tab][1]..tab) == "1"

	local function on_execute(path,fname)
		local full_path = path.."\\"..fname
		if (search_pattern == nil or search_pattern == "" or string.match(full_path,search_pattern)) then
			local skip = false
			local dds = cDDS(full_path)
			local command_line_options = user_command_line_options
			local output_format = dds and (dds.pixel_format.dwFourCC == "DXT5" and "dxt5" or  dds.pixel_format.dwFourCC == "DXT3" and "dxt5" or dds.pixel_format.dwFourCC == "DXT1" and "dxt1") or nil
			if (output_format) then
				command_line_options = command_line_options .. " -define dds:compression="..output_format.." "
				if (output_format == "dxt1" and dds:HasAlpha()) then 
					skip = true
					Msg("DXT1a not supported skipping image")
				end
			end
				
			if not (skip) then
				local local_path = trim_final_backslash(output_path..string.gsub(full_path,escape_lua_pattern(input_path),""))
				
				lfs.mkdir(get_path(local_path))
				
				Msg("%s converting",local_path)
				
				if (use_mogrify) then
					RunWait( strformat([["%s" %s "%s"]],cp,command_line_options,local_path) , working_directory )
				else
					RunWait( strformat([["%s" "%s" %s "%s"]],cp,full_path,command_line_options,local_path) , working_directory )
				end
				
				if (copy_thm) then
					RunWait( strformat([[xcopy "%s" "%s" /y /i /q /c]],trim_ext(full_path)..".thm",get_path(local_path)) , working_directory )
				end
			end
		end
	end
	
	for i=2,#file_list do 
		on_execute(input_path,file_list[i])
	end
	
	Msg("ImageMagick:= Finished!")
end