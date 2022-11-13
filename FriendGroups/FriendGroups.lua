--[[
	Variables
]]--
local groupsTotal = {}
local groupsSorted = {}
local groupsCount = {}
local expansionMaxLevel = {}
local currentExpansionMaxLevel, FriendGroups_Menu, FriendGroupFrame, searchOpened
local searchValue = ""
local menuItems = {
	[1] = {
		{ text = "", notCheckable = true, isTitle = true },
		{ text = "Invite all to party", notCheckable = true, func = function(self, menu, clickedgroup) FriendGroups_InviteOrGroup(clickedgroup, true) end },
		{ text = "Rename group", notCheckable = true, func = function(self, menu, clickedgroup) StaticPopup_Show("FRIEND_GROUP_RENAME", nil, nil, clickedgroup) end },
		{ text = "Remove group", notCheckable = true, func = function(self, menu, clickedgroup) FriendGroups_InviteOrGroup(clickedgroup, false) end },
		{ text = "Settings", notCheckable = true, hasArrow = true },
	},
	[2] = {
		{ text = "Hide all offline", checked = function() return FriendGroups_SavedVars.hide_offline end, func = function() CloseDropDownMenus() FriendGroups_SavedVars.hide_offline = not FriendGroups_SavedVars.hide_offline FriendsList_Update() end },
		{ text = "Show Faction Icons", checked = function() return FriendGroups_SavedVars.show_faction_icons end, func = function() CloseDropDownMenus() FriendGroups_SavedVars.show_faction_icons = not FriendGroups_SavedVars.show_faction_icons FriendsList_Update() end },
		{ text = "Hide level of max level players", checked = function() return FriendGroups_SavedVars.hide_high_level end, func = function() CloseDropDownMenus() FriendGroups_SavedVars.hide_high_level = not FriendGroups_SavedVars.hide_high_level FriendsList_Update() end },
		{ text = "Colour names", checked = function() return FriendGroups_SavedVars.colour_classes end, func = function() CloseDropDownMenus() FriendGroups_SavedVars.colour_classes = not FriendGroups_SavedVars.colour_classes FriendsList_Update() end },
		{ text = "Gray out other Faction", checked = function() return FriendGroups_SavedVars.gray_faction end, func = function() CloseDropDownMenus() FriendGroups_SavedVars.gray_faction = not FriendGroups_SavedVars.gray_faction FriendsList_Update() end },
		{ text = "Show Mobile always as AFK", checked = function() return FriendGroups_SavedVars.show_mobile_afk end, func = function() CloseDropDownMenus() FriendGroups_SavedVars.show_mobile_afk = not FriendGroups_SavedVars.show_mobile_afk FriendsList_Update() end },
		{ text = "Add Mobile Text", checked = function() return FriendGroups_SavedVars.add_mobile_text end, func = function() CloseDropDownMenus() FriendGroups_SavedVars.add_mobile_text = not FriendGroups_SavedVars.add_mobile_text FriendsList_Update() end },
		{ text = "Show only Ingame Friends", checked = function() return FriendGroups_SavedVars.ingame_only end, func = function() CloseDropDownMenus() FriendGroups_SavedVars.ingame_only = not FriendGroups_SavedVars.ingame_only FriendsList_Update() end },
		--{ text = "Show only Retail Friends", checked = function() return FriendGroups_SavedVars.ingame_retail end, func = function() CloseDropDownMenus() FriendGroups_SavedVars.ingame_retail = not FriendGroups_SavedVars.ingame_retail FriendsList_Update() end },		
		{ text = "Show only BattleTag", checked = function() return FriendGroups_SavedVars.show_btag end, func = function() CloseDropDownMenus() FriendGroups_SavedVars.show_btag = not FriendGroups_SavedVars.show_btag FriendsList_Update() end },
		{ text = "Show only Retail Friends", checked = function() return FriendGroups_SavedVars.show_retail end, func = function() CloseDropDownMenus() FriendGroups_SavedVars.show_retail = not FriendGroups_SavedVars.show_retail FriendsList_Update() end },
		{ text = "Sort by status", checked = function() return FriendGroups_SavedVars.sort_by_status end, func = function() CloseDropDownMenus() FriendGroups_SavedVars.sort_by_status = not FriendGroups_SavedVars.sort_by_status FriendsList_Update() end },
		{ text = "Enable Favorite Friends Group", checked = function() return FriendGroups_SavedVars.add_favorite_group end, func = function() CloseDropDownMenus() FriendGroups_SavedVars.add_favorite_group = not FriendGroups_SavedVars.add_favorite_group FriendsList_Update() end },
		{ text = "Enable Search", disabled = true, checked = function() return FriendGroups_SavedVars.show_search end, func = function() CloseDropDownMenus() FriendGroups_SavedVars.show_search = not FriendGroups_SavedVars.show_search FriendsList_Update() end },
	},
}

--[[
	Init Values
]]--

