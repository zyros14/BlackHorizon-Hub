local BH = {}
BH.__index = BH

BH.Version = "v1.0.0"
BH.Name = "Black Horizon Hub"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

BH.Player = Players.LocalPlayer
BH.PlayerGui = BH.Player:WaitForChild("PlayerGui")
BH.ReplicatedStorage = game:GetService("ReplicatedStorage")
BH.Workspace = workspace
BH.BloxFruitGameId = 994732206

if game.GameId ~= BH.BloxFruitGameId then
	warn(BH.Name .. " is designed for Blox Fruits only.")
	return
end

local BASE_URL = "https://raw.githubusercontent.com/zyros14/BlackHorizon-Hub/main"

local function fetchModule(path)
	local url = BASE_URL .. "/" .. path
	local success, source = pcall(function()
		return game:HttpGet(url)
	end)

	if not success or not source or source == "" then
		warn("[BH] Failed to fetch:", path, source)
		return nil
	end

	local fn, err = loadstring(source)
	if not fn then
		warn("[BH] Failed to compile:", path, err)
		return nil
	end

	return fn()
end

repeat task.wait() until game:IsLoaded()
repeat task.wait() until BH.Player.Character
repeat task.wait() until BH.Player.Character:FindFirstChild("HumanoidRootPart")

BH.Config = {
	Features = {
		AutoFarm = { Enabled = true, AutoQuest = true, BringMobs = true, TweenSpeed = 256 },
		Combat = { Enabled = true, AutoClick = true, AutoSkill = true, AntiStun = true, AntiKnockback = true },
		AutoRaid = { Enabled = false, Intervale = 5, Difficulty = "Hard" },
		AutoChest = { Enabled = false, TweenSpeed = 300, AutoLoot = true },
		AutoFruit = { Enabled = false, AutoStore = true },
		AntiAFK = { Enabled = true },
		WhiteScreen = { Enabled = false },
		NoClip = { Enabled = false },
		AntiDetection = { Enabled = true },
	},
	UI = {
		Minimized = false,
		Transparency = 0.05,
		TextColor = Color3.fromRGB(220, 220, 220),
		AccentColor = Color3.fromRGB(40, 120, 255),
		ButtonColor = Color3.fromRGB(45, 45, 50),
		OutlineColor = Color3.fromRGB(30, 30, 35),
	},
	Debug = {
		Enabled = false,
	},
}

setreadonly(BH.Config, false)

BH.State = {
	Running = false,
	ModulesLoaded = false,
}

function BH:_loadModules()
	self.Modules = {}

	local modulePaths = {
		GameAPI = "Modules/GameAPI.lua",
		Quest = "Modules/Quest.lua",
		Combat = "Modules/Combat.lua",
		Farm = "Modules/Farm.lua",
		Chest = "Modules/Chest.lua",
		Raid = "Modules/Raid.lua",
		Utility = "Modules/Utility.lua",
	}

	for name, path in pairs(modulePaths) do
		local module = fetchModule(path)
		if module then
			self.Modules[name] = module
			getgenv()["BH_" .. name] = module
		else
			warn("[BH] Module not loaded:", name)
		end
	end

	if not self.Modules.GameAPI then
		self.Modules.GameAPI = self:_loadGameAPIFallback()
	end

	self.State.ModulesLoaded = true
end

function BH:_loadGameAPIFallback()
	local api = {}
	api.__index = api

	local function getRemote(name)
		local rs = game:GetService("ReplicatedStorage")
		local remotes = rs:FindFirstChild("Remotes")
		if remotes then
			return remotes:FindFirstChild(name)
		end
		return rs:FindFirstChild(name)
	end

	function api:SendCommF(...)
		local remote = getRemote("CommF_")
		if remote and remote:IsA("RemoteFunction") then
			return remote:InvokeServer(...)
		end
		return nil
	end

	function api:Quest(id, name)
		return self:SendCommF("Quest", id, name)
	end

	function api:Attack(target)
		self:SendCommF("CombatHit", target)
	end

	function api:FindMob(name)
		for _, v in ipairs(workspace:GetChildren()) do
			if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") then
				if not name or v.Name:lower():find(name:lower()) then
					return v
				end
			end
		end
		return nil
	end

	function api:GetMobs()
		local mobs = {}
		for _, v in ipairs(workspace:GetChildren()) do
			if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") then
				if v:FindFirstChild("HumanoidRootPart") or v:FindFirstChild("Torso") then
					table.insert(mobs, v)
				end
			end
		end
		return mobs
	end

	function api:GetQuestData()
		return self:SendCommF("GetQuestData") or {}
	end

	function api:GetRoot()
		local char = BH.Player.Character or BH.Player.CharacterAdded:Wait()
		return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
	end

	return api
end

function BH:_initAntiDetection()
	local Utility = self.Modules.Utility
	if not Utility then return end

	pcall(function() Utility:AntiAFK(true) end)
	pcall(function() Utility:AntiLag(true) end)
end

function BH:_initGUI()
	local ui = fetchModule("UI/init.lua")
	if ui then
		self.UI = ui
		ui:Create(self)
	end
end

function BH:_startFeatures()
	if self.Modules.Farm and self.Config.Features.AutoFarm.Enabled then
		for k, v in pairs(self.Config.Features.AutoFarm) do self.Modules.Farm.Config[k] = v end
		pcall(function() self.Modules.Farm:Start() end)
	end

	if self.Modules.Combat then
		self.Modules.Combat.State.AntiStun.Enabled = self.Config.Features.Combat.AntiStun
		pcall(function() self.Modules.Combat:ApplyAntiStun() end)
		pcall(function() self.Modules.Combat:ApplyAntiKnockback() end)
	end
end

function BH:Run()
	self:_startFeatures()
	self.State.Running = true
end

function BH:_log(msg)
	if self.Config.Debug.Enabled then
		print("[BH] " .. tostring(msg))
	end
end

BH:_loadModules()
BH:_initAntiDetection()
BH:_initGUI()
BH:Run()

if BH.UI and BH.UI.Notify then
	pcall(function() BH.UI:Notify("Black Horizon", "Loaded & running", 3) end)
end

return BH