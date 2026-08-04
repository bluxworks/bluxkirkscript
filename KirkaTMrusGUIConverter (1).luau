--[[
	All-in-one GUI + Button Logic Script
	Finds the existing GUI (cloned from StarterGui into PlayerGui) and wires up all buttons.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================
-- Map toggle loop state
-- ============================================================

local activeMapLoop = nil -- holds the name of the currently active map loop
local mapConnection = nil -- holds the Heartbeat connection for the active loop
local mapTargetPosition = nil

local function stopMapLoop()
	activeMapLoop = nil
	mapTargetPosition = nil
	if mapConnection then
		mapConnection:Disconnect()
		mapConnection = nil
	end
end

local function startMapLoop(mapName, position)
	stopMapLoop()
	activeMapLoop = mapName
	mapTargetPosition = position

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
-- Wire up all buttons (called each time the GUI is recreated)
-- ============================================================

local function findButton(scroll, name)
	return scroll:FindFirstChild(name)
end

local function wireUpGUI(screenGui)
	local frame = screenGui:FindFirstChild("Frame")
	if not frame then return end

	local scroll = frame:FindFirstChild("ScrollingFrame")
	if not scroll then return end

	-- ============================================================
	-- Dragging: make the frame movable
	-- ============================================================
	local dragging = false
	local dragStart = nil
	local start_pos = nil

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			start_pos = frame.Position
		end
	end)

	frame.InputChanged:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				start_pos.X.Scale, start_pos.X.Offset + delta.X,
				start_pos.Y.Scale, start_pos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	-- Helper to find a remote safely
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

	-- goto lobby
	local lobbyButton = findButton(scroll, "goto lobby")
	if lobbyButton then
		lobbyButton.MouseButton1Click:Connect(function()
			teleportToPosition(Vector3.new(0, -67, 6))
		end)
	end

	-- goto sherrif
	local sherrifButton = findButton(scroll, "goto sherrif")
	if sherrifButton then
		sherrifButton.MouseButton1Click:Connect(function()
			teleportToToolHolder("Gun")
		end)
	end

	-- goto murd
	local murdButton = findButton(scroll, "goto murd")
	if murdButton then
		murdButton.MouseButton1Click:Connect(function()
			teleportToToolHolder("Knife")
		end)
	end

	-- IMMORTAL
	local immortalButton = findButton(scroll, "IMMORTAL")
	if immortalButton then
		immortalButton.MouseButton1Click:Connect(onImmortalPressed)
	end

	-- knife1
	local knife1Button = findButton(scroll, "knife1")
	if knife1Button then
		knife1Button.MouseButton1Click:Connect(function()
			playToolAnimation("rbxassetid://2467567750")
		end)
	end

	-- knife2
	local knife2Button = findButton(scroll, "knife2")
	if knife2Button then
		knife2Button.MouseButton1Click:Connect(function()
			playToolAnimation("rbxassetid://1957890538")
		end)
	end

	-- box: fire RenamePet with "str box"
	local boxButton = findButton(scroll, "box")
	if boxButton then
		boxButton.MouseButton1Click:Connect(function()
			local remote = getRenamePetRemote()
			if remote then
				remote:FireServer("str box")
			end
		end)
	end

	-- di: fire RenamePet with "fa"
	local diButton = findButton(scroll, "di")
	if diButton then
		diButton.MouseButton1Click:Connect(function()
			local remote = getRenamePetRemote()
			if remote then
				remote:FireServer("fa")
			end
		end)
	end

	-- txt: TextBox - fire RenamePet with the typed text on FocusLost (Enter key)
	local txtBox = scroll:FindFirstChild("txt")
	if txtBox and txtBox:IsA("TextBox") then
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
	end

	-- map1: toggle teleport loop to (-10, -64, -94)
	local map1Button = findButton(scroll, "map1")
	if map1Button then
		map1Button.MouseButton1Click:Connect(function()
			toggleMapLoop("map1", Vector3.new(-10, -64, -94))
		end)
	end

	-- map2: toggle teleport loop to (1, -64, -97)
	local map2Button = findButton(scroll, "map2")
	if map2Button then
		map2Button.MouseButton1Click:Connect(function()
			toggleMapLoop("map2", Vector3.new(1, -64, -97))
		end)
	end

	-- map3: toggle teleport loop to (10, -64, -94)
	local map3Button = findButton(scroll, "map3")
	if map3Button then
		map3Button.MouseButton1Click:Connect(function()
			toggleMapLoop("map3", Vector3.new(10, -64, -94))
		end)
	end
end

-- ============================================================
-- Find and wire up the GUI (handles initial load + respawns)
-- ============================================================

local function findAndWireGUI()
	local existing = playerGui:FindFirstChild("ScreenGui")
	if existing then
		wireUpGUI(existing)
	end
end

-- Wire up the initial GUI
findAndWireGUI()

-- Re-wire when the GUI is recreated on respawn (ResetOnSpawn = true)
playerGui.ChildAdded:Connect(function(child)
	if child:IsA("ScreenGui") and child.Name == "ScreenGui" then
		wireUpGUI(child)
	end
end)
