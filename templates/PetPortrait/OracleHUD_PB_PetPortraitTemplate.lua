--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_PetPortraitTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
    self.ShowFull = OracleHUD_FrameShowFull
    -- Emulate inheritence even though we are composition.
	function self:CanSpeak(...) return self.AnimationBox:CanSpeak(...) end
	function self:Speak(...) return self.AnimationBox:Speak(...) end
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
	-- @param db			Oracle HUD Pet Battle database.
	--- @param  display         OracleHUD_PB_Display
    --- @param  petInfoSvc      OracleHUD_PB_PetInfoService
    --- @param  tooltipPetInfo	OracleHUD_PB_TooltipPetInfo
	function self:Configure(db, display, petInfoSvc, tooltipPetInfo)
        if (db == nil or display == nil or petInfoSvc == nil or tooltipPetInfo == nil) then
            error("OracleHUD_PB_PetPortraitTemplate:Configure(): Invalid arguments.")
		end
		self.db = db
        self.display = display
        self.petInfoSvc = petInfoSvc
        self.tooltipPetInfo = tooltipPetInfo
        self.AnimationBox:Configure(db, display)
    end
   	---------------------------------------------------------------------------
	--- All required resources and data has been loaded, use it.
	function self:Initialize()
        self.AnimationBox:Initialize()
    end
	---------------------------------------------------------------------------
	--- Set all pet information. Will automatically disseminate info to other 
	--- methods when required.
	--- @param petInfo	OracleHUD_PB_PetInfo		OracleHUD_PB Uniform pet table.
    function self:SetPetInfo(petInfo)
        if (petInfo == nil) then
            error("OracleHUD_PB_PanelPetLoadoutSlotTemplate:SetPetInfo(): Invalid arguments")
        end
        self.petInfo = petInfo
		self.AnimationBox:SetPetInfo(self.petInfo)
		self.Type:SetType(self.petInfo.type)
		self.Level.font:SetText(petInfo.level)
        for i = 1, 3 do
            self.Collected["Slot"..i]:Hide()
        end
        local collected = self.petInfoSvc:GetPetInfoCollected(petInfo.name)
        if (collected ~= nil) then
            for i = 1, #collected do
                local text = self.petInfoSvc:WrapTextWithRarityColor("0", collected[i].rarity)
                self.Collected["Slot"..i]:SetText(text)
                self.Collected["Slot"..i]:Show()
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Play a specific animation sequence.
    -- @param animation    @see OracleHUD_PB_DB_PetAnimation
    function self:SetAnimation(animation)
        self.AnimationBox:SetAnimation(animation)
    end
    ---------------------------------------------------------------------------
    --- Set the frame highlight
    -- @param active        The pet is the active pet on battlefield.
    function self:SetActive(active)
        if (active == true) then
            self.border:SetAlpha(1.0)
        else
            self.border:SetAlpha(0.6)
        end
    end
    ---------------------------------------------------------------------------
    --- Dynamically resize all children elements when frame changes size.
    function self:OnSizeChanged_PetPortraitTemplate()
        self:SetWidth(self:GetHeight() * 1.2)
        OracleHUD_FrameSetHeightSquarePct(self.AnimationBox, 1.00)
        -- Level
        OracleHUD_FrameSetWidthSquarePct(self.Level, 0.35)
        local point, relativeTo, relativePoint, xOfs, yOfs = self.Level:GetPoint()
        self.Level:SetPoint(
            point,
            relativeTo,
            relativePoint,
            self.Level:GetWidth() * -0.0,
            self.Level:GetHeight() * -0.0)
        OracleHUD_FrameSetWidthSquarePct(self.Level.font, 0.75)
        local ratio = self.Level:GetWidth() / 22
        local fontSize = math.max(9 * ratio, 4)
        local font, size, flags = self.Level.font:GetFont()
        self.Level.font:SetFont(font, fontSize, flags)
        -- Type
        OracleHUD_FrameSetWidthSquarePct(self.Type, 0.30)
        point, relativeTo, relativePoint, xOfs, yOfs = self.Type:GetPoint()
        self.Type:SetPoint(
            point,
            relativeTo,
            relativePoint,
            self.Type:GetWidth() * -0.0,
            self.Type:GetHeight() * 0.0)
    end
    self:SetScript("OnMouseDown", function()
        self.tooltipPetInfo:SetPetInfo(self.petInfo)
        self.tooltipPetInfo:ShowFull()
    end)
    ---------------------------------------------------------------------------
    --- Dynamically resize all children elements when frame changes size.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_PetPortraitTemplate()
    end)
    self.Level.image:SetAlpha(0.25)
end
