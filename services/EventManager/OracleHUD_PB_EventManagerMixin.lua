---
--- Move events between services. Example: Capture combat log service event
--- for a lost pet battle and broadcast it via the network service.
---
--- @class OracleHUD_PB_EventManager : OracleHUD_PB_Service
--- @field RegisterEvent    any Inherited from mixin XML frame.
OracleHUD_PB_EventManagerMixin = CreateFromMixins(OracleHUD_PB_ServiceMixin)
OracleHUD_PB_EventManagerMixin._class = "OracleHUD_PB_EventManagerMixin"
OracleHUD_PB_EventManagerMixin.listenNetwork = false
---------------------------------------------------------------------------
--- Configure frame with required data.
--- @param db 		    OracleHUD_PB_DB	                OracleHUD Pet Battles Database.
--- @param combatLogSvc OracleHUD_PB_CombatLogService	OracleHUD Combat Log Service.
--- @param networkSvc   OracleHUD_PB_NetworkService		OracleHUD Network Service.
--- @param petInfoSvc	OracleHUD_PB_PetInfoService		OracleHUD Pet Information Service.
--- @param display		OracleHUD_PB_Display			OracleHUD Display Interface.
function OracleHUD_PB_EventManagerMixin:Configure(db, combatLogSvc, networkSvc, petInfoSvc, display)
	if (db == nil or combatLogSvc == nil or networkSvc == nil or petInfoSvc == nil) then
		error(self._class..":Configure(): Invalid arguments.")
	end
	self.db = db
	self.combatLogSvc = combatLogSvc
	self.networkSvc = networkSvc
	self.petInfoSvc = petInfoSvc
	self.display = display
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback	function?      Execute callback when initialize has finished.
function OracleHUD_PB_EventManagerMixin:Initialize(callback)
	if (self.db.debug) then self.display:Print("..Initialize Event Manager") end
	self:ListenCombatLogSvc()
	self:ListenNetworkSvc()
	self:RegisterEvent("PET_BATTLE_CAPTURED")
	self:RegisterEvent("NEW_PET_ADDED")
	self:RegisterEvent("GROUP_JOINED")
	if (callback ~= nil) then
		callback()
	end
end
---------------------------------------------------------------------------
--- Listen to the network service events.
function OracleHUD_PB_EventManagerMixin:ListenNetworkSvc()
	if (self.listenNetwork == false) then
		self.networkSvc:SetCallback(function(message)
			local elements = OracleHUD_StringSplit(message, ":")
			local playerId = elements[2]
			local locClass, engClass, locRace, engRace, gender, name, server = GetPlayerInfoByGUID(playerId)
			local playerName = name
			if (server ~= nil and server ~= "") then 
				playerName = name.."-"..server 
			end
			-- Respond to hello requests.
			if (elements[3] == "hello") then
				self.networkSvc:SendWhisper("helloWhisper", playerName, false)
			end
		end)
		self.listenNetwork = true
	end
end
---------------------------------------------------------------------------
--- Listen to the combat log service events
function OracleHUD_PB_EventManagerMixin:ListenCombatLogSvc()
	self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.WON, function()
		self:SendPetBattleWon()
	end)
	self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.LOST, function()
		self:SendPetBattleLost()
	end)
	self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.LEVEL, function(petInfo, newLevel)
		if (newLevel == 25) then
			self:SendPetLevelMaxed(petInfo.name)
		else
			self:SendPetLevel(petInfo.name, newLevel)
		end
	end)
end
---------------------------------------------------------------------------
--- Raised battle pet to maximum level.
--- @param petName	string	Name of pet.
function OracleHUD_PB_EventManagerMixin:SendPetLevelMaxed(petName)
	local message = "petLevelMax:" .. petName
	self.networkSvc:Send(message, false)
end
---------------------------------------------------------------------------
--- Raised battle pet a level.
--- @param petName	number	Name of pet.
--- @param level	number	New level of pet.
function OracleHUD_PB_EventManagerMixin:SendPetLevel(petName, level)
	local message = "petLevel:" .. petName .. ":" .. level
	self.networkSvc:Send(message, false)
end
---------------------------------------------------------------------------
--- Pet battle won.
function OracleHUD_PB_EventManagerMixin:SendPetBattleWon()
	local message = "petBattleWon"
	self.networkSvc:Send(message, false)
end
---------------------------------------------------------------------------
--- Pet battle lost.
function OracleHUD_PB_EventManagerMixin:SendPetBattleLost()
	local message = "petBattleLost"
	self.networkSvc:Send(message, false)
end
---------------------------------------------------------------------------
--- Pet captured.
--- @param petInfo	OracleHUD_PB_PetInfo		OracleHUD_PB Uniform pet table.
function OracleHUD_PB_EventManagerMixin:SendPetCaptured(petInfo)
	local message = "petCaptured" .. ":" .. petInfo.speciesId .. ":" .. petInfo.name
	self.networkSvc:Send(message, false)
end
---------------------------------------------------------------------------
--- Pet added, via inventory etc.
--- @param petInfo	OracleHUD_PB_PetInfo		OracleHUD_PB Uniform pet table.
function OracleHUD_PB_EventManagerMixin:SendPetAdded(petInfo)
	local message = "petAdded" .. ":" .. petInfo.speciesId .. ":" .. petInfo.name
	self.networkSvc:Send(message, false)
end
---------------------------------------------------------------------------
--- Announce ourselves to the party.
function OracleHUD_PB_EventManagerMixin:SendPartyHello(num, partyId)
	self.networkSvc:SendParty("hello", false)
end
---------------------------------------------------------------------------
--- Process incoming events.
--- @param event		any		Unique event identification
--- @param eventName	string	Human friendly name of event
function OracleHUD_PB_EventManagerMixin:OnEvent(event, eventName, ...)
	if (eventName == "PET_BATTLE_CAPTURED") then
		local owner, petIndex = ...
		local petInfo = self.petInfoSvc:GetPetInfoBySlot(petIndex, self.db, owner)
		if (petInfo == nil) then error(self._class..":OnEvent(): petInfo is nil.") end
		self:SendPetCaptured(petInfo)
	end
	if (eventName == "GROUP_JOINED") then
		local num, partyId = ...
		self:SendPartyHello(num, partyId)
	end
	if (eventName == "NEW_PET_ADDED") then
		local petId = ...
		local petInfo = self.petInfoSvc:GetPetInfoByPetId(petId)
		self:SendPetAdded(petInfo)
	end
end
---------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
function OracleHUD_PB_EventManagerMixin:OnSizeChanged_EventManager()
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param self any	Main XML frame.
function OracleHUD_PB_EventManagerMixin:OnLoad()
	---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_EventManager()
    end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
