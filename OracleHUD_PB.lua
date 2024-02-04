-- /run print((select(4, GetBuildInfo())))
-- Community API: https://develop.battle.net/documentation/world-of-warcraft/game-data-apis
-- API Index: https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
	-- Pet Journal: https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Pet_Journal
	-- Pet Battles: https://warcraft.wiki.gg/wiki/World_of_Warcraft_API#Pet_Battles
-- Character Model Base: https://warcraft.wiki.gg/wiki/UIOBJECT_CharacterModelBase
-- Sounds: https://www.wowhead.com/sounds/name:chicken (PlaySound)
-- Layer: https://wowpedia.fandom.com/wiki/Layer
-- Frame Strata: https://wowpedia.fandom.com/wiki/Frame_Strata
-- Frame: https://warcraft.wiki.gg/wiki/XML/Frame
-- DATABASE: https://wago.tools/db2

-- Content will dynamically attach themselves to this object for loading.
--ORACLEHUD_PB_DB_UPDATE = {}


OracleHUD_PB = CreateFrame("Frame")
function OracleHUD_PB_Setup(self)
	-- This is our main "dependency injection":
	self.db = nil
	self.variables_loaded = false
	self.player_entering_world = false
	--- @type OracleHUD_PB_PetInfoService
	self.petInfoSvc = OracleHUD_PB_PetInfoService
	self.networkSvc = OracleHUD_PB_NetworkService
	--- @type OracleHUD_PB_CombatLogService
	self.combatLogSvc = OracleHUD_PB_CombatLogService
	self.achievementSvc = OracleHUD_PB_AchievementService
	self.eventManager = OracleHUD_PB_EventManager
	self.spellSvc = OracleHUD_PB_SpellService
	self.options = OracleHUD_PB_InterfaceOptions
	self.community = OracleHUD_PB_PanelCommunity
	self.uncollected = OracleHUD_PB_PanelUncollected
	self.zoo = OracleHUD_PB_PanelZoo
	self.support = OracleHUD_PB_PanelPetBattleBar
	self.loadoutAlly = OracleHUD_PB_PanelLoadoutAlly
	self.loadoutEnemy = OracleHUD_PB_PanelLoadoutEnemy
	---@type OracleHUD_PB_DisplayConsole
	self.displayConsole = OracleHUD_PB_DisplayConsole
	---@type OracleHUD_PB_DisplayChat
	self.displayChat = OracleHUD_PB_DisplayChat
