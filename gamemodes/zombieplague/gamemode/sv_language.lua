Dictionary = Dictionary or {Languages = {}}

function Dictionary:SearchLanguages()
	local Files = file.Find("zombieplague/gamemode/languages/*.lua", "LUA")
	if Files then
		for k, File in pairs(Files) do
			include("zombieplague/gamemode/languages/" .. File)
		end
	end
end
function Dictionary:AddLanguage(LanguageID, Language)
	Dictionary.Languages[LanguageID] = Language
end
function Dictionary:GetPhrase(PhraseID, ply)
	return Dictionary:GetServerSideLanguageBook(ply:GetLanguage())[PhraseID] or "{UNKNOWN}"
end
function Dictionary:GetLanguageBook(LanguageID)
	for ID, Language in pairs(Dictionary.Languages) do
		if ID == LanguageID then
			return Language
		end
	end
	return Dictionary.Languages["en-us"]
end
function Dictionary:GetServerSideLanguageBook(LanguageID)
	return Dictionary:GetLanguageBook(LanguageID or "en-us")["Values"]["Server"]
end
function Dictionary:GetClientSideLanguageBook(LanguageID)
	local id = LanguageID or "en-us"
	return {
		ID = id,
		Value = Dictionary:GetLanguageBook(id)["Values"]["Client"]
	}
end
function Dictionary:RegisterPhrase(LanguageAlias, PhraseID, Phrase, Client)
	local Language
	for ID, Lang in pairs(self.Languages) do
		if ID == LanguageAlias then
			Language = Lang.Values
			break
		end
	end
	if Language then
		Language[(Client and "Client" or "Server")][PhraseID] = Phrase
	else
		print("Unknown language: '" .. LanguageAlias .. "'!")
	end
end
function Dictionary:GetLanguageIDs()
	local Languages = {}
	for ID, Language in pairs(Dictionary.Languages) do
		Languages[ID] = {
			Description = Language.PrettyName,
			Order = Language.Order or 100
		}
	end
	return Languages
end
function Dictionary:OpenLanguageMenu(ply)
	net.Start("OpenBackMenu")
		net.WriteString("SendLanguage")
		net.WriteTable(Dictionary:GetLanguageIDs())
		net.WriteBool(false)
	net.Send(ply)
