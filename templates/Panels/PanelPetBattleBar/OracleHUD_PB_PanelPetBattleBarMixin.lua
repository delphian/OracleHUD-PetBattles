--- Pet battle bar with 3 ability buttons of active pet plus skip and forfeit.
--- @class OracleHUD_PB_PanelPetBattleBar : OracleHUD_PB_Panel
--- @field	Bandage		    any     	                                Inherited from mixin XML frame.
--- @field	Revive		    any     	                                Inherited from mixin XML frame.
--- @field	Skip		    any     	                                Inherited from mixin XML frame.
--- @field	Forfeit		    any     	                                Inherited from mixin XML frame.
--- @field	Trap		    any     	                                Inherited from mixin XML frame.
--- @field	Abilities	    OracleHUD_PB_PanelPetBattleAbilities     	Inherited from mixin XML frame.
OracleHUD_PB_PanelPetBattleBarMixin = CreateFromMixins(OracleHUD_PB_PanelMixin)
OracleHUD_PB_PanelPetBattleBarMixin._class = "OracleHUD_PB_PanelPetBattleBarMixin"
---------------------------------------------------------------------------
--- Configure frame with required data.
--- @param db 			OracleHUD_PB_DB	                OracleHUD Pet Battles Database.
--- @param petInfoSvc   OracleHUD_PB_PetInfoService     OracleHUD Pet Battles Pet Information Service.
--- @param combatLogSvc OracleHUD_PB_CombatLogService   OracleHUD Pet Battles Pet Information Service.
function OracleHUD_PB_PanelPetBattleBarMixin:Configure(db, petInfoSvc, combatLogSvc)
    if (db == nil or petInfoSvc == nil or combatLogSvc == nil) then
        error(self._class..":Configure(): Invalid arguments.")
    end
    self.db = db
    self.petInfoSvc = petInfoSvc
    self.combatLogSvc = combatLogSvc
    -- Configure children.
    self.Revive:Configure(db, petInfoSvc, combatLogSvc)
    self.Bandage:Configure(db, petInfoSvc, combatLogSvc)
    self.Forfeit:Configure(db, petInfoSvc, combatLogSvc)
    self.Skip:Configure(db, petInfoSvc, combatLogSvc)
    self.Trap:Configure(db, petInfoSvc, combatLogSvc)
    self.Abilities:Configure(0, Enum.BattlePetOwner.Ally, self.db, self.petInfoSvc, self.combatLogSvc)
end
-------------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param  callback    function?      (Optional) Execute callback when initialize has finished.
function OracleHUD_PB_PanelPetBattleBarMixin:Initialize(callback)
    if (self.db.debug) then print("..Initialize Loadout Battle Support Panel") end
    self.Revive:Initialize()
    self.Bandage:Initialize()
    self.Forfeit:Initialize()
    self.Skip:Initialize()
    self.Trap:Initialize()
    self.Abilities:Initialize()
    if (self.combatLogSvc:IsInBattle()) then
        self:OnPetBattleOpen()
    end
    self:ListenCombatLog()
    C_Timer.After(1.0, function()
        if (self:ShouldShow() == true) then
            self:ShowFull()
        else
            self:HideFull()
        end
        if (callback ~= nil) then
            callback()
        end
    end)
end
-------------------------------------------------------------------------------
--- Set the pet battle bar ability buttons to the currently active pet.
function OracleHUD_PB_PanelPetBattleBarMixin:SetAbilities()
    local jSlot = self.combatLogSvc:GetActiveJSlot(Enum.BattlePetOwner.Ally)
    if (jSlot ~= nil) then
        self.Abilities:Configure(jSlot, Enum.BattlePetOwner.Ally, self.db, self.petInfoSvc, self.combatLogSvc)
        local petInfo = self.petInfoSvc:GetPetInfoBySlot(jSlot, self.db, Enum.BattlePetOwner.Ally)
        if (petInfo ~= nil) then
            self.Abilities:SetAbilities(petInfo.abilities)
        end
        self.Abilities:SetPetActive(true)
    end
