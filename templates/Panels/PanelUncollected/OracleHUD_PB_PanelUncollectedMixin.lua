--- Display a list of uncollected pets in the local zone.
--- @class OracleHUD_PB_PanelUncollected : OracleHUD_PB_Panel
--- @field Left				OracleHUD_PB_DisplayHTML	Inherited from mixin XML frame.
--- @field Right			OracleHUD_PB_DisplayHTML	Inherited from mixin XML frame.
--- @field RegisterEvent	any							Inherited from mixin XML frame.
OracleHUD_PB_PanelUncollectedMixin = CreateFromMixins(OracleHUD_PB_PanelMixin)
OracleHUD_PB_PanelUncollectedMixin._class = "OracleHUD_PB_PanelUncollectedMixin"
---------------------------------------------------------------------------
--- Configure frame with required data.
--- @param db		    	OracleHUD_PB_DB                 Oracle HUD Pet Battle database.
--- @param petInfoSvc   	OracleHUD_PB_PetInfoService     Oracle HUD Pet Info Service.
--- @param combatLogSvc 	OracleHUD_PB_CombatLogService   Oracle HUD Combat Log Service.
--- @param tooltipPetInfo	OracleHUD_PB_TooltipPetInfo
function OracleHUD_PB_PanelUncollectedMixin:Configure(db, petInfoSvc, combatLogSvc, tooltipPetInfo)
	if (db == nil or petInfoSvc == nil or combatLogSvc == nil or tooltipPetInfo == nil) then
		error(self._class..":Configure(): Invalid arguments.")
	end
	self.db = db
	self.petInfoSvc = petInfoSvc
	self.combatLogSvc = combatLogSvc
	self.tooltipPetInfo = tooltipPetInfo
	self.Left:Configure(db, 10)
	self.Right:Configure(db, 10)
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback	function?      (Optional) Execute callback when initialize has finished.
function OracleHUD_PB_PanelUncollectedMixin:Initialize(callback)
	if (self.db.debug) then print("..Initialize Uncollected Panel") end
	self:RegisterEvent("ZONE_CHANGED")
	local pets = self.petInfoSvc:GetPetInfoByUncollectedZone(GetZoneText(), self.db)
	if (pets ~= nil and
		OracleHUD_TableGetLength(pets) > 0 and
		self.combatLogSvc:IsInBattle() == false and
		self.db.options.uncaptured.show == true)
	then
		self:SetPets(pets)
		self:ShowFull()
	else
		self:HideFull()
	end
    self:ListenCombatLog()
	if (callback ~= nil) then
		callback()
	end
end
-------------------------------------------------------------------------------
--- Set callback function to call when html link is clicked.
--- @param callback	function
function OracleHUD_PB_PanelUncollectedMixin:SetCallback(callback)
	self.callback = callback
end
-------------------------------------------------------------------------------
--- Print list of pets to the display.
--- @param pets any		Array of OracleHUD_PB_PetInfo
function OracleHUD_PB_PanelUncollectedMixin:SetPets(pets)
	local total = OracleHUD_TableGetLength(pets)
	local half = math.floor((total / 2)+0.5)
	local uncollected = ""
	for i = 1, half do
		local image = '<img src="'..pets[i].icon..'" />'
		image = "|T"..pets[i].icon..":30|t"
		local href = '<a href="'..pets[i].speciesId..'">'..image..'</a>'
		uncollected = uncollected..href.." "..pets[i].name.."<br />"
	end
	self.Left:SetText("<html><body><p>"..uncollected.."</p></body></html>")
	if (half > 1) then
		uncollected = ""
		for i = half + 1, total do
			local image = '<img src="'..pets[i].icon..'" />'
			image = "|T"..pets[i].icon..":30|t"
			local href = '<a href="'..pets[i].speciesId..'">'..image..'</a>'
			uncollected = uncollected..href.." "..pets[i].name.."<br />"
		end
		self.Right:SetText("<html><body><p>"..uncollected.."</p></body></html>")
	end
end
-------------------------------------------------------------------------------
--- Listen to the combat log for events.
function OracleHUD_PB_PanelUncollectedMixin:ListenCombatLog()
    self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.OPEN, function()
		self:HideFull()
    end)
    self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.CLOSE, function()
		local pets = self.petInfoSvc:GetPetInfoByUncollectedZone(GetZoneText(), self.db)
		if (pets ~= nil and
			OracleHUD_TableGetLength(pets) > 0 and
			self.db.options.uncaptured.show == true)
		then
			self:SetPets(pets)
			self:ShowFull()
		else
			self:HideFull()
		end
    end)
end
---------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
function OracleHUD_PB_PanelUncollectedMixin:OnSizeChanged_PanelUncollectedTemplate()
	OracleHUD_FrameSetSizePct(self.Left, 0.5, 1.0)
	OracleHUD_FrameSetSizePct(self.Right, 0.5, 1.0)
end
---------------------------------------------------------------------------
--- Process incoming events.
--- @param event		any		Unique event identification
--- @param eventName	string	Human friendly name of event
function OracleHUD_PB_PanelUncollectedMixin:OnEvent(event, eventName, ...)
	if (eventName == "ZONE_CHANGED") then
		local pets = self.petInfoSvc:GetPetInfoByUncollectedZone(GetZoneText(), self.db)
		if (pets ~= nil and
			OracleHUD_TableGetLength(pets) > 0 and
			self.db.options.uncaptured.show == true)
		then
			self:SetPets(pets)
			self:ShowFull()
		else
			self:HideFull()
		end
	end
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param self			any	Main XML frame.
function OracleHUD_PB_PanelUncollectedMixin:OnLoad()
	---------------------------------------------------------------------------
	--- Capture click from left hand panel and show tooltip.
	self.Left:SetCallback(function(frame, first, link, innerHtml)
		if (self.db == nil) then
			print("OracleHUD_PB_PanelUncollectedTemplate: Configure() must be called first.")
		else
			local speciesId = link
			if (speciesId ~= nil) then
				local petInfo = self.petInfoSvc:GetPetInfoBySpeciesId(speciesId, self.db)
				self.tooltipPetInfo:SetPetInfo(petInfo)
				self.tooltipPetInfo:ShowFull()
			end
			if (self.callback ~= nil) then
				self.callback(self, first, link, innerHtml)
			end
		end
	end)
	---------------------------------------------------------------------------
	--- capture click from right hand panel and show tooltip.
	self.Right:SetCallback(function(frame, first, link, innerHtml)
		if (self.db == nil) then
			print("OracleHUD_PB_PanelUncollectedTemplate: Configure() must be called first.")
		else
			local speciesId = link
			if (speciesId ~= nil) then
				local petInfo = self.petInfoSvc:GetPetInfoBySpeciesId(speciesId, self.db)
				self.tooltipPetInfo:SetPetInfo(petInfo)
				self.tooltipPetInfo:ShowFull()
			end
			if (self.callback ~= nil) then
				self.callback(self, first, link, innerHtml)
			end
		end
	end)
	---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:HookScript("OnSizeChanged", function()
		self:OnSizeChanged_PanelUncollectedTemplate()
	end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
    self:HookScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
