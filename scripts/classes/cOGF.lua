Class "cOGF" (cBinaryData)
function cOGF:initialize(fname,partial,start,chunk)
	self.inherited[1].initialize(self,fname,partial,start,chunk)
	
	if (self:size() <= 0) then
		return
	end
	
	self:OGF_HEADER(true)
	
	if not (self.format_version == xrOGF_FormatVersion) then 
		Msg("incorrect format version %s",self.format_version)
		return
	end
	
	self:OGF_S_DESC(true)
	self:OGF_TEXTURE(true)
	self:OGF_S_BONE_NAMES(true)
	self:OGF_S_MOTION_REFS(true)
	self:OGF_S_MOTION_REFS2(true)
	self:OGF_S_USERDATA(true)
	self:OGF_S_LODS(true)
	self:OGF_CHILDREN(true)
end

function cOGF:OGF_HEADER(loading)
	if (loading) then
		if (self:find_chunk(OGF_HEADER) > 0) then
			self.format_version = self:r_u8()
			self.type = self:r_u8()
			self.shader_id = self:r_u16()
			self.ogf_bbox = {min={self:r_float(),self:r_float(),self:r_float()},max={self:r_float(),self:r_float(),self:r_float()}}
			self.ogf_bsphere = {c={self:r_float(),self:r_float(),self:r_float()},r=self:r_float()}
		end
	end
end

function cOGF:OGF_TEXTURE(loading)
	if (loading) then
		if (self:find_chunk(OGF_TEXTURE) > 0) then
			self.texture = trim(self:r_stringZ())
			self.shader = trim(self:r_stringZ())
		end
	elseif (self.texture and self.shader and self.texture ~= "" and self.shader ~= "") then
		local chunk = self:open_chunk(OGF_TEXTURE)
		if (chunk) then
			chunk:w_stringZ(trim(self.texture))
			chunk:w_stringZ(trim(self.shader))
			self:replace_chunk(OGF_TEXTURE,chunk)
		end
	end
end

function cOGF:OGF_S_DESC(loading)
	if (loading) then
		if (self:find_chunk(OGF_S_DESC) > 0) then
			self.description = {
				source_file = self:r_stringZ(),
				build_name = self:r_stringZ(),
				build_time = self:r_u32(),
				create_name = self:r_stringZ(),
				create_time = self:r_u32(),
				modif_name = self:r_stringZ(),
				modif_time = self:r_u32()
			}
		end
	elseif (self.description) then
		local chunk = self:open_chunk(OGF_S_DESC)
		if (chunk) then
			chunk:w_stringZ(trim(self.description.source_file))
			chunk:w_stringZ(trim(self.description.build_name))
			chunk:w_u32(self.description.build_time)
			chunk:w_stringZ(trim(self.description.create_name))
			chunk:w_u32(self.description.create_time)
			chunk:w_stringZ(trim(self.description.modif_name))
			chunk:w_u32(self.description.modif_time)
			self:replace_chunk(OGF_S_DESC,chunk)
		end
	end
end

function cOGF:OGF_S_MOTION_REFS(loading)
	if (loading) then
		if (self:find_chunk(OGF_S_MOTION_REFS) > 0) then
			self.motion_refs = trim(self:r_stringZ())
		end
	elseif (self.motion_refs) then 
		local chunk = self:open_chunk(OGF_S_MOTION_REFS)
		if (chunk) then
			chunk:w_stringZ(trim(self.motion_refs))
			self:replace_chunk(OGF_S_MOTION_REFS,chunk)
		end
	end
end

function cOGF:OGF_S_MOTION_REFS2(loading)
	if (loading) then
		if (self:find_chunk(OGF_S_MOTION_REFS2) > 0) then
			local cnt = self:r_u32()
			if (cnt > 0) then 
				self.motion_refs2 = {}
				for i=1,cnt do
					local v = trim(self:r_stringZ())
					if (v and v ~= "") then
						table.insert(self.motion_refs2,v)
					end
				end
			end
		end
	elseif (self.motion_refs2) then
		local chunk = self:open_chunk(OGF_S_MOTION_REFS2)
		if (chunk) then
			local cnt = #self.motion_refs2
			chunk:w_u32(cnt)
			for i=1,cnt do
				chunk:w_stringZ(trim(self.motion_refs2[i]))
			end	
			self:replace_chunk(OGF_S_MOTION_REFS2,chunk)
		end
	end
