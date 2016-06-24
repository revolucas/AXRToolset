lua_LoadDLL(dll)
{
   return, DllCall("LoadLibrary", "str", dll)
}

lua_UnloadDLL(hDll)
{
   DllCall("FreeLibrary", "UInt", hDll)
}

lua_atPanic(ByRef l, panicf)
{
   Return, DllCall("lua51\lua_atPanic", "UInt", L, "UInt", panicF, "Cdecl")
}

lua_call(ByRef l, nargs, nresults)
{
   Return, DllCall("lua51\lua_pcall", "UInt", l, "Int", nargs, "Int", nresults, "Cdecl")
}

lua_checkstack(ByRef l, extra)
{
   Return, DllCall("lua51\lua_checkstack", "UInt", l, "Int", extra, "Cdecl Int")
}

lua_close(ByRef l)
{
   Return, DllCall("lua51\lua_close", "UInt", l, "Cdecl")
}

lua_concat(ByRef l, extra)
{
   Return, DllCall("lua51\lua_concat", "UInt", l, "Int", extra, "Cdecl")
}

lua_cpcall(ByRef l, func, ByRef ud)
{
   Return, DllCall("lua51\lua_cpcall", "UInt", l, "UInt", func, "UInt", ud, "Cdecl Int")
}

lua_createtable(ByRef l, narr, nrec)
{
   Return, DllCall("lua51\lua_createtable", "UInt", l, "Int", narr, "Int", nrec, "Cdecl")
}

lua_dump(ByRef l, writer, ByRef data)
{
   Return, DllCall("lua51\lua_dump", "UInt", l, "UInt", writer, "UInt", data, "Cdecl Int")
}

lua_equal(ByRef l, index1, index2)
{
   Return, DllCall("lua51\lua_equal", "UInt", l, "Int", index1, "Int", index2, "Cdecl Int")
}

lua_error(ByRef l)
{
   Return, DllCall("lua51\lua_error", "UInt", l, "Cdecl Int")
}

lua_gc(ByRef l, what, data)
{
   Return, DllCall("lua51\lua_gc", "UInt", l, "Int", what, "Int", data, "Cdecl Int")
}

;lua_getallofc(lua_State *L, void **ud)
; Returns the memory-allocation function of a given state.
; If ud is not NULL, Lua stores in *ud the opaque pointer passed to lua_newstate.

lua_getfenv(ByRef l, index)
{
   Return, DllCall("lua51\lua_getfenv", "UInt", l, "Int", index, "Cdecl")
}

lua_getfield(ByRef L, index, name)
{
   Return, DllCall("lua51\lua_getfield", "UInt", L, "Int", index, "Str", name, "Cdecl")
}

lua_getglobal(ByRef L, name)
{
   ;Return, DllCall("lua51\lua_getfield", "UInt", L, "Int", -10002, "Str", name, "Cdecl")
   Return, lua_getfield(L, -10002, name)
}

lua_getmetatable(ByRef L, index)
{
   Return, DllCall("lua51\lua_getmetatable", "UInt", L, "Int", index, "Cdecl Int")
}

lua_gettable(ByRef L, index)
{
   Return, DllCall("lua51\lua_gettable", "UInt", L, "Int", index, "Cdecl")
}

lua_gettop(ByRef l)
{
   Return, DllCall("lua51\lua_gettop", "UInt", l, "Cdecl Int")
}

lua_insert(ByRef l, index)
{
   Return, DllCall("lua51\lua_insert", "UInt", l, "Int", index, "Cdecl")
}

lua_isboolean(ByRef l, index)
{
   Return, DllCall("lua51\lua_isboolean", "UInt", L, "Int", index, "Cdecl Int")
}

