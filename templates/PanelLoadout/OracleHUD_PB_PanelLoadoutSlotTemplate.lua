--- Called by XML onload.
-- @param self      Our main XML frame.
-- @param db		Oracle HUD Pet Battle database.
function OracleHUD_PB_PanelLoadoutSlotTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
    self.ShowFull = OracleHUD_FrameShowFull
    -- Emulate inheritence even though we are composition.
	function self:CanSpeak(...) return self.Left:CanSpeak(...) end
	function self:Speak(...) return self.Left:Speak(...) end
    ---------------------------------------------------------------------------
	--- Configure frame with required data.
	-- @param db			Oracle HUD Pet Battle database.
	-- @param chat			Oracle HUD primary text output frame.
    -- @param slot          Journal slot of this frame.
	-- @param owner			Enum.BattlePetOwner.Ally or Enum.BattlePetOwner.Enemy.
	-- @param network		Oracle HUD Addon network communications.
    -- @param petAnimEnum	ORACLEHUD_PB_DB_PET_ANIMATION_ENUM
	-- @param zoo			(Optional) Frame of the zoo.
	--- @param petInfoSvc	OracleHUD_PB_PetInfoService
	--- @param tooltipPetInfo	OracleHUD_PB_TooltipPetInfo
	function self:Configure(db, display, slot, owner, network, petAnimEnum, zoo, petInfoSvc, tooltipPetInfo)
		if (db == nil or display == nil or slot == nil or owner == nil or
			network == nil or petAnimEnum == nil or petInfoSvc == nil or tooltipPetInfo == nil)
		then
            error("OracleHUD_PB_PanelLoadoutSlotTemplate:Configure(): Invalid arguments")
		end
		self.db = db
		self.display = display
		self.slot = slot
		self.owner = owner
		self.network = network
		self.petAnimEnum = petAnimEnum
		self.zoo = zoo
		self.petInfoSvc = petInfoSvc
		self.Left:Configure(db, display, petInfoSvc, tooltipPetInfo)
	end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded, use it.
	function self:Initialize()
		self.Left:Initialize()
		if (self.owner == Enum.BattlePetOwner.Enemy) then
			self.Right.Name.color:SetColorTexture(0.4, 0.0, 0.0, 0.4)
		end
	end
	---------------------------------------------------------------------------
	--- Set all pet information. Will automatically disseminate info to other 
	--- methods when required.
	--- @param petInfo	OracleHUD_PB_PetInfo		OracleHUD_PB Uniform pet table.
    function self:SetPetInfo(petInfo)
        if (petInfo == nil) then
            error("OracleHUD_PB_PanelLoadoutSlotTemplate:SetPetInfo(): Invalid arguments")
		end
        if (self.owner == nil) then
            error("OracleHUD_PB_PanelLoadoutSlotTemplate:SetPetInfo(): Configure() must be called first.")
		end
		self.petInfo = petInfo
		local name = self.petInfoSvc:WrapTextWithRarityColor(petInfo.name, petInfo.rarity)
		self:SetName(name)
		self:SetLevel(petInfo.level)
		self:SetHealth(petInfo.health, petInfo.healthMax)
		self:SetExperience(petInfo.experience)
		if (self.owner == Enum.BattlePetOwner.Enemy) then
			self.Right.ExperienceBar:Hide()
		else
			self.Right.ExperienceBar:Show()
		end
	end
	function self:SetName(name)
		self.Right.Name.Font:SetText(name)
	end
	function self:SetLevel(level)
		self.petInfo.level = level
		self.petInfo.experienceMax = OracleHUD_PB_DB_PetExperienceGetMax(level)
		self.Left:SetPetInfo(self.petInfo)
	end
	function self:SetExperience(experience, max)
		if (self.owner == Enum.BattlePetOwner.Ally) then
			self.petInfo.experience = experience
			local pct = math.floor((self.petInfo.experience / self.petInfo.experienceMax) * 100)
			self.Right.ExperienceBar:SetExperience(pct)
		end
	end
	function self:SetAnimation(animation)
		self.Left:SetAnimation(animation)
	end
	function self:SetLoss(health)
		local pct = math.floor((health / self.petInfo.healthMax) * 100)
		self.Right.HealthBar:SetLoss(pct)
	end
	function self:SetHealth(health, max)
		if (self.petInfo.health == 0 and health > 0) then
			self:SetAnimation(self.petAnimEnum.STAND)
		elseif (health == 0) then
			self:SetAnimation(self.petAnimEnum.DEATH)
		end	
		self.petInfo.health = health
		local pct = math.floor((self.petInfo.health / self.petInfo.healthMax) * 100)
		self.Right.HealthBar:SetHealth(pct)
	end
    ---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
	end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
    function self:OnSizeChanged_PanelLoadoutSlotTemplate()
		OracleHUD_FrameSetHeightSquarePct(self.Left, 1.00)
		OracleHUD_FrameSetHeightPct(self.Right, 1.0)
		OracleHUD_FrameSetHeightPct(self.Right.Name, 0.3333)
		OracleHUD_FrameSetSizePct(self.Right.ButtonsBorder.Buttons, 0.95, 0.80)
		self.color:SetSize(self:GetWidth(), self:GetHeight());
        self.Right.color:SetSize(self.Right:GetWidth(), self.Right:GetHeight());
	end
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:SetScript("OnSizeChanged", function()
		self:OnSizeChanged_PanelLoadoutSlotTemplate()
	end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
