---Ghost Gui UI Library
loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/UI-Library/refs/heads/main/Ghost%20Gui'))()
game.CoreGui.GhostGui.MainFrame.Title.Text = "Title Here"
---


AddContent("Switch", "Auto Fly", [[
-- ===== TOGGLE ON =====

_G.AutoFly = true
print("Auto Fly: true")

-- Jalankan Fly Script
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"
))()

]], [[
-- ===== TOGGLE OFF =====

_G.AutoFly = false
print("Auto Fly dimatikan")

-- (Optional)
-- Kalau nanti punya stop-fly script, taruh di sini
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