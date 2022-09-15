ExtraItem.ID = "ZPZombieNemesis"
ExtraItem.Name = "ExtraItemNemesisName"
ExtraItem.Price = 40
ExtraItem.Type = ITEM_ZOMBIE
ExtraItem.BuySounds = { 'npc/fast_zombie/fz_scream1.wav' }
function ExtraItem:OnBuy(ply)
	ply:MakeNemesis()
end
function ExtraItem:CanBuy(ply)
	return ply:Alive()
end

Dictionary:RegisterPhrase("en-us", "ExtraItemNemesisName", "Nemesis", false)
Dictionary:RegisterPhrase("pt-br", "ExtraItemNemesisName", "Nemesis", false)
Dictionary:RegisterPhrase("es-ar", "ExtraItemNemesisName", "Nemesis", false)
Dictionary:RegisterPhrase("ru", "ExtraItemNemesisName", "Немезис", false)
Dictionary:RegisterPhrase("uk", "ExtraItemNemesisName", "Немезид", false)
Dictionary:RegisterPhrase("tchinese", "ExtraItemNemesisName", "復仇者", false)
Dictionary:RegisterPhrase("ja", "ExtraItemNemesisName", "ネメシス", false)
Dictionary:RegisterPhrase("ko", "ExtraItemNemesisName", "네메시스", false)