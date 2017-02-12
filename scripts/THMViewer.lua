--[[

Notes: When using LV functions make sure to switch to GUI ID that has the LV before using commands. For example
I couldn't figure out why LV commands weren't working while in the Modify UI. it's because I had to switch 
to GUI 0.
http://stackoverflow.com/questions/24002210/cannot-update-listview

--]]

local Checks = {}
local thm_fields = {	"version","texture_format","flags","border_color",
					"fade_color","fade_amount","mip_filter","texture_width",
					"texture_height","texture_type","detail_name","detail_scale",
					"material","material_weight","bump_height","bump_mode","bump_name",
					"normal_map_name","fade_delay"
}
table.sort(thm_fields)

local clipboard = {}
-----------------------------------------------------------------
-- 
-----------------------------------------------------------------
function OnApplicationBegin()
	Application.AddPluginButton("t_plugin_thm_viewer","UITHMViewerShow",GetAndShow)
end

UI = nil
function Get()
	if not (UI) then 
		UI = cUITHMViewer("1")
		UI.parent = Application.MainMenu
	end 
	return UI
end

function GetAndShow()
	local _ui = Get()
	_ui:Show(true)
	return _ui
end

-----------------------------------------------------------------
-- UI Class Definition
-----------------------------------------------------------------
Class "cUITHMViewer" (cUIBase)
function cUITHMViewer:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUITHMViewer:Show(bool)
	self.inherited[1].Show(self,bool)
end 

function cUITHMViewer:Create()
	self.inherited[1].Create(self)
end

function cUITHMViewer:Reinit()
	self.inherited[1].Reinit(self)
	
	self.thm = self.thm or {}
	self.list = self.list or {}
	
	local tabs = {"t_thm_viewer","t_thm_validator","t_thm_editor"}
	Checks["2"] = {"t_resync_size","t_resync_format","t_resync_mipmaps","t_resync_bump_mode","t_resync_alpha","t_remove_thm_of_missing_dds"}
	
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vUITHMViewerTab hwndUITHMViewerTab_H|%t_thm_viewer^%t_thm_validator^%t_thm_editor")
	
	
	for i=1,#tabs do
		local i_s = tostring(i)
		if (i == 1) then
			local filters = table.concat({"All","Diffuse","Bump"},"^")
			self:Gui("Tab|%s",Language.translate(tabs[i]))
				self:Gui("Add|Text|x550 y75 w265 h30|%t_click_to_edit")
				
				-- ListView 
				self:Gui("Add|ListView|gOnScriptControlAction x22 y109 w920 h440 grid cBlack +altsubmit -multi vUITHMViewerLV%s|filename^%s",i,table.concat(thm_fields,"^"))
				
				-- GroupBox
				self:Gui("Add|GroupBox|x22 y555 w530 h75|%t_working_directory")
				
				self:Gui("Add|DropDownList|gOnScriptControlAction x22 y69 w320 h30 R40 H300 vUITHMViewerSection%s|"..filters,i)
				
				-- Buttons 
				self:Gui("Add|Button|gOnScriptControlAction x495 y600 w30 h20 vUITHMViewerBrowsePath%s|...",i)
				self:Gui("Add|Button|gOnScriptControlAction x485 y680 w201 h20 vUITHMViewerSaveSettings%s|%t_save_settings",i)
				
				-- Editbox 
				self:Gui("Add|Edit|gOnScriptControlAction x30 y600 w450 h20 vUITHMViewerPath%s|",i)
				
			GuiControl(self.ID,"","UITHMViewerPath"..i, gSettings:GetValue("thm_viewer","path"..i) or "")
		elseif (i == 2) then
			self:Gui("Tab|%s",Language.translate(tabs[i]))
				-- GroupBox
				self:Gui("Add|GroupBox|x10 y50 w510 h75|%t_textures")
				
				if (Checks[i_s]) then
					local y = 145
					for n=1,#Checks[i_s] do
						self:Gui("Add|CheckBox|x50 y%s w190 h22 %s vUITHMViewerCheck%s%s|%s",y,gSettings:GetValue("thm_viewer","check_"..Checks[i_s][n]..i_s,"") == "1" and "Checked" or "",Checks[i_s][n],i_s,Language.translate(Checks[i_s][n]))
						y = y + 20
					end
				end
			
				-- Buttons 
				self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vUITHMViewerBrowsePath%s|...",i)
				self:Gui("Add|Button|gOnScriptControlAction x485 y655 w201 h20 vUITHMViewerSaveSettings%s|%t_save_settings",i)
				self:Gui("Add|Button|gOnScriptControlAction x485 y680 w201 h20 vUITHMViewerExecute%s|%t_execute",i)
				
				-- Editbox 
				self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vUITHMViewerPath%s|",i)
			
			GuiControl(self.ID,"","UITHMViewerPath"..i, gSettings:GetValue("thm_viewer","path"..i) or "")
		elseif (i == 3) then 
			local filters = table.concat({"All","Diffuse","Bump","MissingTHM"},"^")
			self:Gui("Tab|%s",Language.translate(tabs[i]))
				self:Gui("Add|Text|x550 y75 w265 h30|%t_click_to_edit")
				
				-- ListView 
				self:Gui("Add|ListView|gOnScriptControlAction x22 y109 w920 h440 grid cBlack +altsubmit -multi vUITHMViewerLV%s|",i)
				
				-- GroupBox
				self:Gui("Add|GroupBox|x22 y555 w530 h75|%t_working_directory")
				
				self:Gui("Add|DropDownList|gOnScriptControlAction x22 y69 w320 h30 R40 H300 vUITHMViewerSection%s|"..filters,i)
				
				-- Buttons 
				self:Gui("Add|Button|gOnScriptControlAction x495 y600 w30 h20 vUITHMViewerBrowsePath%s|...",i)
				self:Gui("Add|Button|gOnScriptControlAction x485 y680 w201 h20 vUITHMViewerSaveSettings%s|%t_save_settings",i)
				
				-- Editbox 
				self:Gui("Add|Edit|gOnScriptControlAction x30 y600 w450 h20 vUITHMViewerPath%s|",i)
				
			GuiControl(self.ID,"","UITHMViewerPath"..i, gSettings:GetValue("thm_viewer","path"..i) or "")
		end
	end
	
	self:Gui("Show|w1024 h720|%t_plugin_thm_viewer")

	LV("LV_Delete",self.ID)
	clear(self.list)