-- Expansion Max Level
expansionMaxLevel[LE_EXPANSION_CLASSIC] = 60
expansionMaxLevel[LE_EXPANSION_BURNING_CRUSADE] = 70
expansionMaxLevel[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = 80
expansionMaxLevel[LE_EXPANSION_CATACLYSM] = 85
expansionMaxLevel[LE_EXPANSION_MISTS_OF_PANDARIA] = 90
expansionMaxLevel[LE_EXPANSION_WARLORDS_OF_DRAENOR] = 100
expansionMaxLevel[LE_EXPANSION_LEGION] = 110
expansionMaxLevel[LE_EXPANSION_BATTLE_FOR_AZEROTH] = 120
expansionMaxLevel[LE_EXPANSION_SHADOWLANDS] = 60
expansionMaxLevel[LE_EXPANSION_DRAGONFLIGHT] = 70

currentExpansionMaxLevel = expansionMaxLevel[GetExpansionLevel()]

--[[
	Helper Functions
]]--

function FriendGroups_DebugLog(tData, strName)
	if ViragDevTool_AddData then 
		ViragDevTool_AddData(tData, strName)
	end
end

function FriendGroups_Rename(self, old)
	local input = self.editBox:GetText()
	local oldGroup = old.name:GetText()
	if input == "" then
		return
	end
	local groups = {}
	for i = 1, BNGetNumFriends() do
		local presenceID = C_BattleNet.GetFriendAccountInfo(i).bnetAccountID
		local noteText = C_BattleNet.GetFriendAccountInfo(i).note
		local note = FriendGroups_NoteAndGroups(noteText, groups)
		if groups[oldGroup] then
			groups[oldGroup] = nil
			groups[input] = true
			note = FriendGroups_CreateNote(note, groups)
			BNSetFriendNote(presenceID, note)
		end
	end
	for i = 1, C_FriendList.GetNumFriends() do
		local note = C_FriendList.GetFriendInfoByIndex(i).notes
		local name = C_FriendList.GetFriendInfoByIndex(i).name
		note = FriendGroups_NoteAndGroups(note, groups)

		if groups[oldGroup] then
			groups[oldGroup] = nil
			groups[input] = true
			note = FriendGroups_CreateNote(note, groups)
			C_FriendList.SetFriendNotes(name, note)
		end
	end
	FriendsList_Update()
end

function FriendGroups_InviteOrGroup(clickedgroup, invite)
	local groups = {}
	
	clickedgroup = clickedgroup.name:GetText()
	
	for i = 1, BNGetNumFriends() do
		local friendAccountInfo = C_BattleNet.GetFriendAccountInfo(i)
		local gameAccountInfo = friendAccountInfo.gameAccountInfo
		local presenceID = friendAccountInfo.bnetAccountID
		local noteText = friendAccountInfo.note
		local note = FriendGroups_NoteAndGroups(noteText, groups)
		if groups[clickedgroup] then
			if invite and gameAccountInfo and gameAccountInfo.gameAccountID then
				BNInviteFriend(gameAccountInfo.gameAccountID)
			elseif not invite then
				groups[clickedgroup] = nil
				note = FriendGroups_CreateNote(note, groups)
				BNSetFriendNote(presenceID, note)
			end
		end
	end
	for i = 1, C_FriendList.GetNumFriends() do
		local friend_info = C_FriendList.GetFriendInfoByIndex(i)
		local name = friend_info.name
		local connected = friend_info.connected
		local noteText = friend_info.notes
		local note = FriendGroups_NoteAndGroups(noteText, groups)

		if groups[clickedgroup] then
			if invite and connected then
				C_PartyInfo.InviteUnit(name)
			elseif not invite then
				groups[clickedgroup] = nil
				note = FriendGroups_CreateNote(note, groups)
				C_FriendList.SetFriendNotes(name, note)
			end
		end
	end
end

function FriendGroups_AddGroup(note, group)
	local groups = {}
	note = FriendGroups_NoteAndGroups(note, groups)
	groups[""] = nil
	groups[group] = true
	return FriendGroups_CreateNote(note, groups)
end

function FriendGroups_Create(self, data)
	local input = self.editBox:GetText()
	if input == "" then
		return
	end
	local note = FriendGroups_AddGroup(data.note, input)
	if data.name then
		data.set(data.name, note)
	else
		data.set(data.id, note)
		
	FriendGroups_SavedVars.collapsed[input] = true
	end
end



function FriendGroups_NoteAndGroups(note, groups)
	if not note then
		return FriendGroups_FillGroups(groups, "")
	end
	if groups then
		return FriendGroups_FillGroups(groups, strsplit("#", note))
	end
	return strsplit("#", note)
end

function FriendGroups_RemoveGroup(note, group)
	local groups = {}
	note = FriendGroups_NoteAndGroups(note, groups)
	groups[""] = nil
	groups[group] = nil
	
	return FriendGroups_CreateNote(note, groups)
end

function FriendGroups_CreateNote(note, groups)
	local value = ""
	if note then
		value = note
	end
	for group in pairs(groups) do
		value = value .. "#" .. group
	end
	return value
end

function FriendGroups_FillGroups(groups, note, ...)
	wipe(groups)
	local n = select('#', ...)
	for i = 1, n do
		local v = select(i, ...)
		v = strtrim(v)
		groups[v] = true
	end
	if n == 0 then
		groups[""] = true
	end
	return note
end

function FriendGroups_HasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function FriendGroups_AddDropDown(self, level)
    if UIDROPDOWNMENU_OPEN_MENU.which == "BN_FRIEND" or UIDROPDOWNMENU_OPEN_MENU.which == "BN_FRIEND_OFFLINE" or UIDROPDOWNMENU_OPEN_MENU.which == "FRIEND" or UIDROPDOWNMENU_OPEN_MENU.which == "FRIEND_OFFLINE" then
        local info = UIDropDownMenu_CreateInfo()
        local name = UIDROPDOWNMENU_OPEN_MENU.name
		local bnetfriend = nil

		if not C_FriendList.GetFriendInfo(name) and UIDROPDOWNMENU_OPEN_MENU.which == "FRIEND" then return end

		if UIDROPDOWNMENU_OPEN_MENU.which == "BN_FRIEND" or UIDROPDOWNMENU_OPEN_MENU.which == "BN_FRIEND_OFFLINE" then 
			bnetfriend = true
		else
			bnetfriend = false
		end

        if level == 1 then
			local listFrame = _G["DropDownList"..level];
			local listFrameName = listFrame:GetName();
			local buttonsAdded = false
			
			for index = 1, listFrame.numButtons do
				local button = _G[listFrameName.."Button"..index];
				
				if button and button.value and button.value == "Friend Groups" then
					buttonsAdded = true
					break
				end
			end
			
			if not buttonsAdded then
				info.isTitle = 1
				info.text = "Friend Groups"
				info.notCheckable = 1
				UIDropDownMenu_AddButton(info, level)
		
				info.keepShownOnClick = false
				info.disabled = false
				info.isTitle = false
				info.isNotRadio = true
				info.notCheckable = true
		
				info.text = "Create new group"
				info.func = function() FriendGroups_CreateNewGroup(name, bnetfriend) end      
				UIDropDownMenu_AddButton(info, level)

				info.text = "Add to group"
				info.func = function() ToggleDropDownMenu(1, nil, FriendGroupFrame, "FriendsFrameCloseButton", 0, 0, {option = "add", name = name, bnetfriend = bnetfriend}) end     
				UIDropDownMenu_AddButton(info, level)

				info.text = "Remove from group"
				info.func = function() ToggleDropDownMenu(1, nil, FriendGroupFrame, "FriendsFrameCloseButton", 0, 0, {option = "delete", name = name, bnetfriend = bnetfriend}) end      
				UIDropDownMenu_AddButton(info, level)
			end
        end
		
		
    end
end

function FriendGroups_GetInfoByName(name, bnetfriend)
	if bnetfriend then
		local accountID = 0
		for i=1, BNGetNumFriends() do
			local acc = C_BattleNet.GetFriendAccountInfo(i)
			if acc.accountName == name then
				accountID = acc.bnetAccountID
			end
		end

		return C_BattleNet.GetAccountInfoByID(accountID)
	else
		local info = C_FriendList.GetFriendInfo(name)
		return info
	end
end

function FriendGroups_CreateNewGroup(name, bnetfriend)
	if bnetfriend then
		local accountInfo = FriendGroups_GetInfoByName(name, bnetfriend)
		StaticPopup_Show("FRIEND_GROUP_CREATE", nil, nil, {id = accountInfo.bnetAccountID, note = accountInfo.note, set = BNSetFriendNote})
	else
		local FriendInfo = C_FriendList.GetFriendInfo(name)
		StaticPopup_Show("FRIEND_GROUP_CREATE", nil, nil, {name = name, note = FriendInfo.notes, set = C_FriendList.SetFriendNotes})
	end
end

function FriendGroups_SplitBattleTag(battleTag)
	local sep = "#"

	if sep == nil then
	   sep = "%s"
	end
	local t={}
	for str in string.gmatch(battleTag, "([^"..sep.."]+)") do
	   table.insert(t, str)
	end
	return t[1]
end

function FriendGroups_GetClassColorCode(class, returnTable)
	if not class then
		return returnTable and FRIENDS_GRAY_COLOR or string.format("|cFF%02x%02x%02x", FRIENDS_GRAY_COLOR.r*255, FRIENDS_GRAY_COLOR.g*255, FRIENDS_GRAY_COLOR.b*255)
	end

	local initialClass = class
	for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
		if class == v then
			class = k
			break
		end
	end

	if class == initialClass then
		for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
			if class == v then
				class = k
				break
			end
		end
	end

	local color = class ~= "" and RAID_CLASS_COLORS[class] or FRIENDS_GRAY_COLOR
	if returnTable then
		return color
	else
		return string.format("|cFF%02x%02x%02x", color.r*255, color.g*255, color.b*255)
	end
end

function FriendGroups_GetBNetButtonNameText(accountName, client, canCoop, characterName, class, level, battleTag)
	local nameText

	-- set up player name and character name
	if accountName then
		if FriendGroups_SavedVars.show_btag and battleTag then
			nameText = FriendGroups_SplitBattleTag(battleTag)
		else
			nameText = accountName
		end
	else
		nameText = UNKNOWN
	end

	-- append character name
	if characterName then

		local characterNameSuffix
		if (not level) or (FriendGroups_SavedVars.hide_high_level and level == currentExpansionMaxLevel) then
			characterNameSuffix = ""
		else
			characterNameSuffix= " | "..level
		end

		if client == BNET_CLIENT_WOW then
			if not canCoop and FriendGroups_SavedVars.gray_faction then
				nameText = "|CFF949694"..nameText.." ".."["..characterName..characterNameSuffix.."}".."|r"
			elseif FriendGroups_SavedVars.colour_classes then
				local nameColor = FriendGroups_GetClassColorCode(class)
				nameText = nameText.." "..nameColor.."["..characterName..characterNameSuffix.."]"..FONT_COLOR_CODE_CLOSE
			else
				nameText = nameText.." ".."["..characterName..characterNameSuffix.."]"..FONT_COLOR_CODE_CLOSE
			end
		else
			if ENABLE_COLORBLIND_MODE == "1" then
				characterName = characterName
			end
			local characterNameAndLevel = characterName..characterNameSuffix
			nameText = nameText.." "..FRIENDS_OTHER_NAME_COLOR_CODE.."["..characterNameAndLevel.."]"..FONT_COLOR_CODE_CLOSE
		end
	end

	return nameText
end

function FriendGroups_GetPlayerGroups(note)
    if note then
        local groups = {}
		local formattedNote = string.match(note, "#.*")
		
		if formattedNote then
			for s in string.gmatch(formattedNote, "[^#]+") do
				table.insert(groups, s)
			end
		end
        
        return groups
    else
        return {}
    end
end

function FriendGroups_GetPlayerData(friendsListData, playerId, playerType)
	for _, playerData in pairs(friendsListData) do
		if playerData and playerData.id and playerData.id == playerId and playerData.buttonType and playerData.buttonType == playerType then
			return playerData
		end
	end
	
	return nil
end

function FriendGroups_ShowRichPresenceOnly(client, wowProjectID, faction, realmID)
	if (client ~= BNET_CLIENT_WOW) or (wowProjectID ~= WOW_PROJECT_ID) then
		-- If they are not in wow or in a different version of wow, always show rich presence only
		return true;
	elseif (WOW_PROJECT_ID == WOW_PROJECT_CLASSIC) and ((faction ~= playerFactionGroup) or (realmID ~= playerRealmID)) then
		-- If we are both in wow classic and our factions or realms don't match, show rich presence only
		return true;
	else
		-- Otherwise show more detailed info about them
		return false;
	end;
end

function FriendGroups_GetOnlineInfoText(client, isMobile, rafLinkType, locationText)
	if not locationText then
		return UNKNOWN;
	end
	if isMobile then
		return LOCATION_MOBILE_APP;
	end
	if (client == BNET_CLIENT_WOW) and (rafLinkType ~= Enum.RafLinkType.None) and not isMobile then
		if rafLinkType == Enum.RafLinkType.Recruit then
			return RAF_RECRUIT_FRIEND:format(locationText);
		else
			return RAF_RECRUITER_FRIEND:format(locationText);
		end
	end

	return locationText;
end

function FriendGroups_GetFriendInfoById(id)
	local accountName, characterName, class, level, isFavoriteFriend, isOnline,
		bnetAccountId, client, canCoop, wowProjectID, lastOnline,
		isAFK, isGameAFK, isDND, isGameBusy, mobile, zoneName, battleTag, factionName
	local realmName

	if C_BattleNet and C_BattleNet.GetFriendAccountInfo then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(id)
		if accountInfo then
			accountName = accountInfo.accountName
			isFavoriteFriend = accountInfo.isFavorite
			bnetAccountId = accountInfo.bnetAccountID
			isAFK = accountInfo.isAFK
			isDND = accountInfo.isDND
			lastOnline = accountInfo.lastOnlineTime
			battleTag = accountInfo.battleTag

			local gameAccountInfo = accountInfo.gameAccountInfo
			if gameAccountInfo then
				isOnline = gameAccountInfo.isOnline
				isGameAFK = gameAccountInfo.isGameAFK
				isGameBusy = gameAccountInfo.isGameBusy
				mobile = gameAccountInfo.isWowMobile
				characterName = gameAccountInfo.characterName
				class = gameAccountInfo.className
				level = gameAccountInfo.characterLevel
				client = gameAccountInfo.clientProgram
				wowProjectID = gameAccountInfo.wowProjectID
				gameText = gameAccountInfo.richPresence
				zoneName = gameAccountInfo.areaName
				realmName = gameAccountInfo.realmName
				factionName = gameAccountInfo.factionName
			end

			canCoop = CanCooperateWithGameAccount(accountInfo)
		end
	else
		bnetIDAccount, accountName, _, _, characterName, bnetAccountId, client,
		isOnline, lastOnline, isAFK, isDND, _, _, _, _, wowProjectID, _, _,
		isFavorite, mobile = BNetAccountInfo(id)


		if isOnline then
			_, _, _, realmName, realmID, factionName, _, class, _, zoneName, level,
			gameText, _, _, _, _, _, isGameAFK, isGameBusy, guid,
			wowProjectID, mobile = BNGetGameAccountInfo(bnetAccountId)
		end

		canCoop = CanCooperateWithGameAccount(bnetAccountId)
	end

	if realmName and realmName ~= "" then
		if zoneName then
			zoneName = zoneName .. " - " .. realmName
		end
	end

	return accountName, characterName, class, level, isFavoriteFriend, isOnline,
		bnetAccountId, client, canCoop, wowProjectID, lastOnline,
		isAFK, isGameAFK, isDND, isGameBusy, mobile, zoneName, gameText, battleTag, factionName
end

function FriendGroups_GetFactionIcon(factionGroup)
	if factionGroup == "Alliance" then
		return "Interface\\TargetingFrame\\UI-PVP-ALLIANCE";
	elseif factionGroup == "Horde" then
		return "Interface\\TargetingFrame\\UI-PVP-HORDE";
	end
end

function FriendGroups_GetStatusString(playerData)
	local status = "Offline"
	
	if playerData.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local friendAccountInfo = C_BattleNet.GetFriendAccountInfo(playerData.id)
		
		if friendAccountInfo then
			local gameAccountInfo = friendAccountInfo.gameAccountInfo

			if friendAccountInfo.isAFK and gameAccountInfo and gameAccountInfo.isOnline then
				status = "AFK"
			end
			
			if friendAccountInfo.isDND and gameAccountInfo and gameAccountInfo.isOnline then
				status = "DND"
			end
			
			if not friendAccountInfo.isAFK and not friendAccountInfo.isDND then
				if gameAccountInfo.isOnline then
					status = "Online"
					
					if gameAccountInfo.isGameBusy then
						status = "DND"
					end
					
					if gameAccountInfo.isGameAFK then
						status = "AFK"
					end
					
					if gameAccountInfo.clientProgram == "BSAp" then
						status = status .. "Mobile"
					end
					
					if gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
						status = status .. "InGame"
					end
				end
			end
		end
	elseif playerData.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local friendInfo = C_FriendList.GetFriendInfoByIndex(playerData.id)
		
		if friendInfo.connected then
			status = "OnlineInGame"
			
			if friendInfo.dnd then
				status = "DNDInGame"
			end
			
			if friendInfo.afk then
				status = "AFKInGame"
			end
		end
	end
	
	return status
end

function FriendGroups_SortTableByStatus(playerA, playerB)
	local statusSort = {}
	
	statusSort["OnlineInGame"] = 1
	statusSort["DNDInGame"] = 2
	statusSort["AFKInGame"] = 3
	statusSort["Online"] = 4
	statusSort["OnlineMobile"] = 5
	statusSort["DND"] = 6
	statusSort["AFK"] = 7
	statusSort["AFKMobile"] = 8
	statusSort["Offline"] = 9
	
	return statusSort[playerA.statusText] < statusSort[playerB.statusText]
end

function FriendGroups_SortGroupsCustom(groupA, groupB)
	if groupA == "[Favorites]" then
		return true
	end
	
	if groupB == "[Favorites]" then
		return false
	end
	
	return groupA < groupB
end

function FriendGroups_GetFriendNote(id, buttonType)
	local noteText = ""
	
	if buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(id)
			
		if accountInfo then
			noteText = accountInfo.note
			addFavorite = (FriendGroups_SavedVars.add_favorite_group and accountInfo.isFavorite)
		end
	elseif buttonType == FRIENDS_BUTTON_TYPE_WOW then
        noteText = C_FriendList.GetFriendInfoByIndex(id) and C_FriendList.GetFriendInfoByIndex(id).notes
	end
	
	return noteText
end

function FriendGroups_SetGroups(id, buttonType, favorite)
	local noteText = FriendGroups_GetFriendNote(id, buttonType)
	local groups = FriendGroups_GetPlayerGroups(noteText)
	local statusText = FriendGroups_GetStatusString({id=id,buttonType=buttonType})
	
	if FriendGroups_SavedVars.add_favorite_group and favorite then
		table.insert(groups, "[Favorites]")
	end
	
	if next(groups) == nil then
		table.insert(groups, "[No Group]")
	end
	
	for _, groupName in ipairs(groups) do
		local isOnline, client, isRetail
		local addToTable = false
		
		if not groupsTotal[groupName] then
			groupsTotal[groupName] = {}
			groupsCount[groupName] = {}
			groupsCount[groupName].Total = 0
			groupsCount[groupName].Online = 0
			table.insert(groupsSorted, groupName)
		end
		
		if buttonType == FRIENDS_BUTTON_TYPE_BNET then
			local friendAccountInfo = C_BattleNet.GetFriendAccountInfo(id)
			isOnline = friendAccountInfo.gameAccountInfo.isOnline
			client = friendAccountInfo.gameAccountInfo.clientProgram
			isRetail = (friendAccountInfo.gameAccountInfo.wowProjectID == WOW_PROJECT_MAINLINE)
		elseif buttonType == FRIENDS_BUTTON_TYPE_WOW then
			isOnline = C_FriendList.GetFriendInfoByIndex(id).connected
			client = BNET_CLIENT_WOW
		end
		
		if isOnline then
			if (FriendGroups_SavedVars.ingame_only and client == BNET_CLIENT_WOW) or not FriendGroups_SavedVars.ingame_only then
				if FriendGroups_SavedVars.show_retail and client == BNET_CLIENT_WOW then 
					if isRetail then
						addToTable = true
					end
				else
					addToTable = true
				end
			end
		else
			if not FriendGroups_SavedVars.hide_offline and ((FriendGroups_SavedVars.ingame_only and client == BNET_CLIENT_WOW) or not FriendGroups_SavedVars.ingame_only) then
				addToTable = true
			end
		end
		
		if addToTable then
			table.insert(groupsTotal[groupName], {id=id,buttonType=buttonType,statusText=statusText})
			groupsCount[groupName].Total = groupsCount[groupName].Total + 1
			if statusText ~= "Offline" then
				groupsCount[groupName].Online = groupsCount[groupName].Online + 1
			end
		end
	end
end


--[[
	FriendGroups_Menu
]]--
FriendGroups_Menu = CreateFrame("Frame", "FriendGroups_Menu")
FriendGroups_Menu.displayMode = "MENU"
FriendGroups_Menu.initialize = function(self, level)
	if not menuItems[level] then return end
	for _, items in ipairs(menuItems[level]) do
		local info = UIDropDownMenu_CreateInfo()
		for prop, value in pairs(items) do
			info[prop] = value ~= "" and value or UIDROPDOWNMENU_MENU_VALUE and UIDROPDOWNMENU_MENU_VALUE.name and UIDROPDOWNMENU_MENU_VALUE.name:GetText() or "[No Group]"
		end
		info.arg1 = k
		info.arg2 = UIDROPDOWNMENU_MENU_VALUE
		
		if level == 1 then
			local groupName = UIDROPDOWNMENU_MENU_VALUE and UIDROPDOWNMENU_MENU_VALUE.name and UIDROPDOWNMENU_MENU_VALUE.name:GetText()
			if groupName == "" or groupName == "[No Group]" or groupName == "[Favorites]"  then
				if items.text == "Rename group" or items.text == "Remove group" then
					info.disabled = true
				end
			end
		end
		
		UIDropDownMenu_AddButton(info, level)
	end
end

--[[
	FriendGroupFrame
]]--
FriendGroupFrame = CreateFrame("Frame", "FriendGroupFrame")
FriendGroupFrame.displayMode = "MENU"
FriendGroupFrame.info = {}
FriendGroupFrame.UncheckHack = function(dropdownbutton)
    _G[dropdownbutton:GetName().."Check"]:Hide()
end
FriendGroupFrame.HideMenu = function()
    if UIDROPDOWNMENU_OPEN_MENU == FriendGroupFrame then
        CloseDropDownMenus()
    end
end
FriendGroupFrame.initialize = function(self, level)
    local info = self.info
    local option = self.menuList.option
	local bnetfriend = self.menuList.bnetfriend
	local note = nil
	
    if level == 1 then            
        if option == "add" then
			local accountInfo = FriendGroups_GetInfoByName(self.menuList.name, bnetfriend)
			if bnetfriend then 
				note = accountInfo.note 
			else 
				note = accountInfo.notes 
			end

			info.isTitle = 1
            info.text = "Friend Groups"
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info)
    
            info.keepShownOnClick = false
            info.disabled = false
            info.isTitle = false
            info.isNotRadio = true
            info.notCheckable = true

			local groups = FriendGroups_GetPlayerGroups(note)
			for _, group in ipairs(groupsSorted) do
				if not FriendGroups_HasValue(groups, group) and not (group == "") and not (group == "[Favorites]") then
					info.text = group
					info.func = function() 
						note = FriendGroups_AddGroup(note, group) 
						if bnetfriend then
							BNSetFriendNote(accountInfo.bnetAccountID, note)
						else
							C_FriendList.SetFriendNotes(self.menuList.name, note)
						end
						
					end
					UIDropDownMenu_AddButton(info)
				end
			end

        elseif option == "delete" then
			local accountInfo = FriendGroups_GetInfoByName(self.menuList.name, bnetfriend)
			if bnetfriend then 
				note = accountInfo.note 
			else 
				note = accountInfo.notes 
			end

			info.isTitle = 1
            info.text = "Friend Groups"
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info)
    
            info.keepShownOnClick = false
            info.disabled = false
            info.isTitle = false
            info.isNotRadio = true
            info.notCheckable = true

			local groups = FriendGroups_GetPlayerGroups(note)
			
			for _,group in ipairs(groupsSorted) do
				if FriendGroups_HasValue(groups, group) then
					info.text = group
					info.func = function() 
						note = FriendGroups_RemoveGroup(note, group) 
						if bnetfriend then
							BNSetFriendNote(accountInfo.bnetAccountID, note)
						else
							C_FriendList.SetFriendNotes(self.menuList.name, note)
						end
						
					end
					UIDropDownMenu_AddButton(info)
				end
			end
        end

        -- Close menu item
        info.hasArrow     = nil
        info.value        = nil
        info.notCheckable = 1
        info.text         = "Cancel"
        info.func         = self.HideMenu
        UIDropDownMenu_AddButton(info)
    end
