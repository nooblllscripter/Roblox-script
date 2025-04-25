local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Remote setup
local PlotServiceRE = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("PlotService"):WaitForChild("RE"):WaitForChild("CollectDrill")
local OreServiceRE = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("RequestRandomOre")
local SellAllRE = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("SellAll")

-- GUI Creation
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "DaddyCDEXAutoFarm"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

-- Main Container Frame
local container = Instance.new("Frame")
container.Size = UDim2.new(0, 300, 0, 60)
container.Position = UDim2.new(0.5, -150, 0, 10)
container.BackgroundTransparency = 1
container.Parent = gui

-- Love Text Label
local loveText = Instance.new("TextLabel")
loveText.Text = "I ❤️ CDEX DADDY"
loveText.Size = UDim2.new(0, 150, 0, 30)
loveText.Position = UDim2.new(1, 10, 0, 15)
loveText.BackgroundTransparency = 1
loveText.TextColor3 = Color3.fromRGB(255, 100, 200)
loveText.Font = Enum.Font.GothamBold
loveText.TextSize = 14
loveText.TextXAlignment = Enum.TextXAlignment.Left
loveText.Parent = container

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 60)
frame.Position = UDim2.new(0, 0, 0, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = container

-- Universal Dragging Functionality
local dragStartPos
local frameStartPos
local isDragging = false

local function startDrag(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStartPos = input.Position
        frameStartPos = container.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                isDragging = false
            end
        end)
    end
end

local function updateDrag(input)
    if isDragging then
        local delta = input.Position - dragStartPos
        container.Position = UDim2.new(
            frameStartPos.X.Scale, 
            frameStartPos.X.Offset + delta.X,
            frameStartPos.Y.Scale, 
            frameStartPos.Y.Offset + delta.Y
        )
    end
end

-- Connect input events for all devices
frame.InputBegan:Connect(startDrag)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
        updateDrag(input)
    end
end)

-- Add corner radius
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

-- Main Toggle Button
local mainButton = Instance.new("TextButton")
mainButton.Text = "[AUTO FARM]"
mainButton.Size = UDim2.new(1, -10, 1, -10)
mainButton.Position = UDim2.new(0, 5, 0, 5)
mainButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
mainButton.TextColor3 = Color3.new(1, 1, 1)
mainButton.Font = Enum.Font.GothamBold
mainButton.TextSize = 16
mainButton.Parent = frame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 6)
buttonCorner.Parent = mainButton

-- Expanded Frame (hidden by default)
local expandedFrame = Instance.new("Frame")
expandedFrame.Size = UDim2.new(0, 250, 0, 200)
expandedFrame.Position = UDim2.new(0, 0, 0, 65)
expandedFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
expandedFrame.Visible = false
expandedFrame.Parent = container

local expandedCorner = Instance.new("UICorner")
expandedCorner.CornerRadius = UDim.new(0, 8)
expandedCorner.Parent = expandedFrame

-- Auto Drill Collector Button
local drillButton = Instance.new("TextButton")
drillButton.Text = "DRILL COLLECTOR: OFF"
drillButton.Size = UDim2.new(1, -10, 0, 40)
drillButton.Position = UDim2.new(0, 5, 0, 10)
drillButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80) -- Red when off
drillButton.TextColor3 = Color3.new(1, 1, 1)
drillButton.Font = Enum.Font.Gotham
drillButton.TextSize = 14
drillButton.Parent = expandedFrame

-- Auto Ore Requester Button
local oreButton = Instance.new("TextButton")
oreButton.Text = "ORE REQUESTER: OFF"
oreButton.Size = UDim2.new(1, -10, 0, 40)
oreButton.Position = UDim2.new(0, 5, 0, 60)
oreButton.BackgroundColor3 = Color3.fromRGB(200, 80, 80) -- Red when off
oreButton.TextColor3 = Color3.new(1, 1, 1)
oreButton.Font = Enum.Font.Gotham
oreButton.TextSize = 14
oreButton.Parent = expandedFrame

