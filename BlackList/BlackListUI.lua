local SelectedIndex = 1;
BLACKLISTS_TO_DISPLAY = 18;
FRIENDS_FRAME_BLACKLIST_HEIGHT = 16;

Classes = {"", "Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior"};
Races = {"", "Human", "Dwarf", "Night Elf", "Gnome", "Draenei", "Orc", "Undead", "Tauren", "Troll", "Blood Elf"};

-- Phrase variables
PLAYER_IGNORING 			= "Player is ignoring you.";

PLAYER_NOT_FOUND			= "Player not found.";
ALREADY_BLACKLISTED		= "is already blacklisted.";
ADDED_TO_BLACKLIST		= "added to blacklist."
REMOVED_FROM_BLACKLIST		= "removed from blacklist."

BLACKLIST				= "BlackList";
BLACKLIST_PLAYER 			= "BlackList Player";
REMOVE_PLAYER 			= "Remove Player";
OPTIONS 				= "Options";
SHARE_LIST				= "Share List";

BLACK_LIST_DETAILS_OF		= "BlackList Details of";
LEVEL					= "Level";
BLACK_LISTED			= "BlackListed:";
IGNORE_PLAYER			= "Ignore Player";
WARN_ME				= "Warn Me";
REASON				= "Reason:";
IS_BLACKLISTED			= "is on your blacklist.";

BINDING_HEADER_BLACKLIST	= "BlackList";
BINDING_NAME_TOGGLE_BLACKLIST	= "Toggle BlackList";

-- Inserts all of the UI elements
function BlackList:InsertUI()

	-- Add tab buttons to Friends tab
	CreateFrame("Button", "FriendFrameToggleTab3", getglobal("FriendsListFrame"), "FriendsFrameToggleTab3");
	CreateFrame("Button", "IgnoreFrameToggleTab3", getglobal("IgnoreListFrame"), "IgnoreFrameToggleTab3");
	
	-- Add the tab itself
	table.insert(FRIENDSFRAME_SUBFRAMES, "BlackListFrame");
	CreateFrame("Frame", "BlackListFrame", getglobal("FriendsFrame"), "BlackListFrame");

	-- Create name prompt
	StaticPopupDialogs["BLACKLIST_PLAYER"] = {
		text = "Enter name of player to blacklist:",
		button1 = "Accept",
		button2 = "Cancel",
		OnShow = function()
			getglobal(this:GetName().."EditBox"):SetText("");
		end,
		OnAccept = function()
			BlackListPlayer(getglobal(this:GetParent():GetName().."EditBox"):GetText());
		end,
		hasEditBox = 1,
		timeout = 0,
		whileDead = 1,
		exclusive = 1,
		hideOnEscape = 1
		};

end

function BlackList:ClickBlackList()

	index = this:GetID();

	self:SetSelectedBlackList(index);

	self:UpdateUI();

	self:ShowDetails();

end

function BlackList:SetSelectedBlackList(index)

	SelectedIndex = index;

end

function BlackList:GetSelectedBlackList()

	return SelectedIndex;

end

function BlackList:ShowTab()

	FriendsFrameTopLeft:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft");
	FriendsFrameTopRight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight");
	FriendsFrameBottomLeft:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-BotLeft");
	FriendsFrameBottomRight:SetTexture("Interface\\FriendsFrame\\UI-FriendsFrame-BotRight");
	FriendsFrameTitleText:SetText("Black List");
	FriendsFrame_ShowSubFrame("BlackListFrame");
	self:UpdateUI();

end

function BlackList:ToggleTab()

	ToggleFriendsFrame();

	if (BlackListFrame:IsVisible()) then
		BlackListFrame:Hide();
	else
		BlackList:ShowTab();
	end

end

function BlackList:ShowDetails()

	-- get player
	local player = self:GetPlayerByIndex(self:GetSelectedBlackList());

	-- update details
	getglobal("BlackListDetailsName"):SetText(BLACK_LIST_DETAILS_OF .. " " .. player["name"]);

	local level, race = "", "";
	if (player["level"] == "" and player["class"] == "") then
		level = "Unknown Level, Class";
	elseif (player["level"] == "") then
		level = "Unknown Level " .. player["class"];
	elseif (player["class"] == "") then
		level = "Level " .. player["level"] .. " Unknown Class";
	else
		level = "Level " .. player["level"] .. " " .. player["class"];
	end
	if (player["race"] == "") then
		race = "Unknown Race";
	else
		race = player["race"];
	end
	getglobal("BlackListDetailsLevel"):SetText(level);
	getglobal("BlackListDetailsRace"):SetText(race);

	if (GetFaction(player["race"]) == 1) then
		getglobal("BlackListDetailsFactionInsignia"):SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp");
		getglobal("BlackListDetailsFactionInsignia"):SetTexCoord(0, 0.5, 0, 1);
	elseif (GetFaction(player["race"]) == 2) then
		getglobal("BlackListDetailsFactionInsignia"):SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp");
		getglobal("BlackListDetailsFactionInsignia"):SetTexCoord(0.5, 1, 0, 1);
	else
		getglobal("BlackListDetailsFactionInsignia"):SetTexture(0, 0, 0, 0);
	end

	local date = date("%I:%M%p on %b %d, 20%y", player["added"]);
	getglobal("BlackListDetailsBlackListedText"):SetText(date);

	-- update checkboxes
	getglobal("BlackListDetailsFrameCheckButton1Text"):SetText("  " .. IGNORE_PLAYER);
	getglobal("BlackListDetailsFrameCheckButton1"):SetChecked(player["ignore"]);
	getglobal("BlackListDetailsFrameCheckButton2Text"):SetText("  " .. WARN_ME);
	getglobal("BlackListDetailsFrameCheckButton2"):SetChecked(player["warn"]);

	-- update reason
	getglobal("BlackListDetailsFrameReasonTextBox"):SetText(player["reason"]);

	getglobal("BlackListDetailsFrame"):Show();
	getglobal("BlackListEditDetailsFrame"):Hide();

