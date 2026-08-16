local Utility = {}
Utility.__index = Utility

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

Utility.State = {
	AntiAFK = false,
	NoClip = false,
	WhiteScreen = false,
}

Utility.Connections = {}

function Utility:AntiAFK(enabled)
	if not enabled then
		self.State.AntiAFK = false
		return
	end
	if self.State.AntiAFK then return end
	self.State.AntiAFK = true

	-- universal anti-AFK: trigger the Idled handler with VirtualUser (works on all executors)
	local success, vu = pcall(function()
		return game:GetService("VirtualUser")
	end)

	if success and vu then
		local function simulateInput()
			pcall(function()
				vu:CaptureController()
				vu:Button1Down(Vector2.new(0, 0))
				task.wait(0.05)
				vu:Button1Up(Vector2.new(0, 0))
			end)
		end

		self._antiAfkConn = Players.LocalPlayer.Idled:Connect(function()
			simulateInput()
			vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			task.wait(0.05)
			vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		end)

		-- also periodically move to prevent idle
		self._afkHeartbeat = RunService.Heartbeat:Connect(function()
			local player = Players.LocalPlayer
			local char = player and player.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if root then
				simulateInput()
			end
		end)
	else
		-- fallback: nudge the humanoid so the game never flags us as idle
		self._afkHeartbeat = RunService.Heartbeat:Connect(function()
			local player = Players.LocalPlayer
			local char = player and player.Character
			local humanoid = char and char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Jump = true
			end
		end)
		if self.State.AntiAFK then
			Players.LocalPlayer.Idled:Connect(function()
				local char = Players.LocalPlayer.Character
				local humanoid = char and char:FindFirstChildOfClass("Humanoid")
				if humanoid then humanoid.Jump = true end
			end)
		end
	end
end

function Utility:AntiLag(enabled)
	if not enabled then return end

	pcall(function()
		for _, v in ipairs(Lighting:GetChildren()) do
			if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Sparkles") or v:IsA("Fire") then
				v.Enabled = false
			end
		end

		Lighting.FogEnd = 100000

		for _, v in ipairs(workspace:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("Trail") then
				v.Enabled = false
			end
		end
	end)
end

function Utility:WhiteScreenFix(enabled)
	if enabled then
		if self._whiteScreenConn then return end

		self._whiteScreenConn = RunService.Heartbeat:Connect(function()
			pcall(function()
				Lighting.Brightness = 1
				Lighting.ClockTime = 14
				Lighting.EnvironmentDiffuseScale = 0.5
				Lighting.EnvironmentSpecularScale = 0.5

				for _, effect in ipairs(Lighting:GetChildren()) do
					if effect:IsA("ColorCorrectionEffect") then
						effect.Enabled = false
					end
				end
			end)
		end)
		self.State.WhiteScreen = true
	else
		if self._whiteScreenConn then
			self._whiteScreenConn:Disconnect()
			self._whiteScreenConn = nil
			self.State.WhiteScreen = false
		end
	end
end

function Utility:NoClip(enabled)
	if enabled then
		if self._noclipConn then return end

		self._noclipConn = RunService.Heartbeat:Connect(function()
			local player = Players.LocalPlayer
			local character = player.Character
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false
					end
				end
			end
		end)
		self.State.NoClip = true
	else
		if self._noclipConn then
			self._noclipConn:Disconnect()
			self._noclipConn = nil

			local player = Players.LocalPlayer
			local character = player.Character
			if character then
				for _, part in ipairs(character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = true
					end
				end
			end
			self.State.NoClip = false
		end
	end
end

function Utility:Destroy()
	for _, conn in ipairs(self.Connections) do
		if conn.Connected then conn:Disconnect() end
	end
	self.Connections = {}
	if self._whiteScreenConn then self._whiteScreenConn:Disconnect() end
	if self._noclipConn then self._noclipConn:Disconnect() end
	if self._antiAfkConn then self._antiAfkConn:Disconnect() end
	if self._afkHeartbeat then self._afkHeartbeat:Disconnect() end
end

return Utility