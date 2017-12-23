local PLAYER = FindMetaTable("Player")
function PLAYER:IsHuman()
	return self:Team() == TEAM_HUMANS
end
function PLAYER:IsZombie()
	return self:Team() == TEAM_ZOMBIES
end