local Quest = {}
Quest.__index = Quest

local function getGameAPI()
	return getgenv().BH_GameAPI
end

Quest.Data = {
	LevelRanges = {
		{Min = 1, Max = 10, QuestId = "Bandit", QuestName = "Bandit"},
		{Min = 11, Max = 20, QuestId = "Monkey", QuestName = "Monkey"},
		{Min = 21, Max = 30, QuestId = "Gorilla", QuestName = "Gorilla"},
		{Min = 30, Max = 50, QuestId = "Pirate", QuestName = "Pirate"},
		{Min = 50, Max = 75, QuestId = "Brute", QuestName = "Brute"},
		{Min = 75, Max = 100, QuestId = "Desert Bandit", QuestName = "Desert Bandit"},
		{Min = 100, Max = 130, QuestId = "Desert Officer", QuestName = "Desert Officer"},
		{Min = 130, Max = 160, QuestId = "Snow Bandit", QuestName = "Snow Bandit"},
		{Min = 160, Max = 190, QuestId = "Snow Marine", QuestName = "Snow Marine"},
		{Min = 190, Max = 230, QuestId = "Snow Naval", QuestName = "Snow Naval"},
		{Min = 230, Max = 260, QuestId = "Snow Mountain", QuestName = "Snow Mountain"},
		{Min = 260, Max = 300, QuestId = "Chief Marine", QuestName = "Chief Marine"},
		{Min = 300, Max = 350, QuestId = "Sky Marine", QuestName = "Sky Marine"},
		{Min = 350, Max = 400, QuestId = "Sky Soldier", QuestName = "Sky Soldier"},
		{Min = 400, Max = 450, QuestId = "Sky Guard", QuestName = "Sky Guard"},
		{Min = 450, Max = 475, QuestId = "Sky Officer", QuestName = "Sky Officer"},
		{Min = 475, Max = 500, QuestId = "Sky Bandit", QuestName = "Sky Bandit"},
		{Min = 500, Max = 550, QuestId = "Steam Marine", QuestName = "Steam Marine"},
		{Min = 550, Max = 575, QuestId = "Steam Soldier", QuestName = "Steam Soldier"},
		{Min = 575, Max = 600, QuestId = "Steam Officer", QuestName = "Steam Officer"},
		{Min = 600, Max = 650, QuestId = "Steam Bandit", QuestName = "Steam Bandit"},
		{Min = 650, Max = 675, QuestId = "Frost Pirate", QuestName = "Frost Pirate"},
		{Min = 675, Max = 700, QuestId = "Frost Soldier", QuestName = "Frost Soldier"},
		{Min = 700, Max = 750, QuestId = "Frost Guard", QuestName = "Frost Guard"},
		{Min = 750, Max = 800, QuestId = "Frost Bandit", QuestName = "Frost Bandit"},
		{Min = 800, Max = 850, QuestId = "Ice Marine", QuestName = "Ice Marine"},
		{Min = 850, Max = 875, QuestId = "Ice Soldier", QuestName = "Ice Soldier"},
		{Min = 875, Max = 900, QuestId = "Ice Guard", QuestName = "Ice Guard"},
		{Min = 900, Max = 950, QuestId = "Ice Bandit", QuestName = "Ice Bandit"},
		{Min = 950, Max = 1000, QuestId = "Ice Marine 2", QuestName = "Ice Marine 2"},
		{Min = 1000, Max = 1050, QuestId = "Ice Soldier 2", QuestName = "Ice Soldier 2"},
		{Min = 1050, Max = 1100, QuestId = "Ice Guard 2", QuestName = "Ice Guard 2"},
		{Min = 1100, Max = 1150, QuestId = "Ice Bandit 2", QuestName = "Ice Bandit 2"},
		{Min = 1150, Max = 1200, QuestId = "Ice Officer", QuestName = "Ice Officer"},
		{Min = 1200, Max = 1250, QuestId = "Ice Pirate", QuestName = "Ice Pirate"},
		{Min = 1250, Max = 1300, QuestId = "Ice Marine 3", QuestName = "Ice Marine 3"},
		{Min = 1300, Max = 1350, QuestId = "Ice Soldier 3", QuestName = "Ice Soldier 3"},
		{Min = 1350, Max = 1400, QuestId = "Ice Guard 3", QuestName = "Ice Guard 3"},
		{Min = 1400, Max = 1450, QuestId = "Ice Bandit 3", QuestName = "Ice Bandit 3"},
		{Min = 1450, Max = 1500, QuestId = "Ice Marine 4", QuestName = "Ice Marine 4"},
		{Min = 1500, Max = 1550, QuestId = "Ice Officer 2", QuestName = "Ice Officer 2"},
		{Min = 1550, Max = 1600, QuestId = "Ice Pirate 2", QuestName = "Ice Pirate 2"},
		{Min = 1600, Max = 1650, QuestId = "Magma Marine", QuestName = "Magma Marine"},
		{Min = 1650, Max = 1700, QuestId = "Magma Soldier", QuestName = "Magma Soldier"},
		{Min = 1700, Max = 1750, QuestId = "Magma Bandit", QuestName = "Magma Bandit"},
		{Min = 1750, Max = 1800, QuestId = "Magma Pirate", QuestName = "Magma Pirate"},
		{Min = 1800, Max = 1850, QuestId = "Fishman Marine", QuestName = "Fishman Marine"},
		{Min = 1850, Max = 1900, QuestId = "Fishman Soldier", QuestName = "Fishman Soldier"},
		{Min = 1900, Max = 1950, QuestId = "Fishman Guard", QuestName = "Fishman Guard"},
		{Min = 1950, Max = 2000, QuestId = "Fishman Bandit", QuestName = "Fishman Bandit"},
		{Min = 2000, Max = 2050, QuestId = "Sky Island Marine", QuestName = "Sky Island Marine"},
		{Min = 2050, Max = 2100, QuestId = "Sky Island Soldier", QuestName = "Sky Island Soldier"},
		{Min = 2100, Max = 2150, QuestId = "Sky Island Guard", QuestName = "Sky Island Guard"},
		{Min = 2150, Max = 2200, QuestId = "Sky Island Bandit", QuestName = "Sky Island Bandit"},
		{Min = 2200, Max = 2250, QuestId = "Udon Marine", QuestName = "Udon Marine"},
		{Min = 2250, Max = 2300, QuestId = "Udon Soldier", QuestName = "Udon Soldier"},
		{Min = 2300, Max = 2350, QuestId = "Udon Bandit", QuestName = "Udon Bandit"},
		{Min = 2350, Max = 2400, QuestId = "Wano Marine", QuestName = "Wano Marine"},
		{Min = 2400, Max = 2450, QuestId = "Wano Soldier", QuestName = "Wano Soldier"},
		{Min = 2450, Max = 2500, QuestId = "Wano Guard", QuestName = "Wano Guard"},
		{Min = 2500, Max = 2600, QuestId = "Hydra Marine", QuestName = "Hydra Marine"},
		{Min = 2600, Max = 2700, QuestId = "Treaty Marine", QuestName = "Treaty Marine"},
		{Min = 2700, Max = 2800, QuestId = "Leviathan Marine", QuestName = "Leviathan Marine"},
	},
}

