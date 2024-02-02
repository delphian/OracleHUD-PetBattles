--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_PanelCommunityTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
	self.ShowFull = OracleHUD_FrameShowFull
	self.listening = false
	self.online = {
		players = {},
		total = 0
	}
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db			Oracle HUD Pet Battle database.
	--- @param display		OracleHUD_PB_Display			OracleHUD Display Interface.
	-- @param petInfoSvc	Oracle HUD Pet Information Service.
    -- @param networkSvc    Oracle HUD Network Service.
    function self:Configure(db, display, petInfoSvc, networkSvc)
        if (db == nil or display == nil or petInfoSvc == nil or networkSvc == nil) then
            error("OracleHUD_PB_PanelCommunityTemplate:Configure(): Invalid arguments.")
		end
		self.db = db
		self.display = display
		self.petInfoSvc = petInfoSvc
		self.networkSvc = networkSvc
	end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    -- @param callback      (Optional) Execute callback when initialize has finished.
    function self:Initialize(callback)
        if (self.db.debug) then self.display:Print("..Initialize Community Panel") end
		if (self.db.options.community.show) then
			self:ShowFull()
		else
			self:HideFull()
		end
		self:ListenNetworkSvc()
		if (callback ~= nil) then
			callback()
		end
	end
    ---------------------------------------------------------------------------
    --- Monitor the addon communication network for events.
    function self:ListenNetworkSvc()
		if (self.listening == false) then
			self.networkSvc:SetCallback(function(message)
				local elements = OracleHUD_StringSplit(message, ":")
				local member = self:GetMember(elements[2])
				if (elements[3] == "hello" or elements[3] == "helloWhisper" or member == nil) then
					member = self:SetMemberOnline(elements[2])
					member.frame:Notify()
				end
				if (elements[3] == "goodbye") then
					self:SetMemberOffline(elements[2])
				end
				if (elements[3] == "petBattleWon") then
					self:PetBattleWon(member)
				end
				if (elements[3] == "petBattleLost") then
					self:PetBattleLost(member)
				end
				if (elements[3] == "petLevelMax") then
					self:PetLevelMax(member, elements[4])
				end
				if (elements[3] == "petLevel") then
					self:PetLevel(member, elements[4], elements[5])
				end
				if (elements[3] == "petCaptured") then
					self:PetCaptured(member, elements[4], elements[5])
				end
			end)
			self.listening = true
		end
    end
	---------------------------------------------------------------------------
	--- Get the next available open index. Re-use the assigned frame.
	function self:GetAvailableIndex()
		local nextIndex = 1
		for i = 1, (self.online.total + 1) do
			if (self.online.players[i] == nil or self.online.players[i].active == false) then
				nextIndex = i
				break
			end
		end
		return nextIndex
	end
	---------------------------------------------------------------------------
	--- Get the member object of a player if they already exist.
	-- @param playerId		Player GUID.
	function self:GetMember(playerId)
		local member = nil
		for k, v in pairs(self.online.players) do
			if (v.id == playerId) then
				member = v
				break
			end
		end
		return member
	end
	---------------------------------------------------------------------------
	--- Indicate member has won a pet battle.
	-- @param member		Member object as defined in SetMemberOnline()
	function self:PetBattleWon(member)
		self.display:Print(member.name.." has won a pet battle!")
	end
	---------------------------------------------------------------------------
	--- Indicate member has lost a pet battle.
	-- @param member		Member object as defined in SetMemberOnline()
	function self:PetBattleLost(member)
		self.display:Print(member.name.." lost a pet battle! Because they are a looser.")
	end
	---------------------------------------------------------------------------
	--- Indicate member has raised a pet to maximum level.
	-- @param member		Member object as defined in SetMemberOnline()
	-- @param petName		Name of the pet.
	function self:PetLevelMax(member, petName)
		self.display:Print(member.name.." maxed pet "..petName)
		member.frame:Notify()
	end
	---------------------------------------------------------------------------
	--- Indicate member has raised a pet one level.
	-- @param member		Member object as defined in SetMemberOnline()
	-- @param petName		Name of the pet.
	-- @param level			New level of pet.
	function self:PetLevel(member, petName, level)
		self.display:Print(member.name.." leveled pet "..petName.." to "..level)
	end
	---------------------------------------------------------------------------
	--- Indicate member has captured a new pet.
	-- @param member		Member object as defined in SetMemberOnline()
	-- @param speciesId		Species identifyer of pet.
	-- @param name			Name of pet.
	function self:PetCaptured(member, speciesId, name)
		self.display:Print(member.name.." captured "..name)
		member.frame:Notify()
	end
	---------------------------------------------------------------------------
	--- Add a player to the online list.
	-- @param playerId		Player GUID.
	function self:SetMemberOnline(playerId)
		-- C_PlayerInfo.GetDisplayID()
		local member = self:GetMember(playerId)
		if (member ~= nil) then 
			member.active = true
			member.frame:ShowFull()
			self.display:Print(member.name.." returns!")
		else
			local locClass, engClass, locRace, engRace, gender, name, server = GetPlayerInfoByGUID(playerId)
			local nextIndex = self:GetAvailableIndex()
			member = {}
			if (self.online.players[nextIndex] ~= nil) then
				member = self.online.players[nextIndex]
			else
				self.online.players[nextIndex] = member
				member.frame = CreateFrame("Frame", playerId, self.Bar, "OracleHUD_PB_PanelCommunityMemberTemplate")
				if (nextIndex == 1) then
					member.frame:SetPoint("TOPLEFT", self.Bar, "TOPLEFT", 0, 0)
				else
					member.frame:SetPoint("TOPLEFT", self.online.players[nextIndex - 1].frame, "TOPRIGHT", 2, 0)
				end
				member.frame:SetPoint("BOTTOM", self.Bar, "BOTTOM", 0, 0)
				member.frame:SetWidth(member.frame:GetHeight())
				member.frame:Configure(self.db, self.display, self.petInfoSvc, self.networkSvc)
				member.frame:Initialize()
			end
			member.frame:SetPetInfo(self.petInfoSvc:GetPetInfoBySpeciesId(1660))
			member.frame:SetName(name)
			member.frame:ShowFull()
			member.id = playerId
			member.active = true
			member.name = name
			member.server = server
			self.online.total = self.online.total + 1
		end
		self:SetOnlineText(self.online)
		return member
	end
	---------------------------------------------------------------------------
	--- Remove player from the online list.
	-- @param playerId		Player GUID.
	function self:SetMemberOffline(playerId)
		for k, v in pairs(self.online.players) do
			if (v.id == playerId) then
				self.display:Print(v.name.." says goodbye!")
				v.active = false
				v.frame:HideFull()
				self.online.total = self.online.total - 1
				break
			end
		end
		self:SetOnlineText(self.online.players)
	end
	---------------------------------------------------------------------------
	--- Set online list with names of all players currently online.
	-- @param players		Table of players currently online.
	function self:SetOnlineText(players)
		local total = OracleHUD_TableGetLength(players)
		local text = ""
		for k, v in pairs(self.online.players) do
			if (v.active == true) then
				--local image = '<img src="'..pets[i].icon..'" />'
				--image = "|T"..pets[i].icon..":30|t"
				--href = '<a href="'..pets[i].speciesId..'">'..image..'</a>'
				text = text..v.name.."<br />"
			end
		end
		--self.Online:SetText("<html><body><p>"..text.."</p></body></html>")
	end
	---------------------------------------------------------------------------
	--- Print a message.
	--- @param message string	Message to print.
	--- @return nil
	function self:Print(message)
		self.display:Print(message)
	end
    ---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
	end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
	function self:OnSizeChanged_PanelCommunityTemplate()
		for k, v in pairs(self.online.players) do
			if (v.active == true) then
				v:SetWidth(v.frame:GetHeight())
				v:OnSizeChanged_PanelCommunityMemberTemplate()
			end
		end
	end
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:SetScript("OnSizeChanged", function()
		self:OnSizeChanged_PanelCommunityTemplate()
	end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
