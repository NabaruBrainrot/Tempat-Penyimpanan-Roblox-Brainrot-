---Ghost Gui UI Library
loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/UI-Library/refs/heads/main/Ghost%20Gui'))()
game.CoreGui.GhostGui.MainFrame.Title.Text = "Title Here"
---







AddContent("Switch", "Auto Speed", [[
-- ===== TOGGLE ON =====

_G.AutoSpeed = true
print("Auto Speed: ON")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Path TextLabel speed
local speedLabel = player.PlayerGui
    :WaitForChild("BottomLeft")
    :WaitForChild("Frame")
    :WaitForChild("Speed")

local MULTIPLIER = 120 / 18
local MAX_SPEED = 300
local cachedSpeed = 0
local currentTween

-- 🔄 UPDATE SPEED DARI TEXT
if not _G.SpeedUpdateThread then
    _G.SpeedUpdateThread = task.spawn(function()
        while _G.AutoSpeed do
            local value = tonumber(speedLabel.Text:match("%d+"))
            if value then
                cachedSpeed = value * MULTIPLIER
                if cachedSpeed > MAX_SPEED then
                    cachedSpeed = MAX_SPEED
                end
            end
            task.wait(1)
        end
    end)
end

-- 🚶‍♂️ MOVEMENT DENGAN TWEEN (SAAT JALAN)
if not _G.SpeedMoveConn then
    _G.SpeedMoveConn = RunService.Heartbeat:Connect(function(dt)
        if not _G.AutoSpeed then return end

        local char = player.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not (hrp and hum) then return end

        local dir = hum.MoveDirection
        if dir.Magnitude == 0 then
            if currentTween then
                currentTween:Cancel()
                currentTween = nil
            end
            return
        end

        -- Stop tween lama
        if currentTween then
            currentTween:Cancel()
        end

        -- Hitung jarak langkah kecil (biar natural)
        local moveDistance = cachedSpeed * dt
        local goalCFrame = hrp.CFrame + Vector3.new(
            dir.X * moveDistance,
            0,
            dir.Z * moveDistance
        )

        currentTween = TweenService:Create(
            hrp,
            TweenInfo.new(
                dt,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.Out
            ),
            {CFrame = goalCFrame}
        )

        currentTween:Play()
    end)
end

]], [[
-- ===== TOGGLE OFF =====

_G.AutoSpeed = false
print("Auto Speed: OFF")

if _G.SpeedMoveConn then
    _G.SpeedMoveConn:Disconnect()
    _G.SpeedMoveConn = nil
end

if _G.SpeedUpdateThread then
    _G.SpeedUpdateThread = nil
end
]])



AddContent("Switch", "Collect Cash", [[
-- ===== TOGGLE ON =====
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("CollectMoney")

_G.AutoCollectCash = true

task.spawn(function()
    while _G.AutoCollectCash do
        for i = 1, 30 do
            if not _G.AutoCollectCash then break end
            Remote:FireServer("Slot"..i)
            task.wait() -- anti lag
        end
        task.wait(0.5)
    end
end)
]], [[
-- ===== TOGGLE OFF =====
_G.AutoCollectCash = false
]])





AddContent("Switch", "Upgrade All", [[
-- ===== TOGGLE ON =====
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage
    :WaitForChild("RemoteFunctions")
    :WaitForChild("UpgradeBrainrot")

_G.AutoUpgradeAllSlot = true

task.spawn(function()
    while _G.AutoUpgradeAllSlot do
        -- jalankan semua slot SEKALIGUS
        for i = 1, 30 do
            if not _G.AutoUpgradeAllSlot then break end
            task.spawn(function()
                Remote:InvokeServer("Slot" .. i)
            end)
        end
        task.wait(0.5) -- jeda antar batch
    end
end)
]], [[
-- ===== TOGGLE OFF =====
_G.AutoUpgradeAllSlot = false
]])