end

function BlackListEditDetailsFrame_Update()

	-- get player
	local player = BlackList:GetPlayerByIndex(BlackList:GetSelectedBlackList());

	BlackListEditDetailsFrameLevel:SetText(player["level"]);

	UIDropDownMenu_SetSelectedValue(BlackListEditDetailsFrameClassDropDown, player["class"]);

	UIDropDownMenu_SetSelectedValue(BlackListEditDetailsFrameRaceDropDown, player["race"]);

end

function BlackListEditDetailsFrameClassDropDown_OnLoad()

	UIDropDownMenu_SetWidth(70);
	UIDropDownMenu_SetButtonWidth(24);
	UIDropDownMenu_JustifyText("LEFT", BlackListEditDetailsFrameClassDropDown);

end

function BlackListEditDetailsFrameClassDropDown_Initialize()

	local info = UIDropDownMenu_CreateInfo();
	for i = 1, getn(Classes), 1 do
		info.text = Classes[i];
		info.value = Classes[i];
		info.func = BlackListEditDetailsFrameClassDropDown_OnClick;
		info.owner = this:GetParent();
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
	end

end

function BlackListEditDetailsFrameClassDropDown_OnClick()

	UIDropDownMenu_SetSelectedID(this.owner, this:GetID());
	UIDropDownMenu_SetSelectedValue(this.owner, this.value);

end

function BlackListEditDetailsFrameRaceDropDown_OnLoad()

	UIDropDownMenu_SetWidth(80);
	UIDropDownMenu_SetButtonWidth(24);
	UIDropDownMenu_JustifyText("LEFT", BlackListEditDetailsFrameRaceDropDown);

end

function BlackListEditDetailsFrameRaceDropDown_Initialize()

	local info = UIDropDownMenu_CreateInfo();
	for i = 1, getn(Races), 1 do
		info.text = Races[i];
		info.value = Races[i];
		info.func = BlackListEditDetailsFrameRaceDropDown_OnClick;
		info.owner = this:GetParent();
		info.checked = checked;
		UIDropDownMenu_AddButton(info);
	end

end

function BlackListEditDetailsFrameRaceDropDown_OnClick()

	UIDropDownMenu_SetSelectedID(this.owner, this:GetID());
	UIDropDownMenu_SetSelectedValue(this.owner, this.value);

end

function BlackListEditDetailsSaveButton_OnClick()

	local index = BlackList:GetSelectedBlackList();
	local level = BlackListEditDetailsFrameLevel:GetText();
	local class = UIDropDownMenu_GetSelectedValue(BlackListEditDetailsFrameClassDropDown);
	local race = UIDropDownMenu_GetSelectedValue(BlackListEditDetailsFrameRaceDropDown);

	BlackList:UpdateDetails(index, nil, nil, nil, level, class, race);
	getglobal("BlackListEditDetailsFrame"):Hide();
	BlackList:ShowDetails();

end

function BlackList_Update()

	BlackList:UpdateUI();

end

function BlackList:UpdateUI()

	local numBlackLists = BlackList:GetNumBlackLists();
	local nameText, name;
	local blacklistButton;
	local selectedBlackList = self:GetSelectedBlackList();

	if (numBlackLists > 0) then
		if (selectedBlackList == 0 or selectedBlackList > numBlackLists) then
			self:SetSelectedBlackList(1);
			selectedBlackList = 1;
		end
		FriendsFrameRemovePlayerButton:Enable();
	else
		FriendsFrameRemovePlayerButton:Disable();
	end

	local blacklistOffset = FauxScrollFrame_GetOffset(FriendsFrameBlackListScrollFrame);
	local blacklistIndex;
	for i=1, BLACKLISTS_TO_DISPLAY, 1 do
		blacklistIndex = i + blacklistOffset;
		nameText = getglobal("FriendsFrameBlackListButton" .. i .. "ButtonTextName");
		nameText:SetText(self:GetNameByIndex(blacklistIndex));
		blacklistButton = getglobal("FriendsFrameBlackListButton" .. i);
		blacklistButton:SetID(blacklistIndex);

		-- Update the highlight
		if (blacklistIndex == selectedBlackList) then
			blacklistButton:LockHighlight();
		else
			blacklistButton:UnlockHighlight();
		end

		if (blacklistIndex > numBlackLists) then
			blacklistButton:Hide();
		else
			blacklistButton:Show();
		end
	end

	-- ScrollFrame stuff
	FauxScrollFrame_Update(FriendsFrameBlackListScrollFrame, numBlackLists, BLACKLISTS_TO_DISPLAY, FRIENDS_FRAME_BLACKLIST_HEIGHT);

end