end

-- Popups
StaticPopupDialogs["FRIEND_GROUP_CREATE"] = {
	text = "Enter new group name",
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	OnAccept = function(self)
		local parent = self.editBox:GetParent()
		FriendGroups_Create(parent, parent.data)
		parent:Hide()
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent()
		FriendGroups_Create(parent, parent.data)
		parent:Hide()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}
StaticPopupDialogs["FRIEND_GROUP_RENAME"] = {
	text = "Enter new group name",
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	OnAccept = function(self)
		local parent = self.editBox:GetParent()
		FriendGroups_Rename(parent, parent.data)
		parent:Hide()
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent()
		FriendGroups_Rename(parent, parent.data)
		parent:Hide()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}

--[[
	Functions
]]--

function FriendsList_UpdateFriendButton(button, elementData)	
	local id = elementData.id;
	local buttonType = elementData.buttonType;
	button.buttonType = buttonType;
	button.id = id;
	
	if button.facIcon then button.facIcon:Hide() end
	
	local nameText, nameColor, infoText, isFavoriteFriend, statusTexture;
	local hasTravelPassButton = false;
	local isCrossFactionInvite = false;
	local inviteFaction = nil;
	if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
		local info = C_FriendList.GetFriendInfoByIndex(id);

		if ( info.connected ) then
			button.background:SetColorTexture(FRIENDS_WOW_BACKGROUND_COLOR.r, FRIENDS_WOW_BACKGROUND_COLOR.g, FRIENDS_WOW_BACKGROUND_COLOR.b, FRIENDS_WOW_BACKGROUND_COLOR.a);
			if ( info.afk ) then
				button.status:SetTexture(FRIENDS_TEXTURE_AFK);
			elseif ( info.dnd ) then
				button.status:SetTexture(FRIENDS_TEXTURE_DND);
			else
				button.status:SetTexture(FRIENDS_TEXTURE_ONLINE);
			end
			
			nameText = info.name..", "..format(FRIENDS_LEVEL_TEMPLATE, info.level, info.className);
			nameColor = FRIENDS_WOW_NAME_COLOR;
			infoText = FriendGroups_GetOnlineInfoText(BNET_CLIENT_WOW, info.mobile, info.rafLinkType, info.area);
		else
			button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a);
			button.status:SetTexture(FRIENDS_TEXTURE_OFFLINE);
			nameText = info.name;
			nameColor = FRIENDS_GRAY_COLOR;
			infoText = FRIENDS_LIST_OFFLINE;
		end
		button.gameIcon:Hide();
		button.summonButton:ClearAllPoints();
		button.summonButton:SetPoint("TOPRIGHT", button, "TOPRIGHT", 1, -1);
		FriendsFrame_SummonButton_Update(button.summonButton);
	elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
		local accountInfo = C_BattleNet.GetFriendAccountInfo(id);
		if accountInfo then
			nameText, nameColor, statusTexture = FriendsFrame_GetBNetAccountNameAndStatus(accountInfo);
			
			local accountName, characterName, class, level, isFavoriteFriend, isOnline,
			bnetAccountId, client, canCoop, wowProjectID, lastOnline,
			isAFK, isGameAFK, isDND, isGameBusy, mobile, zoneName, gameText, battleTag, factionName = FriendGroups_GetFriendInfoById(button.id)
			
			if FriendGroups_SavedVars.show_mobile_afk and client == 'BSAp' then
				statusTexture = FRIENDS_TEXTURE_AFK
			end

			nameText = FriendGroups_GetBNetButtonNameText(accountName, client, canCoop, characterName, class, level, battleTag)
			
			isFavoriteFriend = accountInfo.isFavorite;

			button.status:SetTexture(statusTexture);

			isCrossFactionInvite = accountInfo.gameAccountInfo.factionName ~= playerFactionGroup;
			inviteFaction = accountInfo.gameAccountInfo.factionName;

			if accountInfo.gameAccountInfo.isOnline then
				button.background:SetColorTexture(FRIENDS_BNET_BACKGROUND_COLOR.r, FRIENDS_BNET_BACKGROUND_COLOR.g, FRIENDS_BNET_BACKGROUND_COLOR.b, FRIENDS_BNET_BACKGROUND_COLOR.a);

				if FriendGroups_ShowRichPresenceOnly(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.wowProjectID, accountInfo.gameAccountInfo.factionName, accountInfo.gameAccountInfo.realmID) then
					infoText = FriendGroups_GetOnlineInfoText(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.richPresence);
				else
					infoText = FriendGroups_GetOnlineInfoText(accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.isWowMobile, accountInfo.rafLinkType, accountInfo.gameAccountInfo.areaName);
				end

				button.gameIcon:SetAtlas(BNet_GetBattlenetClientAtlas(accountInfo.gameAccountInfo.clientProgram));

				local fadeIcon = (accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW) and (accountInfo.gameAccountInfo.wowProjectID ~= WOW_PROJECT_ID);
				if fadeIcon then
					button.gameIcon:SetAlpha(0.6);
				else
					button.gameIcon:SetAlpha(1);
				end

				--Note - this logic should match the logic in FriendsFrame_ShouldShowSummonButton

				local shouldShowSummonButton = FriendsFrame_ShouldShowSummonButton(button.summonButton);
				button.gameIcon:SetShown(not shouldShowSummonButton);

				-- travel pass
				hasTravelPassButton = true;
				local restriction = FriendsFrame_GetInviteRestriction(button.id);
				if restriction == INVITE_RESTRICTION_NONE then
					button.travelPassButton:Enable();
				else
					button.travelPassButton:Disable();
				end
				
				if FriendGroups_SavedVars.show_faction_icons then
					if not button.facIcon then 
						button.facIcon = button:CreateTexture("facIcon"); 
						button.facIcon:ClearAllPoints();
						button.facIcon:SetPoint("RIGHT", button.gameIcon, "LEFT", 7, -5);
						button.facIcon:SetWidth(button.gameIcon:GetWidth())
						button.facIcon:SetHeight(button.gameIcon:GetHeight())
					end
					button.facIcon:SetTexture(FriendGroups_GetFactionIcon(accountInfo.gameAccountInfo.factionName));
					button.facIcon:Show()

					if accountInfo.gameAccountInfo.factionName == "Horde" then
						button.background:SetColorTexture(0.7, 0.2, 0.2, 0.2);
					elseif accountInfo.gameAccountInfo.factionName == "Alliance" then
						button.background:SetColorTexture(0.2, 0.2, 0.7, 0.2);
					end
				else
					if button.facIcon then
						button.facIcon:Hide()
					end
				end
			else
				button.background:SetColorTexture(FRIENDS_OFFLINE_BACKGROUND_COLOR.r, FRIENDS_OFFLINE_BACKGROUND_COLOR.g, FRIENDS_OFFLINE_BACKGROUND_COLOR.b, FRIENDS_OFFLINE_BACKGROUND_COLOR.a);
				button.gameIcon:Hide();
				infoText = FriendsFrame_GetLastOnlineText(accountInfo);
			end
			
			if FriendGroups_SavedVars.add_mobile_text and infoText == '' and client == 'BSAp' then
				infoText = "Mobile"
			end
			
			button.summonButton:ClearAllPoints();
			button.summonButton:SetPoint("CENTER", button.gameIcon, "CENTER", 1, 0);
			FriendsFrame_SummonButton_Update(button.summonButton);
		end
	end

	if hasTravelPassButton then
		button.travelPassButton:Show();
	else
		button.travelPassButton:Hide();
	end

	local selected = (FriendsFrame.selectedFriendType == buttonType) and (FriendsFrame.selectedFriend == id);
	FriendsFrame_FriendButtonSetSelection(button, selected);

	-- finish setting up button if it's not a header
	if nameText then
		button.name:SetText(nameText);
		button.name:SetTextColor(nameColor.r, nameColor.g, nameColor.b);
		button.info:SetText(infoText);
		button:Show();

		if isFavoriteFriend then
			button.Favorite:Show();
			button.Favorite:ClearAllPoints()
			button.Favorite:SetPoint("TOPLEFT", button.name, "TOPLEFT", button.name:GetStringWidth(), 0);
		else
			button.Favorite:Hide();
		end
	else
		button:Hide();
	end
	-- update the tooltip if hovering over a button
	if (FriendsTooltip.button == button) or (GetMouseFocus() == button) then
		button:OnEnter();
	end

	-- show cross faction helptip on first online cross faction friend
	if hasTravelPassButton and isCrossFactionInvite and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_CROSS_FACTION_INVITE) then
		local helpTipInfo = {
			text = CROSS_FACTION_INVITE_HELPTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_CROSS_FACTION_INVITE,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			alignment = HelpTip.Alignment.Left,
		};
		crossFactionHelpTipInfo = helpTipInfo;
		crossFactionHelpTipButton = button;
		HelpTip:Show(FriendsFrame, helpTipInfo, button.travelPassButton);
	end
	-- update invite button atlas to show faction for cross faction players, or reset to default for same faction players
	if hasTravelPassButton then
		if isCrossFactionInvite and inviteFaction == "Horde" then
			button.travelPassButton.NormalTexture:SetAtlas("friendslist-invitebutton-horde-normal");
			button.travelPassButton.PushedTexture:SetAtlas("friendslist-invitebutton-horde-pressed");
			button.travelPassButton.DisabledTexture:SetAtlas("friendslist-invitebutton-horde-disabled");
		elseif isCrossFactionInvite and inviteFaction == "Alliance" then
			button.travelPassButton.NormalTexture:SetAtlas("friendslist-invitebutton-alliance-normal");
			button.travelPassButton.PushedTexture:SetAtlas("friendslist-invitebutton-alliance-pressed");
			button.travelPassButton.DisabledTexture:SetAtlas("friendslist-invitebutton-alliance-disabled");
		else
			button.travelPassButton.NormalTexture:SetAtlas("friendslist-invitebutton-default-normal");
			button.travelPassButton.PushedTexture:SetAtlas("friendslist-invitebutton-default-pressed");
			button.travelPassButton.DisabledTexture:SetAtlas("friendslist-invitebutton-default-disabled");
		end
	end
	return height;