end
-------------------------------------------------------------------------------
--- When battle is starting then show the buttons and set the hotkey overrides.
function OracleHUD_PB_PanelPetBattleBarMixin:OnPetBattleOpen()
    self:SetAbilities()
    self.Abilities:ShowFull()
    self:ShowFull()
    SetOverrideBinding(self.Abilities.Ability1.Ability, true, "Q", "CLICK " .. self.Abilities.Ability1.Ability:GetName() .. ":LeftButton")
    SetOverrideBinding(self.Abilities.Ability2.Ability, true, "E", "CLICK " .. self.Abilities.Ability2.Ability:GetName() .. ":LeftButton")
    SetOverrideBinding(self.Abilities.Ability3.Ability, true, "R", "CLICK " .. self.Abilities.Ability3.Ability:GetName() .. ":LeftButton")
end
-------------------------------------------------------------------------------
--- When battle is over then hide the buttons and clear the hotkey overrides.
function OracleHUD_PB_PanelPetBattleBarMixin:OnPetBattleClose()
    self.Abilities:HideFull()
    ClearOverrideBindings(self.Abilities.Ability1.Ability)
    ClearOverrideBindings(self.Abilities.Ability2.Ability)
    ClearOverrideBindings(self.Abilities.Ability3.Ability)
    C_Timer.After(1.0, function()
        if (self:ShouldShow() == true) then
            self:ShowFull()
        else
            self:HideFull()
        end
    end)
end
-------------------------------------------------------------------------------
--- Register a callback that will be executed when a button is clicked.
--- @param  callback    function
function OracleHUD_PB_PanelPetBattleBarMixin:SetCallback(callback)
    self.callback = callback
end
-------------------------------------------------------------------------------
--- Determine if the panel should be shown
function OracleHUD_PB_PanelPetBattleBarMixin:ShouldShow()
    local shouldShow = false
    if (self.combatLogSvc:IsInBattle()) then
        shouldShow = true
    end
    if (self.Abilities:IsShown() == true or
        self.Revive:IsShown() == true or
        self.Bandage:IsShown() == true or
        self.Trap:IsShown() == true or
        self.Skip:IsShown() == true)
    then
        shouldShow = true
    end
    return shouldShow
end
-------------------------------------------------------------------------------
--- Listen to the combat log for events.
function OracleHUD_PB_PanelPetBattleBarMixin:ListenCombatLog()
    self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.ACTIVE, function(owner, jSlot)
        if (owner == Enum.BattlePetOwner.Ally) then
            self.slot = jSlot
            self:SetAbilities()
        end
    end)
    self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.OPEN, function()
        self:OnPetBattleOpen()
    end)
    self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.CLOSE, function()
        self:OnPetBattleClose()
    end)
end
-------------------------------------------------------------------------------
--- Process incoming events.
--- @param  event       any		Unique event identification
--- @param  eventName   string	Human friendly name of event
function OracleHUD_PB_PanelPetBattleBarMixin:OnEvent(event, eventName, ...)
end
-------------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
function OracleHUD_PB_PanelPetBattleBarMixin:OnSizeChanged()
    OracleHUD_FrameSetHeightSquarePct(self.Abilities, 3.0)
    OracleHUD_FrameSetHeightSquarePct(self.Revive, 1.0)
    OracleHUD_FrameSetHeightSquarePct(self.Bandage, 1.0)
    OracleHUD_FrameSetHeightSquarePct(self.Forfeit, 1.0)
    OracleHUD_FrameSetHeightSquarePct(self.Skip, 1.0)
    OracleHUD_FrameSetHeightSquarePct(self.Trap, 1.0)
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param  self     any      Our main XML frame.
function OracleHUD_PB_PanelPetBattleBarMixin:OnLoad()
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
    ---------------------------------------------------------------------------
    --- Listen to ability panel and execute ability when button is clicked.
    self.Abilities:SetCallback(function(ability, index)
		C_PetBattles.UseAbility(index)
    end)
    ---
    self.Revive:SetCallback(function(reviveBtn)
        self.Bandage:HideFull()
        if (self:ShouldShow() == false) then
            self:HideFull()
        end
		C_Timer.After(1, function()
			OracleHUD_PB_PanelLoadoutAlly:Revive()
		end)
	end)
    ---
    self.Bandage:SetCallback(function(bandageBtn)
        self.Revive:HideFull()
        if (self:ShouldShow() == false) then
            self:HideFull()
        end
		C_Timer.After(1, function()
			OracleHUD_PB_PanelLoadoutAlly:Revive()
		end)
    end)
    self.Forfeit:SetCallback(function()
    end)
    self.Skip:SetCallback(function()
    end)
    self.Trap:SetCallback(function()
    end)
end
