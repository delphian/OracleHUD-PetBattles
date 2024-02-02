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
    end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    -- @param callback      Execute callback when initialize has finished.
    function self:Initialize(callback)
        if (self.db.debug) then print("..Initialize Interface Options") end
        self.Title = self:CreateFontString("ARTWORK", nil, "GameFontNormalLarge")
        self.Title:SetPoint("TOP")
        self.Title:SetText("Oracle HUD Pet Battles")
        -- Debug
        self.Debug = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
        self.Debug:SetPoint("TOPLEFT", 20, -20)
        self.Debug.Text:SetText("Debug Module Loading")
        self.Debug:HookScript("OnClick", function(_, btn, down)
            self.db.debug = self.Debug:GetChecked()
        end)
        self.Debug:SetChecked(self.db.debug)
        -- Debug Show Combat Log
        self.ShowCombatLog = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
        self.ShowCombatLog:SetPoint("TOPLEFT", self.Debug, "BOTTOMLEFT", 20, -2)
        self.ShowCombatLog.Text:SetText("Show Combat Log")
        self.ShowCombatLog:HookScript("OnClick", function(_, btn, down)
            self.db.modules.combatLogService.options.showLog = self.ShowCombatLog:GetChecked()
        end)
        self.ShowCombatLog:SetChecked(self.db.modules.combatLogService.options.showLog)
        -- Debug combat log
        self.DebugCombatLogEvents = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
        self.DebugCombatLogEvents:SetPoint("TOPLEFT", self.ShowCombatLog, "BOTTOMLEFT", 0, -2)
        self.DebugCombatLogEvents.Text:SetText("Show Combat Log Events")
        self.DebugCombatLogEvents:HookScript("OnClick", function(_, btn, down)
            self.db.modules.combatLogService.options.debugEvents = self.DebugCombatLogEvents:GetChecked()
        end)
        self.DebugCombatLogEvents:SetChecked(self.db.modules.combatLogService.options.debugEvents)
        -- Show Missing Pets
        self.ShowMissing = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
        self.ShowMissing:SetPoint("TOPLEFT", self.DebugCombatLogEvents, "BOTTOMLEFT", -20, -2)
        self.ShowMissing.Text:SetText("Show Uncaptured Pets")
        self.ShowMissing:HookScript("OnClick", function(_, btn, down)
            self.db.options.uncaptured.show = self.ShowMissing:GetChecked()
            if (self.db.options.uncaptured.show) then
                self.uncollectedPanel:ShowFull()
            else
                self.uncollectedPanel:HideFull()
            end
        end)
        self.ShowMissing:SetChecked(self.db.options.uncaptured.show)
        -- Show Zoo
        self.ShowZoo = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
        self.ShowZoo:SetPoint("TOPLEFT", self.ShowMissing, "BOTTOMLEFT", 0, -2)
        self.ShowZoo.Text:SetText("Show Zoo")
        self.ShowZoo:HookScript("OnClick", function(_, btn, down)
            self:SetZooShow(self.ShowZoo:GetChecked())
        end)
        self.ShowZoo:SetChecked(self:GetZooShow())
        -- Show Community Panel
        self.ShowCommunity = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
        self.ShowCommunity:SetPoint("TOPLEFT", self.ShowZoo, "BOTTOMLEFT", 0, -2)
        self.ShowCommunity.Text:SetText("Show Community")
        self.ShowCommunity:HookScript("OnClick", function(_, btn, down)
            self.db.options.community.show = self.ShowCommunity:GetChecked()
            if (self.db.options.community.show) then
                OracleHUD_PB_PanelCommunity:ShowFull()
            else
                OracleHUD_PB_PanelCommunity:HideFull()
            end
        end)
        self.ShowCommunity:SetChecked(self.db.options.community.show)
        -- Show Ally Loadout
        self.ShowAllyLoadout = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
        self.ShowAllyLoadout:SetPoint("TOPLEFT", self.ShowCommunity, "BOTTOMLEFT", 0, -2)
        self.ShowAllyLoadout.Text:SetText("Show Pet Loadout")
        self.ShowAllyLoadout:HookScript("OnClick", function(_, btn, down)
            self.db.modules.loadout.options.show = self.ShowAllyLoadout:GetChecked()
            if (self.db.modules.loadout.options.show) then
                OracleHUD_PB_PanelLoadoutAlly:ShowFull()
            else
                OracleHUD_PB_PanelLoadoutAlly:HideFull()
            end
        end)
        self.ShowAllyLoadout:SetChecked(self.db.modules.loadout.options.show)
        -- Show Enemy Loadout
        self.ShowOpponents = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
        self.ShowOpponents:SetPoint("TOPLEFT", self.ShowAllyLoadout, "BOTTOMLEFT", 20, -2)
        self.ShowOpponents.Text:SetText("Show Enemy Loadout")
        self.ShowOpponents:HookScript("OnClick", function(_, btn, down)
            self.db.modules.loadout.options.showOpponents = self.ShowOpponents:GetChecked()
            if (self.db.modules.loadout.options.showOpponents) then
                -- OracleHUD_PBEnemyPanel:ShowFull()
            else
                OracleHUD_PB_PanelLoadoutEnemy:HideFull()
            end
        end)
        self.ShowOpponents:SetChecked(self.db.modules.loadout.options.showOpponents)
        -- Allow pet quip after battle.
        self.AllyLoadoutQuip = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
        self.AllyLoadoutQuip:SetPoint("TOPLEFT", self.ShowOpponents, "BOTTOMLEFT", 0, -2)
        self.AllyLoadoutQuip.Text:SetText("Allow pet quip after battle.")
        self.AllyLoadoutQuip:HookScript("OnClick", function(_, btn, down)
            self.db.modules.loadout.options.afterBattleQuip = self.AllyLoadoutQuip:GetChecked()
        end)
        self.AllyLoadoutQuip:SetChecked(self.db.modules.loadout.options.afterBattleQuip)
        if (callback ~= nil) then
            callback()
        end
    end
    ---------------------------------------------------------------------------
    --- Set the zoo visibility option.
    -- @param show      Show or hide the zoo panel.
    function self:SetZooShow(show)
        self.db.options.zoo.show = show
        self.ShowZoo:SetChecked(self.db.options.zoo.show)
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
