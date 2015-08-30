function BlackList:AddPlayer(player, warn, ignore, reason)

	-- handle player
	if (player == "" or player == nil) then
		return;
	elseif (player == "target") then
		if (UnitIsPlayer("target")) then
			name = UnitName("target");
			level = UnitLevel("target") .. "";
			class = UnitClass("target");
			race, raceEn = UnitRace("target");
		else
			StaticPopup_Show("BLACKLIST_PLAYER");
			return;
		end
	else
		name = player;
		level = "";
		class = "";
		race = "";
	end
	if (self:GetIndexByName(name) > 0) then
		self:AddMessage(name .. " " .. ALREADY_BLACKLISTED, "yellow");
		return;
	end

	-- handle warn
	if (warn == nil) then
		warn = true;
	end

	-- handle ignore
	if (ignore == nil or ignore == "") then
		ignore = false;
	end

	-- handle reason
	if (reason == nil) then
		reason = "";
	end

	-- timestamp
	added = time();

	-- lower the name and upper the first letter, not for chinese and korean though
	if ((GetLocale() ~= "zhTW") and (GetLocale() ~= "zhCN") and (GetLocale() ~= "koKR")) then
		local _, len = string.find(name, "[%z\1-\127\194-\244][\128-\191]*");
		name = string.upper(string.sub(name, 1, len)) .. string.lower(string.sub(name, len + 1));
	end
	
	player = {["name"] = name, ["warn"] = warn, ["ignore"] = ignore, ["reason"] = reason, ["added"] = added, ["level"] = level, ["class"] = class, ["race"] = race};
	table.insert(BlackListedPlayers[GetRealmName()], player);

	self:AddMessage(name .. " " .. ADDED_TO_BLACKLIST, "yellow");

	self:UpdateUI();

end

function BlackList:RemovePlayer(player)

	-- handle player
	if (player == "target") then
		name = UnitName("target");
	else
		name = player;
	end

	if (name == nil) then
		index = self:GetSelectedBlackList();
	else
		index = self:GetIndexByName(name);
	end

	if (index == 0) then
		self:AddMessage(PLAYER_NOT_FOUND, "yellow");
		return;
	end

	name = self:GetNameByIndex(index);

	table.remove(BlackListedPlayers[GetRealmName()], index);

	self:AddMessage(name .. " " .. REMOVED_FROM_BLACKLIST, "yellow");

	self:UpdateUI();

end

function BlackList:UpdateDetails(index, ignore, warn, reason, level, class, race)

	-- update player
	local player = self:GetPlayerByIndex(index);
	-- for old version i have to convert old name format (there was no format...) in new "Name" format
	if ((GetLocale() ~= "zhTW") and (GetLocale() ~= "zhCN") and (GetLocale() ~= "koKR")) then
		local _, len = string.find(player["name"], "[%z\1-\127\194-\244][\128-\191]*");
		player["name"] = string.upper(string.sub(player["name"], 1, len)) .. string.lower(string.sub(player["name"], len + 1));
	end
	if (ignore ~= nil) then
		player["ignore"] = ignore:GetChecked();
	end
	if (warn ~= nil) then
		player["warn"] = warn:GetChecked();
	end
	if (reason ~= nil) then
		player["reason"] = reason;
	end
	if (level ~= nil) then
		player["level"] = level;
	end
	if (class ~= nil) then
		player["class"] = class;
	end
	if (race ~= nil) then
		player["race"] = race;
	end

	table.remove(BlackListedPlayers[GetRealmName()], index);
	table.insert(BlackListedPlayers[GetRealmName()], index, player);

end

-- Returns the number of blacklisted players
function BlackList:GetNumBlackLists()

	return table.getn(BlackListedPlayers[GetRealmName()]);

end

-- Returns the index of the player given by name
function BlackList:GetIndexByName(name)

	for i = 1, self:GetNumBlackLists() do
		if (self:GetNameByIndex(i) == name) then
			return i
		end
	end

	return 0

end

-- Returns the name of the player given by index
function BlackList:GetNameByIndex(index)

	if (index < 1 or index > self:GetNumBlackLists()) then
		return nil;
	end

	player = BlackListedPlayers[GetRealmName()][index];
	return player["name"];

end

-- Returns the player object given by index
function BlackList:GetPlayerByIndex(index)

	if (index < 1 or index > self:GetNumBlackLists()) then
		return nil
	end

	player = BlackListedPlayers[GetRealmName()][index];
	return player;

end

function BlackList:AddMessage(msg, color)

	local r = 0.0; g = 0.0; b = 0.0;

	if (color == "red") then
		r = 1.0; g = 0.0; b = 0.0;
	elseif (color == "yellow") then
		r = 1.0; g = 1.0; b = 0.0;
	end

	if (DEFAULT_CHAT_FRAME) then
		DEFAULT_CHAT_FRAME:AddMessage(msg, r, g, b);
	end

end

function BlackList:AddErrorMessage(msg, color, timeout)

	local r = 0.0; g = 0.0; b = 0.0;

	if (color == "red") then
		r = 1.0; g = 0.0; b = 0.0;
	elseif (color == "yellow") then
		r = 1.0; g = 1.0; b = 0.0;
	end

	if (DEFAULT_CHAT_FRAME) then
		UIErrorsFrame:AddMessage(msg, r, g, b, nil, timeout);
	end

end

function GetFaction(race, returnText)

	local factions = {"Alliance", "Horde", "Unknown"};
	local faction = 0;

	if	     (race == "Human" or
			race == "Dwarf" or
			race == "Night Elf" or
			race == "Gnome" or
			race == "Draenei") then
		faction = 1;
	elseif     (race == "Orc" or
			race == "Undead" or
			race == "Tauren" or
			race == "Troll" or
			race == "Blood Elf") then
		faction = 2;
	else
		faction = 3;
	end

	if (returnText) then
		return factions[faction];
	else
		return faction;
	end

end