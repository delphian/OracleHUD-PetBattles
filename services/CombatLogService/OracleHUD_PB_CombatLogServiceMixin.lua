--- Aggregate all pet combat related events and combat log data into a single authority.
--- 
--- combatLogSvc:SetCallback(combatLogSvc.ENUM.OPEN, function(loadoutOnOpen)
---     print("Battle Begins!")
--- end)
---
--- @class OracleHUD_PB_CombatLogService : OracleHUD_PB_Service
--- @field Display          any Inherited from mixin XML frame.
--- @field RegisterEvent    any Inherited from mixin XML frame.
OracleHUD_PB_CombatLogServiceMixin = CreateFromMixins(OracleHUD_PB_ServiceMixin)
OracleHUD_PB_CombatLogServiceMixin._class = "OracleHUD_PB_CombatLogServiceMixin"
OracleHUD_PB_CombatLogServiceMixin.callbacks = {}
OracleHUD_PB_CombatLogServiceMixin.countPetBattleClose = 0
OracleHUD_PB_CombatLogServiceMixin.inBattle = false
--- Statistics for a single pet battle.
--- @class OracleHUD_PB_CombatLogService_StatsBattle
--- @field timeBegin    integer Time battle started.
--- @field timeEnd      integer Time battle finished.
--- @field ally         any
--- @field  enemy       any

OracleHUD_PB_CombatLogServiceMixin.statsBattle = {
    timeBegin = 0,
    timeEnd = 0,
    ally = {
        win = false,
        damageTaken = 0
    },
    enemy = {
        damageTaken = 0
    }
}
--- @class OracleHUD_PB_CombatLogService_BattleOrder
OracleHUD_PB_CombatLogServiceMixin.battleOrder = {
    ally = {
        max = 0,
        order = {}
    },
    enemy = {
        max = 0,
        order = {}
    }
}
-------------------------------------------------------------------------------
--- @class OracleHUD_PB_CombatLogService_DB_Totals
--- @field levels   integer
--- @field xp       integer
--- @field won      integer
--- @field lost     integer
--- @field battles  integer
--- @field maxed    integer
-------------------------------------------------------------------------------
--- @class OracleHUD_PB_CombatLogService_DB_Options
--- @field debugEvents  boolean     Print debuging information on WOW events.
--- @field showLog      boolean     Print the log to the display.
-------------------------------------------------------------------------------
--- @class OracleHUD_PB_CombatLogService_DB
--- @field statsTotal   OracleHUD_PB_CombatLogService_DB_Totals
--- @field options      OracleHUD_PB_CombatLogService_DB_Options
-------------------------------------------------------------------------------
--- @enum ORACLEHUD_PB_COMBATLOGSERVICE_ENUM
OracleHUD_PB_CombatLogServiceMixin.ENUM = {
    ALL         = 500,
    ACTIVE      = 1000,
    DIE         = 1100,
    DAMAGE      = 1200,
    HEAL        = 1300,
    IMMUNE      = 1400,
    FADE        = 1500,
    FADETEAM    = 1600,
    APPLY       = 1700,
    APPLYTEAM   = 1800,
    ROUNDSTART  = 1900,
    ROUNDEND    = 1910,
    DODGE       = 2000,
    MISS        = 2100,
    BLOCK       = 2200,
    WON         = 3000,
    LOST        = 4000,
    LEVEL       = 5000,
    XP          = 5100,
    OPEN        = 6000,
    CLOSE       = 7000,
    TRAP        = 8000
}
---------------------------------------------------------------------------
--- Configure frame with required data.
--- @param db 		    OracleHUD_PB_DB	                OracleHUD Pet Battles Database.
--- @param petInfoSvc   OracleHUD_PB_PetInfoService     OracleHUD Pet Battles Pet Information Service.
--- @param display		OracleHUD_PB_Display			OracleHUD Display Interface.
function OracleHUD_PB_CombatLogServiceMixin:Configure(db, petInfoSvc, display)
    if (db == nil or petInfoSvc == nil) then
        error(self._class..":Configure(): Invalid arguments.")
    end
    self.db = db
    self.petInfoSvc = petInfoSvc
    self.display = display
    self:ConfigureDb(db)
    self.statsTotal = db.modules.combatLogService.statsTotal
    -- Initial stats when battle first opens.
    self.loadoutOnOpen = {}
