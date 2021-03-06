--[[--------------------------------------------------------------------
	CleanCompare
	Removes irrelevant stats from item comparison tooltips.
	Copyright (c) 2014-2017 Phanx <addons@phanx.net>. All rights reserved.
	https://github.com/phanx-wow/CleanCompare
----------------------------------------------------------------------]]

local ADDON, Addon = ...
CleanCompareDB = {}
_G[ADDON] = Addon -- #DEBUG

------------------------------------------------------------------------

local statToKey = {
	-- Properties
	[RESISTANCE0_NAME] = "ARMOR",
	[ITEM_MOD_DAMAGE_PER_SECOND_SHORT] = "DAMAGE_PER_SECOND",
	-- Stats
	[ITEM_MOD_AGILITY_SHORT] = "AGILITY",
	[ITEM_MOD_ATTACK_POWER_SHORT] = "ATTACK_POWER",-- only on gear up to level 80
	[ITEM_MOD_CR_AVOIDANCE_SHORT] = "AVOIDANCE", -- only on Mark of Supreme Doom
	[ITEM_MOD_CRIT_RATING_SHORT] = "CRIT",
	[ITEM_MOD_HASTE_RATING_SHORT] = "HASTE",
	[ITEM_MOD_HEALTH_REGEN_SHORT] = "HEALTH_REGENERATION",
	[ITEM_MOD_HEALTH_REGENERATION_SHORT] = "HEALTH_REGENERATION",
	[ITEM_MOD_DODGE_RATING_SHORT] = "DODGE",
	[ITEM_MOD_INTELLECT_SHORT] = "INTELLECT",
	[ITEM_MOD_CR_LIFESTEAL_SHORT] = "LEECH", -- only on Mark of Supreme Doom
	[ITEM_MOD_MASTERY_RATING_SHORT] = "MASTERY",
	[ITEM_MOD_PARRY_RATING_SHORT] = "PARRY", -- only on gear up to level 85
	[ITEM_MOD_PVP_POWER_SHORT] = "PVP_POWER", -- only on gear up to level 90
	[ITEM_MOD_PVP_PRIMARY_STAT_SHORT] = "PVP_POWER", -- only on gear up to level 90
	[ITEM_MOD_RESILIENCE_RATING_SHORT] = "PVP_RESILIENCE", -- only on gear up to level 90
	[ITEM_MOD_CR_SPEED_SHORT] = "SPEED", -- only on Mark of Supreme Doom
	[ITEM_MOD_STAMINA_SHORT] = "STAMINA",
	[ITEM_MOD_STRENGTH_SHORT] = "STRENGTH",
	[ITEM_MOD_VERSATILITY] = "VERSATILITY",
	-- Sockets
	[EMPTY_SOCKET_RED] = "SOCKET",
	[EMPTY_SOCKET_YELLOW] = "SOCKET",
	[EMPTY_SOCKET_BLUE] = "SOCKET",
	[EMPTY_SOCKET_META] = "SOCKET",
	[EMPTY_SOCKET_PRISMATIC] = "SOCKET",
	[EMPTY_SOCKET_NO_COLOR] = "SOCKET", -- Prismatic
	[EMPTY_SOCKET_COGWHEEL] = "SOCKET",
	[EMPTY_SOCKET_HYDRAULIC] = "SOCKET", -- Sha-Touched
	-- Resistances
	[RESISTANCE1_NAME] = "RESISTANCE",
	[RESISTANCE2_NAME] = "RESISTANCE",
	[RESISTANCE3_NAME] = "RESISTANCE",
	[RESISTANCE4_NAME] = "RESISTANCE",
	[RESISTANCE5_NAME] = "RESISTANCE",
	[RESISTANCE6_NAME] = "RESISTANCE",
	[strtrim(gsub(ITEM_RESIST_ALL, "%%[cd]", ""))] = "RESISTANCE",
}
Addon.statToKey = statToKey

------------------------------------------------------------------------

