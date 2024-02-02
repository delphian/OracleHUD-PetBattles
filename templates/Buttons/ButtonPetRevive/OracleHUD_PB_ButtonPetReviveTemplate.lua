--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_ButtonPetReviveTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
    self.ShowFull = OracleHUD_FrameShowFull
    self.callback = nil
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db		    Oracle HUD Pet Battle database.
    -- @param petInfoSvc    OracleHUD PetInfo Service.
	-- @param combatLogSvc  OracleHUD CombatLog Service.
	function self:Configure(db, petInfoSvc, combatLogSvc)
        if (db == nil or petInfoSvc == nil) then
            error("OracleHUD_PB_ButtonPetReviveTemplate:Configure(): Invalid arguments.")
		end
        self.db = db
        self.petInfoSvc = petInfoSvc
        self.combatLogSvc = combatLogSvc
    end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    function self:Initialize()
        if (self.db.debug) then print("..Initialize Revive Button") end
        self:RegisterForClicks("AnyDown")
        self:SetAttribute('type', 'macro')
        self:SetAttribute('macrotext', '/cast revive battle pets')
        if (self:ShouldShow()) then self:ShowFull() else self:HideFull() self:Hide() end
        if (self:GetCooldown("revive battle pets") > 0) then
            self:Countdown()
        end
        self:ListenCombatLog()
    end
    ---------------------------------------------------------------------------
    --- Register a callback that will be executed when the button is clicked.
    function self:SetCallback(callback)
        self.callback = callback
    end
    --------------------------------------------------------------------------=
    --- Get seconds remaining until button is useable. Negative values means 
    --- usable.
    function self:GetCooldown(spell)
        local start, duration, enabled, modRate = GetSpellCooldown(spell)
        local timeRemaining = start + duration - GetTime()
        return timeRemaining
    end
    ---------------------------------------------------------------------------
    --- Determine if a pets are in a state that require showing button
    function self:ShouldShow()
        local shouldShow = true
        if (self.petInfoSvc:PetsAllWell(Enum.BattlePetOwner.Ally) or self.combatLogSvc:IsInBattle())
        then
            shouldShow = false
        end
        return shouldShow
    end
    ---------------------------------------------------------------------------
    --- Listen to combat log events
    function self:ListenCombatLog()
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.OPEN, function(loadoutOnOpen)
            self:HideFull()
        end)
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.CLOSE, function(statsTotal, statsBattle)
            self:PetBattleClose()
        end)
    end
    ---------------------------------------------------------------------------
    --- Process PET_BATTLE_CLOSE event.
    function self:PetBattleClose()
        local shouldShow = self:ShouldShow()
        if (shouldShow) then
            self:ShowFull()
            if (self:GetCooldown("revive battle pets") > 0) then
                self:Countdown()
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Create a countdown which updates seconds remaining until button may be
    --- clicked again.
    function self:Countdown()
        self.background:Show()
        self.font:Show()
        self:Disable()
        C_Timer.NewTicker(1, function(ticker)
            local timeRemaining = math.floor(self:GetCooldown("revive battle pets"))
            if (timeRemaining < 0) then
                ticker:Cancel()
                self.background:Hide()
                self.font:Hide()
                self:Enable()
                if (self:ShouldShow() == true) then
                    self:ShowFull()
                end
            else
                self.font:SetText(timeRemaining)
            end
        end)
    end
    ---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
    end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
    function self:OnSizeChanged_ButtonPetReviveTemplate()
    end
    ---------------------------------------------------------------------------
    --- After button is clicked then hide and execute callback.
    self:SetScript("PostClick", function(self)
        self:HideFull()
        C_Timer.After(0.25, function()
            self:Countdown()
            if (self.callback ~= nil) then
                self.callback(self)
            end
        end)
    end)
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_ButtonPetReviveTemplate()
    end)
    ---------------------------------------------------------------------------
    --- Catch events and forard to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
