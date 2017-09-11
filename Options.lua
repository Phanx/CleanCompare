--[[--------------------------------------------------------------------
	CleanCompare
	Removes irrelevant stats from item comparison tooltips.
	Copyright (c) 2014-2017 Phanx <addons@phanx.net>. All rights reserved.
	https://github.com/phanx-wow/CleanCompare
----------------------------------------------------------------------]]

local ADDON, Addon = ...

local L = {
	PANEL_DESC = "Use this panel to choose which stats are shown in item compare tooltips for each of your class's specializations.",
	RESET_TOOLTIP = "Revert to the default settings for all specializations for your current class.",
	SINGLE_PROFILE = "Single Profile",
	SINGLE_PROFILE_TOOLTIP = "Use a single profile for all specializations for your class.",
	SOCKETS = "Sockets",
}
if GetLocale() == "deDE" then
	L.PANEL_DESC = "Diese Einstellungen ermöglichen das Auswählen der Statistiken, die für jede Spezialisierung Eurer Klasse in der Vergleichens-Tooltipps anzuzeigen."
	L.RESET_TOOLTIP = "Auf die Standardeinstellungen für alle Spezialisierung Eurer Klasse zurücksetzen."
	L.SINGLE_PROFILE = "Einzelnes Profil"
	L.SINGLE_PROFILE_TOOLTIP = "Das gleiche Profil für alle Spezialisierung Eurer Klasse verwenden."
	L.SOCKETS = "Sockel"
elseif GetLocale():match("^es") then
	L.PANEL_DESC = "Estas opciones te permiten escoger qué estadísticas se muestran en las descripciones de comparación para cada especalización de tu clase."
	L.RESET_TOOLTIP = "Restablece la configuración predeterminada para todas las especializaciones de tu clase."
	L.SINGLE_PROFILE = "Único perfil"
	L.SINGLE_PROFILE_TOOLTIP = "Use un único perfil para todas las especializaciones de tu clase."
	L.SOCKETS = "Ranuras"
end

local Options = CreateFrame("Frame", ADDON.."Options", InterfaceOptionsFramePanelContainer)
Options.name = GetAddOnMetadata(ADDON, "Title") or ADDON
InterfaceOptions_AddCategory(Options)
Addon.OptionsPanel = Options

