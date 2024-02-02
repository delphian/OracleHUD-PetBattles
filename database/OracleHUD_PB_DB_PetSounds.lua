-------------------------------------------------------------------------------
--- Get the sound kit identifier based on a species id.
-- @param speciesId     Battle pet species id.
function OracleHUD_PB_PetSoundsGetSoundKitId(speciesId)
    local soundKitDb = {
        [646] = 6820    -- Chicken
    }
    return soundKitDb[speciesId]
end