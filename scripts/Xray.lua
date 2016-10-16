valid_item_classes =
{
	["ARTEFACT"] = true,
	["SCRPTART"] = true,

	["II_ATTCH"] = true,
	["II_BTTCH"] = true,

	["II_DOC"]   = true,

	["TORCH_S"]  = true,

	["DET_SIMP"] = true,
	["DET_ADVA"] = true,
	["DET_ELIT"] = true,
	["DET_SCIE"] = true,

	["E_STLK"]   = true,
	["E_HLMET"]  = true,
	["EQU_STLK"]   = true,
	["EQU_HLMET"]  = true,
	
	["II_BANDG"] = true,
	["II_MEDKI"] = true,
	["II_ANTIR"] = true,
	["II_BOTTL"] = true,
	["II_FOOD"]  = true,
	["S_FOOD"]   = true,

	["S_PDA"]    = true,
	["D_PDA"]    = true,

	["II_BOLT"]  = true,

	["WP_AK74"] = true,
	["WP_ASHTG"] = true,
	["WP_BINOC"] = true,
	["WP_BM16"] = true,
	["WP_GROZA"] = true,
	["WP_HPSA"] = true,
	["WP_KNIFE"] = true,
	["WP_LR300"] = true,
	["WP_PM"] = true,
	["WP_RG6"] = true,
	["WP_RPG7"] = true,
	["WP_SVD"] = true,
	["WP_SVU"] = true,
	["WP_VAL"] = true,

	["AMMO"]	= true,
	["AMMO_S"]   = true,
	["S_OG7B"]   = true,
	["S_VOG25"]  = true,
	["S_M209"]   = true,

	["G_F1_S"]   = true,
	["G_RGD5_S"] = true,
	["G_F1"]   = true,
	["G_RGD5"] = true,

	["WP_SCOPE"] = true,
	["WP_SILEN"] = true,
	["WP_GLAUN"] = true
}

function parse_condlist(s)
	local t = {}
	for fld in string.gfind(s, "%s*([^,]+)%s*") do
		local s = fld:gsub("{.+}%s*","")
		table.insert(t,s)
	end
	return t
end

function IsWeapon(k)
	local cls = system_ini():GetValue(k,"class",3)
	local t = 	{
		["WP_AK74"] = true,
		["WP_ASHTG"] = true,
		["WP_BINOC"] = true,
		["WP_BM16"] = true,
		["WP_GROZA"] = true,
		["WP_HPSA"] = true,
		["WP_KNIFE"] = true,
		["WP_LR300"] = true,
		["WP_PM"] = true,
		["WP_RG6"] = true,
		["WP_RPG7"] = true,
		["WP_SVD"] = true,
		["WP_SVU"] = true,
		["WP_VAL"] = true,
		["WP_SCOPE"] = true,
		["WP_SILEN"] = true,
		["WP_GLAUN"] = true
	}
	return cls and t[cls] == true or k == "wpn_mine"
end

function IsAmmo(k)
	local cls = system_ini():GetValue(k,"class",3)
	local t = 	{
		["AMMO"]	= true,
		["AMMO_S"]   = true,
		["S_OG7B"]   = true,
		["S_VOG25"]  = true,
		["S_M209"]   = true,
		["G_F1"]   = true,
		["G_RGD5"] = true,
		["G_F1_S"]   = true,
		["G_RGD5_S"] = true
	}
	return cls and t[cls] == true
end

function IsOutfit(k)
	local cls = system_ini():GetValue(k,"class",3)
	local t = 	{
		["E_STLK"]   = true,
		["E_HLMET"]  = true,
		["EQU_STLK"]   = true,
		["EQU_HLMET"]  = true
	}
	return cls and t[cls] == true
end

function IsMedicine(k)
	local cls = system_ini():GetValue(k,"class",3)
	local t = 	{
		["II_BANDG"] = true,
		["II_MEDKI"] = true,
		["II_ANTIR"] = true
	}
	return cls and t[cls] == true