end

function FriendsList_Update(forceUpdate)
	local numBNetTotal, numBNetOnline, numBNetFavorite, numBNetFavoriteOnline = BNGetNumFriends()
	local numBNetOffline = numBNetTotal - numBNetOnline
	local numBNetFavoriteOffline = numBNetFavorite - numBNetFavoriteOnline
	local numWoWTotal = C_FriendList.GetNumFriends()
	local numWoWOnline = C_FriendList.GetNumOnlineFriends()
	local numWoWOffline = numWoWTotal - numWoWOnline
	local dataProvider = CreateDataProvider()
	local retainScrollPosition = not forceUpdate
	
	if (not FriendsListFrame:IsShown() and not forceUpdate) then
		return
	end
	
	wipe(groupsTotal)
	wipe(groupsSorted)
	wipe(groupsCount)
	
	-- invites
	local numInvites = BNGetNumFriendInvites()
	if ( numInvites > 0 ) then
		table.insert(friendsListData, {buttonType=FRIENDS_BUTTON_TYPE_INVITE_HEADER})
		if ( not GetCVarBool("friendInvitesCollapsed") ) then
			for i = 1, numInvites do
				dataProvider:Insert({id=i, buttonType=FRIENDS_BUTTON_TYPE_INVITE})
			end
		end
	end

	local bnetFriendIndex = 0;
	-- favorite friends, online and offline
	for i = 1, numBNetFavorite do
		bnetFriendIndex = bnetFriendIndex + 1;
		FriendGroups_SetGroups(bnetFriendIndex, FRIENDS_BUTTON_TYPE_BNET, true)
	end

	-- online Battlenet friends
	for i = 1, numBNetOnline - numBNetFavoriteOnline do
		bnetFriendIndex = bnetFriendIndex + 1
		FriendGroups_SetGroups(bnetFriendIndex, FRIENDS_BUTTON_TYPE_BNET)
	end
	-- online WoW friends
	for i = 1, numWoWOnline do
		FriendGroups_SetGroups(i, FRIENDS_BUTTON_TYPE_WOW)
	end

	-- offline Battlenet friends
	for i = 1, numBNetOffline - numBNetFavoriteOffline do
		bnetFriendIndex = bnetFriendIndex + 1
		FriendGroups_SetGroups(bnetFriendIndex, FRIENDS_BUTTON_TYPE_BNET)
	end
	-- offline WoW friends
	for i = 1, numWoWOffline do
		FriendGroups_SetGroups(i+numWoWOnline, FRIENDS_BUTTON_TYPE_WOW)
	end
	
	--[[
	if FriendGroups_SavedVars.show_search then
		dataProvider:Insert({buttonType = FRIENDS_BUTTON_TYPE_DIVIDER, groupName = "Search..."})
	end
	]]--
	
	table.sort(groupsSorted, FriendGroups_SortGroupsCustom)
	
	for _, groupName in ipairs(groupsSorted) do
		if FriendGroups_SavedVars.collapsed[groupName] == nil then
			FriendGroups_SavedVars.collapsed[groupName] = true
		end
		
		dataProvider:Insert({buttonType = FRIENDS_BUTTON_TYPE_DIVIDER, groupName = groupName})
		
		if not FriendGroups_SavedVars.collapsed[groupName] then
			if FriendGroups_SavedVars.sort_by_status then
				table.sort(groupsTotal[groupName], FriendGroups_SortTableByStatus)
			end
			
			for _, playerData in ipairs(groupsTotal[groupName]) do
				if playerData.buttonType and playerData.id then
					dataProvider:Insert({id=playerData.id, buttonType=playerData.buttonType})
				end
			end
		end
	end
	
	FriendsListFrame.ScrollBox:SetDataProvider(dataProvider, retainScrollPosition)
	
	-- Cleanup
	for groupName, _ in pairs(FriendGroups_SavedVars.collapsed) do
		if not groupsTotal[groupName] then
			FriendGroups_SavedVars.collapsed[groupName] = nil
		end
	end