function Quest:GetPlayerLevel()
	local api = getGameAPI()
	if not api then return 0 end
	local stats = api:GetPlayerStats()
	return stats.Level or 0
end

function Quest:GetCurrentQuest()
	local api = getGameAPI()
	if not api then return nil end
	return api:GetQuestData()
end

function Quest:GetQuestForLevel(level)
	level = level or self:GetPlayerLevel()
	for _, range in ipairs(self.Data.LevelRanges) do
		if level >= range.Min and level <= range.Max then
			return {
				QuestId = range.QuestId,
				QuestName = range.QuestName,
				MinLevel = range.Min,
				MaxLevel = range.Max,
			}
		end
	end
	return nil
end

function Quest:StartQuest(questId, questName)
	local api = getGameAPI()
	if not api then return nil end
	return api:Quest(questId, questName)
end

function Quest:GetNearestMobForQuest()
	local api = getGameAPI()
	if not api then return nil end

	local questData = self:GetCurrentQuest()
	if questData and questData.TargetName then
		local mob = api:FindMob(questData.TargetName)
		if mob then return mob, questData end
	end

	local questInfo = self:GetQuestForLevel(self:GetPlayerLevel())
	if questInfo then
		local mob = api:FindMob(questInfo.QuestName)
		return mob, questInfo
	end
	return nil, nil
end

function Quest:CanStartNewQuest()
	local questData = self:GetCurrentQuest()
	if not questData then return true end
	local progress = questData.Progress or 0
	local goal = questData.Goal or questData.TargetCount or 1
	return progress >= goal
end

return Quest