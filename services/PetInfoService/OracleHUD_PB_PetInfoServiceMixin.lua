--- Aggregate all pet information retrieval into a single authority.
--- @class OracleHUD_PB_PetInfoService : OracleHUD_PB_Service
OracleHUD_PB_PetInfoServiceMixin = CreateFromMixins(OracleHUD_PB_ServiceMixin)
OracleHUD_PB_PetInfoServiceMixin._class = "OracleHUD_PB_PetInfoServiceMixin"
--------------------------------------------------------------------------
--- Configure frame with required data.
--- @param db 		    OracleHUD_PB_DB	                OracleHUD Pet Battles Database.
--- @param combatLogSvc OracleHUD_PB_CombatLogService   OracleHUD Pet Battles Pet Information Service.
function OracleHUD_PB_PetInfoServiceMixin:Configure(db, combatLogSvc)
    if (db == nil or combatLogSvc == nil) then
        error(self._class..":Configure(): Invalid arguments.")
    end
    self.db = db
    self.combatLogSvc = combatLogSvc
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback function?   (Optional) Execute callback when initialize has finished.
function OracleHUD_PB_PetInfoServiceMixin:Initialize(callback)
    if (self.db.debug) then print("..Initialize Pet Info Service") end
    if (callback ~= nil) then
        callback()
    end
end
-------------------------------------------------------------------------------
--- Get the battle order of a journal order slot. In battle order slots with a dead pet do not count.
--- @param slot		    integer                 Slot as presented in pet journal order (1-3). A slot with a dead pet is counted.
--- @param db 		    OracleHUD_PB_DB	        OracleHUD Pet Battles Database.
--- @param owner	    Enum.BattlePetOwner?    (Optional) Ally or Enemy, defaults to Ally.
--- @param battleOrder  OracleHUD_PB_CombatLogService_BattleOrder   Battle order when battle first began.
--- @return number|nil
function OracleHUD_PB_PetInfoServiceMixin:GetBattleOrderSlot(slot, db, owner, battleOrder)
    if (slot == nil or db == nil or owner == nil or battleOrder == nil) then
        error(self._class..":GetBattleOrderSlot(): Invalid arguments")
    end
    local battleOrderSlot = nil
    if (owner == nil) then
        owner = Enum.BattlePetOwner.Ally
    end
    if (owner == Enum.BattlePetOwner.Ally) then
        for i = 1, battleOrder.ally.max do
            if (battleOrder.ally.order[i].slot == slot) then
                battleOrderSlot = i
                break;
            end
        end
    end
    if (owner == Enum.BattlePetOwner.Enemy) then
        for i = 1, battleOrder.enemy.max do
            if (battleOrder.enemy.order[i].slot == slot) then
                battleOrderSlot = i
                break;
            end
        end
    end
    return battleOrderSlot
end
-------------------------------------------------------------------------------
--- Get the journal order of a battle order slot. In battle order slots with a dead pet do not count.
--- @param slot		    integer                 Slot as presented in pet battle order (1-3). A slot with a dead pet is counted.
--- @param db 		    OracleHUD_PB_DB	        OracleHUD Pet Battles Database.
--- @param owner	    Enum.BattlePetOwner?    (Optional) Ally or Enemy, defaults to Ally.
--- @param battleOrder  OracleHUD_PB_CombatLogService_BattleOrder   Battle order when battle first began.
--- @return integer|nil
function OracleHUD_PB_PetInfoServiceMixin:GetJournalOrderSlot(slot, db, owner, battleOrder)
    if (owner == nil) then owner = Enum.BattlePetOwner.Ally end
    if (slot == nil or db == nil or owner == nil or battleOrder == nil) then
        error(self._class..":GetJournalOrderSlot(): Invalid arguments.")
    end
    local journalOrderSlot = nil
    if (owner == Enum.BattlePetOwner.Ally) then
        if (battleOrder.ally.order[slot] == nil or battleOrder.ally.order[slot].slot == nil) then
            print (self._class..":GetJournalOrderSlot(): Journal order slot not found.")
        else
            journalOrderSlot = battleOrder.ally.order[slot].slot
        end
    end
    if (owner == Enum.BattlePetOwner.Enemy) then
        if (battleOrder.enemy.order[slot] == nil or battleOrder.enemy.order[slot].slot == nil) then
            print (self._class..":GetJournalOrderSlot(): Journal order slot not found.")
        else
            journalOrderSlot = battleOrder.enemy.order[slot].slot
        end
    end
    return journalOrderSlot
