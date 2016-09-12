cIniFile = Class{}
function cIniFile:init(fname,simple_mode)
	local cfg = io.open(fname,"a+")
	if not (cfg) then
		return
	end
	cfg:close()
	self.fname = fname
	self.directory = get_path(fname) or ""

	self.insert = {}
	self.root = {}
	file_to_table(fname,self,simple_mode)

	return self
end

function cIniFile:GetValue(sec,key,typ)
	local val = self.root and self.root[sec] and self.root[sec][key]
	if (val == nil) then
		return def
	end

	if (typ == 1 or typ == "bool") then
		return val == "true"
	elseif (typ == 2 or typ == "number") then
		return tonumber(val)
	end
	return val
end

function cIniFile:GetKeys(sec)
	if (self.root and self.root[sec]) then
		local t={}
		for k,v in pairs(self.root[sec]) do
			if (k ~= "_____link") then
				t[k] = v
			end
		end
		return t
	end
end

function cIniFile:GetSections(key)
	if (self.root) then 
		local t = {}
		for k,v in pairs(self.root) do 
			if (key == nil) then
				table.insert(t,k)
			else
				for kk,vv in pairs(v) do
					if (kk == key) then
						t[k] = { [kk] = self.root[k][kk] }
					end
				end
			end
		end
		return t
	end
end

function cIniFile:GetKeysAsString(sec,delim)
	delim = delim or ","
	if (self.root and self.root[sec]) then
		local t = {}
		local s = ""
		for k,v in pairs(self.root[sec]) do
			if (k ~= "_____link") then
				table.insert(t,k)
			end
		end
		
		table.sort(t)
		
		for i=1,#t do 
			s = s .. delim .. t[i]
		end
		
		return s
	end
end

function cIniFile:SetValue(sec,key,val)
	if not (self.root) then
		self.root = {}
	end

	if not (self.root[sec]) then
		self.root[sec] = {}
	end
	
	if (self.root[sec][key] == nil) then
		if not (self.insert[sec]) then 
			self.insert[sec] = {}
		end
		table.insert(self.insert[sec],key)
	end

	self.root[sec][key] = val == nil and "" or tostring(val)
end

function cIniFile:ClearValue(sec,key)
	if not (self.root) then
		self.root = {}
	end

	if not (self.root[sec]) then
		self.root[sec] = {}
	end
	self.root[sec][key] = nil
end

function cIniFile:SectionExist(sec)
	return self.root and self.root[sec] ~= nil
end

function cIniFile:KeyExist(sec,key)
	return self.root and self.root[sec] and self.root[sec][key] ~= nil
end

-- Save ini by preserving original file. Cannot insert new keys or sections
function cIniFile:SaveExt()
	local t,sec,comment
	local str = ""

	local function addTab(s,n)
		local padding = {}
		local l = string.len(s)
		for i=1,n-l do 
			table.insert(padding," ")
		end 
		return s .. table.concat(padding)
	end

	for ln in io.lines(self.fname) do
		ln = trim(ln)
		if (startsWith(ln,"[")) then

			-- inject new fields that previously didn't exist
			if (sec and self.root[sec] and self.insert[sec]) then
				for i=1,#self.insert[sec] do
					local k = self.insert[sec][i]
					if (k ~= "_____link") then
						str = str .. addTab(k,40) .. " = " .. tostring(self.root[sec][k]) .. "\n"
					end
				end
			end

			t = str_explode(ln,";")
			t = str_explode(t[1],":")

			sec = string.sub(t[1],2,-2)
		elseif (not startsWith(ln,";") and self.root[sec]) then
			comment = string.find(ln,";")
			comment = comment and string.sub(ln,comment) or ""

			if (comment ~= "") then
				comment = addTab("\t",40) .. comment
			end

			t = str_explode(ln,"=")
			if (self.root[sec][t[1]] ~= nil) then
				if (self.root[sec][t[1]] == "") then
					ln = addTab(t[1],40) .. " =" .. comment
				else
					ln = addTab(t[1],40) .. " = " .. tostring(self.root[sec][t[1]]) .. comment
				end
			end
		end
		str = str .. ln .. "\n"
	end
	
	empty(self.insert)
	
	local cfg = io.open(self.fname,"w+")
	cfg:write(str)
	cfg:close()
end

