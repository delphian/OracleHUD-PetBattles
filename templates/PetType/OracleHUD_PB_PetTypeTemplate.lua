--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_PetTypeTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
	self.ShowFull = OracleHUD_FrameShowFull
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db		Oracle HUD Pet Battle database.
	function self:Configure(db)
        if (db == nil) then
            print("OracleHUD_PB_TooltipPetInfoSpeciesTemplate:Configure(): Invalid arguments")
		end
		self.db = db
	end
	---------------------------------------------------------------------------
	--- Set the pet type and change icon.
	-- @param petType		Type of pet (integer)
	function self:SetType(petType)
		self.petType = petType
		self.Icon:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petType])
	end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
	function self:OnSizeChanged_PetTypeTemplate()
	end
	---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_PetTypeTemplate()
    end)
	self:OnSizeChanged_PetTypeTemplate()
end