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
    if (self.content.emotes ~= nil and self.content.emotes[type] ~= nil) then
        local table = self.content.emotes[type]
        text = table[math.random(1, #table)]
        if (type == ORACLEHUD_PB_CONTENTEMOTE_ENUM.SPEAK) then
            text = 'says "' .. text .. '"'
        else
            text = string.lower(text)
        end
    end
    local emote = link .. ' ' .. text
    return emote
end
-------------------------------------------------------------------------------
--- Set the emotes for a type.
--- @param type     ORACLEHUD_PB_CONTENTEMOTE_ENUM
--- @param emotes   any     Table containing an array of emotes.
function OracleHUD_PB_PetInfo:SetEmotes(type, emotes)
    if (self.content == nil) then self.content = {} end
    if (self.content.emotes == nil) then self.content.emotes = {} end
    self.content.emotes[type] = emotes
end
-------------------------------------------------------------------------------
--- Save the emotes to the datastore.
--- @param db 		    OracleHUD_PB_DB	        OracleHUD Pet Battles Database.
function OracleHUD_PB_PetInfo:SaveEmotes(db)
    local key = "s" .. self.speciesId
    db.content.petComments[key] = self.content.emotes
end
-------------------------------------------------------------------------------
--- Get the database table where pet can store information.
--- @param db   OracleHUD_PB_DB (Optional, defaults to self.db) OracleHUD Pet Battles Database.
--- @return OracleHUD_PB_PetInfo_Table
function OracleHUD_PB_PetInfo:GetDBTable(db)
    if (db == nil) then db = self.db end
    local key = "s" .. self.id
    if (db.pets == nil) then db.pets = {} end
    if (db.pets[key] == nil) then
        db.pets[key] = {
            stats = {
                kills = 0,
                deaths = 0
            }
        }
    end
    return db.pets[key]
end
-------------------------------------------------------------------------------
--- Get number of others that this pet has killed.
--- @param db   OracleHUD_PB_DB (Optional, defaults to self.db) OracleHUD Pet Battles Database.
function OracleHUD_PB_PetInfo:GetKills(db)
    if (db == nil) then db = self.db end
    local kills = 0
    local storage = self:GetDBTable(db)
    kills = storage.stats.kills or 0
    return kills
end
-------------------------------------------------------------------------------
--- Set number of others that this pet has killed.
--- @param kills    number  Number of others that this pet has killed.
--- @param db       OracleHUD_PB_DB (Optional, defaults to self.db) OracleHUD Pet Battles Database.
function OracleHUD_PB_PetInfo:SetKills(kills, db)
    if (db == nil) then db = self.db end
    local storage = self:GetDBTable(db)
    storage.stats.kills = kills
end
-------------------------------------------------------------------------------
--- Get number of times this pet has died.
--- @param db   OracleHUD_PB_DB     (Optional, defaults to self.db) OracleHUD Pet Battles Database.
function OracleHUD_PB_PetInfo:GetDeaths(db)
    if (db == nil) then db = self.db end
    local deaths = 0
    local storage = self:GetDBTable(db)
    deaths = storage.stats.deaths or 0
    return deaths
end
-------------------------------------------------------------------------------
--- Set number of times this pet has died.
--- @param deaths   number          Number of times this pet has died.
--- @param db       OracleHUD_PB_DB (Optional, defaults to self.db) OracleHUD Pet Battles Database.
function OracleHUD_PB_PetInfo:SetDeaths(deaths, db)
    if (db == nil) then db = self.db end
    local storage = self:GetDBTable(db)
    storage.stats.deaths = deaths
end
