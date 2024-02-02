--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_ButtonPetBattleAttackTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
    self.ShowFull = OracleHUD_FrameShowFull
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db		    Oracle HUD Pet Battle database.
    --- @param petInfoSvc   OracleHUD_PB_PetInfoService    OracleHUD PetInfo Service.
    -- @param combatLogSvc  OracleHUD Combat Log Service.
	function self:Configure(db, petInfoSvc, combatLogSvc)
        if (db == nil or petInfoSvc == nil or combatLogSvc == nil) then
            error("OracleHUD_PB_ButtonPetBattleAttackTemplate:Configure(): Invalid arguments.")
		end
        self.db = db
        self.petInfoSvc = petInfoSvc
        self.combatLogSvc = combatLogSvc
    end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    function self:Initialize()
        self:RegisterForClicks("AnyDown")
        if (self.combatLogSvc:IsInBattle()) then
            self:SetAttackAction()
            SetOverrideBinding(self, true, "Q", "CLICK " .. self:GetName() .. ":LeftButton")
            SetOverrideBinding(self, true, "Z", "CLICK " .. self:GetName() .. ":RightButton")
        else
            ClearOverrideBindings(self)
        end
        if (self:ShouldShow() == true) then
            self:ShowFull()
        else
            self:HideFull()
        end
        self:ListenCombatLog()
    end
    ---------------------------------------------------------------------------
    --- Register a callback that will be executed when the button is clicked.
    function self:SetCallback(callback)
        self.callback = callback
    end
    ---------------------------------------------------------------------------
    --- Determine if a pets are in a state that require showing button
    function self:ShouldShow()
        local shouldShow = false
        if (C_PetBattles.IsInBattle() == true) then
            shouldShow = true
        end     
        return shouldShow
    end
    function self:SetAttackAction()
        local swapTo = nil
        local petInfo = self.petInfoSvc:GetPetInfoByActive(self.db, Enum.BattlePetOwner.Ally)
        -- Effective disabled for now.
        --if ((petInfo.health / petInfo.healthMax) <= 0.00) then
        if (true) then
            local petInfo1 = self.petInfoSvc:GetPetInfoBySlot(1, self.db, Enum.BattlePetOwner.Ally)
            local petInfo2 = self.petInfoSvc:GetPetInfoBySlot(2, self.db, Enum.BattlePetOwner.Ally)
            local petInfo3 = self.petInfoSvc:GetPetInfoBySlot(3, self.db, Enum.BattlePetOwner.Ally)
            local petFirst = nil
            local petSecond = nil
            if (petInfo1 ~= nil and petInfo1.id ~= petInfo.id) then
                petFirst = petInfo1
            end
            if (petFirst == nil and petInfo2 ~= nil and petInfo2.id ~= petInfo.id) then
                petFirst = petInfo2
            end
            if (petFirst == nil and petInfo3 ~= nil and petInfo3.id ~= petInfo.id) then
                petFirst = petInfo3
            end
            if (petInfo1 ~= nil and petInfo1.id ~= petInfo.id and petInfo1.id ~= petFirst.id) then
                petSecond = petInfo1
            end
            if (petInfo2 ~= nil and petInfo2.id ~= petInfo.id and petInfo2.id ~= petFirst.id) then
                petSecond = petInfo2
            end
            if (petInfo3 ~= nil and petInfo3.id ~= petInfo.id and petInfo3.id ~= petFirst.id) then
                petSecond = petInfo3
            end
            if ((petFirst.health/petFirst.healthMax) > 0.5 and petFirst.level <= petSecond.level) then
                swapTo = petFirst.slot
            end
            if ((petSecond.health/petSecond.healthMax) > 0.5 and swapTo == nil) then
                swapTo = petSecond.slot
            end
        end
        --[[        
        if ((petInfo.health / petInfo.healthMax) > 0.33 or swapTo == nil) then
            self:SetNormalTexture(petInfo.abilities.ability1.icon)
            self:SetPushedTexture(petInfo.abilities.ability1.icon)
        else
            self:SetNormalTexture("Interface\\Icons\\Ability_Hunter_BeastCall")
            self:SetPushedTexture("Interface\\Icons\\Ability_Hunter_BeastCall")
        end
        --]]
        self:SetNormalTexture(petInfo.abilities.ability1.icon)
        self:SetPushedTexture(petInfo.abilities.ability1.icon)
        self.ability = petInfo.abilities.ability1
        self.swap = swapTo
    end
    ---------------------------------------------------------------------------
    --- Listen to combat log events
    function self:ListenCombatLog()
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.OPEN, function(loadoutOnOpen)
            self:ShowFull()
            SetOverrideBinding(self, true, "Q", "CLICK " .. self:GetName() .. ":LeftButton")
            SetOverrideBinding(self, true, "Z", "CLICK " .. self:GetName() .. ":RightButton")
        end)
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.CLOSE, function(statsTotal, statsBattle)
            ClearOverrideBindings(self)
            self:HideFull()
        end)
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.ROUNDEND, function()
            self:PetRoundEnd()
        end)
    end
    function self:PetRoundEnd()
        self:SetAttackAction()
    end
    ---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
    end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
    function self:OnSizeChanged_ButtonPetAttackTemplate()
    end
    ---------------------------------------------------------------------------
    --- After button is clicked then execute callback.
    self:SetScript("PostClick", function(self, button)
        if (self.ability ~= nil and button == "LeftButton") then
            C_PetBattles.UseAbility(1)
        else
            local battleOrderSlot = self.petInfoSvc:GetBattleOrderSlot(
                self.swap,
                self.db,
                Enum.BattlePetOwner.Ally,
                self.combatLogSvc:GetBattleOrder())
            C_PetBattles.ChangePet(battleOrderSlot)
        end
        if (self.callback ~= nil) then
            self.callback(self)
        end
    end)
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_ButtonPetAttackTemplate()
    end)
    ---------------------------------------------------------------------------
    --- Catch events and forard to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
