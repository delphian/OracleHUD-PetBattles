--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_ZooTemplate_OnLoad(self)
	self.HideFull = OracleHUD_FrameHideFull
    self.ShowFull = OracleHUD_FrameShowFull
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db		    Oracle HUD Pet Battle database.    
    -- @param networkSvc    Oracle HUD Network Service.
	-- @param petInfoSvc	Oracle HUD Pet Information Service.
	-- @param options		OracleHUD Interface Options.
	function self:Configure(db, networkSvc, petInfoSvc, options)
        if (db == nil or networkSvc == nil or petInfoSvc == nil or
            options == nil)
        then
            error("OracleHUD_PB_ZooTemplate:Configure(): Invalid arguments.")
		end
        self.db = db
        self.petSize = 45
        self.zooPets = {}
        self.networkSvc = networkSvc
        self.petInfoSvc = petInfoSvc
        self.options = options
        self.Chat:Configure(db, 12)
        self:ListenNetwork()
    end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    -- @param callback      (Optional) Execute callback when initialize has finished.
    function self:Initialize(callback)
        if (self.db.debug) then print("..Initialize Zoo Panel") end
        if (self.options:GetZooShow() == true and #self.zooPets > 0) then
            self:ShowFull()
        end
        self:RegisterEvent("PET_BATTLE_OPENING_START")
        self:RegisterEvent("PET_BATTLE_OVER")
		if (callback ~= nil) then
			callback()
		end
    end
    ---------------------------------------------------------------------------
    --- Find the zoo pet meta information object for an identifier
    -- @param uuid      A zoo pet unique identifier
    function self:GetZooPet(uuid)
        local zooPet = nil
        for i = 1, #self.zooPets do
            if (self.zooPets[i].uuid == uuid) then
                zooPet = self.zooPets[i]
                break
            end
        end
        return zooPet
    end
    ---------------------------------------------------------------------------
    --- Monitor the addon communication network for events.
    function self:ListenNetwork()
        self.networkSvc:SetCallback(function(message)
            local elements = OracleHUD_StringSplit(message, ":")
            if (elements[3] == "adoption") then
                if (self:GetZooPet(elements[9]) == nil) then
                    local petInfo = self.petInfoSvc:GetPetInfoBySpeciesId(elements[4])
                    petInfo.healthMax = elements[5]
                    petInfo.power = elements[6]
                    petInfo.speed = elements[7]
                    petInfo.level = elements[8]
                    self:AdoptPet(petInfo, elements[2], elements[9])
                end
            end
            if (elements[3] == "petSizeUp") then
                local zooPet = self:GetZooPet(elements[4])
                if (zooPet ~= nil) then
                    zooPet.frame:Scale(1.25, 3)
                end
            end
            if (elements[3] == "petSizeDown") then
                local zooPet = self:GetZooPet(elements[4])
                if (zooPet ~= nil) then
                    zooPet.frame:Scale(0.80, 3)
                end
            end
        end)
    end
    ---------------------------------------------------------------------------
    --- Send out a pet adoption request over the network.
	--- @param petInfo	OracleHUD_PetInfo		OracleHUD_PB Uniform pet table.
    function self:RequestAdoptPet(petInfo)
        self.networkSvc:SendAdoption(petInfo, OracleHUD_UUID())
    end
    ---------------------------------------------------------------------------
    --- Send out a size up request over the network.
    -- @param zooPet    Meta information about a pet belonging inside a zoo.
    --                  Created by OracleHUD_PB_ZooTemplate:AdoptPet()
    function self:RequestSizeUp(zooPet)
        self.networkSvc:SendPetSizeUp(zooPet)
    end
    ---------------------------------------------------------------------------
    --- Send out a size down request over the network.
    -- @param zooPet    Meta information about a pet belonging inside a zoo.
    --                  Created by OracleHUD_PB_ZooTemplate:AdoptPet()
    function self:RequestSizeDown(zooPet)
        self.networkSvc:SendPetSizeDown(zooPet)
    end
    ---------------------------------------------------------------------------
    --- Create a frame of a pet animation suited to display in the zoo frame.
	--- @param petInfo	OracleHUD_PetInfo		OracleHUD_PB Uniform pet table.
    -- @param userGUID  Owner of the pet.
    -- @param uuid      A zoo pet unique identifier
    function self:AdoptPet(petInfo, userGUID, zooPetUUID)
		local frame = CreateFrame("Frame", "Zoo"..petInfo.name, self.Zoo, "OracleHUD_PB_ZooPetAnimationTemplate")
        local zooPet = {
            active = true,
            petInfo = petInfo,
            frame = frame,
            user = userGUID,
            uuid = zooPetUUID
        }
		frame:Configure(self.db, zooPet, self)
		frame:SetSize(self.petSize, self.petSize)
        frame:SetPoint("CENTER", self.Zoo, "CENTER")
        frame:Initialize()
        frame:SetSpeak(false)
        local xPct = random()
        if (random() > 0.5) then xPct = xPct * -1 end
        local yPct = random()
        if (random() > 0.5) then yPct = yPct * -1 end
        frame:SetOffsetByPct(xPct, yPct, self.Zoo, true)
        table.insert(self.zooPets, zooPet)
        self:Activate(zooPet)
        if (self.options:GetZooShow() == true and #self.zooPets > 0) then
            self:ShowFull()
        else
            self:HideFull()
        end
    end
    ---------------------------------------------------------------------------
    --- Cause the pet in the cage to begin exploring the zoo.
    -- @param zooPet    Meta information about a pet belonging inside a zoo.
    --                  Created by OracleHUD_PB_ZooTemplate:AdoptPet()
    function self:Activate(zooPet)
        zooPet.cancelToken = C_Timer.NewTicker(20, function()
            local rnd = math.random(1, 6)
            local distance = math.random(1, 50) / 100
            local time = math.random(5, 10)
            if (rnd == 1) then
                zooPet.frame:PlatformWalkUp(distance, time, true, self.Zoo)
            elseif (rnd == 2) then
                zooPet.frame:PlatformWalkDown(distance, time, true, self.Zoo)
            elseif (rnd == 3) then
                zooPet.frame:PlatformWalkLeft(distance, time, true, self.Zoo)
            elseif (rnd == 4) then
                zooPet.frame:PlatformWalkRight(distance, time, true, self.Zoo)
            elseif (rnd == 5 or rnd == 6) then
                -- print("wait")
            end
        end)
    end
    ---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
        if (self.db == nil) then
            print("OracleHUD_PB_ZooTemplate:OnEvent(): Configure() must be called first.")
        end
        if (eventName == "PET_BATTLE_OPENING_START") then
            self:HideFull()
        end
        if (eventName == "PET_BATTLE_OVER") then
            if (self.options:GetZooShow() == true and #self.zooPets > 0) then
                self:ShowFull()
            else
                self:HideFull()
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Dynamically resize all children elements when frame changes size.
    function self:OnSizeChanged_ZooTemplate()
        self.Image:SetSize(self:GetWidth(), self:GetHeight())
    end
    ---------------------------------------------------------------------------
    --- Dynamically resize all children elements when frame changes size.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_ZooTemplate()
    end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
