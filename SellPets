local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local sellRemote = ReplicatedStorage:WaitForChild("RemotesEvent"):WaitForChild("SellPetEvent")

local selectedFolder = "common"
local selectedPets = {}
local autoSell = false
local sellDelay = 1
local rarities = {"common", "rare", "epic", "legendary", "mythic"}

local rarityColors = {
	common    = Color3.fromRGB(160, 160, 160),
	rare      = Color3.fromRGB(80, 140, 255),
	epic      = Color3.fromRGB(180, 80, 255),
	legendary = Color3.fromRGB(255, 180, 40),
	mythic    = Color3.fromRGB(255, 80, 120),
}

local gui = Instance.new("ScreenGui")
gui.Name = "AutoSellGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = game.CoreGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 176, 0, 154)
main.AnchorPoint = Vector2.new(0.5, 0)
main.Position = UDim2.new(0.5, 0, 0, -15)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 11)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 80)
mainStroke.Thickness = 1.2
mainStroke.Parent = main

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 31)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
titleBar.BorderSizePixel = 0
titleBar.Parent = main

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 11)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -35, 1, 0)
titleLabel.Position = UDim2.new(0, 9, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.fromRGB(230, 230, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 12
titleLabel.Text = "🐾 Auto Sell Pets"
titleLabel.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 22, 0, 22)
minBtn.Position = UDim2.new(1, -26, 0, 4)
minBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 68)
minBtn.BorderSizePixel = 0
minBtn.Text = "–"
minBtn.TextColor3 = Color3.fromRGB(200, 200, 230)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 13
minBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(1, 0)
minCorner.Parent = minBtn

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, 0, 1, -31)
content.Position = UDim2.new(0, 0, 0, 31)
content.BackgroundTransparency = 1
content.Parent = main

local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0, 8)
pad.PaddingRight = UDim.new(0, 8)
pad.PaddingTop = UDim.new(0, 7)
pad.Parent = content

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = content

local function makeButton(text, color, layoutOrder)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 29)
	btn.BackgroundColor3 = color or Color3.fromRGB(40, 40, 58)
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(230, 230, 255)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 11
	btn.LayoutOrder = layoutOrder or 0
	btn.Parent = content
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 8)
	c.Parent = btn
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(
				math.clamp(btn.BackgroundColor3.R * 255 + 20, 0, 255),
				math.clamp(btn.BackgroundColor3.G * 255 + 20, 0, 255),
				math.clamp(btn.BackgroundColor3.B * 255 + 20, 0, 255)
			)
		}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = color or Color3.fromRGB(40, 40, 58)
		}):Play()
	end)
	return btn
end

local toggleBtn = makeButton("AUTO SELL  ●  OFF", Color3.fromRGB(40, 40, 58), 1)
local folderBtn = makeButton("📁  Folder: common", Color3.fromRGB(35, 35, 52), 2)
local petBtn    = makeButton("🐾  Select Pets ▾", Color3.fromRGB(35, 35, 52), 3)

local dropFrame = Instance.new("Frame")
dropFrame.Name = "DropFrame"
dropFrame.Size = UDim2.new(0, 176, 0, 0)
dropFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 36)
dropFrame.BorderSizePixel = 0
dropFrame.ClipsDescendants = true
dropFrame.Visible = false
dropFrame.ZIndex = 10
dropFrame.Parent = gui

local dropCorner = Instance.new("UICorner")
dropCorner.CornerRadius = UDim.new(0, 9)
dropCorner.Parent = dropFrame

local dropStroke = Instance.new("UIStroke")
dropStroke.Color = Color3.fromRGB(60, 60, 80)
dropStroke.Thickness = 1
dropStroke.Parent = dropFrame

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollBarThickness = 3
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ZIndex = 10
scroll.Parent = dropFrame

local scrollLayout = Instance.new("UIListLayout")
scrollLayout.Padding = UDim.new(0, 2)
scrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
scrollLayout.Parent = scroll

local scrollPad = Instance.new("UIPadding")
scrollPad.PaddingLeft = UDim.new(0, 6)
scrollPad.PaddingRight = UDim.new(0, 6)
scrollPad.PaddingTop = UDim.new(0, 6)
scrollPad.PaddingBottom = UDim.new(0, 6)
scrollPad.Parent = scroll

