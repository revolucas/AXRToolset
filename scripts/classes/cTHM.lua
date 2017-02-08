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

Class "cTHM"
function cTHM:initialize(fname,fail_on_thm_size_zero)
	local thm = cBinaryData(fname)
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