end
---------------------------------------------------------------------------
--- Setup statistics for long term storage in the database.
--- @param  db 		    OracleHUD_PB_DB	                OracleHUD Pet Battles Database.
function OracleHUD_PB_CombatLogServiceMixin:ConfigureDb(db)
    if (db.modules == nil) then db.modules = {} end
    if (db.modules.combatLogService == nil) then
        --- @type OracleHUD_PB_CombatLogService_DB
        db.modules.combatLogService = {
            statsTotal = {
                levels = 0,
                xp = 0,
                won = 0,
                lost = 0,
                battles = 0,
                maxed = 0
            },
            options = {
                debugEvents = false,
                showLog = false,
            }
        }
    end
    db.modules.combatLogService.options.showLog = false
end
---------------------------------------------------------------------------
--- All required resources and data has been loaded. Set initial state.
--- @param callback function?   (Optional) Execute callback when initialize has finished.
function OracleHUD_PB_CombatLogServiceMixin:Initialize(callback)
    if (self.db.debug) then self.display:Print("..Initialize Combat Log Service") end
    self:RegisterEvent("CHAT_MSG_PET_BATTLE_COMBAT_LOG")
    self:RegisterEvent("CONSOLE_MESSAGE")
    self:RegisterEvent("CHAT_MSG_PET_BATTLE_INFO")
    self:RegisterEvent("PET_BATTLE_PET_ROUND_RESULTS")
    self:RegisterEvent("PET_BATTLE_ACTION_SELECTED")
    self:RegisterEvent("PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE")
    self:RegisterEvent("PET_BATTLE_CLOSE")
    self:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
    self:RegisterEvent("PET_BATTLE_OPENING_START")
    self:RegisterEvent("PET_BATTLE_OPENING_DONE")
    self:RegisterEvent("PET_BATTLE_OVER")
    self:RegisterEvent("PET_BATTLE_HEALTH_CHANGED")
    self:RegisterEvent("PET_BATTLE_XP_CHANGED")
    self:RegisterEvent("PET_BATTLE_LEVEL_CHANGED")
    self.inBattle = C_PetBattles.IsInBattle()
    if (self.inBattle) then
        self.battleOrder = self:CreateBattleOrder()
        self.loadoutOnOpen = self:CreateLoadoutOnOpen()
    end
    if (self.db.debug) then
        self:ShowFull()
    end
    if (callback ~= nil) then
        callback()
    end
end
---------------------------------------------------------------------------
--- Save all initial opening stats before the battle begins.
function OracleHUD_PB_CombatLogServiceMixin:CreateLoadoutOnOpen()
    local loadoutOnOpen = {}
    loadoutOnOpen.numPets = C_PetBattles.GetNumPets(Enum.BattlePetOwner.Ally)
    for i = 1, loadoutOnOpen.numPets do
        loadoutOnOpen["slot"..i] = {
            level = C_PetBattles.GetLevel(Enum.BattlePetOwner.Ally, i)
        }
    end
    if (self.db.modules.combatLogService.options.debugEvents) then 
        self.display:Print("CombatLogService: Loadout on open: ", OracleHUD_Dump(loadoutOnOpen)) 
    end
    return loadoutOnOpen
