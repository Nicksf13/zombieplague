local Language = {PrettyName = "Español Argentino",
	Values = 
	{
		Server = {
			ZombiesWin = "Los zombies han ganado!",
			HumansWin = "Los humanos han derrotado a la plaga!",
			RoundDraw = "Empate",
			RoundSimple = "La infeccion a comenzado!",
			RoundSimpleName = "Modo de infeccion unica",
			RoundMultiInfectionName = "Modo de infeccion multiple",
			RoundNemesisName = "Modo Nemesis",
			RoundSurvivorName = "Modo Superviviente",
			RoundSwarmName = "Modo Swarm",
			RoundPlagueName = "Modo Plague",
			NoticeFirstZombie = "%s Es el primer zombie!",
			NoticeInfect = "%s Ha sido infectado por %s...",
			NoticeSelfInfect = "%s Ha usado un T-VIRUS!!",
			NoticeAntidote = "%s Ha usado antidoto",
			NoticeGetCured = "%s Fue curado por %s...",
			NoticeNemesis = "%s Es un nemesis",
			NoticeSurvivor = "%s Es un Superviviente",
			NoticeSwarm = "Modo Swarm!!!",
			NoticePlague = "Modo Plague!",
			NoticeMultiInfection = "Modo de infeccion múltiple!!!",
			NoticeVotemapEnded = "El tiempo de votacion termino! %s Sera el proximo mapa!!",
			NoticeVotemapProlong = "O mapa se extendera por otra %s ronda(s)!",
			NoticeNotAllowed = "No tienes permiso para eso!",
			NoticeHasHability = "Tu clase tiene una habilidad escriba! Digite: zp_ability en la consola para usarlo!",
			NoticeIsNotAlive = "¡Debes estar vivo para usar tu habilidad!",
			NoticeNoAbility = "¡Tu clase no tiene una habilidad!",
			NoticeSpecialClassNotAllowed = "Estás usando una clase especial, ¡no puedes usar tu habilidad!",
			NoticeNotEnoughAbilityPower = "¡No tienes suficiente poder para usar tu habilidad!",
			NoticeForceRound = "%s comenzo %s",
			LastZombieLeft = "O El ultimo se fue, %s ahora es el nuevo zombi",
			LastHumanLeft = "O ultimo humano se fue, %s ahora es el nuevo humano.",
			ExtraItemCantBuy = "No podes comprar el item extra ahora!",
			ExtraItemEnought = "No tenes los ammo packs suficientes!",
			ExtraItemChoose = "Debes elegir un artículo adicional válido!",
			ExtraItemCantOpen = "No puedes abrir el menu ahora",
			ExtraItemBought = "Compraste: '%s'.",
			AmmoPackWithdraw = "Sacaste la cantidad de  %d ammo packs, ahora hay %d ammo packs en su cuenta.",
			AmmoPackDeposit = "Depositaste la cantidad de  %d ammo packs, ahora tienes %d ammo packs en tu cuenta .",
			AmmoPackNotEnought = "No tienes dinero (O ammo packs)!",
			AmmoPackGivePlyNotFound = "Jugador no encontrado!",
			AmmoPackGiveInvalidAmount = "Cuenta invalida.",
			AmmoPackGiveName = "%s Le diste  %d ammo packs!",
			AmmoPackTakeName = "%s Saco %d de tus ammo packs!",
			AmmoPackNoAmmoPacks = "Tu cuenta no tiene ammo packs!",
			AmmoPackBalance = "Su saldo de  %d ammo packs!",
			AmmoPackPlayerNotFound = "Jugador '%s' no encontrado!",
			AmmoPackGiverMessage = "Le diste %d para %s!",
			CommandInvalidArgument = "Argumento inválido para ese commando!",
			CommandNotAccess = "No tienes acceso a este commando!",
			ExtraItemAntidoteBulletsName = "Balas de antídoto",
			ExtraItemAntidoteBulletsLeft = "Te quedan %d balas de antídoto sobrando.",
			ExtraItemAntidoteBulletsLost = "Perdiste balas de antidoto",
			ExtraItemAntidoteName = "Antídoto",
			ExtraItemArmorName = "Chaleco",
			ExtraItemInfectionBombName = "Bomba de infeccion",
			ExtraItemGrenadeName = "Granada",
			ExtraItemSlamName = "S.L.A.M",
			ExtraItemTVirusName = "T-Virus",
			ExtraItemZombieMadnessName = "Furia zombie",
			ExtraItemRPGName = "RPG",
			RoundsLeft = "%d ronda(s) restante(s)!",
			FinalRound = "Ronda final!"
		},
		Client = {
			ClassClass = "Clase",
			ClassHealth = "Vida",
			ClassArmor = "Chaleco",
			ClassGravity = "Gravedad",
			ClassRunSpeed = "Velocidad de carrera",
			ClassSpeed = "Velocidad",
			ClassBattery = "Bateria",
			ClassAbilityPower = "Poder de habilidad",
			ClassOxygenLevel = "Nivel de oxigeno",
			AP = "Ammo Packs",
			MenuZombieChoose = "Menu De Clase - Zombie",
			MenuHumanChoose = "Menu De Classe - Humano",
			MenuWeaponChoose = "Menu de seleccion de armas",
			MenuExtraItemChoose = "Items Extras",
			MenuLanguageChoose = "Menu de idiomas",
			MenuAdminRoundChoose = "Menu de rondas",
			MenuSpectator = "Entra en espectadores",
			MenuNonSpectator = "Salir de espectadores",
			MenuAdmin = "Menu de administrador",
			MenuAdminGiveAmmoPacks = "Dar Ammo Packs",
			MenuNoOptionsAvailableNow = "No hay opción disponible para ese menú!",
			MenuBack = "Atras",
			MenuNext = "Siguiente",
			MenuClose = "Cerrar",
			MenuCredit = "Créditos",
			MenuOptions = "Opciones",
			Nemesis = "Nemesis",
			Survivor = "Sobrevivente",
			NoticeVotemapProlong = "Ampliar mapa para más {RoundsToExtend} rounda(s)!",
			HumanDefaultClassName = "Humano",
			HumanDefaultClassDescription = "Un terricola, nada mas.",
			HumanHeavyClassName = "Humano pesado",
			HumanHeavyClassDescription = "Invencible tiene buena resistencia pero es un poco lento.",
			HumanSpeedClassName = "Humano rápido",
			HumanSpeedClassDescription = "Es el mas veloz fiumm.",
			HumanCrouchClassName = "Humano Agachador",
			HumanCrouchClassDescription = "Eres muy veloz agachado.",
			HumanLightClassName = "Humano liviano",
			HumanLightClassDescription = "Salta muy alto BASTANTE.",
			HumanCamouflageClassName = "Humano Camuflado",
			HumanCamouflageClassDescription = "Puede disfrazarse de un zombie.",
			HumanSuicidalClassName = "Humano Suícida",
			HumanSuicidalClassDescription = "Puede hacer explotar BOOM.",
			ZombieDefaultClassName = "Zombie",
			ZombieDefaultClassDescription = "Un zombie, nada mas.",
			ZombieHeavyClassName = "Zombie Pesado",
			ZombieHeavyClassDescription = "Muy dificil de vencer.",
			ZombieSpeedClassName = "Zombie Rápido",
			ZombieSpeedClassDescription = "Corre para infectar humanos.",
			ZombieCrouchClassName = "Zombie Agachador",
			ZombieCrouchClassDescription = "Podes andar mas rápido agachado.",
			ZombieLightClassName = "Zombie Liviano",
			ZombieLightClassDescription = "Salta bastante alto, desafia las leyes de la gravedad.",
			ZombieLeechClassName = "Zombie Parasito",
			ZombieLeechClassDescription = "Gana 500 HP por cada humano infectado.",
			ZombieBomberClassName = "Zombie Granadero",
			ZombieBomberClassDescription = "Tira bombas infectadas.",
			ZombieCamouflageClassName = "Zombie Camuflado",
			ZombieCamouflageClassDescription = "Se disfraza de humano.",
			ZombieFasterClassName = "Zombie mas rápido",
			ZombieFasterClassDescription = "Podes ser rápido,podes ser sincero.",
			ZombieJumperClassName = "Zombie Saltante",
			ZombieJumperClassDescription = "Usa su habilidad para saltar bien alto.",
			ZombieTankClassName = "Zombie Tanque ",
			ZombieTankClassDescription = "Podes usar DIOS Y MATARLOS A TODOS.",
			HUDCustomizerComboMenu = "Menu",
			HUDCustomizerComboStatusBar = "Barra de estado",
			HUDCustomizerComboRoundTimer = "Temporizador de ronda",
			HUDCustomizerTabTitleBody = "Cuerpo",
			HUDCustomizerTabTitleBorder = "Borde",
			HUDCustomizerTabTitleText = "Texto",
			HUDCustomizerApplyButton = "Aplicar",
			HUDCustomizerLabelX = "Posicion horizontal",
			HUDCustomizerLabelY = "Posición vertical",
			HUDCustomizerLabelFont = "Tipo de fuente",
			HUDCustomizerMenu = "Menu",
			HUDCustomizerStatus = "Estado",
			HUDCustomizerTimer = "Temporizador",
			HUDCustomizerTabTitleOther = "Otras opciones",
			HUDCustomizerLeft = "Izquierda",
			HUDCustomizerCenter = "Centro",
			HUDCustomizerRight = "Derecha",
			HUDCustomizerTop = "Parte superior",
			HUDCustomizerBottom = "Parte inferior",
			KeyBindingApply = "Aplicar",
			KeyBindingCancel = "Cancelar",
			KeyBindingDefault = "Restablecer teclas",
			KeyBindingKeyAlreadyInUse = "Esta tecla ya está en uso",
			KeyBindingNightVisionToggle = "Alternar visión nocturna",
			KeyBindingRequestAbility = "Usar habilidad de clase",
			KeyBindingOpenZPMenu = "Abrir menú de Zombie Plague",
			KeyBindingOpenHumanMenu = "Abrir menú de clase de humano",
			KeyBindingOpenZombieMenu = "Abrir menú de clase de zombie",
			KeyBindingOpenWeaponsMenu = "Abrir menú de armas",
			KeyBindingOpenExtreItemsMenu = "Abrir menú de itens extra",
			KeyBindingPopupTitle = "¡Aviso!",
			KeyBindingPopupReset = "Esto restablecerá las teclas a los valores predeterminados. ¿Desea continuar?",
			ZPHUDCustomizer = "Menú de personalización de HUD",
			ZPKeyBinding = "Menú de encuadernación de teclas",
			ZombiePlagueActions = "Acciones de Zombie Plague",
			ZombiePlagueMenu = "Menus de Zombie Plague",
			ZombiePlagueOptions = "Menú de opciones",
			PopupYes = "Si",
			PopupNo = "No"
		}
	}
}
Dictionary:AddLanguage("es-ar", Language)