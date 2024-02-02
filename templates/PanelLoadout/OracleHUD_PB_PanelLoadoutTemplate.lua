--- Generic pet loudout (a collection of pets). This is inherited by
--- the Pet Battle Loadout.

--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_PanelLoadoutTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
    self.ShowFull = OracleHUD_FrameShowFull
    self.slotIndex = 1
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db			Oracle HUD Pet Battle database.
    -- @param c_petjournal	Wow's C_PetJournal or a mocked version.
	function self:Configure(db, c_petjournal)
        if (db == nil or c_petjournal == nil) then
            error("OracleHUD_PB_PanelLoadoutTemplate:Configure(): Invalid arguments")
		end
        self.db = db
        self.c_petjournal = c_petjournal
    end
    ---------------------------------------------------------------------------
    --- Get the next slot index to be assigned.
    function self:GetSlotIndex()
        return self.slotIndex
    end
    ---------------------------------------------------------------------------
    --- If the currently summoned pet is loaded into a slot, return the slot number.
    function self:GetSummonedSlot()
        local summonedSlot = nil
        local summonedPetId = self.c_petjournal.GetSummonedPetGUID()
        if (summonedPetId ~= nil) then
            if (self:GetSlotIndex() > 1) then
                for i = 1, (self:GetSlotIndex() - 1) do
                    if (self["Slot"..i].petInfo ~= nil and summonedPetId == self["Slot"..i].petInfo.id) then
                        summonedSlot = i
                        break
                    end
                end
            end
        end
        return summonedSlot
    end
    ---------------------------------------------------------------------------
    --- Add an already created loadout slot frame
    -- @param panelLoadoutSlot  A frame which inherits from PanelLoadoutSlotTemplate
    function self:AddSlot(panelLoadoutSlot)
        panelLoadoutSlot:SetParent(self)
        self["Slot"..self:GetSlotIndex()] = panelLoadoutSlot
        panelLoadoutSlot:ClearAllPoints()
        if (self:GetSlotIndex() == 1) then
            panelLoadoutSlot:SetPoint("TOP", self, "TOP")
            panelLoadoutSlot:SetPoint("LEFT", self, "LEFT")
            panelLoadoutSlot:SetPoint("RIGHT", self, "RIGHT")
        else
            local previousSlot = self["Slot"..(self:GetSlotIndex() - 1)]
            panelLoadoutSlot:SetPoint("TOP", previousSlot, "BOTTOM")
            panelLoadoutSlot:SetPoint("LEFT", self, "LEFT")
            panelLoadoutSlot:SetPoint("RIGHT", self, "RIGHT")
        end
        self.slotIndex = self:GetSlotIndex() + 1
        self:OnSizeChanged_PanelLoadoutTemplate()
    end
    ---------------------------------------------------------------------------
    --- Load a pet into a slot.
	--- @param petInfo	OracleHUD_PB_PetInfo		OracleHUD_PB Uniform pet table.
    -- @param slot      Slot number to load pet into.
    function self:SetPetInfo(petInfo, slot)
        if (petInfo == nil or slot == nil) then
            error("OracleHUD_PB_PanelLoadoutTemplate:SetPetInfo(): Invalid arguments")
		end
        self["Slot"..slot]:SetPetInfo(petInfo)
    end
    ---------------------------------------------------------------------------
    --- Register a callback that will be executed when events happen.
    function self:SetCallback(callback)
        self.callback = callback
    end
    ---------------------------------------------------------------------------
    --- Visually revive pets in all battle slots of loadout.
	function self:Revive()
        for i = 1, (self.slotIndex - 1) do
            local slot = self["Slot"..i]
			slot:SetHealth(slot.petInfo.healthMax, slot.petInfo.healthMax)
		end
	end
    ---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
    end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
    function self:OnSizeChanged_PanelLoadoutTemplate()
        if (self.slotIndex > 1) then
            for i = 1, (self.slotIndex - 1) do
                OracleHUD_FrameSetSizePct(self["Slot"..i], 1.0, 0.3333)
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_PanelLoadoutTemplate()
    end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
