--- Display, manage cooldowns, and execution of a single pet ability when clicked.
--- @class OracleHUD_PB_ButtonPetBattleAura : OracleHUD_PB_Button
--- @field Aura 		        any         Inherited from mixin XML frame.
--- @field Background           any         Inherited from mixin XML frame.
--- @field Font                 any         Inherited from Mixin XML frame.
OracleHUD_PB_ButtonPetBattleAuraMixin = CreateFromMixins(OracleHUD_PB_ButtonMixin)
OracleHUD_PB_ButtonPetBattleAuraMixin._class = "OracleHUD_PB_ButtonPetBattleAuraMixin"
-------------------------------------------------------------------------------
--- Configure mixin with required data.
--- @param db 		    OracleHUD_PB_DB	                OracleHUD Pet Battles Database.
--- @param petInfoSvc   OracleHUD_PB_PetInfoService     OracleHUD Pet Battles Pet Information Service.
--- @param combatLogSvc OracleHUD_PB_CombatLogService   OracleHUD Pet Battles Combat Log Service.
--- @param slot         integer                         Journal order pet is slotted to.
--- @param owner        Enum.BattlePetOwner             Ally or Enemy owner of pet.
function OracleHUD_PB_ButtonPetBattleAuraMixin:Configure(db, petInfoSvc, combatLogSvc, slot, owner)
	if (db == nil or petInfoSvc == nil or combatLogSvc == nil or slot == nil or owner == nil) then
		error(self._class..":Configure(): Invalid arguments")
	end
	self.db = db
    self.petInfoSvc = petInfoSvc
    self.combatLogSvc = combatLogSvc
    self.owner = owner
    self.slot = slot
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_ButtonPetBattleAuraMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Pet Battle Aura Button, Owner "..self.owner..", Slot "..self.slot) end
    if (callback ~= nil) then
		callback()
	end
end
-------------------------------------------------------------------------------
--- Update the aura of the button.
--- @param aura  any petInfo.abilities loaded from OracleHUD_PB_GetPetInfoBySlot()
function OracleHUD_PB_ButtonPetBattleAuraMixin:SetAura(aura)
    if (aura == nil) then
        error(self._class..":SetAura(): Invalid arguments")
    end
    self.aura = aura
    self.Aura:SetNormalTexture(aura.icon)
    self.Aura:SetHighlightTexture(aura.icon)
    self.Aura:SetPushedTexture(aura.icon, "ADD")
end
-------------------------------------------------------------------------------
--- Set the button's availability based on cooldowns and lockdowns.
function OracleHUD_PB_ButtonPetBattleAuraMixin:SetAvailability()
    local isUsable, currentCooldown, currentLockdown = C_PetBattles.GetAbilityState(self.owner, self.slot, self.index)
    if (isUsable and self.petActive) then
        self.Ability:SetAlpha(1.0)
    else
        self.Ability:SetAlpha(0.3)
    end
    if (currentCooldown ~= nil and currentCooldown > 0) then
        self.Background:Show()
        self.Font:Show()
        self.Font:SetText(currentCooldown)
        self.Ability:SetAlpha(0.3)
    else
        self.Background:Hide()
        self.Font:Hide()
    end
    if (currentLockdown ~= nil and currentLockdown > 0) then
        self.Ability:SetAlpha(0.3)
    end
end
-------------------------------------------------------------------------------
--- Show the pet ability tooltip.
function OracleHUD_PB_ButtonPetBattleAuraMixin:OnEnter()
    local battleSlot = self.petInfoSvc:GetBattleOrderSlot(
        self.slot,
        self.db,
        self.owner,
        self.combatLogSvc:GetBattleOrder())
    OracleHUD_PB_TooltipAbility_SetAbilityByID(self.owner, battleSlot, self.aura.id)
    OracleHUD_PB_TooltipAbility:SetParent(self)
    OracleHUD_PB_TooltipAbility:SetAllPoints(self)
    -- TODO : Put this in the XML.
    OracleHUD_SetFramePercent(OracleHUD_PB_TooltipAbility, 0, 1, 0, 0)
    OracleHUD_PB_TooltipAbility:Show()
end
-------------------------------------------------------------------------------
--- Hide the pet ability tooltip.
function OracleHUD_PB_ButtonPetBattleAuraMixin:OnLeave()
    OracleHUD_PB_TooltipAbility:Hide()
end
-------------------------------------------------------------------------------
--- Process incoming events.
--- @param event		any		Unique event identification
--- @param eventName	string	Human friendly name of event
function OracleHUD_PB_ButtonPetBattleAuraMixin:OnEvent(event, eventName, ...)
end
-------------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
--- @param self			any	Main XML frame.
function OracleHUD_PB_ButtonPetBattleAuraMixin:OnSizeChanged_ButtonPetBattleAura()
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_ButtonPetBattleAuraMixin:OnLoad()
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:HookScript("OnSizeChanged", function()
		self:OnSizeChanged_ButtonPetBattleAura()
	end)
    ---------------------------------------------------------------------------
    --- Catch mouse action and forward to handler.
    self.Aura:HookScript("OnEnter", function()
        self:OnEnter()
    end)
    ---------------------------------------------------------------------------
    --- Catch mouse action and forward to handler.
    self.Aura:HookScript("OnLeave", function()
        self:OnLeave()
    end)
end