function rem_quotes(txt)
	if not (txt) then return end
	for w in string.gmatch(txt,"[\"'](.+)[\"']") do
		return w
	end
	return txt
end

function addTab(s,n)
	local padding = {}
	local l = string.len(s)
	for i=1,n-l do 
		table.insert(padding," ")
	end 
	return s .. table.concat(padding)
end
	
function trim_comment(str)
	local a = string.find(str,";")
	return a and trim(string.sub(str,1,a-1)) or str
end

function get_comment(str)
	local a = string.find(str,";")
	return a and " " .. string.sub(str,a) or ""
end

function string:split(pat)
	pat = pat or '%s+'
  local st, g = 1, self:gmatch("()("..pat..")")
  local function getter(self, segs, seps, sep, cap1, ...)
    st = sep and seps + #sep
    return self:sub(segs, (seps or 0) - 1), cap1 or sep, ...
  end
  local function splitter(self)
    if st then return getter(self, st, g()) end
  end
  return splitter, self
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
	return string.gsub(s, "^%s*(.-)%s*$", "%1")
end

function get_path(str,sep)
	sep=sep or'\\'
	return str:match("(.*"..sep..")")
end

function trim_directory(str,sep)
	sep=sep or'\\'
	str = str:reverse()
	return string.sub(str,1,string.find(str,sep)-1):reverse()
end

function str_explode(str,div,dont_trim)
	if not (dont_trim) then
		trim(str)
	end
	local t={}
	local cpt = string.find (str, div, 1, true)
	local a
	if cpt then
		repeat
			if not dont_trim then
				a = trim(string.sub(str, 1, cpt-1))
				table.insert( t, a )
			else
				table.insert( t, string.sub(str, 1, cpt-1) )
			end
			str = string.sub( str, cpt+string.len(div) )
			cpt = string.find (str, div, 1, true)
		until cpt==nil
	end
	if not dont_trim then
		a = trim(str)
		table.insert(t, a)
	else
		table.insert(t, str)
	end
	return t
end

function file_to_table(fname,parent,simple)
	local root = parent and parent.root or {}
	local sec,t,key,val
	for line in io.lines(fname) do
		if (line ~= "" and line ~= "\n") then
			if (startsWith(line, "#include")) then
				t = str_explode(line,";")
				t = str_explode(t[1],[["]])

				if (simple ~= true and parent ~= nil and file_exists(get_path(fname)..t[2])) then
					file_to_table(get_path(fname)..t[2],parent,simple)
				end
			elseif (startsWith(line, "[")) then
				t = str_explode(line,";")
				t = str_explode(t[1],":")

				sec = string.sub(t[1],2,-2)

				if (root[sec]) then
					printf("ERROR: Duplicate section exists! %s",line)
				end

				root[sec] = {}

				if (t[2]) then
					root[sec]["_____link"] = t[2]
					if (simple ~= true) then
						local a = str_explode(t[2],",")
						for k,v in pairs(a) do
							if (root[v]) then
								for kk,vv in pairs(root[v]) do
									root[sec][kk] = vv
								end
							end
						end
					end
				end
			elseif (not startsWith(line, ";") and not startsWith(line,"	") and not startsWith(line," ")) then
				t = str_explode(line,";")
				key = trim(string.match(t[1],"(.-)=") or t[1])
				if (key and key ~= "") then
					key = trim(key)
					val = string.match(t[1],"=(.+)")
					if (val) then
						val = trim(val)
					end

					if (sec) then
						root[sec] = root[sec] or {}
						root[sec][key] = val or ""
					else
						root[key] = val or ""
					end
				end
			end
		end
	end

	return root
end

function recurse_subdirectories_and_execute(node,ext,func,...)
	local stack = {}
	local deepest
	while not deepest do
		if (node) then
			for file in lfs.dir(node) do
				if lfs.attributes(file,"mode") == "file" then
					--Msg(file)
				elseif lfs.attributes(file,"mode") == "directory" then
					if (file == ".") then
						for l in lfs.dir(node) do
							if (l ~= ".." and l ~= ".") then
								if lfs.attributes(node.."\\"..file.."\\"..l,"mode") == "file" then
									--Msg(l)
									for i=1,#ext do
										if (get_ext(l) == ext[i]) then
											func(node,l,...)
										end
									end
								elseif lfs.attributes(node.."\\"..file.."\\"..l,"mode") == "directory" then
									--print(node .. "\\"..l)
									table.insert(stack,node .. "\\" .. l)
								end
							end
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
	if (t and #t > 0) then
		for i=#t,1 do 
			table.remove(t,i)
		end
	end
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

function Msg(s,...)
	DebugMsg(strformat(s,...))
end