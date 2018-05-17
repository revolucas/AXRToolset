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
	self:OGF_VERTICES(true)
	self:OGF_S_BONE_NAMES(true)
	--self:OGF_S_IKDATA(true)
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
			chunk:resize(chunk:w_tell())
			self:replace_chunk(OGF_TEXTURE,chunk)
		end
	end
end

function cOGF:OGF_VERTICES(loading)
	if (loading) then
		if (self:find_chunk(OGF_VERTICES) > 0) then
			self.vertices = {type=self:r_u32(),count=self:r_u32()}
			Msg("Vertices: type=%s count=%s",self.vertices.type,self.vertices.count)
		end
	elseif (self.texture and self.shader and self.texture ~= "" and self.shader ~= "") then
		local chunk = self:open_chunk(OGF_VERTICES)
		if (chunk) then

			chunk:resize(chunk:w_tell())
			self:replace_chunk(OGF_VERTICES,chunk)
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
			chunk:resize(chunk:w_tell())
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
			chunk:resize(chunk:w_tell())
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
			chunk:resize(chunk:w_tell())
			self:replace_chunk(OGF_S_MOTION_REFS2,chunk)
		end
	end
end

function cOGF:OGF_S_LODS(loading)
	if (loading) then
		local size = self:find_chunk(OGF_S_LODS)
		if (size > 0) then
			self.lod_path = self:r_string(size)
		end
	elseif (self.lod_path and self.lod_path ~= "") then 
		local chunk = self:open_chunk(OGF_S_LODS)
		if (chunk) then
			chunk:w_string(trim(self.lod_path))
			chunk:resize(chunk:w_tell())
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
				Msg("======== BONE DATA ========")
				for i=1,cnt do
					self.bones[i] = {name=self:r_stringZ(),parent=self:r_stringZ()}
					Msg("bone=%s  parent=%s",self.bones[i].name,self.bones[i].parent)
					self.bones[i].fobb = {} --15*4 Fobb (5 vec3)
					for n=1,5 do
						table.insert(self.bones[i].fobb,{self:r_float(),self:r_float(),self:r_float()})
					end
				end
				Msg("===========================")
			end
		end
	elseif (self.bones) then
		local chunk = self:open_chunk(OGF_S_BONE_NAMES)
		if (chunk) then
			chunk:w_u32(#self.bones)
			for i,data in ipairs(self.bones) do
				chunk:w_stringZ(trim(data.name))
				chunk:w_stringZ(trim(data.parent))
				for n=1,5 do
					chunk:w_float(data.fobb[n][1])
					chunk:w_float(data.fobb[n][2])
					chunk:w_float(data.fobb[n][3])
				end
			end
			chunk:resize(chunk:w_tell())
			self:replace_chunk(OGF_S_BONE_NAMES,chunk)
		end
	end
end

function cOGF:OGF_S_IKDATA(loading)
	if (loading) then 
		if (self.bones) then
			local main_chunk = self:open_chunk(OGF_S_IKDATA)
			if (main_chunk) then 
				for i,data in ipairs(self.bones) do
					data.version = self:r_u32()
					data.game_mtl_name = self:r_stringZ()
					--Msg("version=%s mtl_name=%s",data.version,data.game_mtl_name)
					-- shape
					data.type = self:r_u16()
					data.flags = self:r_u16() --Flags16 flags; // 2
					
					data.box = {}
					for n=1,15 do -- Fobb box; // 15*4
						table.insert(data.box,self:r_float())
					end
					data.sphere = {}
					for n=1,4 do  -- Fsphere; //4*4
						table.insert(data.sphere,self:r_float())
					end
					data.cylinder = {}
					for n=1,8 do -- Fcylinder cylinder; // 8*4
						table.insert(data.cylinder,self:r_float())
					end
					-- IK data
					data.joint = {}
					data.joint.type = self:r_u32()
					data.joint.limits = {}
					for n=1,3 do
						table.insert(data.joint.limits,{self:r_float(),self:r_float(),self:r_float(),self:r_float()})
					end
					data.joint.spring_factor = self:r_float()
					data.joint.damping_factor = self:r_float()
					data.joint.flags = self:r_u32()
					data.joint.break_force = self:r_float()
					data.joint.break_torque = self:r_float()
					data.joint.friction = self:r_float()
					data.rotation = {self:r_float(),self:r_float(),self:r_float()}
					data.offset = {self:r_float(),self:r_float(),self:r_float()}
					data.mass = self:r_float()
					data.center_of_mass = {self:r_float(),self:r_float(),self:r_float()}
				end
			end
		end
	elseif (self.bones) then
		local chunk = self:open_chunk(OGF_S_IKDATA)
		if (chunk) then
			for i,data in pairs(self.bones) do 
				chunk:w_u32(data.version)
				chunk:w_stringZ(data.game_mtl_name)
				chunk:w_u16(data.type)
				chunk:w_u16(data.flags)
				for n=1,15 do
					chunk:r_float(data.box[n])
				end
				for n=1,4 do
					chunk:r_float(data.sphere[n])
				end
				for n=1,8 do
					chunk:r_float(data.cylinder[n])
				end
				chunk:w_u32(data.joint.type)
				for n=1,3 do
					chunk:w_float(data.joint.limits[n][1])
					chunk:w_float(data.joint.limits[n][2])
					chunk:w_float(data.joint.limits[n][3])
					chunk:w_float(data.joint.limits[n][4])
				end
				chunk:w_float(data.joint.spring_factor)
				chunk:w_float(data.joint.damping_factor)
				chunk:w_u32(data.joint.flags)
				chunk:w_float(data.joint.break_force)
				chunk:w_float(data.joint.break_torque)
				chunk:w_float(data.joint.friction)
				for n=1,3 do
					chunk:w_float(data.rotation[1])
					chunk:w_float(data.rotation[2])
					chunk:w_float(data.rotation[3])
				end
				for n=1,3 do
					chunk:w_float(data.offset[1])
					chunk:w_float(data.offset[2])
					chunk:w_float(data.offset[3])
				end
				chunk:w_float(data.mass)
				for n=1,3 do
					chunk:w_float(data.center_of_mass[1])
					chunk:w_float(data.center_of_mass[2])
					chunk:w_float(data.center_of_mass[3])
				end
			end
			chunk:resize(chunk:w_tell())
			self:replace_chunk(OGF_S_IKDATA,chunk)
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
			chunk:resize(chunk:w_tell())
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
				Msg("child %s:",#self.children+1)
				table.insert(self.children,cOGF(nil,nil,nil,chunk))
				chunk = main_chunk:open_chunk(#self.children)
			end
		end 
	elseif (self.children) then
		local main_chunk = self:open_chunk(OGF_CHILDREN)
		if (main_chunk and main_chunk:size() > 0) then
			local total_size = 0
 			for i,child in ipairs(self.children) do
				child:save()
				local chunk = main_chunk:open_chunk(i-1)
				if (chunk) then
					main_chunk:replace_chunk(i-1,child)
					total_size = total_size + child:size() + 8
				end
			end
			main_chunk:resize(total_size)
			self:replace_chunk(OGF_CHILDREN,main_chunk)
		end
	end
end

function cOGF:save(to_fname)
	self:OGF_S_DESC()
  	self:OGF_TEXTURE()
	--self:OGF_S_BONE_NAMES()
	--self:OGF_S_IKDATA()
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
		for i,t in pairs(self.bones) do 
			table.insert(new,t.name)
		end
		table.sort(new)
		t.bones = table.concat(new,",")
	end
	return t
end