Options:SetScript("OnShow", function()
	local className, class = UnitClass("player")
	local classDB = Addon.classDB
	local spec = GetSpecialization()

	local classRoles = {}
	for i = 1, GetNumSpecializations() do
		local _, _, _, _, role = GetSpecializationInfo(i)
		if not classRoles[role] then
			table.insert(classRoles, _G[role])
			classRoles[role] = true
		end
	end
	table.sort(classRoles)
	classRoles = table.concat(classRoles, LIST_DELIMITER)

	local Title = Options:CreateFontString("$parentTitle", "ARTWORK", "GameFontNormalLarge")
	Title:SetPoint("TOPLEFT", 16, -16)
	Title:SetText(Options.name)

	local Notes = Options:CreateFontString("$parentSubText", "ARTWORK", "GameFontHighlightSmall")
	Notes:SetPoint("TOPLEFT", Title, "BOTTOMLEFT", 0, -8)
	Notes:SetPoint("RIGHT", -32, 0)
	Notes:SetHeight(32)
	Notes:SetJustifyH("LEFT")
	Notes:SetJustifyV("TOP")
	Notes:SetText(L.PANEL_DESC)

	local Reset = CreateFrame("Button", "$parentReset", Options, "UIPanelButtonTemplate")
	Reset:SetPoint("TOPRIGHT", -16, -16)
	Reset:SetWidth(96)
	Reset:SetText(RESET)
	Reset:SetScript("OnEnter", function(this)
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
		GameTooltip:SetText(L.RESET_TOOLTIP, nil, nil, nil, nil, true)
	end)
	Reset:SetScript("OnLeave", GameTooltip_Hide)
	Reset:SetScript("OnClick", function(this)
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
		for spec = 1, #classDB do
			local specDB = classDB[spec]
			wipe(specDB)
			for stat in pairs(Addon.classDefaults[spec]) do
				specDB[stat] = true
			end
		end
		Options.refresh()
	end)

	local TabPanel = CreateFrame("Frame", nil, Options)
	TabPanel:SetPoint("TOPLEFT", Notes, "BOTTOMLEFT", 0, -24)
	TabPanel:SetPoint("BOTTOMRIGHT", Options, -16, 16)
	TabPanel:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets= { left = 3, right = 3, top = 5, bottom = 3 }
	})
	TabPanel:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
	TabPanel:SetBackdropBorderColor(0.4, 0.4, 0.4)

	--[[
	local SingleSpec = CreateFrame("CheckButton", "$parentSingleSpec", Options, "InterfaceOptionsCheckButtonTemplate")
	SingleSpec:SetPoint("BOTTOMRIGHT", TabPanel, "TOPRIGHT", -4, -2)
	SingleSpec.Text:ClearAllPoints()
	SingleSpec.Text:SetPoint("RIGHT", SingleSpec, "LEFT", -2, 1)
	SingleSpec.Text:SetText(SINGLE_PROFILE)
	SingleSpec.tooltipText = SINGLE_PROFILE_TOOLTIP
	SingleSpec:SetScript("OnClick", function(this)
		local checked = not not this:GetChecked()
		PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		spec = checked and 0 or 1
		Options.refresh()
	end)
	]]

	local Tabs = {}
	do
		local function clicktab(this)
			PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB)
			PanelTemplates_Tab_OnClick(this, Options)
			spec = this:GetID()
			Options.refresh()
		end

		for i = 1, GetNumSpecializations() do
			local tab = CreateFrame("Button", "$parentTab"..i, Options, "OptionsFrameTabButtonTemplate")
			local _, name, _, icon, _, role = GetSpecializationInfo(i)
			tab:SetText(name)
			tab:SetID(i)
			if i == 1 then
				tab:SetPoint("BOTTOMLEFT", TabPanel, "TOPLEFT", 4, 0)
			else
				tab:SetPoint("BOTTOMLEFT", Tabs[i-1], "BOTTOMRIGHT", -8, 0)
			end
			tab:SetScript("OnClick", clicktab)
			tab:SetDisabledFontObject(GameFontDisableSmall)
			tab:GetFontString():SetPoint("CENTER", 0, -4)
			PanelTemplates_TabResize(tab, 0)
			Tabs[i] = tab
		end

		PanelTemplates_SetNumTabs(Options, #Tabs)
		PanelTemplates_SetTab(Options, 1)
	end

	local SpecIconBG = TabPanel:CreateTexture(nil, "BORDER")
	SpecIconBG:SetPoint("TOPLEFT", 16, -16)
	SpecIconBG:SetSize(32, 32)
	SpecIconBG:SetTexture(0, 0, 0, 1)

	local SpecIcon = TabPanel:CreateTexture(nil, "OVERLAY")
	SpecIcon:SetAllPoints(SpecIconBG)

	local SpecName = TabPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	SpecName:SetPoint("TOPLEFT", SpecIcon, "TOPRIGHT", 8, 0)
	SpecName:SetPoint("RIGHT", -16, 0)
	SpecName:SetJustifyH("LEFT")

	local RoleName = TabPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	RoleName:SetPoint("BOTTOMLEFT", SpecIcon, "BOTTOMRIGHT", 8, -1)
	RoleName:SetPoint("RIGHT", -16, 0)
	RoleName:SetJustifyH("LEFT")

	local Toggles = {}
	do
		local stats = {}
		local hidden = {
			[ITEM_MOD_HEALTH_REGEN_SHORT] = true,
			[ITEM_MOD_HEALTH_REGENERATION_SHORT] = true,
			[EMPTY_SOCKET_BLUE] = true,
			[EMPTY_SOCKET_COGWHEEL] = true,
			[EMPTY_SOCKET_HYDRAULIC] = true,
			[EMPTY_SOCKET_META] = true,
			[EMPTY_SOCKET_NO_COLOR] = true,
			[EMPTY_SOCKET_PRISMATIC] = true,
			[EMPTY_SOCKET_RED] = true,
			[EMPTY_SOCKET_YELLOW] = true,
			[RESISTANCE1_NAME] = true,
			[RESISTANCE2_NAME] = true,
			[RESISTANCE3_NAME] = true,
			[RESISTANCE4_NAME] = true,
			[RESISTANCE5_NAME] = true,
			[RESISTANCE6_NAME] = true,
			[strtrim(gsub(ITEM_RESIST_ALL, "%%[cd]", ""))] = true,
		}
		tinsert(stats, L.SOCKETS)
		tinsert(stats, STAT_CATEGORY_RESISTANCE)
		for text in pairs(Addon.statToKey) do
			if not hidden[text] then
				tinsert(stats, text)
			end
		end
		sort(stats)
		hidden = nil

		local breakpoint = 1 + floor(#stats / 2 + 0.5)

		local function checkbox(this)
			local checked = not not this:GetChecked()
			PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
			print("toggle", class, spec, this.stat, checked or nil)
			if checked == classDB[0][this.stat] then
				classDB[spec][this.stat] = nil
			else
				classDB[spec][this.stat] = checked
			end
			Addon:UpdateStatsList()
		end

		local statToKey = setmetatable({
			[L.SOCKETS] = "SOCKET",
			[STAT_CATEGORY_RESISTANCE] = "RESISTANCE",
		}, { __index = Addon.statToKey })

		for i = 1, #stats do
			local box = CreateFrame("CheckButton", "$parentToggle"..i, TabPanel, "InterfaceOptionsCheckButtonTemplate")
			box:SetScript("OnClick", checkbox)
			box.Text:SetText(stats[i])
			box.stat = statToKey[stats[i]]

			if i == 1 then
				box:SetPoint("TOPLEFT", TabPanel, 16, -16 - 46)
			elseif i == breakpoint then
				box:SetPoint("TOPLEFT", TabPanel, "TOP", 8, -16 - 46)
			else
				box:SetPoint("TOPLEFT", Toggles[i-1], "BOTTOMLEFT", 0, -3)
			end

			Toggles[i] = box
		end
	end

	function Options.okay() spec = nil end
	function Options.cancel() spec = nil end
	function Options.refresh()
		if not spec then
			spec = GetSpecialization() or 1
		end
		--[[
		if spec == 0 then
			local coords = CLASS_ICON_TCOORDS[class]
			SpecIcon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
			SpecIcon:SetTexCoord(coords[1] + 0.02, coords[2] - 0.02, coords[3] + 0.02, coords[4] - 0.02)
			SpecName:SetText(className)
			RoleName:SetText(classRoles)

			for i = 1, #Tabs do
				PanelTemplates_DisableTab(Options, i)
			end
			PanelTemplates_SetTab(Options, nil)
		else
		]]
			local _, name, _, icon, _, role = GetSpecializationInfo(spec)
			SpecIcon:SetTexture(icon)
			SpecIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			SpecName:SetText(name)
			RoleName:SetText(_G[role])

			for i = 1, #Tabs do
				PanelTemplates_EnableTab(Options, i)
			end
			PanelTemplates_SetTab(Options, spec)
--[[
		end

		SingleSpec:SetHitRectInsets(-16 - SingleSpec.Text:GetWidth(), 0, 0, 0)
]]
		for i = 1, #Toggles do
			local check = Toggles[i]
			check:SetHitRectInsets(0, -16 - check.Text:GetWidth(), 0, 0)
			check:SetChecked(Addon.enabledStatsBySpec[spec][check.stat])
		end
	end

	Options:SetScript("OnShow", nil)
	Options.refresh()
end)

SLASH_CLEANCOMPARE1 = "/ccompare"
SlashCmdList.CLEANCOMPARE = function() InterfaceOptionsFrame_OpenToCategory(Options) end
