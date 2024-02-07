--- Display, manage cooldowns, and execution of a single pet ability when clicked.
--- @class OracleHUD_PB_TabPanel : Frame
--- @field Background           any         Inherited from mixin XML frame.
--- @field Border               any         Inherited from Mixin XML frame.
OracleHUD_PB_TabPanelMixin = CreateFromMixins({})
OracleHUD_PB_TabPanelMixin._class = "OracleHUD_PB_TabPanelMixin"
OracleHUD_PB_TabPanelMixin.callback = nil
-------------------------------------------------------------------------------
--- Configure mixin with required data. Should only be called by tab button configure().
--- @param  db 		    OracleHUD_PB_DB	    OracleHUD Pet Battles Database.
function OracleHUD_PB_TabPanelMixin:Configure(db)
	if (db == nil) then
		error(self._class..":Configure(): Invalid arguments")
	end
	self.db = db
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_TabPanelMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Tab Panel") end
    if (callback ~= nil) then
		callback()
	end
end
-------------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
--- @param self			any	Main XML frame.
function OracleHUD_PB_TabPanelMixin:OnSizeChanged()
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_TabPanelMixin:OnLoad()
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:HookScript("OnSizeChanged", function()
		self:OnSizeChanged()
	end)
end