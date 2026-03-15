
-- ============================================================
--        Muscle Master - WindUI Version
--        Original by fadhen | Converted to WindUI
-- ============================================================

pcall(function()
    local cg = game:GetService("CoreGui"):FindFirstChild("MusclemasterWindUI")
    if cg then cg:Destroy() end
end)

-- ================= SERVICES =================
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser       = game:GetService("VirtualUser")

local LocalPlayer  = Players.LocalPlayer
local playerService = Players

-- ================= REMOTES =================
local RemotesEvent       = ReplicatedStorage:WaitForChild("RemotesEvent", 10)
local machineactive      = RemotesEvent:WaitForChild("MachineActiveFunction", 10)
local MachineActiveEvent = RemotesEvent:WaitForChild("MachineActiveEvent", 10)
local spinfu             = RemotesEvent:WaitForChild("SpinFunction", 10)
local machineuse         = LocalPlayer:WaitForChild("Machineuse", 10)
local machinesFolder     = workspace:WaitForChild("MachinesFolder", 10)

if not machineactive or not MachineActiveEvent or not spinfu then
    warn("[Script] Gagal menemukan RemoteEvents!")
end

-- ================= LOAD WINDUI =================
local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()

-- ================= THEME =================
WindUI:AddTheme({
    Name       = "MuscleTheme",
    Accent     = Color3.fromHex("#1c1c1f"),
    Background = Color3.fromHex("#111113"),
    Outline    = Color3.fromHex("#ffffff"),
    Text       = Color3.fromHex("#ffffff"),
    Placeholder= Color3.fromHex("#6b6b6b"),
    Button     = Color3.fromHex("#3f3f46"),
    Icon       = Color3.fromHex("#a1a1aa"),
})
WindUI:SetTheme("MuscleTheme")

-- ================= WINDOW =================
local Window = WindUI:CreateWindow({
    Title       = "Muscle Master",
    Icon        = "dumbbell",
    Author      = "by fadhen",
    Folder      = "MusclemasterWindUI",
    Size        = UDim2.fromOffset(560, 400),
    MinSize     = Vector2.new(520, 360),
    Transparent = true,
    Resizable   = true,
    Theme       = "MuscleTheme",
})

-- ================= TABS =================
local FarmTab   = Window:Tab({ Title = "Main",   Icon = "sprout"   })
local PlayerTab = Window:Tab({ Title = "Player", Icon = "sword"    })
local MiscTab   = Window:Tab({ Title = "Misc",   Icon = "star"     })
local QuestTab  = Window:Tab({ Title = "Quest",  Icon = "scroll"   })

-- ===========================================================
--  TAB FARM
-- ===========================================================

local FarmSection = FarmTab:Section({ Title = "Auto Farm" })

-- AUTO FARM (Bench Press + Pull Ups)
local farmMachines = {}
local farmTargetNames = {
    ["Bench Press Muscle Emperor"] = true,
    ["Pull Ups Muscle Emperor"]    = true,
}
for _, v in ipairs(machinesFolder:GetChildren()) do
    if farmTargetNames[v.Name] then
        table.insert(farmMachines, v)
    end
end

local farmCooldown  = {}
local FARM_COOLDOWN = 0
local AutoFarmValue = false

local function tryUseFarmMachine(machine)
    local now = tick()
    if (now - (farmCooldown[machine] or 0)) < FARM_COOLDOWN then return end
    farmCooldown[machine] = now
    pcall(function()
        machineactive:InvokeServer(machine, true)
    end)
end

FarmSection:Toggle({
    Title    = "Auto Farm",
    Default  = false,
    Callback = function(Value)
        AutoFarmValue = Value
    end,
})

task.spawn(function()
    while true do
        task.wait(0.01)
        if not AutoFarmValue then continue end
        if machineuse.Value == nil then
            task.wait(1)
            for _, machine in ipairs(farmMachines) do
                if not AutoFarmValue then break end
                if machineuse.Value ~= nil then break end
                tryUseFarmMachine(machine)
                task.wait(0.5)
            end
        else
            local ok, err = pcall(function()
                MachineActiveEvent:FireServer()
            end)
            if not ok then
                warn("[AutoFarm] FireServer gagal:", err)
                task.wait(0.5)
            end
        end
    end
end)

-- AUTO GLITCH (Squat + Rock Squat)
local glitchMachines = {}
local glitchTargetNames = {
    ["Squat Muscle Emperor"]      = true,
    ["Rock Squat Muscle Emperor"] = true,
}
for _, v in ipairs(machinesFolder:GetChildren()) do
    if glitchTargetNames[v.Name] then
        table.insert(glitchMachines, v)
    end
end

local glitchCooldown  = {}
local GLITCH_COOLDOWN = 0
local AutoGlitchValue = false

local function tryUseGlitchMachine(machine)
    local now = tick()
    if (now - (glitchCooldown[machine] or 0)) < GLITCH_COOLDOWN then return end
    glitchCooldown[machine] = now
    pcall(function()
        machineactive:InvokeServer(machine, true)
    end)
