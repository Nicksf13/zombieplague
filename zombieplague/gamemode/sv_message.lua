AddCSLuaFile("cl_message.lua")
function BroadcastMessage(text)
	for k, ply in pairs(player.GetAll()) do
		SendColorMessage(ply, text, Color(255, 255, 255))
	end
end
function BroadcastColorMessage(text, cor, listaExcluir)
	for k, ply in pairs(player.GetAll()) do
		if listaExcluir == nil || !table.HasValue(listaExcluir, ply) then
			SendColorMessage(ply, text, cor)
		end
	end
end
function BroadcastSound(SoundPath, Exclude)
	for k, ply in pairs(player.GetAll()) do
		if Exclude == nil || !table.HasValue(Exclude, ply) then
			SendSound(ply, SoundPath)
		end
	end
end
function BroadcastNotifyMessage(txt, time, color)
	for k, ply in pairs(player.GetAll()) do
		SendNotifyMessage(ply, txt, time, color)
	end
end
function SendMessage(ply, text)
	SendColorMessage(ply, text, Color(255, 255, 255))
end
function SendColorMessage(ply, text, cor)
	net.Start("SendMessage")
		net.WriteColor(cor)
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