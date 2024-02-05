--- @class  OracleHUD_PB_TooltipPetInfo : OracleHUD_PB_Tooltip
--- @field	GetHeight		function	Inherited from mixin XML frame.
--- @field	JournalClick	any			Inherited from mixin XML frame.
--- @field	Name			any			Inherited from mixin XML frame.
--- @field	SpeciesId		any			Inherited from mixin XML frame.
--- @field	PetType			any			Inherited from mixin XML frame.
--- @field	PetTypeTexture	any			Inherited from mixin XML frame.
--- @field	Owned			any			Inherited from mixin XML frame.
--- @field	Animation		any			Inherited from mixin XML frame.
OracleHUD_PB_TooltipPetInfoMixin = CreateFromMixins(OracleHUD_PB_TooltipMixin)
OracleHUD_PB_TooltipPetInfoMixin._class = "OracleHUD_PB_TooltipPetInfoMixin"
--- Create Supers (this seems weird)
local Super = OracleHUD_PB_TooltipMixin
-------------------------------------------------------------------------------
--- Configure mixin with required data.
--- @param db 			OracleHUD_PB_DB	OracleHUD Pet Battles Database.
function OracleHUD_PB_TooltipPetInfoMixin:Configure(db)
	if (db == nil) then
		error(self._class":Configure(): Invalid arguments.")
	end
	Super.Configure(self, db)
end
-------------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_TooltipPetInfoMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Pet Info Tooltip") end
	self.originalHeight = self:GetHeight()
	if (self.originalHeight == nil) then error(self._class..":Initialize(): Original height is nil") end
	self.JournalClick:RegisterForClicks("AnyDown")
	Super.Initialize(self, callback)
end
-------------------------------------------------------------------------------
--- Set pet information to be displayed by tooltip.
--- @param petInfo OracleHUD_PB_PetInfo
function OracleHUD_PB_TooltipPetInfoMixin:SetPetInfo(petInfo)
    if (petInfo == nil) then
        error(self._class..":SetPetInfo(): Invalid parameters.")
    end
    self.petInfo = petInfo
	self:PrintPetInfo()
end
-------------------------------------------------------------------------------
--- Copy pet information into fields that are displayed by tooltip.
function OracleHUD_PB_TooltipPetInfoMixin:PrintPetInfo()
	local petInfo = self.petInfo
	self.textLineAnchor = nil
	self:Show()
	self.linePool:ReleaseAll()
	self:SetHeight(self.originalHeight)
	self.speciesID = petInfo.speciesId; -- For the button
	self.Name:SetText(petInfo.name);
	self.SpeciesId:SetText(petInfo.speciesId)
	self.PetType:SetText(_G["BATTLE_PET_NAME_"..petInfo.type])
	self.PetTypeTexture:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petInfo.type])
	local text = C_PetJournal.GetOwnedBattlePetString(petInfo.speciesId)
	if (text == nil) then text = "None collected!" end
	self.Owned:SetText(text)
	self.Animation:SetPetInfo(petInfo)
	self.originalHeight = self:GetHeight()
	self:AddTextLine(petInfo.tooltip, 1, 1, 1, true, self.Animation)
	self:AddTextLine(petInfo.description, 1, 1, 1, true, self.Animation)
end
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_TooltipPetInfoMixin:OnLoad()
    Super.OnLoad(self)
end