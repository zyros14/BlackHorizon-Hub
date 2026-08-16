local Raid = {}
Raid.__index = Raid

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local function getGameAPI()
	return getgenv().BH_GameAPI
end

local function getCombat()
	return getgenv().BH_Combat
end

Raid.Config = {
	Enabled = false,
	AutoStart = true,
	Intervale = 5,
	Difficulty = "Hard",
	TweenSpeed = 280,
	AutoKick = false,
}

Raid.State = {
	Active = false,
	CurrentRaid = nil,
	LastRaidCheck = 0,
	CompletedAt = {},
}

Raid.AvailableRaids = {
	{Name = "Rumble", Tier = 1},
	{Name = "Phoenix", Tier = 2},
	{Name = "Dough", Tier = 3},
	{Name = "Dark", Tier = 3},
	{Name = "Ice", Tier = 3},
	{Name = "Quake", Tier = 3},
}

function Raid:Start()
	self:Stop()
	self.State.Active = true

	self._loopConn = RunService.Heartbeat:Connect(function()
		self:_runRaidLoop()
	end)
end

function Raid:Stop()
	self.State.Active = false
	if self._loopConn then
		self._loopConn:Disconnect()
		self._loopConn = nil
	end
end

function Raid:_runRaidLoop()
	pcall(function()
		self:_runRaidLoopSafe()
	end)
end

function Raid:_runRaidLoopSafe()
	if not self.Config.Enabled or not self.State.Active then return end

	local tickNow = tick()
	if tickNow - (self.State.LastRaidCheck or 0) < (self.Config.Intervale or 5) then return end
	self.State.LastRaidCheck = tickNow

	local api = getGameAPI()
	if not api then return end

	if self:IsInRaid() then
		self:_runCombat(api)
	else
		local selectedRaid = self:GetBestRaid()
		if selectedRaid then
			self:_startRaid(api, selectedRaid)
		end
	end
end

function Raid:_startRaid(api, raid)
	local success = pcall(function()
		api:InitiateRaid(raid.Name)
	end)

	if success then
		self.State.CurrentRaid = raid
		task.wait(2)
		self:_runCombat(api)
	end
end

function Raid:_runCombat(api)
	local Combat = getCombat()
	local mobs = api:GetMobs()
	if #mobs == 0 then return end

	local player = Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local closest = nil
	local closestDist = math.huge

	for _, mob in ipairs(mobs) do
		local mobRoot = mob:FindFirstChild("HumanoidRootPart")
		if mobRoot then
			local dist = (root.Position - mobRoot.Position).magnitude
			if dist < closestDist then
				closest = mob
				closestDist = dist
			end
		end
	end

	if closest then
		if Combat then
			Combat:PerformCombo(closest)
			Combat:UseAllSkills(closest)
		end
		api:Attack(closest)
	end
end

function Raid:GetBestRaid()
	local available = {}
	for _, raid in ipairs(self.AvailableRaids) do
		local raidName = raid.Name
		if not self.State.CompletedAt[raidName] or tick() - self.State.CompletedAt[raidName] > 30 then
			table.insert(available, raid)
		end
	end

	if #available == 0 then return nil end
	return available[math.random(1, #available)]
end

function Raid:IsInRaid()
	local player = Players.LocalPlayer
	if player.Team and player.Team.Name:lower():find("raid") then
		return true
	end
	return false
end

return Raid