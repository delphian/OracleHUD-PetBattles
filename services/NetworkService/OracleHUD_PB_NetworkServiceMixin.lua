--- Addon backchannel network services.
--- @class OracleHUD_PB_NetworkService : OracleHUD_PB_Service
--- @field Display                  any Inherited from mixin XML frame.
--- @field RegisterEvent            any Inherited from mixin XML frame.
OracleHUD_PB_NetworkServiceMixin = CreateFromMixins(OracleHUD_PB_ServiceMixin)
OracleHUD_PB_NetworkServiceMixin._class = "OracleHUD_PB_NetworkServiceMixin"
OracleHUD_PB_NetworkServiceMixin.callbacks = {}
OracleHUD_PB_NetworkServiceMixin.account = nil
OracleHUD_PB_NetworkServiceMixin.debug = {
    print = false,
    accountAttempt = 0,
    channelAttempt = 0
}
---------------------------------------------------------------------------
--- Configure frame with required data.
--- @param db 		    OracleHUD_PB_DB	                OracleHUD Pet Battles Database.
--- @param petInfoSvc   OracleHUD_PB_PetInfoService     OracleHUD Pet Battles Pet Information Service.
--- @param display		OracleHUD_PB_Display			OracleHUD Display Interface.
function OracleHUD_PB_NetworkServiceMixin:Configure(db, petInfoSvc, display)
    if (db == nil or petInfoSvc == nil) then
        error(self._class..":Configure(): Invalid arguments.")
    end
    self.db = db
    self.petInfoSvc = petInfoSvc
    self.display = display
    -- Special case for this to be in config, show frame early.
    if (db.debug) then
        self:ShowFull()
    end
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback     function?   (Optional) Execute callback when initialize has finished.
function OracleHUD_PB_NetworkServiceMixin:Initialize(callback)
    if (self.db.debug) then self.display:Print("..Initialize Network Service") end
    self:RegisterEvent("CHAT_MSG_ADDON")
    self:RegisterEvent("CHAT_MSG_ADDON_LOGGED")
    self:JoinCustomChatChannel("ORACLEHUD", 1, function()
        C_Timer.NewTicker(2, function(ticker)
            self.debug.accountAttempt = self.debug.accountAttempt + 1
            local playerGuid = UnitGUID("player")
            if (playerGuid ~= nil) then
                self.account = C_BattleNet.GetAccountInfoByGUID(playerGuid)
                if (self.db.debug) then print("NetworkService: Get account attempt.") end
                if (self.account ~= nil) then
                    ticker:Cancel()
                    if (self.db.debug) then
                        self.display:Print("NetworkService: " .. self.debug.accountAttempt .. " total account attempts.")
                        self.display:Print("NetworkService: found "..self.account.gameAccountInfo.characterName)
                    end
                    if (callback ~= nil) then
                        callback()
                    end
                end
            end
            if (self.debug.accountAttempt >= 30) then
                ticker:Cancel()
                self.display:Print("NetworkService: Get Account Failed!", { r = 1.0, g = 0.0, b = 0.0 })
            end
        end)
    end)
end
---------------------------------------------------------------------------
--- Join custom chat channel with specific index for network traffic.
--- @param name         string      Name of custom chat channel for network traffic.
--- @param index        integer     Index of custom chat channel for network traffic.
--- @param callback     function    Execute callback when initialize has finished.
function OracleHUD_PB_NetworkServiceMixin:JoinCustomChatChannel(name, index, callback)
    C_Timer.NewTicker(2, function(ticker)
        if (self.db.debug) then self.display:Print("NetworkService: Join channel attempt.") end
        self.debug.channelAttempt = self.debug.channelAttempt + 1
        JoinChannelByName(name, "", ChatFrame1:GetID(), false)
        local info = C_ChatInfo.GetChannelInfoFromIdentifier(name)
        if (info ~= nil) then
            if (info.localID == index) then
                ticker:Cancel()
                if (self.db.debug) then
                    self.display:Print("NetworkService: " .. self.debug.channelAttempt .. " total join channel attempts.")
                end
                if (callback ~= nil) then
                    callback()
                end
            else
                C_ChatInfo.SwapChatChannelsByChannelIndex(info.localID, index)
            end
        end
        if (self.debug.channelAttempt >= 30) then
            ticker:Cancel()
            self.display:Print("NetworkService: Join Channel Failed!", { r = 1.0, g = 0.0, b = 0.0 })
        end
    end)
end
---------------------------------------------------------------------------
--- Set callback to be invoked when an addon message is received.
--- @param callback     function  Function to be called.
function OracleHUD_PB_NetworkServiceMixin:SetCallback(callback)
    table.insert(self.callbacks, callback)
end
---------------------------------------------------------------------------
--- Send a network message to custom channels and party.
--- @param message  string      Message to send.
--- @param logged   boolean     Send network message as logged (true/false)
function OracleHUD_PB_NetworkServiceMixin:Send(message, logged)
    message = "PB:"..UnitGUID("player")..":"..message
    if (logged == true) then
        C_ChatInfo.SendAddonMessageLogged("ORACLEHUD", message, "CHANNEL", "1")
        C_ChatInfo.SendAddonMessageLogged("ORACLEHUD", message, "PARTY")
    else
        C_ChatInfo.SendAddonMessage("ORACLEHUD", message, "CHANNEL", "1")
        C_ChatInfo.SendAddonMessage("ORACLEHUD", message, "PARTY")
    end