end
-------------------------------------------------------------------------------
--- Get pet information by species name
--- @param speciesName    string Unique species name
--- @return OracleHUD_PB_PetInfo|nil
function OracleHUD_PB_PetInfoServiceMixin:GetPetInfoBySpeciesName(speciesName)
    local speciesID = C_PetJournal.FindPetIDByName(speciesName)
    return self:GetPetInfoBySpeciesId(speciesID)
end
-------------------------------------------------------------------------------
--- Get pet information by species identifier.
--- @param speciesId    number  Unique species identifier
--- @return OracleHUD_PB_PetInfo|nil
function OracleHUD_PB_PetInfoServiceMixin:GetPetInfoBySpeciesId(speciesId)
    local speciesNumber = tonumber(speciesId)
    if (speciesNumber == nil) then
        error(self._class..":GetPetInfoBySpeciesId(): Invalid arguments.")
    end
    local petInfo = nil
    local speciesName, speciesIcon, petType, companionID, tooltipSource, tooltipDescription, isWild, canBattle, isTradeable, isUnique, obtainable, creatureDisplayID = C_PetJournal.GetPetInfoBySpeciesID(speciesId)
    if (speciesName ~= nil and petType ~= nil and tooltipSource ~= nil and tooltipDescription ~= nil and 
        creatureDisplayID ~= nil and companionID ~= nil and canBattle ~= nil and isWild ~= nil)
    then
        local idTable, levelTable = C_PetJournal.GetPetAbilityList(speciesNumber)
        --- @type OracleHUD_PB_PetInfo
        petInfo = CreateFromMixins(OracleHUD_PB_PetInfo)
        petInfo.speciesId = speciesNumber
        petInfo.name = speciesName
        petInfo.icon = speciesIcon
        petInfo.type = petType
        petInfo.companionId = companionID
        petInfo.tooltip = tooltipSource
        petInfo.sources = self:ParsePetSourceText(tooltipSource)
        petInfo.description = tooltipDescription
        petInfo.displayId = creatureDisplayID
        petInfo.canBattle = canBattle
        petInfo.wild = isWild
        petInfo.abilities = {
            ids = idTable
        }
        petInfo.content = {}
        -- Comments
        local key = "s" .. petInfo.speciesId
		if (self.db.content.petComments[key] ~= nil) then
            petInfo.content.emotes = self.db.content.petComments[key]
        end
        -- Abilities
        if (petInfo.abilities.ids ~= nil) then
            for i = 1, OracleHUD_TableGetLength(petInfo.abilities.ids) do
                local name, icon, type = C_PetJournal.GetPetAbilityInfo(petInfo.abilities.ids[i])
                --- @type OracleHUD_PB_PetAbility
                petInfo.abilities["ability"..i] = {
                    id = petInfo.abilities.ids[i],
                    name = name,
                    icon = icon,
                    type = type
                }
            end
        end
    end
    return petInfo
end
-------------------------------------------------------------------------------
--- Get pet information by pet identifier.
--- @param petId    string     Unique pet identifier (petID or petGUID)
--- @return OracleHUD_PB_PetInfo|nil
function OracleHUD_PB_PetInfoServiceMixin:GetPetInfoByPetId(petId)
    if (petId == nil or petId == "") then
        error(self._class..":GetPetInfoByPetId(): Invalid arguments.")
    end
    local petInfo = nil
    local speciesID, customName, level, xp, maxxp, displayID, favorite,
          name, icon, petType, creatureID = C_PetJournal.GetPetInfoByPetID(petId)
    local hp, maxhp, power, speed, rarity = C_PetJournal.GetPetStats(petId)
    if (speciesID ~= nil and displayID ~= nil) then
        petInfo = self:GetPetInfoBySpeciesId(speciesID)
        -- Caution. A petID, if not GUID, can be interpreted by lua as a string 
        -- instead of a number. This can cause issues in some methods.
        petInfo.id = petId
        petInfo.creatureId = creatureID
        petInfo.displayId = displayID
        petInfo.level = level
        petInfo.health = hp
        petInfo.healthMax = maxhp
        petInfo.experience = xp
        petInfo.experienceMax = maxxp
        petInfo.speed = speed
        petInfo.power = power
        petInfo.customName = customName
        petInfo.rarity = rarity
    end
    return petInfo
