cCallbackManager = Class{}
function cCallbackManager:init()
	self.callbacks = {}
	_G.CallbackRegister = function (...) self.register(self,...) end
	_G.CallbackUnregister = function (...) self.unregister(self,...) end
	_G.CallbackSend = function (...) self.callback(self,...) end
end
function cCallbackManager:register(name,func,usrdata)
	assert(func)
	if not (self.callbacks[name]) then
		self.callbacks[name] = {}
	end
	local function wrapper(...)
		func(usrdata,...)
	end
	self.callbacks[name][func] = wrapper
end
function cCallbackManager:unregister(name,func)
	assert(func)
	if (self.callbacks[name]) then
		self.callbacks[name][func] = nil
	end
end
function cCallbackManager:callback(name,...)
	if not (self.callbacks[name]) then
		return
	end

	for k,func in pairs(self.callbacks[name]) do
		func(...)
	end
end
function cCallbackManager:OnApplicationBegin()
	CallbackSend("OnApplicationBegin")
end 
function cCallbackManager:OnApplicationExit()
	CallbackSend("ApplicationExit")
end
return cCallbackManager()