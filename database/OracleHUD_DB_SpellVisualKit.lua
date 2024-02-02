--- 
--- Navigation through database for ENTANGLING_VINES (66):
--- db2.SpellVisualKitModelAttach
--- 	.ParentSpellVisualKitID (66)
--- 	.SpellvisualEffectNameID (80)
---	db2.SpellVisualEffectName
---		.ID (80)
---		.ModelFileDataID (166042)
--- Files
---		.Fdid (166042)
---		.Filename (spells/entanglingroots_state.m2)
---
--- @enum ORACLEHUD_DB_SPELL_VISUAL_KIT_ENUM
ORACLEHUD_DB_SPELL_VISUAL_KIT_ENUM = {
	ENTANGLING_VINES = 66,
	HOLY_IMPACT_LOW_CHEST = 121,
	CHAINS_OF_ICE = 125,
	BRILLIANCE_AURA = 136,
	BRILLIANCE_AURA_2 = 139,
	GARRISON_MINE_PICKAXE = 166,
	FIRST_AID_HAND = 173,
	SMITHING_HAMMER = 545,
	HOLY_PRECAST_UBER_HAND_BASE = 587,
	HOLY_WARD_HEAL_BASE = 28898
}
ORACLEHUD_DB_SPELL_VISUAL_KIT_TEXT = {
	[66] = "Entangling Vines",
	[121] = "Holy Impact Low Chest",
	[125] = "Chains of Ice",
	[136] = "Brilliance Aura",
	[139] = "Brilliance Aura 2",
	[166] = "Garrison Mine Pickaxe",
	[173] = "First Aid Hand",
	[545] = "Smithing Hammer",
	[587] = "Holy Precast Uber Hand and Base",
	[28898] = "Holy Ward Heal Base"
}
-------------------------------------------------------------------------------
--- Get the visual kit name from the enumeration.
--- @param kitEnum ORACLEHUD_DB_SPELL_VISUAL_KIT_ENUM
--- @return string|nil
function OracleHUD_DB_GetSpellVisualKitText(kitEnum)
	return ORACLEHUD_DB_SPELL_VISUAL_KIT_TEXT[kitEnum]
end