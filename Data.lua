local Sa = SafeArmory
local L = Sa.L
Sa.fnc = {}
Sa.dataCount = 0



if not Sa then return end 

----------------------------------------------------------------------------
---- Constants
--

Sa.classID = {
    ["NONE"] = 0,
    ["WARRIOR"] = 1,
    ["PALADIN"] = 2,
    ["HUNTER"] = 3,
    ["ROGUE"] = 4,
    ["PRIEST"] = 5,
    ["DEATHKNIGHT"] = 6,
    ["SHAMAN"] = 7,
    ["MAGE"] = 8,
    ["WARLOCK"] = 9,
    ["MONK"] = 10,
    ["DRUID"] = 11,
    ["DEMONHUNTER"] = 12,
}

Sa.raceID = {
	["None"] = 0,
	["Human"] = 1,
	["Orc"] = 2,
	["Dwarf"] = 3,
	["NightElf"] = 4,
	["Undead"] = 5,
	["Tauren"] = 6,
	["Gnome"] = 7,
	["Troll"] = 8,
	["Goblin"] = 9,
	["BloodElf"] = 10,
	["Draenei"] = 11,
	["Worgen"] = 2,
	["Pandaren"] = 23,
	["Nightborne"] = 27,
	["HighmountainTauren"] = 28,
	["VoidElf"] = 29,
	["LightforgedDraenei"] = 30,
	["ZandalariTroll"] = 31,
	["KulTiran"] = 32,
	["DarkIronDwarf"] = 34,
	["Vulpera"] = 35,
	["MagharOrc"] = 36,
	["Mechagnome"] = 37
}

Sa.equipCategories = {
	[1] = "AMMOSLOT",
	[2] = "HEADSLOT",
	[3] = "NECKSLOT",
	[4] = "SHOULDERSLOT",
	[5] = "SHIRTSLOT",
	[6] = "CHESTSLOT",
	[7] = "WAISTSLOT",
	[8] = "LEGSSLOT",
	[9] = "FEETSLOT",
	[10] = "WRISTSLOT",
	[11] = "HANDSSLOT",
	[12] = "FINGER0SLOT",
	[13] = "FINGER1SLOT",
	[14] = "TRINKET0SLOT",
	[15] = "TRINKET1SLOT",
	[16] = "BACKSLOT",
	[17] = "MAINHANDSLOT",
	[18] = "SECONDARYHANDSLOT",
	[19] = "RANGEDSLOT",
	[20] = "TABARDSLOT",
}

Sa.standings = { "Unknown", "Hated", "Hostile", "Unfriendly", "Neutral", "Friendly", "Honored", "Revered", "Exalted" }

----------------------------------------------------------------------------
---- Utils
--

function Sa:dump(t)

	if type(t) == 'table' then
	   local s = '{ '
	   for k,v in pairs(t) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. Sa:dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(t)
	end

end

local function tableCount(t)

	if type(t) == 'table' then
	   for k,v in pairs(t) do
		  Sa.dataCount = Sa.dataCount + 1
		  tableCount(v)
	   end	   
	else
	   return tostring(t)
	end

	return tostring(Sa.dataCount)

end

function isEmpty(s)

  return s == nil or s == '' or not s

end

function Sa.fnc:x(b)
	return GetContainerNumSlots(b)
end

function Sa.fnc:y(b,s)
	return Item:CreateFromBagAndSlot(b,s)
end

function Sa.fnc:_z(v)
	if v then
		return v:IsItemEmpty()
	else
		return nil
	end
end

function Sa.fnc:idg(v)
	if v then
		return v:GetItemID()
	else
		return nil
	end	
end

function Sa.fnc:s_bn()
	return NUM_BAG_SLOTS
end

function Sa.fnc:s_bbn()
	return NUM_BANKBAGSLOTS
end

----------------------------------------------------------------------------
---- ParseItemTooltip
--

local tooltip
local function GetTooltip()

	if not tooltip then
		tooltip = CreateFrame("GameTooltip", "SaScanningTooltip", nil, "GameTooltipTemplate")
		tooltip:SetOwner(UIParent, "ANCHOR_NONE")
	end

	return tooltip

end

local function GetItemTooltip(bagId, slotId, link)

	local tooltip = GetTooltip()

	tooltip:ClearLines()
	if bagId then
		tooltip:SetBagItem(bagId, slotId)
	elseif slotId then
		tooltip:SetInventoryItem("player", slotId)
	else
		tooltip:SetHyperlink(link)
	end

	return tooltip

end

