BlackList = {};

BlackList_Blocked_Channels = {"SAY", "YELL", "WHISPER", "PARTY", "RAID", "RAID_WARNING", "GUILD", "OFFICER", "EMOTE", "TEXT_EMOTE", "CHANNEL", "CHANNEL_JOIN", "CHANNEL_LEAVE"};

Already_Warned_For = {};
Already_Warned_For["WHISPER"] = {};
Already_Warned_For["TARGET"] = {};
Already_Warned_For["PARTY_INVITE"] = {};
Already_Warned_For["PARTY"] = {};
Already_Warned_For["MOUSEOVER"] = {};

BlackListedPlayers = {};

local SLASH_TYPE_ADD = 1;
local SLASH_TYPE_REMOVE = 2;

-- Function to handle onload event
function BlackList:OnLoad()

	-- constructions
	self:InsertUI();
	self:RegisterEvents();
	self:HookFunctions();
	self:RegisterSlashCmds();

	FriendsFrameOptionsButton:Disable();
	FriendsFrameShareListButton:Disable();

end

-- Registers events to be recieved
function BlackList:RegisterEvents()

	local frame = getglobal("BlackListTopFrame");

	-- register events
	frame:RegisterEvent("VARIABLES_LOADED");
	frame:RegisterEvent("PLAYER_TARGET_CHANGED");
	frame:RegisterEvent("PARTY_INVITE_REQUEST");
	frame:RegisterEvent("PARTY_MEMBERS_CHANGED");
	frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");

end

local Orig_ChatFrame_MessageEventHandler;
-- Hooks onto the functions needed
function BlackList:HookFunctions()

	Orig_ChatFrame_MessageEventHandler = ChatFrame_MessageEventHandler;
	ChatFrame_MessageEventHandler = BlackList_MessageEventHandler;

end

-- Hooked ChatFrame_MessageEventHandler function
function BlackList_MessageEventHandler(event)

	local warnplayer, warnname = false, nil;

	if (strsub(event, 1, 8) == "CHAT_MSG") then
		local type = strsub(event, 10);

		for key, channel in pairs(BlackList_Blocked_Channels) do
			if (type == channel) then
				-- search for player name
				local name = arg2;
				if (BlackList:GetIndexByName(name) > 0) then
					local player = BlackList:GetPlayerByIndex(BlackList:GetIndexByName(name));
					if (player["ignore"]) then
						-- respond to whisper
						if (type == "WHISPER" and name ~= UnitName("player")) then
							SendChatMessage(PLAYER_IGNORING, "WHISPER", nil, name);
						end
						-- block communication
						return;
					elseif (player["warn"]) then
						-- warn player
						if (type == "WHISPER") then
							local alreadywarned = false;

							for key, warnedname in pairs(Already_Warned_For["WHISPER"]) do
								if (name == warnedname) then
									alreadywarned = true;
								end
							end

							if (not alreadywarned) then
								table.insert(Already_Warned_For["WHISPER"], name);
								warnplayer = true;
								warnname = name;
							end
						end
					end
				end
			end
		end
	end

	local returnvalue = Orig_ChatFrame_MessageEventHandler(event);

	if (warnplayer) then
		this:AddMessage(warnname .. " is on your blacklist", 1.0, 0.0, 0.0);
	end

	return returnvalue;

end

-- Registers slash cmds
function BlackList:RegisterSlashCmds()

	SlashCmdList["BlackList"]   = function(args)
							BlackList:HandleSlashCmd(SLASH_TYPE_ADD, args)
						end;
	SLASH_BlackList1 = "/blacklist";
	SLASH_BlackList2 = "/bl";

	SlashCmdList["RemoveBlackList"]   = function(args)
								BlackList:HandleSlashCmd(SLASH_TYPE_REMOVE, args)
							end;
	SLASH_RemoveBlackList1 = "/removeblacklist";
	SLASH_RemoveBlackList2 = "/removebl";

end

-- Handles the slash cmds
function BlackList:HandleSlashCmd(type, args)

	if (type == SLASH_TYPE_ADD) then
		if (args == "") then
			self:AddPlayer("target");
		else
			local name = args;
			local reason = "";
			local index = string.find(args, " ", 1, true);
			if (index) then
				-- space found, have reason in args
				name = string.sub(args, 1, index - 1);
				reason = string.sub(args, index + 1);
			end

			self:AddPlayer(name, nil, nil, reason);
		end
	elseif (type == SLASH_TYPE_REMOVE) then
		if (args == "") then
			self:RemovePlayer("target");
		else
			self:RemovePlayer(args);
		end
	end

