--- Uniform pet information table.
--- @class OracleHUD_PB_PetInfo
--- @description                    
--- @field id                   string?     GUID of pet.
--- @field creatureId           number?     Unique 
--- @field speciesId            number      Unique pet species identifier.
--- @field name                 string      WOW pet name.
--- @field customName           string?     Custom name.
--- @field displayId            integer     Display 3d model identifier.
--- @field health               integer?    Health of the pet.
--- @field healthMax            integer?    Maximum possible health of pet.
--- @field experience           integer?    Experience of pet.
--- @field experienceMax        integer?    Maximum experience of pet.
--- @field level                integer?    Level of pet (0-25).
--- @field type                 integer     Type of pet.
--- @field speed                integer?    Speed.
--- @field power                integer?    Power.
--- @field rarity               integer?    Quality.
--- @field abilities            any         OracleHUD_PB_PetAbility
--- @field slot                 integer?    Used when pet is in a pet battle loadout.
--- @field tooltip              string
--- @field description          string
--- @field content              any?        Random comments pet may say.
--- @field icon                 string?
--- @field companionId          number
--- @field sources              any
--- @field canBattle            boolean
--- @field wild                 boolean
OracleHUD_PB_PetInfo = {}
-------------------------------------------------------------------------------
--- Get a random emote from the pet.
--- @param type     ORACLEHUD_PB_CONTENTEMOTE_ENUM
--- @return string emote
function OracleHUD_PB_PetInfo:GetEmote(type)
    local link = "["..self.name.."]"
    if (self.id ~= nil) then
        link = C_PetJournal.GetBattlePetLink(self.id);
    end
    local text = "Has nothing interesting to say"
    if (self.content.emotes ~= nil) then
        local table = self.content.emotes[type]
        text = table[math.random(1, OracleHUD_TableGetLength(table))]
        if (type == ORACLEHUD_PB_CONTENTEMOTE_ENUM.SPEAK) then
            text = 'says "' .. text .. '"'
        else
            text = string.lower(text)
        end
    end
    local emote = link .. ' ' .. text
    return emote
end
