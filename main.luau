-- Black Horizon Hub Loader
-- Executor-agnostic: works with Lua 5.1 and Luau-based executors
-- Loads the latest Black Horizon Hub script for Blox Fruits

local _ENV = getgenv or {}

local REPOSITORY = "https://raw.githubusercontent.com/zyros14/BlackHorizon-Hub/main/"

local Scripts = {
	{
		GameId = 994732206, -- Blox Fruits
		Script = "init.lua"
	}
}

-- clear any previous error message from workspace
for _, msg in ipairs(workspace:GetChildren()) do
	if msg:IsA("Message") and msg.Text:find("Black Horizon") then
		msg:Destroy()
	end
end

-- robust error display + throw
local function fail(text)
	_ENV.BH_Loaded = nil
	_ENV.BH_Running = nil
	pcall(function()
		local msg = Instance.new("Message", workspace)
		msg.Text = tostring(text)
		task.delay(20, function()
			if msg and msg.Parent then msg:Destroy() end
		end)
	end)
	error(text, 2)
end

-- safe HTTP fetch with retry
local function fetch(url)
	local lastErr
	for attempt = 1, 3 do
		local ok, res = pcall(function()
			return game:HttpGet(url)
		end)
		if ok and res and #res > 0 then
			return res
		end
		lastErr = res
		task.wait(attempt * 0.5)
	end
	fail("[Black Horizon] Failed to fetch: " .. url .. " - " .. tostring(lastErr))
end

-- compile source to a function (works whether executor exposes loadstring or load)
local function compile(source, chunkName)
	if type(loadstring) == "function" then
		return loadstring(source)
	end
	if type(load) == "function" then
		return load(source, chunkName, "t", getfenv(2))
	end
	return nil, "No loadstring/load available on this executor"
end

-- queue teleport so the script auto-runs after server hop
local function setupTeleportQueue(scriptArgs)
	if _ENV.BH_TeleportQueued then return end
	_ENV.BH_TeleportQueued = true

	local qtp = queue_on_teleport
	if type(qtp) ~= "function" then
		local exec = syn or fluxus or krnl
		if exec and type(exec.queue_on_teleport) == "function" then
			qtp = exec.queue_on_teleport
		end
	end

	if type(qtp) == "function" then
		local settingsCode = ""
		local ok, encoded = pcall(function()
			return game:GetService("HttpService"):JSONEncode(scriptArgs)
		end)
		if ok and encoded then
			settingsCode = "unpack(game:GetService('HttpService'):JSONDecode('" .. encoded .. "'))"
		end
		local source = "loadstring(game:HttpGet('" .. REPOSITORY .. "init.lua'))(" .. settingsCode .. ")"
		pcall(qtp, source)
	end
end

-- debounce: prevent double execution
do
	local lastExec = _ENV.BH_LastExec
	if lastExec and (tick() - lastExec) <= 5 then
		return nil
	end
	_ENV.BH_LastExec = tick()
end

setupTeleportQueue({...})

local loaded = false
for _, entry in ipairs(Scripts) do
	local isPlace = false

	if entry.PlacesIds and table.find(entry.PlacesIds, game.PlaceId) then
		isPlace = true
	elseif entry.GameId and entry.GameId == game.GameId then
		isPlace = true
	end

	if isPlace and not loaded then
		local source = fetch(REPOSITORY .. entry.Script)
		local fn, err = compile(source, "BlackHorizon")
		if not fn then
			fail("[Black Horizon] Compile error: " .. tostring(err))
		end

		local ok, runErr = pcall(fn, ...)
		if not ok then
			warn("[Black Horizon] runtime error:", runErr)
		end

		loaded = true
	end
end

if not loaded then
	warn("[Black Horizon] This script only supports Blox Fruits. PlaceId:", game.PlaceId, "GameId:", game.GameId)
end