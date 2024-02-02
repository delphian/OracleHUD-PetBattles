--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_SpellService_OnLoad(self)
	self.searchActive = false
	self.searchFinished = false
	self.searchResults = nil
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db		    Oracle HUD Pet Battle database.
	function self:Configure(db)
        if (db == nil) then
            error("OracleHUD_PB_SpellService.Configure(): Invalid arguments.")
		end
		self.db = db
	end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    -- @param callback      Execute callback when initialize has finished.
    function self:Initialize(callback)
        if (self.db.debug) then print("..Initialize Spell Service") end
		self:RegisterEvent("SPELL_DATA_LOAD_RESULT")
		if (callback ~= nil) then
			callback()
		end
	end
	---------------------------------------------------------------------------
	--- Search achievements by name.
	--- Example:
	--- 	self.achievementSvc:Search("\"Experienced Pet Battler\"", function(results)
	---			print(OracleHUD_Dump(results))
	---		end)
	-- @param text			Text that must be contained in achievement name.
	-- @param callback      Execute callback with search results.
	function self:GetSpell(id, callback)
		if (id == nil or callback == nil) then
			error("OracleHUD_PB_SpellService.Search(): Invalid arguments.")
		end
		if (self.searchActive == true) then
			error("OracleHUD_PB_SpellService.Search(): Search already in progress.")
		end
		self.searchActive = true
		self.searchFinished = false
		if (C_Spell.DoesSpellExist(id)) then
			if (C_Spell.IsSpellDataCached(id)) then
				self.searchActive = false
				callback({
					id = id,
					exists = true,
					wasCached = true,
					data = { GetSpellInfo(id) }
				})
			else
				C_Spell.RequestLoadSpellData(id)		
				C_Timer.NewTicker(1, function(ticker)
					if (self.searchFinished) then
						ticker:Cancel()
						self.searchActive = false
						-- table copy?
						callback({
							id = id,
							exists = true,
							wasCached = false,
							data = { GetSpellInfo(id) }
						})
					end
				end)
			end
		else
			self.searchActive = false
			callback({
				id = id,
				exists = false,
				wasCached = false
			})
		end
	end
--[[
	---------------------------------------------------------------------------
	--- Get normalized spell table.
	-- @param spellId		Unique spell identifier.
	function self:GetSpell(spellId)
		local id, name, points, completed, month, day, year, description, flags,
			  icon, rewardText, isGuild, wasEarnedByMe, earnedBy, isStatistic
			  = GetAchievementInfo(achievementId)
		local numCriteria = GetAchievementNumCriteria(achievementId)
		local criterias = {}
		for i = 1, numCriteria do
			local criteriaString, criteriaType, completed, quantity, reqQuantity, 
				  charName, flags, assetID, quantityString, criteriaID, eligible
				  = GetAchievementCriteriaInfo(achievementId, i)
			table.insert(criterias, {
				id = criteriaID,
				type = criteriaType,
				name = criteriaString,
				quantity = quantity,
				required = reqQuantity,
				quantityDescription = quantityString
			})
		end
		local spell = {
			id = id,
		}
		return spell
	end
--]]
	---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
		if (eventName == "SPELL_DATA_LOAD_RESULT") then
			self.searchFinished = true
			self.searchResults = ...
		end
	end
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(events, eventName, ...)
    end)
	---	
	--- Spell slash command
	SLASH_OHPBSPELL1 = "/ohpbspell"
	SlashCmdList["OHPBSPELL"] = function(msg, editBox)
		local _, _, arg, _ = string.find(msg, "%s?(%w+)%s?(.*)")
		self:GetSpell(arg, function(...)
			print(OracleHUD_Dump(...))
		end)
	end
end