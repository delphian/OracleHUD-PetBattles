--- @class 	OracleHUD_PB_Tooltip
--- @field	NineSlice		any			Inherited from mixin XML frame.
--- @field	GetHeight		function	Inherited from mixin XML frame.
--- @field	SetHeight		function	Inherited from mixin XML frame.
--- @field	Show			function	Inherited from mixin XML frame.
--- @field	linePool		any			
OracleHUD_PB_TooltipMixin = {}
OracleHUD_PB_TooltipMixin._class = "OracleHUD_PB_TooltipMixin"
OracleHUD_PB_TooltipMixin.HideFull = OracleHUD_FrameHideFull
OracleHUD_PB_TooltipMixin.ShowFull = OracleHUD_FrameShowFull
---------------------------------------------------------------------------
--- Configure mixin with required data.
--- @param db 			OracleHUD_PB_DB	OracleHUD Pet Battles Database.
function OracleHUD_PB_TooltipMixin:Configure(db)
	if (db == nil) then
		error(self._class":Configure(): Invalid arguments.")
	end
	self.db = db
	self.linePool = CreateFontStringPool(self, "ARTWORK", 0, "GameTooltipText");
 end
-------------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_TooltipMixin:Initialize(callback)
	if (callback) then
		callback()
	end
end
-------------------------------------------------------------------------------
--- Add a line of text to the tooltip and adjust total height.
--- @param	text			string		Text to display.
--- @param	r				number?		Red value of text (0-1)
--- @param	g				number?		Green value of text (0-1)
--- @param	b				number?		Blue value of text (0-1)
--- @param	wrap			boolean?	Allow text to wrap.
--- @param	defaultAnchor	any		Begin text directly beneath this anchor.
function OracleHUD_PB_TooltipMixin:AddTextLine(text, r, g, b, wrap, defaultAnchor)
	local LinePadding = 10;
	if not r then
		r, g, b = NORMAL_FONT_COLOR:GetRGB();
	end
	local anchor = self.textLineAnchor;
	if (anchor == nil) then
		anchor = defaultAnchor
	end
	local line = self.linePool:Acquire();
	line:SetText(text);
	line:SetTextColor(r, g, b);
	line:SetPoint("TOP", anchor, "BOTTOM", 0, -LinePadding);
	line:SetPoint("LEFT", self, "LEFT", 12, 0);
	if wrap then
		line:SetPoint("RIGHT", self, "RIGHT", -4, 0);
	end
	line:Show();
	self.textLineAnchor = line;
	self:SetHeight(self:GetHeight() + line:GetHeight() + LinePadding);
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_TooltipMixin:OnLoad()
	NineSliceUtil.DisableSharpening(self.NineSlice)
	local bgColor = self.backdropColor or TOOLTIP_DEFAULT_BACKGROUND_COLOR
	local bgAlpha = self.backdropColorAlpha or 1
	local bgR, bgG, bgB = bgColor:GetRGB()
	self:SetBackdropColor(bgR, bgG, bgB, bgAlpha)
	if self.backdropBorderColor then
		local borderR, borderG, borderB = self.backdropBorderColor:GetRGB()
		local borderAlpha = self.backdropBorderColorAlpha or 1
		self:SetBackdropBorderColor(borderR, borderG, borderB, borderAlpha)
	end
end
function OracleHUD_PB_TooltipMixin:SetBackdropColor(r, g, b, a)
	self.NineSlice:SetCenterColor(r, g, b, a)
end
function OracleHUD_PB_TooltipMixin:GetBackdropColor()
	return self.NineSlice:GetCenterColor()
end
function OracleHUD_PB_TooltipMixin:SetBackdropBorderColor(r, g, b, a)
	self.NineSlice:SetBorderColor(r, g, b, a)
end
function OracleHUD_PB_TooltipMixin:GetBackdropBorderColor()
	return self.NineSlice:GetBorderColor()
end
function OracleHUD_PB_TooltipMixin:SetBorderBlendMode(blendMode)
	self.NineSlice:SetBorderBlendMode(blendMode)
end
