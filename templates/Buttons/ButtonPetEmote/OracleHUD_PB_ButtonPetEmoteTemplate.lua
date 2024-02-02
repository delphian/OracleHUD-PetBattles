--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_ButtonPetEmoteTemplate_OnLoad(self)
    self.HideFull = OracleHUD_FrameHideFull
    self.ShowFull = OracleHUD_FrameShowFull
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db			Oracle HUD Pet Battle database.
	-- @param slot			Loadout slot this button is located in.
    function self:Configure(db, slot)
        if (db == nil or slot == nil) then
            error("OracleHUD_PB_ButtonPetEmoteTemplate:Configure(): Invalid arguments.")
		end
        self.db = db
        self.slot = slot
    end
    ---------------------------------------------------------------------------
    --- Register a callback that will be executed when the button is clicked.
    function self:SetCallback(callback)
        self.callback = callback
    end
	--- @param petInfo	OracleHUD_PB_PetInfo		OracleHUD_PB Uniform pet table.
    function self:SetPetInfo(petInfo)
        if (petInfo == nil) then
            error("OracleHUD_PB_ButtonPetEmoteTemplate:SetPetInfo(): Invalid arguments.")
		end
        self.petInfo = petInfo
	end
	self:SetScript("PostClick", function()
        local emote = self.petInfo:GetEmote("speak|emote")
        SendChatMessage(emote, "EMOTE")
        if (self.callback ~= nil) then
            self.callback(self, self.slot)
        end
	end)
    ---------------------------------------------------------------------------
    --- Dynamically resize all children elements when frame changes size.
    self:SetScript("OnSizeChanged", function()
    end)
    self:RegisterForClicks("AnyDown")
end