local Checks = {}

-----------------------------------------------------------------
--
-----------------------------------------------------------------
function OnApplicationBegin()
	Application.AddPluginButton("Converter","UIConverterShow",GetAndShow)
end
---------------------------------------------------------------------------
UI = nil
function Get()
	if not (UI) then 
		UI = cUIConverter("1")
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

Class "cUIConverter" (cUIBase)
function cUIConverter:initialize(id)
	self.inherited[1].initialize(self,id)
end

function cUIConverter:Reinit()
	self.inherited[1].Reinit(self)
	
	local tabs = {"OGF->Object","OMF->SKLS","DDS->TGA","OGF->SMD"}
	Checks["1"] = {"object", "bones", "skls"}
	Checks["2"] = {"skls"}
	Checks["3"] = {"t_with_solid","t_with_bump"}
	
	-- below will be automated based on above tab definition and checks
	self:Gui("Add|Tab2|x0 y0 w1024 h720 AltSubmit vUIConverterTab|%s",table.concat(tabs,"^"))
	
	for i=1,#tabs do
		local i_s = tostring(i)
		
		self:Gui("Tab|%s",tabs[i])
			-- GroupBox
			self:Gui("Add|GroupBox|x10 y50 w510 h75|%t_input_path")
			self:Gui("Add|GroupBox|x10 y150 w510 h75|%t_output_path")
			
			if (Checks[i_s]) then
				local y = 245
				--table.sort(Checks[i_s])
				for n=1,#Checks[i_s] do
					self:Gui("Add|CheckBox|x50 y%s w100 h22 %s vUIConverterCheck%s%s|%s",y,gSettings:GetValue("converter","check_"..Checks[i_s][n]..i_s,"") == "1" and "Checked" or "",Checks[i_s][n],i_s,Language.translate(Checks[i_s][n]))
					y = y + 20
				end
			end
				
			-- Buttons 
			self:Gui("Add|Button|gOnScriptControlAction x485 y80 w30 h20 vUIConverterBrowseInputPath%s|...",i)
			self:Gui("Add|Button|gOnScriptControlAction x485 y180 w30 h20 vUIConverterBrowseOutputPath%s|...",i)
			self:Gui("Add|Button|gOnScriptControlAction x485 y655 w90 h20 vUIConverterSaveSettings%s|%t_save_settings",i)	
			self:Gui("Add|Button|gOnScriptControlAction x485 y680 w90 h20 vUIConverterExecute%s|%t_execute",i)		
			
			-- Editbox 
			self:Gui("Add|Edit|gOnScriptControlAction x25 y80 w450 h20 vUIConverterInputPath%s|",i)
			self:Gui("Add|Edit|gOnScriptControlAction x25 y180 w450 h20 vUIConverterOutputPath%s|",i)
			
		GuiControl(self.ID,"","UIConverterInputPath"..i, gSettings:GetValue("converter","input_path"..i) or "")
		GuiControl(self.ID,"","UIConverterOutputPath"..i, gSettings:GetValue("converter","output_path"..i) or "")
	end
	self:Gui("Show|w1024 h720|Converter")
end

function cUIConverter:OnGuiClose(idx) -- needed because it's registered to callback
	self.inherited[1].OnGuiClose(self,idx)
end 

function cUIConverter:OnScriptControlAction(hwnd,event,info) -- needed because it's registered to callback
	self:Gui("Submit|NoHide")
	local tab = ahkGetVar("UIConverterTab") or "1"
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","UIConverterBrowseInputPath"..tab)) then
		local dir = FileSelectFolder("*"..(gSettings:GetValue("converter","input_path"..tab) or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UIConverterInputPath"..tab,dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIConverterBrowseOutputPath"..tab)) then 
		local dir = FileSelectFolder("*"..(gSettings:GetValue("converter","output_path"..tab) or ""))
		if (dir and dir ~= "") then
			GuiControl(self.ID,"","UIConverterOutputPath"..tab,dir)
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIConverterExecute"..tab)) then
		self:Gui("Submit|NoHide")
		self:ActionExecute(tab)
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIConverterSaveSettings"..tab)) then
		local input_path = ahkGetVar("UIConverterInputPath"..tab)
		local output_path = ahkGetVar("UIConverterOutputPath"..tab)
		
		gSettings:SetValue("converter","input_path"..tab,input_path)
		gSettings:SetValue("converter","output_path"..tab,output_path)
		gSettings:Save()
	end
end