local function positionDropBelow(btn)
	local absPos = btn.AbsolutePosition
	local absSize = btn.AbsoluteSize
	dropFrame.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 4)
end

local function openDrop(height)
	dropFrame.Visible = true
	TweenService:Create(dropFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {
		Size = UDim2.new(0, 176, 0, math.min(height, 176))
	}):Play()
end

local function closeDrop()
	TweenService:Create(dropFrame, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
		Size = UDim2.new(0, 176, 0, 0)
	}):Play()
	task.delay(0.16, function() dropFrame.Visible = false end)
end

local function clearScroll()
	for _, c in pairs(scroll:GetChildren()) do
		if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
			c:Destroy()
		end
	end
end

local function makeDropItem(text, color, onClick)
	local item = Instance.new("TextButton")
	item.Size = UDim2.new(1, 0, 0, 29)
	item.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
	item.BorderSizePixel = 0
	item.Text = text
	item.TextColor3 = color or Color3.fromRGB(210, 210, 240)
	item.Font = Enum.Font.Gotham
	item.TextSize = 11
	item.ZIndex = 10
	item.Parent = scroll
	local ic = Instance.new("UICorner")
	ic.CornerRadius = UDim.new(0, 6)
	ic.Parent = item
	item.MouseEnter:Connect(function() item.BackgroundColor3 = Color3.fromRGB(50, 50, 70) end)
	item.MouseLeave:Connect(function() item.BackgroundColor3 = Color3.fromRGB(35, 35, 50) end)
	item.MouseButton1Click:Connect(onClick)
	return item
end

