--- Display, manage cooldowns, and execution of a single pet ability when clicked.
--- @class OracleHUD_PB_ButtonPetAbility : OracleHUD_PB_Button
--- @field petActive            boolean     Pet is currently on the battle field.
--- @field RegisterForClicks    any         Inherited from mixin XML frame.
--- @field Ability		        any         Inherited from mixin XML frame.
--- @field Background           any         Inherited from mixin XML frame.
--- @field Font                 any         Inherited from Mixin XML frame.
OracleHUD_PB_ButtonPetAbilityMixin = CreateFromMixins(OracleHUD_PB_ButtonMixin)
OracleHUD_PB_ButtonPetAbilityMixin._class = "OracleHUD_PB_ButtonPetAbilityMixin"
OracleHUD_PB_ButtonPetAbilityMixin.callback = nil
OracleHUD_PB_ButtonPetAbilityMixin.listeningCombatLog = false
-------------------------------------------------------------------------------
--- Configure mixin with required data.
--- @param db 		    OracleHUD_PB_DB	                OracleHUD Pet Battles Database.
--- @param petInfoSvc   OracleHUD_PB_PetInfoService     OracleHUD Pet Battles Pet Information Service.
--- @param combatLogSvc OracleHUD_PB_CombatLogService   OracleHUD Pet Battles Combat Log Service.
--- @param slot         integer                         Journal order pet is slotted to.
--- @param owner        Enum.BattlePetOwner             Ally or Enemy owner of pet.
--- @param index        integer                         Ability index from left to right (1-3)
function OracleHUD_PB_ButtonPetAbilityMixin:Configure(db, petInfoSvc, combatLogSvc, slot, owner, index)
	if (db == nil or petInfoSvc == nil or combatLogSvc == nil or slot == nil or owner == nil or index == nil) then
		error(self._class..":Configure(): Invalid arguments")
	end
	self.db = db
    self.petInfoSvc = petInfoSvc
    self.combatLogSvc = combatLogSvc
    self.owner = owner
    self.slot = slot
    self.index = index
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_ButtonPetAbilityMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Pet Ability Button, Owner "..self.owner..", Slot "..self.slot..", Index "..self.index) end
    if (callback ~= nil) then
		callback()
	end
end
-------------------------------------------------------------------------------
--- Update the action ability of the button.
--- @param ability  any petInfo.abilities loaded from OracleHUD_PB_GetPetInfoBySlot()
function OracleHUD_PB_ButtonPetAbilityMixin:SetAbility(ability)
    if (ability == nil) then
        error(self._class..":SetAbility(): Invalid arguments")
    end
    self.ability = ability
    self.Ability:SetNormalTexture(ability.icon)
    self.Ability:SetHighlightTexture(ability.icon)
    self.Ability:SetPushedTexture(ability.icon, "ADD")
    self:RegisterForClicks("AnyDown")
    if (self.listeningCombatLog ~= true) then
        self.listeningCombatLog = true
        self:ListenCombatLog()
    end
    if (self.combatLogSvc:IsInBattle()) then
        self:SetAvailability()
        if (self.owner == Enum.BattlePetOwner.Ally) then
            local eJSlot = self.combatLogSvc:GetJSlotActive(Enum.BattlePetOwner.Enemy)
            self:OnPetActive(Enum.BattlePetOwner.Enemy, eJSlot)
        end
    end
end
-------------------------------------------------------------------------------
--- Set the button's availability based on cooldowns and lockdowns.
function OracleHUD_PB_ButtonPetAbilityMixin:SetAvailability()
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
--- Listen to the combat log for events.
function OracleHUD_PB_ButtonPetAbilityMixin:ListenCombatLog()
    self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.OPEN, function(round)
        self:SetAvailability()
    end)
    self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.ROUNDSTART, function(round)
        self:SetAvailability()
    end)
    self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.ROUNDEND, function(round)
        self:SetAvailability()
    end)
    self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.ACTIVE, function(owner, jSlot)
        self:OnPetActive(owner, jSlot)
    end)