local defaultStats = {
	[0] = { -- Everyone
		CRIT = true,
		HASTE = true,
		HEALTH_REGENERATION = true,
		LEECH = true,
		MASTERY = true,
		PVP_POWER = true,
		PVP_RESILIENCE = true,
		SOCKET = true,
		SPEED = true,
		STAMINA = true,
		VERSATILITY = true,
	},
	DEATHKNIGHT = {
		[0] = {
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			STRENGTH = true,
		},
		[1] = { -- Blood
			ARMOR = true,
			AVOIDANCE = true,
			DODGE = true,
			PARRY = true,
		},
		[2] = {}, -- Frost
		[3] = {}, -- Unholy
	},
	DRUID = {
		[1] = { -- Balance
			INTELLECT = true,
		},
		[2] = { -- Feral
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			STRENGTH = true,
		},
		[3] = { -- Guardian
			AGILITY = true,
			ARMOR = true,
			AVOIDANCE = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			DODGE = true,
			STRENGTH = true,
		},
		[4] = { -- Restoration
			INTELLECT = true,
			MANA_REGENERATION = true,
		},
	},
	HUNTER = {
		[0] = {
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
		},
		[1] = {}, [2] = {}, [3] = {}, -- Beast Mastery, Marksmanship, Survival
	},
	MAGE = {
		[0] = {
			INTELLECT = true,
		},
		[1] = {}, [2] = {}, [3] = {}, -- Arcane, Fire, Frost
	},
	MONK = {
		[1] = { -- Brewmaster
			AGILITY = true,
			ARMOR = true,
			ATTACK_POWER = true,
			AVOIDANCE = true,
			DAMAGE_PER_SECOND = true,
			DODGE = true,
			PARRY = true,
		},
		[2] = { -- Mistweaver
			INTELLECT = true,
		},
		[3] = { -- Windwalker
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
		},
	},
	PALADIN = {
		[1] = { -- Holy
			INTELLECT = true,
		},
		[2] = { -- Protection
			ARMOR = true,
			AGILITY = true,
			ATTACK_POWER = true,
			AVOIDANCE = true,
			DAMAGE_PER_SECOND = true,
			PARRY = true,
			STRENGTH = true,
		},
		[3] = { -- Retribution
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			DODGE = true,
			STRENGTH = true,
		},
	},
	PRIEST = {
		[0] = {
			INTELLECT = true,
		},
		[1] = {}, -- Discipline
		[2] = {}, -- Holy
		[3] = { -- Shadow
		},
	},
	ROGUE = {
		[0] = {
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
		},
		[1] = {}, [2] = {}, [3] = {}, -- Assassination, Combat, Subtlety
	},
	SHAMAN = {
		[1] = { -- Elemental
			INTELLECT = true,
		},
		[2] = { -- Enhancement
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
		},
		[3] = { -- Restoration
			INTELLECT = true,
		},
	},
	WARLOCK = {
		[0] = {
			INTELLECT = true,
		},
		[1] = {}, [2] = {}, [3] = {}, -- Affliction, Demonology, Destruction
	},
	WARRIOR = {
		[0] = {
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			STRENGTH = true,
		},
		[1] = {}, -- Arms
		[2] = {}, -- Fury
		[3] = { -- Protection
			ARMOR = true,
			AVOIDANCE = true,
			DODGE = true,
			PARRY = true,
		},
	},
}

------------------------------------------------------------------------

local classDefaults, classDB

local enabledStats = {}
Addon.enabledStats = enabledStats

local enabledStatsBySpec = {}
Addon.enabledStatsBySpec = enabledStatsBySpec

local function UpdateStatsList()
	wipe(enabledStats)
	for spec = 1, GetNumSpecializations() do
		local t = enabledStatsBySpec[spec] or {}
		enabledStatsBySpec[spec] = wipe(t)
		for stat, enable in pairs(classDB[0]) do
			t[stat] = enable
		end
		if classDB[spec] then
			for stat, enable in pairs(classDB[spec]) do
				t[stat] = enable
			end
		end
	end
	local spec = GetSpecialization()
	if spec and enabledStatsBySpec[spec] then
		for stat, enable in pairs(enabledStatsBySpec[spec]) do
			enabledStats[stat] = enable
		end
	else
		for stat, enable in pairs(classDB[0]) do
			enabledStats[stat] = enable
		end
	end
