--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_ButtonPetBattleTrapTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
    self.ShowFull = OracleHUD_FrameShowFull
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db		Oracle HUD Pet Battle database.
	function self:Configure(db)
        if (db == nil) then
            error("OracleHUD_PB_ButtonPetBattleTrapTemplate:Configure(): Invalid arguments")
		end
        self.db = db
    end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    function self:Initialize()
        self:RegisterEvent("PET_BATTLE_OPENING_START")
        self:RegisterEvent("PET_BATTLE_OVER")
        self:RegisterForClicks("AnyDown")
            if (self:ShouldShow() == true) then
            self:ShowFull()
        else
            self:HideFull()
        end
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
    ---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
        if (eventName == "PET_BATTLE_OPENING_START") then
            self:ShowFull()
        end
        if (eventName == "PET_BATTLE_OVER") then
            self:HideFull()
        end
    end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
    function self:OnSizeChanged_ButtonPetBattleTrapTemplate()
    end
    ---------------------------------------------------------------------------
    --- After button is clicked trap enemy pet then execute callback.
    self:SetScript("PostClick", function(self)
        C_PetBattles.UseTrap()
        self:HideFull()
        C_Timer.After(0.5, function()
            self:ShowFull()
        end)
        if (self.callback ~= nil) then
            self.callback(self)
        end
    end)
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_ButtonPetBattleTrapTemplate()
    end)
    ---------------------------------------------------------------------------
    --- Catch events and forard to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
