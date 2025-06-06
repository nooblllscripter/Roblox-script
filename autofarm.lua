local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Remote setup
local PlotServiceRE = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("PlotService"):WaitForChild("RE"):WaitForChild("CollectDrill")
local OreServiceRE = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("RequestRandomOre")

-- GUI Creation
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmGUI"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 150)
frame.Position = UDim2.new(0.5, -100, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Text = "Auto Farm Controls"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
title.TextColor3 = Color3.white
title.Parent = frame

-- Drill Collector Toggle
local drillToggle = Instance.new("TextButton")
drillToggle.Text = "Drill Collector: OFF"
drillToggle.Size = UDim2.new(0.9, 0, 0, 30)
drillToggle.Position = UDim2.new(0.05, 0, 0.25, 0)
drillToggle.Name = "DrillToggle"
drillToggle.Parent = frame

-- Ore Requester Toggle
local oreToggle = Instance.new("TextButton")
oreToggle.Text = "Ore Requester: OFF"
oreToggle.Size = UDim2.new(0.9, 0, 0, 30)
oreToggle.Position = UDim2.new(0.05, 0, 0.55, 0)
oreToggle.Name = "OreToggle"
oreToggle.Parent = frame

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Text = "X"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0, 0)
closeButton.Parent = frame

-- Make draggable
local dragging
local dragInput
local dragStart
local startPos

local function update(input)
    local delta = input.Position - dragStart
    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Toggle functionality
local drillActive = false
local oreActive = false

local function collectAllDrills()
    while drillActive and RunService.Heartbeat:Wait() do
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
        task.wait(5) -- Main collection interval
    end
end

local function requestOres()
    local requestCount = 0
    local startTime = os.clock()
    
    while oreActive and requestCount < 1000 and RunService.Heartbeat:Wait() do
        OreServiceRE:FireServer()
        requestCount += 1
        task.wait(0.1)
    end
    
    if not oreActive then
        print("Ore requests stopped manually")
    else
        local totalTime = os.clock() - startTime
        print(string.format("Completed %d ore requests in %.2f seconds", requestCount, totalTime))
    end
end

drillToggle.MouseButton1Click:Connect(function()
    drillActive = not drillActive
    drillToggle.Text = "Drill Collector: " .. (drillActive and "ON" or "OFF")
    drillToggle.BackgroundColor3 = drillActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    
    if drillActive then
        coroutine.wrap(collectAllDrills)()
    end
end)

oreToggle.MouseButton1Click:Connect(function()
    oreActive = not oreActive
    oreToggle.Text = "Ore Requester: " .. (oreActive and "ON" or "OFF")
    oreToggle.BackgroundColor3 = oreActive and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(170, 0, 0)
    
    if oreActive then
        coroutine.wrap(requestOres)()
    end
end)

closeButton.MouseButton1Click:Connect(function()
    gui:Destroy()
    drillActive = false
    oreActive = false
end)

-- Make GUI visible
gui.Enabled = true
