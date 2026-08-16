local GameAPI = {}
GameAPI.__index = GameAPI

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

GameAPI.Player = Players.LocalPlayer
GameAPI.Workspace = workspace

function GameAPI:GetRemotes()
	if self._remotes then return self._remotes end

	local cache = {}
	local rs = ReplicatedStorage

	local remotesFolder = rs:FindFirstChild("Remotes")
	if remotesFolder then
		for _, remote in ipairs(remotesFolder:GetDescendants()) do
			if remote:IsA("RemoteFunction") or remote:IsA("RemoteEvent") then
				cache[remote.Name] = remote
			end
		end
	end

	for _, v in ipairs(rs:GetDescendants()) do
		if v:IsA("RemoteFunction") or v:IsA("RemoteEvent") then
			cache[v.Name] = cache[v.Name] or v
		end
	end

	self._remotes = cache
	return cache
end

function GameAPI:SendCommF(...)
	local remotes = self:GetRemotes()
	local remote = remotes["CommF_"]
	if remote and remote:IsA("RemoteFunction") then
		return remote:InvokeServer(...)
	end
	return nil
end

function GameAPI:GetQuestData()
	local data = self:SendCommF("GetQuestData")
	if data and type(data) == "table" then
		return data
	end
	return {}
end

function GameAPI:GetPlayerStats()
	local stats = self:SendCommF("getPlayTime") or {}
	return {
		Level = stats.Level or 0,
		Bounty = stats.Bounty or 0,
		Beli = stats.Beli or 0,
		Fragments = stats.Fragments or 0,
		Race = stats.Race or "Unknown",
		SkillPoints = stats.SkillPoints or stats.SkillPoint or 0
	}
end

function GameAPI:Quest(questId, questName)
	if questName then
		return self:SendCommF("Quest", questId, questName)
	else
		return self:SendCommF("Quest", questId)
	end
end

function GameAPI:Attack(target)
	local remotes = self:GetRemotes()
	local attackEvent = remotes["attackRemote"] or remotes["Attack"] or remotes["CombatHit"]

	if attackEvent then
		if attackEvent:IsA("RemoteEvent") then
			attackEvent:FireServer(target)
		elseif attackEvent:IsA("RemoteFunction") then
			attackEvent:InvokeServer(target)
		end
	end
end

function GameAPI:TeleportTo(position, onComplete)
	local character = self.Player.Character or self.Player.CharacterAdded:Wait()
	local root = character:WaitForChild("HumanoidRootPart")

	local distance = (position - root.Position).magnitude
	if distance < 5 then
		if onComplete then onComplete() end
		return
	end

	local tweenInfo = TweenInfo.new(distance / 768, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(position + Vector3.new(0, 5, 0))})
	if onComplete then tween.Completed:Connect(onComplete) end
	tween:Play()
	return tween
end

function GameAPI:GetMobs()
	local mobs = {}
	local seen = {}

	local function addMob(mob)
		if mob and not seen[mob] then
			seen[mob] = true
			if mob:FindFirstChildOfClass("Humanoid") then
				table.insert(mobs, mob)
			end
		end
	end

	local cacheFolder = self.Workspace:FindFirstChild("Cache")
	if cacheFolder then
		for _, v in ipairs(cacheFolder:GetChildren()) do
			if v:IsA("Model") then addMob(v) end
		end
	end

	for _, v in ipairs(self.Workspace:GetChildren()) do
		if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") then
			if v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso") then
				addMob(v)
			end
		end
	end

	return mobs
end

function GameAPI:FindMob(mobName, maxDistance)
	local mobs = self:GetMobs()
	local playerRoot = self:GetRoot()
	if not playerRoot then return nil end

	local bestMob = nil
	local bestDist = maxDistance or math.huge

	for _, mob in ipairs(mobs) do
		local humanoid = mob:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			local mobRoot = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
			if mobRoot then
				local dist = (mobRoot.Position - playerRoot.Position).magnitude
				if dist < bestDist then
					if not mobName or mob.Name:lower():find(mobName:lower()) then
						bestMob = mob
						bestDist = dist
					end
				end
			end
		end
	end

	return bestMob
end

function GameAPI:GetRoot()
	local char = self.Player.Character or self.Player.CharacterAdded:Wait()
	return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
end

function GameAPI:GetCombatController()
	if self._combatController then return self._combatController end

	local scripts = self.Player:WaitForChild("PlayerScripts")
	local combatScripts = scripts:FindFirstChild("CombatFramework") or scripts:FindFirstChild("Combat")

	if combatScripts and combatScripts:IsA("ModuleScript") then
		local success, controller = pcall(function()
			return require(combatScripts):GetCombatController()
		end)
		if success and controller then
			self._combatController = controller
			return controller
		end
	end

	local success, controller = pcall(function()
		for _, func in ipairs(getgc(true)) do
			if typeof(func) == "function" then
				local constants = getconstants(func)
				if table.find(constants, "getCombatController") then
					return func()
				end
			end
		end
		return nil
	end)

	if success and controller and typeof(controller) == "table" then
		self._combatController = controller
		return controller
	end

	return nil
end

function GameAPI:GetClosestEnemy(maxDistance)
	local mobs = self:GetMobs()
	local playerRoot = self:GetRoot()
	if not playerRoot then return nil end

	local closest = nil
	local closestDist = maxDistance or 500

	for _, mob in ipairs(mobs) do
		local mobRoot = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
		if mobRoot then
			local dist = (playerRoot.Position - mobRoot.Position).magnitude
			if dist < closestDist then
				local humanoid = mob:FindFirstChildOfClass("Humanoid")
				if humanoid and humanoid.Health > 0 then
					closest = mob
					closestDist = dist
				end
			end
		end
	end

	return closest
end

function GameAPI:FindChests()
	local chests = {}
	for _, v in ipairs(self.Workspace:GetChildren()) do
		if v:IsA("Model") and (v.Name:lower():find("chest") or v.Name:lower():find("treasure")) then
			table.insert(chests, v)
		end
		if v:IsA("Part") and v.Name:lower():find("chest") then
			table.insert(chests, v)
		end
	end
	return chests
end

function GameAPI:FindFruits()
	local fruits = {}
	for _, v in ipairs(self.Workspace:GetChildren()) do
		if v:IsA("Tool") and v.Name:lower():find("fruit") then
			table.insert(fruits, v)
		end
	end
	return fruits
end

function GameAPI:GetCurrentSea()
	local zone = self:SendCommF("GetCurrentZone") or ""
	if zone:find("Second") or zone:find("Sea 2") then return 2 end
	if zone:find("Third") or zone:find("Sea 3") then return 3 end
	return 1
end

function GameAPI:InitiateRaid(raidType)
	return self:SendCommF("Raid", raidType)
end

function GameAPI:StoreFruit(fruit)
	local remotes = self:GetRemotes()
	local rs = remotes["FruitStorage"] or remotes["StoreFruit"]
	if rs and rs:IsA("RemoteEvent") then
		rs:FireServer(fruit)
	end
end

function GameAPI:ServerHop()
	local servers = {}
	local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/0?limit=100"
	local success, response = pcall(function()
		return HttpService:JSONDecode(game:HttpGet(url))
	end)

	if success and response and response.data then
		for _, server in ipairs(response.data) do
			if server.maxPlayers > server.playing and server.id ~= game.JobId then
				table.insert(servers, server.id)
			end
		end
	end

	if #servers > 0 then
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], self.Player)
	end
end

return GameAPI