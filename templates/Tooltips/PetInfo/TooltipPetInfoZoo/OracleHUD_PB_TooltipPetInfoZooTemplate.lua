--- Called by XML onload.
-- @param self      Our main XML frame.
function OracleHUD_PB_TooltipPetInfoZooTemplate_OnLoad(self)
	local subLayer = 0;
	self.originalHeight = self:GetHeight()
	self.linePool = CreateFontStringPool(self, "ARTWORK", subLayer, "GameTooltipText")
	self.AddLine = OracleHUD_PB_TooltipPetInfoZooTemplate_AddTextLine
	self.HideFull = OracleHUD_FrameHideFull
	self.ShowFull = OracleHUD_FrameShowFull
	self.spellId = 0
    ---------------------------------------------------------------------------
    --- Configure frame with required data.
    -- @param db		Oracle HUD Pet Battle database.
	--- @param petInfo	OracleHUD_PB_PetInfo		OracleHUD_PB Uniform pet table.
	-- @param user      Owner of the pet.
	-- @param frame		Frame of pet in zoo.
	function self:Configure(db, petInfo, user, frame)
		self.db = db
		self.petInfo = petInfo
		self.PetDebug:Configure(self.db, ORACLEHUD_PB_DB_PET_ANIMATION_TEXT)
		self.PetDebug:SetPetInfo(self.petInfo)
		self.user = user
		self.frame = frame
		self:SetHeight(self.originalHeight)

		self.battlePetID = petInfo.id
		self.speciesID = petInfo.speciesId
		self.Name:SetText(petInfo.name)
		if (petInfo.rarity ~= nil) then
			self.Name:SetTextColor(ITEM_QUALITY_COLORS[petInfo.rarity].r, ITEM_QUALITY_COLORS[petInfo.rarity].g, ITEM_QUALITY_COLORS[data.rarity].b)
		else
			self.Name:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		end
		self.PetType:SetText(_G["BATTLE_PET_NAME_"..petInfo.type])
		self.Level:SetFormattedText(BATTLE_PET_CAGE_TOOLTIP_LEVEL, petInfo.level)
		self.Health:SetText(petInfo.healthMax)
		self.Power:SetText(petInfo.power)
		self.Speed:SetText(petInfo.speed)
		self.PetTypeTexture:SetTexture("Interface\\PetBattles\\PetIcon-"..PET_TYPE_SUFFIX[petInfo.type])

		self.AnimationBox:SetPetInfo(petInfo)



		self.linePool:ReleaseAll()
		self.textLineAnchor = nil

		OracleHUD_FrameSetWidthSquarePct(self.SizeUp, 0.10)
		OracleHUD_FrameSetWidthSquarePct(self.SizeDown, 0.10)
		OracleHUD_FrameSetWidthSquarePct(self.Cage, 0.10)
		OracleHUD_FrameSetWidthSquarePct(self.PetDebug, 0.10)
		self.SizeUp:RegisterForClicks("AnyDown")
		self.SizeDown:RegisterForClicks("AnyDown")
		self.Cage:RegisterForClicks("AnyDown")
		self.SizeUp:SetScript("OnClick", function(button)
			button:Hide()
			self.frame:SizeUp()
			C_Timer.After(0.1, function()
				button:Show()
			end)
		end)
		self.SizeDown:SetScript("OnClick", function(button)
			button:Hide()
			self.frame:SizeDown()
			C_Timer.After(0.1, function()
				button:Show()
			end)
		end)
		self.Cage:SetScript("OnClick", function(button)
			button:Hide()
			self.frame:Hide()
			self:Hide()
			C_Timer.After(0.1, function()
				button:Show()
			end)
		end)

		local account = C_BattleNet.GetAccountInfoByGUID(self.user)
		local server = account.gameAccountInfo.realmName
		local player = account.gameAccountInfo.characterName
		self.User:SetText(server .. ": "..player)

		OracleHUD_FrameSetWidthSquarePct(self.AnimationBox, 1.0)
		local positions = OracleHUD_PB_DB_AnimationGetPosition(self.petInfo.speciesId)
		if (positions ~= nil and positions.default ~= nil and positions.default.hRatio ~= nil) then
			local newHeight = self.AnimationBox:GetHeight() * positions.default.hRatio
			local newHeightDiff = self.AnimationBox:GetHeight() - newHeight
			self.AnimationBox:SetHeight(newHeight)
			self:SetHeight(self:GetHeight() - newHeightDiff)
		end


--		OracleHUD_PB_ZooTooltipPetInfoTemplate_AddTextLine(self, server..": "..player, 1.0, 1.0, 1.0, false)

	end

--[[
:ApplySpellVisualKit()

VINES (66)
SpellVisualKitModelAttach
	.ParentSpellVisualKitID (66)
	.SpellvisualEffectNameID (80)
SpellvisualEffectName
	.ID (80)
	.ModelFileDataID (166042)
Files
	.Fdid (166042)
	.Filename (spells/entanglingroots)

BONES (55)
SpellVisualKitModelAttach
	.ParentSpellVisualKitID (55)
	.SpellvisualEffectNameID (1322)
SpellvisualEffectName
	.ID (1322)
	.ModelFileDataID (165751)
Files
	.Fdid (165751)
	.Filename (spells/bonearmor_state_chest.m2)

]]
	SLASH_SPELL1 = "/spelltest"
	SlashCmdList["SPELL"] = function(msg, editBox)
		local _, _, arg, _ = string.find(msg, "%s?(%w+)%s?(.*)")
		C_Timer.NewTicker(4, function()
			self.spellId = self.spellId + 1
			self.AnimationBox:SetPetInfo(self.AnimationBox.petInfo)
			self.AnimationBox:SetSpell(self.spellId)
			print("Spell", self.spellId)
		end)
	end 

end
function OracleHUD_PB_TooltipPetInfoZooTemplate_AddTextLine(self, text, r, g, b, wrap)
print("OK")
	local LinePadding = 8
	if not r then
		r, g, b = NORMAL_FONT_COLOR:GetRGB()
	end
	local anchor = self.textLineAnchor;
	if (anchor == nil) then
		anchor = self.AnimationBox
	end
	local line = self.linePool:Acquire();
	line:SetText(text);
	line:SetTextColor(r, g, b);
	line:SetPoint("TOP", anchor, "BOTTOM", 0, -LinePadding);
	line:SetPoint("LEFT", self.Name, "LEFT");
	if wrap then
		line:SetPoint("RIGHT", self, "RIGHT");
	end
	line:Show();
	self.textLineAnchor = line;
	self:SetHeight(self:GetHeight() + line:GetHeight() + LinePadding);
end

