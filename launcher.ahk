#NoEnv
#SingleInstance, force

OnMessage(0x115, "OnScroll") ; WM_VSCROLL
OnMessage(0x114, "OnScroll") ; WM_HSCROLL

#include core\debug.ahk
#include core\lua.ahk
#include core\lua_ahkfunctions.ahk
OnExit, OnExit

; load luajit-2
hDll := lua_loadDll("bin\lua51.dll")
L := luaL_newstate()
luaL_openlibs(L)
lua_registerAhkFunction(L)

luaL_dofile(L, "core\environment.lua")

if lua_isstring(L,-1) {
	MsgBox % "Error: " . lua_tostring(L,-1)
}

;ExitApp
return

#include core\label_actions.ahk
#include core\message_handlers.ahk