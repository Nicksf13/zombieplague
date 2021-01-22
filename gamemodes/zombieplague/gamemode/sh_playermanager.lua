PlayerManager = {}

function PlayerManager:GetPlayerID(ply)
	return ply:IsBot() and ply:GetName() or ply:SteamID()
end
function PlayerManager:DiscoverPlayerByTextID(TextID)
	for k, ply in pairs(player.GetAll()) do
		if (self:GetPlayerID(ply)) == TextID then
			return ply
		end
	end

	return nil
end