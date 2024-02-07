--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_PanelLoadoutBattleTemplate_OnLoad(self)
    self._class = "OracleHUD_PB_PanelLoadoutBattleTemplate"
	self.HideFull = OracleHUD_FrameHideFull
    self.ShowFull = OracleHUD_FrameShowFull
    self.state = {
        originalWidth = self:GetWidth(),
        originalHeight = self:GetHeight()
    }
    -- Emulate inheritence even though we are composition.
    function self:AddSlot(panelLoadoutSlot) return self.Parent:AddSlot(panelLoadoutSlot) end
    function self:SetPetInfo(...) return self.Parent:SetPetInfo(...) end
    function self:SetCallback(...) return self.Parent:SetCallback(...) end
    function self:Revive(...) return self.Parent:Revive(...) end
    function self:GetSlotIndex(...) return self.Parent:GetSlotIndex(...) end
    function self:GetSummonedSlot(...) return self.Parent:GetSummonedSlot(...) end
    function self:Horizontal(...)
        self:SetWidth(self.state.originalWidth * (self:GetSlotIndex() - 1))
        self:SetHeight(self.state.originalHeight / (self:GetSlotIndex() - 1))
        local result = self.Parent:Horizontal(...)
        return result
    end
    function self:Vertical(...)
        self:SetWidth(self.state.originalWidth)
        self:SetHeight(self.state.originalHeight)
        local result = self.Parent:Vertical(...)
        return result
    end
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db			Oracle HUD Pet Battle database.
	--- @param  display     OracleHUD_PB_Display
    -- @param owner		    Enum.BattlePetOwner.Ally or Enum.BattlePetOwner.Enemy.
	--- @param combatLogSvc  OracleHUD_PB_CombatLogService
    -- @param c_petjournal	Wow's C_PetJournal or a mocked version.
    -- @param c_petbattles  Wow's C_PetBattles or a mocked version.
    -- @param petAnimEnum	ORACLEHUD_PB_DB_PET_ANIMATION_ENUM
    --- @param petInfoSvc   OracleHUD_PB_PetInfoService     PetInfo Service.
    -- @param combatLogSvc  OracleHUD Combat Log Service.
	-- @param options		OracleHUD Interface Options.
	-- @param zoo			(Optional) Frame of the zoo.
    --- @param tooltipPetInfo	OracleHUD_PB_TooltipPetInfo
    function self:Configure(db, display, owner, network, combatLogSvc, c_petjournal, c_petbattles, petAnimEnum,
                            petInfoSvc, options, zoo, tooltipPetInfo)
        if (db == nil or display == nil or owner == nil or network == nil or combatLogSvc == nil or c_petjournal == nil or 
            c_petbattles == nil or petAnimEnum == nil or petInfoSvc == nil or options == nil)
        then
            error(self._class..":Configure(): Invalid arguments.")
        end
        self.db = db
        self:ConfigureDB(db)
        self.display = display
        self.owner = owner
        self.network = network
        self.c_petjournal = c_petjournal
        self.c_petbattles = c_petbattles
        self.petInfoSvc = petInfoSvc
        self.combatLogSvc = combatLogSvc
        self.petAnimEnum = petAnimEnum
        self.options = options
        self.zoo = zoo
        self.tooltipPetInfo = tooltipPetInfo
        for i = 1, 3 do
            local slot = CreateFrame("Frame", "$parentSlot"..self:GetSlotIndex(), 
                               self.Parent, "OracleHUD_PB_PanelLoadoutBattleSlotTemplate")
            slot:Configure(db, display, self:GetSlotIndex(), owner, network, combatLogSvc, c_petjournal, c_petbattles, 
                           petAnimEnum, petInfoSvc, options, zoo, tooltipPetInfo)
            self:AddSlot(slot)
        end
        if (owner == Enum.BattlePetOwner.Ally) then
            self:Configure_Location()
            if (db.modules.loadout.options.allyHorizontal == true) then
                self:Horizontal()
            end
        else
            if (db.modules.loadout.options.enemyHorizontal == true) then
                self:Horizontal()
            end
       end
        return self.Parent:Configure(db, c_petjournal)
    end
    function self:Configure_Location()
        if (self.db.mainPanel ==  nil) then
            self.db.mainPanel = {
                position = {
                    point = nil,
                    relativeTo = nil,
                    relativePoint = nil,
                    x = nil,
                    y = nil
                }
            }
        end
        if (self.db.mainPanel.position.point ~= nil) then
			self:ClearAllPoints()
			self:SetPoint(
				self.db.mainPanel.position.point,
				ParentUI,
				self.db.mainPanel.position.relativePoint,
				self.db.mainPanel.position.x,
				self.db.mainPanel.position.y)
		end
		self.texture = self:CreateTexture(nil, "OVERLAY")
		self.texture:SetAllPoints(self)
		self.texture:SetColorTexture(0.1, 0.1, 0.1, 0)
		self:EnableMouse(true)
        self:RegisterForDrag("LeftButton")
		self:HookScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
			local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
			self.db.mainPanel.position.point = point
			self.db.mainPanel.position.relativeTo = relativeTo
			self.db.mainPanel.position.relativePoint = relativePoint
			self.db.mainPanel.position.x = xOfs
			self.db.mainPanel.position.y = yOfs
		end)
    end
    ---------------------------------------------------------------------------
    --- Setup variables for long term storage in the database.
    --- @param  db 		OracleHUD_PB_DB     OracleHUD Pet Battles Database.
    function self:ConfigureDB(db)
        if (db.modules == nil) then db.modules = {} end
        if (db.modules.loadout == nil) then
            db.modules.loadout = {
                options = {
                    afterBattleQuip = true,
                    showOpponents = true,
                    show = true,
                    allyHorizontal = false
                }
            }
        end
        if (db.modules.loadout.options.allyHorizontal == nil) then
            db.modules.loadout.options.allyHorizontal = false
        end
    end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    -- @param callback      (Optional) Execute callback when initialize has finished.
    function self:Initialize(callback)
        if (self.db.debug) then print("..Initialize Loadout") end
        if (self:GetSlotIndex() > 1) then
            for i = 1, (self:GetSlotIndex() - 1) do
                self.Parent["Slot"..i]:Initialize()
            end
        end
        self:HookPetSummonButtons()
        self:HookPetCallButtons()
        if (self.combatLogSvc:IsInBattle()) then
            self:OnPetBattleOpen()
        else
            self:RefreshPetInfo()
            self:OnPetBattleClose()
        end
        self:RegisterEvent("PET_BATTLE_PET_CHANGED")
		if (self.owner == Enum.BattlePetOwner.Enemy) then
			if (self.db.modules.loadout.options.showOpponents == true) then
				self:ShowFull()
			else
				self:HideFull()
			end
		end
		if (self.owner == Enum.BattlePetOwner.Ally) then
			if (self.db.modules.loadout.options.show == true) then
				self:ShowFull()
			else
				self:HideFull()
			end
		end
        self:ListenCombatLog()
        if (callback) then
            callback()
        end
    end
    ---------------------------------------------------------------------------
    --- Match frame state to actual game state.
    function self:Update()
    end
    ---------------------------------------------------------------------------
    --- Determine if the panel should be shown
    function self:ShouldShow()
        local shouldShow = true
        return shouldShow
    end
    ---------------------------------------------------------------------------
    --- Refresh pet slots state to match actual game state.
    function self:RefreshPetInfo()
        if (self.owner == Enum.BattlePetOwner.Ally or self.c_petbattles.IsInBattle() == true) then
            local max = 3
            if (self.owner == Enum.BattlePetOwner.Enemy) then
                max = C_PetBattles.GetNumPets(self.owner)
            end
            for i = 1, max do
                local petInfo = self.petInfoSvc:GetPetInfoBySlot(i, self.db, self.owner)
                if (petInfo == nil) then
                    error(self._class..":RefreshPetInfo(): petInfo is nil on owner "..self.owner.." at index "..i)
                end
                self:SetPetInfo(petInfo, i)
            end
            self:SetSummonedStatus(self:GetSummonedSlot())
        end
    end
    ---------------------------------------------------------------------------
    --- Get the loadout index of the current pet on battlefield.
    function self:GetActivePet()
        local battleSlot = C_PetBattles.GetActivePet(self.owner)
        local journalSlot = self.petInfoSvc:GetJournalOrderSlot(
            battleSlot,
            self.db,
            self.owner,
            self.combatLogSvc:GetBattleOrder())
        return journalSlot
    end
    ---------------------------------------------------------------------------
    --- Inform each slot if they are the currently active pet.
    -- @param journalSlot   Journal order slot number of active pet (1-3)
    function self:SetActivePet(journalSlot)
        if (self:GetSlotIndex() > 1) then
            for i = 1, (self:GetSlotIndex() - 1) do
                self.Parent["Slot"..i]:SetActivePet(journalSlot == i)
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Set each slot to be in or out of battle (display battle buttons)
    -- @param inBattle      In battle or out of battle (true, false)
	function self:SetInBattle(inBattle)
        if (self:GetSlotIndex() > 1) then
            for i = 1, (self:GetSlotIndex() - 1) do
                self.Parent["Slot"..i]:SetInBattle(inBattle)
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Set each slot to be in summoned or unsummoned state (display summon/speak buttons).
    -- @param slot      Slot that is currently summoned. (0 or nil to set all
    --                  slot status to unsummoned)
	function self:SetSummonedStatus(slot)
        if (self:GetSlotIndex() > 1) then
            for i = 1, (self:GetSlotIndex() - 1) do
                if (slot == nil or slot == 0) then
                    self.Parent["Slot"..i]:SetSummonedStatus(false)
                else
                    self.Parent["Slot"..i]:SetSummonedStatus(i == slot)
                end
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Process event PET_BATTLE_OPENING_START
    function self:OnPetBattleOpen()
        if (self.db.modules.loadout.options.showOpponents and self.owner == Enum.BattlePetOwner.Enemy) then
            self:ShowFull()
        end
        if (self.db.modules.loadout.options.show and self.owner == Enum.BattlePetOwner.Ally) then
            self:ShowFull()
        end
        self.close = nil
        self:RefreshPetInfo()
        self:SetInBattle(true)
        self:SetActivePet(self:GetActivePet())
        if (self.owner == Enum.BattlePetOwner.Enemy) then
            local numPets = C_PetBattles.GetNumPets(Enum.BattlePetOwner.Enemy)
            if (numPets == 3) then
            end
            if (numPets == 2) then
                self.Parent.Slot3:HideFull()
            end
            if (numPets == 1) then
                self.Parent.Slot2:HideFull()
                self.Parent.Slot3:HideFull()
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Process event PET_BATTLE_CLOSE
    function self:OnPetBattleClose()
        self:SetInBattle(false)
        self:SetActivePet(0)
        if (self.owner == Enum.BattlePetOwner.Enemy) then
            C_Timer.After(3, function()
                self:HideFull()
                self.Parent.Slot1:ShowFull()
                self.Parent.Slot2:ShowFull()
                self.Parent.Slot3:ShowFull()
            end)
        end
    end
    ---------------------------------------------------------------------------
    --- Pets mourn after a loss.
    function self:OnPetBattleLost()
        if (self.owner == Enum.BattlePetOwner.Ally and self.db.modules.loadout.options.afterBattleQuip) then
            local random = math.random(1, 3)
            if (random == 1) then
                for i = 1, (self:GetSlotIndex() - 1) do
                    if (self.Parent["Slot"..i]:CanSpeak(ORACLEHUD_PB_CONTENTEMOTE_ENUM.SPEAK_LOSS)) then
                        self.Parent["Slot"..i]:Speak(ORACLEHUD_PB_CONTENTEMOTE_ENUM.SPEAK_LOSS)
                        break
                    end
                end
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Pets celebrate after a win.
    function self:OnPetBattleWon()
        if (self.owner == Enum.BattlePetOwner.Ally and self.db.modules.loadout.options.afterBattleQuip) then
            local random = math.random(1, 3)
            if (random == 1) then
                for i = 1, (self:GetSlotIndex() - 1) do
                    if (self.Parent["Slot"..i]:CanSpeak(ORACLEHUD_PB_CONTENTEMOTE_ENUM.SPEAK_WIN)) then
                        self.Parent["Slot"..i]:Speak(ORACLEHUD_PB_CONTENTEMOTE_ENUM.SPEAK_WIN)
                        break
                    end
                end
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Process event PET_BATTLE_PET_CHANGED
    -- @param owner     Owner of the pet. Enum.BattlePetOwner.
    function self:PetBattlePetChanged(owner)
        if (owner == self.owner) then
            self:SetActivePet(self:GetActivePet())
        end
    end
    ---------------------------------------------------------------------------
    --- Listen to combat log events
    function self:ListenCombatLog()
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.OPEN, function(loadoutOnOpen)
            self:OnPetBattleOpen()
        end)
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.CLOSE, function(statsTotal, statsBattle)
            self:OnPetBattleClose()
        end)
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.WON, function(statsTotal, statsBattle)
            self:OnPetBattleWon()
        end)
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.LOST, function(statsTotal, statsBattle)
            self:OnPetBattleLost()
        end)
    end
    ---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
        if (eventName == "PET_BATTLE_PET_CHANGED") then
			local owner = ...
            self:PetBattlePetChanged(owner)
        end
    end
    ---------------------------------------------------------------------------
    --- Refresh pet loadout from pet journal.
	function self:HookPetJournalHide()
		self.myTimer:Cancel()
        self:RefreshPetInfo()
	end
    ---------------------------------------------------------------------------
    --- Show the summoned pet, show speak button. Hide all other speak buttons.
    -- @param button        Frame of speak button that was clicked on.
    -- @param slot          Journal slot the button is located in.
    function self:OnPetSummonClick(button, slot)
        C_Timer.After(1, function()
            if (self.c_petjournal.GetSummonedPetGUID() == button.petInfo.id) then
                SendChatMessage(button.petInfo:GetEmote(ORACLEHUD_PB_CONTENTEMOTE_ENUM.EMOTE_SUMMON), "EMOTE")
                self:SetSummonedStatus(slot)
            end
        end)
    end
    ---------------------------------------------------------------------------
    --- Hook pet summon button click from all slots.
	function self:HookPetSummonButtons()
        if (self:GetSlotIndex() > 1) then
            for i = 1, (self:GetSlotIndex() - 1) do
                self.Parent["Slot"..i].OutCombat.Summon:SetCallback(function(button, slot)
                    self:OnPetSummonClick(button, slot)
                end)
            end
        end
	end
    ---------------------------------------------------------------------------
    --- Hook pet summon button click from all slots.
	function self:HookPetCallButtons()
        if (self:GetSlotIndex() > 1) then
            for i = 1, (self:GetSlotIndex() - 1) do
                self.Parent["Slot"..i]:SetCallCallback(function(slot)
                    C_PetBattles.ChangePet(slot)
                    self:SetActivePet(slot)
                end)
            end
        end
	end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
    function self:OnSizeChanged_PanelLoadoutBattleTemplate()
        OracleHUD_FrameSetSizePct(self.Parent, 1.0, 1.0)
    end
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_PanelLoadoutBattleTemplate()
	end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
	-- Poll for the existence of the PetJournal, which does not exist until it is first opened.
	self.myTimer = C_Timer.NewTicker(4, function() 
		if (_G["PetJournal"] ~= nil) then
			PetJournal:HookScript("OnHide", function()
				self:HookPetJournalHide()
			end)
			self:HookPetJournalHide()
		end
	end)
end
