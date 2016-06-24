-- uses the lua command line compiler to check the syntax of a lua file

-- formats the output so as to MS DevStudio can understand the output

-- and jump to the next error line

--

-- how to make it work?

--

-- just set up a new Tool (Tools/Customize/Tools) with the following options:

-- Command                                       : lua.exe

-- Arguments                             : -f LuaCheck.lua "$(FilePath)"

-- Initial directory : c:\lua (or wherever your lua.exe is located)

-- Use Output Window : (checked)

--

-- After that, you can add a keyboard shortcut for this tool:

-- (Tools/Customize/Tools) (select from Category: Tools, then from

-- Commands: UserToolX (where X is the number of the newly defined tool)

-- then assign a new key to it...

--

-- Have Fun!

-- Peter Prade



function string.ends(s, p)

   return s == "" or s:sub(-p:len()) == p

end



function printf(fmt, ...)

        if ... == nil then

                print(fmt)

        else

                print(fmt:format(...))

        end

end



function sprintf(fmt, ...)

        return fmt:format(...)

end



-- from shell.lua, by Peter Odding

function escape(...)

        local command = type(...) == 'table' and ... or { ... }

        for i, s in ipairs(command) do

                s = (tostring(s) or ''):gsub('"', '\\"')

                if s:find('[^A-Za-z0-9_."/-]') then

                        s = '"' .. s .. '"'

                elseif s == '' then

                        s = '""'

                end

                command[i] = s

        end

        return table.concat(command, ' ')

end



-- get argument - the file name

local file, cwd, fullpath

if arg and #arg > 0 then

        fullpath = escape(arg[1])



        if #arg >= 2 then

                file = arg[1]:sub(arg[2]:len() + 2)

                cwd  = arg[2]

        else

                file = arg[1]

                local cd = io.popen("cd")

                cwd = cd:read('*l')

                cd:close()

        end



        if not string.ends(file, ".lua") and not string.ends(file, ".script") then

                print("warning: file has invalid extension!")

                os.exit(-1)

        elseif string.ends(file, "lua_help.script") then

                print("skipping: 'lua_help.script'")

                os.exit(-2)

        end

        -- for i = 0, #arg do

        --      printf("\targ[%d] = `%s'", i, arg[i])

        -- end

end

-- printf("full: `%s'", fullpath)

-- printf("file: `%s'", file)

-- printf("cwd:  `%s'", cwd)



function readfile(path)

        assert(type(path) == 'string')

        local file, errmsg = io.open(path, 'r')

        if not file then

                error(errmsg)

        end

        local data = file:read('*a')

        file:close()

        return data

        -- if h == nil then

        --      h = io.input()

        -- elseif type(h) == "string" then

        --      h = io.open(h, 'r')

        --      if h == nil then

        --              print("error: failed to open LuaCheck.log")

        --              os.exit(-4)

        --      end

        -- end

        -- local s = ""

        -- for line in h:lines() do

        --      s = sprintf("%s%s\n", s, line)

        -- end

        -- h:close()

        -- return s

end



function tfind(t, s)

        local i, v

        for i, v in ipairs(t) do

                if v == s then

                        return i

                end

        end

end



function tadd(t, v)

        if not tfind(t, v) then

                table.insert(t, v)

        end

end



-- reformat errors so that visual studio understands them:

function outputerror(msg, last, line, file)

        printf("%s(%d): error: %s", file, line, msg)

        string.gsub(msg, "%((.-) at line (.-)%)%;$", function(msg, line)

                printf("%s(%d): error: ... %s", file, line, msg)

        end)

        printf("%s(%d): error: %s", file, line, last)

end



-- format list of globals nicely:

function printnice(t)

        local n = #t

        local l = n - 1

        for i, v in ipairs(t) do

                print(v)



                if i < l then

                        print(", ")

                elseif i < n then

                        print(" and ")

                end



                if math.fmod(i, 5) ~= 0 then

                        print("\n")

                end

        end

        if math.fmod(i, 5) ~= 0 then

                print("\n")

        end

end



if file then -- check the specified file:

        printf("LuaCheck: `%s'", file)



        -- local luacExePath = escape(os.getenv('LUA_DEV') .. '\\luac.exe')

        local luacExePath = escape('%LUA_DEV%\\luac.exe')



        local outFilePath     = '%TEMP%\\LuaCheck.out'

        local logFilePath     = '%TEMP%\\LuaCheck.log'

        local logFileFullPath = os.getenv('TEMP') .. '\\LuaCheck.log'



        -- local logFilePath     = 'LuaCheck.log'

        -- local logFileFullPath = 'LuaCheck.log'



        local shellCommand = sprintf(

                '"%s -o %s -p %s 2>%s"',

                luacExePath,

                outFilePath,

                fullpath,

                logFilePath

        )



-- printf("\nlog: `%s'", logFilePath)

-- printf("lua: `%s'", luacExePath)

-- printf("\ncmd: `%s'\n", shellCommand)

        local shellResult  = os.execute(shellCommand)



        local _, errorCount = string.gsub(

                readfile(logFileFullPath),

                "luac%:(.-)\n   (last token read: `.-') at line (.-) in file `(.-)'",

                outputerror

        )

        errorCount = tonumber(errorCount)

        printf("%d syntax error(s) found.", errorCount)



        shellResult = errorCount



        if errorCount == 0 then

                shellCommand = sprintf(

                        '"%s -o %s -l %s >%s"',

                        luacExePath,

                        outFilePath,

                        fullpath,

                        logFilePath

                )



-- printf("\ncmd: `%s'\n", shellCommand)

                shellResult = os.execute(shellCommand)



                names_set = {}

                string.gsub(

                        readfile(logFileFullPath),

                        "%d+    %[%d+%] SETGLOBAL               %d+     ; (.-)\n",

                        function(name)

                                tadd(names_set, name)

                        end

                )



                if #names_set > 0 then

                        table.sort(names_set)

                        printf("%d global variable(s) are created in the file: ", #names_set)

                        printnice(names_set)

                end

        end



        os.remove(outFilePath)

        os.remove(logFilePath)



        os.exit(shellResult)

else

        print("error: no file to scan specified")

        os.exit(-3)

end

