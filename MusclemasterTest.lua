
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
    Farm     = Window:AddTab({ Title = "MAIN",     Icon = "sprout"   }),
    Combat   = Window:AddTab({ Title = "KILLER",   Icon = "sword"    }),
    Misc     = Window:AddTab({ Title = "Eggs",     Icon = "star"     }),
    Quest    = Window:AddTab({ Title = "QUEST",    Icon = "scroll"   }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

-- ================= SERVICES =================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesEvent = ReplicatedStorage:WaitForChild("RemotesEvent")

-- ===========================================================
--  TAB FARM
-- ===========================================================


-- AUTO FARM
local Players = game:GetService("Players")
local player = Players.LocalPlayer

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

local function GetPrompts(folder, positions)
    local EPSILON = 0.01
    local prompts = {}

    for _, obj in ipairs(folder:GetDescendants()) do
        if obj:IsA("BasePart") then
            local pos = obj.Position

            for _, target in ipairs(positions) do
                if (pos - target).Magnitude < EPSILON then
                    local prompt = obj:FindFirstChild("ProximityPromptMachine")

                    if prompt and prompt:IsA("ProximityPrompt") then
                        table.insert(prompts, prompt)
                    end
                end
            end
        end
    end

    return prompts
end


local function RunAutoFarm()

    local TARGET_POSITIONS = {
        Vector3.new(2747.89795, 7.65916204, 105.534966),
        Vector3.new(2747.89795, 7.65916204, 126.657951),
        Vector3.new(2743.69092, 11.6664858, 233.435394),
        Vector3.new(2743.69092, 11.6664858, 258.496918),
    }

    local MachinesFolder = workspace:WaitForChild("MachinesFolder")
    local MachineRemote = RemotesEvent.MachineActiveEvent

    local prompts = GetPrompts(MachinesFolder, TARGET_POSITIONS)
    if #prompts == 0 then return end

    table.insert(runningThreads, task.spawn(function()
        while AutoFarmEnabled do

            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            -- hanya jalan saat tidak duduk
            if humanoid and humanoid.SeatPart == nil then
                local prompt = prompts[rng:NextInteger(1,#prompts)]

                if prompt and prompt.Enabled then
                    fireproximityprompt(prompt)
                end
            end

            task.wait(0.3)
        end
    end))

    table.insert(runningThreads, task.spawn(function()
        while AutoFarmEnabled do
            MachineRemote:FireServer()
            task.wait(0.05)
        end
    end))
end


local AutoFarmToggle = Tabs.Farm:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false
})

AutoFarmToggle:OnChanged(function()

    if Options.AutoFarm.Value then
        stopAll()
        AutoFarmEnabled = true
        RunAutoFarm()
    else
        stopAll()
    end

end)







-- AUTO GLITCH
local Players = game:GetService("Players")
local player = Players.LocalPlayer

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
                        table.insert(prompts, prompt)
                    end
                end
            end
        end
    end

    return prompts
end

local function RunAutoGlitch()

    local TARGET_POSITIONS = {
        CFrame.new(2712.48022, 3.71804452, 299.783295),
        CFrame.new(2691.11182, 3.71804452, 299.783295),
        CFrame.new(2613.02808, 4.78257084, 289.732025),
        CFrame.new(2584.5542, 4.78257084, 289.732025),
    }

    local MachinesFolder = workspace:WaitForChild("MachinesFolder")
    local MachineRemote = RemotesEvent.MachineActiveEvent

    local prompts = CollectPrompts(MachinesFolder, TARGET_POSITIONS)
    if #prompts == 0 then return end

    table.insert(glitchThreads, task.spawn(function()
        while AutoGlitchEnabled do

            local character = player.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")

            -- Jalankan hanya saat tidak duduk
            if humanoid and humanoid.SeatPart == nil then
                local prompt = prompts[rng2:NextInteger(1,#prompts)]

                if prompt and prompt.Enabled then
                    fireproximityprompt(prompt)
                end
            end

            task.wait(0.3)
        end
    end))

    table.insert(glitchThreads, task.spawn(function()
        while AutoGlitchEnabled do
            MachineRemote:FireServer()
            task.wait(0.05)
        end
    end))
end


local AutoGlitchToggle = Tabs.Farm:AddToggle("AutoGlitch", {
    Title = "Auto Glitch",
    Default = false
})

AutoGlitchToggle:OnChanged(function()

    if Options.AutoGlitch.Value then
        stopAllGlitch()
        AutoGlitchEnabled = true
        RunAutoGlitch()
    else
        stopAllGlitch()
    end

end)







-- AUTO SPIN
local AutoSpin = false

local AutoSpinToggle = Tabs.Farm:AddToggle("AutoSpin", { Title = "Auto Spin", Default = false })
AutoSpinToggle:OnChanged(function()
    AutoSpin = Options.AutoSpin.Value
    if AutoSpin then
        task.spawn(function()
            while AutoSpin do
                RemotesEvent:WaitForChild("SpinFunction"):InvokeServer()
                task.wait(0.1)
            end
        end)
    end
end)



-- AUTO REBIRTH
local AutoRebirth = false

local AutoRebirthToggle = Tabs.Farm:AddToggle("AutoRebirth", { Title = "Auto Rebirth", Default = false })
AutoRebirthToggle:OnChanged(function()
    AutoRebirth = Options.AutoRebirth.Value
end)

task.spawn(function()
    while true do
        if AutoRebirth then
            RemotesEvent:WaitForChild("RebirthEvent"):FireServer()
        end
        task.wait(0.05)
    end
end)



-- ===========================================================
--  TAB COMBAT (dulu Player)
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
        if combat then combat:Activate() end
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

local PlayerDropdown = Tabs.Combat:AddDropdown("SelectPlayer", {
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

local KillPlayerToggle = Tabs.Combat:AddToggle("KillPlayer", { Title = "Kill Player", Default = false })
KillPlayerToggle:OnChanged(function()
    runningKill = Options.KillPlayer.Value
    if runningKill then
        task.spawn(AutoKillOne)
    end
end)

localPly.CharacterAdded:Connect(function()
    task.wait(1)
    if Options.KillPlayer.Value then
        runningKill = true
        task.spawn(AutoKillOne)
    end
end)



-- AUTO KILL ALL
local runningKillAll = false

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

local AutoKillToggle = Tabs.Combat:AddToggle("AutoKill", { Title = "Auto Kill", Default = false })
AutoKillToggle:OnChanged(function()
    runningKillAll = Options.AutoKill.Value
    if runningKillAll then
        task.spawn(AutoKillAll)
    end
end)

localPly.CharacterAdded:Connect(function()
    task.wait(1)
    if Options.AutoKill.Value then
        runningKillAll = true
        task.spawn(AutoKillAll)
    end
end)

-- ===========================================================
--  TAB QUEST
-- ===========================================================



-- [1] REDEEM CODE
Tabs.Quest:AddToggle("CollectCode", {
    Title = "Redeem Code",
    Description = "Redeem all codes automatically",
    Default = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                local remote = RemotesEvent:WaitForChild("CodeEnterEvent")
                local codes = {"Speedyblox", "MuscleDezz300", "Strongblox"}
                for _, code in ipairs(codes) do
                    if not Options.CollectCode.Value then break end
                    remote:FireServer(code)
                    task.wait(2)
                end
                Options.CollectCode:SetValue(false)
            end)
        end
    end
})



-- [2] COLLECT CHEST
Tabs.Quest:AddToggle("CollectChest", {
    Title = "Collect Chest",
    Description = "Claim all chests automatically",
    Default = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                local remote = RemotesEvent:WaitForChild("ChestClaimEvent")
                local chests = {
                    "Legend Chest", "Big Chest", "Stone Chest",
                    "Frost Chest", "Master Chest", "Emperor Chest",
                    "Ocean Chest", "Chest"
                }
                for _, chest in ipairs(chests) do
                    if not Options.CollectChest.Value then break end
                    remote:FireServer(chest)
                    task.wait(2)
                end
                Options.CollectChest:SetValue(false)
            end)
        end
    end
})



-- [3] COLLECT REWARD
Tabs.Quest:AddToggle("CollectReward", {
    Title = "Collect Reward",
    Description = "Automatic reward claims while active",
    Default = false,
    Callback = function(state)
        if state then
            task.spawn(function()
                local remote = RemotesEvent:WaitForChild("rewardClaim")
                local rewards = {"reward1", "reward2", "reward3", "reward4", "reward5"}
                while Options.CollectReward.Value do
                    for _, reward in ipairs(rewards) do
                        if not Options.CollectReward.Value then break end
                        remote:FireServer(reward)
                        task.wait(2)
                    end
                end
            end)
        end
    end
})



-- ===========================================================
--  TAB MISC
-- ===========================================================
local SelectedPet = "common"
local ToggleEggsEnabled = false

local OpenPetRemote = RemotesEvent:WaitForChild("OpenPetEvent")

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

-- ===========================================================
-- SETTINGS TAB
-- ===========================================================

-- ANTI AFK
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

local AntiAFKToggle = Tabs.Settings:AddToggle("AntiAFK", { Title = "Anti AFK", Default = false })
AntiAFKToggle:OnChanged(function()
    if Options.AntiAFK.Value then
        EnableAntiAFK()
    else
        DisableAntiAFK()
    end
end)

-- AUTO EGGS (Settings)
local AutoEggsToggle = Tabs.Settings:AddToggle("AutoEggs", { Title = "Auto Eggs", Default = false })
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

-- INSTANT HATCH
local instantHatchEnabled = false
local hatchLoop = nil
local hatchConnection = nil

local function disableHatchConnections()
    for _, v in pairs(getconnections(OpenPetRemote.OnClientEvent)) do
        v:Disable()
    end
end

local function enableInstantHatch()
    disableHatchConnections()
    hatchLoop = task.spawn(function()
        while instantHatchEnabled do
            task.wait(1)
            disableHatchConnections()
        end
    end)
    hatchConnection = OpenPetRemote.OnClientEvent:Connect(function(petName, eggModel)
        if not instantHatchEnabled then return end
        if not petName or not eggModel then return end
        pcall(function()
            eggModel.Transparency = 1
        end)
    end)
    print("Instant Hatch: ENABLED")
end

local function disableInstantHatch()
    if hatchLoop then
        task.cancel(hatchLoop)
        hatchLoop = nil
    end
    if hatchConnection then
        hatchConnection:Disconnect()
        hatchConnection = nil
    end
    for _, v in pairs(getconnections(OpenPetRemote.OnClientEvent)) do
        v:Enable()
    end
    print("Instant Hatch: DISABLED")
end

local InstantHatchToggle = Tabs.Settings:AddToggle("InstantHatch", {
    Title = "Instant Hatch",
    Description = "Toggle Instant Hatch (No Animation)",
    Default = false
})
InstantHatchToggle:OnChanged(function()
    instantHatchEnabled = Options.InstantHatch.Value
    if instantHatchEnabled then
        enableInstantHatch()
    else
        disableInstantHatch()
    end
end)

-- AUTO SELL (Settings)
Tabs.Settings:AddButton({
    Title = "Auto Sell",
    Description = "",
    Callback = function()
        print("open sell pets Ui")
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/NabaruBrainrot/Tempat-Penyimpanan-Roblox-Brainrot-/refs/heads/main/SellPets"))()
    end
})
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
    Title = "Muscle Master",
    Content = "Loaded Succesfully!",
    Duration = 5
})