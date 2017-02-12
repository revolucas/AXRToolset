----------------------------------------------------
-- Includes
----------------------------------------------------
package.path = package.path .. ';core\\lua\\?.lua'
package.cpath = package.cpath .. ';bin\\?.dll;..\\bin\\?.dll'

require "lua_extensions"
require "lfs"
bit = require "bit"

----------------------------------------------------
-- scripts\lib\
----------------------------------------------------
require "scripts.lib.utils"
----------------------------------------------------
-- Global vars 
----------------------------------------------------
CFS_CompressMark 		= bit.lshift(1,31) --2147483648

-- THM Chunk
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

-- DDS
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

-- OGF
-- Chunks
OGF_HEADER = 1
OGF_TEXTURE = 2
OGF_VERTICES = 3
OGF_INDICES = 4
OGF_P_MAP = 5 						-- unused
OGF_SWIDATA = 6
OGF_VCONTAINER = 7 					-- not used ??
OGF_ICONTAINER = 8 					-- not used ??
OGF_CHILDREN = 9 					-- * For skeletons only
OGF_CHILDREN_L = 10 				-- Link to child visuals
OGF_LODDEF2 = 11 					-- + 5 channel data
OGF_TREEDEF2 = 12 					-- + 5 channel data
OGF_S_BONE_NAMES = 13 				-- * For skeletons only
OGF_S_MOTIONS = 14 					-- * For skeletons only
OGF_S_SMPARAMS = 15 				-- * For skeletons only
OGF_S_IKDATA = 16 					-- * For skeletons only
OGF_S_USERDATA = 17 				-- * For skeletons only (Ini-file)
OGF_S_DESC = 18 					-- * For skeletons only
OGF_S_MOTION_REFS = 19 				-- * For skeletons only
OGF_SWICONTAINER = 20 				-- * SlidingWindowItem record container
OGF_GCONTAINER = 21 				-- * both VB&IB
OGF_FASTPATH = 22 					-- * extended/fast geometry
OGF_S_LODS = 23 					-- * For skeletons only (Ini-file)
OGF_S_MOTION_REFS2 = 24 			-- * changes in format
OGF_COLLISION_VERTICES = 25
OGF_COLLISION_INDICES = 26
OGF_forcedword = 0xFFFFFFFF
-----
OGF_VERTEXFORMAT_FVF_1L = 1 * 0x12071980
OGF_VERTEXFORMAT_FVF_2L = 2 * 0x12071980
OGF_VERTEXFORMAT_FVF_3L = 4 * 0x12071980
OGF_VERTEXFORMAT_FVF_4L = 5 * 0x12071980
OGF_VERTEXFORMAT_FVF_NL = 3 * 0x12071980
	
xrOGF_SMParamsVersion = 4
xrOGF_FormatVersion = 4

MAX_ANIM_SLOT =	48
-- Level
fsL_HEADER = 1
fsL_SHADERS = 2
fsL_VISUALS = 3
fsL_PORTALS = 4 				-- Portal polygons
fsL_LIGHT_DYNAMIC = 6
fsL_GLOWS = 7 					-- All glows inside level
fsL_SECTORS = 8 				-- All sectors on level
fsL_VB = 9						-- Static geometry
fsL_IB = 10
fsL_SWIS = 11					-- collapse info, usually for trees
fsL_forcedword = 0xFFFFFFFF
----------------------------------------------------
-- Global Utils
----------------------------------------------------
function Class(name)
	this[name] = setmetatable({},{
		__index = getmetatable(_G).__index,
		__call = function(t,...)
			local o = setmetatable({},{__index=t}) 
			o:initialize(...)
			return o
		end
	})
	return function(...)
		local p = {...}
		this[name].inherited = p
		getmetatable(this[name]).__index=function(t,k)
			for i,v in ipairs(p) do 
				local ret = rawget(v,k)
				if (ret ~= nil) then
					return ret
				end
			end
			return getmetatable(_G).__index(_G,k)
		end
	end
end

local callbacks = {}
function CallbackRegister(name,func_or_userdata)
	if (func_or_userdata == nil) then 
		Msg("CallbackSet func_or_userdata is nil!")
		return
	end
	if not (callbacks[name]) then
		callbacks[name] = {}
	end
	callbacks[name][func_or_userdata] = true
end

function CallbackUnregister(name,func_or_userdata)
	if (callbacks[name]) then
		callbacks[name][func_or_userdata] = nil
	end
end

function CallbackSend(name,...)
	if (callbacks[name]) then
		for func_or_userdata,v in pairs(callbacks[name]) do 
			if (type(func_or_userdata) == "function") then 
				func_or_userdata(...)
			elseif (func_or_userdata[name]) then
				func_or_userdata[name](func_or_userdata,...)
			end
		end
	end
end

------------------------------------------------------------------
-- Event handlers
------------------------------------------------------------------
function ApplicationBegin()
	math.randomseed(os.time())
	
	gSettings = cIniFile("configs\\settings.ltx",true)
	if not (gSettings) then
		Msg("Error: configuration is missing for axr_lua_engine!")
		return
	end
	
	local node = "scripts"
	--[[
	local function on_execute(path,fname)
		Run('bin\\luac5.1.exe -p "'..ahkGetVar("A_WorkingDir").."\\"..path.."\\"..fname..'"')
	end
	file_for_each(node,{"lua"},on_execute)
	--]]
	
	Msg("------AXR Toolset by Alundaio------")
	
	for file in lfs.dir(node) do
		if (file ~= ".." and file ~= ".") then
			local fullpath = node .. "\\" .. file
			local mode = lfs.attributes(fullpath,"mode")
			if (mode == "file") then
				local name = file:sub(0,-5)
				if (name ~= "_G" and _G[name] and _G[name].OnApplicationBegin) then 
					_G[name].OnApplicationBegin()
				end
			end
		end
	end
			
	CallbackSend("OnApplicationBeginEnd")
end

function ApplicationExit()
	CallbackSend("OnApplicationExit")
end

function GuiClose(id)
	CallbackSend("OnGuiClose",id)
end

function GuiScriptControlAction(hwnd,event,info)
	CallbackSend("OnScriptControlAction",hwnd,event,info)
end