end

function IsFood(k)
	local cls = system_ini():GetValue(k,"class",3)
	local t = 	{
		["II_BOTTL"] = true,
		["II_FOOD"]  = true,
		["S_FOOD"]   = true
	}
	return cls and t[cls] == true
end

function IsArtefact(k)
	local cls = system_ini():GetValue(k,"class",3)
	local t = 	{
		["ARTEFACT"] = true,
		["SCRPTART"] = true
	}
	return cls and t[cls] == true
end

function IsDetector(k)
	local cls = system_ini():GetValue(k,"class",3)
	local t = 	{
		["DET_SIMP"] = true,
		["DET_ADVA"] = true,
		["DET_ELIT"] = true,
		["DET_SCIE"] = true
	}
	return cls and t[cls] == true
end

function IsMutantPart(k)
	local t = 	{
		["mutant_part_boar_leg"] 			= true,
		["mutant_part_burer_hand"] 			= true,
		["mutant_part_cat_tail"] 			= true,
		["mutant_part_chimera_claw"] 		= true,
		["mutant_part_chimera_kogot"] 		= true,
		["mutant_part_controller_glass"] 	= true,
		["mutant_part_controller_hand"] 	= true,
		["mutant_part_dog_tail"] 			= true,
		["mutant_part_flesh_eye"] 			= true,
		["mutant_part_fracture_hand"] 		= true,
		["mutant_part_krovosos_jaw"] 		= true,
		["mutant_part_pseudogigant_eye"] 	= true,
		["mutant_part_pseudogigant_hand"] 	= true,
		["mutant_part_psevdodog_tail"] 		= true,
		["mutant_part_snork_hand"] 			= true,
		["mutant_part_snork_leg"] 			= true,
		["mutant_part_tushkano_head"] 		= true,
		["mutant_part_zombi_hand"] 			= true
	}
	return k and t[k] == true
end

local system_settings
function system_ini()
	if not (system_settings) then
		local path = gSettings:GetValue("core","Gamedata_Path")
		if (path and path ~= "") then
			system_settings = cIniFile:new(path.."\\configs\\system.ltx")
		else 
			Msg("Error: Incorrect path %s please setup Gamedata Path in Settings",path)
		end
	end
	return system_settings
end

local item_list
function get_item_sections_list(ini,reload)
	if (not reload and item_list and item_list.loaded == true) then 
		return item_list 
	end
	
	ini = ini or system_ini()
	if not (ini and ini.root) then 
		Msg("Failed to load system.ini from your given Game_Path. See the 'Settings' tab.")
		return
	end
	
	item_list = cIniFile:new("xray_sections.ltx")
	
	item_list.loaded = false 

	if not (item_list) then 
		return
	end
	
	Msg("Generating a list of valid item sections from unpacked gamedata")
	
	item_list.root = {}

	for section,t in pairs(ini.root) do
		if (gSettings:GetValue("ignore_sections",section,"string") == nil) then
			if not (string.find(section,"mp_") == 1) then  -- IGNORE MP items
				if not (string.find(section,"ap_mp_")) then -- IGNORE MP items
					local v = ini:GetValue(section,"inv_name")
					if (v and v ~= "" and v ~= "default") then -- most likely an item, add to list
						--Msg("%s",section)
						item_list:SetValue("sections",section,"")
					end
				end
			end
		end
	end

	Msg("Saving the list of valid item sections to xray_sections.ltx")
	
	item_list:SaveOrderByClass(ini,valid_item_classes)
	
	item_list.loaded = true
	
	Msg("Finished...")
	
	return item_list
end

