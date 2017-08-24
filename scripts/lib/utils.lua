function rem_quotes(txt)
	if not (txt) then return end
	for w in string.gmatch(txt,"[\"'](.+)[\"']") do
		return w
	end
	return txt
end

function escape_lua_pattern(s)
	local matches = {
		["^"] = "%^",
		["$"] = "%$",
		["("] = "%(",
		[")"] = "%)",
		["%"] = "%%",
		["."] = "%.",
		["["] = "%[",
		["]"] = "%]",
		["*"] = "%*",
		["+"] = "%+",
		["-"] = "%-",
		["?"] = "%?",
		["\0"] = "%z"
	}
    return (s:gsub(".",matches))
end

function addTab(s,n)
	local padding = {}
	local l = string.len(s)
	for i=1,n-l do 
		table.insert(padding," ")
	end 
	return s .. table.concat(padding)
end
	
function trim_ext(str)
	local a = string.find(str,"%.")
	return a and trim(string.sub(str,1,a-1)) or str
end

function trim_comment(str)
	local a = string.find(str,";")
	return a and trim(string.sub(str,1,a-1)) or str
end

function get_comment(str)
	local a = string.find(str,";")
	return a and " " .. string.sub(str,a) or ""
end

function get_section_includes(str)
	local a = string.find(str,"]")
	return a and " " .. string.sub(str,a+2) or ""
end

function trim_section_includes(str)
	local a = string.find(str,"]")
	return a and trim(string.sub(str,1,a)) or str
end

function directory_exists(path)
	--return os.execute( "CD " .. path ) == 0
	return lfs.attributes(path,"mode") == "directory"
end

function file_exists(path)
	return lfs.attributes(path) ~= nil
end

function get_ext(s)
	return string.gsub(s,"(.*)%.","")
end

function startsWith(text,prefix)
	return string.sub(text, 1, string.len(prefix)) == prefix
end

