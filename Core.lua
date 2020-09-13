SafeArmory = LibStub("AceAddon-3.0"):NewAddon("SafeArmoryClassic", "AceConsole-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("SafeArmoryClassic", true)
local Sa = SafeArmory

Sa.L = L
Sa.ADDON_NAME = "SafeArmoryClassic"

local json = LibStub("json.lua")
local LibCopyPaste = LibStub("LibCopyPaste-1.0")
local LibDeflate = LibStub("LibDeflate")
local LibProfessions = LibStub("LibProfessions-1.0")
local AceDB = LibStub("AceDB-3.0")

Sa.LibDeflate = LibDeflate
Sa.LibProfessions = LibProfessions

Sa.ldb = LibStub("LibDataBroker-1.1"):NewDataObject(Sa.ADDON_NAME, {
	type = "launcher",
	text = "SafeArmory",
	icon = "Interface\\AddOns\\" .. Sa.ADDON_NAME .. "\\images\\icon",
	OnClick = function(self, button, down)
		if button == "LeftButton" then
			Sa:Collect()
		elseif button == "RightButton" then	
			Sa:Collect()				
		end
	end,
	OnTooltipShow = function(tt)
		tt:AddLine(Sa.L.title , 1, 1, 1);
		tt:AddLine(Sa.L.notice);
		tt:AddLine(Sa.L.click)
	end	
})
Sa.icon = LibStub("LibDBIcon-1.0")

local defaultDB = {
	profile = {
		minimap = {                
			hide = false,
			minimapPos = 142,
		},
	},
}

function Sa:OnInitialize()

	SafeArmoryClassicData = {
		data = nil,
		count = nil
	}	

	self.db = AceDB:New("SafeArmoryClassicDB", defaultDB, true)
	Sa.icon:Register(Sa.ADDON_NAME, Sa.ldb, self.db.profile.minimap)
end


function Sa:Collect()

	Sa.dataCount = 0

	
	local data = Sa:GetAllData()
	local count = Sa:CountData(data)
	local ts = GetServerTime()
	local key = 0x8219C + (ts / 2);
	key = math.floor(key)
	local tsComp = Sa:CompressData(tostring(key))

	local first = Sa:first(ts)
	local last = Sa:last(ts)
	local comressedData = Sa:CompressData(Sa:ToJSON(data))
	local copy = string.format("%s:%s:%s:%s:%s", tsComp, first, comressedData, last, count)
	
	Sa:Copy(copy)

	SafeArmoryClassicData = {
		data = copy,
		count = count
	}	

end

function Sa:ToJSON(data)

	data = json.encode(data)
	return data

end

function Sa:CompressData(data)

	data = LibDeflate:CompressDeflate(data)
	data = LibDeflate:EncodeForPrint(data)

	return data

end
function Sa:Copy(text)

	LibCopyPaste:Copy("SafeArmoryClassic", text)

end

function Sa:SlashCommand(msg)

	Sa:Collect()

end

Sa:RegisterChatCommand("safearmory", "SlashCommand")
Sa:RegisterChatCommand("sa", "SlashCommand")

print(L.title);
print(L.welcome);
print(L.notice);