end
Addon.UpdateStatsList = UpdateStatsList

------------------------------------------------------------------------

local f = CreateFrame("Frame", ADDON)
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		local _, class = UnitClass("player")

		classDefaults = defaultStats[class]
		if not classDefaults[0] then
			classDefaults[0] = defaultStats[0]
		else
			for stat in pairs(defaultStats[0]) do
				classDefaults[0][stat] = true
			end
		end
		Addon.classDefaults = classDefaults -- /run wipe(CleanCompareDB) ReloadUI()
		defaultStats = nil

		classDB = CleanCompareDB[class] or {} -- /dump CleanCompareDB
		for spec, stats in pairs(classDefaults) do
			classDB[spec] = classDB[spec] or {}
			for stat in pairs(stats) do
				if classDB[spec][stat] == nil then
					classDB[spec][stat] = true
				end
			end
		end
		CleanCompareDB[class] = classDB
		Addon.classDB = classDB

		--self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	end
	UpdateStatsList()
end)

------------------------------------------------------------------------

local COMPARE_FORMAT = "^|cff%x+[%+%-][%d%.]+|r%s?(.+)" -- TODO: localize?

local left = setmetatable({}, { __index = function(left, tooltip)
	local name = tooltip:GetName()
	local lines = setmetatable({}, { __index = function(lines, i)
		local line = _G[name.."TextLeft"..i]
		lines[i] = line
		return line
	end })
	left[tooltip] = lines
	return lines
end })

local function FixHeight(tooltip)
	if tooltip.minusHeight then
		tooltip:SetHeight(tooltip:GetHeight() - tooltip.minusHeight)
	end
end

local junk = {
	[""] = true,
	[" "] = true,
	[ITEM_COMPARISON_CYCLING_DISABLED_MSG_MAINHAND] = true,
	[ITEM_COMPARISON_CYCLING_DISABLED_MSG_OFFHAND] = true,
}

local function HideIrrelevantStats(tooltip)
	--print(ADDON, "HideIrrelevantStats", tooltip:GetName())
	local checked, removed, title = 0, 0
	local lines = left[tooltip]
	for i = 1, tooltip:NumLines() do
		local line = lines[i]
		local text = line:GetText()
		if text == ITEM_DELTA_DESCRIPTION then
			--print("Found stats comparison")
			title = i
		elseif title then
			local stat = strmatch(text, COMPARE_FORMAT)
			if stat then
				stat = strtrim(gsub(stat, "|T.-|t%s*", ""))
				--print("checking stat", stat)
				if not statToKey[stat] then
					print(format("unknown stat %q", stat))
				end
				stat = statToKey[stat]
				checked = checked + 1
			end
			if (stat and not enabledStats[stat]) or junk[text] then
				--print("ignored stat")
				line:SetText(nil)
				removed = removed + 1
			elseif removed > 0 then
				lines[i-removed]:SetText(text)
				line:SetText(nil)
			end
		end
	end
	if removed > 0 then
		--print("removed", removed, "lines")
		if checked == removed then
			--print("ignored all stats, removing title too")
			lines[title]:SetText(nil)
			removed = removed + 1

			local x = lines[title-1]:GetText()
			if not strfind(x, "%a") then
				lines[title-1]:SetText(nil)
				removed = removed + 1
			end
		end
		tooltip.minusHeight = removed * 2 -- 2
	else
		tooltip.minusHeight = nil
	end
	tooltip:Show()
end

------------------------------------------------------------------------

local function AddHooks(tooltip)
	if not tooltip then return end

	hooksecurefunc(tooltip, "Show", FixHeight)

	if tooltip.SetCompareItem then -- WOD
		hooksecurefunc(tooltip, "SetCompareItem", HideIrrelevantStats)
	else -- MOP
		hooksecurefunc(tooltip, "SetHyperlinkCompareItem", HideIrrelevantStats)
	end
end

AddHooks(ShoppingTooltip1)
AddHooks(ShoppingTooltip2)
AddHooks(ShoppingTooltip3)
AddHooks(ItemRefShoppingTooltip1)
AddHooks(ItemRefShoppingTooltip2)
AddHooks(ItemRefShoppingTooltip3)
