-------------------------------------------------------------------------------
--- List all maximum pet experience values index by pet level.
ORACLEHUD_PB_DB_PET_EXPERIENCE_MAX = {
	[1] = 50,
	[2] = 110,
	[3] = 120,
	[4] = 195,
	[5] = 280,
	[6] = 450,
	[7] = 560,
	[8] = 595,
	[9] = 720,
	[10] = 760,
	[11] = 900,
	[12] = 945,
	[13] = 990,
	[14] = 1150,
	[15] = 1200,
	[16] = 1250,
	[17] = 1430,
	[18] = 1485,
	[19] = 1540,
	[20] = 1595,
	[21] = 1800,
	[22] = 1860,
	[23] = 1920,
	[24] = 1980,
	[25] = 1980
}
-------------------------------------------------------------------------------
--- Get the maximum experience based on pet level.
-- @param level		Pet level.
function OracleHUD_PB_DB_PetExperienceGetMax(level)
	return ORACLEHUD_PB_DB_PET_EXPERIENCE_MAX[level]
end
