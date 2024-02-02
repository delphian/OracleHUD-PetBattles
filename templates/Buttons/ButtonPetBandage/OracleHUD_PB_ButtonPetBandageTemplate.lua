--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_ButtonPetBandageTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
    self.ShowFull = OracleHUD_FrameShowFull
    self.callback = nil
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db		    Oracle HUD Pet Battle database.
    -- @param petInfoSvc    Oracle HUD Pet Info Service.
	-- @param combatLogSvc  OracleHUD CombatLog Service.
	function self:Configure(db, petInfoSvc, combatLogSvc)
        if (db == nil or petInfoSvc == nil) then
            error("OracleHUD_PB_ButtonPetBandageTemplate:Configure(): Invalid arguments.")
		end
        self.db = db
        self.petInfoSvc = petInfoSvc
        self.combatLogSvc = combatLogSvc
    end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    function self:Initialize()
        if (self.db.debug) then print("..Initialize Bandage Button") end
        self:RegisterForClicks("AnyDown")
        self:SetAttribute('type', 'macro')
        self:SetAttribute('macrotext', '/use battle pet bandage')
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
        local allWell = self.petInfoSvc:PetsAllWell(Enum.BattlePetOwner.Ally)
        if (self.combatLogSvc:IsInBattle() == false and allWell == false) then
            shouldShow = true
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
            if (self:ShouldShow() == true) then
                self:ShowFull()
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
    function self:OnSizeChanged_ButtonPetBandageTemplate()
    end
    ---------------------------------------------------------------------------
    --- After button is clicked then hide and execute callback.
    self:SetScript("PostClick", function(self)
        self:HideFull()
        if (self.callback ~= nil) then
            self.callback(self)
        end
    end)
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_ButtonPetBandageTemplate()
    end)
    ---------------------------------------------------------------------------
    --- Catch events and forard to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
