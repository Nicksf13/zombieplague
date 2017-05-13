local Language = {ID = "English",
	Values = 
	{
		Server = {
			ZombiesWin = "The zombies has taken the world!",
			HumansWin = "Humans defeated the plague!",
			RoundDraw = "No one has won!",
			RoundSimple = "The infection has spread!",
			RoundSwarm = "Swarm mode!",
			RoundPlague = "Plague mode!",
			NoticeFirstZombie = "%s is the first zombie !!",
			NoticeInfect = "%s's brains has been eaten by %s...",
			NoticeAntidote = "%s has used an antidote...",
			NoticeGetCured = "%s has been cured by %s...",
			NoticeNemesis = "%s is a Nemesis !!!",
			NoticeSurvivor = "%s is a Survivor !!!",
			NoticeSwarm = "Swarm Mode !!!",
			NoticeMulti = "MultiInfectionMode !!!",
			NoticePlague = "Plague Mode!",
			NoticeVotemapEnded = "Votemap has ended! %s will be the next map!",
			NoticeNotAllowed = "You're not allowed to do this right now!",
			NoticeForceRound = "%s force to start %s!!!",
			LastZombieLeft = "The last zombie has left, %s is the new zombie",
			LastHumanLeft = "The last human has left, %s is the new human.",
			ExtraItemCantBuy = "You can't buy this extra item right now!",
			ExtraItemEnought = "You don't have enought ammo packs to buy this!",
			ExtraItemChoose = "You need to choose a valid extra item!", -- Maybe this will never be called
		},
		Client = {
			ClassClass = "Class",
			ClassHealth = "Health",
			ClassArmor = "Armor",
			ClassGravity = "Gravity",
			ClassRunSpeed = "Run Speed",
			ClassSpeed = "Speed",
			ClassBattery = "Battery",
			AP = "Ammo Packs",
			APNotEnought = "You dont have enough ammo packs",
			MenuZombieChoose = "Zombie Class Menu",
			MenuHumanChoose = "Human Class Menu",
			MenuWeaponChoose = "Weapon Choose Menu",
			MenuExtraItemChoose = "Extra Items",
			MenuLanguageChoose = "Language Choose Menu",
			MenuRoundChoose = "Round Choose Menu",
			MenuSpectator = "Join Spectators",
			MenuNonSpectator = "Join Players",
			MenuBack = "Back",
			MenuNext = "Next",
			MenuClose = "Close"
		}
	}
}
Dictionary:AddLanguage(Language)