end
-------------------------------------------------------------------------------
--- Get pet information on a slotted pet
--- @param slot		    integer                 Slot as presented in pet journal order (1-3). A slot with a dead pet is counted.
--- @param db 		    OracleHUD_PB_DB	        OracleHUD Pet Battles Database.
--- @param owner	    Enum.BattlePetOwner?    (Optional) Ally or Enemy, defaults to Ally.
--- @return OracleHUD_PB_PetInfo|nil
function OracleHUD_PB_PetInfoServiceMixin:GetPetInfoBySlot(slot, db, owner)
    if (owner == nil) then owner = Enum.BattlePetOwner.Ally end
    if (slot == nil or db == nil) then
        error(self._class..":GetPetInfoBySlot(): Invalid arguments.")
    end
    if (owner == Enum.BattlePetOwner.Enemy and self.combatLogSvc:IsInBattle() == false) then
        error(self._class..":GetPetInfoBySlot(): Parameter 'owner' must be ally when not in battle.")
    end
    local petInfo = nil
    local battleOrderSlot = nil
    if (self.combatLogSvc:IsInBattle()) then
        battleOrderSlot = self:GetBattleOrderSlot(slot, db, owner, self.combatLogSvc:GetBattleOrder())
    end
    if (owner == Enum.BattlePetOwner.Ally) then
        local petID, ability1, ability2, ability3 = C_PetJournal.GetPetLoadOutInfo(slot)
        if (petID ~= nil) then
            petInfo = self:GetPetInfoByPetId(petID)
            if (petInfo == nil) then
                error(self._class..":GetPetInfoBySlot(): petInfo is nil.")
            end
            petInfo.slot = slot
            petInfo.abilities.activeIds = {}
            if (ability1 ~= nil) then table.insert(petInfo.abilities.activeIds, ability1) end
            if (ability2 ~= nil) then table.insert(petInfo.abilities.activeIds, ability2) end
            if (ability3 ~= nil) then table.insert(petInfo.abilities.activeIds, ability3) end
        end
    else
        --- battleOrderSlot is nil if pet is dead (i.e. journal slot 1 pet is dead and has no battle order slot)
        if (battleOrderSlot ~= nil) then
            local speciesID, petGUID = C_PetJournal.FindPetIDByName(C_PetBattles.GetName(owner, battleOrderSlot))
            if (petGUID ~= nil) then
                petInfo = self:GetPetInfoByPetId(petGUID)
            else
                petInfo = self:GetPetInfoBySpeciesId(speciesID)
            end
            petInfo.slot = slot
            petInfo.level = C_PetBattles.GetLevel(owner, battleOrderSlot)
            petInfo.health = C_PetBattles.GetHealth(owner, battleOrderSlot)
            petInfo.healthMax = C_PetBattles.GetMaxHealth(owner, battleOrderSlot)
            petInfo.rarity = C_PetBattles.GetBreedQuality(owner, battleOrderSlot)
        end
    end
    -- Abilities
    if (petInfo ~= nil and battleOrderSlot ~= nil) then
        petInfo.health = C_PetBattles.GetHealth(owner, battleOrderSlot)
        petInfo.healthMax = C_PetBattles.GetMaxHealth(owner, battleOrderSlot)
        for abilityIndex = 1, 3 do
            local id, name, icon, maxCooldown, unparsedDescription, 
                numTurns, petType, noStrongWeakHints = C_PetBattles.GetAbilityInfo(owner, battleOrderSlot, abilityIndex)
            local isUsable, currentCooldown, currentLockdown = C_PetBattles.GetAbilityState(owner, battleOrderSlot, abilityIndex)
            if (id ~= nil) then
                --- @type OracleHUD_PB_PetAbility
                local ability = petInfo.abilities["ability"..abilityIndex]
                ability.id = id
                ability.name = name
                ability.icon = icon
                ability.maxCooldown = maxCooldown
                ability.unparsedDescription = unparsedDescription
                ability.numTurns = numTurns
                ability["type"] = petType
                ability.noStrongWeakHints = noStrongWeakHints
                ability.isUsable = isUsable
                ability.currentCooldown = currentCooldown
                ability.currentLockdown = currentLockdown
            end
        end
    end
    return petInfo
