--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_OptionsOracleHUDMainTemplate_OnLoad(self)
    self.name = "Oracle HUD Pet Battles"
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db		        Oracle HUD Pet Battle database.
    -- @param networkSvc        Oracle HUD Network Service.
    -- @param combatLogSvc      Oracle HUD Combat Log Service.
    -- @param uncollectedPanel  Oracle HUD Uncollected Panel.
    -- @param zooPanel          Oracle HUD Zoo Panel.
	function self:Configure(db, networkSvc, combatLogSvc, uncollectedPanel, 
                            zooPanel)
        if (db == nil or networkSvc == nil or combatLogSvc == nil or 
            uncollectedPanel == nil or zooPanel == nil) 
        then
            error("OracleHUD_PB_OptionsOracleHUDMainTemplate:Configure(): Invalid arguments.")
		end
        self.db = db
        self.networkSvc = networkSvc
        self.combatLogSvc = combatLogSvc
        self.uncollectedPanel = uncollectedPanel
        self.zooPanel = zooPanel
        self.Tabs:Configure(db)
    end
    ---------------------------------------------------------------------------
    --- Build xml on loadouts page.
    --- @param db   OracleHUD_PB_DB
    --- @param tab  OracleHUD_PB_TabButton
    function self:BuildLoadouts(db, tab)
        -- Show Ally Loadout
        self.LoadoutShowAlly = CreateFrame("CheckButton", nil, tab.panel, "InterfaceOptionsCheckButtonTemplate")
        self.LoadoutShowAlly:SetPoint("TOPLEFT", tab.panel, "TOPLEFT", 4, -12)
        self.LoadoutShowAlly.Text:SetText("Show My Loadout")
        self.LoadoutShowAlly:HookScript("OnClick", function(_, btn, down)
            db.modules.loadout.options.show = self.LoadoutShowAlly:GetChecked()
            if (db.modules.loadout.options.show) then
                OracleHUD_PB_PanelLoadoutAlly:ShowFull()
            else
                OracleHUD_PB_PanelLoadoutAlly:HideFull()
            end
        end)
        self.LoadoutShowAlly:SetChecked(self.db.modules.loadout.options.show)
        -- Show Enemy Loadout
        self.LoadoutShowEnemy = CreateFrame("CheckButton", nil, tab.panel, "InterfaceOptionsCheckButtonTemplate")
        self.LoadoutShowEnemy:SetPoint("TOPLEFT", self.LoadoutShowAlly, "TOPLEFT", 0, -22)
        self.LoadoutShowEnemy.Text:SetText("Show Enemy Loadout")
        self.LoadoutShowEnemy:HookScript("OnClick", function(_, btn, down)
            db.modules.loadout.options.showOpponents = self.LoadoutShowEnemy:GetChecked()
            if (db.modules.loadout.options.showOpponents) then
                -- OracleHUD_PBEnemyPanel:ShowFull()
            else
                OracleHUD_PB_PanelLoadoutEnemy:HideFull()
            end
        end)
        self.LoadoutShowEnemy:SetChecked(self.db.modules.loadout.options.showOpponents)
    end
    ---------------------------------------------------------------------------
    --- Build xml on quips page.
    --- @param db   OracleHUD_PB_DB
    --- @param tab  OracleHUD_PB_TabButton
    function self:BuildQuips(db, tab)
        -- Allow quip after battle.
        self.QuipAfterBattle = CreateFrame("CheckButton", nil, tab.panel, "InterfaceOptionsCheckButtonTemplate")
        self.QuipAfterBattle:SetPoint("TOPLEFT", tab.panel, "TOPLEFT", 4, -12)
        self.QuipAfterBattle.Text:SetText("Allow quip after battle.")
        self.QuipAfterBattle:HookScript("OnClick", function(_, btn, down)
            self.db.modules.loadout.options.afterBattleQuip = self.QuipAfterBattle:GetChecked()
        end)
        self.QuipAfterBattle:SetChecked(self.db.modules.loadout.options.afterBattleQuip)
    end
    ---------------------------------------------------------------------------
    --- Build xml on zoo page.
    --- @param db   OracleHUD_PB_DB
    --- @param tab  OracleHUD_PB_TabButton
    function self:BuildZoo(db, tab)
        -- Show Zoo
        self.ZooShow = CreateFrame("CheckButton", nil, tab.panel, "InterfaceOptionsCheckButtonTemplate")
        self.ZooShow:SetPoint("TOPLEFT", tab.panel, "TOPLEFT", 4, -12)
        self.ZooShow.Text:SetText("Show Zoo")
        self.ZooShow:HookScript("OnClick", function(_, btn, down)
            self:SetZooShow(self.ZooShow:GetChecked())
        end)
        self.ZooShow:SetChecked(self:GetZooShow())
    end
    ---------------------------------------------------------------------------
    --- Build xml on community page.
    --- @param db   OracleHUD_PB_DB
    --- @param tab  OracleHUD_PB_TabButton
    function self:BuildCommunity(db, tab)
        -- Show Community
        self.CommunityShow = CreateFrame("CheckButton", nil, tab.panel, "InterfaceOptionsCheckButtonTemplate")
        self.CommunityShow:SetPoint("TOPLEFT", tab.panel, "TOPLEFT", 4, -12)
        self.CommunityShow.Text:SetText("Show Community")
        self.CommunityShow:HookScript("OnClick", function(_, btn, down)
            self.db.options.community.show = self.CommunityShow:GetChecked()
            if (self.db.options.community.show) then
                OracleHUD_PB_PanelCommunity:ShowFull()
            else
                OracleHUD_PB_PanelCommunity:HideFull()
            end
        end)
        self.CommunityShow:SetChecked(self.db.options.community.show)
    end
    ---------------------------------------------------------------------------
    --- Build xml on uncollected page.
    --- @param db   OracleHUD_PB_DB
    --- @param tab  OracleHUD_PB_TabButton
    function self:BuildUncollected(db, tab)
        -- Show Missing Pets
        self.ShowMissing = CreateFrame("CheckButton", nil, tab.panel, "InterfaceOptionsCheckButtonTemplate")
        self.ShowMissing:SetPoint("TOPLEFT", tab.panel, "TOPLEFT", 4, -12)
        self.ShowMissing.Text:SetText("Show Uncaptured Pets")
        self.ShowMissing:HookScript("OnClick", function(_, btn, down)
            db.options.uncaptured.show = self.ShowMissing:GetChecked()
            if (db.options.uncaptured.show) then
                self.uncollectedPanel:ShowFull()
            else
                self.uncollectedPanel:HideFull()
            end
        end)
        self.ShowMissing:SetChecked(db.options.uncaptured.show)
    end
    ---------------------------------------------------------------------------
    --- Build xml on debug page.
    --- @param db   OracleHUD_PB_DB
    --- @param tab  OracleHUD_PB_TabButton
    function self:BuildDebug(db, tab)
        -- Debug
        self.Debug = CreateFrame("CheckButton", nil, tab.panel, "InterfaceOptionsCheckButtonTemplate")
        self.Debug:SetPoint("TOPLEFT", tab.panel, "TOPLEFT", 4, -12)
        self.Debug.Text:SetText("Module Loading")
        self.Debug:HookScript("OnClick", function(_, btn, down)
            db.debug = self.Debug:GetChecked()
        end)
        self.Debug:SetChecked(db.debug)
        -- Debug Show Combat Log
        self.ShowCombatLog = CreateFrame("CheckButton", nil, tab.panel, "InterfaceOptionsCheckButtonTemplate")
        self.ShowCombatLog:SetPoint("TOPLEFT", self.Debug, "BOTTOMLEFT", 0, -22)
        self.ShowCombatLog.Text:SetText("Show Combat Log")
        self.ShowCombatLog:HookScript("OnClick", function(_, btn, down)
            db.modules.combatLogService.options.showLog = self.ShowCombatLog:GetChecked()
        end)
        self.ShowCombatLog:SetChecked(db.modules.combatLogService.options.showLog)
        -- Debug combat log
        self.DebugCombatLogEvents = CreateFrame("CheckButton", nil, tab.panel, "InterfaceOptionsCheckButtonTemplate")
        self.DebugCombatLogEvents:SetPoint("TOPLEFT", self.ShowCombatLog, "BOTTOMLEFT", 0, -22)
        self.DebugCombatLogEvents.Text:SetText("Show Combat Log Events")
        self.DebugCombatLogEvents:HookScript("OnClick", function(_, btn, down)
            db.modules.combatLogService.options.debugEvents = self.DebugCombatLogEvents:GetChecked()
        end)
        self.DebugCombatLogEvents:SetChecked(db.modules.combatLogService.options.debugEvents)
    end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    -- @param callback      Execute callback when initialize has finished.
    function self:Initialize(callback)
        if (self.db.debug) then print("..Initialize Interface Options") end
        local loadout = self.Tabs:AddTab("Loadouts")
        local quips = self.Tabs:AddTab("Quips")
        local community = self.Tabs:AddTab("Community")
        local zoo = self.Tabs:AddTab("Zoo")
        local uncollected = self.Tabs:AddTab("Uncollected")
        local debug = self.Tabs:AddTab("Debug")
        self:BuildLoadouts(self.db, loadout)
        self:BuildQuips(self.db, quips)
        self:BuildCommunity(self.db, community)
        self:BuildZoo(self.db, zoo)
        self:BuildUncollected(self.db, uncollected)
        self:BuildDebug(self.db, debug)
        self.Tabs:Initialize()
        self.Tabs:SetFocus(loadout)
        --
        if (callback ~= nil) then
            callback()
        end
    end
    ---------------------------------------------------------------------------
    --- Set the zoo visibility option.
    -- @param show      Show or hide the zoo panel.
    function self:SetZooShow(show)
        self.db.options.zoo.show = show
        self.ZooShow:SetChecked(self.db.options.zoo.show)
        if (self.db.options.zoo.show) then
            self.zooPanel:ShowFull()
        else
            self.zooPanel:HideFull()
        end
    end
    ---------------------------------------------------------------------------
    --- Get the zoo visibility option.
    function self:GetZooShow()
        return self.db.options.zoo.show
    end
    ---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
        if (eventName == "ADDON_LOADED") then
        end
    end
    ---------------------------------------------------------------------------
    --- Catch events and forard to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(events, eventName, ...)
    end)
    self:RegisterEvent("ADDON_LOADED")
    InterfaceOptions_AddCategory(self)
end