function trim(s)
	return s and (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function trim_backslash(s)
	return s and (string.gsub(s, "^[\\%s]*(.-)[\\%s]*$", "%1"))
end

function clamp(val, min, max)
	return val < min and min or val > max and max or val
end

function get_path(str,sep)
	sep=sep or'\\'
	str = str:reverse()
	local a,b = string.find(str,sep)
	if not (a) then 
		return str:reverse()
	end
	return string.sub(str,b+1):reverse()
end

function trim_directory(str,sep)
	sep=sep or'\\'
	str = str:reverse()
	return string.sub(str,1,string.find(str,sep)-1):reverse()
end

function string.gsplit(s, sep, plain)
	local start = 1
	local done = false
	local function pass(i, j, ...)
		if i then
			local seg = s:sub(start, i - 1)
			start = j + 1
			return seg, ...
		else
			done = true
			return s:sub(start)
		end
	end
	return function()
		if done then return end
		if sep == '' then done = true return s end
		return pass(s:find(sep, start, plain))
	end
end

function str_explode(str,sep,plain)
	if not (sep ~= "" and string.find(str,sep,1,plain)) then
		return { str }
	end
	local t = {}
	for s in str:gsplit(sep,plain) do 
		table.insert(t,trim(s))
	end
	return t
end

function file_to_table(fname,parent,simple)
	local root = parent and parent.root or {}
	local sec,t,key
	for line in io.lines(fname) do
		line = trim(trim_comment(line))
		if (line ~= "" and line ~= "\n") then
			if (startsWith(line, "#include")) then
				if (simple ~= true and parent ~= nil) then
					local inc = string.match(line,[["(.-)"]]) or ""
					if (inc ~= "" and file_exists(get_path(fname)..inc)) then
						file_to_table(get_path(fname)..inc,parent,simple)
					end
				end
			elseif (startsWith(line, "[")) then
				sec = string.match(line,"%[(.-)%]")
				
				if (root[sec]) then
					printf("ERROR: Duplicate section exists! %s",line)
				end

				root[sec] = root[sec] or {}

				local inc = trim(get_section_includes(line))
				if (inc and inc ~= "") then
					root[sec]["_____link"] = inc
					if (simple ~= true) then
						local a = str_explode(inc,",")
						for k,v in pairs(a) do
							if (root[v]) then
								for kk,vv in pairs(root[v]) do
									root[sec][kk] = vv
								end
							end
						end
					end
				end
			elseif (sec) then
				key = trim(string.match(line,"(.-)=") or line)
				if (key ~= "") then
					root[sec] = root[sec] or {}
					root[sec][key] = trim(string.match(line,"=(.+)") or "")
				end
			end
		end
	end

	return root
end

lfs_ignore_exact_ext_match = false
function file_for_each(node,ext,func,nonrecursive,...)
	local stack = {}
	local deepest
	while not deepest do
		if (node) then
			for file in lfs.dir(node) do
				if (file ~= ".." and file ~= ".") then
					local fullpath = node .. "\\" .. file
					local mode = lfs.attributes(fullpath,"mode")
					if (mode == "file") then
						for i=1,#ext do
							if (lfs_ignore_exact_ext_match and string.find(get_ext(file), ext[i]) or get_ext(file) == ext[i]) then
								func(node,file,fullpath,...)
							end
						end
					elseif (mode == "directory" and nonrecursive ~= true) then
						if not (file_exists(fullpath.."\\.ignore")) then
							table.insert(stack,fullpath)
						end
					end
				end
			end
		end
		if (#stack > 0) then
			node = stack[#stack]
			stack[#stack] = nil
		else
			deepest = true
		end
	end
	if lfs_ignore_exact_ext_match then
		lfs_ignore_exact_ext_match = false
	end
end

function directory_for_each(node,func,...)
	for l in lfs.dir(node) do
		if (l ~= ".." and l ~= ".") then
			if lfs.attributes(node.."\\"..l,"mode") == "directory" then
				func(node,l,...)
			end
		end
	end
end

function copy_file_data(file,fullpath,data,overwrite)
	if not (file) then
		return 0
	end

	if not (file_exists(fullpath)) then
		-- create the directory for a newly copied file
		for dir in string.gmatch(fullpath,"(.+)\\","") do
			dir = trim(dir)
			if not (directory_exists(dir)) then
				os.execute('MD "'..dir..'"')
			end
		end
		local output_file = io.open(fullpath,"wb+")
		if (output_file) then
			data = data or file:read("*all")
			if (data) then
				output_file:write(data)
				output_file:close()
				return 1
			end
		else
			return -1
		end
	else
		return 2
	end
	return 0
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-- empties key list
function empty(t)
	for k,v in pairs(t) do 
		t[k] = nil
	end
end 

-- clears normal table
function clear(t)
	while (#t > 0) do 
		table.remove(t)
	end
end

function toBits(num, bits)
    -- returns a table of bits
    local t={} -- will contain the bits
	local rest
    for b=bits,1,-1 do
        rest=math.fmod(num,2)
        t[b]=rest
        num=(num-rest)/2
    end
    if num==0 then return t else return {'Not enough bits to represent this number'}end
end

function is_empty(t)
	for k,v in pairs(t) do 
		return false
	end
	return true
end	

function strformat(s,...)
	s = tostring(s)
	if (select('#',...) >= 1) then
		local i = 0
		local p = {...}
		local function sr(a)
			i = i + 1
			if (type(p[i]) == 'userdata') then
				return 'userdata'
			end
			return tostring(p[i] or "")
		end
		s = string.gsub(s,"%%s",sr)
	end
	return s
end

function strformat_table(tbl,header)
	local txt = header and ("-- " .. tostring(header) .. "\n{\n\n") or "{\n\n"
	local depth = 1

	local function tab(amt)
		local str = ""
		for i=1,amt, 1 do
			str = str .. "\t"
		end
		return str
	end

	local function table_to_string(tbl)
		local size = 0
		for k,v in pairs(tbl) do
			size = size + 1
		end

		local key
		local i = 1

		for k,v in pairs(tbl) do
			if (type(k) == "number") then
				key = "[" .. k .. "]"
			else
				key = "[\""..tostring(k) .. "\"]"
			end

			if (type(v) == "table") then
				txt = txt .. tab(depth) .. key .. " =\n"..tab(depth).."{\n"
				depth = depth + 1
				table_to_string(v,tab(depth))
				depth = depth - 1
				txt = txt .. tab(depth) .. "}"
			elseif (type(v) == "number" or type(v) == "boolean") then
				txt = txt .. tab(depth) .. key .. " = " .. tostring(v)
			elseif (type(v) == "userdata") then
				txt = txt .. tab(depth) .. key .. " = \"unknown userdata\""
			else
				txt = txt .. tab(depth) .. key .. " = \"" .. tostring(v) .. "\""
			end

			if (i == size) then
				txt = txt .. "\n"
			else
				txt = txt .. ",\n"
			end

			i = i + 1
		end
	end

	table_to_string(tbl)

	txt = txt .. "\n}"
	
	return txt
end 

function hex2string(str)
    return (str:gsub('..', function (cc)
        return string.char(tonumber(cc, 16))
    end))
end

function string2hex(str)
    return (str:gsub('.', function (c)
        return string.format('%02X', string.byte(c))
    end))
end

function float2hex (n)
    if n == 0.0 then return 0.0 end

    local sign = 0
    if n < 0.0 then
        sign = 0x80
        n = -n
    end

    local mant, expo = math.frexp(n)
    local hext = {}

    if mant ~= mant then
        hext[#hext+1] = string.char(0xFF, 0x88, 0x00, 0x00)

    elseif mant == math.huge or expo > 0x80 then
        if sign == 0 then
            hext[#hext+1] = string.char(0x7F, 0x80, 0x00, 0x00)
        else
            hext[#hext+1] = string.char(0xFF, 0x80, 0x00, 0x00)
        end

    elseif (mant == 0.0 and expo == 0) or expo < -0x7E then
        hext[#hext+1] = string.char(sign, 0x00, 0x00, 0x00)

    else
        expo = expo + 0x7E
        mant = (mant * 2.0 - 1.0) * math.ldexp(0.5, 24)
        hext[#hext+1] = string.char(sign + math.floor(expo / 0x2),
                                    (expo % 0x2) * 0x80 + math.floor(mant / 0x10000),
                                    math.floor(mant / 0x100) % 0x100,
                                    mant % 0x100)
    end

    return tonumber(string.gsub(table.concat(hext),"(.)",
                                function (c) return string.format("%02X%s",string.byte(c),"") end), 16)
end


function hex2float (c)
	if c == 0 then return 0.0 end
	c = string.gsub(string.format("%X", c),"(..)",function (x) return string.char(tonumber(x, 16)) end)

    local b1,b2,b3,b4 = string.byte(c, 1, 4)
    local sign = b1 > 0x7F
    local expo = (b1 % 0x80) * 0x2 + math.floor(b2 / 0x80)
    local mant = ((b2 % 0x80) * 0x100 + b3) * 0x100 + b4

    if sign then
        sign = -1
    else
        sign = 1
    end

    local n

    if mant == 0 and expo == 0 then
        n = sign * 0.0
    elseif expo == 0xFF then
        if mant == 0 then
            n = sign * math.huge
        else
            n = 0.0/0.0
        end
    else
        n = sign * math.ldexp(1.0 + mant / 0x800000, expo - 0x7F)
    end

    return n
end

function number2bytes(num, width)
	local function _n2b(width, num, rem)
		rem = rem * 256
		if width == 0 then return rem end
		return rem, _n2b(width-1, math.modf(num/256))
	end
	--return string.char(_n2b(width-1, math.modf(num/256)))
	return {_n2b(width-1, math.modf(num/256))}
end

function hex_dump (str)
    local len = string.len( str )
    local dump = ""
    local hex = ""
    local asc = ""
    
    for i = 1, len do
        if 1 == i % 8 then
            dump = dump .. hex .. asc .. "\n"
            hex = string.format( "%04x: ", i - 1 )
            asc = ""
        end
        
        local ord = string.byte( str, i )
        hex = hex .. string.format( "%02x ", ord )
        if ord >= 32 and ord <= 126 then
            asc = asc .. string.char( ord )
        else
            asc = asc .. "."
        end
    end

    
    return dump .. hex .. string.rep( "   ", 8 - len % 8 ) .. asc
end

function table_reverse(tbl)
	for i=1, math.floor(#tbl / 2) do
		tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
	end
end

function Msg(s,...)
	DebugMsg(strformat(s,...).."\n")
end