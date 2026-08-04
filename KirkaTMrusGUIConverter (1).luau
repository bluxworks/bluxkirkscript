--[[
	All-in-one GUI + Button Logic Script
	Creates the entire GUI programmatically and wires up all buttons + dragging.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================
-- Build the GUI
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScreenGui"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local frame = Instance.new("Frame")
frame.Name = "Frame"
frame.Size = UDim2.new(0, 428, 0, 309)
frame.Position = UDim2.new(0.302218109, 0, 0.266263247, 0)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TextLabel"
titleLabel.Size = UDim2.new(0, 200, 0, 50)
titleLabel.Position = UDim2.new(0.266355127, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Color3.new(1, 1, 1)
titleLabel.Text = "BLUX/KIRKA MM2"
titleLabel.TextScaled = true
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.Parent = frame

local scroll = Instance.new("ScrollingFrame")
scroll.Name = "ScrollingFrame"
scroll.Size = UDim2.new(0, 414, 0, 234)
scroll.Position = UDim2.new(0.0163551401, 0, 0.239482194, 0)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 12
scroll.ScrollBarImageColor3 = Color3.new(0, 0, 0)
scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
scroll.ScrollingDirection = Enum.ScrollingDirection.XY
scroll.ClipsDescendants = true
scroll.Parent = frame

-- Helper to create buttons
local function createButton(name, text, position)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 179, 0, 50)
	btn.Position = position
	btn.BackgroundColor3 = Color3.new(0.188235, 0.188235, 0.188235)
	btn.BorderColor3 = Color3.new(0.14902, 0.14902, 0.14902)
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = text
	btn.TextScaled = true
	btn.Font = Enum.Font.SourceSansBold
	btn.AutoButtonColor = true
	btn.Active = true
	btn.Parent = scroll
	return btn
end

local lobbyButton    = createButton("goto lobby", "GOTO LOBBY",                 UDim2.new(0.0418190323, 0, 0.0161812305, 0))
local immortalButton = createButton("IMMORTAL", "IMMORTALITY (reset)",       UDim2.new(0.523127437,  0, 0.0161812305, 0))
local sherrifButton  = createButton("goto sherrif", "GOTO SHERRIF",           UDim2.new(0.0418190323, 0, 0.126213595, 0))
local murdButton     = createButton("goto murd", "GOTO MURD",                UDim2.new(0.523127437,  0, 0.126213595, 0))
local knife1Button   = createButton("knife1", "PLAY KNIFE ANIMATION(stab)",  UDim2.new(0.0418190323, 0, 0.242718443, 0))
local knife2Button   = createButton("knife2", "PLAY KNIFE ANIMATION(throw)", UDim2.new(0.523127437,  0, 0.241100326, 0))
local boxButton      = createButton("box", "box",                            UDim2.new(0.0418190323, 0, 0.355987042, 0))
local diButton       = createButton("di", "fa(dih)",                         UDim2.new(0.522495449,  0, 0.355987042, 0))
local map1Button     = createButton("map1", "votemap1",                      UDim2.new(0.0418190323, 0, 0.61003238, 0))
local map2Button     = createButton("map2", "votemap2",                      UDim2.new(0.522495449,  0, 0.61003238, 0))
local map3Button     = createButton("map3", "votemap3",                      UDim2.new(0.0418191068, 0, 0.716828465, 0))

local txtBox = Instance.new("TextBox")
txtBox.Name = "txt"
txtBox.Size = UDim2.new(0, 378, 0, 50)
txtBox.Position = UDim2.new(0.0415030234, 0, 0.474110037, 0)
txtBox.BackgroundColor3 = Color3.new(0.188235, 0.188235, 0.188235)
txtBox.BorderSizePixel = 0
txtBox.TextColor3 = Color3.new(1, 1, 1)
txtBox.Text = "txt"
txtBox.TextScaled = true
txtBox.Font = Enum.Font.SourceSansBold
txtBox.ClearTextOnFocus = true
txtBox.Parent = scroll

screenGui.Parent = playerGui

-- ============================================================
-- Dragging: make the frame movable
-- ============================================================

local dragging = false
local dragStart = nil
local startPos = nil

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
	end
end)

frame.InputChanged:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
	end
end)

-- ============================================================
-- Map toggle loop state
-- ============================================================

local activeMapLoop = nil
local mapConnection = nil

local function stopMapLoop()
	activeMapLoop = nil
	if mapConnection then
		mapConnection:Disconnect()
		mapConnection = nil
	end
end

local function startMapLoop(mapName, position)
	stopMapLoop()
	activeMapLoop = mapName

	mapConnection = RunService.Heartbeat:Connect(function()
		local character = player.Character
		if character then
			local root = character:FindFirstChild("HumanoidRootPart")
			if root then
				root.CFrame = CFrame.new(position)
				root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			end
		end
	end)
