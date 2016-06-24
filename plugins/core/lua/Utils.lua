function rem_quotes(txt)
	if not (txt) then return end
	for w in string.gmatch(txt,"[\"'](.+)[\"']") do
		return w
	end
	return txt
end

function directory_exists(path)
	return os.execute( "CD " .. path ) == 0
end

function file_exists(path)
	return io.open(path) ~= nil
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
					printf(file)
				elseif lfs.attributes(file,"mode") == "directory" then
					if (file == ".") then
						for l in lfs.dir(node) do
							if (l ~= ".." and l ~= ".") then
								if lfs.attributes(node.."\\"..file.."\\"..l,"mode") == "file" then
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
			return tostring(p[i])
		end
		s = string.gsub(s,"%%s",sr)
	end
	return s
end

function Msg(s,...)
	DebugMsg(strformat(s,...))
end