ini = cIniFile("configs\\text\\language.ltx",true)
function translate(str)
	return ini:GetValue(gSettings:GetValue("core","language"),str) or str
end

function format(s)
	local sec = gSettings:GetValue("core","language")
	for k,v in pairs(ini.root[sec]) do
		s = string.gsub(s,"%%"..k,v)
	end
	return s
end