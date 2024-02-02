--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_ButtonPetSummonTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
	self.ShowFull = OracleHUD_FrameShowFull
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db			Oracle HUD Pet Battle database.
	-- @param slot			Loadout slot this button is located in.
    function self:Configure(db, slot)
		if (db == nil or slot == nil) then
            error("OracleHUD_PB_ButtonPetSummonTemplate:Configure(): Invalid arguments.")
		end
        self.db = db
		self.slot = slot
	end	
	function self:SetCallback(callback)
		self.callback = callback
	end
	---------------------------------------------------------------------------
	--- Set all pet information. Will automatically disseminate info to other 
	--- methods when required.
	--- @param petInfo	OracleHUD_PetInfo		OracleHUD_PB Uniform pet table.
	function self:SetPetInfo(petInfo)
		self.petInfo = petInfo
		self:SetNormalTexture(self.petInfo.icon)
		self:SetPushedTexture(self.petInfo.icon)
		self:SetHighlightTexture(self.petInfo.icon, "ADD")
	end
	---------------------------------------------------------------------------
	--- Summon the pet
	function self:Summon()
		if (self.db == nil) then
			print("OracleHUD_PB_ButtonPetSummonTemplate:OnClick: Configure() must be called first.")
		elseif (self.petInfo == nil) then
			print("OracleHUD_PB_ButtonPetSummonTemplate:Onclick: SetPetInfo() must be called first.")
		else
			C_PetJournal.SummonPetByGUID(self.petInfo.id)
		end
		if (self.callback ~= nil) then
			self.callback(self, self.slot)
		end
	end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
    function self:OnSizeChanged_ButtonPetsummonTemplate()
    end
    ---------------------------------------------------------------------------
    --- Catch button click forward to handler.
	self:SetScript("OnClick", function(self, button, down)
		self:Summon()
	end)
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
		self:OnSizeChanged_ButtonPetsummonTemplate()	
    end)
	self:RegisterForClicks("AnyDown")
end
