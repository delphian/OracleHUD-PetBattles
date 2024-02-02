--- Display all pet battle abilities for a single pet.
--- @class OracleHUD_PB_PanelPetBattleAbilities : OracleHUD_PB_Panel
--- @field Ability1    any         Inherited from mixin XML frame.
--- @field Ability2    any         Inherited from mixin XML frame.
--- @field Ability3    any         Inherited from mixin XML frame.
OracleHUD_PB_PanelPetBattleAbilitiesMixin = CreateFromMixins(OracleHUD_PB_PanelMixin)
OracleHUD_PB_PanelPetBattleAbilitiesMixin._class = "OracleHUD_PB_PanelPetBattleAbilitiesMixin"
OracleHUD_PB_PanelPetBattleAbilitiesMixin.callback = nil
---------------------------------------------------------------------------
--- Configure frame with required data.
--- @param slot		    integer                         Journal order pet is slotted to.
--- @param owner		Enum.BattlePetOwner             Ally or Enemy.
--- @param db		    OracleHUD_PB_DB                 Oracle HUD Pet Battle database.
--- @param petInfoSvc   OracleHUD_PB_PetInfoService     Oracle HUD Pet Info Service.
--- @param combatLogSvc OracleHUD_PB_CombatLogService   Oracle HUD Combat Log Service.
function OracleHUD_PB_PanelPetBattleAbilitiesMixin:Configure(slot, owner, db, petInfoSvc, combatLogSvc)
    if (slot == nil or owner == nil or db == nil or petInfoSvc == nil or combatLogSvc == nil) then
        error(self._class..":Configure(): Invalid arguments")
    end
    self.slot = slot
    self.owner = owner
    self.db = db
    self.petInfoSvc = petInfoSvc
    self.combatLogSvc = combatLogSvc
    --- Configure children.
    self.Ability1:Configure(db, petInfoSvc, combatLogSvc, slot, owner, 1)
    self.Ability2:Configure(db, petInfoSvc, combatLogSvc, slot, owner, 2)
    self.Ability3:Configure(db, petInfoSvc, combatLogSvc, slot, owner, 3)
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_PanelPetBattleAbilitiesMixin:Initialize(callback)
    if (self.db.debug) then print("..Initialize Pet Abilities Panel") end
    self.Ability1:Initialize()
    self.Ability2:Initialize()
    self.Ability3:Initialize()
    if (self.combatLogSvc:IsInBattle()) then
        local jSlot = self.combatLogSvc:GetActiveJSlot(self.owner)
        self:SetPetActive(jSlot == self.slot)
    end
    self:ListenCombatLog()
    if (callback ~= nil) then
        callback()
    end
end
-------------------------------------------------------------------------------
--- Update ability buttons of a pet battle slot.
--- @param abilities    any     Array of OracleHUD_PB_PetInfoAbility
function OracleHUD_PB_PanelPetBattleAbilitiesMixin:SetAbilities(abilities)
    if (abilities == nil) then
        error(self._class..":SetAbilities(): Invalid arguments")
    end
    self.Ability1:SetAbility(abilities["ability1"])
    self.Ability2:SetAbility(abilities["ability2"])
    self.Ability3:SetAbility(abilities["ability3"])
end
-------------------------------------------------------------------------------
--- Set pet active state that button is associated with.
--- @param active   boolean     pet is or is not on battlefield.
function OracleHUD_PB_PanelPetBattleAbilitiesMixin:SetPetActive(active)
    self.petActive = active
    self.Ability1:SetPetActive(active)
    self.Ability2:SetPetActive(active)
    self.Ability3:SetPetActive(active)
end
-------------------------------------------------------------------------------
--- Listen to the combat log for events.
function OracleHUD_PB_PanelPetBattleAbilitiesMixin:ListenCombatLog()
    self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.ACTIVE, function(owner, jSlot)
        if (owner == self.owner) then
            self:SetPetActive(self.slot == jSlot)
        end
    end)
end
---------------------------------------------------------------------------
--- Register a callback that will be executed when a button is clicked.
--- @param callback function    Function to execute when a button is clicked.
function OracleHUD_PB_PanelPetBattleAbilitiesMixin:SetCallback(callback)
    self.callback = callback
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_PanelPetBattleAbilitiesMixin:OnLoad()
    ---------------------------------------------------------------------------
    --- Dynamically resize all children elements when frame changes size.
    self:HookScript("OnSizeChanged", function()
        local buttonSize = 0.20
		OracleHUD_FrameSetWidthSquarePct(self.Ability1, buttonSize)
		OracleHUD_FrameSetWidthSquarePct(self.Ability2, buttonSize)
		OracleHUD_FrameSetWidthSquarePct(self.Ability3, buttonSize)
    end)
    -----------------------------------------------------------------------
    --- Forward all button clicks to callback
    for i = 1, 3 do
        self["Ability"..i]:SetCallback(function(button)
            if (self.callback ~= nil) then
                self.callback(button.ability, button.index)
            end
        end)
    end
end
