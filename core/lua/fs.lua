THM_CHUNK_VERSION		= 0x0810
THM_CHUNK_DATA			= 0x0811
THM_CHUNK_TEXTUREPARAM	= 0x0812
THM_CHUNK_TYPE			= 0x0813
THM_CHUNK_TEXTURE_TYPE	= 0x0814
THM_CHUNK_DETAIL_EXT	= 0x0815
THM_CHUNK_MATERIAL		= 0x0816
THM_CHUNK_BUMP			= 0x0817
THM_CHUNK_EXT_NORMALMAP	= 0x0818
THM_CHUNK_FADE_DELAY	= 0x0819
THM_TEXTURE_VERSION		= 0x0012
CFS_CompressMark 		= bit.lshift(1,31) --2147483648

ETType = {
    	[0] = "Image",
		[1] = "CubeMap",
        [2] = "BumpMap",
        [3] = "NormalMap",
        [4] = "Terrain"
}

ETMIPFilter = {	
			[0] = "Box",
			[1] = "Cubic",
			[2] = "Point",
			[3] = "Triangle",
			[4] = "Quadratic",
			[5] = "Advanced",
			[6] = "Catrom",
			[7] = "Mitchell",
			[8] = "Gaussian",
			[9] = "Sinc",
			[10] = "Bessel",
			[11] = "Hanning",
			[12] = "Hamming",
			[13] = "Blackman",
			[14] = "Kaiser"
}

ETFormat = {
			[0] = "DXT1",
			[1] = "DXT1a",
			[2] = "DXT3",
			[3] = "DXT5",
			[4] = "4444",
			[5] = "1555",
			[6] = "565",
			[7] = "RGB",
			[8] = "RGBA",
			[9] = "NVHS",
			[10] = "NVHU",
			[11] = "A8",
			[12] = "L8",
			[13] = "A8L8"
}

ETFlags = {
		[0] = "",
		[1] = "GenerateMipMaps",
		[2] = "BinaryAlpha",
		[16] = "AlphaBorder",
		[32] = "ColorBorder",
		[64] = "FadeToColor",
		[128] = "FadeToAlpha",
		[256] = "DitherColor",
		[512] = "DitherEachMIPLevel",
		[8388608] = "DiffuseDetail",
		[16777216] = "ImplicitLighted",
		[33554432] = "HasAlpha",
		[67108864] = "BumpDetail"
}

ETBumpMode = {
	[1] = "None",
	[2] = "Use",
	[3] = "UseParalax"
}

ETMaterial = {
	[0] = "OrenNayerBlin",
	[1] = "BlinPhong",
	[2] = "PhongMetal",
	[3] = "OrenNayarMetal"
}
---------------------------------------------------------
-- BinaryData
---------------------------------------------------------
cBinaryData = Class "cBinaryData"
function cBinaryData:initialize(fname,partial)

	if (file_exists(fname)) then
		local f, err = io.open(fname,"rb")
		if (err) then 
			error(err)
		end
	
		self.data = {}
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
		self.data = {}
	end
	
	self.w_marker = 1
	self.r_marker = 1
	self.fname = fname
	
	return self
end

function cBinaryData:size()
	return #self.data
end

function cBinaryData:w_tell()
	return self.w_marker
end 

function cBinaryData:r_tell()
	return self.r_marker
end 

function cBinaryData:r_seek(pos)
	assert(pos <= self:size() and pos > 0)
	self.r_marker = pos
end 

function cBinaryData:w_seek(pos)
	assert(pos <= self:size()+1 and pos > 0)
	self.w_marker = pos
end 

function cBinaryData:r(dwSize)
	local t = {}
	local data
	for i=1,dwSize do
		data = self.data[self.r_marker]
		if not (data) then 
			break 
		end
		
		table.insert(t, string.format("%02X",data) )
		
		self.r_marker = self.r_marker + 1
	end
	
	local size = self:size()
	if (self.r_marker > size) then 
		self.r_marker = size 
	end 
	
	table_reverse(t)
	return table.concat(t)
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
		dwType = self:r_u32()
		if not (dwType) then 
			return 0 
		end
		
		dwSize = self:r_u32()
		if not (dwSize) then
			return 0
		end

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

function cBinaryData:r_chunk(ID)
	local dwSize = tonumber(self:find_chunk(ID),16) or 0
	if (dwSize > 0) then
		return tonumber(self:r(dwSize),16) or 0
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

function cBinaryData:save(to_fname)
	local fname = to_fname or self.fname
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