end
---------------------------------------------------------------------------
--- Send a network message to private individual.
--- @param message      string      Message to send.
--- @param recipient    string      Name-Server formatted recipient of network whisper.
--- @param logged       boolean     Send network message as logged (true/false)
function OracleHUD_PB_NetworkServiceMixin:SendWhisper(message, recipient, logged)
    message = "PB:"..UnitGUID("player")..":"..message
    if (logged == true) then
        C_ChatInfo.SendAddonMessageLogged("ORACLEHUD", message, "WHISPER", recipient)
    else
        C_ChatInfo.SendAddonMessage("ORACLEHUD", message, "WHISPER", recipient)
    end
end
---------------------------------------------------------------------------
--- Send a network message to party.
--- @param message      string      Message to send.
--- @param logged       boolean     Send network message as logged (true/false)
function OracleHUD_PB_NetworkServiceMixin:SendParty(message, logged)
    message = "PB:"..UnitGUID("player")..":"..message
    if (logged == true) then
        C_ChatInfo.SendAddonMessageLogged("ORACLEHUD", message, "PARTY")
    else
        C_ChatInfo.SendAddonMessage("ORACLEHUD", message, "PARTY")
    end
end
---------------------------------------------------------------------------
--- Pet has been sent to the zoo.
--- @param petInfo	    OracleHUD_PB_PetInfo    formatted pet information.
--- @param zooPetUUID   string                  A zoo pet unique identifier
--- @param logged       boolean                 Send network message as logged (true/false)
function OracleHUD_PB_NetworkServiceMixin:SendAdoption(petInfo, zooPetUUID, logged)
    if (logged == nil) then
        logged = false
    end
    local message = "adoption:"..petInfo.speciesId..":"..petInfo.healthMax..":"..petInfo.power..":"..petInfo.speed..":"..petInfo.level..":"..zooPetUUID
    self:Send(message, logged)
end
---------------------------------------------------------------------------
--- Pet size has been increased.
--- @param zooPet   any         Meta information about a pet belonging inside a zoo.
---                             Created by OracleHUD_PB_ZooTemplate:AdoptPet()
--- @param logged   boolean     Send network message as logged (true/false)
function OracleHUD_PB_NetworkServiceMixin:SendPetSizeUp(zooPet, logged)
    if (logged == nil) then
        logged = false
    end
    local message = "petSizeUp:"..zooPet.uuid
    self:Send(message, logged)
end
---------------------------------------------------------------------------
--- Pet size has been decreased.
--- @param zooPet   any         Meta information about a pet belonging inside a zoo.
---                             Created by OracleHUD_PB_ZooTemplate:AdoptPet()
--- @param logged   boolean     Send network message as logged (true/false)
function OracleHUD_PB_NetworkServiceMixin:SendPetSizeDown(zooPet, logged)
    if (logged == nil) then
        logged = false
    end
    local message = "petSizeDown:"..zooPet.uuid
    self:Send(message, logged)
end
---------------------------------------------------------------------------
--- Introduce self to the community.
--- @param logged   boolean     Send network message as logged (true/false)
function OracleHUD_PB_NetworkServiceMixin:SendHello(logged)
    self:Send("hello", logged)
end
---------------------------------------------------------------------------
--- Exit self from the community.
--- @param logged   boolean     Send network message as logged (true/false)
function OracleHUD_PB_NetworkServiceMixin:SendGoodbye(logged)
    self:Send("goodbye", logged)
end
---------------------------------------------------------------------------
--- Process incoming events.
--- @param event        any     Unique event identification
--- @param eventName    string  Human friendly name of event
function OracleHUD_PB_NetworkServiceMixin:OnEvent(event, eventName, ...)
    if (eventName == "CHAT_MSG_ADDON_LOGGED" or eventName == "CHAT_MSG_ADDON") then        
        local prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID = ...
        local debug = prefix.."||"..text.."||"..channel.."||"..sender.."||"..target.."||"..zoneChannelID.."||"..localID.."||"..name.."||"..instanceID
        if (self.db.debug) then
            self.display:Print(debug, { r = 1.0, g = 1.0, b = 0.0 })
        end
        local playerGuid = UnitGUID("player")
        if (playerGuid ~= nil) then
            local account = C_BattleNet.GetAccountInfoByGUID(playerGuid)
            if (account ~= nil) then
                local fullName = account.gameAccountInfo.characterName .. "-" .. account.gameAccountInfo.realmName
                if (channel == "PARTY" and sender == fullName) then
                    -- Ignore
                else
                    if (self.callbacks ~= nil) then
                        for i = 1, #self.callbacks do
                            self.callbacks[i](text)
                        end
                    end
                end
            else
                self.display:Print("NetworkService: Nil account information!", { r = 1.0, g = 0.0, b = 0.0 })
            end
        else
            self.display:Print("NetworkService: Nil player GUID!", { r = 1.0, g = 0.0, b = 0.0 })
        end
    end
end
---------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
function OracleHUD_PB_NetworkServiceMixin:OnSizeChanged_NetworkServiceMixin()
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param self any	Main XML frame.
function OracleHUD_PB_NetworkServiceMixin:OnLoad()
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_NetworkServiceMixin()
    end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
