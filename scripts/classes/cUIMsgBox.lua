Class "cUIMsgBox" (cUIBase)
function cUIMsgBox:initialize(id,title,body,on_yes,on_no)
	self.inherited[1].initialize(self,id)
	
	self.title = title
	self.body = body
	self.on_yes = on_yes
	self.on_no = on_no
end

function cUIMsgBox:Reinit()
	self.inherited[1].Reinit(self)
	
	self:Gui("+AlwaysonTop")
	self:Gui("Add|Button|gOnScriptControlAction x100 y170 w90 h20 vUIMsgBox_Yes|%t_yes")
	self:Gui("Add|Button|gOnScriptControlAction y170 w90 h20 vUIMsgBox_No|%t_no")
	self:Gui("Add|Text|x15 y25 w390 h140|%s",self.body)
	self:Gui("Show|w400 h200|%s",self.title)
end

function cUIMsgBox:OnScriptControlAction(hwnd,event,info)
	self.inherited[1].OnScriptControlAction(self,hwnd,event,info)
	
	if (hwnd == GuiControlGet(self.ID,"hwnd","UIMsgBox_Yes")) then
		self:Show(false)
		if (self.on_yes) then
			self.on_yes()
		end
	elseif (hwnd == GuiControlGet(self.ID,"hwnd","UIMsgBox_No")) then
		self:Show(false)
		if (self.on_no) then 
			self.on_no()
		end
	end
end