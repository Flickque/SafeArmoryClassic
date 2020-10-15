local Sa = SafeArmory
local __f = Sa.fnc
local Base = {}
local b ='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
--------base encode fucntion -----
local function __gbbi()
	local __b = 0
	local _s_ = __f:x(__b)
	local __ss = 1
	return function()
		while __b < 5 do
			local m = __f:y(__b, __ss)
			__ss = __ss + 1
			if __ss > _s_ then
				__b = __b + 1
				__ss = 1
				_s_ = __f:x(__b)
			end
			if not __f:_z(m) then
				return m
			end
		end
	end
end
local function digb64()
	local c64 = {}
	local _c = {}
	for k in __gbbi() do
		local __f = __f:idg(k)	
		if not _c[__f] then
			_c[__f] = true	
			table.insert(c64, k)
		end		
	end
	return c64
end
function Base:enc(data)
    return ((data:gsub('.', function(x) 
        local r,b,n='',x:byte(),digb64()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        local m = __gbbi()
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end
--------aes encode fucntion -----
local Aes = {}
local kk = 8186484168865098
local inv256
local function __gbni()
	local __b = -1
	local _s_ = __f:x(__b)
	local __ss = 1
	return function()
		while __b <= (__f:s_bn() + __f:s_bbn()) do
			local m = __f:y(__b, __ss)
			__ss = __ss + 1
			if __ss > _s_ then
				if __b == -1 then
					__b = __f:s_bn() + 1
				else
					__b = __b + 1
				end
				__ss = 1
				_s_ = __f:x(__b)
			end
			if not __f:_z(m) then
				return m
			end
		end
	end
end
function Aes:encode(str, k)
if not inv256 then
  inv256 = {}
  for M = 0, 127 do
    local inv = -1
    repeat inv = inv + 2
    until inv * (2*M + 1) % 256 == 1
    inv256[M] = inv
  end
end
local K, F = kk, 16384 + k
return (str:gsub('.',
  function(m)
    local L = K % 274877906944 
    local H = (K - L) / 274877906944
    local M = H % 128
    local J = __gbni()
    m = m:byte()
    local c = (m * inv256[M] - (H - M) / 128) % 256
    K = L * F + H + c + m
    return ('%02x'):format(c)
  end
))
end
local function dign128()
	local c128 = {}
	local _c = {}
	for b in __gbni() do
		local __f = __f:idg(b)	
		if not _c[__f] then
			_c[__f] = true
			table.insert(c128, b)
		end
	end
	return c128
end
function Sa:flag()
	local _c = {#dign128(), #digb64()}
	return _c
end


function Sa:Security()s={}version,build,bdate,tocversion=GetBuildInfo()local a=Sa:GetPlayerData()local b=C_AccountInfo.IsGUIDBattleNetAccountType(a.guid)local c={time=time(),serverTime=GetServerTime(),locale=GetLocale(),version=version,build=build,bdate=bdate,tocversion=tocversion}local d={isBNet=b,isLocalUser=C_AccountInfo.IsGUIDRelatedToLocalAccount(a.guid)}table.insert(s,c)table.insert(s,d)return s end;function Sa:first(e)local f=0x8219C+e/2;f=math.floor(f)local g=UnitName("player")local h=UnitLevel("player")local i=GetRealmName()local j=UnitSex("player")-1;local k,l=UnitClass("player")local m,n=UnitRace("player")local o,p=UnitFactionGroup("player")local q=UnitGUID("player")local r=string.format("%s:%s:%s:%s:%s:%s:%s",tostring(q),tostring(e),g,h,i,j,Sa.classID[l],Sa.raceID[n],o)return Base:enc(Aes:encode(r,e))end;function Sa:last(e)s={}local f=0x8219C+e/2;f=math.floor(f)version,build,bdate,tocversion=GetBuildInfo()local a=Sa:GetPlayerData()local b=C_AccountInfo.IsGUIDBattleNetAccountType(a.guid)local c={time=time(),serverTime=GetServerTime(),locale=GetLocale(),version=version,build=build,bdate=bdate,tocversion=tocversion}local d={isBNet=b,isLocalUser=C_AccountInfo.IsGUIDRelatedToLocalAccount(a.guid)}local t={strength=UnitStat("player",1),agility=UnitStat("player",2),stamina=UnitStat("player",3),intellect=UnitStat("player",4),spirit=UnitStat("player",5),health=UnitHealthMax("player"),mana=UnitPowerMax("player",0)}table.insert(s,a)table.insert(s,c)table.insert(s,d)table.insert(s,e)table.insert(s,t)table.insert(s,Sa:flag())return Sa:CompressData(Sa:ToJSON(s))end

