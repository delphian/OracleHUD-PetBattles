--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_PanelPetBattleLoadoutTemplate_OnLoad(self)
    self._class = "OracleHUD_PB_PanelLoadoutBattleTemplate"
	self.HideFull = OracleHUD_FrameHideFull
    self.ShowFull = OracleHUD_FrameShowFull
    self.slotIndex = 1
    self.callback = nil
    self.state = {
        originalWidth = self:GetWidth(),
        originalHeight = self:GetHeight(),
        horizontal = false
    }
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
        self:ConfigureDB(db)
        for i = 1, 3 do
            local slot = CreateFrame("Frame", "$parentSlot"..self:GetSlotIndex(), 
                               self, "OracleHUD_PB_PanelPetBattleLoadoutSlotTemplate")
            slot:Configure(db, display, self:GetSlotIndex(), owner, network, combatLogSvc, c_petjournal, c_petbattles, 
                           petAnimEnum, petInfoSvc, options, zoo, tooltipPetInfo)
            self:AddSlot(slot)
        end
        if (owner == Enum.BattlePetOwner.Ally) then
            self:Configure_Location()
        end
    end
    ---------------------------------------------------------------------------
    --- Restore frame location to saved variables values. Both in and out of battle locations are remembered.
    function self:Configure_Location()
        if (self.combatLogSvc:IsInBattle()) then
            self:SetFramePosition(self.db.modules.loadout.position.inbattle[self.owner])
        else
            self:SetFramePosition(self.db.modules.loadout.position.outbattle[self.owner])
        end
		self.texture = self:CreateTexture(nil, "OVERLAY")
		self.texture:SetAllPoints(self)
		self.texture:SetColorTexture(0.1, 0.1, 0.1, 0)
		self:EnableMouse(true)
        self:RegisterForDrag("LeftButton")
        self:SetScript("OnDragStart", function(self, button)
            self:StartMoving()
        end)
		self:HookScript("OnDragStop", function(self)
			self:StopMovingOrSizing()
            if (self.combatLogSvc:IsInBattle()) then
                local position = self.db.modules.loadout.position.inbattle[self.owner]
                local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
                position.point = point
                position.relativeTo = relativeTo
                position.relativePoint = relativePoint
                position.x = xOfs
                position.y = yOfs
            else
                local position = self.db.modules.loadout.position.outbattle[self.owner]
                local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
                position.point = point
                position.relativeTo = relativeTo
                position.relativePoint = relativePoint
                position.x = xOfs
                position.y = yOfs
            end
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
                    allyHorizontalOut = false,
                    allyHorizontalIn = false,
                    enemyHorizontalOut = false,
                    enemyHorizontalIn = false
                },
                position = {
                    outbattle = {
                        [Enum.BattlePetOwner.Ally] = {},
                        [Enum.BattlePetOwner.Enemy] = {}
                    },
                    inbattle = {
                        [Enum.BattlePetOwner.Ally] = {},
                        [Enum.BattlePetOwner.Enemy] = {}
                    }
                }
            }
        end
        --- Differential update
        if (db.modules.loadout.position == nil) then db.modules.loadout.position = {} end
        if (db.modules.loadout.position.outbattle == nil) then db.modules.loadout.position.outbattle = {
            [Enum.BattlePetOwner.Ally] = {},
            [Enum.BattlePetOwner.Enemy] = {}
        } end
        if (db.modules.loadout.position.inbattle == nil) then db.modules.loadout.position.inbattle = {
            [Enum.BattlePetOwner.Ally] = {},
            [Enum.BattlePetOwner.Enemy] = {}
        } end
        if (self.db.modules.loadout.position.inbattle[self.owner] == nil) then
            self.db.modules.loadout.position.inbattle[self.owner] = {
                point = nil,
                relativeTo = nil,
                relativePoint = nil,
                x = nil,
                y = nil
            }
        end
        if (self.db.modules.loadout.position.outbattle[self.owner] == nil) then
            self.db.modules.loadout.position.outbattle[self.owner] = {
                point = nil,
                relativeTo = nil,
                relativePoint = nil,
                x = nil,
                y = nil
            }
        end
        --- End differential update.
    end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    -- @param callback      (Optional) Execute callback when initialize has finished.
    function self:Initialize(callback)
        if (self.db.debug) then print("..Initialize Loadout") end
        if (self:GetSlotIndex() > 1) then
            for i = 1, (self:GetSlotIndex() - 1) do
                self["Slot"..i]:Initialize()
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
    --- Get the next slot index to be assigned.
    function self:GetSlotIndex()
        return self.slotIndex
    end
    ---------------------------------------------------------------------------
    --- Add an already created loadout slot frame
    -- @param panelLoadoutSlot  A frame which inherits from PanelLoadoutSlotTemplate
    function self:AddSlot(panelLoadoutSlot)
        panelLoadoutSlot:SetParent(self)
        self["Slot"..self:GetSlotIndex()] = panelLoadoutSlot
        panelLoadoutSlot:ClearAllPoints()
        if (self:GetSlotIndex() == 1) then
            panelLoadoutSlot:SetPoint("TOP", self, "TOP")
            panelLoadoutSlot:SetPoint("LEFT", self, "LEFT")
            panelLoadoutSlot:SetPoint("RIGHT", self, "RIGHT")
        else
            local previousSlot = self["Slot"..(self:GetSlotIndex() - 1)]
            panelLoadoutSlot:SetPoint("TOP", previousSlot, "BOTTOM")
            panelLoadoutSlot:SetPoint("LEFT", self, "LEFT")
            panelLoadoutSlot:SetPoint("RIGHT", self, "RIGHT")
        end
        self.slotIndex = self:GetSlotIndex() + 1
        self:OnSizeChanged()
    end
    ---------------------------------------------------------------------------
    --- Arrange the loadout horizontally.
    function self:Horizontal()
        self:SetWidth(self.state.originalWidth * (self:GetSlotIndex() - 1))
        self:SetHeight(self.state.originalHeight / (self:GetSlotIndex() - 1))
        for i = 1, (self:GetSlotIndex() - 1) do
            local slot = self:GetSlot(i)
            slot:ClearAllPoints()
            if (i == 1) then
                slot:SetPoint("TOPLEFT", self, "TOPLEFT", 4, 0)
            else
                slot:SetPoint("TOPLEFT", self["Slot"..(i - 1)], "TOPRIGHT", 8, 0)
            end
            slot:Horizontal()
        end
        self.state.horizontal = true
        self:OnSizeChanged()
    end
    ---------------------------------------------------------------------------
    function self:IsHorizontal()
        return self.state.horizontal
    end
    ---------------------------------------------------------------------------
    --- Arrange the loadout horizontally.
    function self:Vertical()
        self:SetWidth(self.state.originalWidth)
        self:SetHeight(self.state.originalHeight)
        for i = 1, (self:GetSlotIndex() - 1) do
            local slot = self:GetSlot(i)
            slot:ClearAllPoints()
            if (i == 1) then
                slot:SetPoint("TOP", self, "TOP", 0, 0)
                slot:SetPoint("LEFT", self, "LEFT", 0, 0)
                slot:SetPoint("RIGHT", self, "RIGHT", 0, 0)
            else
                slot:SetPoint("TOP", self["Slot"..(i - 1)], "BOTTOM", 0, 0)
                slot:SetPoint("LEFT", self, "LEFT", 0, 0)
                slot:SetPoint("RIGHT", self, "RIGHT", 0, 0)
            end
            slot:Vertical()
        end
        self.state.horizontal = false
        self:OnSizeChanged()
    end
    ---------------------------------------------------------------------------
    --- Register a callback that will be executed when events happen.
    function self:SetCallback(callback)
        self.callback = callback
    end
    ---------------------------------------------------------------------------
    --- Visually revive pets in all battle slots of loadout.
	function self:Revive()
        for i = 1, (self.slotIndex - 1) do
            local slot = self["Slot"..i]
			slot:SetHealth(slot.petInfo.healthMax, slot.petInfo.healthMax)
		end
	end
    ---------------------------------------------------------------------------
    --- Load a pet into a slot.
	--- @param petInfo	OracleHUD_PB_PetInfo		OracleHUD_PB Uniform pet table.
    -- @param slot      Slot number to load pet into.
    function self:SetPetInfo(petInfo, slot)
        if (petInfo == nil or slot == nil) then
            error("OracleHUD_PB_PanelLoadoutTemplate:SetPetInfo(): Invalid arguments")
		end
        self["Slot"..slot]:SetPetInfo(petInfo)
    end
    ---------------------------------------------------------------------------
    function self:GetNumSlots()
        return self:GetSlotIndex() - 1
    end
    ---------------------------------------------------------------------------
    --- If the currently summoned pet is loaded into a slot, return the slot number.
    function self:GetSummonedSlot()
        local summonedSlot = nil
        local summonedPetId = self.c_petjournal.GetSummonedPetGUID()
        if (summonedPetId ~= nil) then
            if (self:GetSlotIndex() > 1) then
                for i = 1, (self:GetSlotIndex() - 1) do
                    if (self["Slot"..i].petInfo ~= nil and summonedPetId == self["Slot"..i].petInfo.id) then
                        summonedSlot = i
                        break
                    end
                end
            end
        end
        return summonedSlot
    end
    ---------------------------------------------------------------------------
    --- Set frame location to last saved while in a pet battle.
    function self:SetFramePosition(position)
        if (position.point ~= nil) then
            self:ClearAllPoints()
            self:SetPoint(
                position.point,
                ParentUI,
                position.relativePoint,
                position.x,
                position.y)
        end
        if (self.owner == Enum.BattlePetOwner.Ally) then
            if ((self.db.modules.loadout.options.allyHorizontalOut == true and
                 self.combatLogSvc:IsInBattle() == false)
                 or 
                (self.db.modules.loadout.options.allyHorizontalIn == true and
                 self.combatLogSvc:IsInBattle() == true))
            then
                self:Horizontal()
            else
                self:Vertical()
            end
        else
            if ((self.db.modules.loadout.options.enemyHorizontalOut == true and
                 self.combatLogSvc:IsInBattle() == false)
                 or 
                (self.db.modules.loadout.options.enemyHorizontalIn == true and
                 self.combatLogSvc:IsInBattle() == true))
            then
                self:Horizontal()
            else
                self:Vertical()
            end
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
                self["Slot"..i]:SetActivePet(journalSlot == i)
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Set each slot to be in or out of battle (display battle buttons)
    -- @param inBattle      In battle or out of battle (true, false)
	function self:SetInBattle(inBattle)
        if (self:GetSlotIndex() > 1) then
            for i = 1, (self:GetSlotIndex() - 1) do
                self["Slot"..i]:SetInBattle(inBattle)
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
                    self["Slot"..i]:SetSummonedStatus(false)
                else
                    self["Slot"..i]:SetSummonedStatus(i == slot)
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
        if (self.db.modules.loadout.options.hideDefault) then
            _G["PetBattleFrame"]:Hide()
        end
        self:SetFramePosition(self.db.modules.loadout.position.inbattle[self.owner])
        if (self.owner == Enum.BattlePetOwner.Enemy) then
            local numPets = C_PetBattles.GetNumPets(Enum.BattlePetOwner.Enemy)
            if (numPets == 3) then
            end
            if (numPets == 2) then
                self.Slot3:HideFull()
            end
            if (numPets == 1) then
                self.Slot2:HideFull()
                self.Slot3:HideFull()
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Process event PET_BATTLE_CLOSE
    function self:OnPetBattleClose()
        self:SetInBattle(false)
        self:SetActivePet(0)
        self:SetFramePosition(self.db.modules.loadout.position.outbattle[self.owner])
        if (self.owner == Enum.BattlePetOwner.Enemy) then
            C_Timer.After(3, function()
                self:HideFull()
                self.Slot1:ShowFull()
                self.Slot2:ShowFull()
                self.Slot3:ShowFull()
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
                    if (self["Slot"..i]:CanSpeak(ORACLEHUD_PB_CONTENTEMOTE_ENUM.SPEAK_LOSS)) then
                        self["Slot"..i]:Speak(ORACLEHUD_PB_CONTENTEMOTE_ENUM.SPEAK_LOSS)
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
                    if (self["Slot"..i]:CanSpeak(ORACLEHUD_PB_CONTENTEMOTE_ENUM.SPEAK_WIN)) then
                        self["Slot"..i]:Speak(ORACLEHUD_PB_CONTENTEMOTE_ENUM.SPEAK_WIN)
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
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.APPLY, function(owner, jSlot, abilityId, turnsRemaining, isBuff)
            self:OnAuraApplied(owner, jSlot, abilityId, turnsRemaining, isBuff)
        end)
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.FADE, function(owner, jSlot, abilityId, turnsRemaining, isBuff)
            self:OnAuraFade(owner, jSlot, abilityId, turnsRemaining, isBuff)
        end)
        self.combatLogSvc:SetCallback(self.combatLogSvc.ENUM.ROUNDEND, function(...)
            self:OnRoundEnd(...)
        end)
    end
    ---------------------------------------------------------------------------
    --- Get a slot object.
    --- @param  jSlot   number
    function self:GetSlot(jSlot)
        return self["Slot"..jSlot]
    end
    ---------------------------------------------------------------------------
    --- Add aura icons and speed hints.
    --- @param  owner           Enum.BattlePetOwner
    --- @param  jSlot           number                  Journal order slot.
    --- @param  abilityId       number                  Ability that created the aura.
    --- @param  turnsRemaining  number                  Number of turns aura will be applied.
    --- @param  isBuff          boolean                 Aura is intended to be displayed to user.
    function self:OnAuraApplied(owner, jSlot, abilityId, turnsRemaining, isBuff)
        if (owner == self.owner) then
            local slot = self:GetSlot(jSlot)
            slot:AuraApply(abilityId, turnsRemaining, isBuff)
        end
    end
    ---------------------------------------------------------------------------
    --- Remove aura icons and speed hints.
    --- @param  owner           Enum.BattlePetOwner
    --- @param  jSlot           number                  Journal order slot.
    --- @param  abilityId       number                  Ability that created the aura.
    --- @param  turnsRemaining  number                  Number of turns aura will be applied.
    --- @param  isBuff          boolean                 Aura is intended to be displayed to user.
    function self:OnAuraFade(owner, jSlot, abilityId, turnsRemaining, isBuff)
        if (owner == self.owner) then
            local slot = self:GetSlot(jSlot)
            slot:AuraFade(abilityId)
        end
    end
    ---------------------------------------------------------------------------
    --- Update auras each time the round ends.
    function self:OnRoundEnd(...)
--[[
        if (self.owner == Enum.BattlePetOwner.Ally) then
            local numSlots = self:GetNumSlots()
            for i = 1, numSlots do
                local slot = self:GetSlot(i)
                local auras = slot:GetAuras()
            end
        end
--]]
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
                self["Slot"..i].Right.ButtonsBorder.Buttons.OutCombat.Summon:SetCallback(function(button, slot)
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
                self["Slot"..i]:SetCallCallback(function(slot)
                    C_PetBattles.ChangePet(slot)
                    self:SetActivePet(slot)
                end)
            end
        end
	end
    ---------------------------------------------------------------------------
    --- Dynamically resize all child elements when frame changes size.
    function self:OnSizeChanged()
        if (self.slotIndex > 1) then
            for i = 1, (self.slotIndex - 1) do
                local slot = self:GetSlot(i)
                if (self:IsHorizontal()) then
                    OracleHUD_FrameSetSizePct(slot, 0.3333, 1.0)
                else
                    OracleHUD_FrameSetSizePct(slot, 1.0, 0.3333)
                end
            end
        end
    end
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
	self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged()
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