end
-------------------------------------------------------------------------------
--- Get pet information of active pet in battle
--- @param db 		    OracleHUD_PB_DB	        OracleHUD Pet Battles Database.
--- @param owner	    Enum.BattlePetOwner?    (Optional) Ally or Enemy, defaults to Ally.
--- @return OracleHUD_PB_PetInfo|nil
function OracleHUD_PB_PetInfoServiceMixin:GetPetInfoByActive(db, owner)
    if (db == nil or owner == nil) then
        error(self._class..":GetPetInfoByActive(): Invalid arguments.")
    end
    if (owner == Enum.BattlePetOwner.Enemy and self.combatLogSvc:IsInBattle() == false) then
        error(self._class..":GetPetInfoByActive(): Must be in battle")
    end
    local petInfo = nil
    local battleSlot = C_PetBattles.GetActivePet(owner)
    local journalSlot = self:GetJournalOrderSlot(battleSlot, db, owner, self.combatLogSvc:GetBattleOrder())
    if (journalSlot ~= nil) then
        petInfo = self:GetPetInfoBySlot(journalSlot, db, owner)
    end
    return petInfo
end
-------------------------------------------------------------------------------
--- Get a random unslotted pet.
--- @return OracleHUD_PB_PetInfo|nil
function OracleHUD_PB_PetInfoServiceMixin:GetPetInfoUnslottedRandom()
    local petInfo = {}
    local journal = self:SearchJournal(
        "",
        self.db,
        self:GetFilteredPetTypes(true),
        { collected = true, uncollected = false }
    )
    for i = 1, journal.total do
        local index = math.random(1, journal.total)
        local pet = journal.pets[index]
        if ((pet.level < 25) and (pet.canBattle == true) and (C_PetJournal.PetIsSlotted(pet.id) == false)) then
            petInfo = pet
            break
        end
    end
    return petInfo
end
-------------------------------------------------------------------------------
--- @param rarity integer   Rarity of the pet (1-6)
--- @return string
function OracleHUD_PB_PetInfoServiceMixin:GetRarityText(rarity)
    return _G["BATTLE_PET_BREED_QUALITY"..rarity]
end
-------------------------------------------------------------------------------
--- Get the correct text highlight color for a pet rarity.
--- @return any color
function OracleHUD_PB_PetInfoServiceMixin:GetRarityColor(rarity)
    local PetQualityColors = {}
    for i = 1, 6 do PetQualityColors[i] = ITEM_QUALITY_COLORS[i-1] end
    return PetQualityColors[rarity]
end
-------------------------------------------------------------------------------
--- Format a string of text with the correct color for a pet rarity.
--- @param text     string      Text to format with color.
--- @param rarity   integer     Pet rarity level.
--- @return string 
function OracleHUD_PB_PetInfoServiceMixin:WrapTextWithRarityColor(text, rarity)
    local color = self:GetRarityColor(rarity)
    local formatted = color.hex..text.."|r"
    return formatted
