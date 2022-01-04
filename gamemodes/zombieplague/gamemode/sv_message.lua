AddCSLuaFile("cl_message.lua")
function BroadcastMessage(text)
	for i, ply in ipairs(player.GetAll()) do
		SendColorMessage(ply, text, Color(255, 255, 255))
	end
end
function BroadcastColorMessage(text, Clr, Exclude)
	for i, ply in ipairs(player.GetAll()) do
		if !Exclude || !table.HasValue(Exclude, ply) then
			SendColorMessage(ply, text, Clr)
		end
	end
end
function BroadcastSound(SoundPath, Exclude)
	for i, ply in ipairs(player.GetAll()) do
		if !Exclude || !table.HasValue(Exclude, ply) then
			SendSound(ply, SoundPath)
		end
	end
end
function BroadcastNotifyMessage(txt, time, Clr)
	for i, ply in ipairs(player.GetAll()) do
		SendNotifyMessage(ply, txt, time, Clr)
	end
end
function SendMessage(ply, text)
	SendColorMessage(ply, text, Color(255, 255, 255))
end
function SendColorMessage(ply, text, Clr)
	net.Start("SendMessage")
		net.WriteColor(Clr)
		net.WriteString(text)
	net.Send(ply)
end
function SendConsoleMessage(ply, text)
	net.Start("SendConsoleMessage")
		net.WriteString(text)
	net.Send(ply)
end
function SendPopupMessage(ply, txt)
	net.Start("SendPopupMessage")
		net.WriteString(txt)
	net.Send(ply)
end
function SendSound(ply, SoundPath)
	net.Start("SendSound")
		net.WriteString(SoundPath)
	net.Send(ply)
end
function SendNotifyMessage(ply, txt, time, color)
	net.Start("SendNotifyMessage")
		net.WriteInt(time or 5, 8)
		net.WriteString(txt)
		net.WriteColor(color or Color(255, 255, 255))
	net.Send(ply)
end
util.AddNetworkString("SendMessage")
util.AddNetworkString("SendConsoleMessage")
util.AddNetworkString("SendPopupMessage")
util.AddNetworkString("SendSound")
util.AddNetworkString("SendNotifyMessage")