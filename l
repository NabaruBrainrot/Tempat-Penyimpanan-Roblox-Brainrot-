---Ghost Gui UI Library
loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/UI-Library/refs/heads/main/Ghost%20Gui'))()
game.CoreGui.GhostGui.MainFrame.Title.Text = "Title Here"
---


AddContent("Switch", "Secret Farm", [[
-- ===== TOGGLE ON =====

_G.SecretAutoFarm = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local targetFolder = workspace:WaitForChild("ActiveBrainrots"):WaitForChild("Secret")

-- === CFRAME ===
local CF_RUN = CFrame.new(
    2466.04712, 50.1636543, -0.837399483,
    0.180595279, 0.529440939, -0.82890147,
   -0.00590559095, 0.843327045, 0.537368238,
    0.98353976, -0.0921510085, 0.15542753
)

local CF_BACK = CFrame.new(
    123.538361, 21.1036148, 0.921822429,
    0.0287084393, 0.123787589, -0.991893351,
    0.00509225251, 0.992271364, 0.123982146,
    0.99957478, -0.00861030538, 0.0278562028
)

-- === UTIL ===
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart", 5)
end

local function getRate(model)
    local rate = model:FindFirstChild("Handle")
        and model.Handle:FindFirstChild("StatsGui")
        and model.Handle.StatsGui:FindFirstChild("Frame")
        and model.Handle.StatsGui.Frame:FindFirstChild("Rate")

    if not rate or not rate:IsA("TextLabel") then return 0 end
    if rate.Text == "" or rate.Text == "N/A" then return 0 end

    local text = string.lower(rate.Text)
    local num = tonumber(text:match("%d+%.?%d*")) or 0

    if text:find("k") then num *= 1e3
    elseif text:find("m") then num *= 1e6
    elseif text:find("b") then num *= 1e9 end

    return num
end

-- === AUTO HOLD ===
local autoHold = false
RunService.Heartbeat:Connect(function()
    if not _G.SecretAutoFarm or not autoHold then return end

    for _, v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ProximityPrompt") and v.Enabled then
            v.HoldDuration = 0
            pcall(function()
                v:InputHoldBegin()
                v:InputHoldEnd()
            end)
        end
    end
end)

-- === MAIN LOOP ===
task.spawn(function()
    while _G.SecretAutoFarm do
        local hrp = getHRP()
        if not hrp then break end

        -- TELEPORT RUN
        hrp.CFrame = CF_RUN
        task.wait(0.6)

        -- CARI MODEL TERBESAR
        local bestModel, bestRate = nil, 0
        for _, model in ipairs(targetFolder:GetChildren()) do
            if model:IsA("Model") then
                local rate = getRate(model)
                if rate > bestRate then
                    bestRate = rate
                    bestModel = model
                end
            end
        end

        -- TELEPORT KE MODEL
        if bestModel then
            local part = bestModel.PrimaryPart or bestModel:FindFirstChildWhichIsA("BasePart")
            if part then
                hrp.CFrame = part.CFrame
                autoHold = true
                task.wait(0.7)
                autoHold = false
            end
        end

        -- TELEPORT BACK
        hrp.CFrame = CF_BACK
        task.wait(1)
    end
end)

print("✅ Secret Auto Farm ON")
]], [[
-- ===== TOGGLE OFF =====

_G.SecretAutoFarm = false
print("❌ Secret Auto Farm OFF")
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








AddContent("Switch", "Remove Tsunami", [[
-- ===== TOGGLE ON =====
_G.AntiTsunami = true

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local workspace = game:GetService("Workspace")

-- hapus folder jika sudah ada
local folder = workspace:FindFirstChild("ActiveTsunamis")
if folder then
    folder:Destroy()
end

-- jaga-jaga kalau muncul lagi
_G.AntiTsunamiConnection = workspace.ChildAdded:Connect(function(child)
    if _G.AntiTsunami and child.Name == "ActiveTsunamis" then
        child:Destroy()
    end
end)

print("Remove Tsunami: ON")
]], [[
-- ===== TOGGLE OFF =====
_G.AntiTsunami = false

if _G.AntiTsunamiConnection then
    _G.AntiTsunamiConnection:Disconnect()
    _G.AntiTsunamiConnection = nil
end

print("Remove Tsunami: OFF")
]])