end
-------------------------------------------------------------------------------
--- Get all 3 possible pets collected of a single pet id
--- @param name     string      Exact pet name.
--- @return         any|nil     Collection of OracleHUD_PB_PetInfo
function OracleHUD_PB_PetInfoServiceMixin:GetPetInfoCollected(name)
    if (name == nil) then
        error(self._class..":GetPetInfoByPetId(): Bad arguments.")
    end
    local journal = self:SearchJournal(
        name,
        self.db,
        self:GetFilteredPetTypes(true),
        { collected = true, uncollected = false }
    )
    local petInfos = {}
    for i = 1, journal.total do
        ---@type OracleHUD_PB_PetInfo
        local pet = journal.pets[i]
        if (pet.name == name) then
            table.insert(petInfos, pet)
        end
    end
    return petInfos
end
-------------------------------------------------------------------------------
--- Get a random unslotted pet.
--- @param zone  string?    (Optional) Zone to limit search to. Defaults to current zone.
--- @return OracleHUD_PB_PetInfo|nil
function OracleHUD_PB_PetInfoServiceMixin:GetPetInfoByUnslottedRandomZone(zone)
    if (zone == nil) then zone = GetZoneText() end
    local petInfo = {}
    local journal = self:SearchJournal(
        zone,
        self.db,
        self:GetFilteredPetTypes(true),
        { collected = true, uncollected = false }
    )
    for i = 1, journal.total do
        local index = math.random(1, journal.total)
        local pet = journal.pets[index]
        if ((pet.canBattle == true) and (C_PetJournal.PetIsSlotted(pet.id) == false)) then
            petInfo = pet
            break
        end
    end
    return petInfo
