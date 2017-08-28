Class "cEObject" (cBinaryData)
function cEObject:initialize(fname,partial,start,chunk)
	self.inherited[1].initialize(self,fname,partial,start,chunk)
	if (self:size() <= 0) then
		return
	end
	
	self.params = {}
	
	self:EOBJ_CHUNK_CLASSSCRIPT(true)
 	self:EOBJ_CHUNK_SURFACES(true)
	self:EOBJ_CHUNK_SURFACES2(true)
	self:EOBJ_CHUNK_SURFACES3(true)
	self:EOBJ_CHUNK_SMOTIONS(true)
	self:EOBJ_CHUNK_SMOTIONS2(true)
	self:EOBJ_CHUNK_SMOTIONS3(true)
end

function cEObject:EOBJ_CHUNK_CLASSSCRIPT(loading)
	if (loading) then 
		local main_chunk = self:open_chunk(EOBJ_CHUNK_OBJECT_BODY)
		if (main_chunk and main_chunk:size() > 0) then 
			local chunk = main_chunk:open_chunk(EOBJ_CHUNK_CLASSSCRIPT)
			if (chunk and chunk:size() > 0) then 
				self.params.userdata = chunk:r_stringZ()
			end 
		end
	elseif (self.params.userdata) then
		local main_chunk = self:open_chunk(EOBJ_CHUNK_OBJECT_BODY)
		if (main_chunk and main_chunk:size() > 0) then 
			local chunk = main_chunk:open_chunk(EOBJ_CHUNK_SURFACES)
			if (chunk and chunk:size() > 0) then 
				chunk:w_stringZ(trim(self.params.userdata))
				chunk:resize(chunk:w_tell())
				main_chunk:replace_chunk(EOBJ_CHUNK_SURFACES,chunk)
			end
		end			
	end
end 

function cEObject:EOBJ_CHUNK_SURFACES(loading)
	if (loading) then
		local main_chunk = self:open_chunk(EOBJ_CHUNK_OBJECT_BODY)
		if (main_chunk and main_chunk:size() > 0) then 
			local chunk = main_chunk:open_chunk(EOBJ_CHUNK_SURFACES)
			if (chunk and chunk:size() > 0) then 
				local cnt = chunk:r_u32()
				for i=1,cnt do
					if not (self.params.surfaces) then 
						self.params.surfaces = {}
					end
					self.params.surfaces[i] = {}
					self.params.surfaces[i].name = chunk:r_stringZ()
					self.params.surfaces[i].shader_name = chunk:r_stringZ()
					self.params.surfaces[i].flags = chunk:r_u8()
					self.params.surfaces[i].fvf = chunk:r_u32()
					
					local cnt = chunk:r_u32()
					self.params.surfaces[i].textures = {}
					for n=1,cnt do 
						self.params.surfaces[i].textures[n] = {}
						self.params.surfaces[i].textures[n].texture = chunk:r_stringZ()
						self.params.surfaces[i].textures[n].vmap = chunk:r_stringZ()
						self.params.surfaces[i].textures[n].shader_name = chunk:r_stringZ()
						self.params.surfaces[i].textures[n].shader_xrlc_name = chunk:r_stringZ()
					end
				end 
			end
		end
	elseif (self.params.surfaces) then 
		local main_chunk = self:open_chunk(EOBJ_CHUNK_OBJECT_BODY)
		if (main_chunk and main_chunk:size() > 0) then 
			local chunk = main_chunk:open_chunk(EOBJ_CHUNK_SURFACES)
			if (chunk and chunk:size() > 0) then 
				local cnt = #self.params.surfaces
				chunk:w_u32(cnt)
				for i=1,cnt do
					chunk:w_stringZ(trim(self.params.surfaces[i].name))
					chunk:w_stringZ(trim(self.params.surfaces[i].shader_name))
					chunk:w_stringZ(trim(self.params.surfaces[i].shader_xrlc_name))
					chunk:w_stringZ(trim(self.params.surfaces[i].mtl_name))
					chunk:w_stringZ(trim(self.params.surfaces[i].texture))
					chunk:w_stringZ(trim(self.params.surfaces[i].vmap))
					chunk:w_u32(self.params.surfaces[i].flags)
					chunk:w_u32(self.params.surfaces[i].fvf)
					chunk:w_u32(1)
				end
				chunk:resize(chunk:w_tell())
				main_chunk:replace_chunk(EOBJ_CHUNK_SURFACES,chunk)
			end
		end	
	end
end

