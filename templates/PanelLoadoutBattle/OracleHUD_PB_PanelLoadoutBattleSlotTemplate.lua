--- Called by XML onload.
-- @param self      Our main XML frame.
-- @param db		Oracle HUD Pet Battle database.
function OracleHUD_PB_PanelLoadoutBattleSlotTemplate_OnLoad(self, db)
	local frame = self
	self.HideFull = OracleHUD_FrameHideFull
	self.ShowFull = OracleHUD_FrameShowFull
	self.active = false
	-- Relocated OutCombat
	self.OutCombat:SetParent(self.Parent.Right.ButtonsBorder.Buttons)
	self.Parent.Right.ButtonsBorder.Buttons.OutCombat = self.OutCombat
    -- Emulate inheritence even though we are composition.
	function self:SetLevel(...) return self.Parent:SetLevel(...) end
	function self:SetExperience(...) return self.Parent:SetExperience(...) end
	function self:SetAnimation(...) return self.Parent:SetAnimation(...) end
	function self:SetLoss(...) return self.Parent:SetLoss(...) end
	function self:SetHealth(...) return self.Parent:SetHealth(...) end
	function self:SetName(...) return self.Parent:SetName(...) end
	function self:CanSpeak(...) return self.Parent:CanSpeak(...) end
	function self:Speak(...) return self.Parent:Speak(...) end
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
		self.Parent:Configure(db, display, slot, owner, network, petAnimEnum, zoo, petInfoSvc, tooltipPetInfo)
		self.InCombat.Abilities:Configure(slot, owner, db, petInfoSvc, combatLogSvc)
		self.OutCombat.SwapRandom:Configure(slot, owner, db, petInfoSvc)
		self.OutCombat.SwapDropdown:Configure(slot, owner, db, zoo, petInfoSvc, options)
		self.OutCombat.Summon:Configure(db, slot)
		self.OutCombat.Speak:Configure(db, slot)
	end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
	function self:Initialize()
		self.Parent:Initialize()
		self.InCombat.Abilities:Initialize()
		if (self.owner == Enum.BattlePetOwner.Enemy) then
			self.InCombat.Call:Hide()
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
		self.Parent:SetPetInfo(petInfo)
		self.OutCombat.Summon:SetPetInfo(petInfo)
		self.OutCombat.SwapDropdown:SetPetInfo(petInfo)
		self.OutCombat.Speak:SetPetInfo(petInfo, self.db)
	end
	function self:SetAbilities(abilities, slot, owner)	
		self.InCombat.Abilities:SetAbilities(abilities, slot, owner)
	end
	---------------------------------------------------------------------------
	--- Set pet as currently being on the battle field.
	-- @param active		Pet is on the battle field (true/false).
	function self:SetActivePet(active)
		local origParent = self.Parent.Left
		local frameRef = self.Parent.Left:GetParent():GetParent():GetParent():GetParent():GetParent()
		if (active == true) then
			self.Parent.Left.AnimationBox.AnimationPositioned:SetAlpha(1.0)
			self.Parent.Left.AnimationBox.AnimationRaw:SetAlpha(1.0)
			self.active = true
-- TODO : Call a function instead, pass the info down.
--			self.InCombat.Abilities:SetAlpha(1.0)
			self.InCombat.Call:Hide()
		else
			if (self.battleSlot ~= nil) then
				self.Parent.Left.AnimationBox.AnimationPositioned:SetAlpha(0.4)
				self.Parent.Left.AnimationBox.AnimationRaw:SetAlpha(0.4)
			end
			self.active = false
-- TODO : Call a function instead, pass the info down.			
--			self.InCombat.Abilities:SetAlpha(0.40)
			if (self.owner == Enum.BattlePetOwner.Ally) then
				self.InCombat.Call:Show()
			end
		end
		self.Parent.Left:SetActive(active)
	end
	---------------------------------------------------------------------------
	--- Report if battle slot pet is currently on battlefield.
	function self:IsActive()
		return self.active
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
			self.InCombat:Show()
			self.OutCombat:Hide()
		else
			self.battleSlot = nil
			self.InCombat:Hide()
			self.OutCombat:Show()
			self.InCombat.Call:Hide()
			self.Parent.Left.AnimationBox.AnimationPositioned:SetAlpha(1.0)
			self.Parent.Left.AnimationBox.AnimationRaw:SetAlpha(1.0)
		end
	end
    ---------------------------------------------------------------------------
    --- Set slot to be in summoned or unsummoned state (display summon/speak buttons).
    -- @param slot      True/false
	function self:SetSummonedStatus(summon)
		if (summon == true) then
			if (self.petInfo.content ~= nil and self.petInfo.content.emotes ~= nil) then
				self.OutCombat.Speak:SetPetInfo(self.petInfo, self.db)
				self.OutCombat.Speak:ShowFull()
			else
				self.OutCombat.Speak:HideFull()
			end
			self.OutCombat.Summon:HideFull()
		else
			self.OutCombat.Summon:ShowFull()
			self.OutCombat.Speak:HideFull()
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
					self.Parent:SetLevel(newLevel)
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
    function self:OnSizeChanged_PanelLoadoutBattleSlotTemplate()
		local buttonSize = 0.20
		OracleHUD_FrameSetSizePct(self.Parent, 1.0, 1.0)
		self.Parent:OnSizeChanged_PanelLoadoutSlotTemplate()
		-- Why this??
		-- InCombat
		C_Timer.After(0, function()
			OracleHUD_FrameSetWidthSquarePct(self.InCombat.Call, buttonSize)
			OracleHUD_FrameSetSizePct(self.InCombat.Abilities, 1.0, 1.0)
		end)
		-- OutCombat
		C_Timer.After(0, function()
			OracleHUD_FrameSetWidthSquarePct(self.OutCombat.Summon, buttonSize)
			OracleHUD_FrameSetWidthSquarePct(self.OutCombat.Speak, buttonSize)
			OracleHUD_FrameSetWidthSquarePct(self.OutCombat.SwapRandom, buttonSize)
			OracleHUD_FrameSetWidthSquarePct(self.OutCombat.SwapDropdown, buttonSize)
		end)
	end
	function self:SetCallCallback(callback)
		self.callCallback = callback
	end
	self.OutCombat.Speak:SetCallback(function(button)
		--self:SetPetInfo(self.petInfo, db)
	end)
	self.OutCombat.SwapRandom:SetCallback(function(button, petInfo)
		self:SetPetInfo(petInfo)
	end)
	self.OutCombat.SwapDropdown:SetCallback(function(button, petInfo)
		self:SetPetInfo(petInfo)
	end)
	self.InCombat.Call:SetScript("Onclick", function(button, down)
		if (self.callCallback) then
			self.callCallback(frame.slot)
		end
	end)
	self.InCombat.Call:RegisterForClicks("AnyDown")
	---------------------------------------------------------------------------
	--- Listen for ability button clicks
	self.InCombat.Abilities:SetCallback(function(ability, index)
		self.c_petbattles.UseAbility(index)
	end)
	---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_PanelLoadoutBattleSlotTemplate()
	end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
   self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end

