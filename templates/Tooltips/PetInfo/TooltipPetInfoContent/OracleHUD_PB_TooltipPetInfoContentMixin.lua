--- Tooltip that displays generic pet species information.
--- @class	OracleHUD_PB_TooltipPetInfoContent : OracleHUD_PB_TooltipPetInfoId
--- @field	Left			any			Inherited from mixin XML frame.
--- @field	Right			any			Inherited from mixin XML frame.
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
	self.Right.EditBox:Configure(db)
	self.Right.MenuButton:Configure(db)
	-- Hijack a whole bunch of stuff to simulate an integrated tooltip.
	self.Left.NineSlice:Hide()
	self.Left:SetScript("OnMouseDown", function()
		self:StartMoving()
	end)
	self.Left:SetScript("OnMouseUp", function()
		self:StopMovingOrSizing()
	end)
	self.Left.CloseButton:Hide()
	self.Left.PetType:ClearAllPoints()
	self.Left.PetType:SetPoint("TOPRIGHT", self.Left, "TOPRIGHT", 0, -12)
	--
	self:SetBackdropColor(0, 0, 0, 0.8)
	self.emoteEnum = ORACLEHUD_PB_CONTENTEMOTE_ENUM.SPEAK
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_TooltipPetInfoContentMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Pet Info Content Tooltip") end
	self.Right.EditBox:SetSubmitCallback(function(editbox, content)
		local emotesTable = json.parse(content)
		if (emotesTable ~= nil) then
			if (self.petInfo.content == nil) then self.petInfo.content = {} end
			if (self.petInfo.content.emotes == nil) then self.petInfo.content.emotes = {} end
			self.petInfo.content.emotes[self.emoteEnum] = emotesTable
		end
		self:PrintPetInfo()
	end)
	local TEXT = ORACLEHUD_PB_CONTENTEMOTE_TEXT
	local ENUM = ORACLEHUD_PB_CONTENTEMOTE_ENUM
	self.Right.EditBox:SetCancelCallback(function(editbox, content)
		print("CANCEL")
	end)
	self.Right.MenuButton:SetMenuItem(TEXT[ENUM.SPEAK], function(frame, button)
		self.Right.MenuText:SetText(TEXT[ENUM.SPEAK])
		self.emoteEnum = ENUM.SPEAK
		self:PrintPetInfo()
	end)
	self.Right.MenuButton:SetMenuItem(TEXT[ENUM.SPEAK_WIN], function(frame, button)
		self.Right.MenuText:SetText(TEXT[ENUM.SPEAK_WIN])
		self.emoteEnum = ENUM.SPEAK_WIN
		self:PrintPetInfo()
	end)
	self.Right.MenuButton:SetMenuItem(TEXT[ENUM.SPEAK_LOSS], function(frame, button)
		self.Right.MenuText:SetText(TEXT[ENUM.SPEAK_LOSS])
		self.emoteEnum = ENUM.SPEAK_LOSS
		self:PrintPetInfo()
	end)
	self.Right.MenuButton:SetMenuItem(TEXT[ENUM.EMOTE], function(frame, button)
		self.Right.MenuText:SetText(TEXT[ENUM.EMOTE])
		self.emoteEnum = ENUM.EMOTE
		self:PrintPetInfo()
	end)
	self.Right.MenuButton:SetMenuItem(TEXT[ENUM.EMOTE_SUMMON], function(frame, button)
		self.Right.MenuText:SetText(TEXT[ENUM.EMOTE_SUMMON])
		self.emoteEnum = ENUM.EMOTE_SUMMON
		self:PrintPetInfo()
	end)
	function InitMenuButton() 	self.Right.MenuButton:Initialize(InitEmbedTooltip) 		end
	function InitEmbedTooltip() self.Left:Initialize(InitEditBox) 						end
	function InitEditBox()		self.Right.EditBox:Initialize(InitFinished) 			end
	function InitFinished()
		self.Right.MenuText:SetText(TEXT[ENUM.SPEAK])
		self.Right.MenuButton:SetSize(32, 32)
		self.Right.MenuButton:ClearAllPoints()
		self.Right.MenuButton:SetPoint("TOPRIGHT", self.Right, "TOPRIGHT", -48, -18)
		self.Right.MenuButton:Show()
		self.Right.MenuButton:ShowFull()
		if (callback ~= nil) then
			callback()
		end
	end
	InitMenuButton()
end
-------------------------------------------------------------------------------
--- Set pet information to be displayed.
--- @param petInfo OracleHUD_PB_PetInfo
function OracleHUD_PB_TooltipPetInfoContentMixin:SetPetInfo(petInfo)
	self.petInfo = petInfo
	self.Left:SetPetInfo(petInfo)
	self:PrintPetInfo()
	self:OnSizeChanged()
end
-------------------------------------------------------------------------------
--- Copy pet information into fields that are displayed by tooltip.
function OracleHUD_PB_TooltipPetInfoContentMixin:PrintPetInfo()
	self.Left:PrintPetInfo()
	if (self.petInfo.content ~= nil and self.petInfo.content.emotes ~= nil and
		self.petInfo.content.emotes[self.emoteEnum] ~= nil)
	then
		self.Right.EditBox.Scroll.Box:SetText(json.stringify(self.petInfo.content.emotes[self.emoteEnum]))
	else
		self.Right.EditBox.Scroll.Box:SetText("[\n\n]")
	end
end
---------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
function OracleHUD_PB_TooltipPetInfoContentMixin:OnSizeChanged()
	OracleHUD_FrameSetWidthPct(self.Left, 0.4)
	OracleHUD_FrameSetWidthPct(self.Right, 0.6)
end
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_TooltipPetInfoContentMixin:OnLoad()
	self:OnSizeChanged()
end