end

function cOGF:OGF_S_LODS(loading)
	if (loading) then
		if (self:find_chunk(OGF_S_LODS) > 0) then
			self.lod_path = self:r_string(2*260)
		end
	elseif (self.lod_path and self.lod_path ~= "") then 
		local chunk = self:open_chunk(OGF_S_LODS)
		if (chunk) then
			chunk:w_stringZ(trim(self.lod_path))
			self:replace_chunk(OGF_S_LODS,chunk)
		end
	end
end

function cOGF:OGF_S_BONE_NAMES(loading)
	if (loading) then
		if (self:find_chunk(OGF_S_BONE_NAMES) > 0) then
			local cnt = self:r_u32()
			if (cnt > 0) then
				self.bones = {}
				for i=1,cnt do 
					self.bones[self:r_stringZ()] = self:r_stringZ()
					self:r(60)
				end
			end
		end
	elseif (self.bones) then
		local chunk = self:open_chunk(OGF_S_BONE_NAMES)
		if (chunk) then
			local cnt = 0
			for k,v in pairs(self.bones) do 
				cnt = cnt + 1
			end
			chunk:w_u32(cnt)
			for k,v in pairs(self.bones) do 
				chunk:w_stringZ(trim(k))
				chunk:w_stringZ(trim(v))
			end
			self:replace_chunk(OGF_S_BONE_NAMES,chunk)
		end
	end
end

function cOGF:OGF_S_USERDATA(loading)
	if (loading) then 
		if (self:find_chunk(OGF_S_USERDATA) > 0) then
			self.userdata = self:r_stringZ()
		end
	elseif (self.userdata) then
		local chunk = self:open_chunk(OGF_S_USERDATA)
		if (chunk) then
			chunk:w_stringZ(trim(self.userdata))
			self:replace_chunk(OGF_S_USERDATA,chunk)
		end
	end
end

function cOGF:OGF_CHILDREN(loading)
	if (loading) then 
		local main_chunk = self:open_chunk(OGF_CHILDREN)
		if (main_chunk and main_chunk:size() > 0) then
			self.children = {}
			local chunk = main_chunk:open_chunk(0)
			while (chunk and chunk:size() > 0) do
				table.insert(self.children,cOGF(nil,nil,nil,chunk))
				chunk = main_chunk:open_chunk(#self.children)
			end
		end 
	elseif (self.children) then
		local main_chunk = self:open_chunk(OGF_CHILDREN)
		if (main_chunk and main_chunk:size() > 0) then
 			for i,child in ipairs(self.children) do
				child:save()
				local chunk = main_chunk:open_chunk(i-1)
				if (chunk) then
					main_chunk:replace_chunk(i-1,child)
				end
			end
			self:replace_chunk(OGF_CHILDREN,main_chunk)
		end
	end
end

function cOGF:save(to_fname)
	self:OGF_S_DESC()
  	self:OGF_TEXTURE()
	--self:OGF_S_BONE_NAMES()
	self:OGF_S_MOTION_REFS()
	self:OGF_S_MOTION_REFS2()
	self:OGF_S_USERDATA()
	self:OGF_S_LODS()
	self:OGF_CHILDREN()
	self.inherited[1].save(self,to_fname)
end

function cOGF:params()
	local t = {}
	t.texture = self.texture or ""
	t.shader = self.shader or ""
	t.motion_refs = self.motion_refs or ""
	t.motion_refs2 = self.motion_refs2 and table.concat(self.motion_refs2,",") or ""
	t.lod_path = self.lod_path or ""
	t.userdata = self.userdata or ""
	if (self.children) then
		t.children = {}
		for i,v in ipairs(self.children) do
			t.children[i] = v:params()
		end
	end
	if (self.description) then 
		t.source_file = self.description.source_file or ""
		t.build_name = self.description.build_name or ""
		t.build_time = self.description.build_time or ""
		t.create_name = self.description.create_name or ""
		t.create_time = self.description.create_time or ""
		t.modif_name = self.description.modif_name or ""
		t.modif_time = self.description.modif_time or ""
	end
	if (self.bones) then 
		local new = {}
		for k,v in pairs(self.bones) do 
			table.insert(new,k)
		end
		table.sort(new)
		t.bones = table.concat(new,",")
	end
	return t
end