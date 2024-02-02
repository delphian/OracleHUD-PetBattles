--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_PanelChatTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
	self.ShowFull = OracleHUD_FrameShowFull
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
	-- @param db		Oracle HUD Pet Battle database.
	-- @param fontSize	Size of text font.
    function self:Configure(db, fontSize)
        if (db == nil or fontSize == nil) then
            print("OracleHUD_PB_PanelChatTemplate:Configure(): Invalid arguments")
		end
		self.db = db
		self.fontSize = fontSize
		self.Display:Configure(db, 30, 10, fontSize, 4)
		self:OnSizeChanged_PanelChatTemplate()
	end
	---------------------------------------------------------------------------
	--- Add a message to the chat frame. Color is optional and defaults to white.
	-- @param text		Text to display.
	-- @param r			(Optional, defaults to 1.0) Red component of text color.
	-- @param g			(Optional, defaults to 1.0) Green component of text color.
	-- @param b			(Optional, defaults to 1.0) Blue component of text color.
	function self:AddMessage(text, r, g, b)
		if (r == nil) then r = 1.0 end
		if (g == nil) then g = 1.0 end
		if (b == nil) then b = 1.0 end
		self.Display:AddMessage(date("%H:%M").." "..text, r, g, b);
	end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
	function self:OnSizeChanged_PanelChatTemplate()
		if (self.fontSize ~= nil) then
			self.Display:SetSize(self:GetWidth(), self.fontSize + 1)
		end
		self.color:SetSize(self:GetWidth(), self:GetHeight())
	end
	---------------------------------------------------------------------------
    --- Dynamically resize all children elements when frame changes size.
	self:SetScript("OnSizeChanged", function()
		self:OnSizeChanged_PanelChatTemplate()
	end)
	self:RegisterEvent("ZONE_CHANGED")
	self:SetScript("OnEvent", function(event, eventName, ...)
		if (eventName == "ZONE_CHANGED") then
		end
	end)
	self.image:Hide()
end
