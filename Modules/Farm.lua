local Farm = {}
Farm.__index = Farm

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local function getGameAPI()
	return getgenv().BH_GameAPI
end

local function getQuest()
	return getgenv().BH_Quest
end

local function getCombat()
	return getgenv().BH_Combat
end

Farm.Config = {
	Enabled = true,
	AutoQuest = true,
	BringMobs = true,
	MinDistance = 3,
	AttackRange = 35,
	TweenSpeed = 256,
}

Farm.State = {
	Active = false,
	LastTargetCheck = 0,
	TargetCheckInterval = 0.5,
}

local function getRoot()
	local api = getGameAPI()
	if not api then return nil end
	return api:GetRoot()
end

function Farm:Start()
	self:Stop()
	self.State.Active = true

	self._loopConn = RunService.Heartbeat:Connect(function()
		self:_runFarmLoop()
	end)
end

function Farm:Stop()
	self.State.Active = false
	if self._loopConn then
		self._loopConn:Disconnect()
		self._loopConn = nil
	end
end

function Farm:_runFarmLoop()
	if not self.Config.Enabled or not self.State.Active then return end

	local api = getGameAPI()
	if not api then return end

	local Quest = getQuest()
	if Quest and self.Config.AutoQuest then
		self:_handleQuest(Quest, api)
	end

	local mob = self:_findTargetMob(api)
	if mob then
		self._targetMob = mob
		self:_moveToTarget(mob)
		self:_attackTarget(mob)
		if self.Config.BringMobs then
			self:BringMobsToPlayer(mob)
		end
	end
end

function Farm:_handleQuest(Quest, api)
	local playerLevel = Quest:GetPlayerLevel()
	local currentQuest = Quest:GetCurrentQuest()

	if currentQuest and currentQuest.IsActive then
		if Quest:CanStartNewQuest() then
			local questInfo = Quest:GetQuestForLevel(playerLevel)
			if questInfo then
				Quest:StartQuest(questInfo.QuestId, questInfo.QuestName)
			end
		end
	else
		local questInfo = Quest:GetQuestForLevel(playerLevel)
		if questInfo then
			Quest:StartQuest(questInfo.QuestId, questInfo.QuestName)
		end
	end
end

function Farm:_findTargetMob(api)
	local tickNow = tick()
	if tickNow - self.State.LastTargetCheck < self.State.TargetCheckInterval then
		return self._targetMob and self._targetMob:FindFirstChild("Humanoid") and self._targetMob or nil
	end
	self.State.LastTargetCheck = tickNow

	local Quest = getQuest()
	if Quest then
		local mob = Quest:GetNearestMobForQuest()
		if mob then return mob end
	end

	return api:GetClosestEnemy((self.Config.AttackRange or 35) * 4)
end

function Farm:_moveToTarget(mob)
	local mobRoot = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
	if not mobRoot then return end

	local playerRoot = getRoot()
	if not playerRoot then return end

	local distance = (playerRoot.Position - mobRoot.Position).magnitude
	if distance <= (self.Config.MinDistance or 3) then return end

	local targetPos = mobRoot.Position + Vector3.new(0, (self.Config.MinDistance or 3) + 3, 0)
	local tweenInfo = TweenInfo.new(distance / (self.Config.TweenSpeed or 256), Enum.EasingStyle.Linear)
	local tween = TweenService:Create(playerRoot, tweenInfo, {CFrame = CFrame.new(targetPos)})
	tween:Play()
	self._currentTween = tween
end

function Farm:_attackTarget(mob)
	local Combat = getCombat()
	if Combat then
		Combat:PerformCombo(mob)
		Combat:UseAllSkills(mob)
	end

	local api = getGameAPI()
	if api then
		api:Attack(mob)
	end
end

function Farm:BringMobsToPlayer(mob)
	local mobRoot = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Torso")
	if not mobRoot then return end

	local playerRoot = getRoot()
	if not playerRoot then return end

	local distance = (playerRoot.Position - mobRoot.Position).magnitude
	if distance > (self.Config.AttackRange or 35) or distance < 3 then return end

	local humanoid = mob:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end

	local targetPos = playerRoot.Position + Vector3.new((math.random() - 0.5) * 4, 3, (math.random() - 0.5) * 4)
	local bv = Instance.new("BodyVelocity")
	bv.Velocity = (targetPos - mobRoot.Position).unit * 80
	bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bv.P = 10000
	bv.Name = "_FarmBringVelocity"

	local existing = mobRoot:FindFirstChild("_FarmBringVelocity")
	if existing then existing:Destroy() end

	bv.Parent = mobRoot
	game:GetService("Debris"):AddItem(bv, 0.5)
end

function Farm:GetCurrentTarget()
	return self._targetMob
end

function Farm:IsActive()
	return self.State.Active
end

return Farm