local function GetItemLevel(bagId, slotId, link)	

	local itemLevelPattern = _G["ITEM_LEVEL"]:gsub("%%d", "(%%d+)")
	local tooltipItem = GetItemTooltip(bagId, slotId, link)
	local data = {}
	local regions = { tooltipItem:GetRegions() }
	for i, region in ipairs(regions) do
		if region and region:GetObjectType() == "FontString" then
			local text = region:GetText()
			if text then
				data[#data+1] = text
				ilvl = tonumber(text:match(itemLevelPattern))
				--if ilvl then
				--	return ilvl
				--end
			end
        end	
	end
	
	return data

end


----------------------------------------------------------------------------
---- Character Data
--

function Sa:GetPlayerData()

	local data = {}
	
	local playerClass, classEn = UnitClass("player");
	local race, raceEn = UnitRace("player");
	local englishFaction, localizedFaction = UnitFactionGroup("player");
	local money = {
		copper = 0,
		silver = 0,
		gold = 0
	}
	local copper = GetMoney()
	local honorableKills, dishonorableKills, highestRank = GetPVPLifetimeStats()
	
	data.name = UnitName("player")
	data.realm = GetRealmName()
	data.level = UnitLevel("player")
	data.gender = UnitSex("player")-1
	data.faction = englishFaction
	data.money = copper
	data.pvprank = UnitPVPRank("player")
	data.highestRank = highestRank
	data.classID = Sa.classID[classEn]
	data.raceID = Sa.raceID[raceEn]
	data.locale = GetLocale()
	data.guid = UnitGUID("player")

	data.stats = {}
	data.stats.strength = UnitStat("player" , 1)
	data.stats.agility = UnitStat("player" , 2)
	data.stats.stamina = UnitStat("player" , 3)
	data.stats.intellect = UnitStat("player" , 4)
	data.stats.spirit = UnitStat("player" , 5)
	data.stats.health = UnitHealthMax("player")
	data.stats.mana =  UnitPowerMax("player", 0)

    return data

end

----------------------------------------------------------------------------
---- Items
--


local function GetItemInfoData(itemLink)

	local item = {}	
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType,
    itemStackCount, itemEquipLoc, itemTexture, itemSellPrice = GetItemInfo(itemLink) 
	local stats = {}

	local str = string.match(itemLink, "|Hitem:([\-%d:]+)|")  

    if not str then return nil end

    local parts = { strsplit(":", str) }

    item.id = parts[1]
    item.name = itemName
    item.isItemEquippable = IsEquippableItem(itemLink)
    item.type = itemType
    item.subtype = itemSubType
    item.rarity = itemRarity
    if item.isItemEquippable then
    	item.gems = {parts[3], parts[4], parts[5], parts[6]}
		item.color = Color
		item.lvl = itemLevel
		item.itemMinLevel = itemMinLevel
		item.enchat = parts[2]
		item.stats = GetItemStats(itemLink, stats)
		item.bonus = parts[14]
	end
    
	
    return item

end

local function GetBagItems()

	local bag = 0
	local slots = GetContainerNumSlots(bag)
	local slot = 1

	return function()
		while bag < 5 do
			local item = Item:CreateFromBagAndSlot(bag, slot)
			local _, _, _, _, _, _, itemLink = GetContainerItemInfo(bag, slot)
			local tooltip = GetItemLevel(bag,slot,itemLink)
			slot = slot + 1
			if slot > slots then
				bag = bag + 1
				slot = 1
				slots = GetContainerNumSlots(bag)
			end
			if not item:IsItemEmpty() then
				item.tooltip = tooltip
				return item
			end
		end
	end

end

local function GetBankItems()

	local bag = -1
	local slots = GetContainerNumSlots(bag)
	local slot = 1

	return function()
		while bag <= (NUM_BAG_SLOTS + NUM_BANKBAGSLOTS) do
			local item = Item:CreateFromBagAndSlot(bag, slot)
			local _, itemCount, _, _, _, _, itemLink = GetContainerItemInfo(bag, slot)
			local tooltip = GetItemLevel(bag,slot,itemLink)
			slot = slot + 1
			if slot > slots then
				if bag == -1 then
					bag = NUM_BAG_SLOTS + 1
				else
					bag = bag + 1
				end
				slot = 1
				slots = GetContainerNumSlots(bag)
			end
			if not item:IsItemEmpty() then		
				item.count = itemCount
				item.tooltip = tooltip
				return item
			end
		end
	end

end



----------------------------------------------------------------------------
---- Bag items
--

function Sa:GetBagItemsData()

	local items = {}
	local collectedItems = {}

	for item in GetBagItems() do
		local id = item:GetItemID()	
		if not collectedItems[id] then
			collectedItems[id] = true	
			local _, itemLink = GetItemInfo(id) 	
			local itemInfo = GetItemInfoData(itemLink)
			itemInfo.count = GetItemCount(id, false, false)  	
			itemInfo.tooltip = item.tooltip
			items[#items+1] = itemInfo
		end
	end
	return items

end

----------------------------------------------------------------------------
---- Bank items
--


function Sa:GetBankItemsData()

	local items = {}
	local collectedItems = {}

	for item in GetBankItems() do
		local id = item:GetItemID()	
		if not collectedItems[id] then	
			collectedItems[id] = {
				count = 1,
				itemsID = #items + 1
			}
			local _, itemLink = GetItemInfo(id) 		
			local itemInfo = GetItemInfoData(itemLink)
			itemInfo.count = item.count
			itemInfo.tooltip = item.tooltip
			items[#items+1] = itemInfo
		else
			collectedItems[id].count = collectedItems[id].count + 1
			if items[collectedItems[id].itemsID].count then
				items[collectedItems[id].itemsID].count = item.count + items[collectedItems[id].itemsID].count
			end
		end


	end

	return items

end

----------------------------------------------------------------------------
---- Talents
--

function Sa:GetTalentsData()

	local specializations = {}
	local numTabs = GetNumTalentTabs();

	for t=1, numTabs do
		
		specializations[t] = {
			name = {},
			talents = {},
			talentsMap = {{0,0,0,0}, {0,0,0,0}, {0,0,0,0}, {0,0,0,0}, {0,0,0,0}, {0,0,0,0}, {0,0,0,0}}
		}

		local specName = GetTalentTabInfo(t)
	    specializations[t].name = specName
	    local numTalents = GetNumTalents(t)
	    for i=1, numTalents do
	        nameTalent, _, tier, column, currRank, maxRank= GetTalentInfo(t,i)
	        specializations[t].talentsMap[tier][column] = currRank .. '/' .. maxRank
	        specializations[t].talents[i] = {}
	        specializations[t].talents[i].name = nameTalent
	        specializations[t].talents[i].rank = currRank
	        specializations[t].talents[i].maxrank = maxRank
	        specializations[t].talents[i].place = tier .. ',' .. column       
	    end

	end

	return specializations

end

----------------------------------------------------------------------------
---- Reputation
--


function Sa.GetReputationsData()

	local reputations = {
		faction = {}		
	}
	local j = 1

	for factionIndex = 1, GetNumFactions() do
	  	name, description, standingId, bottomValue, topValue, earnedValue, atWarWith,
	    canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild = GetFactionInfo(factionIndex)
		if reputations.faction[j] == nil then
			reputations.faction[j] = {
				subfaction = {}
			}
		end
		if isHeader then
			reputations.faction[j].name = name
			reputations.faction[j].standingId = Sa.standings[standingId+1]		
			reputations.faction[j].currentValue = earnedValue - bottomValue
			reputations.faction[j].currentTopValue = topValue - bottomValue
			j = j + 1
			i = 1
		else
			reputations.faction[j-1].subfaction[i] = {}
			reputations.faction[j-1].subfaction[i].name = name
			reputations.faction[j-1].subfaction[i].standingId = Sa.standings[standingId+1]
			reputations.faction[j-1].subfaction[i].currentValue = earnedValue - bottomValue
			reputations.faction[j-1].subfaction[i].currentTopValue = topValue - bottomValue
			i = i + 1
		end
	end
	table.remove(reputations.faction)

	return reputations

end

----------------------------------------------------------------------------
---- Professions
--

function Sa:GetProfessionsData()

	local primary = ""
	local secondary = ""
	local weapon = ""
	local section = 0
	for i = 1, GetNumSkillLines() do
		local skillName, isHeader, _, skillRank, _, _, skillMaxRank = GetSkillLineInfo(i)
		if isHeader then
			section = section + 1
			if section == 2 then
				primary = skillName
			elseif section == 3 then
				secondary = skillName
			elseif section == 4 then
				weapon = skillName
			end
		end
	end

	local professions = {
		primary = Sa.LibProfessions:GetProfessions(primary),
		secondary = Sa.LibProfessions:GetProfessions(secondary),
		weapon_skills = Sa.LibProfessions:GetProfessions(weapon)
	}

	return professions

end

----------------------------------------------------------------------------
---- Equip
--

function Sa:GetEquippedItemsData()

	local items = {}

	for i = 1, #Sa.equipCategories, 1 do
		slotID = GetInventorySlotInfo(Sa.equipCategories[i])
		if ( GetInventoryItemLink("player", slotID) ) then
			local itemLink = GetInventoryItemLink("player", slotID)
			local itemData = GetItemInfoData(itemLink)
			itemData.tooltip = GetItemLevel(false,slotID,itemLink)
			items[Sa.equipCategories[i]] = itemData
		else
			items[Sa.equipCategories[i]] = {}
		end	    
	end
    
	return items

end

----------------------------------------------------------------------------
---- Export data
--

function Sa:GetBagBankCounts()

	local counts = {
		bag = #Sa:GetBagItemsData(), 
		bank = #Sa:GetBankItemsData(), 
	}
	return counts

end

function Sa:GetAllData()

	local data = {}
	
	data['equipment'] = Sa:GetEquippedItemsData()
	data['bag'] = Sa:GetBagItemsData()
	data['bank'] = Sa:GetBankItemsData()	
	data['professions'] = Sa:GetProfessionsData()
	data['reputations'] = Sa:GetReputationsData()
	data['talents'] = Sa:GetTalentsData()
	data['info'] = Sa:GetPlayerData()
	data['counts'] = Sa:GetBagBankCounts()
	data['security'] = Sa:Security()


	return data

end

function Sa:CountData(data)

	return tableCount(data)

end

