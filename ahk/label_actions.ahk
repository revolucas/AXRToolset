Dummy:
;do nothing
Return

OnScriptControlAction:
{
	GuiControlGet, h, hwnd, %A_GuiControl%
	
	e :=""
	
	if (A_GuiEvent == "RightClick")
		e = "RightClick"
	else if (A_GuiEvent == "Normal")
		e = "Normal"
	else if (A_GuiEvent == "DoubleClick")
		e = "DoubleClick"
	
	i := A_EventInfo
	luaL_dostring(L,"_G.GuiScriptControlAction([[" . h . "]]," . e . "," . i . ")")
}
Return 

OnExit:
	luaL_dostring(L,"_G.ApplicationExit()")
	lua_close(L)
	lua_UnloadDll(hDll)
	ExitApp
Return

GuiClose:
	luaL_dostring(L,"_G.GuiClose(1)")
Return

2GuiClose:
	luaL_dostring(L,"_G.GuiClose(2)")
Return

3GuiClose:
	luaL_dostring(L,"_G.GuiClose(3)")
Return

4GuiClose:
	luaL_dostring(L,"_G.GuiClose(4)")
Return

5GuiClose:
	luaL_dostring(L,"_G.GuiClose(5)")
Return

6GuiClose:
	luaL_dostring(L,"_G.GuiClose(6)")
Return

7GuiClose:
	luaL_dostring(L,"_G.GuiClose(7)")
Return

8GuiClose:
	luaL_dostring(L,"_G.GuiClose(8)")
Return