--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_ButtonPetBattleForfeitTemplate_OnLoad(self)
    self._class = "OracleHUD_PB_ButtonPetBattleForfeitTemplate"
	self.HideFull = OracleHUD_FrameHideFull
    self.ShowFull = OracleHUD_FrameShowFull
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db		Oracle HUD Pet Battle database.
    -- @param petInfoSvc    OracleHUD PetInfo Service.
    -- @param combatLogSvc  OracleHUD Combat Log Service.
	function self:Configure(db, petInfoSvc, combatLogSvc)
        if (db == nil) then
            print(self._class..":Configure(): Invalid arguments")
		end
        self.db = db
        self.petInfoSvc = petInfoSvc
        self.combatLogSvc = combatLogSvc
    end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    function self:Initialize()
        if (self.db.debug) then print("..Initialize Forfeit Button") end
        self:RegisterForClicks("AnyDown")
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
        if (self.combatLogSvc:IsInBattle()) then
            shouldShow = true
        end
        return shouldShow
    end
    ---------------------------------------------------------------------------
    --- Listen to combat log events
    function self:ListenCombatLog()
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.OPEN, function(loadoutOnOpen)
            self:ShowFull()
        end)
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.CLOSE, function(statsTotal, statsBattle)
            self:HideFull()
        end)
    end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
    function self:OnSizeChanged_ButtonPetBattleForfeitTemplate()
    end
    ---------------------------------------------------------------------------
    --- After button is clicked forfeit the pet battle then execute callback.
    self:SetScript("PostClick", function(self)
        C_PetBattles.ForfeitGame()
        self:HideFull()
        if (self.callback ~= nil) then
            self.callback(self)
        end
    end)
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_ButtonPetBattleForfeitTemplate()
    end)
    ---------------------------------------------------------------------------
    --- Catch events and forard to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