end

local function toggleMapLoop(mapName, position)
	if activeMapLoop == mapName then
		stopMapLoop()
	else
		startMapLoop(mapName, position)
	end
end

-- ============================================================
-- Button Logic
-- ============================================================

-- Helper to find the RenamePet remote safely
local function getRenamePetRemote()
	local rs = game:FindFirstChild("ReplicatedStorage")
	if rs then
		local remotes = rs:FindFirstChild("Remotes")
		if remotes then
			local inventory = remotes:FindFirstChild("Inventory")
			if inventory then
				return inventory:FindFirstChild("RenamePet")
			end
		end
	end
	return nil
end

-- Teleport to a specific position
local function teleportToPosition(position)
	local character = player.Character or player.CharacterAdded:Wait()
	local root = character:FindFirstChild("HumanoidRootPart")
	if root then
		root.CFrame = CFrame.new(position)
	end
end

-- Teleport to the player holding a given tool
local function teleportToToolHolder(toolName)
	local targetPlayer = nil
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			if p.Backpack:FindFirstChild(toolName) or (p.Character and p.Character:FindFirstChild(toolName)) then
				targetPlayer = p
				break
			end
		end
	end

	if targetPlayer and targetPlayer.Character and player.Character then
		local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		local localRoot = player.Character:FindFirstChild("HumanoidRootPart")
		if targetRoot and localRoot then
			localRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 3, 0)
		end
	end
end

-- Play a tool animation
local function playToolAnimation(animId)
	local character = player.Character
	if not character then return end

	local tool = character:FindFirstChildOfClass("Tool")
	if not tool then return end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if animator then
		local animation = Instance.new("Animation")
		animation.AnimationId = animId
		local track = animator:LoadAnimation(animation)
		track:Play()
	end
end

-- IMMORTAL: Save position, reset character, restore position
local savedCFrame = nil
local isCustomReset = false

local function onImmortalPressed()
	local character = player.Character
	if character then
		local rootPart = character:FindFirstChild("HumanoidRootPart")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if rootPart and humanoid and humanoid.Health > 0 then
			savedCFrame = rootPart.CFrame
			isCustomReset = true
			local head = character:FindFirstChild("Head")
			if head then head:Destroy() end
			humanoid.Health = 0
		end
	end
end

player.CharacterAdded:Connect(function(character)
	if isCustomReset and savedCFrame then
		local rootPart = character:WaitForChild("HumanoidRootPart", 10)
		if rootPart then
			task.wait(0.15)
			local startTime = os.clock()
			local connection
			connection = RunService.Heartbeat:Connect(function()
				if rootPart and rootPart.Parent then
					rootPart.CFrame = savedCFrame
					rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
				end
				if os.clock() - startTime > 1.5 then
					connection:Disconnect()
					isCustomReset = false
				end
			end)
		end
	else
		savedCFrame = nil
		isCustomReset = false
	end
end)

-- ============================================================
-- Wire up all buttons
-- ============================================================

lobbyButton.MouseButton1Click:Connect(function()
	teleportToPosition(Vector3.new(0, -67, 6))
end)

sherrifButton.MouseButton1Click:Connect(function()
	teleportToToolHolder("Gun")
end)

murdButton.MouseButton1Click:Connect(function()
	teleportToToolHolder("Knife")
end)

immortalButton.MouseButton1Click:Connect(onImmortalPressed)

knife1Button.MouseButton1Click:Connect(function()
	playToolAnimation("rbxassetid://2467567750")
end)

knife2Button.MouseButton1Click:Connect(function()
	playToolAnimation("rbxassetid://1957890538")
end)

boxButton.MouseButton1Click:Connect(function()
	local remote = getRenamePetRemote()
	if remote then
		remote:FireServer("str box")
	end
end)

diButton.MouseButton1Click:Connect(function()
	local remote = getRenamePetRemote()
	if remote then
		remote:FireServer("fa")
	end
end)

txtBox.FocusLost:Connect(function(enterPressed)
	if enterPressed then
		local typedText = txtBox.Text
		if typedText and typedText ~= "" then
			local remote = getRenamePetRemote()
			if remote then
				remote:FireServer(typedText)
			end
		end
	end
end)

map1Button.MouseButton1Click:Connect(function()
	toggleMapLoop("map1", Vector3.new(-10, -64, -94))
end)

map2Button.MouseButton1Click:Connect(function()
	toggleMapLoop("map2", Vector3.new(1, -64, -97))
end)

map3Button.MouseButton1Click:Connect(function()
	toggleMapLoop("map3", Vector3.new(10, -64, -94))
end)