local translated_list = nil
function translate_string(string_name,gamedata_path)
	if (translated_list) then 
		return translated_list[string_name] or string_name
	end 
	
	translated_list = {}
	
	local function on_execute(path,fname)
		local f = io.open(path.."\\"..fname,"rb")
		if (f) then
			local data = f:read("*all")
			if (data) then
				for st_name,text in string.gmatch(data,[[id="([%w_%.]*)".-<text>(.-)</text>]]) do
					translated_list[st_name] = text
				end
			end
			f:close()
		end
	end
	
	recurse_subdirectories_and_execute(gamedata_path.."\\configs\\text\\eng",{"xml"},on_execute)
	
	return translated_list[string_name] or string_name
end

local valid_params = {
		["version"] = true,
		["texture_format"] = true,
		["flags"] = true,
		["border_color"] = true,
		["fade_color"] = true,
		["fade_amount"] = true,
		["mip_filter"] = true,
		["texture_width"] = true,
		["texture_height"] = true,
		["texture_type"] = true,
		["detail_name"] = true,
		["detail_scale"] = true,
		["material"] = true,
		["material_weight"] = true,
		["bump_height"] = true,
		["bump_mode"] = true,
		["bump_name"] = true,
		["normal_map_name"] = true,
		["fade_delay"] = true
}

cTHM = Class "cTHM"
function cTHM:initialize(fname,fail_on_thm_size_zero)
	local thm = cBinaryData:new(fname)
	assert(thm)
	
	self.thm = thm
	
	-- defaults
	self.params = {
		["version"] = THM_TEXTURE_VERSION,
		["texture_format"] = ETFormat[0],
		["flags"] = 0,
		["border_color"] = 0,
		["fade_color"] = 0,
		["fade_amount"] = 0,
		["mip_filter"] = ETMIPFilter[3],
		["texture_width"] = 0,
		["texture_height"] = 0,
		["texture_type"] = ETType[0],
		["detail_name"] = "",
		["detail_scale"] = 1.0,
		["material"] = ETMaterial[1],
		["material_weight"] = 0.5,
		["bump_height"] = 0.05,
		["bump_mode"] = ETBumpMode[1],
		["bump_name"] = "",
		["normal_map_name"] = "",
		["fade_delay"] = 0
	}
		
	if (thm:size() <= 0) then
		if (fail_on_thm_size_zero) then 
			error("Has zero size! " .. fname)
			return
		end
	else 
		self.params.version = thm:r_chunk(THM_CHUNK_VERSION)
		if (self.params.version ~= THM_TEXTURE_VERSION) then 
			Msg("THM is wrong version! %s should be %s",self.params.version,THM_TEXTURE_VERSION)
		end
		
		assert(thm:find_chunk(THM_CHUNK_TYPE) > 0,"Cannot find chunk type in "..fname)
		local chunk_type = thm:r_u32()

		local size = thm:find_chunk(THM_CHUNK_TEXTUREPARAM)
		assert(size > 0,"Cannot find texture param chunk in "..fname)
		assert(size >= 32,"Texture Param chunk size should be 32 bytes it's "..size)
		self.params.texture_format = ETFormat[thm:r_u32()]

		local flags = {}
		local flag = thm:r_u32()
		if (flag > 0) then
			for k,v in pairs(ETFlags) do 
				if (k > 0 and bit.band(k,flag) == k) then 
					table.insert(flags,v)
				end
			end
		end

		self.params.flags 			= table.concat(flags,",")
		self.params.border_color 	= thm:r_u32()
		self.params.fade_color		= thm:r_u32()
		self.params.fade_amount		= thm:r_u32()
		self.params.mip_filter		= ETMIPFilter[thm:r_u32()]
		self.params.texture_width	= thm:r_u32()
		self.params.texture_height	= thm:r_u32()

		if (thm:find_chunk(THM_CHUNK_TEXTURE_TYPE) > 0) then
			self.params.texture_type = ETType[thm:r_u32()]
		end
		
		if (thm:find_chunk(THM_CHUNK_DETAIL_EXT) > 0) then
			self.params.detail_name = thm:r_stringZ()
			self.params.detail_scale = thm:r_float()
		end 
		
		if (thm:find_chunk(THM_CHUNK_MATERIAL) > 0) then
			self.params.material = ETMaterial[thm:r_u32()]
			self.params.material_weight = thm:r_float()
		end
		
		if (thm:find_chunk(THM_CHUNK_BUMP) > 0) then
			self.params.bump_height = thm:r_float()
			self.params.bump_mode = ETBumpMode[thm:r_u32()]
			self.params.bump_name = thm:r_stringZ()
		end
		
		if (thm:find_chunk(THM_CHUNK_EXT_NORMALMAP) > 0) then 
			self.params.normal_map_name = thm:r_stringZ()
		end
		
		if (thm:find_chunk(THM_CHUNK_FADE_DELAY) > 0) then 
			self.params.fade_delay = thm:r_u8()
		end
		
		for k,v in pairs(valid_params) do 
			if not (self.params[k]) then
				Msg("%s invalid thm file! DO NOT USE",fname)
			end
		end
	end
	return self
