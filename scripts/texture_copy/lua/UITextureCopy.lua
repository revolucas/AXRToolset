local Checks = {}

-----------------------------------------------------------------
--
-----------------------------------------------------------------
function OnApplicationBegin()
	UIMain.AddPluginButton("TextureCopy","UITextureCopyShow",GetAndShow)
end
---------------------------------------------------------------------------
UI = nil
function Get()
	if not (UI) then 
		UI = cUITextureCopy("1")
		UI.parent = UIMain.Get()
	end 
	return UI
end

function GetAndShow()
	Get():Show(true)
end
-----------------------------------------------------------------
-- UI Class Definition
-----------------------------------------------------------------
local inherited = UIBase.cUIBase
cUITextureCopy = Class("cUITextureCopy",inherited)
function cUITextureCopy:initialize(id)
	inherited.initialize(self,id)
end

function cUITextureCopy:Reinit()
	inherited.Reinit(self)
	
	local tabs = {"SoC->CoP rename","missing bump#"}
	Checks["1"] = {"overwrite"}
	
	-- below will be automated based on above tab definition and checks
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vUITextureCopyTab|%s",table.concat(tabs,"^"))
	
	for i=1,#tabs do
		local i_s = tostring(i)
		
		self:Gui("Tab|%s",tabs[i])
			-- GroupBox
			self:Gui("Add|GroupBox|x10 y50 w510 h75|Input Path (Recursive)")
			self:Gui("Add|GroupBox|x10 y150 w510 h75|Output Path")
			
			if (Checks[i_s]) then
				local y = 245
				--table.sort(Checks[i_s])
				for n=1,#Checks[i_s] do
					self:Gui("Add|CheckBox|x50 y%s w150 h22 %s vUITextureCopyCheck%s%s|%s",y,gSettings:GetValue("TextureCopy","check_"..Checks[i_s][n]..i_s,"") == "1" and "Checked" or "",Checks[i_s][n],i_s,Checks[i_s][n])
					y = y + 20
				end
			end
				
			-- Buttons 
			self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vUITextureCopyBrowseInputPath%s|...",i)
			self:Gui("Add|Button|gOnScriptControlAction x485 y180 w30 h20 vUITextureCopyBrowseOutputPath%s|...",i)
			self:Gui("Add|Button|gOnScriptControlAction x485 y655 w90 h20 vUITextureCopySaveSettings%s|Save Settings",i)	
			self:Gui("Add|Button|gOnScriptControlAction x485 y680 w90 h20 vUITextureCopyExecute%s|Execute",i)		
			
			-- Editbox 
			self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vUITextureCopyInputPath%s|",i)
			self:Gui("Add|Edit|gOnScriptControlAction x25 y180 w450 h20 vUITextureCopyOutputPath%s|",i)
			
		GuiControl(self.ID,"","UITextureCopyInputPath"..i, gSettings:GetValue("TextureCopy","input_path"..i) or "")
		GuiControl(self.ID,"","UITextureCopyOutputPath"..i, gSettings:GetValue("TextureCopy","output_path"..i) or "")
	end
	self:Gui("Show|w1024 h720|TextureCopy")
end

function cUITextureCopy:OnGuiClose(idx) -- needed because it's registered to callback
	inherited.OnGuiClose(self,idx)
end 

