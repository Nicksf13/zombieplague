ConvarManager:CreateConVar("zp_print_class_filter", "ALL", 8, "cvar used to set the only class which will print using Utils:Print, if set to 'ALL' will print all messages")

WARNING_MESSAGE = 1
ERROR_MESSAGE = 2
INFO_MESSAGE = 3
DEBUG_MESSAGE = 4

Utils = {
	Messages = {}
}

function Utils:RecursiveFileSearch(CurrentPath, FileSufix)
	local Files, Directories = file.Find(CurrentPath .. "/*", "LUA")
	local LuaFiles = {}

	if(Files && !table.IsEmpty(Files)) then
		for k, File in pairs(Files) do
			if(string.EndsWith(File, FileSufix)) then
				LuaFiles[SysTime() .. File] = CurrentPath .. "/" .. File
			else
				Utils:Print("Utils", WARNING_MESSAGE, "'" .. CurrentPath .. "/" .. File .. "' is not a .lua, ignoring it!")
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

function Utils:Print(TableClass, MessageType, Message)
	local PrintClassFilter = cvars.String("zp_print_class_filter", "ALL")

	if PrintClassFilter != "ALL" && PrintClassFilter != TableClass then
		return
	end

	local MessagePrefix = ""
	if(MessageType == WARNING_MESSAGE) then
		MessagePrefix = "WARNING"
	elseif(MessageType == ERROR_MESSAGE) then
		MessagePrefix = "ERROR"
	elseif(MessageType == INFO_MESSAGE) then
		MessagePrefix = "INFO"
	elseif(MessageType == DEBUG_MESSAGE) then
		MessagePrefix = "DEBUG"
	end
	print("[" .. MessagePrefix .. "] " .. Message)
end
function Utils:SporaticPrint(TableClass, MessageId, DelayBeforeNewMessage, MessageType, Message)
	if !self.Messages[MessageId] || self.Messages[MessageId] < CurTime() then
		self:Print(TableClass, MessageType, Message)

		self.Messages[MessageId] = CurTime() + DelayBeforeNewMessage
	end
end
function Utils:SporaticDebugPrint(TableClass, DelayBeforeNewMessage, MessageId, Message)
	self:SporaticPrint(TableClass, MessageId, DelayBeforeNewMessage, DEBUG_MESSAGE, Message)
end
function Utils:DebugPrint(TableClass, Message)
	self:Print(TableClass, DEBUG_MESSAGE, Message)
end