cUIBase = Class{}
function cUIBase:init()
	self.ID = UIMainMenuWnd:GetID() 
end

function cUIBase:Show(bool)
	if (bool) then
		if not (self.isShown) then 
			self.isShown = true
			self:Create()
		end
	else 
		--if (self.isShown) then
			self.isShown = false
			self:Destroy()
		--end
	end
end

function cUIBase:Create()
	if (self.loaded) then
		return 
	end
	
	self.loaded = true

	-- Register for callbacks
	CallbackRegister("OnScriptControlAction",self.OnScriptControlAction,self)
	CallbackRegister("OnGuiClose",self.OnGuiClose,self)
		
	self:Reinit()
end 

function cUIBase:Destroy()
	self.loaded = false
	self:Gui("Destroy")
	
	-- Unregister for callbacks 
	CallbackUnregister("OnScriptControlAction",self.OnScriptControlAction)
	CallbackUnregister("OnGuiClose",self.OnGuiClose)
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

function cUIBase:Gui(str,...) -- If using text with commas then use normal method
	str = strformat(str,...)
	local p = str_explode(str,",")
	p[1] = self.ID .. ":" .. p[1]
	Gui(unpack(p))
end