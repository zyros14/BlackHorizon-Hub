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
	if enabled then
		if self.State.AntiAFK then return end
		self.State.AntiAFK = true

		local vt = game:GetService("VirtualUserManager")
		table.insert(self.Connections, RunService.Heartbeat:Connect(function()
			local player = Players.LocalPlayer
			if player and player.UserId then
				local idleTime = player:FindFirstChild("PlayerGui")
				pcall(function()
					vt:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
					task.wait(0.05)
					vt:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
				end)
			end
		end))

		self._antiAfkConn = game:GetService("Players").LocalPlayer.Idled:Connect(function()
			pcall(function()
				vt:Button2Down(Vector2.new(), workspace.CurrentCamera.CFrame)
				task.wait(0.05)
				vt:Button2Up(Vector2.new(), workspace.CurrentCamera.CFrame)
			end)
		end)
	else
		self.State.AntiAFK = false
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
end

return Utility