-- Recreates ini as stored in the table
function cIniFile:Save(sysini,show_equal,save_as_path)
	local _s = {}
	_s.__order = {}

	local function addTab(s,n)
		local l = string.len(s)
		for i=1,n-l do
			s = s .. " "
		end
		return s
	end

	for section,tbl in pairs(self.root) do
		table.insert(_s.__order,section)
		if not (_s[section]) then
			_s[section] = {}
		end
		for k,v in pairs(tbl) do
			table.insert(_s[section],k)
		end
	end

	table.sort(_s.__order)

	for i,section in pairs(_s.__order) do
		table.sort(_s[section])
	end

	local str = ""

	local first
	for i,section in pairs(_s.__order) do
		if not (first) then
			str = str .. "[" .. section .. "]"
			first = true
		else
			str = str .. "\n[" .. section .. "]"
		end

		if (self.root[section]["_____link"]) then
			str = str .. ":" .. self.root[section]["_____link"] .. "\n"
		else
			str = str .. "\n"
		end

		local links = self.root[section]["_____link"] and str_explode(self.root[section]["_____link"],",") or {}

		for ii, key in pairs(_s[section]) do
			if (key ~= "_____link") then
				val = self.root[section][key]

				local skip = false
				if (sysini) then -- ignore Duplicate entries from inherited sections if config is passed!
					for j=1,#links do
						if (sysini:GetValue(links[j],key) == val) then
							skip = true
						end
					end
				end

				if not (skip) then
					if (val == "") then
						if (show_equal) then 
							str = str .. addTab(key,40) .. " = \n"
						else
							str = str .. addTab(key,40) .. "\n"
						end
					else
						str = str .. addTab(key,40) .. " = " .. tostring(val) .. "\n"
					end
				end
			end
		end
	end

	local cfg = io.open(save_as_path or self.fname,"w+")
	cfg:write(str)
	cfg:close()
end

-- Recreates ini as stored in the table
function cIniFile:SaveOrderByClass(lookup)
	local str = "",count

	if (self.includes) then
		for i=1,#self.includes do
			str = str .. self.includes[i] .. "\n"
		end
	end

	local function addTab(s,n)
		local l = string.len(s)
		for i=1,n-l do
			s = s .. " "
		end
		return s
	end

	local __t = {}
	local __c = {}

	-- order to list sections
	local __cls = {
		"II_BOLT",
		"TORCH",
		"TORCH_S",
		"S_PDA",
		"D_PDA",
		"II_DOC",
		"II_ATTCH",
		"II_BTTCH",

		"DET_SIMP",
		"DET_ADVA",
		"DET_ELIT",
		"DET_SCIE",

		"ARTEFACT",
		"SCRPTART",

		"II_FOOD",
		"S_FOOD",
		"II_BOTTL",

		"II_MEDKI",
		"II_BANDG",
		"II_ANTIR",

		"G_F1",
		"G_RGD5",
		"G_F1_S",
		"G_RGD5_S",

		"AMMO",
		"AMMO_S",
		"S_OG7B",
		"S_VOG25",
		"S_M209",

		"WP_SCOPE",
		"WP_SILEN",
		"WP_GLAUN",

		"WP_AK74",
		"WP_ASHTG",
		"WP_BINOC",
		"WP_BM16",
		"WP_GROZA",
		"WP_HPSA",
		"WP_KNIFE",
		"WP_LR300",
		"WP_PM",
		"WP_RG6",
		"WP_RPG7",
		"WP_SVD",
		"WP_SVU",
		"WP_VAL",

		"EQU_STLK",
		"EQU_HLMET",
		"E_STLK",
		"E_HLMET"
	}

	for section,tbl in pairs(self.root) do
		if not (__t[section]) then
			__t[section] = {}
		end
		for key,val in pairs(self.root[section]) do
			if (lookup) then
				local cls = lookup:GetValue(key,"class")
				if (cls and Xray.valid_item_classes[cls] == true) then
					if not (__c[cls]) then
						__c[cls] = {}
					end
					if not (__c[cls][section]) then
						__c[cls][section] = {}
					end
					table.insert(__c[cls][section],key)
				else
					table.insert(__t[section],key)
				end
			else
				table.insert(__t[section],key)
			end
		end
	end

	for k,v in pairs(__t) do
		table.sort(__t[k])
	end

	for k,v in pairs(__c) do
		for kk,vv in pairs(v) do
			table.sort(__c[k][kk])
		end
	end

	for section,tbl in pairs(self.root) do
		str = str .. "\n[" .. section .. "]\n"

		if (self.links and self.links[section]) then
			str = str .. ":"
			count = #self.links[section]
			for i=1,count do
				if (count > 1 and i ~= count) then
					str = str .. self.links[section][i] .. ","
				else
					str = str .. self.links[section][i]
				end
			end
		end
		for i,cls in pairs(__cls) do
			if (__c[cls] and __c[cls][section]) then
				str = str .. "\n;" .. cls .. "\n"
				for k,v in pairs(__c[cls][section]) do
					if (tbl[v] and tbl[v] ~= "nil") then
						if (tbl[v] == "") then
							str = str .. addTab(v,40) .. "\n"
						else
							str = str .. addTab(v,40) .. " = " .. tostring(tbl[v]) .. "\n"
						end
					end
				end
			end
		end
		for k,v in pairs(__t[section]) do
			if (tbl[v] and tbl[v] ~= "nil") then
				if (tbl[v] == "") then
					str = str .. addTab(v,40) .. "\n"
				else
					str = str .. addTab(v,40) .. " = " .. tostring(tbl[v]) .. "\n"
				end
			end
		end
	end

	local cfg = io.open(self.fname,"w+")
	cfg:write(str)
	cfg:close()
end

function New(...)
	return cIniFile(...)
end