end

function cUITHMViewer:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUITHMViewer:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("UITHMViewerTab") or "1"
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerLV"..tab)) then
		local selected = ahkGetVar("UITHMViewerSection"..tab)
		if (selected == nil or selected == "") then 
			return 
		end
		if (event and string.lower(event) == "rightclick") then
			LVTop(self.ID,"UITHMViewerLV"..tab)
			local row = LVGetNext(self.ID,"0","UITHMViewerLV"..tab)
			local txt = LVGetText(self.ID,row,"1")
			--Msg("event=%s LVGetNext=%s txt=%s",event,LVGetNext(self.ID,"0","UITHMViewerLV"..tab),txt)
			if (txt and txt ~= "" and not self.listItemSelected) then 
				self.listItemSelected = txt
				GetAndShowModify(tab).modify_row = row
			end
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerSection"..tab)) then 	
		self:FillListView(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerBrowsePath"..tab)) then
		local dir = FileSelectFolder("*"..(gSettings:GetValue("thm_viewer","path"..tab) or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UITHMViewerPath"..tab,dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerSaveSettings"..tab)) then
		local path = ahkGetVar("UITHMViewerPath"..tab)
		if (path and path ~= "") then
			gSettings:SetValue("thm_viewer","path"..tab,path)
			gSettings:Save()
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerExecute"..tab)) then
		self:Gui("Submit|NoHide")
		if (self["ActionExecute"..tab]) then
			self["ActionExecute"..tab](self,tab)
		else 
			Msg("cUITHMViewer:%s doesn't exist!","ActionExecute"..tab)
		end
	end
end

function cUITHMViewer:Gui(...)
	self.inherited[1].Gui(self,...)
end

function get_relative_path(str,path)
	return trim(string.sub(path,str:len()+1))
end

_INACTION = nil
function cUITHMViewer:ActionExecute2(tab)
	if (_INACTION) then 
		MsgBox("Already performing an action")
		return 
	end
	
	local input_path = ahkGetVar("UITHMViewerPath"..tab)
	if (input_path == nil or input_path == "") then 
		MsgBox("Incorrect Path!")
		return 
	end
	
	if (Checks[tab]) then
		for i=1,#Checks[tab] do
			local bool = ahkGetVar("UITHMViewerCheck"..Checks[tab][i]..tab)
			gSettings:SetValue("thm_viewer","check_"..Checks[tab][i]..tab,bool)
		end
	end
	
	gSettings:SetValue("thm_viewer","path"..tab,input_path)
	gSettings:Save()
	
	_INACTION = true
	
	local opt_resync_size = ahkGetVar("UITHMViewerCheck"..Checks[tab][1]..tab) == "1"
	local opt_resync_format = ahkGetVar("UITHMViewerCheck"..Checks[tab][2]..tab) == "1"
	local opt_resync_mipmaps = ahkGetVar("UITHMViewerCheck"..Checks[tab][3]..tab) == "1"
	local opt_resync_bump_mode = ahkGetVar("UITHMViewerCheck"..Checks[tab][4]..tab) == "1"
	--local opt_create_missing_thm = ahkGetVar("UITHMViewerCheck"..Checks[tab][6]..tab) == "1"
	local opt_resync_alpha = ahkGetVar("UITHMViewerCheck"..Checks[tab][5]..tab) == "1"
	local opt_remove_thm = ahkGetVar("UITHMViewerCheck"..Checks[tab][6]..tab) == "1"
	
	local errors = {}
	
	local ignore_list = {
		["$noalphadxt5"] = true,
		["$alphadxt1"] = true
	}
	
	local files_resynced_count = 0
	local function on_execute(path,fname)
		local thm = cTHM(path.."\\"..fname)
		if (thm:size() <= 0) then 
			Msg("THM Validater := %s size is zero!",fname)
		else 
			local fn = trim_ext(fname)
			if not (ignore_list[fn] or string.find(fn,"ui_font_")) then
				local dds_path = path.."\\"..fn..".dds"
				if not (file_exists(dds_path)) then
					if not (string.find(path,"terrain")) then
						if (opt_remove_thm) then
							os.remove(path.."\\"..fname)
							table.insert(errors,strformat("%s.dds not found even though there is %s.thm by this name (normal behavior for textures in terrain directory) *THM REMOVED*\n",fn,fn))
						else 
							table.insert(errors,strformat("%s.dds not found even though there is %s.thm by this name (normal behavior for textures in terrain directory)\n",fn,fn))
						end
					end
				else 
					Msg(fname)
					
					local dds = cDDS(dds_path)
					if (dds) then 
						local needs_resync = false
						
						if not(dds.dwMagic == DDS_MAGIC and dds.dwSize == 124 and dds.pixel_format.dwSize == 32) then 
							table.insert(errors,strformat("%s not a valid DDS format\n",fname))
						else
							-- CHECK DIMENSIONS
							if (dds.dwWidth ~= thm.params.texture_width or dds.dwHeight ~= thm.params.texture_height) then
								--Msg("%s [%sx%s] widthxheight mismatch dds=%sx%s",fn,thm.params.texture_width,thm.params.texture_height,dds.dwWidth,dds.dwHeight)
								table.insert(errors,strformat("%s [%sx%s] widthxheight mismatch dds=%sx%s\n",fn,thm.params.texture_width,thm.params.texture_height,dds.dwWidth,dds.dwHeight))
								needs_resync = opt_resync_size or needs_resync
							end
							
							-- CHECK HAS ALPHA
							local has_alpha = false --dds:PixelFormatIsDXT5() or dds:PixelFormatIsDXT3() or dds:PixelFormatIsRGBA() or false
							if (opt_resync_alpha) then -- for speed
								has_alpha = dds:HasAlpha()
								if (has_alpha) then 
									if not (string.find(thm.params.flags,"HasAlpha")) then
										table.insert(errors,strformat("[HasAlpha] %s HasAlpha flag is off even though dds has alpha\n",fn))
										needs_resync = true
									end
								else 
									if (string.find(thm.params.flags,"HasAlpha")) then
										table.insert(errors,strformat("[HasAlpha] %s HasAlpha flag is on even though dds has does not have alpha\n",fn))
										needs_resync = true
									end
								end
							end
							
							-- CHECK MIPMAPS
							local has_mipmaps = (bit.band(DDSD_MIPMAPCOUNT,dds.dwFlags) == DDSD_MIPMAPCOUNT)
							if (has_mipmaps) then 
								if not (string.find(thm.params.flags,"GenerateMipMaps")) then 
									table.insert(errors,strformat("[GenerateMipMaps] %s GenerateMipMaps flag is off even though dds has %s mipmaps\n",fn,dds.dwMipMapCount))
									needs_resync = opt_resync_mipmaps or needs_resync
								end
							else 
								if (string.find(thm.params.flags,"GenerateMipMaps")) then 
									table.insert(errors,strformat("[GenerateMipMaps] %s GenerateMipMaps flag is enabled even though dds has %s mipmaps\n",fn,dds.dwMipMapCount))
									needs_resync = opt_resync_mipmaps or needs_resync
								end
							end
							
							-- CHECK PIXEL FORMAT
							local pixel_format = dds:PixelFormatIsDXT1() and "DXT1" or dds:PixelFormatIsDXT3() and "DXT3" or dds:PixelFormatIsDXT5() and "DXT5" or dds:PixelFormatIsRGBA() and "RGBA" or dds:PixelFormatIsRGB() and "RGB"
							local has_pixelformat = pixel_format and (bit.band(DDSD_PIXELFORMAT,dds.dwFlags) == DDSD_PIXELFORMAT)
							if (has_pixelformat) then
								if (pixel_format == "DXT1") and (has_alpha or thm.params.texture_format == "DXT1a") then
									pixel_format = "DXT1a"
								end
								if (thm.params.texture_format ~= pixel_format) then
									--Msg("%s has format %s but dds has format %s",fn,thm.params.texture_format,dds.pixel_format.dwFourCC)
									table.insert(errors,strformat("%s has format %s but dds has format %s\n",fn,thm.params.texture_format,pixel_format))
									needs_resync = opt_resync_format or needs_resync
								end
							else
								--Msg("Error format is empty (try resave texture or texture is uncompressed) | %s %sx%s",fn,dds.dwWidth,dds.dwHeight)
								table.insert(errors,strformat("Error format is empty (try resave texture or texture is uncompressed) | %s %sx%s\n",fn,dds.dwWidth,dds.dwHeight))
							end

							-- CHECK BUMP MODE
							if (string.find(fname,"_bump#.dds")) then
								table.insert(errors,strformat("%s doesn't need *.thm",fname))
							elseif (string.find(fname,"_bump.dds")) then
								if not (thm.params.texture_type == "BumpMap") then
									table.insert(errors,strformat("[TextureType] %s has texture_type %s but dds has _bump.dds postfix. Should be BumpMap.\n",fn,thm.params.texture_type))
									needs_resync = true
									thm.params.texture_type = "BumpMap"
								end
							elseif not (thm.params.texture_type == "Image") then
								table.insert(errors,strformat("[TextureType] %s has texture_type %s but should be Image.\n",fn,thm.params.texture_type))
								needs_resync = true
								thm.params.texture_type = "Image"
							end
							
							if (thm.params.bump_mode == "None") then 
								if (thm.params.bump_name and thm.params.bump_name ~= "") then
									table.insert(errors,strformat("[BumpMode] %s has bump %s but bump mode is None.\n",fn,thm.params.bump_name))
									needs_resync = true
								end
							elseif (string.find(fname,"_bump")) then
								table.insert(errors,strformat("[BumpMode] %s has bump mode Use even though it is a bump.\n",fn))
								needs_resync = true
							elseif (thm.params.bump_name == "") then
								table.insert(errors,strformat("[BumpMode] %s has bump mode Use even though it does not have a bump.\n",fn))
								needs_resync = true
							end
							
							if (needs_resync) then 
								if (opt_resync_size) then
									thm.params.texture_width = dds.dwWidth
									thm.params.texture_height = dds.dwHeight
								end 
								
								if (opt_resync_format and pixel_format) then
									thm.params.texture_format = pixel_format
								end
								
								if (opt_resync_alpha) then 
									if (has_alpha) then 
										if not (string.find(thm.params.flags,"HasAlpha")) then
											thm.params.flags = thm.params.flags .. ",HasAlpha"
										end
									else
										if (string.find(thm.params.flags,"HasAlpha")) then
											thm.params.flags = string.gsub(thm.params.flags,"(HasAlpha)","")
										end
									end
								end
								
								if (opt_resync_mipmaps) then
									if (has_mipmaps) then
										if not (string.find(thm.params.flags,"GenerateMipMaps")) then
											thm.params.flags = thm.params.flags .. ",GenerateMipMaps"
										end
									else
										if (string.find(thm.params.flags,"GenerateMipMaps")) then 
											thm.params.flags = string.gsub(thm.params.flags,"(GenerateMipMaps)","")
										end
									end
								end
								
								if (opt_resync_bump_mode) then
									if (thm.params.bump_mode == "None") then 
										if (thm.params.bump_name and thm.params.bump_name ~= "") then
											thm.params.bump_mode = "Use"
										end
									elseif (string.find(fname,"_bump")) then
										thm.params.bump_mode = "None"
										if (thm.params.bump_name and thm.params.bump_name ~= "" and string.find(thm.params.bump_name,"_nmap")) then
											thm.params.normal_map_name = thm.params.bump_name
											thm.params.bump_name = ""
										end
									elseif (thm.params.bump_name == "") then
										thm.params.bump_mode = "None"
									end
								end
								
								thm.params.mip_filter = "Kaiser"
								
								thm:save()
								--Msg("%s resynced with dds",fn)
								files_resynced_count = files_resynced_count + 1
							end
						end
					end
				end
			end
		end
	end
	
	Msg("THM Validater := Checking...")
	recurse_subdirectories_and_execute(input_path,{"thm"},on_execute)
	
	local function on_execute_2(path,fname)
		Msg(fname)
		local fn = trim_ext(fname)
		local thm_path = path.."\\"..fn..".thm"
		local short = string.find(fname,"_bump.dds") and string.gsub(fname,"(_bump.dds)","")
		
		if (short and not file_exists(path.."\\"..short.."_bump#.dds")) then
			table.insert(errors,strformat("Missing %s_bump#.dds for %s.dds\n",fn,short))
		end 
		
		if not (file_exists(thm_path)) then
			if not string.find(fn,"_bump#") then
				table.insert(errors,strformat("Missing thm *.thm for %s.dds\n",fn))
			end
			-- Auto create missing thm
			--[[
			if (string.find(fname,"_bump")) then
				local thm = cTHM(thm_path)
				thm.params.flags = "HasAlpha,DitherColor"
				thm.params.texture_format = "DXT5"
				thm.params.bump_mode = "None"
				
				if (string.find(fname,"#.dds")) then 
					thm.params.texture_type = "Image"
				else 
					thm.params.texture_type = "BumpMap"
				end
				
				thm:save()
			else 
				local thm = cTHM(thm_path)
				thm.params.flags = "GenerateMipMaps"
				thm.params.texture_format = "DXT1"
				thm.params.texture_type = "Image"
				thm.params.mip_filter = "Triangle"
				thm.material = "OrenNayerBlin"
				thm.fade_color = 8355711
				
				if (file_exists(path.."\\"..fn.."_bump.dds")) then
					local relative_path = get_relative_path(input_path.."\\",path)
					local relfn = relative_path.."\\"..fn
					thm.params.bump_mode = "Use"
					thm.params.bump_name = relfn
				else
					thm.params.bump_mode = "None"
				end
				
				thm:save()
			end
			--]]
		elseif (short and short ~= "" and file_exists(path.."\\"..short..".thm")) then
			local thm = cTHM(path.."\\"..short..".thm")
			if (thm:size() > 0) then 
				local relative_path = get_relative_path(input_path.."\\",path)
				local relfn = relative_path.."\\"..fn
				if (thm.params.bump_name ~= relfn) then 
					table.insert(errors,strformat("Incorrect bump name possible for %s.thm; does not have %s for bump_name. bump_name in *.thm is %s\n",short,relfn,thm.params.bump_name))
					
					if (file_exists(path.."\\"..fn..".dds")) then 
						if (opt_advance_verify) then
							--Msg("Incorrect bump_name for %s.thm; has set in *.thm, correcting... [Note: This detection only works if input directory is root textures folder]",short)
							-- [MUST BE IN textures\ root to work] advanced user only
							thm.params.bump_name = relfn
							thm:save()
							files_resynced_count = files_resynced_count + 1
						end
					end
				end
			end
		end
	end

	Msg("THM Validater := Checking DDS...")
	
	recurse_subdirectories_and_execute(input_path,{"dds"},on_execute_2)

	
	if (files_resynced_count > 0) then
		Msg("THM Validater := Finished! %s *.thm resynced. (check thm_viewer_log.txt)",files_resynced_count)
	else
		Msg("THM Validater := Finished! (check logs\\thm_viewer_log.txt)")
	end

	local thm_log, err = io.open("logs\\thm_viewer_log.txt","wb")
	if (err) then 
		error("failed to create thm_viewer_log.txt |"..err)
	end
	thm_log:write(table.concat(errors))
	thm_log:close()
	
	_INACTION = false
end

function cUITHMViewer:FillListView(tab,skip)
	LVTop(self.ID,"UITHMViewerLV"..tab)
	LV("LV_Delete",self.ID)
	
	if not (skip) then
		empty(self.list)
	end

	local selected = trim(ahkGetVar("UITHMViewerSection"..tab))
	if (selected == nil or selected == "") then 
		return Msg("FillListView error selected is %s",selected)
	end
	
	local dir = ahkGetVar("UITHMViewerPath"..tab)
	if (dir == nil or dir == "") then
		return MsgBox("Please select a valid working directory")
	end
	
	for i=1,200 do 
		LV("LV_DeleteCol",self.ID,"1")
	end
			
	self["FillListView"..tab](self,tab,selected,dir,skip)
	
	LV("LV_ModifyCol",self.ID,"1","Sort CaseLocale")
	LV("LV_ModifyCol",self.ID,"1","AutoHdr")

	for i=1,200 do
		LV("LV_ModifyCol",self.ID,tostring(i+1),"AutoHdr")
	end
end

function cUITHMViewer:FillListView1(tab,selected,dir,skip)
	
	LV("LV_InsertCol",self.ID,tostring(1),"","filename")
	for i=1,#thm_fields do 
		LV("LV_InsertCol",self.ID,tostring(i+1),"",thm_fields[i])
	end 

	LV("LV_ModifyCol",self.ID,"1","AutoHdr")
	
	local ignore_paths = {}
	local function on_execute(path,fname)
		local check_path = trim_directory(path)
		if (ignore_paths[check_path]) then 

		else
			local show = selected == "All"
			if (selected == "Diffuse" and not string.find(fname,"bump")) then 
				show = true
			elseif (selected == "Bump" and string.find(fname,"bump")) then 
				show = true
			end 
			
			if (show) then
				if not (self.thm[fname]) then
					self.thm[fname] = cTHM(path.."\\"..fname)
				end
				if (self.thm[fname]) then
					self.list[fname] = self.thm[fname].params
					self.list[fname].__fullpath = path.."\\"..fname
				end
			end
		end
	end
	
	recurse_subdirectories_and_execute(dir,{"thm"},on_execute)
	
	table.sort(self.list)

	for fname,t in pairs(self.list) do
		local a = {}
		for i=1,#thm_fields do
			table.insert(a,t[thm_fields[i]] or "")
		end
		LV("LV_ADD",self.ID,"",fname,unpack(a))
	end
end

function cUITHMViewer:FillListView3(tab,selected,dir,skip)
	local fields = {"DDS","THM"}
	for i=1,#fields do 
		LV("LV_InsertCol",self.ID,tostring(i),"",fields[i])
	end 
	
	LV("LV_ModifyCol",self.ID,"1","AutoHdr")
	
	local ignore_paths = {}
	local function on_execute(path,fname)
		local check_path = trim_directory(path)
		if (ignore_paths[check_path]) then 

		else
			local show = selected == "All"
			if (selected == "Diffuse" and not string.find(fname,"bump")) then 
				show = true
			elseif (selected == "Bump" and string.find(fname,"bump")) then 
				show = true
			elseif (selected == "MissingTHM") then 
				local fn = trim_ext(fname)
				if not (file_exists(path.."\\"..fn..".thm")) then 
					show = true
				end
			end
			
			if (show) then
				local fn = trim_ext(fname)
				self.list[fname] = {path,fn..".thm",file_exists(path.."\\"..fn..".thm") == true}
			end
		end
	end
	
	if not (skip) then
		recurse_subdirectories_and_execute(dir,{"dds"},on_execute)
	end
	
	for fname,t in pairs(self.list) do
		LV("LV_ADD",self.ID,"",fname,t[3] and t[2] or "")
	end
end
-----------------------------------------------------------------
-- Modify UI
-----------------------------------------------------------------
UI2 = nil
UI3 = nil
function GetModify(tab)
	if (tab == "1") then
		if not (UI2) then 
			UI2 = cUITHMViewerModify("2")
		end
		return UI2
	elseif (tab == "3") then 
		if not (UI3) then 
			UI3 = cUITHMViewerModify2("3")
		end
		return UI3
	end
end

function GetAndShowModify(tab)
	local _ui = GetModify(tab)
	_ui:Show(true)
	return _ui
end
-----------------------------------------------------------------
-- UI Modify Class Definition
-----------------------------------------------------------------
Class "cUITHMViewerModify" (cUIBase)
function cUITHMViewerModify:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUITHMViewerModify:Show(bool)
	self.inherited[1].Show(self,bool)
end 

function cUITHMViewerModify:Create()
	self.inherited[1].Create(self)
end

function cUITHMViewerModify:Reinit()
	self.inherited[1].Reinit(self)
	
	self:Gui("+AlwaysonTop")
	self:Gui("Font|s10|Verdana")
	
	local wnd = Get()
	if (wnd.listItemSelected == nil) then 
		return Msgbox("An error has occured. listItemSelected = nil!")
	end
	
	local fname = wnd.listItemSelected
	local list = wnd.list[fname]
	
	if not (list) then 
		return Msgbox("An error has occured. list = nil!")
	end
	
	self:Gui("Add|Text|w300 h30|%s",fname)
	
	local tab = ahkGetVar("UITHMViewerTab")

	local y = 35
	for field,v in pairs(list) do
		if (field ~= "__fullpath") then
			self:Gui("Add|Text|x5 y%s w300 h30|%s",y,field)
			self:Gui("Add|Edit|x200 y%s w800 h30 vUITHMViewerModifyEdit%s|%s",y,field,v)
			y = y + 30
		end
	end
 
	self:Gui("Add|Button|gOnScriptControlAction x12 default vUITHMViewerModifyAccept|%t_accept")
	self:Gui("Add|Button|gOnScriptControlAction x+4 vUITHMViewerModifyCancel|%t_cancel")
	self:Gui("Add|Button|gOnScriptControlAction x+4 vUITHMViewerModifyOpenDDS|%t_open .DDS")
	self:Gui("Add|Button|gOnScriptControlAction x+4 vUITHMViewerModifyCopy|%t_copy")
	self:Gui("Add|Button|gOnScriptControlAction x+4 vUITHMViewerModifyPaste|%t_paste")
	--self:Gui("+Resize +MaxSize1000x800 +0x200000")
	self:Gui("Show|center|%t_edit_values")
	self:Gui("Default")
end

function cUITHMViewerModify:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUITHMViewerModify:Destroy()
	self.inherited[1].Destroy(self)
	
	Get().listItemSelected = nil 
end

function cUITHMViewerModify:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback

	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("UITHMViewerTab") or "1"
		
	if (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerModifyAccept")) then
		local wnd = Get()
		local fname = wnd.listItemSelected
		local list = assert(wnd.list[fname])
	
		for field,v in pairs(list) do
			if (field ~= "__fullpath") then
				local val = ahkGetVar("UITHMViewerModifyEdit"..field)
				if (val) then
					wnd.thm[fname].params[field] = tonumber(val) or val
				end
			end
		end
		
		if not (wnd.thm[fname]) then 
			Msg("Error: wnd.thm[%s] is nil!",fname)
			return 
		end 
		
		wnd.thm[fname]:save()

		local a = {}
		for i=1,#thm_fields do
			table.insert(a,list[thm_fields[i]] or "")
		end
		LVTop(wnd.ID,"UITHMViewerLV"..tab)
		LV("LV_Modify",wnd.ID,self.modify_row,"",fname,unpack(a))
		
		self:Show(false)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerModifyCancel")) then
		self:Show(false)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerModifyOpenDDS")) then 
		local wnd = Get()
		local fname = wnd.listItemSelected
		if not (wnd.list[fname]) then
			Msg("Copy failed")
			return 
		end
		os.execute(strformat([[start "" "%s"]],trim_ext(wnd.list[fname].__fullpath)..".dds"))
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerModifyCopy")) then
		local wnd = Get()
		local fname = wnd.listItemSelected
		if not (wnd.list[fname]) then
			Msg("Copy failed")
			return
		end
		for k,v in pairs(wnd.list[fname]) do
			if (k ~= "__fullpath") then
				clipboard[k] = v
			end
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerModifyPaste")) then
		local wnd = Get()
		local fname = wnd.listItemSelected
		if not (wnd.list[fname]) then
			Msg("Paste failed")
			return 
		end
		for k,v in pairs(clipboard) do
			wnd.list[fname][k] = v
		end
		
		local selected = fname
		self:Show(false)
		wnd.listItemSelected = fname
		self:Show(true)
	end
end

function cUITHMViewerModify:Gui(...)
	self.inherited[1].Gui(self,...)
end
--------------------------------------------------------------------------
-- Modify2 (tab3)
--------------------------------------------------------------------------
Class "cUITHMViewerModify2" (cUIBase)
function cUITHMViewerModify2:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUITHMViewerModify2:Show(bool)
	self.inherited[1].Show(self,bool)
end 

function cUITHMViewerModify2:Create()
	self.inherited[1].Create(self)
end

function cUITHMViewerModify2:Reinit()
	self.inherited[1].Reinit(self)
	
	--self:Gui("+AlwaysonTop")
	self:Gui("Font|s10|Verdana")
	
	local wnd = Get()
	if (wnd.listItemSelected == nil) then 
		return Msgbox("An error has occured. listItemSelected = nil!")
	end
	
	local fname = wnd.listItemSelected
	local list = wnd.list[fname]
	
	if not (list) then 
		return Msgbox("An error has occured. list = nil!")
	end
	
	local thm_path = list[1].."\\"..list[2]
	wnd.thm[thm_path] = wnd.thm[thm_path] or cTHM(thm_path)
	list = wnd.thm[thm_path].params
	
	table.sort(list)
	
	self:Gui("Add|Text|w300 h30|%s",fname)
	
	local tab = ahkGetVar("UITHMViewerTab")

	local y = 35
	for field,v in pairs(list) do 
		self:Gui("Add|Text|x5 y%s w300 h30|%s",y,field)
		self:Gui("Add|Edit|x200 y%s w800 h30 vUITHMViewerModifyEdit2%s|%s",y,field,v)
		y = y + 30
	end
 
	self:Gui("Add|Button|gOnScriptControlAction x12 default vUITHMViewerModifyAccept2|%t_accept")
	self:Gui("Add|Button|gOnScriptControlAction x+4 vUITHMViewerModifyCancel2|%t_cancel")
	self:Gui("Add|Button|gOnScriptControlAction x+4 vUITHMViewerModifyOpenDDS2|%t_open .DDS")
	self:Gui("Add|Button|gOnScriptControlAction x+4 vUITHMViewerModifyCopy2|%t_copy")
	self:Gui("Add|Button|gOnScriptControlAction x+4 vUITHMViewerModifyPaste2|%t_paste")
	--self:Gui("+Resize +MaxSize1000x800 +0x200000")
	self:Gui("Show|center|%t_edit_values")
	self:Gui("Default")
end

function cUITHMViewerModify2:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUITHMViewerModify2:Destroy()
	self.inherited[1].Destroy(self)
	
	Get().listItemSelected = nil 
end

function cUITHMViewerModify2:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback

	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("UITHMViewerTab") or "1"
		
	if (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerModifyAccept2")) then
		local wnd = Get()
		local fname = wnd.listItemSelected
		local list = assert(wnd.list[fname])
		local thm_path = list[1].."\\"..list[2]
		
		if not (file_exists(thm_path)) then
			MsgBox(strformat("%s does not exist this will create a new *.thm",list[2]))
		end 
		
		local t = wnd.thm[thm_path].params
		for field,v in pairs(t) do 
			local val = ahkGetVar("UITHMViewerModifyEdit2"..field)
			if (val) then
				wnd.thm[thm_path].params[field] = tonumber(val) or val
			end
		end

		wnd.thm[thm_path]:save()
		wnd.list[fname][3] = true
		
		LVTop(wnd.ID,"UITHMViewerLV"..tab)
		LV("LV_Modify",wnd.ID,self.modify_row,"Col2",list[2])
		
		self:Show(false)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerModifyCancel2")) then
		self:Show(false)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerModifyOpenDDS2")) then 
		local wnd = Get()
		local fname = wnd.listItemSelected
		local list = assert(wnd.list[fname])
		local full_path = list[1].."\\"..fname
		
		os.execute(strformat([[start "" "%s"]],full_path))
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerModifyCopy2")) then
		local wnd = Get()
		local fname = wnd.listItemSelected
		local list = assert(wnd.list[fname])
		local thm_path = list[1].."\\"..list[2]
		
		local t = wnd.thm[thm_path].params
		for k,v in pairs(t) do
			clipboard[k] = v
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITHMViewerModifyPaste2")) then
		local wnd = Get()
		local fname = wnd.listItemSelected
		local list = assert(wnd.list[fname])
		local thm_path = list[1].."\\"..list[2]
		for k,v in pairs(clipboard) do 
			wnd.thm[thm_path].params[k] = v
		end
		
		local selected = fname
		self:Show(false)
		wnd.listItemSelected = fname
		self:Show(true)
	end
end

function cUITHMViewerModify2:Gui(...)
	self.inherited[1].Gui(self,...)
end