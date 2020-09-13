---A library to get information about the characters professions
-- luacheck: ignore profession
_G['LibProfessions'] = {}
local profession = _G['LibProfessions']
profession = LibStub:NewLibrary("LibProfessions-1.0", 1)
if not profession then
    return	-- already loaded and no upgrade necessary
end

WoWClassic = select(4, GetBuildInfo()) < 20000

--/dump LibStub("LibProfessions-1.0"):profession_id("Leatherworking")
--local addonName, professions = ...

local icons = {
    ["Blacksmithing"] = {136241, 'trade_blacksmithing'},
    ["Leatherworking"] = {133611, 'inv_misc_armorkit_17'},
    ["Skinning"] = {134366, 'inv_misc_pelt_wolf_01'}
}

local professions_bfa = {
    ["Alchemy"] = 2259,
    ["Blacksmithing"] = 3100,
    ["Enchanting"] = 7411,
    ["Engineering"] = 4036,
    ["Inscription"] = 45357,
    ["Jewelcrafting"] = 25229,
    ["Leatherworking"] = 2108,
    ["Tailoring"] = 3908,
    ["Skinning"] = 8617,
    ["Mining"] = 2575,
    ["Herbalism"] = 2366,
    ["Smelting"] = 2656,
    ["Cooking"] = 3102,
    ["Fishing"] = 7731,
}

local professions_classic = {
    ["Alchemy"] = {2259,3101,3464,11611},
    ["Blacksmithing"] = {2018,3100,3538,9785},
    ["Enchanting"] = {},
    ["Engineering"] = {},
    ["Leatherworking"] = {2108,3104,3811},
    ["Tailoring"] = {3908},
    ["Skinning"] = {8613,8617,8618,10768},
    ["Mining"] = {2575,2576,3564,10248},
    ["Herbalism"] = {},
    ["Smelting"] = {},
    ["Cooking"] = {2550,3102,3413,18260},
    ["Fishing"] = {7620,7731,7732,18248},
}

local rank_max = {[75] = "Apprentice",
                  [150] = "Journeyman",
                  [225] = "Expert",
                  [300] = "Artisan"}

function profession:icon(profession_name)
    return icons[profession_name][1]
end

function profession:profession_id(profession_name, rank)
    if rank == nil then
       rank = 1
    end
    local spellID
    if WoWClassic then
        spellID =  professions_classic[profession_name][rank]
    else
        spellID = professions_bfa[profession_name][rank]
    end
    local spellExists = C_Spell.DoesSpellExist(spellID)

    if spellExists then
        return spellID
    else
        return
    end
end

function profession:profession_name()
    --GetSpellInfo
end

--/dump profession_id("Leatherworking")


--/dump LibStub("LibProfessions-1.0"):GetAllSkills()
function profession:GetAllSkills(header_filter)
    local skills = {}
    local header_name = ''
    local i = 1
    -- BfA has no skills, only professions
    if not WoWClassic then
        return
    else
        local numSkills = GetNumSkillLines();
        for skillIndex=1,  numSkills, 1 do
            local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank,
                  isAbandonable, stepCost, rankCost, minLevel, skillCostType = GetSkillLineInfo(skillIndex);
            --print(skillName, header, skillRank)
            if ( header ) then
                header_name = skillName
            else
                local skill_info = {skillName, header, isExpanded, skillRank, numTempPoints, skillModifier,
                                    skillMaxRank, isAbandonable, stepCost, rankCost, minLevel, skillCostType,
                                    rank_max[skillMaxRank], header_name}

                if header_filter ~= nil and header_filter == header_name then
                    --skills[i] = {skillName, skillRank, skillMaxRank, rank_max[skillMaxRank], header, skillModifier}
                    skills[i] = skill_info
                    i = i + 1
                elseif header_filter == nil then
                    skills[skillName] = skill_info
                end
            end
        end
    end
    return skills
end


--/dump LibStub("LibProfessions-1.0"):GetSkill("Leatherworking")
--/dump LibStub("LibProfessions-1.0"):GetSkill("Cooking")
function profession:GetSkill(profession_name)
    local skills = self:GetProfessions()
    return skills[profession_name]
end


--/dump LibStub("LibProfessions-1.0"):GetProfessions()
function profession:GetProfessions(header)
    local skills = {}
    local id = nil
    if WoWClassic then
        local profession_skills =  self:GetAllSkills(header)
        local name
        for _, skill_info in ipairs(profession_skills) do
            name = skill_info[1]
            if header=="Professions" or header=="Secondary Skills" then
                id = self:profession_id(name, skill_info[4])
            else
                id = "undefinded"
            end
            skills[name] = {id = id, name = name, skill = skill_info[4], max_skill = skill_info[7], modifier = skill_info[5]}
        end
    else
        local prof1, prof2, arch, fish, cook = GetProfessions();
        for _, index in ipairs({prof1, prof2, arch, fish, cook}) do
            local name, texture, rank, maxRank, numSpells, spelloffset, skillLine, rankModifier, specializationIndex,
            specializationOffset, skillLineName = GetProfessionInfo(index);
            skills[name] = {name = name, skill = rank, max_skill = maxRank,
                            modifier = rankModifier, specialization = skillLineName}
        end
    end
    return skills
end

function profession:GetProfessionInfo(index)
    local profs = self:GetProfessions()
    local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, isAbandonable,
    stepCost, rankCost, minLevel, skillCostType, rank_name, header_name = profs[index]
    local icon = self:icon(skillName)
    local numAbilities = 0 --TODO: Set this to correct value
    print('Rank line 139:', skillRank)
    return skillName, icon, skillRank, skillMaxRank, numAbilities, nil, nil, skillModifier, nil, nil, rank_name
end