end

function FriendsList_UpdateDividerTemplate(frame, elementData)
	local groupName = elementData.groupName
	local groupOnline = groupsCount[groupName] and groupsCount[groupName]["Online"] or 0
	local groupTotal = groupsCount[groupName] and groupsCount[groupName]["Total"] or 0
	
	if groupName and frame.name then
		if searchOpened and groupName == "Search..." then
			--[[
			frame.name:SetText("")
			local searchBox = CreateFrame("EditBox", "FriendGroupsSearch", frame:GetParent())
			searchBox:SetSize((frame:GetParent():GetWidth() / 1.5), frame:GetParent():GetHeight())
			searchBox:SetFontObject("ChatFontNormal")
			searchBox:SetScript("OnEscapePressed", function()
				searchBox:Hide()
				searchOpened = false
				searchValue = ""
				FriendsList_Update()
			end)
			searchBox:SetScript("OnEditFocusLost", function()
				searchBox:Hide()
				searchOpened = false
				searchValue = ""
				FriendsList_Update()
			end)
			searchBox:SetScript("OnEnterPressed", function()
				searchBox:Hide()
				searchOpened = false
				FriendsList_Update()
			end)
			searchBox:SetScript("OnTextChanged", function(searchBox)
				local textValue = searchBox:GetText()

				if textValue then
					searchValue = textValue
					FriendsList_Update()
				end
			end)
			
			searchBox:SetPoint("CENTER", frame, "CENTER");
			searchBox:SetAutoFocus(false)
			searchBox:SetCursorPosition(1)
			searchBox:SetFocus(true)
			searchBox:SetText(searchValue)
			]]--
		else
			frame.name:SetText(groupName)
			if groupName ~= "Search..." then
				local groupInfo = string.format("%d/%d", groupOnline, groupTotal)
			
				if frame.info then
					frame.info:SetText(groupInfo)
				end
				
				if FriendGroups_SavedVars.collapsed[groupName] then
					frame.collapseButton.status:SetTexture("Interface\\Buttons\\UI-PlusButton-UP")
				else
					frame.collapseButton.status:SetTexture("Interface\\Buttons\\UI-MinusButton-UP")
				end
			else
				frame.collapseButton.status:SetTexture("")
			end
		end
		
	end
