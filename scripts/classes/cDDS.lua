Class "cDDS"
function cDDS:initialize(fname)
	self.fname = fname
	self.header = cBinaryData(fname,128)
	-- Read DDS_HEADER
	self.dwMagic = self.header:r_u32() -- dwMagic (Header)
	self.dwSize = self.header:r_u32() -- dwSize
	self.dwFlags = self.header:r_u32() -- dwFlags
	self.dwHeight = self.header:r_u32() -- dwHeight
	self.dwWidth = self.header:r_u32() -- dwWidth
	self.dwPitchOrLinearSize = self.header:r_u32() -- dwPitchOrLinearSize
	self.dwDepth = self.header:r_u32() -- dwDepth
	self.dwMipMapCount = self.header:r_u32() -- dwMipMapCount
	self.dwReserved1 = {}
	for i=1,11 do
		table.insert(self.dwReserved1,self.header:r_u32()) -- dwReserved1[11];
	end
	self.pixel_format = {}
	self.pixel_format.dwSize = self.header:r_u32() -- DDS_PIXELFORMAT_dwSize
	self.pixel_format.dwFlags = self.header:r_u32() --DDS_PIXELFORMAT_dwFlags
	self.pixel_format.dwFourCC = trim(string.char(self.header:r_u8(),self.header:r_u8(),self.header:r_u8(),self.header:r_u8())) -- DDS_PIXELFORMAT_dwFourCC
	self.pixel_format.dwRGBBitCount = self.header:r_u32() -- DDS_PIXELFORMAT_dwRGBBitCount;
	self.pixel_format.dwRBitMask = self.header:r_u32() -- DDS_PIXELFORMAT_dwRBitMask;
	self.pixel_format.dwGBitMask = self.header:r_u32() -- DDS_PIXELFORMAT_dwGBitMask;
	self.pixel_format.dwBBitMask = self.header:r_u32() -- DDS_PIXELFORMAT_dwBBitMask;
	self.pixel_format.dwABitMask = self.header:r_u32() -- DDS_PIXELFORMAT_dwABitMask;
	self.dwCaps1 = self.header:r_u32() --dwCaps
	self.dwCaps2 = self.header:r_u32() --dwCaps2
	self.dwCaps3 = self.header:r_u32() --dwCaps3
	self.dwCaps4 = self.header:r_u32() --dwCaps4
	self.dwReserved2 = self.header:r_u32() --dwReserved2
end

local bits = {}
function cDDS:HasAlpha(co_routines,current_co)
	if (self:PixelFormatIsDXT5() or self:PixelFormatIsDXT3()) then 
		return true
	elseif (bit.band(DDPF_ALPHAPIXELS,self.pixel_format.dwFlags) == DDPF_ALPHAPIXELS and self.pixel_format.dwABitMask == 0xff000000) then 
		return true
	elseif not (self:PixelFormatIsDXT1()) then
		return false
	end
	
	local bpp = 4
	local blockSize = 8
	local size = (math.max(bpp, self.dwWidth)/bpp) * (math.max(bpp,self.dwHeight)/bpp) * blockSize
	
	local f, err = io.open(self.fname,"rb")
	if (f == nil or err) then 
		error(err)
	end
	
	f:read(128)
	
	local string,math = string,math
	local byte
	local function read(count)
		local hex_string = ""
		for i=1,count do
			byte = f:read(1)
			size = size - 1
			if not (byte) then
				return 
			end
			hex_string = string.format("%02X",string.byte(byte)) .. hex_string
		end
		return tonumber(hex_string,16)
	end
	
	local a,b,c
	while (true) do 
		a = read(2)
		b = read(2)
		
		if not (a and b) then
			break
		end 
		
		c = read(4)
		if not (c) then
			break
		end 
		
		if (a <= b) then
			clear(bits)
			local rest,check_bit
			for i=32,1,-1 do
				rest=math.fmod(c,2)
				bits[i]=rest
				if not (check_bit) then 
					check_bit = rest 
				else
					if (check_bit == 1 and rest == 1) then 
						f:close()
						return true
					end
					check_bit = nil
				end
				c=(c-rest)/2
			end
		end
		
		if size <= 0 then 
			break 
		end
	end
	
	f:close()
	return false
end 

function cDDS:PixelFormatIsDXT1()
	return (bit.band(DDPF_FOURCC,self.pixel_format.dwFlags) == DDPF_FOURCC and self.pixel_format.dwFourCC == "DXT1")
end

function cDDS:PixelFormatIsDXT3()
	return (bit.band(DDPF_FOURCC,self.pixel_format.dwFlags) == DDPF_FOURCC and self.pixel_format.dwFourCC == "DXT3")
end

function cDDS:PixelFormatIsDXT5()
	return (bit.band(DDPF_FOURCC,self.pixel_format.dwFlags) == DDPF_FOURCC and self.pixel_format.dwFourCC == "DXT5")
end

function cDDS:PixelFormatIsRGBA()
	return (bit.band(DDPF_RGB,self.pixel_format.dwFlags) == DDPF_RGB and bit.band(DDPF_ALPHAPIXELS,self.pixel_format.dwFlags) == DDPF_ALPHAPIXELS
		and self.pixel_format.dwRGBBitCount == 32 and self.pixel_format.dwRBitMask == 0xff0000 and self.pixel_format.dwGBitMask == 0xff00
		and self.pixel_format.dwBBitMask == 0xff and self.pixel_format.dwABitMask == 0xff000000)
end

function cDDS:PixelFormatIsRGB()
	return (bit.band(DDPF_RGB,self.pixel_format.dwFlags) == DDPF_RGB and bit.band(DDPF_ALPHAPIXELS,self.pixel_format.dwFlags) ~= DDPF_ALPHAPIXELS
		and self.pixel_format.dwRGBBitCount == 24 and self.pixel_format.dwRBitMask == 0xff0000 and self.pixel_format.dwGBitMask == 0xff00
		and self.pixel_format.dwBBitMask == 0xff and self.pixel_format.dwABitMask == 0xff000000)
end