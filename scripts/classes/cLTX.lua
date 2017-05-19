Class "cLTX"
function cLTX:initialize(fname,simple_mode)
	local cfg,err = io.open(fname,"rb")
	if not (cfg) then
		return
	end
	local data = trim_comments(cfg:read("*all"))
	cfg:close()
	
	self.fname = fname
	self.sections = setmetatable({},{})
	
	-- Parse included files
	local inc = 0
	if not (simple_mode) then
		local path = get_path(fname)
		local imported = {}
		for s in string.gmatch(data,[[#include%s*"([&%w_%-.%s\"'=:]*)"]]) do 
			local import = cLTX(path.."\\"..s)
			if (import.sections) then
				table.insert(imported,import.sections)
			end
		end
		getmetatable(self.sections).__index = function(t,k)
			if (imported) then 
				for i,sections in ipairs(imported) do
					local v = sections[k]
					if (v ~= nil) then
						return v 
					end
				end
			end
		end
	end
	
	-- Parse file to table
	self:ParseData(data)
end

function cLTX:ParseData(data)
	for section,body in string.gmatch(data,"%[([%w%._%-]+)%]([^%[%]]*)") do
		local inherit
		section = trim(section)
		
		if not (self.sections[section]) then
			self.sections[section] = setmetatable({},{})
		end
				
		for ln in string.gmatch(body,"([^\n\r]+)") do
			ln = trim(ln)
			if (ln:find(":") == 1) then
				inherit = str_explode(ln:sub(2,ln:find("[\r\n]")),",")
			elseif (ln ~= "") then
				local eq = ln:find("=")
				local new_key = eq and trim(ln:sub(1,eq-1)) or trim(ln)
				local new_val = eq and trim(ln:sub(eq+1)) or ""
				
				self.sections[section][new_key] = new_val
			end
		end
		
		getmetatable(self.sections[section]).__index=function(tbl,key)
			if (inherit) then
				for i=#inherit,1 do
					if (self.sections[inherit[i]]) then
						local ret = self.sections[inherit[i]][key]
						if (ret ~= nil) then
							return ret
						end
					end
				end
			end
			return
		end
	end
end 

function cLTX:GetValue(sec,key,typ,def)
	local v = self.sections[sec] and self.sections[sec][key]
	if (v == nil) then 
		return def 
	elseif (typ == 1) then 
		return v == "true" or v == "1"
	elseif (typ == 2) then 
		return tonumber(v) or def
	end
	return v
end

function cLTX:SetValue(sec,key,val)
	if not (self.sections[sec]) then 
		self.sections[sec] = {}
	end
	self.sections[sec][key] = val and tostring(val) or ""
end

function cLTX:SectionExist(sec)
	return self.sections[sec] ~= nil
end

function cLTX:KeyExist(sec,key)
	return self.sections[sec] and self.sections[sec][key] ~= nil
end

function cLTX:ClearValue(sec,key)
	if (self.sections[sec]) then
		self.sections[sec][key] = nil 
	end
end

function cLTX:Save(save_as_path)
	local cfg = io.open(save_as_path or self.fname,"wb+")

	local function addTab(s,n)
		local l = string.len(s)
		for i=1,n-l do
			s = s .. " "
		end
		return s
	end
	
	for section,kv in spairs(self.sections) do
		cfg:write(strformat("[%s]\n",section))
		for key,value in spairs(kv) do
			if (value == "") then 
				cfg:write(key.."\n")
			else
				cfg:write(strformat("%s%s= %s\n",key,addTab(key,40),value))
			end
		end
	end
	
	cfg:close()
end