end

function FriendGroups_FrameFriendDividerTemplateCollapseClick(self, button, down)
	local groupName = self and self:GetParent() and self:GetParent().name and self:GetParent().name:GetText() or self.name and self.name:GetText()
	
	FriendGroups_SavedVars.collapsed[groupName] = not FriendGroups_SavedVars.collapsed[groupName]
	
	-- Workaround thanks to scrolling issues...
	
	for collapseGroupName, _ in pairs(FriendGroups_SavedVars.collapsed) do
		if groupName ~= collapseGroupName then FriendGroups_SavedVars.collapsed[collapseGroupName] = true end
	end
	
	-- Workaround end
	
	FriendsList_Update()
end

function FriendGroups_FrameFriendDividerTemplateHeaderClick(self, button, down)
	local groupName = self and self:GetParent() and self:GetParent().name and self:GetParent().name:GetText() or self.name and self.name:GetText()
	
	if button == "LeftButton" and groupName == "Search..." then
		searchOpened = true
		FriendsList_Update()
	elseif button == "RightButton" and groupName ~= "Search..." then
		ToggleDropDownMenu(1, self, FriendGroups_Menu, "cursor", 0, 0)
	else
		FriendGroups_FrameFriendDividerTemplateCollapseClick(self, button, down)
	end
