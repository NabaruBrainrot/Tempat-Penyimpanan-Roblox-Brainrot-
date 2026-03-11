pcall(function()
    local cg = game:GetService("CoreGui"):FindFirstChild("PersistentToggleGui")
    if cg then cg:Destroy() end
    local pg = game:GetService("Players").LocalPlayer.PlayerGui:FindFirstChild("PremiumDeliveryGUI")
    if pg then pg:Destroy() end
end)

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- ================= FLOAT BUTTON =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PersistentToggleGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local toggleImageBtn = Instance.new("ImageButton")
toggleImageBtn.Name = "HoverButton"
toggleImageBtn.Size = UDim2.new(0, 55, 0, 55)
toggleImageBtn.Position = UDim2.new(0, 10, 0.2, 0)
toggleImageBtn.Image = "rbxassetid://108846514953006"
toggleImageBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleImageBtn.BackgroundTransparency = 0.7
toggleImageBtn.Active = true
toggleImageBtn.Draggable = true
toggleImageBtn.Parent = ScreenGui

Instance.new("UICorner", toggleImageBtn).CornerRadius = UDim.new(0, 9)

local stroke = Instance.new("UIStroke", toggleImageBtn)
stroke.Thickness = 3
stroke.Color = Color3.fromRGB(255, 255, 255)
stroke.Transparency = 0.5
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

toggleImageBtn.MouseEnter:Connect(function()
    TweenService:Create(toggleImageBtn, TweenInfo.new(0.15), {
        Size = UDim2.new(0, 60, 0, 60)
    }):Play()
end)

toggleImageBtn.MouseLeave:Connect(function()
    TweenService:Create(toggleImageBtn, TweenInfo.new(0.15), {
        Size = UDim2.new(0, 55, 0, 55)
    }):Play()
end)

-- ================= TARGET GUI (ANTI LAG) =================
local TARGET_SIZE = UDim2.fromOffset(500, 340)
local targetFrame
local isOpen = false
local preloaded = false

task.spawn(function()
    while not targetFrame do
        local screenGui = CoreGui:FindFirstChild("ScreenGui")
        if screenGui then
            for _, v in ipairs(screenGui:GetChildren()) do
                if v:IsA("Frame") and v.Size == TARGET_SIZE then
                    targetFrame = v
                    targetFrame.Visible = true
                    task.wait()
                    targetFrame.Visible = false
                    preloaded = true
                    break
                end
            end
        end
        task.wait(0.25)
    end
end)

toggleImageBtn.MouseButton1Click:Connect(function()
    if not targetFrame or not preloaded then return end
    isOpen = not isOpen
    targetFrame.Visible = isOpen
end)