end
---------------------------------------------------------------------------
--- Process incoming events.
--- @param event        any		Unique event identification
--- @param eventName	string  Human friendly name of event
function OracleHUD_PB_CombatLogServiceMixin:OnEvent(event, eventName, ...)
    if (self.db.modules.combatLogService.options.debugEvents) then self.display:Print(eventName) end
    if (eventName == "CONSOLE_MESSAGE") then
        local message = ...
        if (string.find(message, "---BattleFinished: You Lost ---")) then
            self.statsBattle.ally.win = false
            self.statsTotal.lost = self.statsTotal.lost + 1
            self.statsTotal.battles = self.statsTotal.battles + 1
        end
        if (string.find(message, "---BattleFinished: You Won ---")) then
            self.statsTotal.won = self.statsTotal.won + 1
            self.statsTotal.battles = self.statsTotal.battles + 1
            self.statsBattle.ally.win = true
            -- Pet journal will not be updated if ally has taken no damage. This becomes our hint that battle is over.
            C_Timer.After(3, function()
                if (self.statsBattle.ally.damageTaken == 0) then
                    self:OnBattleClose()
                end
            end)
        end
    end
    if (eventName == "CHAT_MSG_PET_BATTLE_INFO") then
        local message = ...
        if (string.find(message, "Your |T%d+:%d+|t[%w%s%-‘’`%d%.]+ gains %d+ XP!$")) then
            self:ParseXP(message, Enum.BattlePetOwner.Ally)
        end
        if (string.find(message, "Your |T%d+:%d+|t[%w%s%-‘’`%d%.]+ has reached Level %d+!$")) then
            self:ParseLevel(message, Enum.BattlePetOwner.Ally)
        end
    end
    if (eventName == "CHAT_MSG_PET_BATTLE_COMBAT_LOG") then
        local args = {...}
        local message = args[1]
        if (self.db.modules.combatLogService.options.showLog) then self.display:Print(message) end
        -- Damage
        if (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`]+%]|h|r dealt %d+ damage to your |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.") ~= nil) then
            self:ParseDamage(message, Enum.BattlePetOwner.Ally)
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`]+%]|h|r dealt %d+ damage to enemy |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.") ~= nil) then
            self:ParseDamage(message, Enum.BattlePetOwner.Enemy)
        -- Fade
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`]+%]|h|r fades from your |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.") ~= nil) then
            self:ParseFade(message, Enum.BattlePetOwner.Ally)
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`]+%]|h|r fades from enemy |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.") ~= nil) then
            self:ParseFade(message, Enum.BattlePetOwner.Enemy)
        -- Fade Team
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r fades from your team.") ~= nil) then
            self:ParseFadeTeam(message, Enum.BattlePetOwner.Ally)
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r fades from enemy team.") ~= nil) then
            self:ParseFadeTeam(message, Enum.BattlePetOwner.Enemy)
        -- Trap
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r trapped enemy |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.") ~= nil) then
            self:ParseTrap(message, Enum.BattlePetOwner.Ally)
        -- Apply
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r applied |T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-']+%]|h|r to your |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.") ~= nil) then
            self:ParseApply(message, Enum.BattlePetOwner.Ally)
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r applied |T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-']+%]|h|r to enemy |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.") ~= nil) then
            self:ParseApply(message, Enum.BattlePetOwner.Enemy)
        -- Apply Team
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r applied |T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r to enemy team.") ~= nil) then
            self:ParseApplyTeam(message, Enum.BattlePetOwner.Ally)
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r applied |T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-‘’`'%d%.]+%]|h|r to your team.") ~= nil) then
            self:ParseApplyTeam(message, Enum.BattlePetOwner.Enemy)
        -- Immune
        elseif (string.find(message, "your |T%d+:%d+|t[%w%s%-'‘’`%d%.]+ was immune to |T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r") ~= nil) then
            self:ParseImmune(message, Enum.BattlePetOwner.Ally)
        elseif (string.find(message, "enemy |T%d+:%d+|t[%w%s%-'‘’`%d%.]+ was immune to |T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r") ~= nil) then
            self:ParseImmune(message, Enum.BattlePetOwner.Enemy)
        -- Weather
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r changed the weather to |T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`]+%]|h|r.") ~= nil) then
            self:ParseWeather(message)
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r is no longer the weather.") ~= nil) then
            self:ParseWeather(message)
        -- Healed -------------------------------------------------------------
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r healed %d+ damage from your |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.") ~= nil) then
            self:ParseHeal(message, Enum.BattlePetOwner.Ally)
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r healed %d+ damage from enemy |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.") ~= nil) then
            self:ParseHeal(message, Enum.BattlePetOwner.Enemy)
        -- Dodge --------------------------------------------------------------
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r was dodged by your |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.") ~= nil) then
            self:ParseDodge(message, Enum.BattlePetOwner.Ally) 
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r was dodged by enemy |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.") ~= nil) then
            self:ParseDodge(message, Enum.BattlePetOwner.Enemy)
        -- Miss ---------------------------------------------------------------
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r missed enemy |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.") ~= nil) then
            self:ParseMiss(message, Enum.BattlePetOwner.Ally)
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r missed your |T%d+:%d+|t[%w%s%-‘’`'%d%.]+.") ~= nil) then
            self:ParseMiss(message, Enum.BattlePetOwner.Enemy)
        -- Block --------------------------------------------------------------
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r was blocked from striking enemy |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.") ~= nil) then
            self:ParseBlock(message, Enum.BattlePetOwner.Ally)
        elseif (string.find(message, "|T%d+:%d+|t|c%x+|HbattlePetAbil:%d*:%d*:%d*:%d*|h%[[%w%s%-'‘’`%d%.]+%]|h|r was blocked from striking your |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.") ~= nil) then
            self:ParseBlock(message, Enum.BattlePetOwner.Enemy)
        -- Round --------------------------------------------------------------
        elseif (string.find(message, "^Round %d+$") ~= nil) then
            self:ParseRoundStart(message)
        -- Active Pet ---------------------------------------------------------
        elseif (string.find(message, "|T%d+:%d+|t[%w%s%-'‘’`%d%.]+ is now your active pet.$") ~= nil) then
            self:ParseActive(message, Enum.BattlePetOwner.Ally)
        elseif (string.find(message, "|T%d+:%d+|t[%w%s%-'‘’`%d%.]+ is now enemy active pet.$") ~= nil) then
            self:ParseActive(message, Enum.BattlePetOwner.Enemy)
        -- Died ---------------------------------------------------------------
        elseif (string.find(message, "Your |T%d+:%d+|t[%w%s%-'‘’`%d%.]+ died.$")) then
            self:ParseDie(message, Enum.BattlePetOwner.Ally)
        elseif (string.find(message, "Enemy |T%d+:%d+|t[%w%s%-'‘’`%d%.]+ died.$")) then
            self:ParseDie(message, Enum.BattlePetOwner.Enemy)
        else
            self.display:Print(string.gsub(message, "|", "||"), { r = 1, g = 0, b = 0 })
        end
    end
    if (eventName == "PET_BATTLE_OPENING_START") then
        self.inBattle = true
        self.battleOrder = self:CreateBattleOrder()
        self.loadoutOnOpen = self:CreateLoadoutOnOpen()
        self:ResetSingleBattleStats(self.statsBattle)
        self:Send(self.ENUM.OPEN, self.loadoutOnOpen)
    end
    if (eventName == "PET_BATTLE_CLOSE") then
        self.countPetBattleClose = self.countPetBattleClose + 1
        if (self.countPetBattleClose >= 2) then
            -- C_PetBattles.IsInBattle() now reports correctly.
        end
    end
    if (eventName == "PET_JOURNAL_LIST_UPDATE" and self.countPetBattleClose >= 2) then
        -- C_PetJournal stats have been updated.
        self:OnBattleClose()
    end
    if (eventName == "PET_BATTLE_PET_ROUND_PLAYBACK_COMPLETE") then
        local round = ...
        self:ParseRoundEnd(round)
    end
    if (eventName == "PET_BATTLE_LEVEL_CHANGED") then
        local owner, petIndex, newLevel = ...
        if (owner == Enum.BattlePetOwner.Ally) then
            local oldLevel = self.loadoutOnOpen["slot"..petIndex].level
            self.statsTotal.levels = self.statsTotal.levels + (newLevel - oldLevel)
            if (newLevel == 25) then
                self.statsTotal.maxed = self.statsTotal.maxed + 1
            end
            local journalSlot = self.petInfoSvc:GetJournalOrderSlot(petIndex, self.db, owner, self:GetBattleOrder())
            if (journalSlot == nil) then error("journalSlot must not be nil") end
            local petInfo = self.petInfoSvc:GetPetInfoBySlot(journalSlot, self.db, owner)
            self:Send(self.ENUM.LEVEL, petInfo, newLevel)
        end
    end
    if (eventName == "PET_BATTLE_XP_CHANGED") then
        local owner, petIndex, xpChange = ...
        if (owner == Enum.BattlePetOwner.Ally) then
            self.statsTotal.xp = self.statsTotal.xp + xpChange
            local journalSlot = self.petInfoSvc:GetJournalOrderSlot(petIndex, self.db, owner, self:GetBattleOrder())
            if (journalSlot == nil) then error("journalSlot must not be nil") end
            local petInfo = self.petInfoSvc:GetPetInfoBySlot(journalSlot, self.db, owner)
            self:Send(self.ENUM.XP, petInfo, xpChange)
        end
    end
