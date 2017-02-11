
Class "cLevel" (cBinaryData)
function cLevel:initialize(fname,partial,start,chunk)
	self.inherited[1].initialize(self,fname,partial,start,chunk)
	
	if (self:size() <= 0) then
		return
	end

	self:fsL_SHADERS(true)
end

function cLevel:fsL_HEADER(loading)
	if (loading) then 

	else

	end
end 

function cLevel:fsL_SHADERS(loading)
	if (loading) then 
		if (self:find_chunk(fsL_SHADERS) > 0) then
			self.shaders = {}
			local cnt = self:r_u32()
			for i=1,cnt do
				table.insert(self.shaders,self:r_stringZ())
			end 
		end
	elseif (self.shaders) then
		local chunk = self:open_chunk(fsL_SHADERS)
		if (chunk) then
			local cnt = #self.shaders
			chunk:w_u32(cnt)
			for i=1,cnt do
				chunk:w_stringZ(trim(self.shaders[i]))
			end
			chunk:resize(chunk:w_tell())
			self:replace_chunk(fsL_SHADERS,chunk)
		end
	end
end

function cLevel:save(to_fname)
	self:fsL_SHADERS()
	self.inherited[1].save(self,to_fname)
end