-- ===================== FOLDER DROPDOWN =====================
folderBtn.MouseButton1Click:Connect(function()
	clearScroll()
	positionDropBelow(folderBtn)
	for _, rarity in pairs(rarities) do
		local col = rarityColors[rarity] or Color3.fromRGB(200, 200, 200)
		makeDropItem("📁  "..rarity:sub(1,1):upper()..rarity:sub(2), col, function()
			selectedFolder = rarity
			folderBtn.Text = "📁  "..rarity:sub(1,1):upper()..rarity:sub(2)
			closeDrop()
		end)
	end
	scroll.CanvasSize = UDim2.new(0, 0, 0, #rarities * 31 + 11)
	openDrop(#rarities * 31 + 11)
end)

-- ===================== PET DROPDOWN =====================
local function getPetsFolder()
	return player.PlayerGui:WaitForChild("LuckyOpenPets")
		:WaitForChild(selectedFolder)
		:WaitForChild("PetsMenuFrame")
		:WaitForChild("PetsScrolllist")
end

local function refreshPetDrop()
	clearScroll()
	positionDropBelow(petBtn)

	local ok, petsFolder = pcall(getPetsFolder)
	if not ok then
		makeDropItem("⚠  Buka menu pets dulu!", Color3.fromRGB(255, 120, 120), function() end)
		scroll.CanvasSize = UDim2.new(0, 0, 0, 35)
		openDrop(35)
		return
	end

	-- Kumpulkan ImageLabel pet
	local petLabels = {}
	for _, v in pairs(petsFolder:GetChildren()) do
		if v:IsA("ImageLabel") then
			table.insert(petLabels, v)
		end
	end
	table.sort(petLabels, function(a, b) return a.Name < b.Name end)

	if #petLabels == 0 then
		makeDropItem("⚠  Tidak ada pet", Color3.fromRGB(255, 180, 80), function() end)
		scroll.CanvasSize = UDim2.new(0, 0, 0, 35)
		openDrop(35)
		return
	end

	for _, petLabel in pairs(petLabels) do
		local petName = petLabel.Name
		local isSelected = selectedPets[petName] ~= nil

		-- Row container
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 34)
		row.BackgroundColor3 = isSelected
			and Color3.fromRGB(70, 15, 15)   -- bg merah gelap saat selected
			or  Color3.fromRGB(35, 35, 50)   -- bg normal
		row.BorderSizePixel = 0
		row.ZIndex = 10
		row.Parent = scroll

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 6)
		rowCorner.Parent = row

		-- Clone ImageLabel pet asli langsung
		local imgClone = petLabel:Clone()
		imgClone.Size = UDim2.new(0, 26, 0, 26)
		imgClone.Position = UDim2.new(0, 4, 0.5, -13)
		imgClone.BackgroundTransparency = 1
		imgClone.BorderSizePixel = 0
		imgClone.ZIndex = 11
		imgClone.Parent = row

		-- Nama pet + emoji di samping gambar
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, -36, 1, 0)
		nameLabel.Position = UDim2.new(0, 34, 0, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = isSelected and "🗑️  "..petName or petName
		nameLabel.TextColor3 = isSelected
			and Color3.fromRGB(255, 80, 80)   -- merah saat selected
			or  Color3.fromRGB(200, 200, 240) -- putih normal
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Font = Enum.Font.Gotham
		nameLabel.TextSize = 11
		nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
		nameLabel.ZIndex = 11
		nameLabel.Parent = row

		-- Invisible button overlay
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.ZIndex = 12
		btn.Parent = row

		btn.MouseEnter:Connect(function()
			row.BackgroundColor3 = selectedPets[petName]
				and Color3.fromRGB(100, 20, 20)
				or  Color3.fromRGB(50, 50, 70)
		end)
		btn.MouseLeave:Connect(function()
			row.BackgroundColor3 = selectedPets[petName]
				and Color3.fromRGB(70, 15, 15)
				or  Color3.fromRGB(35, 35, 50)
		end)
		btn.MouseButton1Click:Connect(function()
			if selectedPets[petName] then
				-- Deselect: kembali normal
				selectedPets[petName] = nil
				nameLabel.Text = petName
				nameLabel.TextColor3 = Color3.fromRGB(200, 200, 240)
				row.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
			else
				-- Select: merah + emoji tempat sampah
				selectedPets[petName] = true
				nameLabel.Text = "🗑️  "..petName
				nameLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
				row.BackgroundColor3 = Color3.fromRGB(70, 15, 15)
			end
		end)
	end

	scroll.CanvasSize = UDim2.new(0, 0, 0, #petLabels * 36 + 12)
	openDrop(#petLabels * 36 + 12)
end

petBtn.MouseButton1Click:Connect(function()
	if dropFrame.Visible then
		closeDrop()
	else
		refreshPetDrop()
	end
end)

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		local pos = input.Position
		local dp = dropFrame.AbsolutePosition
		local ds = dropFrame.AbsoluteSize
		if not (pos.X >= dp.X and pos.X <= dp.X + ds.X and pos.Y >= dp.Y and pos.Y <= dp.Y + ds.Y) then
			if dropFrame.Visible then closeDrop() end
		end
	end
end)

-- ===================== AUTO SELL LOGIC =====================
toggleBtn.MouseButton1Click:Connect(function()
	autoSell = not autoSell
	if autoSell then
		toggleBtn.Text = "AUTO SELL  ✓  ON"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 140, 80)
		task.spawn(function()
			local firstSell = true
			while autoSell do
				for name, _ in pairs(selectedPets) do
					if not autoSell then break end
					for _, v in pairs(player.PlayerGui:GetDescendants()) do
						if not autoSell then break end
						if v:IsA("ImageLabel") and v.Name == name then
							sellRemote:FireServer(v)
							if firstSell then firstSell = false
							else task.wait(sellDelay) end
						end
					end
				end
				if autoSell then task.wait(0.5) end
			end
		end)
	else
		toggleBtn.Text = "AUTO SELL  ●  OFF"
		toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 58)
	end
end)

-- ===================== MINIMIZE =====================
local minimized = false
minBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	if minimized then
		TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 176, 0, 31)
		}):Play()
		minBtn.Text = "+"
		closeDrop()
	else
		TweenService:Create(main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
			Size = UDim2.new(0, 176, 0, 154)
		}):Play()
		minBtn.Text = "–"
	end
end)

-- ===================== DRAG =====================
local dragging = false
local dragStart = nil
local startPos = nil

local function updateDrag(input)
	if dragging then
		local delta = input.Position - dragStart
		local newPos = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
		main.Position = newPos
		if dropFrame.Visible then
			local anchor = (dropFrame.Position.Y.Offset < main.AbsolutePosition.Y + main.AbsoluteSize.Y / 2)
				and folderBtn or petBtn
			positionDropBelow(anchor)
		end
	end
end

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch then
		updateDrag(input)
	end
end)