function cEObject:EOBJ_CHUNK_SURFACES2(loading)
	if (loading) then
		local main_chunk = self:open_chunk(EOBJ_CHUNK_OBJECT_BODY)
		if (main_chunk and main_chunk:size() > 0) then 
			local chunk = main_chunk:open_chunk(EOBJ_CHUNK_SURFACES2)
			if (chunk and chunk:size() > 0) then 
				local cnt = chunk:r_u32()
				for i=1,cnt do
					if not (self.params.surfaces) then 
						self.params.surfaces = {}
					end
					self.params.surfaces[i] = {}
					self.params.surfaces[i].name = chunk:r_stringZ()
					self.params.surfaces[i].shader_name = chunk:r_stringZ()
					self.params.surfaces[i].shader_xrlc_name = chunk:r_stringZ()
					self.params.surfaces[i].texture = chunk:r_stringZ()
					self.params.surfaces[i].vmap = chunk:r_stringZ()
					self.params.surfaces[i].flags = chunk:r_u32()
					self.params.surfaces[i].fvf = chunk:r_u32()
					chunk:r_u32()
				end 
			end
		end
	elseif (self.params.surfaces) then 
		local main_chunk = self:open_chunk(EOBJ_CHUNK_OBJECT_BODY)
		if (main_chunk and main_chunk:size() > 0) then 
			local chunk = main_chunk:open_chunk(EOBJ_CHUNK_SURFACES2)
			if (chunk and chunk:size() > 0) then 
				local cnt = #self.params.surfaces
				chunk:w_u32(cnt)
				for i=1,self.params.surfaces_count do
					chunk:w_stringZ(trim(self.params.surfaces[i].name))
					chunk:w_stringZ(trim(self.params.surfaces[i].shader_name))
					chunk:w_stringZ(trim(self.params.surfaces[i].shader_xrlc_name))
					chunk:w_stringZ(trim(self.params.surfaces[i].texture))
					chunk:w_stringZ(trim(self.params.surfaces[i].vmap))
					chunk:w_u32(self.params.surfaces[i].flags)
					chunk:w_u32(self.params.surfaces[i].fvf)
					chunk:w_u32(1)
				end
				chunk:resize(chunk:w_tell())
				main_chunk:replace_chunk(EOBJ_CHUNK_SURFACES2,chunk)
			end
		end	
	end
end

function cEObject:EOBJ_CHUNK_SURFACES3(loading)
	if (loading) then
		local main_chunk = self:open_chunk(EOBJ_CHUNK_OBJECT_BODY)
		if (main_chunk and main_chunk:size() > 0) then 
			local chunk = main_chunk:open_chunk(EOBJ_CHUNK_SURFACES3)
			if (chunk and chunk:size() > 0) then 
				local cnt = chunk:r_u32()
				for i=1,cnt do
					if not (self.params.surfaces) then 
						self.params.surfaces = {}
					end
					self.params.surfaces[i] = {}
					self.params.surfaces[i].name = chunk:r_stringZ()
					self.params.surfaces[i].shader_name = chunk:r_stringZ()
					self.params.surfaces[i].shader_xrlc_name = chunk:r_stringZ()
					self.params.surfaces[i].mtl_name = chunk:r_stringZ()
					self.params.surfaces[i].texture = chunk:r_stringZ()
					self.params.surfaces[i].vmap = chunk:r_stringZ()
					self.params.surfaces[i].flags = chunk:r_u32()
					self.params.surfaces[i].fvf = chunk:r_u32()
					chunk:r_u32()
				end 
			end
		end
	elseif (self.params.surfaces) then 
		local main_chunk = self:open_chunk(EOBJ_CHUNK_OBJECT_BODY)
		if (main_chunk and main_chunk:size() > 0) then 
			local chunk = main_chunk:open_chunk(EOBJ_CHUNK_SURFACES3)
			if (chunk and chunk:size() > 0) then 
				local cnt = #self.params.surfaces
				chunk:w_u32(cnt)
				for i=1,cnt do
					chunk:w_stringZ(trim(self.params.surfaces[i].name))
					chunk:w_stringZ(trim(self.params.surfaces[i].shader_name))
					chunk:w_stringZ(trim(self.params.surfaces[i].shader_xrlc_name))
					chunk:w_stringZ(trim(self.params.surfaces[i].mtl_name))
					chunk:w_stringZ(trim(self.params.surfaces[i].texture))
					chunk:w_stringZ(trim(self.params.surfaces[i].vmap))
					chunk:w_u32(self.params.surfaces[i].flags)
					chunk:w_u32(self.params.surfaces[i].fvf)
					chunk:w_u32(1)
				end
				chunk:resize(chunk:w_tell())
				main_chunk:replace_chunk(EOBJ_CHUNK_SURFACES3,chunk)
			end
		end	
	end
