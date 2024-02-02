--- Called by XML onload.
-- @param self      Our main XML frame.
-- @param db		Oracle HUD Pet Battle database.
function OracleHUD_PB_PetExperienceTemplate_OnLoad(self, db)
    self.db = db
    ---------------------------------------------------------------------------
    --- Dynamically resize all children elements when frame changes size.
    self:SetScript("OnSizeChanged", function()
        self.Experience:SetSize(self:GetWidth(), self:GetHeight());
    end)
    ---------------------------------------------------------------------------
    --- Set the percentage value of the experience bar.
    -- @param experiencePct Experience of the pet in percentage (0-100)
    function self:SetExperience(experiencePct)
        self.Experience:SetValue(experiencePct)
    end
end
