DDS_MAGIC = 0x20534444

-- dwFlags
DDSD_CAPS                    = 0x00000001 
DDSD_HEIGHT                  = 0x00000002 
DDSD_WIDTH                   = 0x00000004 
DDSD_PITCH                   = 0x00000008 
DDSD_PIXELFORMAT             = 0x00001000 
DDSD_MIPMAPCOUNT             = 0x00020000 
DDSD_LINEARSIZE              = 0x00080000 
DDSD_DEPTH                   = 0x00800000 

-- pixel_format.dwFlags
DDPF_ALPHAPIXELS             = 0x00000001 
DDPF_FOURCC                  = 0x00000004 
DDPF_INDEXED                 = 0x00000020 
DDPF_RGB                     = 0x00000040 

-- dwCaps1
DDSCAPS_COMPLEX              = 0x00000008 
DDSCAPS_TEXTURE              = 0x00001000 
DDSCAPS_MIPMAP               = 0x00400000 

--  dwCaps2
DDSCAPS2_CUBEMAP             = 0x00000200 
DDSCAPS2_CUBEMAP_POSITIVEX   = 0x00000400 
DDSCAPS2_CUBEMAP_NEGATIVEX   = 0x00000800 
DDSCAPS2_CUBEMAP_POSITIVEY   = 0x00001000 
DDSCAPS2_CUBEMAP_NEGATIVEY   = 0x00002000 
DDSCAPS2_CUBEMAP_POSITIVEZ   = 0x00004000 
DDSCAPS2_CUBEMAP_NEGATIVEZ   = 0x00008000 
DDSCAPS2_VOLUME              = 0x00200000

cDDS = Class "cDDS"
function cDDS:initialize(fname)
	self.fname = fname
	self.header = cBinaryData:new(fname,128)
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

local function check_alpha(num)
	if (num) then
		local bits = toBits(num,8)
		if (bits[1] == 1 and bits[2] == 1 or bits[3] == 1 and bits[4] == 1 or bits[5] == 1 and bits[6] == 1 or bits[7] == 1 and bits[8] == 1) then 
			return true
		end
	end
	return false
end 

function cDDS:HasAlpha()
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

	self.data = cBinaryData:new(self.fname,size,128)
	while (self.data:r_eof() ~= true) do
		local a = self.data:r_u16()
		local b = a and self.data:r_u16()
		if not (a and b) then
			return false 
		end
		if (a <= b) then
			if (check_alpha(self.data:r_u8()) or check_alpha(self.data:r_u8()) or check_alpha(self.data:r_u8()) or check_alpha(self.data:r_u8())) then
				return true
			end
		else 
			self.data:r_u32()
		end
		--Msg("r_tell=%s size=%s",self.data:r_tell(),size)
	end
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