lua_iscfunction(ByRef l, index)
{
   Return, DllCall("lua51\lua_iscfunction", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isfunction(ByRef l, index)
{
   Return, DllCall("lua51\lua_isfunction", "UInt", L, "Int", index, "Cdecl Int")
}

lua_islightuserdata(ByRef l, index)
{
   Return, DllCall("lua51\lua_islightuserdata", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isnil(ByRef l, index)
{
   Return, DllCall("lua51\lua_isnil", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isnone(ByRef l, index)
{
   Return, DllCall("lua51\lua_isnone", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isnoneornil(ByRef l, index)
{
   Return, DllCall("lua51\lua_isnoneornil", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isnumber(ByRef l, index)
{
   Return, DllCall("lua51\lua_isnumber", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isstring(ByRef l, index)
{
   Return, DllCall("lua51\lua_isstring", "UInt", L, "Int", index, "Cdecl Int")
}

lua_istable(ByRef l, index)
{
   Return, DllCall("lua51\lua_istable", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isthread(ByRef l, index)
{
   Return, DllCall("lua51\lua_isthread", "UInt", L, "Int", index, "Cdecl Int")
}

lua_isuserdata(ByRef l, index)
{
   Return, DllCall("lua51\lua_isuserdata", "UInt", L, "Int", index, "Cdecl Int")
}

lua_lessthan(ByRef l, index)
{
   Return, DllCall("lua51\lua_lessthan", "UInt", L, "Int", index, "Cdecl Int")
}

lua_load(ByRef l, reader, ByRef data, ByRef chunkname)
{
   Return, DllCall("lua51\lua_load", "UInt", L, "UInt", reader, "UInt", data, "UInt", chunkname, "Cdecl Int")
}

lua_newstate(f, ByRef ud)
{
   Return, DllCall("lua51\lua_newstate", "UInt", f, "UInt", ud, "Cdecl UInt")
}

lua_newtable(ByRef l)
{
   ;Return, DllCall("lua51\lua_newtable", "UInt", l, "Cdecl")
   Return, lua_createTable(l, 0, 0)
}

lua_newthread(ByRef l)
{
   Return, DllCall("lua51\lua_newthread", "UInt", l, "Cdecl UInt")
}

;void *lua_newuserdata (lua_State *L, size_t size)
; This function allocates a new block of memory with the given size, pushes onto the
; stack a new full userdata with the block address, and returns this address.

lua_next(ByRef l, index)
{
   Return, DllCall("lua51\lua_next", "UInt", L, "Int", index, "Cdecl Int")
}

/*
;--------------------------------------------
;--- A typical traversal looks like this: ---
;--------------------------------------------
   ;table is in the stack at index 't'
   ;first key
   lua_pushnil(L)
   while (lua_next(L, t) != 0)
   {
    ;uses 'key' (at index -2) and 'value' (at index -1)
    msgbox % lua_typename(L, lua_type(L, -2)) " - " lua_typename(L, lua_type(L, -1))

    ;removes 'value'; keeps 'key' for next iteration
    lua_pop(L, 1);
   }
*/


lua_objlen(ByRef l, index)
{
   Return, DllCall("lua51\lua_objlen", "UInt", L, "Int", index, "Cdecl Int")
}

lua_pcall(ByRef l, nargs, nresults, errfunc)
{
   Return, DllCall("lua51\lua_pcall", "UInt", l, "Int", nargs, "Int", nresults, "UInt", errfunc, "Cdecl")
}

lua_pop(ByRef l, no)
{
   Return, DllCall("lua51\lua_pop", "UInt", l, "Int", no, "Cdecl")
}

lua_pushboolean(ByRef l, bool)
{
   Return, DllCall("lua51\lua_pushboolean", "UInt", l, "Int", bool, "Cdecl")
}

lua_pushcclosure(ByRef L, funcAddr, n)
{
   Return, DllCall("lua51\lua_pushcclosure", "UInt", L, "UInt", funcAddr, "Int", n, "Cdecl")
}

lua_pushcfunction(ByRef L, funcAddr)
{
   Return, DllCall("lua51\lua_pushcclosure", "UInt", L, "UInt", funcAddr, "Int", 0, "Cdecl")
   ;Return, lua_pushcclosure(L, funcAdd, 0)
}

;const char *lua_pushfstring (lua_State *L, const char *fmt, ...);
; Pushes onto the stack a formatted string and returns a pointer to this string.
; It is similar to the C function sprintf. also: lua_pushvfstring()

lua_pushinteger(ByRef l, int)
{
   Return, DllCall("lua51\lua_pushinteger", "UInt", l, "Int", int, "Cdecl")
}

lua_pushlightuserdata(ByRef l, ByRef p)
{
   Return, DllCall("lua51\lua_pushlightuserdata", "UInt", l, "UInt", p, "Cdecl")
}

lua_pushliteral(ByRef l, ByRef str)
{
   Return, DllCall("lua51\lua_pushliteral", "UInt", l, "UInt", str, "Cdecl")
}

lua_pushlstring(ByRef l, ByRef str, len)
{
   Return, DllCall("lua51\lua_pushlstring", "UInt", l, "UInt", str, "Int", len, "Cdecl")
}

lua_pushnil(ByRef l)
{
   Return, DllCall("lua51\lua_pushnil", "UInt", l, "Cdecl")
}

lua_pushnumber(ByRef l, no)
{
   Return, DllCall("lua51\lua_pushnumber", "UInt", l, "Double", no, "Cdecl")
}

lua_pushstring(ByRef l, ByRef str)
{
   Return, DllCall("lua51\lua_pushstring", "UInt", l, "Str", str, "Cdecl")
}

lua_pushthread(ByRef l)
{
   Return, DllCall("lua51\lua_pushthread", "UInt", l, "Cdecl")
}

lua_pushvalue(ByRef l, index)
{
   Return, DllCall("lua51\lua_pushvalue", "UInt", l, "Int", index, "Cdecl")
}

lua_rawequal(ByRef l, index1, index2)
{
   Return, DllCall("lua51\lua_rawequal", "UInt", l, "Int", index1, "Int", index2, "Cdecl Int")
}

lua_rawget(ByRef l, index)
{
   Return, DllCall("lua51\lua_rawget", "UInt", l, "Int", index, "Cdecl")
}

lua_rawgeti(ByRef l, index, n)
{
   Return, DllCall("lua51\lua_rawgeti", "UInt", l, "Int", index, "Int", n, "Cdecl")
}

lua_rawset(ByRef l, index)
{
   Return, DllCall("lua51\lua_rawset", "UInt", l, "Int", index, "Cdecl")
}

lua_rawseti(ByRef l, index, n)
{
   Return, DllCall("lua51\lua_rawseti", "UInt", l, "Int", index, "Int", n, "Cdecl")
}

lua_register(ByRef l, name, funcAddr)
{
   ;Return, DllCall("lua51\lua_register", "UInt", l, "Str", name, "UInt", funcAddr, "Cdecl")
   lua_pushcfunction(l, funcAddr)
   lua_setglobal(l, name)
}

lua_remove(ByRef l, index)
{
   Return, DllCall("lua51\lua_remove", "UInt", l, "Int", index, "Cdecl")
}

lua_replace(ByRef l, index)
{
   Return, DllCall("lua51\lua_replace", "UInt", l, "Int", index, "Cdecl")
}

lua_resume(ByRef l, narg)
{
   Return, DllCall("lua51\lua_resume", "UInt", l, "Int", narg, "Cdecl Int")
}

lua_setallocf(ByRef l, f, ByRef ud)
{
   Return, DllCall("lua51\lua_setallocf", "UInt", l, "UInt", f, "UInt", ud, "Cdecl")
}

lua_setfenv(ByRef l, index)
{
   Return, DllCall("lua51\lua_setfenv", "UInt", l, "Int", index, "Cdecl Int")
}

lua_setfield(ByRef L, index, name)
{
   Return, DllCall("lua51\lua_setfield", "UInt", L, "Int", index, "Str", name, "Cdecl")
}

lua_setglobal(ByRef L, name)
{
   ;Return, DllCall("lua51\lua_setfield", "UInt", L, "Int", -10002, "Str", name, "Cdecl")
   Return, lua_setfield(L, -10002, name)
}

lua_setmetatable(ByRef L, index)
{
   Return, DllCall("lua51\lua_setmetatable", "UInt", L, "Int", index, "Cdecl Int")
}

lua_settable(ByRef L, index)
{
   Return, DllCall("lua51\lua_settable", "UInt", L, "Int", index, "Cdecl")
}

lua_settop(ByRef l, index)
{
   Return, DllCall("lua51\lua_settop", "UInt", l, "Int", index, "Cdecl")
}

lua_status(ByRef l)
{
   Return, DllCall("lua51\lua_status", "UInt", l, "Cdecl")
}

lua_toboolean(ByRef l, no)
{
   Return, DllCall("lua51\lua_toboolean", "UInt", l, "Int", no, "Cdecl Int")
}

lua_tocfunction(ByRef l, no)
{
   Return, DllCall("lua51\lua_tocfunction", "UInt", l, "Int", no, "Cdecl UInt")
}

lua_tointeger(ByRef l, no)
{
   Return, DllCall("lua51\lua_tointeger", "UInt", l, "Int", no, "Cdecl Int")
}

lua_tolstring(ByRef l, no, size)
{
   Return, DllCall("lua51\lua_tolstring", "UInt", l, "Int", no, "Int", size, "Cdecl Str")
}

lua_tonumber(ByRef l, no)
{
   Return, DllCall("lua51\lua_tonumber", "UInt", l, "Int", no, "Cdecl Double")
}

lua_topointer(ByRef l, no)
{
   Return, DllCall("lua51\lua_topointer", "UInt", l, "Int", no, "Cdecl UInt")
}

lua_tostring(ByRef l, no)
{
   ;Return, DllCall("lua51\lua_tostring", "UInt", l, "Int", no, "Cdecl Str")
   Return, lua_tolstring(l, no, 0)
}

lua_tothread(ByRef l, no)
{
   Return, DllCall("lua51\lua_tothread", "UInt", l, "Int", no, "Cdecl UInt")
}

lua_touserdata(ByRef l, no)
{
   Return, DllCall("lua51\lua_touserdata", "UInt", l, "Int", no, "Cdecl UInt")
}

lua_type(ByRef l, no)
{
   Return, DllCall("lua51\lua_type", "UInt", l, "Int", no, "Cdecl Int")
}

lua_typename(ByRef l, tp)
{
   Return, DllCall("lua51\lua_typename", "UInt", l, "Int", tp, "Cdecl Str")
}

lua_xmove(ByRef from, ByRef to, n)
{
   Return, DllCall("lua51\lua_xmove", "UInt", from, "UInt", to, "Int", n, "Cdecl")
}

lua_yield(ByRef l, nresults)
{
   Return, DllCall("lua51\lua_yield", "UInt", l, "Int", nresults, "Cdecl Int")
}



;---------------------------------------------
; Load the standard Lua libraries
;---------------------------------------------
luaopen_base(ByRef l)
{
   Return, DllCall("lua51\luaopen_base", "UInt", l, "Cdecl")
}

luaopen_package(ByRef l)
{
   Return, DllCall("lua51\luaopen_package", "UInt", l, "Cdecl")
}

luaopen_string(ByRef l)
{
   Return, DllCall("lua51\luaopen_string", "UInt", l, "Cdecl")
}

luaopen_table(ByRef l)
{
   Return, DllCall("lua51\luaopen_table", "UInt", l, "Cdecl")
}

luaopen_math(ByRef l)
{
   Return, DllCall("lua51\luaopen_math", "UInt", l, "Cdecl")
}

luaopen_io(ByRef l)
{
   Return, DllCall("lua51\luaopen_io", "UInt", l, "Cdecl")
}

luaopen_os(ByRef l)
{
   Return, DllCall("lua51\luaopen_os", "UInt", l, "Cdecl")
}

luaopen_debug(ByRef l)
{
   Return, DllCall("lua51\luaopen_debug", "UInt", l, "Cdecl")
}

;---------------------------------------------
;luaL
;---------------------------------------------
luaL_buffinit(ByRef l, ByRef Buffer)
{
   Return, DllCall("lua51\luaL_buffinit", "UInt", l, "UInt", Buffer, "Cdecl")
}

luaL_callmeta(ByRef l, obj, ByRef e)
{
   Return, DllCall("lua51\luaL_callmeta", "UInt", l, "Int", obj, "Str", e, "Cdecl Int")
}

luaL_checkany(ByRef l, narg)
{
   Return, DllCall("lua51\luaL_checkany", "UInt", l, "Int", narg, "Cdecl")
}

luaL_checkint(ByRef l, no)
{
   Return, DllCall("lua51\luaL_checkint", "UInt", l, "Int", no, "Cdecl Int")
}

luaL_checkinteger(ByRef l, no)
{
   Return, DllCall("lua51\luaL_checkinteger", "UInt", l, "Int", no, "Cdecl Int")
}

luaL_checklong(ByRef l, no)
{
   Return, DllCall("lua51\luaL_checklong", "UInt", l, "Int", no, "Cdecl Int")
}

luaL_checklstring(ByRef l, no, ByRef len)
{
   Return, DllCall("lua51\luaL_checklstring", "UInt", l, "Int", no, "UInt", len, "Cdecl Str")
}

luaL_checknumber(ByRef l, no)
{
   Return, DllCall("lua51\luaL_checknumber", "UInt", l, "Int", no, "Cdecl Int")
}

luaL_checkoption(ByRef l, no, ByRef def, ByRef lst)
{
   Return, DllCall("lua51\luaL_checkoption", "UInt", l, "Int", no, "UInt", def, "UInt", lst, "Cdecl Int")
}

luaL_checkstack(ByRef l, no, ByRef msg)
{
   Return, DllCall("lua51\luaL_checkstack", "UInt", l, "Int", no, "Str", msg, "Cdecl")
}

luaL_checkstring(ByRef l, narg)
{
   Return, DllCall("lua51\luaL_checkstring", "UInt", l, "Int", narg, "Cdecl")
}

luaL_checktype(ByRef l, no, t)
{
   Return, DllCall("lua51\luaL_checktype", "UInt", l, "Int", no, "Int", t, "Cdecl")
}

luaL_checkudata(ByRef l, no, ByRef tname)
{
   Return, DllCall("lua51\luaL_checkudata", "UInt", l, "Int", no, "Str", tname, "Cdecl")
}

luaL_dofile(ByRef l, file)
{
   ;Return, DllCall("lua51\luaL_dofile", "UInt", l, "Str", file, "Cdecl Int")
   luaL_loadfile(l, file)
   Return % lua_pCall(l, 0, -1, 0)
}

luaL_dostring(ByRef l, ByRef str)
{
   ;Return, DllCall("lua51\luaL_dostring", "UInt", l, "Str", str, "Cdecl Int")
   luaL_loadstring(l, str)
   Return % lua_pCall(l, 0, -1, 0)
}

luaL_error(ByRef l, ByRef str)
{
   Return, DllCall("lua51\luaL_error", "UInt", l, "Str", str, "Cdecl Int")
}

luaL_getmetafield(ByRef l, no, ByRef e)
{
   Return, DllCall("lua51\luaL_getmetafield", "UInt", l, "Int", no, "Str", e, "Cdecl Int")
}

luaL_getmetatable(ByRef l, ByRef tname)
{
   Return, DllCall("lua51\luaL_getmetatable", "UInt", l, "Str", tname, "Cdecl")
}

luaL_gsub(ByRef l, ByRef s, ByRef p, ByRef r)
{
   Return, DllCall("lua51\luaL_gsub", "UInt", l, "UInt", s, "UInt", p, "UInt", r, "Cdecl Str")
}

luaL_loadbuffer(ByRef l, ByRef buff, sz, ByRef name)
{
   Return, DllCall("lua51\luaL_loadbuffer", "UInt", l, "UInt", buff, "Int", sz, "Str", name, "Cdecl Int")
}

luaL_loadfile(ByRef l, file)
{
   Return, DllCall("lua51\luaL_loadfile", "UInt", l, "Str", file, "Cdecl Int")
}

luaL_loadstring(ByRef l, ByRef s)
{
   Return, DllCall("lua51\luaL_loadstring", "UInt", l, "Str", s, "Cdecl Int")
}

luaL_newmetatable(ByRef l, ByRef tname)
{
   Return, DllCall("lua51\luaL_newmetatable", "UInt", l, "Str", tname, "Cdecl Int")
}

luaL_newstate()
{
   Return, DllCall("lua51\luaL_newstate", "Cdecl")
}

luaL_openlibs(ByRef l)
{
   Return, DllCall("lua51\luaL_openlibs", "UInt", l, "Cdecl")
}

;int luaL_optint (lua_State *L, int narg, int d);
;lua_Integer luaL_optinteger (lua_State *L, int narg, lua_Integer d);
;long luaL_optlong (lua_State *L, int narg, long d);
;const char *luaL_optlstring (lua_State *L, int narg, const char *d, size_t *l);
;lua_Number luaL_optnumber (lua_State *L, int narg, lua_Number d);
;const char *luaL_optstring (lua_State *L, int narg, const char *d);
;char *luaL_prepbuffer (luaL_Buffer *B);
;void luaL_pushresult (luaL_Buffer *B);
;int luaL_ref (lua_State *L, int t);
;void luaL_register (lua_State *L, const char *libname, const luaL_Reg *l)
;const char *luaL_typename (lua_State *L, int index);
;int luaL_typerror (lua_State *L, int narg, const char *tname);
;void luaL_unref (lua_State *L, int t, int ref);
;void luaL_where (lua_State *L, int lvl);
