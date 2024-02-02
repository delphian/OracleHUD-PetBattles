--- Display an output panel capable of handling basic HTML.
--- @class	OracleHUD_PB_EditBox : OracleHUD_PB_Edit, OracleHUD_PB_Tooltip
--- @field	EditBox		any		Inherited from mixin XML frame.
OracleHUD_PB_EditBoxMixin = CreateFromMixins(OracleHUD_PB_EditMixin)
OracleHUD_PB_EditBoxMixin._class = "OracleHUD_PB_EditBoxMixin"
---------------------------------------------------------------------------
--- Configure frame with required data.
--- @param db			OracleHUD_PB_DB HUD Pet Battle database.
function OracleHUD_PB_EditBoxMixin:Configure(db)
	if (db == nil) then
		error(self._class..":Configure(): Invalid arguments")
	end
	self.db = db
	self:SetBackdropColor(0, 0, 0, 0.8)
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_EditBoxMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Edit Box") end
	self.EditBox:SetAutoFocus(false)
	if (callback) then
		callback()
	end
end
-------------------------------------------------------------------------------
--- Set callback to invoke when submit button is clicked.
--- @param	callback	function
function OracleHUD_PB_EditBoxMixin:SetSubmitCallback(callback)
	self.submitCallback = callback
end
-------------------------------------------------------------------------------
--- Set callback to invoke when cancel button is clicked.
--- @param	callback	function
function OracleHUD_PB_EditBoxMixin:SetCancelCallback(callback)
	self.cancelCallback = callback
end
---------------------------------------------------------------------------
--- Process incoming events.
--- @param event		any		Unique event identification
--- @param eventName	string	Human friendly name of event
function OracleHUD_PB_EditBoxMixin:OnEvent(event, eventName, ...)
end
---------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
--- @param self			any	Main XML frame.
function OracleHUD_PB_EditBoxMixin:OnSizeChanged()
end
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_EditBoxMixin:OnLoad()
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
    --- Catch submit button click.
    self.Submit:HookScript("PostClick", function()
		if (self.submitCallback ~= nil) then
			self.submitCallback(self, self.EditBox:GetDisplayText())
		end
    end)
    ---------------------------------------------------------------------------
    --- Catch cancel button click.
    self.Cancel:HookScript("PostClick", function()
		if (self.cancelCallback ~= nil) then
			self.cancelCallback(self, self.EditBox:GetDisplayText())
		end
    end)
end