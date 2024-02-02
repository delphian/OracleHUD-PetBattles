-------------------------------------------------------------------------------
--- Set the sort pet journal filter.
-- @param filteredCollected		Return object from OracleHUD_PB_GetFilteredCollected().
function OracleHUD_PB_SetFilteredSort(filteredSort)
	C_PetJournal.SetPetSortParameter(filteredSort)
end
-------------------------------------------------------------------------------
--- Get the sort pet journal filter.
-- @param value		Force sort filter to have this value.
function OracleHUD_PB_GetFilteredSort(value)
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
-- @param filteredCollected		Return object from OracleHUD_PB_GetFilteredCollected().
function OracleHUD_PB_SetFilteredCollected(filteredCollected)
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_COLLECTED, filteredCollected.collected)
	C_PetJournal.SetFilterChecked(LE_PET_JOURNAL_FILTER_NOT_COLLECTED, filteredCollected.uncollected)
end
-------------------------------------------------------------------------------
--- Get the collected/uncollected pet journal filter in the form of a table.
-- @param value		Force filter 'check' to have this value.
function OracleHUD_PB_GetFilteredCollected(value)
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

function OracleHUD_PB_SetFilteredPetTypes(filteredPetTypes)
	local maxPetTypes = C_PetJournal.GetNumPetTypes()
	for k, v in pairs(filteredPetTypes) do
		C_PetJournal.SetPetTypeFilter(v.index, v.checked)
	end
end

--- Get the pet type filter in the form of a table
-- @param value		Force 'checked' to have this value
function OracleHUD_PB_GetFilteredPetTypes(value)
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

