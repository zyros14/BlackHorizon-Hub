local Chest = {}
Chest.__index = Chest

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local function getGameAPI()
	return getgenv().BH_GameAPI
end

Chest.Config = {
	Enabled = false,
	AutoLoot = true,
	TweenToChest = true,
	TweenSpeed = 300,
	MinDistance = 3,
	CheckInterval = 1,
	MaxDistance = 300,
}

Chest.State = {
	Active = false,
	FarmedChests = {},
}

function Chest:Start()
	self:Stop()
	self.State.Active = true

	self._loopConn = RunService.Heartbeat:Connect(function()
		self:_runChestLoop()
	end)
end

function Chest:Stop()
	self.State.Active = false
	if self._loopConn then
		self._loopConn:Disconnect()
		self._loopConn = nil
	end
end

function Chest:_runChestLoop()
	pcall(function()
		self:_runChestLoopSafe()
	end)
end

function Chest:_runChestLoopSafe()
	if not self.Config.Enabled or not self.State.Active then return end

	local api = getGameAPI()
	if not api then return end

	local player = Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local chests = api:FindChests()
	for _, chest in ipairs(chests) do
		local chestId = chest:GetFullName()
		if self.State.FarmedChests[chestId] then continue end

		local chestRoot = chest:IsA("Model") and (chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart")) or chest
		if not chestRoot then continue end

		local distance = (root.Position - chestRoot.Position).magnitude
		if distance > self.Config.MaxDistance then continue end

		if distance > self.Config.MinDistance then
			if self.Config.TweenToChest then
				self:_tweenToPosition(chestRoot.Position + Vector3.new(0, 5, 0))
			end
		else
			self:_lootChest(chest)
		end
	end
end

function Chest:_tweenToPosition(position)
	local player = Players.LocalPlayer
	local char = player.Character or player.CharacterAdded:Wait()
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local distance = (root.Position - position).magnitude
	local tweenInfo = TweenInfo.new(distance / self.Config.TweenSpeed, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(root, tweenInfo, {CFrame = CFrame.new(position)})
	tween:Play()
	tween.Completed:Wait()
end

function Chest:_lootChest(chest)
	local touch = chest:FindFirstChildWhichIsA("ProximityPrompt") or chest:FindFirstChild("Touch")

	if touch and touch:IsA("ProximityPrompt") then
		pcall(function()
			fireproximityprompt(touch)
		end)
	elseif touch then
		pcall(function()
			touch:FireServer()
		end)
	end

	self.State.FarmedChests[chest:GetFullName()] = true
	delay(30, function()
		self.State.FarmedChests[chest:GetFullName()] = nil
	end)
end

function Chest:ResetFarmed()
	self.State.FarmedChests = {}
end

return Chest