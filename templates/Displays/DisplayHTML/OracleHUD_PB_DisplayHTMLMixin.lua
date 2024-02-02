--- Display an output panel capable of handling basic HTML.
--- @class OracleHUD_PB_DisplayHTML : OracleHUD_PB_Display
--- @field	GetFont		function	Inherited from mixin XML frame.
--- @field	SetFont		function	Inherited from mixin XML frame.
--- @field	SetText		function	Inherited from mixin XML frame SimpleHTML.
OracleHUD_PB_DisplayHTMLMixin = CreateFromMixins(OracleHUD_PB_DisplayMixin)
OracleHUD_PB_DisplayHTMLMixin._class = "OracleHUD_PB_DisplayHTMLMixin"
OracleHUD_PB_DisplayHTMLMixin.callback = nil
--- Create Supers (this seems weird)
local Super = OracleHUD_PB_DisplayMixin
-------------------------------------------------------------------------------
--- Configure mixin with required data.
--- @param db 			OracleHUD_PB_DB	OracleHUD Pet Battles Database.
--- @param fontSize 	integer			Size of the font.
function OracleHUD_PB_DisplayHTMLMixin:Configure(db, fontSize)
	if (db == nil or fontSize == nil) then
		error(self._class..":Configure(): Invalid arguments")
	end
	self.db = db
	self.fontSize = fontSize
	local a1, a2, a3 = self:GetFont("p")
	self:SetFont("p", "Fonts\\FRIZQT__.TTF", fontSize, a3)
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_DisplayHTMLMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize HTML Display") end
	if (callback ~= nil) then
		callback()
	end
end
-------------------------------------------------------------------------------
--- Set the HTML text.
--- @param message string	SimpleHTML formated text to display.
function OracleHUD_PB_DisplayHTMLMixin:Print(message)
	self:SetText(message)
end
---------------------------------------------------------------------------
--- Set callback for when hyperlink is clicked.
--- @param callback		function?	(Optional) Execute callback when href is clicked.
function OracleHUD_PB_DisplayHTMLMixin:SetCallback(callback)
	self.callback = callback
end
---------------------------------------------------------------------------
--- Process incoming events.
--- @param event		any		Unique event identification
--- @param eventName	string	Human friendly name of event
function OracleHUD_PB_DisplayHTMLMixin:OnEvent(event, eventName, ...)
end
---------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
--- @param self			any	Main XML frame.
function OracleHUD_PB_DisplayHTMLMixin:OnSizeChanged_DisplayHTML()
	self.color:SetSize(self:GetWidth(), self:GetHeight());
end
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_DisplayHTMLMixin:OnLoad()
	---------------------------------------------------------------------------
	--- Pass hyper link click to callback.
	self:HookScript("OnHyperlinkClick", function(first, link, innerHref)
		if (self.callback ~= nil) then
			self.callback(self, first, link, innerHref)
		end
	end)
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:HookScript("OnSizeChanged", function()
		self:OnSizeChanged_DisplayHTML()
	end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
	--- @param event		any		Event object.
	--- @param eventName	string	Name of event.
    self:HookScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end