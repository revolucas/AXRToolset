cXmlFile = Class "cXmlFile"
function cXmlFile:initialize(fname)
	local f,err = file_exists(fname) and io.open(fname,"rb")
	if (f == nil or err) then 
		return Msg(err)
	end

	local data = f:read("*all")
	f:close()
	
	-- Merge included files
	local path = get_path(fname)
	data = string.gsub(data,[[(#include%s*")([%w_.%-\\]*)(")]],function(a,b,c)
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
	
	self.fname = fname
	self.node = {}
	self.ptr = self.node

	local node = self.node
	for a,b,c,d in string.gmatch(data,"<(%/?)([%w_%-.%s\"'=:]+)(%/?)>([%^%$%(%)%%%.%[%]%*%+%-%?!%w_%s'\"\\]*)") do
		if (a ~= "/") then
			local t = {
				__namespace 	= trim(string.sub(b,1,string.find(b,"%s"))), 
				__parent		= node, 
				__attributes	= {}, 
				__content		= d and trim(d) or ""
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

function cXmlFile:FindChildByAttributeValue(namespace,attribute,value)
	local deepest
	local stack = {}
	local node = self.ptr
	while not deepest do
		for i,child in ipairs(node) do
			if (child.__namespace == namespace and child.__attributes[attribute] and child.__attributes[attribute] == value) then
				self.ptr = child
				return child
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
end

function cXmlFile:FindChildByNamespace(namespace)
	for i,child in ipairs(self.ptr) do
		if (child.__namespace == namespace) then
			self.ptr = child
			return child
		end
	end
end

function cXmlFile:GetAttributeValue(attribute)
	return self.ptr.__attributes[attribute]
end

function cXmlFile:GetContent()
	return self.ptr.__content
end

function cXmlFile:GetParent()
	return self.ptr.__parent
end

function cXmlFile:GetName()
	return self.ptr.__namespace
end

function cXmlFile:GetCurrentNode()
	return self.ptr
end