end
-------------------------------------------------------------------------------
--- Authoritatively close out the battle.
function OracleHUD_PB_CombatLogServiceMixin:OnBattleClose()
    self.countPetBattleClose = 0
    self.inBattle = false
    self.statsBattle.timeEnd = time()
    if (self.db.modules.combatLogService.options.debugEvents) then 
        self.display:Print("CombatLogService: Battle Stats: ", OracleHUD_Dump(self.statsBattle)) 
    end
    if (self.db.modules.combatLogService.options.debugEvents) then 
        self.display:Print("CombatLogService: Total Stats: ", OracleHUD_Dump(self.statsTotal)) 
    end
    self:Send(self.ENUM.CLOSE, self.statsTotal, self.statsBattle)
    if (self.statsBattle.ally.win) then
        self:Send(self.ENUM.WON, self.statsTotal, self.statsBattle)
    else
        self:Send(self.ENUM.LOST, self.statsTotal, self.statsBattle)
    end
end
-------------------------------------------------------------------------------
--- Get the current journal loadout as battle order. Dead pets don't count as slotted in battle order.
--- @return OracleHUD_PB_CombatLogService_BattleOrder
function OracleHUD_PB_CombatLogServiceMixin:CreateBattleOrder()
    local hp1, hp2, hp3 = nil, nil, nil
    local battleOrder = {
        ally = {
            max = 0,
            order = {}
        },
        enemy = {
            max = 0,
            order = {}
        }
    }
    -- Ally
    local pet1ID, _, _, _ = C_PetJournal.GetPetLoadOutInfo(1)
    if (pet1ID ~= nil) then hp1, _, _, _, _ = C_PetJournal.GetPetStats(pet1ID) end
    local pet2ID, _, _, _ = C_PetJournal.GetPetLoadOutInfo(2)
    if (pet2ID ~= nil) then hp2, _, _, _, _ = C_PetJournal.GetPetStats(pet2ID) end
    local pet3ID, _, _, _ = C_PetJournal.GetPetLoadOutInfo(3)
    if (pet3ID ~= nil) then hp3, _, _, _, _ = C_PetJournal.GetPetStats(pet3ID) end
    if (hp1 ~= nil and hp1 > 0) then
        table.insert(battleOrder.ally.order, { petId = pet1ID, slot = 1 })
        battleOrder.ally.max = battleOrder.ally.max + 1
    end
    if (hp2 ~= nil and hp2 > 0) then
        table.insert(battleOrder.ally.order, { petId = pet2ID, slot = 2 })
        battleOrder.ally.max = battleOrder.ally.max + 1
    end
    if (hp3 ~= nil and hp3 > 0) then
        table.insert(battleOrder.ally.order, { petId = pet3ID, slot = 3 })
        battleOrder.ally.max = battleOrder.ally.max + 1
    end
    -- Enemy
    battleOrder.enemy.max = C_PetBattles.GetNumPets(Enum.BattlePetOwner.Enemy)
    for i = 1, battleOrder.enemy.max do
        table.insert(battleOrder.enemy.order, {
            petId = nil,
            slot = i
        })
    end
    return battleOrder
