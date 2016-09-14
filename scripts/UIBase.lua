-----------------------------------------------------------------
-- UI Class Definition
-----------------------------------------------------------------
cUIBase = Class "cUIBase"
function cUIBase:initialize(id)
	self.ID = id or "1"
end

function cUIBase:Show(bool)
	if (bool) then
		if not (self.isShown) then
			self.isShown = true
			if (self.parent) then 
				self.parent:Show(false)
			end
			self:Create()
		end
	else 
		if (self.isShown) then
			self.isShown = false
			self:Destroy()
			if (self.parent) then 
				self.parent:Show(true)
			end
		end
	end
end

function cUIBase:Create()
	if (self.loaded) then
		return 
	end
	
	self.loaded = true

	self:Reinit()
	
	-- Register for callbacks
	CallbackRegister("OnScriptControlAction",self)
	CallbackRegister("OnGuiClose",self)
end 

function cUIBase:Destroy()
	if not (self.loaded) then 
		return 
	end 
	
	self.loaded = false
	self:Gui("Destroy")
	
	-- Unregister for callbacks 
	CallbackUnregister("OnScriptControlAction",self)
	CallbackUnregister("OnGuiClose",self)
end 

function cUIBase:OnGuiClose(idx)
	if (idx == self.ID) then
		self:Show(false)
	end
end

function cUIBase:Reinit()

end

function cUIBase:OnScriptControlAction()

end

function cUIBase:Gui(str,...)
	str = strformat(str,...)
	local p = str_explode(str,"|") -- separate string into subcommands using |
	p[1] = self.ID .. ":" .. p[1]
	p[4] = p[4] and p[4]:gsub("%^","|") -- replace ^ with | because AHK separator is | but we use that to separate subcommands
	Gui(unpack(p))
end