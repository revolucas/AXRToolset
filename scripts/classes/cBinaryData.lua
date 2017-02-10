---------------------------------------------------------
-- BinaryData
---------------------------------------------------------
Class "cBinaryData"
function cBinaryData:initialize(fname,partial,start,chunk)
	self.data = {}
	if (fname and file_exists(fname)) then
		local f, err = io.open(fname,"rb")
		if (f == nil or err) then 
			error(err)
		end
		
		if (start) then
			f:read(start)
		end

		local byte
		local r_tell = 0
		while true do
			byte = f:read(1)
			if not (byte) then 
				break 
			end
			table.insert(self.data,string.byte(byte))
			r_tell = r_tell + 1
			if (partial and r_tell == partial) then 
				break 
			end
		end
		f:close()
	else
		if (chunk) then
			local pos = start or 1
			local size = partial or chunk:size()
			for i=pos,pos+size-1 do
				table.insert(self.data,chunk.data[i] or 0)
			end
		end
	end
	self.w_marker = 1
	self.r_marker = 1
	self.fname = fname
end

function cBinaryData:size()
	return #self.data
end

function cBinaryData:w_tell()
	return self.w_marker-1
end 

function cBinaryData:r_tell()
	return self.r_marker-1
end 

function cBinaryData:r_advance(pos)
	self.r_marker = self.r_marker+pos
	clamp(self.r_marker,1,#self.data)
end 

function cBinaryData:w_advance(pos)
	self.w_marker = self.w_marker+pos
	clamp(self.w_marker,1,#self.data)
end

function cBinaryData:r_seek(pos)
	self.r_marker = pos
	clamp(self.r_marker,1,#self.data)
end 

function cBinaryData:w_seek(pos)
	self.w_marker = pos
	clamp(self.w_marker,1,#self.data)
end 

function cBinaryData:w_eof()
	return self.w_marker+1 > self:size()
end 

function cBinaryData:r_eof()
	return self.r_marker+1 > self:size()
end 

local read_t = {}
function cBinaryData:r(dwSize)
	clear(read_t)
	local data
	for i=1,dwSize do
		data = self.data[self.r_marker]
		if not (data) then 
			break 
		end
		
		table.insert(read_t,1,string.format('%02X',data))
		
		self.r_marker = self.r_marker + 1
	end
	
	local size = self:size()
	if (self.r_marker > size) then 
		self.r_marker = size
	end 
	
	return table.concat(read_t)
end

function cBinaryData:r_u8()
	local v = self:r(1)
	return v and tonumber(v,16)
end 

function cBinaryData:w_u8(val)
	local t = number2bytes(val,1)
	self.data[self.w_marker] = t[1]
	self.w_marker = self.w_marker + 1
end

function cBinaryData:r_u16()
	local v = self:r(2)
	return v and tonumber(v,16)
end 

function cBinaryData:w_u16(val)
	local t = number2bytes(val,2)
	for i=1,#t do
		self.data[self.w_marker] = t[i]
		self.w_marker = self.w_marker + 1
	end
end

function cBinaryData:r_u32()
	local v = self:r(4)
	return v and tonumber(v,16)
end

function cBinaryData:w_u32(val)
	local t = number2bytes(val,4)
	for i=1,#t do
		self.data[self.w_marker] = t[i]
		self.w_marker = self.w_marker + 1
	end
end 

function cBinaryData:r_u64()
	local v = self:r(8)
	return v and tonumber(v,16)
end

function cBinaryData:w_u64(val)
	local t = number2bytes(val,8)
	for i=1,#t do
		self.data[self.w_marker] = t[i]
		self.w_marker = self.w_marker + 1
	end
end 

function cBinaryData:r_float()
	local v = self:r_u32()
	return v and hex2float(v)
end

function cBinaryData:w_float(val)
	local t = number2bytes(float2hex(val),4)
	for i=1,#t do
		self.data[self.w_marker] = t[i]
		self.w_marker = self.w_marker + 1
	end
end

function cBinaryData:find_chunk(ID)
	self.r_marker = 1
	
	local size = self:size()
	local dwType,dwSize
	while true do
		dwType,dwSize = self:r_u32(),self:r_u32()
		if not (dwType and dwSize) then 
			return 0
		end

		--Msg("ID=%s size=%s",dwType,dwSize)
		if (dwType == ID) then
			return dwSize
		end
		
		self.r_marker = self.r_marker + dwSize
		if (self.r_marker > size) then 
			self.r_marker = size
			return 0
		elseif (self.r_marker == size) then 
			return dwSize
		end
	end
	return 0
end

function cBinaryData:open_chunk(ID)
	self.r_marker = 1
	
	local size = self:size()
	local dwType,dwSize
	while true do
		dwType,dwSize = self:r_u32(),self:r_u32()
		if not (dwType and dwSize) then 
			return nil
		end

		if (dwType == ID) then
			if (dwSize > 0) then
				return cBinaryData(nil,dwSize,self.r_marker,self)
			end 
			return nil
		end
		
		self.r_marker = self.r_marker + dwSize
		if (self.r_marker > size) then 
			self.r_marker = size
			return nil
		elseif (self.r_marker == size) then 
			return nil
		end
	end
	return
end 

function cBinaryData:printf(pos,cnt)
	local ln = ""
	local size = cnt or self:size()
	for i=1,size do
		local byte = self.data[pos-1+i]
		if not (byte) then
			break
		end
		ln = ln .. string.format('%02X',byte) .. " "
		if (i % 16 == 0) then 
			Msg(ln)
			ln = ""
		end
	end
	Msg(ln)
end

function cBinaryData:replace_chunk(ID,chunk)
	self.r_marker = 1
	
	local size = self:size()
	local dwType,dwSize
	while true do
		dwType,dwSize = self:r_u32(),self:r_u32()
		if not (dwType and dwSize) then 
			return
		end

		if (dwType == ID) then
			if (dwSize > 0) then
				-- set new size
				local newsize = chunk:size()
				if (newsize ~= dwSize) then
					Msg("ID=%s newsize=%s dwSize=%s",ID,newsize,dwSize)
					self:w_seek(self.r_marker-4)
					self:w_u32(newsize)
				end		
				
				-- insert more bytes
				for i=1,newsize-dwSize do
					table.insert(self.data,self.r_marker,0)
				end
				
				-- overwrite data
				for i=1,newsize do
					if (chunk.data[i]) then
						self.data[self:r_tell()+i] = chunk.data[i]
					end
				end
			end
			return
		end
		
		self.r_marker = self.r_marker + dwSize
		if (self.r_marker > size) then 
			self.r_marker = size
			return
		elseif (self.r_marker == size) then 
			return
		end
	end
end

function cBinaryData:r_chunk(ID)
	local dwSize = self:find_chunk(ID)
	if (dwSize > 0) then
		local v = self:r(dwSize)
		return v and tonumber(v,16) or 0
	end
	return dwSize
end

function cBinaryData:w_chunk(ID,dwSize)
	self:w_u32(ID)
	self:w_u32(dwSize)
end

function cBinaryData:r_stringZ()
	local t = {}
	while true do
		local v = self.data[self.r_marker]
		if not (v) then
			break
		end
		
		self.r_marker = self.r_marker + 1
		
		if (v > 0) then
			table.insert(t,v)
		else 
			break
		end
	end
	
	local size = self:size()
	if (self.r_marker > size) then 
		self.r_marker = size
	end
		
	return #t > 0 and string.char(unpack(t)) or ""
end

function cBinaryData:w_stringZ(str)
	local len = str:len()
	for i=1,len do 
		self.data[self.w_marker] = string.byte(str,i)
		self.w_marker = self.w_marker + 1
	end
	self.data[self.w_marker] = 0
	self.w_marker = self.w_marker + 1
end

function cBinaryData:r_string(cnt)
	clear(read_t)
	local data
	for i=1,cnt do
		data = self.data[self.r_marker]
		if not (data) then 
			break 
		end
		
		table.insert(read_t, data)
		
		self.r_marker = self.r_marker + 1
	end
	
	local size = self:size()
	if (self.r_marker > size) then 
		self.r_marker = size 
	end
	
	return data and #data > 0 and string.char(unpack(data)) or ""
end 

function cBinaryData:w_string(str)
	local len = str:len()
	for i=1,len do 
		self.data[self.w_marker] = string.byte(str,i)
		self.w_marker = self.w_marker + 1
	end
	self.w_marker = self.w_marker + 1
end

function cBinaryData:save(to_fname)
	local fname = to_fname or self.fname
	if (fname) then
		local f,err = io.open(fname,"wb")
		if (err) then 
			error(err)
		end
		
		local t = {}
		for i=1,#self.data do 
			table.insert(t,string.char(self.data[i]))
		end
		
		f:write(table.concat(t))
		f:close()
	end
end