end

function cTHM:size()
	return self.thm:size()
end

function cTHM:GetRealValue(tbl,val,caller)
	val = trim(val)
	for i,key in pairs(tbl) do 
		if (val == key) then 
			return i
		end
	end
	Msg("cTHM:lookup invalid value [%s] for %s",val,caller)
end

function cTHM:GetFlagValue(str)
	str = trim(str)
	local flag = 0
	for i,key in pairs(ETFlags) do 
		if (string.find(str,key)) then 
			flag = flag + i
		end
	end
	return flag
end

function cTHM:save(to_fname)
	local thm = self.thm
	empty(thm.data)
	thm:w_seek(1)

	thm:w_chunk(THM_CHUNK_VERSION,2)
	thm:w_u16(THM_TEXTURE_VERSION)
	
	thm:w_chunk(THM_CHUNK_TYPE,4)
	thm:w_u32(1)
	
	thm:w_chunk(THM_CHUNK_TEXTUREPARAM,32)
	
	thm:w_u32( self:GetRealValue(ETFormat,self.params.texture_format,"Texture Format") )
	thm:w_u32( self:GetFlagValue(self.params.flags) )
	
	thm:w_u32(self.params.border_color)
	thm:w_u32(self.params.fade_color)
	thm:w_u32(self.params.fade_amount)
	thm:w_u32( self:GetRealValue(ETMIPFilter,self.params.mip_filter,"MipMap Filter") )

	thm:w_u32(self.params.texture_width)
	thm:w_u32(self.params.texture_height)
	
	thm:w_chunk(THM_CHUNK_TEXTURE_TYPE,4)
	thm:w_u32( self:GetRealValue(ETType,self.params.texture_type,"Texture Type") )
	
	local size = self.params.detail_name:len()+1
	thm:w_chunk(THM_CHUNK_DETAIL_EXT,size+4)
	thm:w_stringZ(self.params.detail_name)
	thm:w_float(self.params.detail_scale)
	
	thm:w_chunk(THM_CHUNK_MATERIAL,8)
	thm:w_u32( self:GetRealValue(ETMaterial,self.params.material,"Material") )
	thm:w_float(self.params.material_weight)
	
	size = self.params.bump_name:len()+1
	thm:w_chunk(THM_CHUNK_BUMP,size+8)
	thm:w_float(self.params.bump_height)
	thm:w_u32( self:GetRealValue(ETBumpMode,self.params.bump_mode,"Bump Mode") )
	thm:w_stringZ(self.params.bump_name)
	
	size = self.params.normal_map_name:len()+1
	thm:w_chunk(THM_CHUNK_EXT_NORMALMAP,size)
	thm:w_stringZ(self.params.normal_map_name)
	
	thm:w_chunk(THM_CHUNK_FADE_DELAY,1)
	thm:w_u8(self.params.fade_delay)

	thm:save(to_fname)
end