AddContent("Switch", "Anti Tsunami", [[
-- ===== TOGGLE ON =====
if _G.AntiTsunami then return end
_G.AntiTsunami = true

-- ===== SERVICES =====
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- ===== VARIABLES =====
local character, hrp
local currentTween
local params = OverlapParams.new()
params.FilterType = Enum.RaycastFilterType.Blacklist

-- ===== SPEED TEXT =====
local speedLabel = player.PlayerGui
    :WaitForChild("BottomLeft")
    :WaitForChild("Frame")
    :WaitForChild("Speed")

-- ===== CONFIG =====
local COOLDOWN = 2
local PLAYER_RADIUS = 100
local PART_RADIUS = 50
local SPEED_MULT = 6.66
local MAX_SPEED = 300

local function getTweenSpeed()
    local num = tonumber(speedLabel.Text:match("%d+")) or 18
    return math.clamp(num * SPEED_MULT, 1, MAX_SPEED)
end

-- ===== SAFE CFRAMES =====
local SafeCFrames = {
    CFrame.new(543.411316, -4.02592373, -0.922426283),
    CFrame.new(757.379578, -3.1540308, -1.72257304),
    CFrame.new(1075.6106, -3.23971272, 3.20061111),
    CFrame.new(1550.67151, -3.26713109, 10.1864586),
    CFrame.new(2252.74146, -3.2540493, 5.63876724),
    CFrame.new(2605.51904, -3.22055626, 14.0165806),
    CFrame.new(398.271912, -3.89251757, -9.20723152),
    CFrame.new(285.117859, -4.32986689, -8.98183632),
    CFrame.new(201.416275, -4.02712774, -5.44396925)
}

-- ===== FOLDER =====
local folder = Instance.new("Folder")
folder.Name = "SafeCFrameDetectors"
folder.Parent = Workspace

-- ===== DETECTORS =====
local detectors = {}
for _, cf in ipairs(SafeCFrames) do
    local part = Instance.new("Part")
    part.Size = Vector3.new(6,6,6)
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Transparency = 1
    part.Color = Color3.fromRGB(0,255,0)
    part.CFrame = cf * CFrame.new(0,5,0)
    part.Parent = folder

    table.insert(detectors, {
        Part = part,
        CFrame = cf,
        CooldownUntil = 0
    })
end

-- ===== CHARACTER HANDLER =====
local function onCharacterAdded(char)
    character = char
    hrp = char:WaitForChild("HumanoidRootPart", 10)

    if currentTween then
        currentTween:Cancel()
        currentTween = nil
    end

    params.FilterDescendantsInstances = { folder, character }
end

if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

-- ===== TWEEN =====
local function tweenTo(cf)
    if not hrp then return end

    if currentTween then
        currentTween:Cancel()
    end

    local speed = getTweenSpeed()
    local dist = (hrp.Position - cf.Position).Magnitude
    local time = dist / speed

    currentTween = TweenService:Create(
        hrp,
        TweenInfo.new(time, Enum.EasingStyle.Linear),
        { CFrame = cf }
    )
    currentTween:Play()
end

-- ===== MAIN LOOP =====
_G.AntiTsunamiConn = RunService.Heartbeat:Connect(function()
    if not _G.AntiTsunami then return end
    if not hrp or not hrp.Parent then return end

    local now = tick()

    local danger = false
    for _, p in ipairs(Workspace:GetPartBoundsInRadius(hrp.Position, PLAYER_RADIUS, params)) do
        if p.Name == "Hitbox" then
            danger = true
            break
        end
    end
    if not danger then return end

    local best, bestDist
    for _, d in ipairs(detectors) do
        if now >= d.CooldownUntil then
            local dist = (hrp.Position - d.Part.Position).Magnitude
            if not bestDist or dist < bestDist then
                bestDist = dist
                best = d
            end
        end
    end

    if best then
        tweenTo(best.CFrame)
    end
end)

print("✅ Anti Tsunami ON")
]], [[
-- ===== TOGGLE OFF =====
_G.AntiTsunami = false

if _G.AntiTsunamiConn then
    _G.AntiTsunamiConn:Disconnect()
    _G.AntiTsunamiConn = nil
end

if workspace:FindFirstChild("SafeCFrameDetectors") then
    workspace.SafeCFrameDetectors:Destroy()
end

print("⛔ Anti Tsunami OFF")
]])