end
function Dictionary:Init()
	local Language = {PrettyName = "US English",
		Values = 
		{
			Server = {
				ZombiesWin = "The zombies has taken the world!",
				HumansWin = "Humans defeated the plague!",
				RoundDraw = "No one has won!",
				RoundSimple = "The infection has spread!",
				RoundSimpleName = "Simple infection mode",
				RoundMultiInfectionName = "Multi infection mode",
				RoundNemesisName = "Nemesis mode",
				RoundSurvivorName = "Survivor mode",
				RoundSwarmName = "Swarm mode",
				RoundPlagueName = "Plague mode",
				NoticeFirstZombie = "%s is the first zombie!!",
				NoticeInfect = "%s's brains has been eaten by %s...",
				NoticeSelfInfect = "%s has used an T-Virus!",
				NoticeAntidote = "%s has used an antidote...",
				NoticeGetCured = "%s has been cured by %s...",
				NoticeNemesis = "%s is a Nemesis!!!",
				NoticeSurvivor = "%s is a Survivor!!!",
				NoticeSwarm = "Swarm Mode!!!",
				NoticePlague = "Plague Mode!",
				NoticeMultiInfection = "Multi Infection Mode!!!",
				NoticeVotemapEnded = "Votemap has ended! %s will be the next map!",
				NoticeVotemapProlong = "The current map will be prolonged for more %s round(s)!",
				NoticeNotAllowed = "You're not allowed to do this right now!",
				NoticeHasHability = "Your class has an ability! Type: zp_ability in console to use!",
				NoticeIsNotAlive = "You must be alive to use your ability!",
				NoticeNoAbility = "Your class doesn't have an ability!",
				NoticeSpecialClassNotAllowed = "You are using a special class, you can't use your ability!",
				NoticeNotEnoughAbilityPower = "You don't have enough power to use your ability!",
				NoticeForceRound = "%s has started %s",
				LastZombieLeft = "The last zombie has left, %s is the new zombie",
				LastHumanLeft = "The last human has left, %s is the new human.",
				ExtraItemCantBuy = "You can't buy this extra item right now!",
				ExtraItemEnought = "You don't have enought ammo packs to buy this!",
				ExtraItemChoose = "You need to choose a valid extra item!",
				ExtraItemCantOpen = "You can't open this menu right now",
				ExtraItemBought = "You bought: '%s'.",
				AmmoPackWithdraw = "You withdrew %d ammo packs, there's %d ammo packs left in your account.",
				AmmoPackDeposit = "You deposited %d ammo packs, now you have %d ammo packs in your account.",
				AmmoPackNotEnought = "Not enought cash stranger (Or ammo packs)!",
				AmmoPackGivePlyNotFound = "Player not found!",
				AmmoPackGiveInvalidAmount = "Invalid amount.",
				AmmoPackGiveName = "%s gave you %d ammo packs!",
				AmmoPackTakeName = "%s took %d of your ammo packs!",
				AmmoPackNoAmmoPacks = "Your account has no ammo packs!",
				AmmoPackBalance = "Your balance is %d ammo packs!",
				AmmoPackPlayerNotFound = "Player '%s' not found!",
				AmmoPackGiverMessage = "You gave %d to %s!",
				CommandInvalidArgument = "Invalid argument for this command!",
				CommandNotAccess = "You don't have access to this command!",
				ExtraItemAntidoteBulletsName = "Antidote Bullets",
				ExtraItemAntidoteBulletsLeft = "You have %d Antidote Bullets left.",
				ExtraItemAntidoteBulletsLost = "You have lost your Antidote Bullets",
				ExtraItemAntidoteName = "Antidote",
				ExtraItemArmorName = "Armor",
				ExtraItemInfectionBombName = "Infection Bomb",
				ExtraItemGrenadeName = "Grenade",
				ExtraItemSlamName = "S.L.A.M",
				ExtraItemTVirusName = "T-Virus",
				ExtraItemZombieMadnessName = "Zombie Madness",
				ExtraItemRPGName = "RPG",
				ExtraItemExtraAmmoName = "Extra Ammo",
				RoundsLeft = "%d round(s) left!",
				FinalRound = "Final round!",
				SaveSelection = "Save selection?"
			},
			Client = {
				ClassClass = "Class",
				ClassHealth = "Health",
				ClassArmor = "Armor",
				ClassGravity = "Gravity",
				ClassRunSpeed = "Run Speed",
				ClassSpeed = "Speed",
				ClassBattery = "Battery",
				ClassAbilityPower = "Ability Power",
				ClassOxygenLevel = "Oxygen Level",
				ScoreBoardTitleHumans = "Humans",
				ScoreBoardTitleZombies = "Zombies",
				ScoreBoardTitleSpectators = "Spectators",
				ScoreBoardHeaderName = "Name",
				ScoreBoardHeaderKills = "Kills",
				ScoreBoardHeaderDeaths = "Deaths",
				ScoreBoardHeaderStatus = "Status",
				ScoreBoardHeaderPing = "Ping",
				ScoreBoardStatusSpectating = "Spectating",
				ScoreBoardStatusAlive = "Alive",
				ScoreBoardStatusDead = "Dead",
				AP = "Ammo Packs",
				MenuZombieChoose = "Zombie Class Menu",
				MenuHumanChoose = "Human Class Menu",
				MenuWeaponChoose = "Weapon Choose Menu",
				MenuPrimaryWeaponChoose = "Primary Weapon Menu",
				MenuSecondaryWeaponChoose = "Secondary Weapon Menu",
				MenuMeleeWeaponChoose = "Melee Weapon Menu",
				MenuExtraItemChoose = "Extra Items",
				MenuLanguageChoose = "Language Choose Menu",
				MenuAdminRoundChoose = "Round Choose Menu",
				MenuSpectator = "Join Spectators",
				MenuNonSpectator = "Join Players",
				MenuAdmin = "Admin Menu",
				MenuAdminGiveAmmoPacks = "Give Ammo Packs",
				MenuNoOptionsAvailableNow = "No options available for this menu right now!",
				MenuBack = "Back",
				MenuNext = "Next",
				MenuClose = "Close",
				MenuCredit = "Credits",
				MenuOptions = "Options",
				Nemesis = "Nemesis",
				Survivor = "Survivor",
				NoticeVotemapProlong = "Prolong current map for more {RoundsToExtend} round(s)!",
				HumanDefaultClassName = "Human",
				HumanDefaultClassDescription = "A Human, nothing else.",
				HumanHeavyClassName = "Heavy Human",
				HumanHeavyClassDescription = "Stay safe from zombies with his armor.",
				HumanSpeedClassName = "Speed Human",
				HumanSpeedClassDescription = "Have more speed.",
				HumanCrouchClassName = "Crouch Human",
				HumanCrouchClassDescription = "Can walk faster when crouched.",
				HumanLightClassName = "Light Human",
				HumanLightClassDescription = "Low gravity and no fall damage.",
				HumanCamouflageClassName = "Camouflage Human",
				HumanCamouflageClassDescription = "Can desguise as a zombie.",
				HumanSuicidalClassName = "Suicidal Human",
				HumanSuicidalClassDescription = "A Human that can explode",
				ZombieDefaultClassName = "Zombie",
				ZombieDefaultClassDescription = "A Zombie, nothing else.",
				ZombieHeavyClassName = "Heavy Zombie",
				ZombieHeavyClassDescription = "A walking wall.",
				ZombieSpeedClassName = "Speed Zombie",
				ZombieSpeedClassDescription = "Run to seek humans.",
				ZombieCrouchClassName = "Crouch Zombie",
				ZombieCrouchClassDescription = "Can walk faster when crouched.",
				ZombieLightClassName = "Light Zombie",
				ZombieLightClassDescription = "Low gravity and no fall damage.",
				ZombieLeechClassName = "Leech Zombie",
				ZombieLeechClassDescription = "Earn 500 HP for every human infected.",
				ZombieBomberClassName = "Bomber Zombie",
				ZombieBomberClassDescription = "Spawn with an infection bomb.",
				ZombieCamouflageClassName = "Camouflage Zombie",
				ZombieCamouflageClassDescription = "Can desguise as a human.",
				ZombieFasterClassName = "Faster Zombie",
				ZombieFasterClassDescription = "Can be fast. Also Can be weak.",
				ZombieJumperClassName = "Jumper Zombie",
				ZombieJumperClassDescription = "His special ability allows him to jump very high.",
				ZombieTankClassName = "Tank Zombie",
				ZombieTankClassDescription = "Can enable god mode to protect himself.",
				HUDCustomizerComboMenu = "Menu",
				HUDCustomizerComboStatusBar = "Status Bar",
				HUDCustomizerComboRoundTimer = "Round Timer",
				HUDCustomizerTabTitleBody = "Body",
				HUDCustomizerTabTitleBorder = "Border",
				HUDCustomizerTabTitleText = "Text",
				HUDCustomizerApplyButton = "Apply",
				HUDCustomizerLabelX = "Horizontal position",
				HUDCustomizerLabelY = "Vertical position",
				HUDCustomizerLabelFont = "Font type",
				HUDCustomizerMenu = "Menu",
				HUDCustomizerStatus = "Status",
				HUDCustomizerTimer = "Timer",
				HUDCustomizerTabTitleOther = "Other options",
				HUDCustomizerLeft = "Left",
				HUDCustomizerCenter = "Center",
				HUDCustomizerRight = "Right",
				HUDCustomizerTop = "Top",
				HUDCustomizerBottom = "Bottom",
				KeyBindingApply = "Apply",
				KeyBindingCancel = "Cancel",
				KeyBindingDefault = "Reset keys",
				KeyBindingKeyAlreadyInUse = "This key is already in use",
				KeyBindingNightVisionToggle = "Toggle Nightvision",
				KeyBindingRequestAbility = "Use class ability",
				KeyBindingOpenZPMenu = "Open zombie plague menu",
				KeyBindingOpenHumanMenu = "Open human class menu",
				KeyBindingOpenZombieMenu = "Open zombie class menu",
				KeyBindingOpenWeaponsMenu = "Open weapons menu",
				KeyBindingOpenExtreItemsMenu = "Open extra items menu",
				KeyBindingPopupTitle = "Warning!",
				KeyBindingPopupReset = "This will reset the keys to the default values, do you wish to continue?",
				ZPHUDCustomizer = "HUD customizer menu",
				ZPKeyBinding = "Key binding menu",
				ZombiePlagueActions = "Zombie plague actions",
				ZombiePlagueMenu = "Zombie plague menus",
				ZombiePlagueOptions = "Options menu",
				PopupYes = "Yes",
				PopupNo = "No"
			}
		},
		Order = 0
	}
	Dictionary:AddLanguage("en-us", Language)

	Dictionary:SearchLanguages()
end
Commands:AddCommand("languages", "Open language menu.", function(ply, args)
	Dictionary:OpenLanguageMenu(ply)
end)
net.Receive("RequestLanguageMenu", function(len, ply)
	Dictionary:OpenLanguageMenu(ply)
end)
net.Receive("SendLanguage", function(len, ply)
	ply:SetLanguage(net.ReadString(), true)
end)
util.AddNetworkString("RequestLanguageMenu")
util.AddNetworkString("SendLanguage")