end
-------------------------------------------------------------------------------
--- A pet has become active on the battlefield. Update ability modifiers.
--- @param  owner   Enum.BattlePetOwner
--- @param  jSlot   number
function OracleHUD_PB_ButtonPetAbilityMixin:OnPetActive(owner, jSlot)
    if (self.owner == Enum.BattlePetOwner.Ally and owner == Enum.BattlePetOwner.Enemy) then
        local ePetInfo = self.petInfoSvc:GetPetInfoByActive(Enum.BattlePetOwner.Enemy)
        if (ePetInfo ~= nil) then
            local id, name, icon, maxCooldown, unparsedDescription, numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfoByID(self.ability.id);
            local modifier = C_PetBattles.GetAttackModifier(petType, ePetInfo.type)
            if (modifier > 1) then
                self.Ability.Modifier:SetTexture("Interface\\BUTTONS\\UI-MicroStream-Green")
                self.Ability.Modifier:SetRotation(math.pi)
                self.Ability.Modifier:Show()
            end
            if (modifier < 1) then
                self.Ability.Modifier:SetTexture("Interface\\BUTTONS\\UI-MicroStream-Red")
                self.Ability.Modifier:Show()
            end
            if (modifier == 1) then
                self.Ability.Modifier:Hide()
            end
        end
    end
end
-------------------------------------------------------------------------------
--- Set pet active state that button is associated with.
function OracleHUD_PB_ButtonPetAbilityMixin:SetPetActive(active)
    self.petActive = active
    self:SetAvailability()
end
-------------------------------------------------------------------------------
--- Show the pet ability tooltip.
function OracleHUD_PB_ButtonPetAbilityMixin:OnEnter()
    local battleSlot = self.petInfoSvc:GetBattleOrderSlot(
        self.slot,
        self.db,
        self.owner,
        self.combatLogSvc:GetBattleOrder())
    OracleHUD_PB_TooltipAbility_SetAbilityByID(self.owner, battleSlot, self.ability.id)
    OracleHUD_PB_TooltipAbility:SetParent(self)
    OracleHUD_PB_TooltipAbility:SetAllPoints(self)
    -- TODO : Put this in the XML.
    OracleHUD_SetFramePercent(OracleHUD_PB_TooltipAbility, 0, 1, 0, 0)
    OracleHUD_PB_TooltipAbility:Show()
end
-------------------------------------------------------------------------------
--- Hide the pet ability tooltip.
function OracleHUD_PB_ButtonPetAbilityMixin:OnLeave()
    OracleHUD_PB_TooltipAbility:Hide()
end
-------------------------------------------------------------------------------
--- Invoke callback when button is clicked.
function OracleHUD_PB_ButtonPetAbilityMixin:OnClick()
    self:Hide()
    C_Timer.After(0.1, function()
        self:Show()
    end)
    if (self.callback ~= nil) then
        self.callback(self)
    end
end
-------------------------------------------------------------------------------
--- Register a callback that will be executed when the button is clicked.
--- @param callback function    Invoked when button is clicked on.
function OracleHUD_PB_ButtonPetAbilityMixin:SetCallback(callback)
    self.callback = callback
end
-------------------------------------------------------------------------------
--- Process incoming events.
--- @param event		any		Unique event identification
--- @param eventName	string	Human friendly name of event
function OracleHUD_PB_ButtonPetAbilityMixin:OnEvent(event, eventName, ...)
end
-------------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
--- @param self			any	Main XML frame.
function OracleHUD_PB_ButtonPetAbilityMixin:OnSizeChanged_ButtonPetAbility()
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_ButtonPetAbilityMixin:OnLoad()
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:HookScript("OnSizeChanged", function()
		self:OnSizeChanged_ButtonPetAbility()
	end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
	--- @param event		any		Event object.
	--- @param eventName	string	Name of event.
    self:HookScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
    ---------------------------------------------------------------------------
    --- Catch clicks and forward to handler.
    self.Ability:HookScript("OnClick", function()
        self:OnClick()
    end)
    ---------------------------------------------------------------------------
    --- Catch mouse action and forward to handler.
    self.Ability:HookScript("OnEnter", function()
        self:OnEnter()
    end)
    ---------------------------------------------------------------------------
    --- Catch mouse action and forward to handler.
    self.Ability:HookScript("OnLeave", function()
        self:OnLeave()
    end)
end