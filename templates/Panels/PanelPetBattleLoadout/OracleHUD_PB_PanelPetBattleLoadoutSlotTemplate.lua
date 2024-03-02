--- Called by XML onload.
-- @param self      Our main XML frame.
-- @param db		Oracle HUD Pet Battle database.
function OracleHUD_PB_PanelPetBattleLoadoutSlotTemplate_OnLoad(self, db)
	local frame = self
	self.HideFull = OracleHUD_FrameHideFull
	self.ShowFull = OracleHUD_FrameShowFull
	self.active = false
	self.horizontal = false
	self.auras = {}
    -- Emulate inheritence even though we are composition.
	function self:CanSpeak(...) return self.Left:CanSpeak(...) end
	function self:Speak(...) return self.Left:Speak(...) end
    ---------------------------------------------------------------------------
	--- Configure frame with required data.
    -- @param db			Oracle HUD Pet Battle database.
	--- @param  display     OracleHUD_PB_Display
	-- @param slot			Loadout slot of this frame.
	-- @param network		Oracle HUD Addon network communications.
	-- @param combatLogSvc	Oracle HUD Combat Log Service.
	-- @param c_petjournal	Wow's C_PetJournal or a mocked version.
	-- @param c_petbattles  Wow's C_PetBattles or a mocked version.
    -- @param petAnimEnum	ORACLEHUD_PB_DB_PET_ANIMATION_ENUM
    -- @param petInfoSvc    OracleHUD PetInfo Service.
	-- @param options		OracleHUD Interface Options.
	-- @param zoo			(Optional) Frame of the zoo.
	--- @param tooltipPetInfo	OracleHUD_PB_TooltipPetInfo
	function self:Configure(db, display, slot, owner, network, combatLogSvc, c_petjournal, c_petbattles, petAnimEnum,
							petInfoSvc,	options, zoo, tooltipPetInfo)
		if (db == nil or display == nil or slot == nil or owner == nil or network == nil or combatLogSvc == nil or
			c_petjournal == nil or c_petbattles == nil or petAnimEnum == nil or petInfoSvc == nil or options == nil)
		then
            error("OracleHUD_PB_PanelLoadoutBattleSlotTemplate:Configure(): Invalid arguments.")
		end
		self.db = db
		self.display = display
		self.slot = slot
		self.owner = owner
		self.network = network
		self.combatLogSvc = combatLogSvc
		self.c_petjournal = c_petjournal
		self.c_petbattles = c_petbattles
		self.petAnimEnum = petAnimEnum
		self.petInfoSvc = petInfoSvc
		self.options = options
		self.zoo = zoo
		self.tooltipPetInfo = tooltipPetInfo
		-- Configure children.
		self.Left:Configure(db, display, petInfoSvc, tooltipPetInfo)
		self.Auras:Configure(slot, owner, db, petInfoSvc, combatLogSvc)
		self.Right.ButtonsBorder.Buttons.InCombat.Abilities:Configure(slot, owner, db, petInfoSvc, combatLogSvc)
		self.Right.ButtonsBorder.Buttons.OutCombat.SwapRandom:Configure(slot, owner, db, petInfoSvc)
		self.Right.ButtonsBorder.Buttons.OutCombat.SwapDropdown:Configure(slot, owner, db, zoo, petInfoSvc, options)
		self.Right.ButtonsBorder.Buttons.OutCombat.Summon:Configure(db, slot)
		self.Right.ButtonsBorder.Buttons.OutCombat.Speak:Configure(db, slot)
	end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
	function self:Initialize()
		self.Left:Initialize()
		self.Auras:Initialize()
		self.Right.ButtonsBorder.Buttons.InCombat.Abilities:Initialize()
		if (self.owner == Enum.BattlePetOwner.Enemy) then
			self.Right.ButtonsBorder.Buttons.InCombat.Call:Hide()
			self.Right.Name.color:SetColorTexture(0.4, 0.0, 0.0, 0.4)
		end
		self:RegisterEvent("PET_BATTLE_HEALTH_CHANGED")
		self:RegisterEvent("PET_BATTLE_XP_CHANGED")
		self:RegisterEvent("PET_BATTLE_LEVEL_CHANGED")
		self:RegisterEvent("PET_BATTLE_PET_ROUND_RESULTS")
        self:ListenCombatLog()
	end
	---------------------------------------------------------------------------
	--- Set all pet information. Will automatically disseminate info to other 
	--- methods when required.
	--- @param petInfo	OracleHUD_PB_PetInfo		OracleHUD_PB Uniform pet table.
    function self:SetPetInfo(petInfo)
        if (petInfo == nil) then
            error("OracleHUD_PB_PanelLoadoutBattleSlotTemplate:SetPetInfo(): Invalid arguments.")
		end
        if (self.slot == nil or self.owner == nil or self.db == nil) then
            error("OracleHUD_PB_PanelLoadoutBattleSlotTemplate:SetPetInfo(): Configure() must be called first.")
		end
		self.petInfo = petInfo
		self:SetAbilities(self.petInfo.abilities, self.slot, self.owner)
		self.Right.ButtonsBorder.Buttons.OutCombat.Summon:SetPetInfo(petInfo)
		self.Right.ButtonsBorder.Buttons.OutCombat.SwapDropdown:SetPetInfo(petInfo)
		self.Right.ButtonsBorder.Buttons.OutCombat.Speak:SetPetInfo(petInfo, self.db)
		local name = self.petInfoSvc:WrapTextWithRarityColor(petInfo.name, petInfo.rarity)
		self:SetName(name)
		self:SetLevel(petInfo.level)
		self:SetHealth(petInfo.health, petInfo.healthMax)
		self:SetExperience(petInfo.experience)
		if (self.owner == Enum.BattlePetOwner.Enemy) then
			self.Right.ExperienceBar:Hide()
		else
			self.Right.ExperienceBar:Show()
		end
	end
    ---------------------------------------------------------------------------
    --- Arrange the loadout slot horizontally.
    function self:Horizontal()
		self.Auras:ClearAllPoints()
		self.Left:ClearAllPoints()
		self.Left:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
		self.Left:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)
		self.Auras:SetPoint("TOPLEFT", self.Left, "BOTTOMLEFT", 2, -4)
		self.Auras:Horizontal()
		self.horizontal = true
	end
    ---------------------------------------------------------------------------
    --- Arrange the loadout slot vertically.
    function self:Vertical()
		self.Auras:ClearAllPoints()
		self.Left:ClearAllPoints()
		self.Auras:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
		self.Left:SetPoint("TOPLEFT", self.Auras, "TOPRIGHT", 1, 0)
		self.Left:SetPoint("BOTTOM", self, "BOTTOM", 0, 0)
		self.Auras:Vertical()
		self.horizontal = false
	end
    ---------------------------------------------------------------------------
    function self:IsHorizontal()
        return self.horizontal
    end
	function self:SetAbilities(abilities, slot, owner)	
		self.Right.ButtonsBorder.Buttons.InCombat.Abilities:SetAbilities(abilities, slot, owner)
	end
	function self:SetName(name)
		self.Right.Name.Font:SetText(name)
	end
	function self:SetLevel(level)
		self.petInfo.level = level
		self.petInfo.experienceMax = OracleHUD_PB_DB_PetExperienceGetMax(level)
		self.Left:SetPetInfo(self.petInfo)
	end
	function self:SetExperience(experience, max)
		if (self.owner == Enum.BattlePetOwner.Ally) then
			self.petInfo.experience = experience
			local pct = math.floor((self.petInfo.experience / self.petInfo.experienceMax) * 100)
			self.Right.ExperienceBar:SetExperience(pct)
		end
	end
	function self:SetAnimation(animation)
		self.Left:SetAnimation(animation)
	end
	function self:SetLoss(health)
		local pct = math.floor((health / self.petInfo.healthMax) * 100)
		self.Right.HealthBar:SetLoss(pct)
	end
	function self:SetHealth(health, max)
		if (self.petInfo.health == 0 and health > 0) then
			self:SetAnimation(self.petAnimEnum.STAND)
		elseif (health == 0) then
			self:SetAnimation(self.petAnimEnum.DEATH)
		end	
		self.petInfo.health = health
		local pct = math.floor((self.petInfo.health / self.petInfo.healthMax) * 100)
		self.Right.HealthBar:SetHealth(pct)
	end
	---------------------------------------------------------------------------
	--- Set pet as currently being on the battle field.
	-- @param active		Pet is on the battle field (true/false).
	function self:SetActivePet(active)
		if (active == true) then
			self.Left.AnimationBox.AnimationPositioned:SetAlpha(1.0)
			self.Left.AnimationBox.AnimationRaw:SetAlpha(1.0)
			self.active = true
