--- Tooltip that displays generic pet species information.
--- @class	OracleHUD_PB_TooltipPetInfoContent : OracleHUD_PB_TooltipPetInfoId
--- @field	Left			any			Inherited from mixin XML frame.
--- @field	Content			any			Inherited from mixin XML frame.
OracleHUD_PB_TooltipPetInfoContentMixin = CreateFromMixins({})
OracleHUD_PB_TooltipPetInfoContentMixin._class = "OracleHUD_PB_TooltipPetInfoContentMixin"
--- No supers, we are using composition instead of inheritence.
---------------------------------------------------------------------------
--- Configure mixin with required data.
--- @param db 			OracleHUD_PB_DB	OracleHUD Pet Battles Database.
function OracleHUD_PB_TooltipPetInfoContentMixin:Configure(db)
	if (db == nil) then
		error(self._class":Configure(): Invalid arguments.")
	end
	self.db = db
	self.Left:Configure(db)
	-- Hijack a whole bunch of stuff.
	self.Left.NineSlice:Hide()
	self.Left:SetScript("OnMouseDown", function()
		self:StartMoving()
	end)
	self.Left:SetScript("OnMouseUp", function()
		self:StopMovingOrSizing()
	end)

	self:SetBackdropColor(0, 0, 0, 0.8)
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_TooltipPetInfoContentMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Pet Info Content Tooltip") end
	self.Left:Initialize(callback)
end
-------------------------------------------------------------------------------
--- Set pet information to be displayed.
--- @param petInfo OracleHUD_PB_PetInfo
function OracleHUD_PB_TooltipPetInfoContentMixin:SetPetInfo(petInfo)
	self.petInfo = petInfo
	self.Left:SetPetInfo(petInfo)
	self:OnSizeChanged()
end
-------------------------------------------------------------------------------
--- Copy pet information into fields that are displayed by tooltip.
function OracleHUD_PB_TooltipPetInfoContentMixin:PrintPetInfo()
	self.Left:PrintPetInfo()
end
---------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
function OracleHUD_PB_TooltipPetInfoContentMixin:OnSizeChanged()
	OracleHUD_FrameSetWidthPct(self.Left, 0.5)
	OracleHUD_FrameSetWidthPct(self.Content, 0.5)
end
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_TooltipPetInfoContentMixin:OnLoad()
	self:OnSizeChanged()
end