end

--[[
	Init Addon
]]--

local frame = CreateFrame("frame", "FriendGroups")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		local view = CreateScrollBoxListLinearView();
	
		view:SetElementFactory(function(factory, elementData)
			local buttonType = elementData.buttonType;
			if buttonType == FRIENDS_BUTTON_TYPE_DIVIDER then
				factory("FriendGroupsFrameFriendDividerTemplate", FriendsList_UpdateDividerTemplate);
			elseif buttonType == FRIENDS_BUTTON_TYPE_INVITE_HEADER then
				factory("FriendsPendingInviteHeaderButtonTemplate", FriendsFrame_UpdateFriendInviteHeaderButton);
			elseif buttonType == FRIENDS_BUTTON_TYPE_INVITE then
				factory("FriendsFrameFriendInviteTemplate", FriendsFrame_UpdateFriendInviteButton);
			else
				factory("FriendGroupsFriendsListButtonTemplate", FriendsList_UpdateFriendButton);
			end
		end);
		
		ScrollUtil.InitScrollBoxListWithScrollBar(FriendsListFrame.ScrollBox, FriendsListFrame.ScrollBar, view);
		
		hooksecurefunc("FriendsList_Update", FriendsList_Update)
		hooksecurefunc("FriendsFrame_UpdateFriendButton", FriendsList_UpdateFriendButton)
		hooksecurefunc("FriendsFrameBNDropDown_Initialize", FriendGroups_AddDropDown)
		hooksecurefunc("FriendsFrameBNOfflineDropDown_Initialize", FriendGroups_AddDropDown)
		hooksecurefunc("FriendsFrameDropDown_Initialize", FriendGroups_AddDropDown)
		hooksecurefunc("FriendsFrameOfflineDropDown_Initialize", FriendGroups_AddDropDown)
		
		if not FriendGroups_SavedVars then
			FriendGroups_SavedVars = {
				collapsed = {},
				hide_offline = false,
				colour_classes = true,
				gray_faction = false,
				hide_high_level = false,
				show_mobile_afk = false,
				add_mobile_text = false,
				ingame_only = false,
				ingame_retail = false,
				show_btag = false,
				sort_by_status = false,
				show_retail = false,
				show_faction_icons = true,
				show_search = false
			}
		end
		
		-- Migrate collapsed to only have one false value at a time
		local notCollapsed = {}
		for groupName, collapsed in pairs(FriendGroups_SavedVars.collapsed) do
			if not collapsed then
				table.insert(notCollapsed, groupName)
			end
		end
		
		table.sort(notCollapsed)
		
		if #notCollapsed > 1 then
			FriendGroups_SavedVars.collapsed[notCollapsed[1]] = false
			for i = 2, #notCollapsed do
				FriendGroups_SavedVars.collapsed[notCollapsed[i]] = true
			end
		end
	end
end)