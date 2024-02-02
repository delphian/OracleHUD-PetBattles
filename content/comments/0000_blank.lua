--[[
List exactly 100 unique random things a [] might do, format as an emote 
command as would be delivered in an rpg with /me, but omit the /me command 
itself. Format into a lua table named 'emote' and prepend the local keyword.

Then list exactly 100 unique random things a [] might do when it first 
wakes up, related to previously being asleep. Format as an emote /me command, 
but omit the /me command itself. Format into a lua table named 'emote_summon' 
and prepend the local keyword.

Then list extactly 100 unique random things a [] might say, Format into a lua 
table named 'speak' and prepend the local keyword.

Then list extactly 100 unique random things a [] might say in celebration 
after winning an epic battle. Format into a lua table named 'speak_win' and 
prepend the local keyword.

Then list exactly 100 unique random empathetic and considerate things a []
might say in mourning about it's death. Format as a lua table named 
'speak_dead' and prepend the local keyword.
--]]
if (ORACLEHUD_PB_DB_UPDATE == nil) then
    ORACLEHUD_PB_DB_UPDATE = {}
end
ORACLEHUD_PB_DB_UPDATE.s0000 = function(db) 
    db.content.petComments.s0000 = function(db, type)
        local comment = nil
        local collection = nil
        if (type == nil) then
            type = "speak"
        end
        local emote = {
        }
        local emote_summon = {
        }
        local speak = {
        }
        local speak_win = {
        }
        local speak_dead = {
        }
        if (type:lower() == "speak") then
            collection = speak
        elseif (type:lower() == "emote") then
            collection = emote
        elseif (type:lower() == "speak_win") then
            collection = speak_win
        elseif (type:lower() == "emote_summon") then
            collection = emote_summon
        elseif (type:lower() == "speak_dead") then
            collection = speak_dead
        end
        local comment = "Has nothing interesting to say"
        if (collection ~= nil and OracleHUD_TableGetLength(collection) > 0) then
            comment = collection[math.random(1, OracleHUD_TableGetLength(collection))]
        end
        return comment
    end
end
