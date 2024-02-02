--- Tooltip that displays generic pet species information.
--- @class	OracleHUD_PB_TooltipPetInfoId : OracleHUD_PB_TooltipPetInfoSpecies
--- @field	Health			any			Inherited from mixin XML frame.
--- @field	Speed			any			Inherited from mixin XML frame.
--- @field	Power			any			Inherited from mixin XML frame.
--- @field	Level			any			Inherited from mixin XML frame.
OracleHUD_PB_TooltipPetInfoIdMixin = CreateFromMixins(OracleHUD_PB_TooltipPetInfoSpeciesMixin)
OracleHUD_PB_TooltipPetInfoIdMixin._class = "OracleHUD_PB_TooltipPetInfoSpeciesMixin"
--- Create Supers (this seems weird)
local Super = OracleHUD_PB_TooltipPetInfoSpeciesMixin
---------------------------------------------------------------------------
--- Configure mixin with required data.
--- @param db 			OracleHUD_PB_DB	OracleHUD Pet Battles Database.
function OracleHUD_PB_TooltipPetInfoIdMixin:Configure(db)
	if (db == nil) then
		error(self._class":Configure(): Invalid arguments.")
	end
	Super.Configure(self, db)
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_TooltipPetInfoIdMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Pet Info Id Tooltip") end
	Super.Initialize(self, callback)
end
-------------------------------------------------------------------------------
--- Set pet information to be displayed.
--- @param petInfo OracleHUD_PB_PetInfo
function OracleHUD_PB_TooltipPetInfoIdMixin:SetPetInfo(petInfo)
	Super.SetPetInfo(self, petInfo)
	self:OnSizeChanged()
end
-------------------------------------------------------------------------------
--- Copy pet information into fields that are displayed by tooltip.
function OracleHUD_PB_TooltipPetInfoIdMixin:PrintPetInfo()
	Super.PrintPetInfo(self)
	self.Level:SetText(self.petInfo.level)
	self.Health:SetText(self.petInfo.health)
	self.Power:SetText(self.petInfo.power)
	self.Speed:SetText(self.petInfo.speed)
end
---------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
function OracleHUD_PB_TooltipPetInfoIdMixin:OnSizeChanged()
	Super.OnSizeChanged(self)
end
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_TooltipPetInfoIdMixin:OnLoad()
	Super.OnLoad(self)
	self:OnSizeChanged()
end