end
-------------------------------------------------------------------------------
--- Reset the single battle statistics.
--- @param  stats       OracleHUD_PB_CombatLogService_StatsBattle
function OracleHUD_PB_CombatLogServiceMixin:ResetSingleBattleStats(stats)
    stats.timeBegin = time()
    stats.timeEnd = 0
    stats.ally.damageTaken = 0
    stats.ally.win = false
    stats.enemy.damageTaken = 0
end
---------------------------------------------------------------------------
--- Return the last calculated battle order.
--- @return OracleHUD_PB_CombatLogService_BattleOrder
function OracleHUD_PB_CombatLogServiceMixin:GetBattleOrder()
    return self.battleOrder
end
---------------------------------------------------------------------------
--- Reports if C_PetJournal is stats authority vs C_PetBattles.
function OracleHUD_PB_CombatLogServiceMixin:IsInBattle()
    return self.inBattle
end
---------------------------------------------------------------------------
--- Report which journal order slot has it's pet on the battlefield.
--- @param  owner    Enum.BattlePetOwner
--- @return number|nil
function OracleHUD_PB_CombatLogServiceMixin:GetJSlotActive(owner)
    local petIndex = C_PetBattles.GetActivePet(owner)
    return self.petInfoSvc:GetJournalOrderSlot(petIndex, self.db, owner, self:GetBattleOrder())
