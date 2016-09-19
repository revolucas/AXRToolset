#NoEnv
#SingleInstance, force

if (A_IsUnicode) {
	MsgBox This script can only be used with AutoHotKey_L ANSI
	ExitApp
}

#include core\ahk\debug.ahk
#include core\ahk\lua.ahk
#include core\ahk\lua_ahkfunctions.ahk 

; load luajit-2
hDll := lua_loadDll("bin\lua51.dll")
L := luaL_newstate()
OnExit, OnExit
luaL_openlibs(L)
lua_registerAhkFunction(L)

luaL_dofile(L, "core\lua\main.lua")

if lua_isstring(L,-1) {
	MsgBox % "Error: " . lua_tostring(L,-1)
}

;ExitApp
return

#include core\ahk\label_actions.ahk
#include core\ahk\ui_handlers.ahk
#include core\ahk\message_register.ahk
