ExtraItem.Name = "M134"
ExtraItem.Price = 50
function ExtraItem:OnBuy(ply)
	local Weap = ply:Give("m9k_minigun")
	ply:GiveAmmo(300, Weap:GetPrimaryAmmoType(), true) 
end