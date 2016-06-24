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
luaL_dostring(L,"package.path = package.path .. ';lua\\?.lua;plugins\\core\\lua\\?.lua'")
luaL_dostring(L,"package.cpath = package.cpath .. ';bin\\?.dll;..\\bin\\?.dll'")

luaL_dofile(L, "plugins\core\lua\_G.lua")

if lua_isstring(L,-1) {
	MsgBox % "Error: " . lua_tostring(L,-1)
}

; Load all lua plugins
Loop Files, %A_WorkingDir%\plugins\*.lua, R
{
    luaL_dostring(L,"_G.CreateScriptIfNotExist([[" . A_LoopFileDir . "]],[[" . A_LoopFileShortName . "]])")
}

if lua_isstring(L,-1) {
	MsgBox % "Error: " . lua_tostring(L,-1)
}

luaL_dostring(L,"_G.ApplicationBegin()")

;ExitApp
return

#include ahk\label_actions.ahk 
#include ahk\ui_handlers.ahk 
#include ahk\message_register.ahk
