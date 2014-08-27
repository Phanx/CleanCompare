--[[--------------------------------------------------------------------
	CleanCompare
	Removes irrelevant stats from item comparison tooltips.
	Copyright (c) 2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
	http://www.wowinterface.com/downloads/info-CleanCompare.html
	http://www.curse.com/addons/wow/cleancompare
----------------------------------------------------------------------]]

local ADDON, Addon = ...
CleanCompareDB = {}
_G[ADDON] = Addon -- #DEBUG

------------------------------------------------------------------------

local statToKey = {
	[ITEM_MOD_AGILITY_SHORT] = "AGILITY",
	[ITEM_MOD_ATTACK_POWER_SHORT] = "ATTACK_POWER",
	[ITEM_MOD_CRIT_RATING_SHORT] = "CRIT",
	[ITEM_MOD_DAMAGE_PER_SECOND_SHORT] = "DAMAGE_PER_SECOND",
	[ITEM_MOD_DEFENSE_SKILL_RATING_SHORT] = "DEFENSE",
	[ITEM_MOD_DODGE_RATING_SHORT] = "DODGE",
	[ITEM_MOD_EXPERTISE_RATING_SHORT] = "EXPERTISE",
	[ITEM_MOD_FERAL_ATTACK_POWER_SHORT] = "FERAL_ATTACK_POWER",
	[ITEM_MOD_HASTE_RATING_SHORT] = "HASTE",
	[ITEM_MOD_HEALTH_REGEN_SHORT] = "HEALTH_REGENERATION",
	[ITEM_MOD_HEALTH_REGENERATION_SHORT] = "HEALTH_REGENERATION",
	[ITEM_MOD_HIT_RATING_SHORT] = "HIT",
	[ITEM_MOD_INTELLECT_SHORT] = "INTELLECT",
	[ITEM_MOD_MANA_REGENERATION_SHORT] = "MANA_REGENERATION",
	[ITEM_MOD_MASTERY_RATING_SHORT] = "MASTERY",
	[ITEM_MOD_PARRY_RATING_SHORT] = "PARRY",
	[ITEM_MOD_POWER_REGEN0_SHORT] = "MANA_REGENERATION",
	[ITEM_MOD_PVP_POWER_SHORT] = "PVP_POWER",
	[ITEM_MOD_RESILIENCE_RATING_SHORT] = "RESILIENCE",
	[ITEM_MOD_SPELL_POWER_SHORT] = "SPELL_POWER",
	[ITEM_MOD_SPIRIT_SHORT] = "SPIRIT",
	[ITEM_MOD_STAMINA_SHORT] = "STAMINA",
	[ITEM_MOD_STRENGTH_SHORT] = "STRENGTH",
	[EMPTY_SOCKET_BLUE] = "SOCKET",
	[EMPTY_SOCKET_META] = "SOCKET",
	[EMPTY_SOCKET_PRISMATIC] = "SOCKET",
	[EMPTY_SOCKET_RED] = "SOCKET",
	[EMPTY_SOCKET_YELLOW] = "SOCKET",
	[RESISTANCE0_NAME] = "ARMOR",
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
		MASTERY = true,
		PVP_POWER = true,
		RESILIENCE = true,
		SOCKET = true,
		STAMINA = true,
	},
	DEATHKNIGHT = {
		[0] = {
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			EXPERTISE = true,
			HIT = true,
			STRENGTH = true,
		},
		[1] = { -- Blood
			ARMOR = true,
			DEFENSE = true,
			DODGE = true,
			PARRY = true,
		},
		[2] = {}, -- Frost
		[3] = {}, -- Unholy
	},
	DRUID = {
		[1] = { -- Balance
			HIT = true,
			INTELLECT = true,
			MANA_REGENERATION = true,
			SPELL_POWER = true,
			SPIRIT = true,
		},
		[2] = { -- Feral
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			FERAL_ATTACK_POWER = true,
			EXPERTISE = true,
			HIT = true,
			STRENGTH = true,
		},
		[3] = { -- Guardian
			AGILITY = true,
			ARMOR = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			FERAL_ATTACK_POWER = true,
			DEFENSE = true,
			DODGE = true,
			EXPERTISE = true,
			HIT = true,
			STRENGTH = true,
		},
		[4] = { -- Restoration
			INTELLECT = true,
			MANA_REGENERATION = true,
			SPELL_POWER = true,
			SPIRIT = true,
		},
	},
	HUNTER = {
		[0] = {
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			EXPERTISE = true,
			HIT = true,
		},
		[1] = {}, [2] = {}, [3] = {}, -- Beast Mastery, Marksmanship, Survival
	},
	MAGE = {
		[0] = {
			HIT = true,
			INTELLECT = true,
			MANA_REGENERATION = true,
			SPELL_POWER = true,
			SPIRIT = true,
		},
		[1] = {}, [2] = {}, [3] = {}, -- Arcane, Fire, Frost
	},
	MONK = {
		[1] = { -- Brewmaster
			AGILITY = true,
			ARMOR = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			DEFENSE = true,
			DODGE = true,
			EXPERTISE = true,
			HIT = true,
			PARRY = true,
		},
		[2] = { -- Mistweaver
			INTELLECT = true,
			MANA_REGENERATION = true,
			SPELL_POWER = true,
			SPIRIT = true,
		},
		[3] = { -- Windwalker
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			EXPERTISE = true,
			HIT = true,
		},
	},
	PALADIN = {
		[1] = { -- Holy
			INTELLECT = true,
			MANA_REGENERATION = true,
			SPELL_POWER = true,
			SPIRIT = true,
		},
		[2] = { -- Protection
			ARMOR = true,
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			DEFENSE = true,
			EXPERTISE = true,
			HIT = true,
			PARRY = true,
			STRENGTH = true,
		},
		[3] = { -- Retribution
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			DODGE = true,
			EXPERTISE = true,
			HIT = true,
			STRENGTH = true,
		},
	},
	PRIEST = {
		[0] = {
			INTELLECT = true,
			MANA_REGENERATION = true,
			SPELL_POWER = true,
			SPIRIT = true,
		},
		[1] = {}, -- Discipline
		[2] = {}, -- Holy
		[3] = { -- Shadow
			HIT = true,
		},
	},
	ROGUE = {
		[0] = {
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			EXPERTISE = true,
			HIT = true,
		},
		[1] = {}, [2] = {}, [3] = {}, -- Assassination, Combat, Subtlety
	},
	SHAMAN = {
		[1] = { -- Elemental
			HIT = true,
			INTELLECT = true,
			MANA_REGENERATION = true,
			SPELL_POWER = true,
			SPIRIT = true,
		},
		[2] = { -- Enhancement
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			EXPERTISE = true,
			HIT = true,
		},
		[3] = { -- Restoration
			INTELLECT = true,
			MANA_REGENERATION = true,
			SPELL_POWER = true,
			SPIRIT = true,
		},
	},
	WARLOCK = {
		[0] = {
			HIT = true,
			INTELLECT = true,
			MANA_REGENERATION = true,
			SPELL_POWER = true,
		},
		[1] = {}, [2] = {}, [3] = {}, -- Affliction, Demonology, Destruction
	},
	WARRIOR = {
		[0] = {
			AGILITY = true,
			ATTACK_POWER = true,
			DAMAGE_PER_SECOND = true,
			EXPERTISE = true,
			HIT = true,
			STRENGTH = true,
		},
		[1] = {}, -- Arms
		[2] = {}, -- Fury
		[3] = { -- Protection
			ARMOR = true,
			DEFENSE = true,
			DODGE = true,
			PARRY = true,
		},
	},
}

------------------------------------------------------------------------

local classDefaults, classDB

local enabledStats = {}
Addon.enabledStats = enabledStats

local function UpdateStatsList()
	wipe(enabledStats)
	for stat, enable in pairs(classDB[0]) do
		enabledStats[stat] = enable
	end
	local spec = GetSpecialization()
	if classDB[spec] then
		for stat, enable in pairs(classDB[spec]) do
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

local function HideIrrelevantStats(tooltip)
	--print(ADDON, "HideIrenabledStats", tooltip:GetName())
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
			if stat and not enabledStats[stat] then
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