-- Sell All Button
local sellButton = Instance.new("TextButton")
sellButton.Text = "SELL ALL ORES"
sellButton.Size = UDim2.new(1, -10, 0, 40)
sellButton.Position = UDim2.new(0, 5, 0, 110)
sellButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
sellButton.TextColor3 = Color3.new(1, 1, 1)
sellButton.Font = Enum.Font.GothamBold
sellButton.TextSize = 16
sellButton.Parent = expandedFrame

-- Status Timer
local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Status: Ready"
statusLabel.Size = UDim2.new(1, -10, 0, 20)
statusLabel.Position = UDim2.new(0, 5, 0, 160)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = expandedFrame

-- Add corners to all buttons
local function addButtonCorners(button)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
end

addButtonCorners(drillButton)
addButtonCorners(oreButton)
addButtonCorners(sellButton)

-- Toggle functionality
local drillActive = false
local oreActive = false
local expanded = false

-- Timer variables
local startTime = 0
local timerConnection = nil

-- Function to update timer
local function updateTimer()
    while true do
        if drillActive or oreActive then
            local elapsed = os.time() - startTime
            local minutes = math.floor(elapsed / 60)
            local seconds = elapsed % 60
            statusLabel.Text = string.format("Running: %02d:%02d", minutes, seconds)
        else
            statusLabel.Text = "Status: Ready"
        end
        task.wait(1)
    end
end

-- Main toggle button functionality
mainButton.MouseButton1Click:Connect(function()
    expanded = not expanded
    expandedFrame.Visible = expanded
    container.Size = expanded and UDim2.new(0, 300, 0, 270) or UDim2.new(0, 300, 0, 60)
end)

-- Auto Drill Collector
local function collectAllDrills()
    startTime = os.time()
    if not timerConnection then
        timerConnection = coroutine.wrap(updateTimer)()
    end
    
    while drillActive and RunService.Heartbeat:Wait() do
        pcall(function()
            local plots = workspace:FindFirstChild("Plots")
            if plots then
                for _, plot in ipairs(plots:GetChildren()) do
                    local drillsFolder = plot:FindFirstChild("Drills")
                    if drillsFolder then
                        for _, drill in ipairs(drillsFolder:GetChildren()) do
                            if (drill:IsA("Model") or drill:IsA("BasePart")) and drillActive then
                                PlotServiceRE:FireServer(drill)
                                task.wait(0.1)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(1)
    end
end

-- Auto Ore Requester
local function requestOres()
    startTime = os.time()
    if not timerConnection then
        timerConnection = coroutine.wrap(updateTimer)()
    end
    
    while oreActive and RunService.Heartbeat:Wait() do
        pcall(function()
            OreServiceRE:FireServer()
        end)
        task.wait(0.1)
    end
end

-- Button connections
drillButton.MouseButton1Click:Connect(function()
    drillActive = not drillActive
    drillButton.Text = drillActive and "DRILL COLLECTOR: ON" or "DRILL COLLECTOR: OFF"
    drillButton.BackgroundColor3 = drillActive and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(200, 80, 80)
    
    if drillActive then
        coroutine.wrap(collectAllDrills)()
    end
end)

oreButton.MouseButton1Click:Connect(function()
    oreActive = not oreActive
    oreButton.Text = oreActive and "ORE REQUESTER: ON" or "ORE REQUESTER: OFF"
    oreButton.BackgroundColor3 = oreActive and Color3.fromRGB(80, 160, 80) or Color3.fromRGB(200, 80, 80)
    
    if oreActive then
        coroutine.wrap(requestOres)()
    end
end)

sellButton.MouseButton1Click:Connect(function()
    local oldText = sellButton.Text
    sellButton.Text = "SELLING..."
    sellButton.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    
    pcall(function()
        SellAllRE:FireServer()
    end)
    
    task.wait(1)
    sellButton.Text = oldText
    sellButton.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
end)
