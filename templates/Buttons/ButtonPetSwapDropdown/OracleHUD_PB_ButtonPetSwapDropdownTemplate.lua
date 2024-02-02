--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_ButtonPetSwapDropdownTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
	self.ShowFull = OracleHUD_FrameShowFull
	-- https://wowpedia.fandom.com/wiki/Using_UIDropDownMenu
	OracleHUD_UIDropDownMenu_SetWidth(self, 1)
	OracleHUD_UIDropDownMenu_Initialize(self, function(frame, level, menuList)
		local info = OracleHUD_UIDropDownMenu_CreateInfo();
		info.text = "Slot Lowest Level";
		info.arg1 = self;
		info.func = self.SlotRandomLowLevel;
		OracleHUD_UIDropDownMenu_AddButton(info, 1);
		info.text = "Slot Lowest in Zone";
		info.arg1 = self;
		info.func = self.SlotRandomLowLevelZone;
		OracleHUD_UIDropDownMenu_AddButton(info, 1);
		info.text = "Slot Random in Zone";
		info.arg1 = self;
		info.func = self.SlotRandomZone;
		OracleHUD_UIDropDownMenu_AddButton(info, 1);
		info.text = "Send to Zoo";
		info.arg1 = self;
		info.func = self.SendToZoo;
		OracleHUD_UIDropDownMenu_AddButton(info, 1);
	end)
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param slot		Journal order pet is slotted to.
    -- @param owner		Enum.BattlePetOwner.Ally or Enum.BattlePetOwner.Enemy.
	-- @param db		Oracle HUD Pet Battle database.
	-- @param zoo		Frame of the zoo.
	-- @param options		OracleHUD Interface Options.
    function self:Configure(slot, owner, db, zoo, petInfoSvc, options)
		if (db == nil or slot == nil or petInfoSvc == nil or options == nil) then
            error("OracleHUD_PB_ButtonPetSwapDropdownTemplate:Configure(): Invalid arguments.")
		end
        self.slot = slot
        self.owner = owner
		self.db = db
		self.zoo = zoo
		self.petInfoSvc = petInfoSvc
		self.options = options
	end
	function self:SetCallback(callback)
		self.callback = callback
	end
	--- @param petInfo	OracleHUD_PetInfo		OracleHUD_PB Uniform pet table.
	function self:SetPetInfo(petInfo)
		self.petInfo = petInfo
	end
	function self:SendToZoo(self)
		self.options:SetZooShow(true)
		self.zoo:RequestAdoptPet(self.petInfo)
	end
	function self:SlotRandomLowLevel(arg1)
		local self = arg1
		if (self.slot == nil or self.owner == nil or self.db == nil) then
			print("OracleHUD_PB_PetSwapDropdownTemplate:OnClick: Configure() must be called first.")
		else
			local petInfo = self.petInfoSvc:GetPetInfoByUnslottedLowest()
			C_PetJournal.SetPetLoadOutInfo(self.slot, petInfo.id)
			if (self.callback ~= nil) then
				self.callback(self, petInfo)
			end
		end
	end
	function self:SlotRandomLowLevelZone(arg1)
		local self = arg1
		if (self.slot == nil or self.owner == nil or self.db == nil) then
			print("OracleHUD_PB_PetSwapDropdownTemplate:OnClick: Configure() must be called first.")
		else
			local petInfo = self.petInfoSvc:GetPetInfoByUnslottedLowestZone(GetZoneText())
			C_PetJournal.SetPetLoadOutInfo(self.slot, petInfo.id)
			if (self.callback ~= nil) then
				self.callback(self, petInfo)
			end
		end
	end
	function self:SlotRandomZone(arg1)
		local self = arg1
		if (self.slot == nil or self.owner == nil or self.db == nil) then
			print("OracleHUD_PB_PetSwapDropdownTemplate:OnClick: Configure() must be called first.")
		else
			local petInfo = self.petInfoSvc:GetPetInfoByUnslottedRandomZone(GetZoneText())
			C_PetJournal.SetPetLoadOutInfo(self.slot, petInfo.id)
			if (self.callback ~= nil) then
				self.callback(self, petInfo)
			end
		end
	end
	self:ClearPoint("TOPLEFT")
	---------------------------------------------------------------------------
	--- Slot a random low level pet.
	self:SetScript("OnClick", function(self, button, down)
	end)
	self:RegisterForClicks("AnyDown")
	---------------------------------------------------------------------------
    --- Dynamically resize all children elements when frame changes size.
    self:SetScript("OnSizeChanged", function()
		self.Left:SetSize(self:GetWidth(), self:GetHeight());
		self.Button:SetSize(self:GetWidth(), self:GetHeight());
		self.Button.NormalTexture:SetSize(self:GetWidth(), self:GetHeight());
		self.Button.PushedTexture:SetSize(self:GetWidth(), self:GetHeight());
		self.Button.DisabledTexture:SetSize(self:GetWidth(), self:GetHeight());
		self.Button.HighlightTexture:SetSize(self:GetWidth(), self:GetHeight());
		self.Icon:SetSize(self:GetWidth(), self:GetHeight());
	end)
end