end

FarmSection:Toggle({
    Title    = "Auto Glitch",
    Default  = false,
    Callback = function(Value)
        AutoGlitchValue = Value
    end,
})

task.spawn(function()
    while true do
        task.wait(0.01)
        if not AutoGlitchValue then continue end
        if machineuse.Value == nil then
            task.wait(1)
            for _, machine in ipairs(glitchMachines) do
                if not AutoGlitchValue then break end
                if machineuse.Value ~= nil then break end
                tryUseGlitchMachine(machine)
                task.wait(0.5)
            end
        else
            local ok, err = pcall(function()
                MachineActiveEvent:FireServer()
            end)
            if not ok then
                warn("[AutoGlitch] FireServer gagal:", err)
                task.wait(0.5)
            end
        end
    end
end)

-- AUTO SPIN
local AutoSpinValue = false

FarmSection:Toggle({
    Title    = "Auto Spin",
    Default  = false,
    Callback = function(Value)
        AutoSpinValue = Value
        if Value then
            task.spawn(function()
                while AutoSpinValue do
                    RemotesEvent:WaitForChild("SpinFunction"):InvokeServer()
                    task.wait(0.1)
                end
            end)
        end
    end,
})

-- AUTO REBIRTH
local AutoRebirthValue = false

FarmSection:Toggle({
    Title    = "Auto Rebirth",
    Default  = false,
    Callback = function(Value)
        AutoRebirthValue = Value
    end,
})

task.spawn(function()
    while true do
        if AutoRebirthValue then
            RemotesEvent:WaitForChild("RebirthEvent"):FireServer()
        end
        task.wait(0.05)
    end
end)

-- ===========================================================
--  TAB PLAYER (COMBAT)
-- ===========================================================

local CombatSection = PlayerTab:Section({ Title = "Combat" })

local localPly          = Players.LocalPlayer
local runningKill       = false
local runningKillAll    = false
local whitelist         = {}
local selectedPlayerName = nil

local function EquipTool(toolName)
    local backpack = localPly:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild(toolName)
        if tool and localPly.Character and not localPly.Character:FindFirstChild(toolName) then
            local humanoid = localPly.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid:EquipTool(tool) end
        end
    end
end

local function AutoKillOne()
    while runningKill do
        if selectedPlayerName then
            local target = playerService:FindFirstChild(selectedPlayerName)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
                and localPly.Character and localPly.Character:FindFirstChild("HumanoidRootPart") then
                local startTime = tick()
                while tick() - startTime < 0.5 and runningKill do
                    local myHRP    = localPly.Character.HumanoidRootPart
                    local targetHRP = target.Character.HumanoidRootPart
                    myHRP.CFrame = targetHRP.CFrame
                    EquipTool("Punch")
                    local combat = localPly.Character:FindFirstChild("Punch")
                    if combat then combat:Activate() end
                    task.wait(0.05)
                end
            end
        end
        task.wait(0.1)
    end
end

local function TeleportKillTargets()
    for _, plr in ipairs(playerService:GetPlayers()) do
        if runningKillAll
            and plr ~= localPly
            and not whitelist[plr.Name]
            and plr.Character
            and plr.Character:FindFirstChild("HumanoidRootPart")
            and localPly.Character
            and localPly.Character:FindFirstChild("HumanoidRootPart") then
            local startTime = tick()
            while tick() - startTime < 0.5 and runningKillAll do
                local myHRP     = localPly.Character.HumanoidRootPart
                local targetHRP = plr.Character.HumanoidRootPart
                myHRP.CFrame = targetHRP.CFrame
                EquipTool("Punch")
                local combat = localPly.Character:FindFirstChild("Punch")
                if combat then combat:Activate() end
                task.wait(0.05)
            end
        end
    end
end

local function AutoKillAll()
    while runningKillAll do
        TeleportKillTargets()
        task.wait(0.1)
    end
end

local function GetPlayerList()
    local list = {}
    for _, plr in ipairs(playerService:GetPlayers()) do
        if plr ~= localPly then
            table.insert(list, plr.Name)
        end
    end
    return list
end

-- Player Dropdown
local PlayerDropdown = CombatSection:Dropdown({
    Title    = "Select Player",
    Options  = GetPlayerList(),
    Default  = nil,
    Callback = function(Value)
        selectedPlayerName = Value
    end,
})

local function RefreshPlayerDropdown()
    if PlayerDropdown and PlayerDropdown.Refresh then
        PlayerDropdown:Refresh(GetPlayerList())
    end
end

task.wait()
RefreshPlayerDropdown()

playerService.PlayerAdded:Connect(function()
    task.wait(0.1)
    RefreshPlayerDropdown()
end)

playerService.PlayerRemoving:Connect(function(plr)
    task.wait()
    RefreshPlayerDropdown()
    if selectedPlayerName == plr.Name then
        selectedPlayerName = nil
    end
end)

