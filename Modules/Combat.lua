local Combat = {}
Combat.__index = Combat

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local function getGameAPI()
	return getgenv().BH_GameAPI
end

Combat.State = {
	Combo = { Enabled = true, Delay = 0.03, LastClick = 0 },
	Skills = { Enabled = true, Delay = 0.15, LastSkill = 0 },
	AutoClick = { Enabled = true },
	AntiStun = { Enabled = true },
	AntiKnockback = { Enabled = true },
	Range = 50,
}

function Combat:Attack(target)
	if not target then return end
	local api = getGameAPI()
	if api then
		api:Attack(target)
	end
end

function Combat:PerformCombo(target)
	if not self.State.Combo.Enabled then return end
	if not target then return end

	local now = tick()
	if now - self.State.Combo.LastClick < self.State.Combo.Delay then
		return
	end
	self.State.Combo.LastClick = now

	local api = getGameAPI()
	if api then
		api:Attack(target)
	end

	local player = Players.LocalPlayer
	local mouse = player:GetMouse()
	if mouse then
		pcall(function()
			mouse1click()
		end)
	end
end

function Combat:UseAllSkills(target)
	if not self.State.Skills.Enabled then return end

	local now = tick()
	if now - self.State.Skills.LastSkill < self.State.Skills.Delay then
		return
	end
	self.State.Skills.LastSkill = now

	local player = Players.LocalPlayer
	local virtualUser = game:GetService("VirtualInputManager")

	local keys = {"Z", "X", "C", "V", "B", "N"}
	for _, key in ipairs(keys) do
		pcall(function()
			virtualUser:SendKeyEvent(true, Enum.KeyCode[key], false, game)
			task.wait(0.05)
			virtualUser:SendKeyEvent(false, Enum.KeyCode[key], false, game)
		end)
		task.wait(self.State.Skills.Delay)
	end
end

function Combat:AutoAttack(target, duration)
	local endTime = tick() + (duration or 1)
	while tick() < endTime do
		if not target or not target:FindFirstChild("HumanoidRootPart") then break end
		self:PerformCombo(target)
		self:Attack(target)
		task.wait(self.State.Combo.Delay)
	end
end

function Combat:ApplyAntiStun()
	if not self.State.AntiStun.Enabled then return end

	if self._antiStunConn then
		self._antiStunConn:Disconnect()
	end

	self._antiStunConn = RunService.Heartbeat:Connect(function()
		local player = Players.LocalPlayer
		local char = player.Character
		if char then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				if humanoid:FindFirstChild("JumpPower") then
					humanoid.JumpPower = 50
				end
				if humanoid:FindFirstChild("WalkSpeed") then
					humanoid.WalkSpeed = math.max(humanoid.WalkSpeed, 16)
				end
			end
		end
	end)
end

function Combat:ApplyAntiKnockback()
	if not self.State.AntiKnockback.Enabled then return end

	if self._knockbackConn then
		self._knockbackConn:Disconnect()
	end

	self._knockbackConn = RunService.Heartbeat:Connect(function()
		local player = Players.LocalPlayer
		local char = player.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				root.Velocity = Vector3.new(
					root.Velocity.X * 0.8,
					math.clamp(root.Velocity.Y, -50, 200),
					root.Velocity.Z * 0.8
				)
				root.RotVelocity = Vector3.new(0, 0, 0)
			end
		end
	end)
end

function Combat:Destroy()
	if self._antiStunConn then self._antiStunConn:Disconnect() end
	if self._knockbackConn then self._knockbackConn:Disconnect() end
end

return Combat