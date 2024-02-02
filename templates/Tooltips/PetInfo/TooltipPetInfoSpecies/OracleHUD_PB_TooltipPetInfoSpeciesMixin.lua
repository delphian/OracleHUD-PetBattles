--- Tooltip that displays generic pet species information.
--- @class	OracleHUD_PB_TooltipPetInfoSpecies : OracleHUD_PB_TooltipPetInfo
--- @field	Name			any			Inherited from mixin XML frame.
--- @field	Animation		any			Inherited from mixin XML frame.
--- @field	JournalClick	any			Inherited from mixin XML frame.
--- @field	Owned			any			Inherited from mixin XML frame.
--- @field	PetType			any			Inherited from mixin XML frame.
--- @field	PetTypeTexture	any			Inherited from mixin XML frame.
--- @field	SpeciesId		any			Inherited from mixin XML frame.
OracleHUD_PB_TooltipPetInfoSpeciesMixin = CreateFromMixins(OracleHUD_PB_TooltipPetInfoMixin)
OracleHUD_PB_TooltipPetInfoSpeciesMixin._class = "OracleHUD_PB_TooltipPetInfoSpeciesMixin"
--- Create Supers (this seems weird)
local Super = OracleHUD_PB_TooltipPetInfoMixin
---------------------------------------------------------------------------
--- Configure mixin with required data.
--- @param db 			OracleHUD_PB_DB	OracleHUD Pet Battles Database.
function OracleHUD_PB_TooltipPetInfoSpeciesMixin:Configure(db)
	if (db == nil) then
		error(self._class":Configure(): Invalid arguments.")
	end
	Super.Configure(self, db)
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_TooltipPetInfoSpeciesMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Pet Info Species Tooltip") end
	Super.Initialize(self, callback)
end
-------------------------------------------------------------------------------
--- Set pet information to be displayed.
--- @param petInfo OracleHUD_PB_PetInfo
function OracleHUD_PB_TooltipPetInfoSpeciesMixin:SetPetInfo(petInfo)
	Super.SetPetInfo(self, petInfo)
	self:OnSizeChanged()
end
-------------------------------------------------------------------------------
--- Copy pet information into fields that are displayed by tooltip.
function OracleHUD_PB_TooltipPetInfoSpeciesMixin:PrintPetInfo()
	Super.PrintPetInfo(self)
end
---------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
function OracleHUD_PB_TooltipPetInfoSpeciesMixin:OnSizeChanged()
	if (self.onSizeChanged ~= true) then
		OracleHUD_FrameSetWidthSquarePct(self.Animation, 1.0)
		if (self.petInfo ~= nil) then
			local positions = OracleHUD_PB_DB_AnimationGetPosition(self.petInfo.speciesId)
			if (positions ~= nil and positions.default ~= nil and positions.default.hRatio ~= nil) then
				local newHeight = self.Animation:GetHeight() * positions.default.hRatio
				local newHeightDiff = newHeight - self.Animation:GetHeight()
				self.Animation:SetHeight(newHeight)
				self.onSizeChanged = true
				--	self:SetHeight(self:GetHeight() + newHeightDiff)
			end
		end
	else
		self.onSizeChanged = false
	end
end
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_TooltipPetInfoSpeciesMixin:OnLoad()
	Super.OnLoad(self)
	---------------------------------------------------------------------------
    --- View pet in pet journal.
	self.JournalClick:HookScript("PostClick", function()
		PetJournal_SelectSpecies(PetJournal, self.petInfo.speciesId)
	end)
	---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:HookScript("OnSizeChanged", function()
        self:OnSizeChanged()
    end)
	self:OnSizeChanged()
end
