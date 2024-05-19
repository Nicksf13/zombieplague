PlayerManager = {}

function PlayerManager:GetPlayerID(ply)
	return ply:SteamID64()
end
function PlayerManager:DiscoverPlayerByTextID(TextID)
	for i, ply in ipairs(player.GetAll()) do
		if (self:GetPlayerID(ply)) == TextID then
			return ply
		end
	end

	return nil
end