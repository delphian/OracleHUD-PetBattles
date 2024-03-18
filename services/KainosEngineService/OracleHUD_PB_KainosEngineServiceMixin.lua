---
--- What is the Kainos Engine?
---
--- @class OracleHUD_PB_KainosEngineService : OracleHUD_PB_Service
--- @field RegisterEvent    any Inherited from mixin XML frame.
OracleHUD_PB_KainosEngineServiceMixin = CreateFromMixins(OracleHUD_PB_ServiceMixin)
OracleHUD_PB_KainosEngineServiceMixin._class = "OracleHUD_PB_KainosEngineServiceMixin"
OracleHUD_PB_KainosEngineServiceMixin.listenNetwork = false
---------------------------------------------------------------------------
--- Configure frame with required data.
--- @param db 		    OracleHUD_PB_DB	                OracleHUD Pet Battles Database.
--- @param networkSvc   OracleHUD_PB_NetworkService		OracleHUD Network Service.
--- @param display		OracleHUD_PB_Display			OracleHUD Display Interface.
function OracleHUD_PB_KainosEngineServiceMixin:Configure(db, networkSvc, display)
	if (db == nil or networkSvc == nil) then
		error(self._class..":Configure(): Invalid arguments.")
	end
	self.db = db
	self.networkSvc = networkSvc
	self.display = display
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback	function?      Execute callback when initialize has finished.
function OracleHUD_PB_KainosEngineServiceMixin:Initialize(callback)
	if (self.db.debug) then self.display:Print("..Initialize Kainos Engine Service") end
	self:ListenNetworkSvc()
	if (callback ~= nil) then
		callback()
	end
end
---------------------------------------------------------------------------
--- Listen to the network service events.
function OracleHUD_PB_KainosEngineServiceMixin:ListenNetworkSvc()
	if (self.listenNetwork == false) then
		self.networkSvc:SetCallback(function(message)
			local elements = OracleHUD_StringSplit(message, ":")
			local playerId = elements[2]
			local messageId = elements[3]
		end)
		self.listenNetwork = true
	end
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param self any	Main XML frame.
function OracleHUD_PB_KainosEngineServiceMixin:OnLoad()
end
