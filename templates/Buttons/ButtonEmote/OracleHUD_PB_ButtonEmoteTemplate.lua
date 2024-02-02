--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_ButtonEmoteTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
	self.ShowFull = OracleHUD_FrameShowFull
    self:RegisterForClicks("AnyDown")
	function self:SetCallback(callback)
        self.callback = callback
    end
	self:SetScript("PostClick", function(self)
        if (self.callback ~= nil) then
            self.callback(self)
        end
	end)
    ---------------------------------------------------------------------------
    --- Dynamically resize all children elements when frame changes size.
    self:SetScript("OnSizeChanged", function()
    end)
end
