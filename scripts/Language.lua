ini = cIniFile("configs\\text\\language.ltx",true)

do
	local lang = gSettings:GetValue("core","language")
	if not (lang and lang ~="" and ini:SectionExist(lang)) then 
		gSettings:SetValue("core","language","english")
	end
end 

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