cXmlFile = Class "cXmlFile"
function cXmlFile:initialize(fname,simple_mode)
	local f,err = file_exists(fname) and io.open(fname,"rb")
	if (f == nil or err) then 
		return Msg(err)
	end

	local data = f:read("*all")
	f:close()
	
	-- Merge included files
	if (simple_mode) then
		local path = get_path(get_path(fname)) -- trim off gameplay\\
		data = string.gsub(data,[[(#include%s*")([&%w_%-.%s\"'=:]*)(")]],function(a,b,c)
			local import_fname = path.."\\"..b
			if (file_exists(import_fname)) then
				f,err = io.open(import_fname,"rb")
				if not (err) then
					local import_data = f:read("*all")
					f:close()
					return import_data
				end
			end
			return ""
		end)
	end
	
	local function get_count(t)
		local count = 0
		for i,v in ipairs(t) do 
			count = count + 1
		end
		return count
	end
	
	self.fname = fname
	self.node = {}
	self.ptr = self.node

	local charset = "@AÁBCDEÉFGHIÍJKLMNOÓÖÕPQRSTUÚÜÛVWXYZ" ..
		"`aábcdeéfghiíjklmnoóöõpqrstuúüûvwxyz" ..
		[[!"#&'()*+,-./0123456789:;=?^_{|}]] ..
		"~€‚„…‰ŒŽ‘’“”•–—™žŸ¡¢£¥§¨©ª«­®¯°±²³´µ" ..
		"¶·¸¹º»¼½¾¿ÀÂÃÄÅÆÇÈÊËÌÎÏÐÑÒÔ×ØÙÝÞßàâã" ..
		"äåæçèêëìîïðñòô÷øùýþÿ"
				
	local node = self.node
	for a,b,c,d in string.gmatch(data,"<(%/?)([&%w_%-.%s\"'=:]+)(%/?)>(["..charset.."#,=&%^%$%(%)%%%.%[%]%*%+%-%?!%w_%s'\"\\/]*)") do
		if (a ~= "/") then
			local _1,_2 = string.find(b,"%s")
			local t = {
				__namespace 	= trim(_1 and string.sub(b,1,_1-1) or b), 
				__parent		= node, 
				__id 			= get_count(node)+1,
				__attributes	= {}, 
				__content		= d and trim(d) or "",
				__original		= string.format("<%s%s%s>%s",a,b,c,d)
			}
			for key,value in string.gmatch(b,"([%w_%-]*)%s*=%s*([%w_\".%-]*)") do
				t.__attributes[trim(key)] = trim(rem_quotes(value))
			end
			table.insert(node,t)
			
			if (c ~= "/") then
				node = t
			end
		else
			node = node.__parent or self.node
		end
	end
end

function cXmlFile:Root()
	self.ptr = self.node
end

-- If value is nil it will find next node with attribute name
function cXmlFile:FindChildByAttributeValue(namespace,attribute,value,node,start_index)
	local deepest
	local stack = {}
	node = node or self.ptr
	while not deepest do
		for i,child in ipairs(node) do
			if (start_index == nil or i >= start_index) then
				if (child.__namespace == namespace) then
					if (attribute == nil) or (value == nil or child.__attributes[attribute] and child.__attributes[attribute] == value) then
						self.ptr = child
						return child
					end
				end
				table.insert(stack,child)
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

-- If value is nil it will find next node with attribute name
function cXmlFile:FindNext(namespace,attribute,value)
	local next_node = self:FindChildByAttributeValue(namespace,attribute,value)
	if (next_node) then
		return next_node
	end
	
	local current = self.ptr
	local parent = current.__parent
	
	return self:FindChildByAttributeValue(namespace,attribute,value,parent,current.__id+1)
end

function cXmlFile:FindChildByNamespace(namespace)
	for i,child in ipairs(self.ptr) do
		if (child.__namespace == namespace) then
			self.ptr = child
			return child
		end
	end
end

function cXmlFile:GetCount(namespace,attribute,value,node,start_index)
	local count = 0
	local deepest
	local stack = {}
	node = node or self.ptr
	while not deepest do
		for i,child in ipairs(node) do
			if (start_index == nil or i >= start_index) then
				if (child.__namespace == namespace) then
					if (attribute == nil) or (value == nil or child.__attributes[attribute] and child.__attributes[attribute] == value) then
						count = count + 1
					end
				end
				table.insert(stack,child)
			end
		end
		if (#stack > 0) then
			node = stack[#stack]
			stack[#stack] = nil
		else
			deepest = true
		end
	end
	return count
end 

function cXmlFile:GetAttributeValue(attribute)
	return self.ptr.__attributes[attribute]
end

function cXmlFile:SetAttributeValue(attribute,value)
	self.ptr.__attributes[attribute] = value
	self.ptr.__need_save = true
end

function cXmlFile:GetContent()
	return self.ptr.__content
end

function cXmlFile:SetContent(str)
	self.ptr.__content = str
	self.ptr.__need_save = true
end

function cXmlFile:GetParent()
	return self.ptr.__parent
end

function cXmlFile:GetName()
	return self.ptr.__namespace
end

function cXmlFile:SetName(new_name)
	self.ptr.__namespace = new_name
	self.ptr.__need_save = true
end

function cXmlFile:Save(fname)
	fname = fname or self.fname
	local f,err = file_exists(fname) and io.open(fname,"rb")
	if (f == nil or err) then 
		return Msg(err)
	end

	local data = f:read("*all")
	f:close()
	
	local deepest
	local stack = {}
	local node = self.node
	while not deepest do
		for i,child in ipairs(node) do
			if (child.__need_save) then
				child.__original = string.gsub(child.__original,"<(%/?)([&%w_%-.%s\"'=:]+)(%/?)>(["..charset.."#,=&%^%$%(%)%%%.%[%]%*%+%-%?!%w_%s'\"\\/]*)",function(a,b,c,d)
					local new_b = child.__namespace .. " "
					for key,val in spairs(child.__attributes) do 
						new_b = new_b .. string.format([[ %s="%s"]],tostring(key),tostring(val))
					end
					local str = string.format("<%s%s%s>\n%s",a,new_b,c,child.__content)
					data = string.gsub(data,child.__original,str) or data
					return str
				end)
			end
			table.insert(stack,child)
		end
		if (#stack > 0) then
			node = stack[#stack]
			stack[#stack] = nil
		else
			deepest = true
		end
	end
	
	local f,err = file_exists(fname) and io.open(fname,"wb")
	if (f == nil or err) then 
		return Msg(err)
	end
	f:write(data)
	f:close()
end