function cUITextureCopy:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("UITextureCopyTab") or "1"
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","UITextureCopyBrowseInputPath"..tab)) then
		local dir = FileSelectFolder("*"..(gSettings:GetValue("TextureCopy","input_path"..tab) or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UITextureCopyInputPath"..tab,dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITextureCopyBrowseOutputPath"..tab)) then 
		local dir = FileSelectFolder("*"..(gSettings:GetValue("TextureCopy","output_path"..tab) or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UITextureCopyOutputPath"..tab,dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITextureCopyExecute"..tab)) then
		self:Gui("Submit|NoHide")
		self:ActionExecute(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UITextureCopySaveSettings"..tab)) then
		local input_path = ahkGetVar("UITextureCopyInputPath"..tab)
		local output_path = ahkGetVar("UITextureCopyOutputPath"..tab)
		
		gSettings:SetValue("TextureCopy","input_path"..tab,input_path)
		gSettings:SetValue("TextureCopy","output_path"..tab,output_path)
		gSettings:Save()
	end
end

_INACTION = nil
function cUITextureCopy:ActionExecute(tab)
	if (_INACTION) then 
		MsgBox("Already performing an action")
		return 
	end
	
	local input_path = ahkGetVar("UITextureCopyInputPath"..tab)
	if (input_path == nil or input_path == "") then 
		MsgBox("Incorrect Path!")
		return 
	end 
	
	local output_path = ahkGetVar("UITextureCopyOutputPath"..tab)
	if (output_path == nil or output_path == "") then 
		MsgBox("Incorrect Output Path!")
		return 
	end

	if (Checks[tab]) then
		for i=1,#Checks[tab] do 
			local bool = ahkGetVar("UITextureCopyCheck"..Checks[tab][i]..tab)
			gSettings:SetValue("TextureCopy","check_"..Checks[tab][i]..tab,bool)
		end
	end
	
	gSettings:SetValue("TextureCopy","input_path"..tab,input_path)
	gSettings:SetValue("TextureCopy","output_path"..tab,output_path)
	gSettings:Save()
	
	_INACTION = true
	
	self["ActionExecute"..tab](self,tab,input_path,output_path)
	
	_INACTION = false
end

function cUITextureCopy:ActionExecute1(tab,input_path,output_path)
	
	Msg("TextureCopy:= (SoC->CoP) Working...")
	
	local ltx = cIniFile:new("scripts\\texture_copy\\data\\soc_cop_texture_map.ltx",true)
	if not (ltx) then
		Msg("TextureCopy:= Error unable to load scripts\\texture_copy\\data\\soc_cop_texture_map.ltx")
		return
	end
	
	lfs.mkdir(output_path)
	
	-- the ltx is setup for soc = cop texture, we reverse this
	local cop_to_soc = {}
	local old_to_new = ltx:GetKeys("old_to_new")
	for k,v in pairs(old_to_new) do 
		cop_to_soc[v] = k
	end
	
	local overwrite = ahkGetVar("UITextureCopyCheck"..Checks[tab][1]..tab) == "1"
	--local copy_textures_in_thm = ahkGetVar("UITextureCopyCheck"..Checks[tab][2]..tab) == "1"
	
	local file_types = {".dds","_bump.dds","_bump#.dds",".thm","_bump.thm","_bump#.thm",".ogm",".ini",".seq"}
	local function on_execute(path,fname)
		local root_dir = trim_directory(path)
		local fn = trim_ext(fname)
		local key_name = root_dir.."\\"..fn
		if (cop_to_soc[key_name]) then
			for i=1,#file_types do
				if (overwrite or not file_exists(output_path.."\\"..cop_to_soc[key_name]..file_types[i])) then
					local f = io.open(path.."\\"..fn..file_types[i],"rb")
					if (f) then
						local data = f:read("*all")
						f:close()
						if (data) then
							-- copy textures defined in .thm too
							--[[
							if (copy_textures_in_thm) then
								if (get_ext(file_types[i]) == "thm") then 
									for a,b in string.gmatch(data,"([%w_#%.]*)\\([%w_#%.]*)") do 
										for n=1,#file_types do 
											f = io.open(path.."\\"..a.."\\"..b..file_types[i],"rb")
											if (f) then 
												local data2 = f:read("*all")
												f:close()
												if (data2) then 
													f = io.open(output_path.."\\"..a.."\\"..b..file_types[i],"wb")
													if (f) then 
														f:write(data2)
														f:close()
														Msg("Copied %s",output_path.."\\"..a.."\\"..b..file_types[i])
													end
												end
											end
										end
									end
								end
							end
							--]]
						
							-- create new file and copy data
							lfs.mkdir(output_path.."\\"..get_path(cop_to_soc[key_name]):sub(1,-2))
							f = io.open(output_path.."\\"..cop_to_soc[key_name]..file_types[i],"wb")
							if (f) then
								f:write(data)
								f:close()
								Msg("Copied %s",cop_to_soc[key_name]..file_types[i])
							end
						end
					end
				end
			end
		end
	end
	
	recurse_subdirectories_and_execute(input_path,{"dds"},on_execute)
	
	Msg("TextureCopy:= (SoC->CoP) Finished!")
end

function cUITextureCopy:ActionExecute2(tab,input_path,output_path)
	
	Msg("TextureCopy:= Missing Bump# Working...")
	
	lfs.mkdir(output_path)
	lfs.mkdir(output_path.."\\textures")

	local ltx = cIniFile:new(output_path.."\\missing_bumps.ltx",true)
	ltx.root = {}
	
	local function trim_texture_dir(str)
		local a = string.find(str,"textures\\")
		return a and trim(string.sub(str,a)) or ""
	end
	
	local function trim_bump_ext(str)
		local a = string.find(str,"_bump")
		return a and trim(string.sub(str,1,a-1)) or str
	end
	
	local function on_execute(path,fname)
		local fn = trim_ext(fname)
		if (string.find(fname,"_bump.dds") and not file_exists(path.."\\"..fn.."#.dds")) then
			local relative_path = trim_texture_dir(path)
			local tname = trim_bump_ext(fn)
			ltx:SetValue("missing_bump#",relative_path.."\\"..fn.."#.dds","")
			
			if (file_exists(path.."\\"..tname..".dds")) then 
				local f = io.open(path.."\\"..tname..".dds","rb")
				if (f) then
					local data = f:read("*all")
					f:close()
					if (data) then
						-- create new file and copy data
						lfs.mkdir(output_path.."\\"..relative_path.."\\")
						f = io.open(output_path.."\\"..relative_path.."\\"..tname..".dds","wb")
						if (f) then
							f:write(data)
							f:close()
							Msg("Copied %s",relative_path.."\\"..tname..".dds")
						end
					end 
				end
			end
		end
	end
	
	recurse_subdirectories_and_execute(input_path,{"dds"},on_execute)
	
	ltx:Save()
	
	Msg("TextureCopy:= Missing Bump# Finished!")
end