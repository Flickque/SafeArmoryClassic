---A library to make similar profession API calls for classic and BfA
-- luacheck: ignore api
_G['ProfessionAPI'] = {}
local api = _G['ProfessionAPI']
api = LibStub:NewLibrary("LibProfessionAPI-1.0", 1)
if not api then
    return	-- already loaded and no upgrade necessary
end

-- defined in LibProfessions.lua
local WoWClassic = _G['WoWClassic']

--local WoWClassic = select(4, GetBuildInfo()) < 20000

function api:IsReady()
    if WoWClassic then --Professions are always ready in classic
        return true
    elseif not C_TradeSkillUI.IsTradeSkillReady() or C_TradeSkillUI.IsDataSourceChanging() then
        return false
    else
        return true
    end
end

--- Get info about the current profession
--- @return string Profession name
--- @return number Current skill
--- @return number Maximum skill
--- @return number Skill modifier (Not classic)
--- @return number Profession ID (Not classic)
function api:GetInfo()
    if WoWClassic then
        return GetTradeSkillLine();
    else
        local tradeSkillID, skillLineName, skillLineRank, skillLineMaxRank, skillLineModifier,
        parentSkillLineID, parentSkillLineName = C_TradeSkillUI.GetTradeSkillLine()
        return parentSkillLineName or skillLineName, skillLineRank, skillLineMaxRank, skillLineModifier,
        parentSkillLineID or tradeSkillID
    end
end

--/dump LibStub("LibProfessionAPI-1.0"):GetName()
--- @deprecated Use GetInfo
function api:GetName()
    return self:GetInfo()
end

--- Get the number of recipes learned
--- This is currently working only in WoW classic
--- @return number Number of recipes
function api:NumRecipes()
	--TODO: Not working in BfA
    return GetNumTradeSkills()
end

--- Get the number of reagents for a recipe
--- @param recipeID number Recipe ID
--- @return number Number of reagents
function api:NumReagents(recipeID)
    if WoWClassic then
        return GetTradeSkillNumReagents(recipeID)
    else
        return C_TradeSkillUI.GetRecipeNumReagents(recipeID)
    end
end


--- Get item link for a reagent
--- @param recipeID number Recipe ID
--- @param reagentIndex number Reagent index
function api:GetReagentItemLink(recipeID, reagentIndex)
    if WoWClassic then
        return GetTradeSkillReagentItemLink(recipeID, reagentIndex);
    else
        return C_TradeSkillUI.GetRecipeReagentItemLink(recipeID, reagentIndex);
    end
end

--/dump LibStub("LibProfessionAPI-1.0"):GetReagentInfo(2,1)
--- Get information about a reagent
--- @param recipeID number Recipe ID (BfA) or recipe index (Classic)
--- @param reagentIndex number Reagent index
function api:GetReagentInfo(recipeID, reagentIndex)
    if WoWClassic then
        return GetTradeSkillReagentInfo(recipeID, reagentIndex);
    else
        return C_TradeSkillUI.GetRecipeReagentInfo(recipeID, reagentIndex)
    end
end