end
---------------------------------------------------------------------------
--- Report which battle order slot should be the next active on the battlefield.
--- @param  owner    Enum.BattlePetOwner    (Optional, defaults to Ally)
--- @return number
function OracleHUD_PB_CombatLogServiceMixin:GetBSlotActiveNext(owner)
    if (owner == nil) then owner = Enum.BattlePetOwner.Ally end
    local nextBSlot = 1
    local hp1 = C_PetBattles.GetHealth(owner, 1)
    local hp2 = C_PetBattles.GetHealth(owner, 2)
    local hp3 = C_PetBattles.GetHealth(owner, 3)
    if (math.max(hp1, hp2, hp3) == hp1) then
        nextBSlot = 1
    end
    if (math.max(hp1, hp2, hp3) == hp2) then
        nextBSlot = 2
    end
    if (math.max(hp1, hp2, hp3) == hp3) then
        nextBSlot = 3
    end
    return nextBSlot
end
---------------------------------------------------------------------------
--- Report which journal order slot should be the next active on the battlefield.
--- @param  owner    Enum.BattlePetOwner
--- @return number|nil
function OracleHUD_PB_CombatLogServiceMixin:GetJSlotActiveNext(owner)
    local nextBSlot = self:GetBSlotActiveNext(owner)
    return self.petInfoSvc:GetJournalOrderSlot(nextBSlot, self.db, owner, self:GetBattleOrder())
end
---------------------------------------------------------------------------
--- Set callback to be invoked when an addon message is received.
--- @param event     ORACLEHUD_PB_COMBATLOGSERVICE_ENUM?    (Optional, defaults to "ALL")
--- @param callback  function                               Function to be called.
function OracleHUD_PB_CombatLogServiceMixin:SetCallback(event, callback)
    if (event == nil) then event = self.ENUM.ALL end
    if (self.callbacks[event] == nil) then
        self.callbacks[event] = {}
    end
    table.insert(self.callbacks[event], callback)
end
---------------------------------------------------------------------------
--- Pull pet id out of pet link.
--- @param text string  Text that contains a pet link.
function OracleHUD_PB_CombatLogServiceMixin:GetPetId(text)
    local link = string.match(text, "(|T[%d]+:[%d]+|t[%w%s%-'‘’`]+)")
    local petId = string.match(link, "|T[%d]+:([%d])+|t[%w%s%-'‘’`]+")
    return petId
end
---------------------------------------------------------------------------
--- Send the event to subscribers.
--- @param event ORACLEHUD_PB_COMBATLOGSERVICE_ENUM
function OracleHUD_PB_CombatLogServiceMixin:Send(event, ...)
    if (self.callbacks[event] ~= nil) then
        for i = 1, #self.callbacks[event] do
            local callback = self.callbacks[event][i]
            callback(...)
        end
    end
    if (self.callbacks["all"] ~= nil) then
        for i = 1, #self.callbacks["all"] do
            local callback = self.callbacks["all"][i]
            callback(event, ...)
        end
    end