-- Kill Player
CombatSection:Toggle({
    Title    = "Kill Player",
    Default  = false,
    Callback = function(Value)
        runningKill = Value
        if Value then
            game:GetService("ReplicatedStorage"):WaitForChild("RemotesEvent"):WaitForChild("SizeChanged"):FireServer(unpack({ 1 }))
            task.spawn(AutoKillOne)
        end
    end,
})

localPly.CharacterAdded:Connect(function()
    task.wait(1)
    if runningKill then
        game:GetService("ReplicatedStorage"):WaitForChild("RemotesEvent"):WaitForChild("SizeChanged"):FireServer(unpack({ 1 }))
        task.spawn(AutoKillOne)
    end
    if runningKillAll then
        game:GetService("ReplicatedStorage"):WaitForChild("RemotesEvent"):WaitForChild("SizeChanged"):FireServer(unpack({ 1 }))
        task.spawn(AutoKillAll)
    end
end)

-- Auto Kill All
CombatSection:Toggle({
    Title    = "Auto Kill All",
    Default  = false,
    Callback = function(Value)
        runningKillAll = Value
        if Value then
            game:GetService("ReplicatedStorage"):WaitForChild("RemotesEvent"):WaitForChild("SizeChanged"):FireServer(unpack({ 1 }))
            task.spawn(AutoKillAll)
        end
    end,
})

-- ===========================================================
--  TAB MISC
-- ===========================================================

local MiscSection = MiscTab:Section({ Title = "Pets" })

local SelectedPet        = "common"
local ToggleEggsEnabled  = false
local OpenPetRemote      = RemotesEvent:WaitForChild("OpenPetEvent")

local PetMapping = {
    Common    = "common",
    Rare      = "rare",
    Epic      = "epic",
    Legendary = "legendary",
    Mythic    = "mythic",
}

MiscSection:Dropdown({
    Title    = "Select Eggs",
    Options  = { "Common", "Rare", "Epic", "Legendary", "Mythic" },
    Default  = "Common",
    Callback = function(Value)
        SelectedPet = PetMapping[Value] or "common"
    end,
})

MiscSection:Toggle({
    Title    = "Auto Eggs",
    Default  = false,
    Callback = function(Value)
        ToggleEggsEnabled = Value
        if Value then
            task.spawn(function()
                while ToggleEggsEnabled do
                    OpenPetRemote:FireServer(SelectedPet)
                    task.wait(0.1)
                end
            end)
        end
    end,
})

-- INSTANT HATCH
local OpenPetEvent        = RemotesEvent:WaitForChild("OpenPetEvent")
local instantHatchEnabled = false
local hatchLoop           = nil
local hatchConnection     = nil

local function disableConnections()
    for _, v in pairs(getconnections(OpenPetEvent.OnClientEvent)) do
        v:Disable()
    end
end

local function enableInstantHatch()
    disableConnections()
    hatchLoop = task.spawn(function()
        while instantHatchEnabled do
            task.wait(1)
            disableConnections()
        end
    end)
    hatchConnection = OpenPetEvent.OnClientEvent:Connect(function(petName, eggModel)
        if not instantHatchEnabled then return end
        if not petName or not eggModel then return end
        pcall(function()
            eggModel.Transparency = 1
        end)
    end)
end

local function disableInstantHatch()
    if hatchLoop then task.cancel(hatchLoop); hatchLoop = nil end
    if hatchConnection then hatchConnection:Disconnect(); hatchConnection = nil end
    for _, v in pairs(getconnections(OpenPetEvent.OnClientEvent)) do
        v:Enable()
    end
end

MiscSection:Toggle({
    Title    = "Instant Hatch",
    Default  = false,
    Callback = function(Value)
        instantHatchEnabled = Value
        if Value then
            enableInstantHatch()
        else
            disableInstantHatch()
        end
    end,
})

MiscSection:Button({
    Title    = "Auto Sell Pets",
    Callback = function()
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/NabaruBrainrot/Tempat-Penyimpanan-Roblox-Brainrot-/refs/heads/main/SellPets"
        ))()
    end,
})

-- ===========================================================
--  TAB QUEST
-- ===========================================================

local QuestSection      = QuestTab:Section({ Title = "Utility" })
local AntiAFKConnection = nil

local function EnableAntiAFK()
    if AntiAFKConnection then return end
    AntiAFKConnection = localPly.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end

local function DisableAntiAFK()
    if AntiAFKConnection then
        AntiAFKConnection:Disconnect()
        AntiAFKConnection = nil
    end
end

QuestSection:Toggle({
    Title    = "Anti AFK",
    Default  = false,
    Callback = function(Value)
        if Value then
            EnableAntiAFK()
        else
            DisableAntiAFK()
        end
    end,
})

-- ===========================================================
--  STARTUP NOTIFICATION
-- ===========================================================

WindUI:Notification({
    Title    = "Muscle Master",
    Content  = "Script berhasil diload! by fadhen",
    Icon     = "check",
    Duration = 5,
})
