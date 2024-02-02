--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_AchievementService_OnLoad(self)
	self.searchActive = false
	self.searchFinished = false
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db		    Oracle HUD Pet Battle database.
	function self:Configure(db)
        if (db == nil) then
            error("OracleHUD_PB_AchievementService.Configure(): Invalid arguments.")
		end
		self.db = db
	end
	---------------------------------------------------------------------------
	--- All required resources and data has been loaded. Set initial state.
    -- @param callback      Execute callback when initialize has finished.
    function self:Initialize(callback)
        if (self.db.debug) then print("..Initialize Achievement Service") end
		self:RegisterEvent("ACHIEVEMENT_SEARCH_UPDATED")
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
	function self:Search(text, callback)
		if (text == nil or callback == nil) then
			error("OracleHUD_PB_AchievementService.Search(): Invalid arguments.")
		end
		if (self.searchActive == true) then
			error("OracleHUD_PB_AchievementService.Search(): Search already in progress.")
		end
		self.searchActive = true
		self.searchFinished = false
		SetAchievementSearchString(text)
		C_Timer.NewTicker(1, function(ticker)
			if (self.searchFinished) then
				ticker:Cancel()
				local searchResults = {}
				local numFiltered = GetNumFilteredAchievements()
				for i = 1, numFiltered do
					local achievementId = GetFilteredAchievementID(i)
					table.insert(searchResults, self:GetAchievement(achievementId))
				end
				self.searchActive = false
				callback(searchResults)
			end
		end)
	end
	---------------------------------------------------------------------------
	--- Get normalized achievement table.
	-- @param achievementId		Unique achievement identifier.
	function self:GetAchievement(achievementId)
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
		local achievement = {
			id = id,
			name = name,
			icon = icon,
			completed = completed,
			statistic = isStatistic,
			criteria = criterias
		}
		return achievement
	end
    ---------------------------------------------------------------------------
    --- Process incoming events.
    -- @param event		Unique event identification
    -- @param eventName	Human friendly name of event
    function self:OnEvent(event, eventName, ...)
		if (eventName == "ACHIEVEMENT_SEARCH_UPDATED") then
			self.searchFinished = true
		end
	end
    ---------------------------------------------------------------------------
    --- Catch events and forward to handler.
    self:SetScript("OnEvent", function(event, eventName, ...)
        self:OnEvent(event, eventName, ...)
    end)
end
