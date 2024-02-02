--- Display messages to regular chat window.
--- @class OracleHUD_PB_DisplayConsole : OracleHUD_PB_Display
OracleHUD_PB_DisplayConsoleMixin = CreateFromMixins(OracleHUD_PB_DisplayMixin)
OracleHUD_PB_DisplayConsoleMixin._class = "OracleHUD_PB_DisplayConsoleMixin"
OracleHUD_PB_DisplayConsoleMixin.callback = nil
--- Create Supers (this seems weird)
local Super = OracleHUD_PB_DisplayMixin
-------------------------------------------------------------------------------
--- Configure mixin with required data.
--- @param db 			OracleHUD_PB_DB	OracleHUD Pet Battles Database.
function OracleHUD_PB_DisplayConsoleMixin:Configure(db)
	if (db == nil) then
		error(self._class..":Configure(): Invalid arguments")
	end
	self.db = db
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_DisplayConsoleMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Console Display") end
	if (callback ~= nil) then
		callback()
	end
end
-------------------------------------------------------------------------------
--- Print a message to the chat window.
--- @param message string	Message to display.
function OracleHUD_PB_DisplayConsoleMixin:Print(message)
	print(message)
end
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_DisplayConsoleMixin:OnLoad()
	---------------------------------------------------------------------------
	--- Dynamically resize all children elements when frame changes size.
	self:HookScript("OnSizeChanged", function()
	end)
end