--	---@type OracleHUD_PB_DisplayFader
	self.displayCommunity = OracleHUD_PB_DisplayCommunity
	---@type OracleHUD_PB_TooltipPetInfoSpecies
	self.tooltipPetInfoSpecies = OracleHUD_PB_TooltipPetInfoSpecies
	---@type OracleHUD_PB_TooltipPetInfoId
	self.tooltipPetInfoId = OracleHUD_PB_TooltipPetInfoId
	self.tooltipPetInfoContent = OracleHUD_PB_TooltipPetInfoContent
	self.editBox = OracleHUD_PB_EditBox
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db		    Oracle HUD Pet Battle database.
	function self:Configure(db)
        if (db == nil) then
            error("OracleHUD_PB:Configure(): Invalid arguments.")
		end
		db.battleOrder = nil
		self.displayChat:Configure(db, "EMOTE")
		self.displayConsole:Configure(db)
		self.displayCommunity:Configure(db, 300, 30, 12, 6)
		self.displayCommunity:SetAlpha(0.8)
		self.petInfoSvc:Configure(db, self.combatLogSvc)
		self.networkSvc:Configure(db, self.petInfoSvc, self.displayCommunity)
		self.combatLogSvc:Configure(db, self.petInfoSvc, self.displayCommunity)
		self.options:Configure(
			db,
			self.networkSvc,
			self.combatLogSvc,
			self.uncollected,
			self.zoo)
		self.community:Configure(db, self.displayCommunity, self.petInfoSvc, self.networkSvc)
		self.achievementSvc:Configure(db)
		self.spellSvc:Configure(db)
		self.support:Configure(db, self.petInfoSvc, self.combatLogSvc)
		self.zoo:Configure(db, self.networkSvc, self.petInfoSvc, self.options)
		self.uncollected:Configure(db, self.petInfoSvc, self.combatLogSvc, self.tooltipPetInfoSpecies)
		self.loadoutAlly:Configure(db, self.displayChat, Enum.BattlePetOwner.Ally, self.networkSvc,	self.combatLogSvc, 
								   C_PetJournal, C_PetBattles, ORACLEHUD_PB_DB_PET_ANIMATION_ENUM, self.petInfoSvc, 
								   self.options, self.zoo, self.tooltipPetInfoContent)
		self.loadoutEnemy:Configure(db, self.displayChat, Enum.BattlePetOwner.Enemy, self.networkSvc, self.combatLogSvc, 
									C_PetJournal, C_PetBattles, ORACLEHUD_PB_DB_PET_ANIMATION_ENUM, self.petInfoSvc, 
									self.options, self.zoo, self.tooltipPetInfoSpecies)
		self.eventManager:Configure(db, self.combatLogSvc, self.networkSvc, self.petInfoSvc, self.displayConsole)
		self.tooltipPetInfoSpecies:Configure(db)
		self.tooltipPetInfoId:Configure(db)
		self.tooltipPetInfoContent:Configure(db)
		self.editBox:Configure(db)
	end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    -- @param callback      (Optional) Execute callback when initialize has finished.
    function self:Initialize(callback)
		if (self.db.debug) then print("Initialize:") end
		function InitPetInfoSvc()				self.petInfoSvc:Initialize(InitNetworkSvc) end
		function InitNetworkSvc()				self.networkSvc:Initialize(InitCombatLogSvc) end
		function InitCombatLogSvc()				self.combatLogSvc:Initialize(InitAchievementSvc) end
		function InitAchievementSvc() 			self.achievementSvc:Initialize(InitSpellSvc) end
		function InitSpellSvc()					self.spellSvc:Initialize(InitEventManager) end
		function InitEventManager() 			self.eventManager:Initialize(InitPanelZoo) end
		function InitPanelZoo()					self.zoo:Initialize(InitPanelCommunity) end
		function InitPanelCommunity() 			self.community:Initialize(InitPanelLoadout) end
		function InitPanelLoadout() 			self.loadoutAlly:Initialize(InitPanelLoadoutEnemy) end
		function InitPanelLoadoutEnemy()		self.loadoutEnemy:Initialize(InitPanelSupport) end
		function InitPanelSupport() 			self.support:Initialize(InitPanelUncollected) end
		function InitPanelUncollected() 		self.uncollected:Initialize(InitDisplayChat) end
		function InitDisplayChat()				self.displayChat:Initialize(InitDisplayConsole) end
		function InitDisplayConsole()			self.displayConsole:Initialize(InitDisplayCommunity) end
		function InitDisplayCommunity()			self.displayCommunity:Initialize(InitTooltipPetInfoSpecies) end
		function InitTooltipPetInfoSpecies()	self.tooltipPetInfoSpecies:Initialize(InitTooltipPetInfoId) end
		function InitTooltipPetInfoId()			self.tooltipPetInfoId:Initialize(InitTooltipPetInfoContent) end
		function InitTooltipPetInfoContent()	self.tooltipPetInfoContent:Initialize(InitEditBox) end
		function InitEditBox()					self.editBox:Initialize(InitFinished) end
		function InitFinished()
			self:RegisterEvent("PLAYER_LEAVING_WORLD")
			if (callback ~= nil) then
				if (self.db.debug) then print("Initialize Finished.") end
				callback()
			end
		end
		-- First call here.
		self.options:Initialize(InitPetInfoSvc)
	end
    ---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
		if (eventName == "VARIABLES_LOADED") then
			if (OracleHUD_PB_DB == nil) then OracleHUD_PB_DB = {} end
			self.db = OracleHUD_PB_DB
			C_Timer.After(1, function()
				OracleHUD_PB_DatabaseInitialize(self.db, false)
				self.db.meta.loginCount = self.db.meta.loginCount + 1
				print("Login count: " .. self.db.meta.loginCount)
				-- Load in content files.
				for key, value in pairs(ORACLEHUD_PB_DB_UPDATE) do
					value(self.db)
				end
				self:Configure(self.db)
				self.variables_loaded = true
				self:Initialize(function()
					self.networkSvc:SendHello(false)
				end)
			end)
		end
		if (eventName == "PLAYER_LEAVING_WORLD") then
			if (self.networkSvc ~= nil) then
				self.networkSvc:SendGoodbye()
			end
		end
	end
	---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
    function self:OnSizeChanged_PB()
    end
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_PB()
    end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
	C_ChatInfo.RegisterAddonMessagePrefix("ORACLEHUD")
	OracleHUD_PB:RegisterEvent("VARIABLES_LOADED")
end
OracleHUD_PB_Setup(OracleHUD_PB)


function OracleHUD_PB_GetPetTypeName(index)
	return _G["BATTLE_PET_NAME_"..index]
end
---
SLASH_TEST1 = "/testhello"
SlashCmdList["TEST"] = function(msg, editBox)
	local _, _, arg, _ = string.find(msg, "%s?(%w+)%s?(.*)")
	--
	--	local pUID = UnitGUID("target")
	local pUID = "Player-54-0D901B07" -- Lador
	local message = "PB:"..pUID..":".."hello"
    C_ChatInfo.SendAddonMessage("ORACLEHUD", message, "CHANNEL", "5")
	--
--	OracleHUD_PB_TooltipPetInfoZooAnimationBox:SetAnimation(arg)
end 
---
SLASH_TESTGOODBYE1 = "/testgoodbye"
SlashCmdList["TESTGOODBYE"] = function(msg, editBox)
	local _, _, arg, _ = string.find(msg, "%s?(%w+)%s?(.*)")
	--
	--	local pUID = UnitGUID("target")
	local pUID = "Player-54-0D901B07" -- Lador
	local message = "PB:"..pUID..":".."goodbye"
    C_ChatInfo.SendAddonMessage("ORACLEHUD", message, "CHANNEL", "5")
end
---
SLASH_DEBUG1 = "/debug"
SlashCmdList["DEBUG"] = function(msg, editBox)
	local _, _, arg, _ = string.find(msg, "%s?(%w+)%s?(.*)")
	if (OracleHUD_PB_DB.debug == true) then
		OracleHUD_PB_DB.debug = false
	else
		OracleHUD_PB_DB.debug = true
	end
	print("Debug", OracleHUD_PB_DB.debug)
end 