-- TODO : Call a function instead, pass the info down.
--			self.InCombat.Abilities:SetAlpha(1.0)
			self.Right.ButtonsBorder.Buttons.InCombat.Call:Hide()
		else
			if (self.battleSlot ~= nil) then
				self.Left.AnimationBox.AnimationPositioned:SetAlpha(0.4)
				self.Left.AnimationBox.AnimationRaw:SetAlpha(0.4)
			end
			self.active = false
-- TODO : Call a function instead, pass the info down.			
--			self.InCombat.Abilities:SetAlpha(0.40)
			if (self.owner == Enum.BattlePetOwner.Ally) then
				self.Right.ButtonsBorder.Buttons.InCombat.Call:Show()
			end
		end
		self.Left:SetActive(active)
	end
	---------------------------------------------------------------------------
	--- Report if battle slot pet is currently on battlefield.
	function self:IsActive()
		return self.active
	end
	---------------------------------------------------------------------------
	--- Apply an aura.
    --- @param  auraId       	number                  Ability that created the aura.
    --- @param  turnsRemaining  number                  Number of turns aura will be applied.
    --- @param  isBuff          boolean                 Aura is intended to be displayed to user.
	function self:AuraApply(auraId, turnsRemaining, isBuff)
		local auras = OracleHUD_TableCopy(self:GetAuras())
		local id, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfoByID(auraId)
		if (self:AuraExists(auraId) == false) then
			table.insert(auras, {
				auraId = auraId,
				turnsRemaining = turnsRemaining,
				name = name,
				icon = icon })
			self:SetAuras(auras)
		end
	end
	---------------------------------------------------------------------------
	--- Fade an aura.
	--- @param	auraId	number
	function self:AuraFade(auraId)
		local auras = OracleHUD_TableCopy(self:GetAuras())
		for k, v in pairs(auras) do
			if (v.auraId == auraId) then
				auras[k] = nil
				break
			end
		end
		self:SetAuras(auras)
	end
	---------------------------------------------------------------------------
	--- Report if aura is already applied.
	--- @param	auraId	number
	function self:AuraExists(auraId)
		local exists = false
		local auras = self:GetAuras()
		for k, v in pairs(auras) do
			if (v.auraId == auraId) then
				exists = true
				break
			end
		end
		return exists
	end
	---------------------------------------------------------------------------
	--- Get all auras.
	function self:GetAuras()
		return self.auras
	end
	---------------------------------------------------------------------------
	--- Set all auras.
	--- @param	auras	table
	function self:SetAuras(auras)
		self.auras = auras
		self.Auras:SetAuras(self:GetAuras())
	end
	---------------------------------------------------------------------------
	--- Set pet as being in a pet battle.
	-- @param inCombat		Pet is in a pet battle (true/false).
	function self:SetInBattle(inCombat)
		if (inCombat == true) then
			self.battleSlot = self.petInfoSvc:GetBattleOrderSlot(
				self.slot,
				self.db,
				self.owner,
				self.combatLogSvc:GetBattleOrder())
			self.Right.ButtonsBorder.Buttons.InCombat:Show()
			self.Right.ButtonsBorder.Buttons.OutCombat:Hide()
		else
			self.battleSlot = nil
			self.Right.ButtonsBorder.Buttons.InCombat:Hide()
			self.Right.ButtonsBorder.Buttons.OutCombat:Show()
			self.Right.ButtonsBorder.Buttons.InCombat.Call:Hide()
			self.Left.AnimationBox.AnimationPositioned:SetAlpha(1.0)
			self.Left.AnimationBox.AnimationRaw:SetAlpha(1.0)
		end
	end
    ---------------------------------------------------------------------------
    --- Set slot to be in summoned or unsummoned state (display summon/speak buttons).
    -- @param slot      True/false
	function self:SetSummonedStatus(summon)
		if (summon == true) then
			if (self.petInfo.content ~= nil and self.petInfo.content.emotes ~= nil) then
				self.Right.ButtonsBorder.Buttons.OutCombat.Speak:SetPetInfo(self.petInfo, self.db)
				self.Right.ButtonsBorder.Buttons.OutCombat.Speak:ShowFull()
			else
				self.Right.ButtonsBorder.Buttons.OutCombat.Speak:HideFull()
			end
			self.Right.ButtonsBorder.Buttons.OutCombat.Summon:HideFull()
		else
			self.Right.ButtonsBorder.Buttons.OutCombat.Summon:ShowFull()
			self.Right.ButtonsBorder.Buttons.OutCombat.Speak:HideFull()
		end
	end
    ---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
		if (eventName == "PET_BATTLE_HEALTH_CHANGED") then
			local owner, battleSlot, healthChange = ...
			if (owner == self.owner) then
				local journalSlot = self.petInfoSvc:GetJournalOrderSlot(
					battleSlot,
					self.db,
					owner,
					self.combatLogSvc:GetBattleOrder())
				if (self.slot == journalSlot) then
					local petInfo = self.petInfoSvc:GetPetInfoBySlot(self.slot, self.db, self.owner)
					self:SetHealth(petInfo.health)
				end
			end
		end
		if (eventName == "PET_BATTLE_XP_CHANGED") then
			local owner, battleSlot, xpChange = ...
			local journalSlot = self.petInfoSvc:GetJournalOrderSlot(
				battleSlot,
				self.db,
				owner,
				self.combatLogSvc:GetBattleOrder())
			if (owner == self.owner and journalSlot == self.slot) then
				local petInfo = self.petInfoSvc:GetPetInfoBySlot(journalSlot, self.db, owner)
				local newExperience = petInfo.experience + xpChange
				if (newExperience > petInfo.experienceMax) then
					newExperience = newExperience - petInfo.experienceMax
					self:SetLevel(petInfo.level + 1)
				end
				self:SetExperience(newExperience)
			end
		end
		if (eventName == "PET_BATTLE_LEVEL_CHANGED") then
            local owner, battleSlot, newLevel = ...
            if (owner == self.owner) then
				local journalSlot = self.petInfoSvc:GetJournalOrderSlot(
					battleSlot,
					self.db,
					owner,
					self.combatLogSvc:GetBattleOrder())
				if (journalSlot == self.slot) then
					self:SetLevel(newLevel)
				end
            end
		end
	end
	---------------------------------------------------------------------------
	--- Listen to combat log service events.
	function self:ListenCombatLog()
		-- Damage
		self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.DAMAGE, function(abilityId, amount, owner, target)
			if (owner == self.owner and self:IsActive()) then
				C_Timer.After(0.5, function()
					self:SetAnimation(self.petAnimEnum.COMBATWOUND)
				end)
			end
			if (owner ~= self.owner and self:IsActive()) then
				self:SetAnimation(self.petAnimEnum.ATTACKUNARMED)
			end
		end)
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.OPEN, function(loadoutOnOpen)

		end)
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.CLOSE, function(statsTotal, statsBattle)
			self:SetAuras({})
		end)
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.ROUNDEND, function(round)
			self:OnRoundEnd(round)
		end)
	end
	---------------------------------------------------------------------------
	--- When the round ends then recalculate the size of the loss bar if needed.
	--- @param	round	number
	function self:OnRoundEnd(round)
		if (self.combatLogSvc:IsInBattle()) then
			local petInfo = self.petInfoSvc:GetPetInfoBySlot(self.slot, self.db, self.owner)
			if (petInfo ~= nil) then
				self:SetLoss(petInfo.health)
			end
		end
	end
	---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
    function self:OnSizeChanged()
		local buttonSize = 0.20
		OracleHUD_FrameSetHeightSquarePct(self.Left, 1.00)
		OracleHUD_FrameSetHeightPct(self.Right, 1.0)
		OracleHUD_FrameSetHeightPct(self.Right.Name, 0.3333)
		OracleHUD_FrameSetSizePct(self.Right.ButtonsBorder.Buttons, 0.95, 0.80)
		self.color:SetSize(self:GetWidth(), self:GetHeight());
        self.Right.color:SetSize(self.Right:GetWidth(), self.Right:GetHeight());
		if (self:IsHorizontal()) then
			OracleHUD_FrameSetSizePct(self.Auras, 1.0, 0.25)
		else
			OracleHUD_FrameSetSizePct(self.Auras, 0.1, 1.0)
		end
		-- Why this??
		-- InCombat
		C_Timer.After(0, function()
			OracleHUD_FrameSetWidthSquarePct(self.Right.ButtonsBorder.Buttons.InCombat.Call, buttonSize)
			OracleHUD_FrameSetSizePct(self.Right.ButtonsBorder.Buttons.InCombat.Abilities, 1.0, 1.0)
		end)
		-- OutCombat
		C_Timer.After(0, function()
			OracleHUD_FrameSetWidthSquarePct(self.Right.ButtonsBorder.Buttons.OutCombat.Summon, buttonSize)
			OracleHUD_FrameSetWidthSquarePct(self.Right.ButtonsBorder.Buttons.OutCombat.Speak, buttonSize)
			OracleHUD_FrameSetWidthSquarePct(self.Right.ButtonsBorder.Buttons.OutCombat.SwapRandom, buttonSize)
			OracleHUD_FrameSetWidthSquarePct(self.Right.ButtonsBorder.Buttons.OutCombat.SwapDropdown, buttonSize)
		end)
	end
	function self:SetCallCallback(callback)
		self.callCallback = callback
	end
	self.Right.ButtonsBorder.Buttons.OutCombat.Speak:SetCallback(function(button)
		--self:SetPetInfo(self.petInfo, db)
	end)
	self.Right.ButtonsBorder.Buttons.OutCombat.SwapRandom:SetCallback(function(button, petInfo)
		self:SetPetInfo(petInfo)
	end)
	self.Right.ButtonsBorder.Buttons.OutCombat.SwapDropdown:SetCallback(function(button, petInfo)
		self:SetPetInfo(petInfo)
	end)
	self.Right.ButtonsBorder.Buttons.InCombat.Call:SetScript("Onclick", function(button, down)
		if (self.callCallback) then
			self.callCallback(frame.slot)
		end
	end)
	self.Right.ButtonsBorder.Buttons.InCombat.Call:RegisterForClicks("AnyDown")
	---------------------------------------------------------------------------
	--- Listen for ability button clicks
	self.Right.ButtonsBorder.Buttons.InCombat.Abilities:SetCallback(function(ability, index)
		self.c_petbattles.UseAbility(index)
	end)
	---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged()
	end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
   self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end