end
-------------------------------------------------------------------------------
--- Get the lowest level unslotted pet.
--- @return OracleHUD_PB_PetInfo|nil
function OracleHUD_PB_PetInfoServiceMixin:GetPetInfoByUnslottedLowest()
    local petInfo = nil
    local journal = self:SearchJournal(
        "",
        self.db,
        self:GetFilteredPetTypes(true),
        { collected = true, uncollected = false },
        LE_SORT_BY_LEVEL
    )
    if (journal.total > 0) then
        for i = 1, #journal.pets do
            local pet = journal.pets[#journal.pets + 1 - i]
            if ((pet.canBattle == true) and (C_PetJournal.PetIsSlotted(pet.id) == false)) then
                petInfo = pet
                break;
            end
        end
    end
    return petInfo
end
-------------------------------------------------------------------------------
--- Get the lowest level unslotted pet for the specified zone.
--- @param zone string?  (Optional) Zone to limit search to. Defaults to current zone.
--- @return OracleHUD_PB_PetInfo|nil
function OracleHUD_PB_PetInfoServiceMixin:GetPetInfoByUnslottedLowestZone(zone)
    if (zone == nil) then zone = GetZoneText() end
    local petInfo = nil
    local journal = self:SearchJournal(
        zone,
        self.db,
        self:GetFilteredPetTypes(true),
        { collected = true, uncollected = false },
        LE_SORT_BY_LEVEL
    )
    if (journal.total > 0) then
        for i = 1, #journal.pets do
            local pet = journal.pets[#journal.pets + 1 - i]
            if ((pet.canBattle == true) and (C_PetJournal.PetIsSlotted(pet.id) == false)) then
                petInfo = pet
                break;
            end
        end
    end
    return petInfo
end
-------------------------------------------------------------------------------
--- Search zone for all uncollected pets.
--- @param zone         string?             (Optional) Zone to limit search to. Defaults to current zone.
--- @param db 		    OracleHUD_PB_DB	    OracleHUD Pet Battles Database.
--- @return OracleHUD_PB_PetInfo|nil
function OracleHUD_PB_PetInfoServiceMixin:GetPetInfoByUncollectedZone(zone, db)
    if (zone == nil or db == nil) then
        error(self._class..":GetPetInfoByUncollectedZone(): Invalid arguments.")
    end
    local searchText = zone
    local journal = self:SearchJournal(
        searchText,
        db,
        self:GetFilteredPetTypes(true),
        { collected = false, uncollected = true }
    )
    return journal.pets
end
-------------------------------------------------------------------------------
--- Report if all slotted pets are fully healed
--- @param petInfoSvc   OracleHUD_PB_PetInfoService     OracleHUD_PB PetInfoService.
--- @param owner	    Enum.BattlePetOwner?            (Optional) Ally or Enemy, defaults to Ally.
function OracleHUD_PB_PetInfoServiceMixin:PetsAllWell(petInfoSvc, owner)
    if (owner == nil) then owner = Enum.BattlePetOwner.Ally end
    if (petInfoSvc == nil) then
        error(self._class..":PetsAllWell(): Invalid arguments.")
    end
    local allWell = true
    if (self.combatLogSvc:IsInBattle()) then
        local numPets = C_PetBattles.GetNumPets(owner)
        for i = 1, numPets do
            if (C_PetBattles.GetHealth(i, owner) < C_PetBattles.GetMaxHealth(i, owner)) then
                allWell = false
                break
            end
        end
    else
        for i = 1, 3 do
            local pet = self:GetPetInfoBySlot(i, self.db, owner)
            if (pet ~= nil) then
                if (pet.health < pet.healthMax) then
                    allWell = false
                    break
                end
            end
        end
    end
    return allWell
end
-------------------------------------------------------------------------------
--- Parse pet source text into discrete properties.
--- @param sourceText	string  pet source description provided by wow.
function OracleHUD_PB_PetInfoServiceMixin:ParsePetSourceText(sourceText)
    local sources = {}
    if (sourceText ~= nil and sourceText ~= "") then
        local lines = OracleHUD_StringSplitWOWText(sourceText)
        local numLines = OracleHUD_TableGetLength(lines)
        local line1 = OracleHUD_StringReplaceWOWCrLf(OracleHUD_StringRemoveWOWColor(lines[1]))
        local index = string.find(line1, ":")

        local lineGroups = {}
        local lineGroup = {}
        for i = 1, numLines do
            table.insert(lineGroup, OracleHUD_StringReplaceWOWCrLf(OracleHUD_StringRemoveWOWColor(lines[i])))
            if (lines[i] == "" and i ~= numLines) then
                table.insert(lineGroups, lineGroup)
                lineGroup = {}
            end
        end
        table.insert(lineGroups, lineGroup)
        for groupKey, lineGroup in pairs(lineGroups) do
            local sourceType = nil
            local source = {}
            for k, line in pairs(lineGroup) do
                local typeIndex = string.find(line, ":")
                if (typeIndex ~= nil) then
                    local type = string.sub(line, 1, typeIndex - 1)
                    if (sourceType == nil) then
                        source.type = type
                    else
                        source[type] = string.sub(line, typeIndex)
                    end
                end
            end
            table.insert(sources, source)
        end
    end
    return sources
end
---------------------------------------------------------------------------
--- Search journal pets. Will restore original search filters when complete
--- @param text                 string              Search for this text.
--- @param db 		            OracleHUD_PB_DB	    OracleHUD Pet Battles Database.
--- @param filteredPetTypes	    any                 Apply this pet type filter.
--- @param filteredCollected	any                 Apply this collected/uncollected filter.
--- @param filteredSort		    any                 (Optional, defaults to LE_SORT_BY_NAME) Apply this sort filter.
function OracleHUD_PB_PetInfoServiceMixin:SearchJournal(text, db, filteredPetTypes, filteredCollected, filteredSort)
    if (filteredSort == nil) then filteredSort = LE_SORT_BY_NAME end
    if (text == nil or db == nil or filteredPetTypes == nil or filteredCollected == nil) then
        error(self._class..":SearchJournal(): Invalid arguments.")
    end
    -- Backup original filters
    local orig_filteredPetTypes = self:GetFilteredPetTypes()
    local orig_filteredCollected = self:GetFilteredCollected()
    local orig_filteredSort = self:GetFilteredSort()
    -- Apply specified filters
    self:SetFilteredPetTypes(filteredPetTypes)
    self:SetFilteredCollected(filteredCollected)
    self:SetFilteredSort(filteredSort)
    C_PetJournal.SetSearchFilter(text)
    -- Perform search
    local journal = {
        total = 0,
        pets = {}
    }
    journal.total = C_PetJournal.GetNumPets()
    for i = 1, journal.total do
        ---@type OracleHUD_PB_PetInfo?
        local pet
        local petID, speciesID, _, _, _, _, _, _, _, _, _, _, _, _, _, _, _ = C_PetJournal.GetPetInfoByIndex(i);
        if (petID ~= nil) then
            pet = self:GetPetInfoByPetId(petID)
        elseif (speciesID ~= nil) then
            pet = self:GetPetInfoBySpeciesId(speciesID)
        end
        journal.pets[i] = pet
    end
    -- Restore original filters
    self:SetFilteredPetTypes(orig_filteredPetTypes)
    self:SetFilteredCollected(orig_filteredCollected)
    self:SetFilteredSort(orig_filteredSort)
    C_PetJournal:ClearSearchFilter()
    return journal
end
-------------------------------------------------------------------------------
--- Set the sort pet journal filter.
--- @param filteredSort    any		Return object from OracleHUD_PB_GetFilteredCollected().
function OracleHUD_PB_PetInfoServiceMixin:SetFilteredSort(filteredSort)
    C_PetJournal.SetPetSortParameter(filteredSort)
end
-------------------------------------------------------------------------------
--- Get the sort pet journal filter.
--- @param value    integer?		(Optional) Force sort filter to have this value.
--- @return integer
function OracleHUD_PB_PetInfoServiceMixin:GetFilteredSort(value)
    local filteredSort = nil
    if (value ~= nil) then
        filteredSort = value
    else
        filteredSort = C_PetJournal.GetPetSortParameter()
    end
    return filteredSort
end
-------------------------------------------------------------------------------
--- Set the collected/uncollected pet journal filter.
--- @param filteredCollected    any		Return object from OracleHUD_PB_GetFilteredCollected().
function OracleHUD_PB_PetInfoServiceMixin:SetFilteredCollected(filteredCollected)
    C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, filteredCollected.collected)
    C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, filteredCollected.uncollected)
