--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_ButtonPetSwapRandomTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
	self.ShowFull = OracleHUD_FrameShowFull
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param slot			Journal order pet is slotted to.
    -- @param owner			Enum.BattlePetOwner.Ally or Enum.BattlePetOwner.Enemy.
    -- @param db			Oracle HUD Pet Battle database.
    -- @param petInfoSvc    Oracle HUD Pet Info Service.
    function self:Configure(slot, owner, db, petInfoSvc)
        if (slot == nil or owner == nil or db == nil or petInfoSvc == nil) then
            error("OracleHUD_PB_ButtonPetSwapRandomTemplate:Configure(): Invalid arguments.")
		end
        self.slot = slot
        self.owner = owner
        self.db = db
		self.petInfoSvc = petInfoSvc
	end
	function self:SetCallback(callback)
		self.callback = callback
	end
	--- @param petInfo	OracleHUD_PetInfo		OracleHUD_PB Uniform pet table.
	function self:SetPetInfo(petInfo)
		self.petInfo = petInfo
	end
	self:ClearPoint("TOPLEFT")
	---------------------------------------------------------------------------
	--- Slot a random pet.
	self:SetScript("OnClick", function(self, button, down)
		if (self.slot == nil or self.owner == nil or self.db == nil) then
			print("OracleHUD_PB_PetSwapRandomTemplate:OnClick: Configure() must be called first.")
		else
			local petInfo = self.petInfoSvc:GetPetInfoUnslottedRandom()
			C_PetJournal.SetPetLoadOutInfo(self.slot, petInfo.id)
			if (self.callback ~= nil) then
				self.callback(self, petInfo)
			end
		end
	end)
	self:RegisterForClicks("AnyDown")
	---------------------------------------------------------------------------
    --- Dynamically resize all children elements when frame changes size.
    self:SetScript("OnSizeChanged", function()
    end)
end
