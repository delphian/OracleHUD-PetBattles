-------------------------------------------------------------------------------
--- (Abstract) Display messages.
--- @class OracleHUD_PB_Display
OracleHUD_PB_DisplayMixin = {}
OracleHUD_PB_DisplayMixin.HideFull = OracleHUD_FrameHideFull
OracleHUD_PB_DisplayMixin.ShowFull = OracleHUD_FrameShowFull
OracleHUD_PB_DisplayMixin._class = "OracleHUD_PB_DisplayMixin"
-------------------------------------------------------------------------------
--- (Abstract) Configure mixin with required data.
--- @param db   OracleHUD_PB_DB     OracleHUD Pet Battles Database.
function OracleHUD_PB_DisplayMixin:Configure(db)
    error("Class must provide override")
end
---------------------------------------------------------------------------
--- (Abstract) All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_DisplayMixin:Initialize(callback)
    error("Class must provide override")
end
-------------------------------------------------------------------------------
--- (Abstract) Display a text message.
--- @param message string               Message to display.
--- @param rgb     OracleHUD_PB_RGB?    (Optional, defaults to white) Red, green, blue values.
function OracleHUD_PB_DisplayMixin:Print(message, rgb)
    error("Class must provide override")
end
