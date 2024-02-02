--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_ButtonPetDebugTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
    self.ShowFull = OracleHUD_FrameShowFull
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db		Oracle HUD Pet Battle database.
    -- @param enumText  ORACLEHUD_PB_DB_PET_ANIMATION_TEXT
	function self:Configure(db, enumText)
        if (db == nil or enumText == nil) then
            error("OracleHUD_PB_ButtonPetDebugTemplate:Configure(): Invalid arguments")
		end
        self.db = db
        self.enumText = enumText
    end
	---------------------------------------------------------------------------
	--- Set all pet information. Will automatically disseminate info to other 
	--- methods when required.
	--- @param petInfo	OracleHUD_PetInfo		OracleHUD_PB Uniform pet table.
    function self:SetPetInfo(petInfo)
        if (petInfo == nil) then
            error("OracleHUD_PB_ButtonPetDebugTemplate:SetPetInfo(): Invalid arguments")
		end
        self.petInfo = petInfo
        self.Model:RefreshCamera()
        self.Model:SetPosition(0, 0, 0)
        self.Model:SetFacing(0)
        self.Model:SetDisplayInfo(self.petInfo.displayId)
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
        if (self.debug == true) then
            shouldShow = true
        end
    end
    ---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
        if (self.db == nil) then
            error("OracleHUD_PB_ButtonPetDebugTemplate:OnEvent(): Configure() must be called first.")
        end
    end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
    function self:OnSizeChanged_ButtonPetDebugTemplate()
    end
    ---------------------------------------------------------------------------
    --- After button is clicked then execute callback.
    self:SetScript("PostClick", function(self)
        if (self.petInfo == nil) then
            error("OracleHUD_PB_ButtonPetDebugTemplate:PostClick(): SetPetInfo() must be called first.")
        end
        print("DEBUG ========================================================")
        if (self.petInfo.id ~= nil) then print("ID: "..self.petInfo.id) end
        print("SPECIES: "..self.petInfo.speciesId)
        print("ICON: "..self.petInfo.icon)
        print("DISPLAY ID: "..self.petInfo.displayId)
        print("ABILITIES:")
        for i = 1, 6 do
            print("    "..
                  "ID: "..self.petInfo.abilities["ability"..i].id.." "..
                  "NAME: "..self.petInfo.abilities["ability"..i].name.." "..
                  "ICON: "..self.petInfo.abilities["ability"..i].icon)
        end
        self.Model:Show()
        print("ANIMATIONS:")
        for i = 0, 1103 do 
            if (self.Model:HasAnimation(i)) then
                print("    "..self.enumText[i], ": ", i)
            end
        end
        self.Model:Hide()
        if (self.callback ~= nil) then
            self.callback(self)
        end
    end)
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_ButtonPetDebugTemplate()
    end)
    ---------------------------------------------------------------------------
    --- Catch events and forard to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
    self:RegisterForClicks("AnyDown")
end