end

-- Function to handle events
function BlackList:HandleEvent(event)

	if (event == "VARIABLES_LOADED") then
		if (not BlackListedPlayers[GetRealmName()]) then
			BlackListedPlayers[GetRealmName()] = {};
		end
	elseif (event == "PLAYER_TARGET_CHANGED") then
		-- search for player name
		local name = UnitName("target");
		local faction, localizedFaction = UnitFactionGroup("target");
		if (BlackList:GetIndexByName(name) > 0) then
			local player = BlackList:GetPlayerByIndex(BlackList:GetIndexByName(name));

			if (player["warn"]) then
				-- warn player
				local alreadywarned = false;

				for warnedname, timepassed in pairs(Already_Warned_For["TARGET"]) do
					if ((name == warnedname) and (GetTime() < timepassed+10)) then
						alreadywarned = true;
					end
				end

				if (not alreadywarned) then
					Already_Warned_For["TARGET"][name]=GetTime();
					PlaySound("PVPTHROUGHQUEUE");
					BlackList:AddErrorMessage(name .. " is on your blacklist", "red", 5);
					BlackList:AddMessage(name .. " is on your blacklist for reason: " .. player["reason"], "yellow");
				end
			end
		end
	elseif (event == "UPDATE_MOUSEOVER_UNIT") then
		-- search for player name
		local name = UnitName("mouseover");
		local faction, localizedFaction = UnitFactionGroup("mouseover");
		if (BlackList:GetIndexByName(name) > 0) then
			local player = BlackList:GetPlayerByIndex(BlackList:GetIndexByName(name));

			if (player["warn"]) then
				-- warn player
				local alreadywarned = false;

				for warnedname, timepassed in pairs(Already_Warned_For["MOUSEOVER"]) do
					if ((name == warnedname) and (GetTime() < timepassed+10)) then
						alreadywarned = true;
					end
				end

				if (not alreadywarned) then
					Already_Warned_For["MOUSEOVER"][name]=GetTime();
					PlaySound("PVPTHROUGHQUEUE");
					BlackList:AddErrorMessage(name .. " is on your blacklist", "red", 5);
					BlackList:AddMessage(name .. " is on your blacklist for reason: " .. player["reason"], "yellow");
				end
			end
		end
	elseif (event == "PARTY_INVITE_REQUEST") then
		-- search for player name
		local name = arg1;
		if (BlackList:GetIndexByName(name) > 0) then
			local player = BlackList:GetPlayerByIndex(BlackList:GetIndexByName(name));

			if (player["ignore"]) then
				-- decline party invite
				DeclineGroup();
				StaticPopup_Hide("PARTY_INVITE");
			elseif (player["warn"]) then
				-- warn player
				local alreadywarned = false;

				for key, warnedname in pairs(Already_Warned_For["PARTY_INVITE"]) do
					if (name == warnedname) then
						alreadywarned = true;
					end
				end

				if (not alreadywarned) then
					table.insert(Already_Warned_For["PARTY_INVITE"], name);
					BlackList:AddErrorMessage(name .. " is on your blacklist", "red", 10);
				end
			end
		end
	elseif (event == "PARTY_MEMBERS_CHANGED") then
		for i = 0, GetNumPartyMembers(), 1 do
			-- search for player name
			local name = UnitName("party" .. i);
			if (BlackList:GetIndexByName(name) > 0) then
				local player = BlackList:GetPlayerByIndex(BlackList:GetIndexByName(name));

				if (player["warn"]) then
					-- warn player
					local alreadywarned = false;

					for key, warnedname in pairs(Already_Warned_For["PARTY"]) do
						if (name == warnedname) then
							alreadywarned = true;
						end
					end

					if (not alreadywarned) then
						table.insert(Already_Warned_For["PARTY"], name);
						BlackList:AddMessage(name .. " is on your blacklist", "red");
					end
				end
			end
		end
	end

end

-- Blacklists the given player, sets the ignore flag to be 'ignore' and enters the given reason
function BlackListPlayer(player, ignore, reason)

	BlackList:AddPlayer(player, ignore, reason);

end