_INACTION = nil
function cUIConverter:ActionExecute(tab)
	if (_INACTION) then 
		MsgBox("Already performing an action")
		return 
	end
	
	local input_path = ahkGetVar("UIConverterInputPath"..tab)
	if (input_path == nil or input_path == "") then 
		MsgBox("Incorrect Path!")
		return 
	end 
	
	local output_path = ahkGetVar("UIConverterOutputPath"..tab)
	if (output_path == nil or output_path == "") then 
		MsgBox("Incorrect Output Path!")
		return 
	end

	if (Checks[tab]) then
		for i=1,#Checks[tab] do 
			local bool = ahkGetVar("UIConverterCheck"..Checks[tab][i]..tab)
			gSettings:SetValue("converter","check_"..Checks[tab][i]..tab,bool)
		end
	end
	
	gSettings:SetValue("converter","input_path"..tab,input_path)
	gSettings:SetValue("converter","output_path"..tab,output_path)
	gSettings:Save()
	
	_INACTION = true
	
	self["ActionExecute"..tab](self,tab,input_path,output_path)
	
	_INACTION = false
end

function cUIConverter:ActionExecute1(tab,input_path,output_path)
	local working_directory = ahkGetVar("A_WorkingDir")..[[\bin\]]
	local cp = working_directory .. "converter.exe"
	
	local function on_execute(path,fname)
		--@start /wait converter.exe -ogf -object wpn_pkm_trenoga.ogf -out wpn_pkm_trenoga.object
		if (Checks[tab]) then
			for i=1,#Checks[tab] do
				local bool = ahkGetVar("UIConverterCheck"..Checks[tab][i]..tab)
				if (gSettings:GetValue("converter","check_"..Checks[tab][i]..tab,"") == "1") then
					RunWait( strformat([["%s" -ogf -%s "%s" -out "%s"]],cp,Checks[tab][i],path.."\\"..fname,output_path.."\\"..trim_ext(fname).."."..Checks[tab][i]), working_directory )
				end
			end
		end
	end
	
	Msg("Converter:= (OGF) Working...")
	
	recurse_subdirectories_and_execute(input_path,{"ogf"},on_execute)	
	
	Msg("Converter:= (OGF) Finished!")
end

function cUIConverter:ActionExecute2(tab,input_path,output_path)
	local working_directory = ahkGetVar("A_WorkingDir")..[[\bin\]]
	local cp = working_directory .. "converter.exe"
	
	local function on_execute(path,fname)
		if (Checks[tab]) then
			local fn = trim_ext(fname)
			lfs.mkdir(output_path)
			if (gSettings:GetValue("converter","check_"..Checks[tab][1]..tab,"") == "1") then
				RunWait( strformat([["%s" -omf -%s "%s" -out "%s"]],cp,Checks[tab][1],path.."\\"..fname,output_path.."\\"..trim_ext(fname).."."..Checks[tab][1]), working_directory )
			else
				lfs.mkdir(output_path.."\\"..fn)
				RunWait( strformat([["%s" -omf -skl all "%s"]],cp,path.."\\"..fname), output_path.."\\"..fn )
			end
		end
	end
	
	Msg("Converter:= (OMF) Working...")
	
	recurse_subdirectories_and_execute(input_path,{"omf"},on_execute)	
	
	Msg("Converter:= (OMF) Finished!")
end

function cUIConverter:ActionExecute3(tab,input_path,output_path)
	local working_directory = ahkGetVar("A_WorkingDir")..[[\bin\]]
	local cp = working_directory .. "converter.exe"
	
	local function on_execute(path,fname)
		RunWait( strformat([["%s" -dds2tga %s %s "%s" -dir "%s"]],cp,Checks[tab][1] and "-"..Checks[tab][1] or "", Checks[tab][2] and "-"..Checks[tab][2] or "",path.."\\"..fname,output_path), working_directory )
	end
	
	Msg("Converter:= (DDS) Working...")
	
	recurse_subdirectories_and_execute(input_path,{"dds"},on_execute)	
	
	Msg("Converter:= (DDS) Finished!")
end

function cUIConverter:ActionExecute4(tab,input_path,output_path)
	local working_directory = ahkGetVar("A_WorkingDir")..[[\bin\]]
	local cp = working_directory .. "ogf2smd.exe"
	
	local function on_execute(path,fname)
		RunWait( strformat([["%s" "%s"  "%s"]],cp,path.."\\"..fname,output_path), working_directory )
	end
	
	Msg("Converter:= (OGF->SMD) Working...")
	
	recurse_subdirectories_and_execute(input_path,{"ogf"},on_execute)	
	
	Msg("Converter:= (OGF->SMD) Finished!")
end