-- ================= FLUENT UI =================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Muscle Master",
    SubTitle = "Premium",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 340),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Farm    = Window:AddTab({ Title = "Farm",   Icon = "sprout" }),
    Player  = Window:AddTab({ Title = "Player", Icon = "user" }),
    Misc    = Window:AddTab({ Title = "Misc",   Icon = "star" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

-- ===========================================================
--  TAB FARM
-- ===========================================================

local PlayersService = game:GetService("Players")
local localPlayer = PlayersService.LocalPlayer
local leaderstats = localPlayer:WaitForChild("leaderstats")
local rebirths = leaderstats:WaitForChild("Rebirths")

local AutoFarmEnabled = false
local runningThreads = {}
local rng = Random.new()

local function stopAll()
    AutoFarmEnabled = false
    for _, t in ipairs(runningThreads) do
        if t then task.cancel(t) end
    end
    table.clear(runningThreads)
end

local function GetPrompts(MachinesFolder, positions)
    local EPSILON = 0.01
    local prompts = {}
    for _, obj in ipairs(MachinesFolder:GetDescendants()) do
        if obj:IsA("BasePart") then
            local pos = obj.Position
            for _, target in ipairs(positions) do
                if (pos - target).Magnitude < EPSILON then
                    local prompt = obj:FindFirstChild("ProximityPromptMachine")
                    if prompt and prompt:IsA("ProximityPrompt") then
                        prompts[#prompts+1] = prompt
                    end
                end
            end
        end
    end
    return prompts
end

local function RunScriptBelow10()
    local TARGET_POSITIONS = {
        CFrame.new(-120.774185, 5.02033472, -56.9413261).Position,
        CFrame.new(-94.2546463, 5.02033472, -35.0815392).Position
    }
    local MachinesFolder = workspace:WaitForChild("MachinesFolder")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local MachineRemote = ReplicatedStorage.RemotesEvent.MachineActiveEvent
    local prompts = GetPrompts(MachinesFolder, TARGET_POSITIONS)
    if #prompts == 0 then return end

    table.insert(runningThreads, task.spawn(function()
        while AutoFarmEnabled do
            local prompt = prompts[rng:NextInteger(1, #prompts)]
            if prompt and prompt.Enabled then fireproximityprompt(prompt) end
            task.wait(0.1)
        end
    end))
    table.insert(runningThreads, task.spawn(function()
        while AutoFarmEnabled do
            MachineRemote:FireServer()
            task.wait(0.1)
        end
    end))
end

local function RunScriptAboveOrEqual10()
    local TARGET_POSITIONS = {
        Vector3.new(2747.89795, 7.65916204, 105.534966),
        Vector3.new(2747.89795, 7.65916204, 126.657951),
        Vector3.new(2743.69092, 11.6664858, 233.435394),
        Vector3.new(2743.69092, 11.6664858, 258.496918),
    }
    local MachinesFolder = workspace:WaitForChild("MachinesFolder")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local MachineRemote = ReplicatedStorage.RemotesEvent.MachineActiveEvent
    local prompts = GetPrompts(MachinesFolder, TARGET_POSITIONS)
    if #prompts == 0 then return end

    table.insert(runningThreads, task.spawn(function()
        while AutoFarmEnabled do
            local prompt = prompts[rng:NextInteger(1, #prompts)]
            if prompt and prompt.Enabled then fireproximityprompt(prompt) end
            task.wait(0.1)
        end
    end))
    table.insert(runningThreads, task.spawn(function()
        while AutoFarmEnabled do
            MachineRemote:FireServer()
            task.wait(0.05)
        end
    end))
end

local AutoFarmToggle = Tabs.Farm:AddToggle("AutoFarm", { Title = "Auto Farm", Default = false })
AutoFarmToggle:OnChanged(function()
    local Value = Options.AutoFarm.Value
    if Value then
        stopAll()
        AutoFarmEnabled = true
        if rebirths.Value < 10 then
            RunScriptBelow10()
        else
            RunScriptAboveOrEqual10()
        end
    else
        stopAll()
    end
end)

-- ===========================================================
-- AUTO GLITCH
-- ===========================================================

local AutoGlitchEnabled = false
local glitchThreads = {}
local rng2 = Random.new()

local function stopAllGlitch()
    AutoGlitchEnabled = false
    for _, t in ipairs(glitchThreads) do
        if t then task.cancel(t) end
    end
    table.clear(glitchThreads)
end

local function CollectPrompts(folder, positions)
    local EPSILON = 0.01
    local prompts = {}
    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("BasePart") then
            local pos = obj.Position
            for _, cf in ipairs(positions) do
                if (pos - cf.Position).Magnitude < EPSILON then
                    local prompt = obj:FindFirstChild("ProximityPromptMachine")
                    if prompt and prompt:IsA("ProximityPrompt") then
                        prompts[#prompts+1] = prompt
                    end
                end
            end
        end
    end
    return prompts
end

local function RunGlitchBelow10()
    local TARGET_POSITIONS = {
        CFrame.new(-41.5637741, 3.47935009, 44.4185333),
        CFrame.new(-24.1162872, 3.47935009, 44.4185333),
    }
    local MachinesFolder = workspace:WaitForChild("MachinesFolder")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local MachineRemote = ReplicatedStorage.RemotesEvent.MachineActiveEvent
    local prompts = CollectPrompts(MachinesFolder, TARGET_POSITIONS)
    if #prompts == 0 then return end

    table.insert(glitchThreads, task.spawn(function()
        while AutoGlitchEnabled do
            local prompt = prompts[rng2:NextInteger(1, #prompts)]
            if prompt and prompt.Enabled then fireproximityprompt(prompt) end
            task.wait(0.1)
        end
    end))
    table.insert(glitchThreads, task.spawn(function()
        while AutoGlitchEnabled do
            MachineRemote:FireServer()
            task.wait(0.1)
        end
    end))
end

local function RunGlitchAbove10()
    local TARGET_POSITIONS = {
        CFrame.new(2712.48022, 3.71804452, 299.783295),
        CFrame.new(2691.11182, 3.71804452, 299.783295),
        CFrame.new(2613.02808, 4.78257084, 289.732025),
        CFrame.new(2584.5542, 4.78257084, 289.732025),
    }
    local MachinesFolder = workspace:WaitForChild("MachinesFolder")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local MachineRemote = ReplicatedStorage.RemotesEvent.MachineActiveEvent
    local prompts = CollectPrompts(MachinesFolder, TARGET_POSITIONS)
    if #prompts == 0 then return end

    table.insert(glitchThreads, task.spawn(function()
        while AutoGlitchEnabled do
            local prompt = prompts[rng2:NextInteger(1, #prompts)]
            if prompt and prompt.Enabled then fireproximityprompt(prompt) end
            task.wait(0.1)
        end
    end))
    table.insert(glitchThreads, task.spawn(function()
        while AutoGlitchEnabled do
            MachineRemote:FireServer()
            task.wait(0.05)
        end
    end))
end

local AutoGlitchToggle = Tabs.Farm:AddToggle("AutoGlitch", { Title = "Auto Glitch", Default = false })
AutoGlitchToggle:OnChanged(function()
    local Value = Options.AutoGlitch.Value
    if Value then
        stopAllGlitch()
        AutoGlitchEnabled = true
        if rebirths.Value <= 10 then
            RunGlitchBelow10()
        else
            RunGlitchAbove10()
        end
    else
        stopAllGlitch()
    end
end)



-- ===========================================================
-- AUTO SPIN
-- ===========================================================
local AutoSpin = false

local AutoSpinToggle = Tabs.Farm:AddToggle("AutoSpin", { Title = "Auto Spin", Default = false })
AutoSpinToggle:OnChanged(function()
    AutoSpin = Options.AutoSpin.Value
    if AutoSpin then
        task.spawn(function()
            while AutoSpin do
                game:GetService("ReplicatedStorage")
                    :WaitForChild("RemotesEvent")
                    :WaitForChild("SpinFunction")
                    :InvokeServer()
                task.wait(0.1)
            end
        end)
    end
end)

-- =============================



-- ===========================================================
-- AUTO REBIRTH
-- ===========================================================
local AutoRebirth = false
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AutoRebirthToggle = Tabs.Farm:AddToggle("AutoRebirth", { Title = "Auto Rebirth", Default = false })
AutoRebirthToggle:OnChanged(function()
    AutoRebirth = Options.AutoRebirth.Value
end)

task.spawn(function()
    while true do
        if AutoRebirth then
            ReplicatedStorage
                :WaitForChild("RemotesEvent")
                :WaitForChild("RebirthEvent")
                :FireServer()
        end
        task.wait(0.05)
    end
end)

-- ===========================================================
-- SELECT PLAYER KILL
-- ===========================================================
local playerService = game:GetService("Players")
local localPly = playerService.LocalPlayer

local runningKill = false
local whitelist = {}
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

local function TeleportToTarget()
    if not selectedPlayerName then return end
    local target = playerService:FindFirstChild(selectedPlayerName)
    if not target or whitelist[target.Name] then return end
    if not target.Character or not localPly.Character then return end
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = localPly.Character:FindFirstChild("HumanoidRootPart")
    if not targetHRP or not myHRP then return end
    myHRP.CFrame = targetHRP.CFrame
end

local function AutoKillOne()
    while runningKill do
        TeleportToTarget()
        EquipTool("Punch")
        local combat = localPly.Character and localPly.Character:FindFirstChild("Punch")
        if combat then
            combat:Activate()
        end
        task.wait(0.05)
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

local PlayerDropdown = Tabs.Player:AddDropdown("SelectPlayer", {
    Title = "Select Player",
    Values = GetPlayerList(),
    Multi = false,
    Default = 1,
})

PlayerDropdown:OnChanged(function(Value)
    selectedPlayerName = Value
end)

local function RefreshPlayerDropdown()
    PlayerDropdown:SetValues(GetPlayerList())
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

-- Toggle Kill Player
local KillPlayerToggle = Tabs.Player:AddToggle("KillPlayer", { Title = "Kill Player", Default = false })
KillPlayerToggle:OnChanged(function()
    runningKill = Options.KillPlayer.Value
    if runningKill then
        task.spawn(AutoKillOne)
    end
end)

-- Auto-restart saat respawn (Kill Player)
localPly.CharacterAdded:Connect(function()
    task.wait(1)
    if Options.KillPlayer.Value then
        runningKill = true
        task.spawn(AutoKillOne)
    end
end)

-- ===========================================================
-- AUTO KILL ALL
-- ===========================================================
local runningKillAll = false

local function EquipToolAll(toolName)
    local backpack = localPly:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChild(toolName)
        if tool and localPly.Character and not localPly.Character:FindFirstChild(toolName) then
            local humanoid = localPly.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:EquipTool(tool)
            end
        end
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
                local myHRP = localPly.Character.HumanoidRootPart
                local targetHRP = plr.Character.HumanoidRootPart
                myHRP.CFrame = targetHRP.CFrame
                EquipToolAll("Punch")
                local combat = localPly.Character:FindFirstChild("Punch")
                if combat then
                    combat:Activate()
                end
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

local AutoKillToggle = Tabs.Player:AddToggle("AutoKill", { Title = "Auto Kill", Default = false })
AutoKillToggle:OnChanged(function()
    runningKillAll = Options.AutoKill.Value
    if runningKillAll then
        task.spawn(AutoKillAll)
    end
end)

-- Auto-restart saat respawn (Auto Kill All)
localPly.CharacterAdded:Connect(function()
    task.wait(1)
    if Options.AutoKill.Value then
        runningKillAll = true
        task.spawn(AutoKillAll)
    end
end)

-- ===========================================================
--  TAB MISC
-- ===========================================================
local SelectedPet = "common"
local ToggleEggsEnabled = false

local OpenPetRemote = game:GetService("ReplicatedStorage")
    :WaitForChild("RemotesEvent")
    :WaitForChild("OpenPetEvent")

local PetMapping = {
    Common    = "common",
    Rare      = "rare",
    Epic      = "epic",
    Legendary = "legendary",
    Mythic    = "mythic"
}

local EggsDropdown = Tabs.Misc:AddDropdown("SelectEggs", {
    Title = "Select Eggs",
    Values = {"Common", "Rare", "Epic", "Legendary", "Mythic"},
    Multi = false,
    Default = 1,
})

EggsDropdown:OnChanged(function(Value)
    SelectedPet = PetMapping[Value]
end)

local AutoEggsToggle = Tabs.Misc:AddToggle("AutoEggs", { Title = "Auto Eggs", Default = false })
AutoEggsToggle:OnChanged(function()
    ToggleEggsEnabled = Options.AutoEggs.Value
    if ToggleEggsEnabled then
        task.spawn(function()
            while ToggleEggsEnabled do
                OpenPetRemote:FireServer(SelectedPet)
                task.wait(0.1)
            end
        end)
    end
end)



-- 🔘 BUTTON
Tabs.Misc:AddButton({
    Title = "Auto Sell",
    Description = "Click to open Sell Pets Ui",
    Callback = function()
        print("open sell pets Ui")

        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/NabaruBrainrot/Tempat-Penyimpanan-Roblox-Brainrot-/refs/heads/main/SellPets"))()
    end
})



-- ===========================================================
local VirtualUser = game:GetService("VirtualUser")
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

local AntiAFKToggle = Tabs.Misc:AddToggle("AntiAFK", { Title = "Anti AFK", Default = false })
AntiAFKToggle:OnChanged(function()
    if Options.AntiAFK.Value then
        EnableAntiAFK()
    else
        DisableAntiAFK()
    end
end)

-- ===========================================================
-- SETTINGS TAB
-- ===========================================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/legend-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Legend",
    Content = "Script berhasil dimuat!",
    Duration = 5
})