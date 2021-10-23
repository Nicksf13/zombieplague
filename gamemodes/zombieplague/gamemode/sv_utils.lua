WARNING_MESSAGE = 1
ERROR_MESSAGE = 2
INFO_MESSAGE = 3

Utils = {}

function Utils:RecursiveFileSearch(CurrentPath, FileSufix)
	local Files, Directories = file.Find(CurrentPath .. "/*", "LUA")
	local LuaFiles = {}

	if(Files && !table.IsEmpty(Files)) then
		for k, File in pairs(Files) do
			if(string.EndsWith(File, FileSufix)) then
				LuaFiles[SysTime() .. File] = CurrentPath .. "/" .. File
			else
				Utils:Print(WARNING_MESSAGE, "'" .. CurrentPath .. "/" .. File .. "' is not a .lua, ignoring it!")
			end
		end
	end

	if(Directories && !table.IsEmpty(Directories)) then
		for k, Directory in pairs(Directories) do
			table.Merge(LuaFiles, Utils:RecursiveFileSearch(CurrentPath .. "/" .. Directory, FileSufix))
		end
	end

	return LuaFiles
end

function Utils:Print(MessageType, Message)
	local MessagePrefix = ""
	if(MessageType == WARNING_MESSAGE) then
		MessagePrefix = "WARNING"
	elseif(MessageType == ERROR_MESSAGE) then
		MessagePrefix = "ERROR"
	elseif(MessageType == INFO_MESSAGE) then
		MessagePrefix = "INFO"
	end

	print("[" .. MessagePrefix .. "] " .. Message)
end