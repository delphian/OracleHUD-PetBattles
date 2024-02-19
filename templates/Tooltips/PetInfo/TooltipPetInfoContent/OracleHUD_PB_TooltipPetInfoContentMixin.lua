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
	self.Right.Tabs:Configure(db)
	self.Right.Tabs.Quips.EditBox:Configure(db)
	self.Right.Tabs.Quips.MenuButton:Configure(db)
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
	self.Left:SetBackdropColor(0, 0, 0, 0.95)
	-- Change layout of the edit box.
	self.Right.Tabs.Quips.EditBox.Cancel:Hide()
	self.Right.Tabs.Quips.EditBox.Submit:SetText("Update")
	self.Right.Tabs.Quips.EditBox.Submit:ClearAllPoints()
	self.Right.Tabs.Quips.EditBox.Submit:SetPoint("BOTTOMRIGHT", self.Right.Tabs.Quips.EditBox, "BOTTOMRIGHT", 0, 10)
	--
	self:SetBackdropColor(0, 0, 0, 0.95)
	self.emoteEnum = ORACLEHUD_PB_CONTENTEMOTE_ENUM.SPEAK
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_TooltipPetInfoContentMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Pet Info Content Tooltip") end
	self.Right.Tabs.Quips.EditBox:SetSubmitCallback(function(editbox, content)
		local emotesTable = json.parse(content)
		if (emotesTable ~= nil) then
			self.petInfo:SetEmotes(self.emoteEnum, emotesTable)
			self.petInfo:SaveEmotes(self.db)
		end
		self:PrintPetInfo()
	end)
	local TEXT = ORACLEHUD_PB_CONTENTEMOTE_TEXT
	local ENUM = ORACLEHUD_PB_CONTENTEMOTE_ENUM
	self.Right.Tabs.Quips.EditBox:SetCancelCallback(function(editbox, content)
		print("CANCEL")
	end)
	self.Right.Tabs.Quips.MenuButton:SetMenuItem(TEXT[ENUM.SPEAK], function(frame, button)
		self.Right.Tabs.Quips.MenuText:SetText(TEXT[ENUM.SPEAK])
		self.emoteEnum = ENUM.SPEAK
		self:PrintPetInfo()
	end)
	self.Right.Tabs.Quips.MenuButton:SetMenuItem(TEXT[ENUM.SPEAK_WIN], function(frame, button)
		self.Right.Tabs.Quips.MenuText:SetText(TEXT[ENUM.SPEAK_WIN])
		self.emoteEnum = ENUM.SPEAK_WIN
		self:PrintPetInfo()
	end)
	self.Right.Tabs.Quips.MenuButton:SetMenuItem(TEXT[ENUM.SPEAK_LOSS], function(frame, button)
		self.Right.Tabs.Quips.MenuText:SetText(TEXT[ENUM.SPEAK_LOSS])
		self.emoteEnum = ENUM.SPEAK_LOSS
		self:PrintPetInfo()
	end)
	self.Right.Tabs.Quips.MenuButton:SetMenuItem(TEXT[ENUM.EMOTE], function(frame, button)
		self.Right.Tabs.Quips.MenuText:SetText(TEXT[ENUM.EMOTE])
		self.emoteEnum = ENUM.EMOTE
		self:PrintPetInfo()
	end)
	self.Right.Tabs.Quips.MenuButton:SetMenuItem(TEXT[ENUM.EMOTE_SUMMON], function(frame, button)
		self.Right.Tabs.Quips.MenuText:SetText(TEXT[ENUM.EMOTE_SUMMON])
		self.emoteEnum = ENUM.EMOTE_SUMMON
		self:PrintPetInfo()
	end)
	function InitTabs()			self.Right.Tabs:Initialize(InitMenuButton)							end
	function InitMenuButton() 	self.Right.Tabs.Quips.MenuButton:Initialize(InitEmbedTooltip) 		end
	function InitEmbedTooltip() self.Left:Initialize(InitEditBox) 									end
	function InitEditBox()		self.Right.Tabs.Quips.EditBox:Initialize(InitFinished) 				end
	function InitFinished()
		self.Right.Tabs.Quips.MenuText:SetText(TEXT[ENUM.SPEAK])
		self.Right.Tabs.Quips.MenuButton:SetSize(32, 32)
		self.Right.Tabs.Quips.MenuButton:ClearAllPoints()
		self.Right.Tabs.Quips.MenuButton:SetPoint("TOPRIGHT", self.Right, "TOPRIGHT", -32, -18)
		self.Right.Tabs.Quips.MenuButton:Show()
		self.Right.Tabs.Quips.MenuButton:ShowFull()
		self.Right.Tabs:SetFocus(self.Right.Tabs:GetTabByName("Stats"))
		if (callback ~= nil) then
			callback()
		end
	end
	InitTabs()
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
		local text = json.stringify(self.petInfo.content.emotes[self.emoteEnum])
		-- Brutal.
		text = strsub(text, 2, strlen(text) - 1)
		text = text:gsub("\",", "\",\n    ")
		text = strsub(text, 1, strlen(text))
		text = "[\n    "..text.."\n]"
		self.Right.Tabs.Quips.EditBox.Scroll.Box:SetText(text)
	else
		self.Right.Tabs.Quips.EditBox.Scroll.Box:SetText("[\n\n]")
	end
	self.Right.Tabs.Stats.Kills:SetText(self.petInfo:GetKills(self.db))
	self.Right.Tabs.Stats.Deaths:SetText(self.petInfo:GetDeaths(self.db))
	self.Right.Tabs.Stats.Battles:SetText(self.petInfo:GetBattles(self.db))
end
---------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
function OracleHUD_PB_TooltipPetInfoContentMixin:OnSizeChanged()
	OracleHUD_FrameSetWidthPct(self.Left, 0.35)
	OracleHUD_FrameSetWidthPct(self.Right, 0.65)
end
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_TooltipPetInfoContentMixin:OnLoad()
	self:OnSizeChanged()
end
