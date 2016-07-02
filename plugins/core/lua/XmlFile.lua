function LoadFile(path)
	local hFile, err = io.open(path, "r");
	if hFile and not err then
		local xmlText = hFile:read("*a"); -- read file content
		io.close(hFile);
		return ParseXmlText(xmlText), nil;
	else
		Msg(err)
		return nil
	end
end

function ToXmlString(value)
	value = string.gsub(value, "&", "&amp;"); -- '&' -> "&amp;"
	value = string.gsub(value, "<", "&lt;"); -- '<' -> "&lt;"
	value = string.gsub(value, ">", "&gt;"); -- '>' -> "&gt;"
	value = string.gsub(value, "\"", "&quot;"); -- '"' -> "&quot;"
	value = string.gsub(value, "([^%w%&%;%p%\t% ])",
		function(c)
			return string.format("&#x%X;", string.byte(c))
		end);
	return value;
end
function FromXmlString(value)
	value = string.gsub(value, "&#x([%x]+)%;",
		function(h)
			return string.char(tonumber(h, 16))
		end);
	value = string.gsub(value, "&#([0-9]+)%;",
		function(h)
			return string.char(tonumber(h, 10))
		end);
	value = string.gsub(value, "&quot;", "\"");
	value = string.gsub(value, "&apos;", "'");
	value = string.gsub(value, "&gt;", ">");
	value = string.gsub(value, "&lt;", "<");
	value = string.gsub(value, "&amp;", "&");
	return value;
end
function ParseArgs(s)
	local arg = {}
	string.gsub(s, "(%w+)=([\"'])(.-)%2", function(w, _, a)
		arg[w] = FromXmlString(a);
	end)
	return arg
end
function ParseXmlText(xmlText,path)
  local stack = {}
  local top = {Name=nil,Value=nil,Attributes={},ChildNodes={}}
  table.insert(stack, top)
  local ni,c,label,xarg, empty
  local i, j = 1, 1
  while true do
    ni,j,c,label,xarg, empty = string.find(xmlText, "<(%/?)([%w_:]+)(.-)(%/?)>", i)
    if not ni then break end
    local text = string.sub(xmlText, i, ni-1);
    if not string.find(text, "^%s*$") then
      top.Value=(top.Value or "")..FromXmlString(text);
    end
    if empty == "/" then  -- empty element tag
		table.insert(top.ChildNodes, {Name=label,Value=nil,Attributes=ParseArgs(xarg),ChildNodes={}})
    elseif c == "" then   -- start tag
		top = {Name=label, Value=nil, Attributes=ParseArgs(xarg), ChildNodes={}}
		table.insert(stack, top)   -- new level
		--log("openTag ="..top.Name);
    else  -- end tag
		local toclose = table.remove(stack)  -- remove top
		--log("closeTag="..toclose.Name);
		top = stack[#stack]
		if #stack < 1 then
			Msg("XmlP: nothing to close with %s",label)
		end
		if toclose.Name ~= label then
			Msg(text)
			Msg("XmlP: trying to close %s with %s",toclose.Name,label)
		end
		if (top) then
		table.insert(top.ChildNodes, toclose)
		end
    end
    i = j+1
  end
  local text = string.sub(xmlText, i);
  if not string.find(text, "^%s*$") then
      stack[#stack].Value=(stack[#stack].Value or "")..FromXmlString(text);
  end
  if #stack > 1 then
    Msg("XmlP: unclosed "..stack[stack.n].Name)
  end
  return stack[1] and stack[1].ChildNodes[1];
end

function FindNodeWithAttribute(n,node_name,prop_name,val)
	local node = n.ChildNodes
	local deepest,p,c
	local stack = {}
	while not deepest do
		if (node and #node > 0) then
			for i=1,#node do
				if (node[i].Name == node_name and node[i].Attributes[prop_name] == val) then
					return node[i]
				end
				c = node[i].ChildNodes
				if (c and #c > 0) then
					table.insert(stack,node[i].ChildNodes)
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

function FindNextNodeByName(n,node_name)
	if (n.ChildNodes and #n.ChildNodes > 0) then
		for k,v in pairs(n.ChildNodes) do
			if (v.Name == node_name) then
				return n.ChildNodes[k]
			end
		end
	end
end

function GetNodeValue(n,node_name)
	if (n.ChildNodes and #n.ChildNodes > 0) then
		for k,v in pairs(n.ChildNodes) do
			if (v.Name == node_name) then
				return n.ChildNodes[k].Value
			end
		end
	end
end

function GetNodeAttribute(n,node_name,attribute)
	if (n.ChildNodes and #n.ChildNodes > 0) then
		for k,v in pairs(n.ChildNodes) do
			if (v.Name == node_name) then
				return n.ChildNodes[k].Attributes[attribute]
			end
		end
	end
end