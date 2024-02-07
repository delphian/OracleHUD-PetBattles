--- Display, manage cooldowns, and execution of a single pet ability when clicked.
--- @class OracleHUD_PB_TabButton : Frame
--- @field Background          any         Inherited from mixin XML frame.
--- @field Font                any         Inherited from Mixin XML frame.
--- @field Tab                 any         Inherited from Mixin XML frame.
OracleHUD_PB_TabButtonMixin = CreateFromMixins({})
OracleHUD_PB_TabButtonMixin._class = "OracleHUD_PB_TabButtonMixin"
-------------------------------------------------------------------------------
--- Configure mixin with required data.
--- @param  db 		    OracleHUD_PB_DB	    OracleHUD Pet Battles Database.
--- @param  name        string              Name of tab.
--- @param  panel       any                 Tab panel frame associated with this tab.
function OracleHUD_PB_TabButtonMixin:Configure(db, name, panel)
	if (db == nil or name == nil) then
		error(self._class..":Configure(): Invalid arguments")
	end
	self.db = db
    self.name = name
    self.panel = panel
    panel:Configure(db)
    self.callback = nil
    self.state = {
        focus = false
    }
    self.config = {
        colors = {
            focus = {
                r = 0.4,
                g = 0.4,
                b = 0.4,
                a = 1.0
            },
            focusLost = {
                r = 0.2,
                g = 0.2,
                b = 0.2,
                a = 0.8
            }
        }
    }
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_TabButtonMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Tab "..self.name) end
    self.Font:SetText(self.name)
    self.panel:Initialize(callback)
end
-------------------------------------------------------------------------------
--- Handle event.
function OracleHUD_PB_TabButtonMixin:OnEnter()
    self.Background:SetColorTexture(0.8, 0.8, 0.8, 1.0)
end
-------------------------------------------------------------------------------
--- Handle event.
function OracleHUD_PB_TabButtonMixin:OnLeave()
    local c = self.config.colors.focusLost
    if (self.state.focus == true) then
        c = self.config.colors.focus
    end
    self.Background:SetColorTexture(c.r, c.g, c.b, c.a)
end
-------------------------------------------------------------------------------
--- Handle event.
function OracleHUD_PB_TabButtonMixin:OnClick()
    self:Focus()
    if (self.callback ~= nil) then
        self.callback(self)
    end
end
-------------------------------------------------------------------------------
--- Focus on tab, make panel visible.
function OracleHUD_PB_TabButtonMixin:Focus()
    local c = self.config.colors.focus
    self.Background:SetColorTexture(c.r, c.g, c.b, c.a)
    self.panel:Show()
    self.state.focus = true
end
-------------------------------------------------------------------------------
--- Focus on tab, make panel visible.
function OracleHUD_PB_TabButtonMixin:FocusLost()
    local c = self.config.colors.focusLost
    self.Background:SetColorTexture(c.r, c.g, c.b, c.a)
    self.panel:Hide()
    self.state.focus = false
end
-------------------------------------------------------------------------------
--- Register a callback that will be executed when the tab is clicked.
--- @param callback function    Invoked when tab is clicked on.
function OracleHUD_PB_TabButtonMixin:SetCallback(callback)
    self.callback = callback
end
-------------------------------------------------------------------------------
--- Handle incoming events.
--- @param event		any		Unique event identification
--- @param eventName	string	Human friendly name of event
function OracleHUD_PB_TabButtonMixin:OnEvent(event, eventName, ...)
end
-------------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
--- @param self			any	Main XML frame.
function OracleHUD_PB_TabButtonMixin:OnSizeChanged()
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_TabButtonMixin:OnLoad()
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
    ---------------------------------------------------------------------------
    --- Catch clicks and forward to handler.
    self:HookScript("OnClick", function()
        self:OnClick()
    end)
    ---------------------------------------------------------------------------
    --- Catch mouse action and forward to handler.
    self:HookScript("OnEnter", function()
        self:OnEnter()
    end)
    ---------------------------------------------------------------------------
    --- Catch mouse action and forward to handler.
    self:HookScript("OnLeave", function()
        self:OnLeave()
    end)
end