end

function cEObject:EOBJ_CHUNK_SMOTIONS(loading)
	if (loading) then
		local main_chunk = self:open_chunk(EOBJ_CHUNK_OBJECT_BODY)
		if (main_chunk and main_chunk:size() > 0) then 
			local chunk = main_chunk:open_chunk(EOBJ_CHUNK_SMOTIONS)
			if (chunk and chunk:size() > 0) then 
				local cnt = chunk:r_u32()
				for i=1,cnt do
					local t = {chunk:r_stringZ(),chunk:r_u32(),chunk:r_u32(),chunk:r_float()}
					self.params.smotions = self.params.smotions and ", " .. table.concat(t,"|") or table.concat(t,"|")
				end 
			end
		end
	elseif (self.params.smotions) then 
		local main_chunk = self:open_chunk(EOBJ_CHUNK_OBJECT_BODY)
		if (main_chunk and main_chunk:size() > 0) then 
			local chunk = main_chunk:open_chunk(EOBJ_CHUNK_SMOTIONS)
			if (chunk and chunk:size() > 0) then 
				local t = str_explode(self.params.smotions,",")
				local cnt = #t
				chunk:w_u32(cnt)
				for i=1,cnt do
					local b = str_explode(t[i],"|")
					chunk:w_stringZ(b[1])
					chunk:w_u32(tonumber(b[2]))
					chunk:w_u32(tonumber(b[3]))
					chunk:w_float(tonumber(b[4]))
				end
				chunk:resize(chunk:w_tell())
				main_chunk:replace_chunk(EOBJ_CHUNK_SURFACES,chunk)
			end
		end	
	end
end

function cEObject:EOBJ_CHUNK_SMOTIONS2(loading)
	if (loading) then
		local main_chunk = self:open_chunk(EOBJ_CHUNK_OBJECT_BODY)
		if (main_chunk and main_chunk:size() > 0) then 
			local chunk = main_chunk:open_chunk(EOBJ_CHUNK_SMOTIONS2)
			if (chunk and chunk:size() > 0) then 
				self.params.smotions2 = chunk:r_stringZ()
			end
		end
	elseif (self.params.smotions2) then 
		local main_chunk = self:open_chunk(EOBJ_CHUNK_OBJECT_BODY)
		if (main_chunk and main_chunk:size() > 0) then 
			local chunk = main_chunk:open_chunk(EOBJ_CHUNK_SMOTIONS2)
			if (chunk and chunk:size() > 0) then 
				chunk:w_stringZ(self.params.smotions2)
				chunk:resize(chunk:w_tell())
				main_chunk:replace_chunk(EOBJ_CHUNK_SURFACES,chunk)
			end
		end	
	end
end

function cEObject:EOBJ_CHUNK_SMOTIONS3(loading)
	if (loading) then
		local main_chunk = self:open_chunk(EOBJ_CHUNK_OBJECT_BODY)
		if (main_chunk and main_chunk:size() > 0) then 
			local chunk = main_chunk:open_chunk(EOBJ_CHUNK_SMOTIONS3)
			if (chunk and chunk:size() > 0) then 
				local cnt = chunk:r_u32()
				for i=1,cnt do
					self.params.smotions3 = self.params.smotions3 and self.params.smotions3 .. ", " .. chunk:r_stringZ() or chunk:r_stringZ()
				end
			end
		end
	elseif (self.params.smotions3) then 
		local main_chunk = self:open_chunk(EOBJ_CHUNK_OBJECT_BODY)
		if (main_chunk and main_chunk:size() > 0) then 
			local chunk = main_chunk:open_chunk(EOBJ_CHUNK_SMOTIONS3)
			if (chunk and chunk:size() > 0) then 
				local t = str_explode(self.params.smotions3,",")
				local cnt = #t
				chunk:w_u32(cnt)
				for i=1,cnt do
					if (t[i] ~= "") then
						chunk:w_stringZ(t[i])
					end
				end
				chunk:resize(chunk:w_tell())
				main_chunk:replace_chunk(EOBJ_CHUNK_SURFACES,chunk)
			end
		end	
	end
end

function cEObject:save(to_fname)
	self:EOBJ_CHUNK_CLASSSCRIPT()
 	self:EOBJ_CHUNK_SURFACES()
	self:EOBJ_CHUNK_SURFACES2()
	self:EOBJ_CHUNK_SURFACES3()
	self:EOBJ_CHUNK_SMOTIONS()
	self:EOBJ_CHUNK_SMOTIONS2()
	self:EOBJ_CHUNK_SMOTIONS3()
	self.inherited[1].save(self,to_fname)
end