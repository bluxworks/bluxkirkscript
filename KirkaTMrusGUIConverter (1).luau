--[[
	All-in-one GUI + Button Logic Script
	Creates the entire GUI programmatically and wires up all button actions.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================
-- Build the GUI
-- ============================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ScreenGui"
screenGui.ResetOnSpawn = true
screenGui.IgnoreGuiInset = false
screenGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
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

-- Helper to create buttons
local function createButton(name, text, position)
	local btn = Instance.new("TextButton")
	btn.Name = name
	btn.Size = UDim2.new(0, 179, 0, 50)
	btn.Position = position
	btn.BackgroundColor3 = Color3.fromRGB(48, 48, 48)
	btn.BorderColor3 = Color3.fromRGB(38, 38, 38)
	btn.BorderSizePixel = 0
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Text = text
	btn.TextScaled = true
	btn.Font = Enum.Font.SourceSansBold
	btn.AutoButtonColor = true
	btn.Active = true
	btn.Parent = frame
	return btn
end

local lobbyButton    = createButton("goto lobby", "GOTO LOBBY",                 UDim2.new(0.0490654223, 0, 0.239482194, 0))
local sherrifButton  = createButton("goto sherrif", "GOTO SHERRIF",           UDim2.new(0.0490654223, 0, 0.488673151, 0))
local murdButton     = createButton("goto murd", "GOTO MURD",                UDim2.new(0.530373812,  0, 0.488673151, 0))
local immortalButton = createButton("IMMORTAL", "IMMORTALITY (reset)",       UDim2.new(0.530373812,  0, 0.239482194, 0))
local knife1Button   = createButton("knife1", "PLAY KNIFE ANIMATION(stab)",  UDim2.new(0.0490654223, 0, 0.734627843, 0))
local knife2Button   = createButton("knife2", "PLAY KNIFE ANIMATION(throw)", UDim2.new(0.530373812,  0, 0.734627843, 0))

screenGui.Parent = playerGui

-- ============================================================
-- Button Logic
-- ============================================================

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
-- Wire up buttons
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
