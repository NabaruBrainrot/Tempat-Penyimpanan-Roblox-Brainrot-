
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
    Farm     = Window:AddTab({ Title = "Farm",     Icon = "sprout"   }),
    Combat   = Window:AddTab({ Title = "Combat",   Icon = "sword"    }),
    Misc     = Window:AddTab({ Title = "Misc",     Icon = "star"     }),
    Quest    = Window:AddTab({ Title = "Quest",    Icon = "scroll"   }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}

local Options = Fluent.Options

-- ================= SERVICES (SHARED) =================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesEvent      = ReplicatedStorage:WaitForChild("RemotesEvent", 10)
local machineactive     = RemotesEvent:WaitForChild("MachineActiveFunction", 10)
local MachineActiveEvent = RemotesEvent:WaitForChild("MachineActiveEvent", 10)
local spinfu            = RemotesEvent:WaitForChild("SpinFunction", 10)
local LocalPlayer       = Players.LocalPlayer
local machineuse        = LocalPlayer:WaitForChild("Machineuse", 10)
local machinesFolder    = workspace:WaitForChild("MachinesFolder", 10)

if not machineactive or not MachineActiveEvent or not spinfu then
    warn("[Script] Gagal menemukan RemoteEvents!")
    -- tidak pakai return agar toggle tetap muncul
end

-- ===========================================================
--  TAB FARM
-- ===========================================================

-- AUTO FARM (Bench Press + Pull Ups)
local AutoFarmToggle = Tabs.Farm:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false
})

local farmMachines = {}
local farmTargetNames = {
    ["Bench Press Muscle Emperor"] = true,
    ["Pull Ups Muscle Emperor"] = true,
}
for _, v in ipairs(machinesFolder:GetChildren()) do
    if farmTargetNames[v.Name] then
        table.insert(farmMachines, v)
    end
end

local farmCooldown = {}
local FARM_COOLDOWN = 0.5

local function tryUseFarmMachine(machine)
    local now = tick()
    if (now - (farmCooldown[machine] or 0)) < FARM_COOLDOWN then return end
    farmCooldown[machine] = now
    local ok, err = pcall(function()
        machineactive:InvokeServer(machine, true)
    end)
    if not ok then
        warn("[AutoFarm] Gagal invoke:", machine.Name, "-", err)
    end
end

task.spawn(function()
    while true do
        task.wait(0.01)
        if not AutoFarmToggle.Value then continue end

        if machineuse.Value == nil then
            task.wait(1)
            for _, machine in ipairs(farmMachines) do
                if not AutoFarmToggle.Value then break end
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
local AutoGlitchToggle = Tabs.Farm:AddToggle("AutoGlitch", {
    Title = "Auto Glitch",
    Default = false
})

local glitchMachines = {}
local glitchTargetNames = {
    ["Squat Muscle Emperor"] = true,
    ["Rock Squat Muscle Emperor"] = true,
}
for _, v in ipairs(machinesFolder:GetChildren()) do
    if glitchTargetNames[v.Name] then
        table.insert(glitchMachines, v)
    end
end

local glitchCooldown = {}
local GLITCH_COOLDOWN = 0.5

local function tryUseGlitchMachine(machine)
    local now = tick()
    if (now - (glitchCooldown[machine] or 0)) < GLITCH_COOLDOWN then return end
    glitchCooldown[machine] = now
    local ok, err = pcall(function()
        machineactive:InvokeServer(machine, true)
    end)
    if not ok then
        warn("[AutoGlitch] Gagal invoke:", machine.Name, "-", err)
    end
end

task.spawn(function()
    while true do
        task.wait(0.01)
        if not AutoGlitchToggle.Value then continue end

        if machineuse.Value == nil then
            task.wait(1)
            for _, machine in ipairs(glitchMachines) do
                if not AutoGlitchToggle.Value then break end
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
--  TAB COMBAT
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

local function AutoKillOne()
	while runningKill do
		if selectedPlayerName then
			local target = playerService:FindFirstChild(selectedPlayerName)
			if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
				and localPly.Character and localPly.Character:FindFirstChild("HumanoidRootPart") then
				local startTime = tick()
				while tick() - startTime < 0.5 and runningKill do
					local myHRP = localPly.Character.HumanoidRootPart
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
		game:GetService("ReplicatedStorage"):WaitForChild("RemotesEvent"):WaitForChild("SizeChanged"):FireServer(unpack({ 1 }))
		task.spawn(AutoKillOne)
	end
end)

localPly.CharacterAdded:Connect(function()
	task.wait(1)
	if Options.KillPlayer.Value then
		runningKill = true
		game:GetService("ReplicatedStorage"):WaitForChild("RemotesEvent"):WaitForChild("SizeChanged"):FireServer(unpack({ 1 }))
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
		game:GetService("ReplicatedStorage"):WaitForChild("RemotesEvent"):WaitForChild("SizeChanged"):FireServer(unpack({ 1 }))
		task.spawn(AutoKillAll)
	end
end)

localPly.CharacterAdded:Connect(function()
	task.wait(1)
	if Options.AutoKill.Value then
		runningKillAll = true
		game:GetService("ReplicatedStorage"):WaitForChild("RemotesEvent"):WaitForChild("SizeChanged"):FireServer(unpack({ 1 }))
		task.spawn(AutoKillAll)
	end
end)

-- ===========================================================
--  TAB QUEST
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

local AntiAFKToggle = Tabs.Quest:AddToggle("AntiAFK", { Title = "Anti AFK", Default = false })
AntiAFKToggle:OnChanged(function()
    if Options.AntiAFK.Value then
        EnableAntiAFK()
    else
        DisableAntiAFK()
    end
end)

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

-- INSTANT HATCH
local OpenPetEvent = RemotesEvent:WaitForChild("OpenPetEvent")

local instantHatchEnabled = false
local hatchLoop = nil
local hatchConnection = nil

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

    for _, v in pairs(getconnections(OpenPetEvent.OnClientEvent)) do
        v:Enable()
    end

    print("Instant Hatch: DISABLED")
end

local InstantHatchToggle = Tabs.Misc:AddToggle("InstantHatch", {
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

Tabs.Misc:AddButton({
    Title = "Auto Sell",
    Description = "",
    Callback = function()
        print("open sell pets Ui")
        loadstring(game:HttpGet(
            "https://raw.githubusercontent.com/NabaruBrainrot/Tempat-Penyimpanan-Roblox-Brainrot-/refs/heads/main/SellPets"))()
    end
})

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
    Title = "Muscle Master",
    Content = "Loaded Succesfully!",
    Duration = 5
})
