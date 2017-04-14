local low = string.lower


local function log(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end -- alias for convenience
local GetSpellInfoVanilla = CreateFrame("Frame", nil, UIParent, "ActionButtonTemplate")

GetSpellInfoVanilla.OnEvent = function() -- functions created in "object:method"-style have an implicit first parameter of "this", which points to object || in 1.12 parsing arguments as ... doesn't work
	this[event](GetSpellInfoVanilla, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10) -- route event parameters to GetSpellInfoVanilla:event methods
end
GetSpellInfoVanilla:SetScript("OnEvent", GetSpellInfoVanilla.OnEvent)
GetSpellInfoVanilla:RegisterEvent("PLAYER_ENTERING_WORLD")

function GetSpellInfoVanilla_OnUpdate(elapsed)
end

function GetSpellInfoVanilla:PLAYER_ENTERING_WORLD()

end

-- Returns: name, rank, icon, castTime, minRange, maxRange, spellSchool
function GetSpellInfoById(id)
	if type(id) == "number" and SpellsDB[id] then
		local s = SpellsDB[id]
		return s.n, s.r, GlobalIconsDB[s.i or 1], GlobalCastingTime[s.c or 1], GlobalSpellRange[s.ra].mn, GlobalSpellRange[s.ra].mx, s.s, s.m or 0
	end
end

-- Returns: manaCost
function GetSpellPowerCost(id)
	if type(id) == "number" and SpellsDB[id] then
		return SpellsDB[id].m or 0
	end
end

function GetSpellIdByIcon(Icon)
	if type(Icon) ~= "string" then return end
	local shortIcon
	
	for x in split(Icon,"\\") do
		shortIcon = x
	end
	
	local resultArray = {}
	for id, v in pairs(SpellsDB) do
		if v.i == shortIcon or v.i == Icon then
			table.insert(resultArray, id)
		end
	end
	if table.getn(resultArray) = 1 then
		return resultArray[1]
	elseif table.getn(resultArray) > 1 then
		return resultArray
	end
end

function GetSpellIdByName(Name)
	if type(Name) ~= "string" then return end
	
	local rank = getRankFromName(Name)
	local shortName = string.sub(Name,rank or "","")
	
	Name = low(Name)
	rank = rank and low(rank) or nil
	shortName = low(shortName)
	
	local resultArray = {}
	for id, v in pairs(SpellsDB) do
		local name = low(v.n)
		local crank = low(v.r or "")
		if rank then
			if rank == crank and (name == shortName or name == Name) then
				table.insert(resultArray, id)
			end
		elseif (name == shortName or name == Name) then
			table.insert(resultArray, id)
		end
	end
	if table.getn(resultArray) = 1 then
		return resultArray[1]
	elseif table.getn(resultArray) > 1 then
		return resultArray
	end
end

local function getRankFromName(name)
	local _, rank
	for k, pt in rankPatterns do
		_, _, rank = string.find(name,pt)
		if rank then
			return rank
		end
	end
end

function GetSpellInfoByIconAndName(Icon, Name)
	local resultArray = {}
	for id,v in pairs(GetSpellInfoVanillaDB["spells"]) do
		local name, rank, icon, cost, isFunnel, powerType
		name = GetSpellInfoVanillaDB["spells"][id]["name"]
		rank = GetSpellInfoVanillaDB["spells"][id]["rank"]
		icon = GetSpellInfoVanillaDB["spells"][id]["icon"]
		cost = GetSpellInfoVanillaDB["spells"][id]["cost"]
		isFunnel = GetSpellInfoVanillaDB["spells"][id]["isFunnel"]
		powerType = GetSpellInfoVanillaDB["spells"][id]["powerType"]
		if icon == Icon and name == Name then
			if type(resultArray[id]) ~= "table" then resultArray[id] = {} end
			resultArray[id]["name"] = name
			resultArray[id]["rank"] = rank
			resultArray[id]["icon"] = icon
			resultArray[id]["cost"] = cost
			resultArray[id]["isFunnel"] = isFunnel
			resultArray[id]["powerType"] = powerType
		end
	end
	return resultArray
end

function GSIV_Test()
	local buffTexture, buffApplications = UnitBuff("target", 1);
	local tempTable = GetSpellInfoByIcon(buffTexture)
	for k,v in pairs(tempTable) do
		log(k.."  "..v["name"])
	end
end
