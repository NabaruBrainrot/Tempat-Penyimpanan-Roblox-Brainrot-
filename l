pcall(function()
    game:GetService("CoreGui"):FindFirstChild("PersistentToggleGui"):Destroy()
    game:GetService("CoreGui"):FindFirstChild("PremiumDeliveryGUI"):Destroy()
end)

local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PersistentToggleGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

local toggleImageBtn = Instance.new("ImageButton")
toggleImageBtn.Name = "HoverButton"
toggleImageBtn.Size = UDim2.new(0, 55, 0, 55)
toggleImageBtn.Position = UDim2.new(0, 10, 0.2, 0)
toggleImageBtn.Image = "rbxassetid://116189732890823"
toggleImageBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleImageBtn.BackgroundTransparency = 0.7
toggleImageBtn.Active = true
toggleImageBtn.Draggable = true
toggleImageBtn.Parent = ScreenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 9)
toggleCorner.Parent = toggleImageBtn

local stroke = Instance.new("UIStroke")
stroke.Parent = toggleImageBtn
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

local targetCanvasGroup
local isOpen = false

local function tryFindTarget()
    local sg = CoreGui:FindFirstChild("ScreenGui")
    if not sg then return end

    local children = sg:GetChildren()
    if not children[4] then return end

    local cg = children[4]
    if not cg:IsA("CanvasGroup") then return end

    local blur = cg:FindFirstChild("blurEffect")
    if blur then blur:Destroy() end

    targetCanvasGroup = cg
end

task.spawn(function()
    while true do
        if not targetCanvasGroup or not targetCanvasGroup.Parent then
            tryFindTarget()
        end
        task.wait(0.3)
    end
end)

toggleImageBtn.MouseButton1Click:Connect(function()
    if not targetCanvasGroup then return end

    isOpen = not isOpen
    targetCanvasGroup.Visible = isOpen
    targetCanvasGroup.GroupTransparency = isOpen and 0 or 1
    targetCanvasGroup.Active = isOpen
    targetCanvasGroup.Interactable = isOpen
end)

pcall(function()
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/osakaTP2/OsakaTP2/main/Escape%20Tsunami%20For%20BrainrotsV3"
    ))()
end)

local character, humanoidRootPart
local EventFolder = workspace:WaitForChild("EventParts")

local PullDelay = 0.1
local HeightOffset = 3
local active = false

local function setupCharacter(char)
    character = char
    humanoidRootPart = char:WaitForChild("HumanoidRootPart")
end

if player.Character then
    setupCharacter(player.Character)
end
player.CharacterAdded:Connect(setupCharacter)

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "PremiumDeliveryGUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 176, 0, 104)
frame.Position = UDim2.new(0.1, 0, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.BackgroundTransparency = 1
title.Text = "RadioActive Farm"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 16

local garis = Instance.new("Frame", frame)
garis.Size = UDim2.new(1, -20, 0, 1)
garis.Position = UDim2.new(0, 10, 0, 25)
garis.BackgroundColor3 = Color3.fromRGB(60,60,60)
garis.BorderSizePixel = 0

local farmToggleBtn = Instance.new("TextButton", frame)
farmToggleBtn.Size = UDim2.new(0.9, 0, 0, 34)
farmToggleBtn.Position = UDim2.new(0.05, 0, 0, 42)
farmToggleBtn.BackgroundColor3 = Color3.fromRGB(45,45,65)
farmToggleBtn.TextColor3 = Color3.new(1,1,1)
farmToggleBtn.Font = Enum.Font.GothamSemibold
farmToggleBtn.TextSize = 14
farmToggleBtn.Text = "▶ Start"
farmToggleBtn.AutoButtonColor = false
Instance.new("UICorner", farmToggleBtn).CornerRadius = UDim.new(0,6)

farmToggleBtn.MouseEnter:Connect(function()
    farmToggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,90)
end)

farmToggleBtn.MouseLeave:Connect(function()
    if active then
        farmToggleBtn.BackgroundColor3 = Color3.fromRGB(0,200,120)
    else
        farmToggleBtn.BackgroundColor3 = Color3.fromRGB(45,45,65)
    end
end)

local function getModelPart(model)
    if model.PrimaryPart then return model.PrimaryPart end
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            return v
        end
    end
end

task.spawn(function()
    while true do
        if active and humanoidRootPart then
            for _, model in ipairs(EventFolder:GetChildren()) do
                if model:IsA("Model") then
                    local part = getModelPart(model)
                    if part then
                        model:SetPrimaryPartCFrame(
                            CFrame.new(humanoidRootPart.Position + Vector3.new(0, HeightOffset, 0))
                        )
                    end
                end
            end
        end
        task.wait(PullDelay)
    end
end)

farmToggleBtn.MouseButton1Click:Connect(function()
    active = not active
    if active then
        farmToggleBtn.Text = "■ Stop"
        farmToggleBtn.BackgroundColor3 = Color3.fromRGB(0,200,120)
    else
        farmToggleBtn.Text = "▶ Start"
        farmToggleBtn.BackgroundColor3 = Color3.fromRGB(45,45,65)
    end
end)