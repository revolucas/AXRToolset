#NoEnv
#SingleInstance, force

if (A_IsUnicode) {
	MsgBox This script can only be used with AutoHotKey_L ANSI
	ExitApp
}

#include ahk\debug.ahk
#include ahk\lua.ahk
#include ahk\lua_ahkfunctions.ahk 

; load luajit-2
hDll := lua_loadDll("bin\lua51.dll")
L := luaL_newstate()
OnExit, OnExit
luaL_openlibs(L)
lua_registerAhkFunction(L)

; Append to default package paths
luaL_dostring(L,"package.path = package.path .. ';core\\?.lua'")
luaL_dostring(L,"package.cpath = package.cpath .. ';bin\\?.dll;..\\bin\\?.dll'")

luaL_dofile(L, "core\main.lua")

if lua_isstring(L,-1) {
	MsgBox % "Error: " . lua_tostring(L,-1)
}

;ExitApp
return

#include ahk\label_actions.ahk 
#include ahk\ui_handlers.ahk 
#include ahk\message_register.ahk
