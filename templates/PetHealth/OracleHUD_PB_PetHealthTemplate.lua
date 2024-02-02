--- Called by XML onload.
-- @param self      Our main XML frame.
-- @param db		Oracle HUD Pet Battle database.
function OracleHUD_PB_PetHealthTemplate_OnLoad(self, db)
    self.db = db
    ---------------------------------------------------------------------------
    --- Dynamically resize all children elements when frame changes size.
    self:SetScript("OnSizeChanged", function()
        self.Health:SetSize(self:GetWidth(), self:GetHeight());
        self.HealthLoss:SetSize(self:GetWidth(), self:GetHeight());
    end)
    ---------------------------------------------------------------------------
    --- Set the percentage value of the health bar.
    -- @param healthPct     Health of the pet in percentage (0-100)
    function self:SetHealth(healthPct)
        self.Health:SetValue(healthPct)
    end
    ---------------------------------------------------------------------------
    --- Set the percentage value of the loss bar.
    -- @param healthPct     Health of the pet in percentage (0-100)
    function self:SetLoss(healthPct)
        self.HealthLoss:SetValue(healthPct)
    end
end