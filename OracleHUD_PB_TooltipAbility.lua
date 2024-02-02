--------------------------------------------
---------Pet Battle Ability Tooltip---------
--------------------------------------------
ORACLEHUD_PB_ABILITY_INFO = OracleHUD_PB_TooltipAbilityTemplate_GetInfoTable();

function ORACLEHUD_PB_ABILITY_INFO:GetCooldown()
	if (self.abilityID) then
		return 0;
	end
	local isUsable, currentCooldown = C_PetBattles.GetAbilityState(self.petOwner, self.petIndex, self.abilityIndex);
	return currentCooldown;
end

function ORACLEHUD_PB_ABILITY_INFO:GetAbilityID()
	if (self.abilityID) then
		return self.abilityID;
	end
	local id = C_PetBattles.GetAbilityInfo(self.petOwner, self.petIndex, self.abilityIndex);
	return id;
end

function ORACLEHUD_PB_ABILITY_INFO:IsInBattle()
	return true;
end

function ORACLEHUD_PB_ABILITY_INFO:GetMaxHealth(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetMaxHealth(petOwner, petIndex);
end

function ORACLEHUD_PB_ABILITY_INFO:GetHealth(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetHealth(petOwner, petIndex);
end

function ORACLEHUD_PB_ABILITY_INFO:GetAttackStat(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetPower(petOwner, petIndex);
end

function ORACLEHUD_PB_ABILITY_INFO:GetSpeedStat(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetSpeed(petOwner, petIndex);
end

function ORACLEHUD_PB_ABILITY_INFO:GetState(stateID, target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetStateValue(petOwner, petIndex, stateID);
end

function ORACLEHUD_PB_ABILITY_INFO:GetWeatherState(stateID)
	return C_PetBattles.GetStateValue(Enum.BattlePetOwner.Weather, PET_BATTLE_PAD_INDEX, stateID);
end

function ORACLEHUD_PB_ABILITY_INFO:GetPadState(stateID, target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetStateValue(petOwner, PET_BATTLE_PAD_INDEX, stateID);
end

function ORACLEHUD_PB_ABILITY_INFO:GetPetOwner(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return petOwner;
end

function ORACLEHUD_PB_ABILITY_INFO:HasAura(auraID, target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return PetBattleUtil_PetHasAura(petOwner, petIndex, auraID);
end

function ORACLEHUD_PB_ABILITY_INFO:GetPetType(target)
	local petOwner, petIndex = self:GetUnitFromToken(target);
	return C_PetBattles.GetPetType(petOwner, petIndex);
end


--For use by other functions here
function ORACLEHUD_PB_ABILITY_INFO:GetUnitFromToken(target)
	if ( target == "default" ) then
		target = "self";
	elseif ( target == "affected" ) then
		target = "enemy";
	end

	if ( target == "self" ) then
		return self.petOwner, self.petIndex;
	elseif ( target == "enemy" ) then
		local owner = PetBattleUtil_GetOtherPlayer(self.petOwner);
		return owner, C_PetBattles.GetActivePet(owner);
	else
		error("Unsupported token: "..tostring(target));
	end
end

function OracleHUD_PB_TooltipAbility_SetAbility(petOwner, petIndex, abilityIndex)
	ORACLEHUD_PB_ABILITY_INFO.petOwner = petOwner;
	ORACLEHUD_PB_ABILITY_INFO.petIndex = petIndex;
	ORACLEHUD_PB_ABILITY_INFO.abilityID = nil;
	ORACLEHUD_PB_ABILITY_INFO.abilityIndex = abilityIndex;
	OracleHUD_PB_TooltipAbilityTemplate_SetAbility(OracleHUD_PB_TooltipAbility, ORACLEHUD_PB_ABILITY_INFO);
end

function OracleHUD_PB_TooltipAbility_SetAbilityByID(petOwner, petIndex, abilityID, additionalText)
	ORACLEHUD_PB_ABILITY_INFO.petOwner = petOwner;
	ORACLEHUD_PB_ABILITY_INFO.petIndex = petIndex;
	ORACLEHUD_PB_ABILITY_INFO.abilityID = abilityID;
	ORACLEHUD_PB_ABILITY_INFO.abilityIndex = nil;
	OracleHUD_PB_TooltipAbilityTemplate_SetAbility(OracleHUD_PB_TooltipAbility, ORACLEHUD_PB_ABILITY_INFO, additionalText);
end
