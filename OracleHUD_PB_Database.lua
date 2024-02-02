-------------------------------------------------------------------------------
--- Initialize the pet battle database
-- @param db 		global pet battle database
-- @param reset		Reset the database to default
function OracleHUD_PB_DatabaseInitialize(db, reset)
	-- Setup interface options
	if (db.options == nil) then
		db.options = {}
	end
	if (db.options.uncaptured == nil) then
		db.options.uncaptured = {
			show = true
		}
	end
	if (db.options.zoo == nil) then
		db.options.zoo = {
			show = true
		}
	end
	if (db.options.community == nil) then
		db.options.community = {
			show = true
		}
	end
	if (db.debug == nil) then
		db.debug = false
	end
	if (db.options.debug == nil) then
		db.options.debug = {
			showBackgrounds = false
		}
	end
	-- Reset
	if (reset == true or db.loaded == nil) then
		db.debug = false
		db.loaded = true
		db.primaryFontSize = 8
		db.meta = {
			loginCount = 0
		}
		db.supportPanel = {
			buttonSizePct = 0.15
		}
		db.loadout = {
			slot1 = {
				pet = {}
			},
			slot2 = {
				pet = {}
			},
			slot3 = {
				pet = {}
			},
			enemy = {
				slot1 = {
					pet = {}
				}
			}
		}
		db.battleOrder = {
			ally = {
				max = 0,
				order = {}
			},
			enemy = {
				max = 0,
				order = {}
			}
		}
		db.content = {
			petComments = {},
			petCommentsCallbacks = {}
		}
		db.status = {
			ready = false,
			inBattle = false
		}
	end
	if (OracleHUD_PB_DB_UPDATE ~= nil) then
		for k, v in pairs(OracleHUD_PB_DB_UPDATE) do
			v(db)
		end
	end
end
