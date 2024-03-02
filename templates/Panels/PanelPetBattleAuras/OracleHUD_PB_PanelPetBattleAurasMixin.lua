--- Display all pet battle abilities for a single pet.
--- @class OracleHUD_PB_PanelPetBattleAuras : OracleHUD_PB_Panel
--- @field Aura1    any         Inherited from mixin XML frame.
--- @field Aura2    any         Inherited from mixin XML frame.
--- @field Aura3    any         Inherited from mixin XML frame.
--- @field Aura4    any         Inherited from mixin XML frame.
OracleHUD_PB_PanelPetBattleAurasMixin = CreateFromMixins(OracleHUD_PB_PanelMixin)
OracleHUD_PB_PanelPetBattleAurasMixin._class = "OracleHUD_PB_PanelPetBattleAurasMixin"
OracleHUD_PB_PanelPetBattleAurasMixin.callback = nil
OracleHUD_PB_PanelPetBattleAurasMixin.horizontal = false
---------------------------------------------------------------------------
--- Configure frame with required data.
--- @param slot		    integer                         Journal order pet is slotted to.
--- @param owner		Enum.BattlePetOwner             Ally or Enemy.
--- @param db		    OracleHUD_PB_DB                 Oracle HUD Pet Battle database.
--- @param petInfoSvc   OracleHUD_PB_PetInfoService     Oracle HUD Pet Info Service.
--- @param combatLogSvc OracleHUD_PB_CombatLogService   Oracle HUD Combat Log Service.
function OracleHUD_PB_PanelPetBattleAurasMixin:Configure(slot, owner, db, petInfoSvc, combatLogSvc)
    if (slot == nil or owner == nil or db == nil or petInfoSvc == nil or combatLogSvc == nil) then
        error(self._class..":Configure(): Invalid arguments")
    end
    self.slot = slot
    self.owner = owner
    self.db = db
    self.petInfoSvc = petInfoSvc
    self.combatLogSvc = combatLogSvc
    -- Configure children
    self.Aura1:Configure(db, petInfoSvc, combatLogSvc, slot, owner, 1)
    self.Aura2:Configure(db, petInfoSvc, combatLogSvc, slot, owner, 2)
    self.Aura3:Configure(db, petInfoSvc, combatLogSvc, slot, owner, 3)
    self.Aura4:Configure(db, petInfoSvc, combatLogSvc, slot, owner, 3)
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_PanelPetBattleAurasMixin:Initialize(callback)
    if (self.db.debug) then print("..Initialize Pet Auras Panel") end
    self:ListenCombatLog()
    if (callback ~= nil) then
        callback()
    end
end
---------------------------------------------------------------------------
--- Arrange the auras horizontally.
function OracleHUD_PB_PanelPetBattleAurasMixin:Horizontal()
    for i = 2, 4 do
        self["Aura"..i]:ClearAllPoints()
        self["Aura"..i]:SetPoint("TOPLEFT", self["Aura"..i-1], "TOPRIGHT", 1, 0)
    end
    self.horizontal = true
end
---------------------------------------------------------------------------
--- Arrange the auras vertically.
function OracleHUD_PB_PanelPetBattleAurasMixin:Vertical()
    for i = 2, 4 do
        self["Aura"..i]:ClearAllPoints()
        self["Aura"..i]:SetPoint("TOPLEFT", self["Aura"..i-1], "BOTTOMLEFT", 0, 1)
    end
    self.horizontal = false
end
-------------------------------------------------------------------------------
--- Update aura icons of a pet battle slot.
--- @param auras    any     Array of OracleHUD_PB_PetInfoAbility
function OracleHUD_PB_PanelPetBattleAurasMixin:SetAuras(auras)
    for i = 1, 4 do
        if (auras[i] ~= nil) then
            self["Aura"..i]:SetAura({
                id = auras[i].auraId,
                icon = auras[i].icon
            })
            self["Aura"..i]:ShowFull()
        else
            self["Aura"..i]:HideFull()
        end
    end
end
-------------------------------------------------------------------------------
--- Listen to the combat log for events.
function OracleHUD_PB_PanelPetBattleAurasMixin:ListenCombatLog()
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_PanelPetBattleAurasMixin:OnLoad()
    ---------------------------------------------------------------------------
    --- Dynamically resize all children elements when frame changes size.
    self:HookScript("OnSizeChanged", function()
        local buttonSize = 1.0
		OracleHUD_FrameSetWidthSquarePct(self.Aura1, buttonSize)
		OracleHUD_FrameSetWidthSquarePct(self.Aura2, buttonSize)
		OracleHUD_FrameSetWidthSquarePct(self.Aura3, buttonSize)
		OracleHUD_FrameSetWidthSquarePct(self.Aura4, buttonSize)
    end)
end
