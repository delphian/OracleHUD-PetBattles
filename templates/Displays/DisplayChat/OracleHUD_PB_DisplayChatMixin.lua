--- Display messages to regular chat window.
--- @class OracleHUD_PB_DisplayChat : OracleHUD_PB_Display
OracleHUD_PB_DisplayChatMixin = CreateFromMixins(OracleHUD_PB_DisplayMixin)
OracleHUD_PB_DisplayChatMixin._class = "OracleHUD_PB_DisplayChatMixin"
OracleHUD_PB_DisplayChatMixin.callback = nil
--- Create Supers (this seems weird)
local Super = OracleHUD_PB_DisplayMixin
-------------------------------------------------------------------------------
--- Configure mixin with required data.
--- @param db 			OracleHUD_PB_DB	OracleHUD Pet Battles Database.
--- @param chatType		string			SAY, EMOTE, YELL, PARTY, RAID, RAID_WARNING, INSTANCE_CHAT, GUILD, OFFICER, WHISPER, CHANNEL, AFK, DND, VOICE_TEXT
function OracleHUD_PB_DisplayChatMixin:Configure(db, chatType)
	if (db == nil or chatType == nil) then
		error(self._class..":Configure(): Invalid arguments")
	end
	self.db = db
	self.chatType = chatType
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback		function?	(Optional) Execute callback when initialize has finished.
function OracleHUD_PB_DisplayChatMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Chat Display: "..self.chatType) end
	if (callback ~= nil) then
		callback()
	end
end
-------------------------------------------------------------------------------
--- Print a message to the chat window.
--- @param message string	Message to display.
function OracleHUD_PB_DisplayChatMixin:Print(message)
	SendChatMessage(message, self.chatType)
end
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_DisplayChatMixin:OnLoad()
end
