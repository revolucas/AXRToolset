@echo off

 

rem arguments:

rem   %1: path or name of a specific file to check.

 

if defined %1 do (

        goto scan_var

) else (

        goto scan_dir

)

goto end

 

:scan_var

"%LUA_DEV%\lua.exe" LuaCheck.lua %1 %2

goto end

 

:scan_dir

for %%f in (.\*.lua) do (

        "%LUA_DEV%\lua.exe" "%cd%\LuaCheck.lua" "%%f"

        if %errorlevel% neq 0 pause

)

goto end

 

:end

rem del /Q LuaCheck.log

rem del /Q luac.out

pause