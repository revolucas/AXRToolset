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
			system_settings = cIniFile(path.."\\configs\\system.ltx")
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
	
	item_list = cIniFile("configs\\xray_sections.ltx")
	
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