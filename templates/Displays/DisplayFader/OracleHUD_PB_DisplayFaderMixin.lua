--- Display an output panel capable of handling basic HTML.
--- @class OracleHUD_PB_DisplayFader : OracleHUD_PB_Display
--- @field padding		any		Inherited from mixin XML frame
--- @field background	any		Inherited from mixin XML frame
--- @field border		any		Inherited from mixin XML frame
OracleHUD_PB_DisplayFaderMixin = CreateFromMixins(OracleHUD_PB_DisplayMixin)
OracleHUD_PB_DisplayFaderMixin._class = "OracleHUD_PB_DisplayFaderMixin"
--- Create Supers (this seems weird)
local Super = OracleHUD_PB_DisplayMixin
---------------------------------------------------------------------------
--- Configure frame with required data.
--- @param db			OracleHUD_PB_DB HUD Pet Battle database.
--- @param timeVisible	integer			Seconds that text will be visible before fading.
--- @param timeFade		integer			Seconds that text will transition to invisible.
--- @param fontSize		integer?		(Optional, defaults to 10) Size of text font.
--- @param lines		integer?		(Optional, defaults to 4) Number of lines to display.
function OracleHUD_PB_DisplayFaderMixin:Configure(db, timeVisible, timeFade, fontSize, lines)
	if (fontSize == nil) then fontSize = 10 end
	if (lines == nil) then lines = 4 end
	if (db == nil or timeVisible == nil or timeFade == nil) then
		error(self._class..":Configure(): Invalid arguments")
	end
	self.db = db
	self.timeVisible = timeVisible
	self.timeFade = timeFade
	self.fontSize = fontSize
	self.lines = lines
	local fontFile, height, flags = self.padding.Messages:GetFont()
	self.padding.Messages:SetFont("Fonts\\FRIZQT__.TTF", fontSize, flags)
	self.padding.Messages:SetJustifyH("LEFT")
	self.padding.Messages:SetJustifyV("TOP")
	self.padding.Messages:SetShadowColor(0.0, 0.0, 0.0, 1.0)
	self.padding.Messages:SetShadowOffset(-1, -1)
	self.padding.Messages:SetTimeVisible(timeVisible)
	self.padding.Messages:SetFadeDuration(timeFade)
	self.padding.Messages:SetInsertMode("TOP")
	self.padding.Messages:SetSpacing(0)
	self:OnSizeChanged()
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_DisplayFaderMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Fader Display") end
	if (callback ~= nil) then
		callback()
	end
end
-------------------------------------------------------------------------------
--- Add line of text to output.
--- @param message string				Message text to add.
--- @param rgb     OracleHUD_PB_RGB?    (Optional, defaults to white) Red, green, blue values.
function OracleHUD_PB_DisplayFaderMixin:Print(message, rgb)
	if (rgb == nil) then rgb = { r = 1.0, g = 1.0, b = 1.0 } end
	self:AddMessage(message, rgb.r, rgb.g, rgb.b)
end
---------------------------------------------------------------------------
--- Set the background color and transparency.
--- @param r	integer		red component (0-1)
--- @param g    integer 	green component (0-1)
--- @param b    integer 	blue component (0-1)
--- @param a    integer 	alpha component (0-1)
function OracleHUD_PB_DisplayFaderMixin:SetBackgroundColor(r, b, g, a)
	self.background:SetColorTexture(r, b, g, a)
end
---------------------------------------------------------------------------
--- Set the border transparency.
--- @param a	integer		alpha component (0-1)
function OracleHUD_PB_DisplayFaderMixin:SetBorderAlpha(a)
	self.border:SetAlpha(a)
end
---------------------------------------------------------------------------
--- Add a message to the chat frame. Color is optional and defaults to white.
--- @param text	string		Text to display.
--- @param r	integer?	(Optional, defaults to 1.0) Red component of text color.
--- @param g	integer?	(Optional, defaults to 1.0) Green component of text color.
--- @param b	integer?	(Optional, defaults to 1.0) Blue component of text color.
function OracleHUD_PB_DisplayFaderMixin:AddMessage(text, r, g, b)
	if (r == nil) then r = 1.0 end
	if (g == nil) then g = 1.0 end
	if (b == nil) then b = 1.0 end
	self.padding.Messages:AddMessage(text, r, g, b);
end
---------------------------------------------------------------------------
--- Process incoming events.
--- @param event		any		Unique event identification
--- @param eventName	string	Human friendly name of event
function OracleHUD_PB_DisplayFaderMixin:OnEvent(event, eventName, ...)
end
---------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
--- @param self			any	Main XML frame.
function OracleHUD_PB_DisplayFaderMixin:OnSizeChanged()
	if (self.db ~= nil) then
		-- TODO : This is crap. Spacing is not calculated, and the padding constant needs to be variable
		-- based on the anchor points.
		local spacing = self.padding.Messages:GetSpacing()
		local height = (self.lines) * ((self.fontSize * 1.100) + spacing) + (40)
		self:SetHeight(height)
	end
end
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_DisplayFaderMixin:OnLoad()
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:HookScript("OnSizeChanged", function()
		self:OnSizeChanged()
	end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
	--- @param event		any		Event object.
	--- @param eventName	string	Name of event.
    self:HookScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end