end
-------------------------------------------------------------------------------
--- Get the collected/uncollected pet journal filter in the form of a table.
--- @param value    boolean?		(Optional) Force filter 'check' to have this value.
function OracleHUD_PB_PetInfoServiceMixin:GetFilteredCollected(value)
    local filteredCollected = {}
    if (value ~= nil) then
        filteredCollected.collected = value
        filteredCollected.uncollected = value
    else
        filteredCollected.collected = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED)
        filteredCollected.uncollected = C_PetJournal.IsFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED)
    end
    return filteredCollected
end
---------------------------------------------------------------------------
--- Set the pet type filters in the pet journal.
--- @param filteredPetTypes any     Pet type filters to apply.
function OracleHUD_PB_PetInfoServiceMixin:SetFilteredPetTypes(filteredPetTypes)
    local maxPetTypes = C_PetJournal.GetNumPetTypes()
    for k, v in pairs(filteredPetTypes) do
        C_PetJournal.SetPetTypeFilter(v.index, v.checked)
    end
end
---------------------------------------------------------------------------
--- Get the pet type filter in the form of a table
--- @param value    boolean?		(Optional) Force 'checked' to have this value
function OracleHUD_PB_PetInfoServiceMixin:GetFilteredPetTypes(value)
    local maxPetTypes = C_PetJournal.GetNumPetTypes()
    local filteredPetTypes = {}
    for i = 1, maxPetTypes do
        local checked = C_PetJournal.IsPetTypeChecked(i)
        if (value ~= nil) then
            checked = value
        end
        filteredPetTypes[OracleHUD_PB_GetPetTypeName(i)] = {
            index = i,
            checked = checked
        }
    end
    return filteredPetTypes
end
-------------------------------------------------------------------------------
--- Process incoming events.
--- @param event		any     Unique event identification
--- @param eventName    string	Human friendly name of event
function OracleHUD_PB_PetInfoServiceMixin:OnEvent(event, eventName, ...)
end
-------------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
function OracleHUD_PB_PetInfoServiceMixin:OnSizeChanged_PetInfoService()
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param self any	Main XML frame.
function OracleHUD_PB_PetInfoServiceMixin:OnLoad()
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_PetInfoService()
    end)
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