end
---------------------------------------------------------------------------
--- Parse damage combat message.
--- ICON         COLOR     LINK            ID               TEXT
--- |T136067:14|t|cff4396f7|HbattlePetAbil:379:335:176:294|h[Poisoned]|h|r dealt 123 damage to your |T464160:14|tSea Gull.
-- @param message   Combat log message.
function OracleHUD_PB_CombatLogServiceMixin:ParseDamage(message, owner)
    local abilityId, amount, target = nil, nil, nil
    if (owner == Enum.BattlePetOwner.Ally) then
        abilityId = string.match(message, "battlePetAbil:(%d+):")
        amount = string.match(message, "dealt (%d+) damage to your")
        target = string.match(message, "damage to your |T[%d]+:[%d]+|t([%w%s%-'‘’`]+).")
        self.statsBattle.ally.damageTaken = self.statsBattle.ally.damageTaken + amount
    else
        abilityId = string.match(message, "battlePetAbil:(%d+):")
        amount = string.match(message, "dealt (%d+) damage to enemy")
        target = string.match(message, "damage to enemy |T[%d]+:[%d]+|t([%w%s%-'‘’`]+).")
        self.statsBattle.enemy.damageTaken = self.statsBattle.enemy.damageTaken + amount
    end
    self:Send(self.ENUM.DAMAGE, abilityId, tonumber(amount), owner, target)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseRoundStart(message)
    local round = string.match(message, "^Round (%d+)$")
    self.round = round
    self:Send(self.ENUM.ROUNDSTART, round)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseRoundEnd(round)
    self:Send(self.ENUM.ROUNDEND, round)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseLevel(message, owner)
    local amount = nil
    local targetName = nil
    local targetId = nil
    if (owner == Enum.BattlePetOwner.Ally) then
        amount = tonumber(string.match(message, "reached Level (%d+)!"))
        targetName = string.match(message, "Your |T[%d]+:[%d]+|t([%w%s%-'‘’`]+) has reached")
        targetId = string.match(message, "Your |T([%d]+):[%d]+|t[%w%s%-'‘’`]+ has reached")
    end
end
function OracleHUD_PB_CombatLogServiceMixin:ParseActive(message, owner)
    local petIndex = C_PetBattles.GetActivePet(owner)
    local jSlot = self.petInfoSvc:GetJournalOrderSlot(petIndex, self.db, owner, self:GetBattleOrder())
    self:Send(self.ENUM.ACTIVE, owner, jSlot)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseTrap(message, owner)
    local targetName = string.match(message, "trapped enemy |T%d+:%d+|t[%w%s%-'‘’`%d%.]+.")
    local targetId = string.match(message, "trapped enemy |T(%d+):%d+|t[%w%s%-'‘’`%d%.]+.")
    self:Send(self.ENUM.TRAP, targetName, targetId)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseDie(message, owner)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseApply(message, owner)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseApplyTeam(message, owner)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseWeather(message)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseFade(message, owner)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseFadeTeam(message, owner)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseImmune(message, owner)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseHeal(message, owner)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseXP(message, owner)
    local amount, targetName = nil, nil
    if (owner == Enum.BattlePetOwner.Ally) then
        amount = tonumber(string.match(message, "Your |T%d+:%d+|t[%w%s%-‘’`]+ gains (%d+) XP!$"))
        targetName = string.match(message, "Your |T%d+:%d+|t([%w%s%-‘’`]+) gains %d+ XP!$")
    end
end
function OracleHUD_PB_CombatLogServiceMixin:ParseDodge(message, owner)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseMiss(message, owner)
end
function OracleHUD_PB_CombatLogServiceMixin:ParseBlock(message, owner)
end
---------------------------------------------------------------------------
--- Dynamically resize all child elements when frame changes size.
function OracleHUD_PB_CombatLogServiceMixin:OnSizeChanged_CombatLogService()
end
-------------------------------------------------------------------------------
--- Called by XML onload.
--- @param self any	Main XML frame.
function OracleHUD_PB_CombatLogServiceMixin:OnLoad()
    ---------------------------------------------------------------------------
    --- Catch frame being resized and forward to resize handler.
    self:SetScript("OnSizeChanged", function()
        self:OnSizeChanged_CombatLogService()
    end)
    ---------------------------------------------------------------------------
    --- Catch events and forard to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end