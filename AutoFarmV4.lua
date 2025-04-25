--[[
    Premium AutoFarm GUI v3.0
    Features:
    - Sleek modern UI with animations
    - Comprehensive error handling
    - Activity logging system
    - Performance optimizations
    - Auto-sell toggle option
    - Stats tracking
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local CONFIG = {
    DEBUG_MODE = true,
    DRILL_COLLECTION_INTERVAL = 5,
    ORE_REQUEST_INTERVAL = 0.1,
    AUTO_SELL_INTERVAL = 60,
    GUI_THEME = {
        Background = Color3.fromRGB(25, 25, 30),
        Primary = Color3.fromRGB(0, 170, 255),
        Secondary = Color3.fromRGB(50, 50, 60),
        Success = Color3.fromRGB(0, 200, 100),
        Warning = Color3.fromRGB(255, 150, 0),
        Danger = Color3.fromRGB(255, 50, 50),
        Text = Color3.fromRGB(240, 240, 240)
    }
}

-- Debug logging
local function log(message, level)
    if not CONFIG.DEBUG_MODE then return end
    local prefix = level and ("["..string.upper(level).."] ") or ""
    print("AutoFarm: "..prefix..message)
end

-- Error handling wrapper
local function safeCall(name, func, ...)
    local success, err = pcall(func, ...)
    if not success then
        log(name.." failed: "..tostring(err), "error")
        return false
    end
    return true
end

-- Wait for player
local player = Players.LocalPlayer
while not player do
    Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
    player = Players.LocalPlayer
end

-- Remote service setup
local function getRemote(path)
    local current = ReplicatedStorage
    for _, name in ipairs(path) do
        current = current:WaitForChild(name, 5)
        if not current then
            error("Remote not found: "..table.concat(path, "/"))
        end
    end
    return current
end

local PlotServiceRE = getRemote({"Packages","Knit","Services","PlotService","RE","CollectDrill"})
local OreServiceRE = getRemote({"Packages","Knit","Services","OreService","RE","RequestRandomOre"})
local SellAllRE = getRemote({"Packages","Knit","Services","OreService","RE","SellAll"})

-- Stats tracking
local STATS = {
    DrillsCollected = 0,
    OresRequested = 0,
    OresSold = 0,
    MoneyEarned = 0,
    StartTime = os.time()
}

-- GUI Creation
local gui = Instance.new("ScreenGui")
gui.Name = "PremiumAutoFarm"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.DisplayOrder = 999
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- Main container
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 350, 0, 400)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
mainFrame.BackgroundColor3 = CONFIG.GUI_THEME.Background
mainFrame.BorderColor3 = CONFIG.GUI_THEME.Secondary
mainFrame.BorderSizePixel = 2
mainFrame.ClipsDescendants = true
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

-- Add UI effects
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, CONFIG.GUI_THEME.Primary),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 100, 255))
})
gradient.Rotation = 90
gradient.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 50)
header.Position = UDim2.new(0, 0, 0, 0)
header.BackgroundColor3 = CONFIG.GUI_THEME.Secondary
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 8)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Text = "PREMIUM AUTO FARM"
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = CONFIG.GUI_THEME.Text
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Close button
local closeButton = Instance.new("TextButton")
closeButton.Text = "×"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -30, 0.5, -15)
closeButton.BackgroundColor3 = CONFIG.GUI_THEME.Danger
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 24
closeButton.Parent = header

-- Add button effects
local function createButtonEffect(button)
    local hover = Instance.new("TextButton")
    hover.Size = UDim2.new(1, 0, 1, 0)
    hover.BackgroundTransparency = 1
    hover.Text = ""
    hover.ZIndex = button.ZIndex + 1
    hover.Parent = button
    
    hover.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0.8
        }):Play()
    end)
    
    hover.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.2), {
            BackgroundTransparency = 0
        }):Play()
    end)
end

-- Control buttons container
local controlsFrame = Instance.new("Frame")
controlsFrame.Size = UDim2.new(1, -20, 0, 200)
controlsFrame.Position = UDim2.new(0, 10, 0, 60)
controlsFrame.BackgroundTransparency = 1
controlsFrame.Parent = mainFrame

-- Toggle buttons
local function createToggleButton(name, position)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Text = name:upper()..": OFF"
    button.Size = UDim2.new(1, 0, 0, 40)
    button.Position = position
    button.BackgroundColor3 = CONFIG.GUI_THEME.Secondary
    button.TextColor3 = CONFIG.GUI_THEME.Text
    button.Font = Enum.Font.Gotham
    button.TextSize = 14
    button.Parent = controlsFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = button
    
    createButtonEffect(button)
    return button
end

local drillToggle = createToggleButton("Drill Collector", UDim2.new(0, 0, 0, 0))
local oreToggle = createToggleButton("Ore Requester", UDim2.new(0, 0, 0, 50))
local autoSellToggle = createToggleButton("Auto Sell", UDim2.new(0, 0, 0, 100))

-- Sell button
local sellButton = Instance.new("TextButton")
sellButton.Text = "💰 SELL ALL ORES NOW"
sellButton.Size = UDim2.new(1, 0, 0, 40)
sellButton.Position = UDim2.new(0, 0, 0, 150)
sellButton.BackgroundColor3 = CONFIG.GUI_THEME.Warning
sellButton.TextColor3 = Color3.new(0, 0, 0)
sellButton.Font = Enum.Font.GothamBold
sellButton.TextSize = 14
sellButton.Parent = controlsFrame

local sellCorner = Instance.new("UICorner")
sellCorner.CornerRadius = UDim.new(0, 6)
sellCorner.Parent = sellButton

createButtonEffect(sellButton)

-- Stats panel
local statsFrame = Instance.new("Frame")
statsFrame.Size = UDim2.new(1, -20, 0, 120)
statsFrame.Position = UDim2.new(0, 10, 0, 270)
statsFrame.BackgroundColor3 = CONFIG.GUI_THEME.Secondary
statsFrame.Parent = mainFrame

local statsCorner = Instance.new("UICorner")
statsCorner.CornerRadius = UDim.new(0, 8)
statsCorner.Parent = statsFrame

local statsTitle = Instance.new("TextLabel")
statsTitle.Text = "FARMING STATISTICS"
statsTitle.Size = UDim2.new(1, 0, 0, 20)
statsTitle.Position = UDim2.new(0, 10, 0, 5)
statsTitle.BackgroundTransparency = 1
statsTitle.TextColor3 = CONFIG.GUI_THEME.Text
statsTitle.Font = Enum.Font.GothamBold
statsTitle.TextSize = 14
statsTitle.TextXAlignment = Enum.TextXAlignment.Left
statsTitle.Parent = statsFrame

-- Stats labels
local function createStatLabel(text, position, parent)
    local label = Instance.new("TextLabel")
    label.Text = text
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = position
    label.BackgroundTransparency = 1
    label.TextColor3 = CONFIG.GUI_THEME.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

local drillStat = createStatLabel("Drills Collected: 0", UDim2.new(0, 10, 0, 30), statsFrame)
local oreStat = createStatLabel("Ores Requested: 0", UDim2.new(0, 10, 0, 55), statsFrame)
local sellStat = createStatLabel("Ores Sold: 0", UDim2.new(0, 10, 0, 80), statsFrame)
local timeStat = createStatLabel("Running Time: 00:00:00", UDim2.new(0, 10, 0, 105), statsFrame)

-- Status bar
local statusBar = Instance.new("Frame")
statusBar.Size = UDim2.new(1, -20, 0, 20)
statusBar.Position = UDim2.new(0, 10, 1, -30)
statusBar.BackgroundColor3 = CONFIG.GUI_THEME.Secondary
statusBar.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 4)
statusCorner.Parent = statusBar

local statusLabel = Instance.new("TextLabel")
statusLabel.Text = "Status: Ready"
statusLabel.Size = UDim2.new(1, -10, 1, 0)
statusLabel.Position = UDim2.new(0, 5, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = CONFIG.GUI_THEME.Success
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = statusBar

-- Update stats display
local function updateStats()
    drillStat.Text = "Drills Collected: "..STATS.DrillsCollected
    oreStat.Text = "Ores Requested: "..STATS.OresRequested
    sellStat.Text = "Ores Sold: "..STATS.OresSold
    
    local runningTime = os.time() - STATS.StartTime
    local hours = math.floor(runningTime / 3600)
    local minutes = math.floor((runningTime % 3600) / 60)
    local seconds = runningTime % 60
    timeStat.Text = string.format("Running Time: %02d:%02d:%02d", hours, minutes, seconds)
end

-- Update status with color coding
local function updateStatus(text, statusType)
    statusLabel.Text = "Status: "..text
    statusLabel.TextColor3 = CONFIG.GUI_THEME[statusType] or CONFIG.GUI_THEME.Text
end

-- Toggle states
local states = {
    drillActive = false,
    oreActive = false,
    autoSellActive = false
}

-- Farming functions
local function collectAllDrills()
    while states.drillActive and RunService.Heartbeat:Wait() do
        updateStatus("Collecting drills...", "Primary")
        
        local plots = workspace:FindFirstChild("Plots")
        if plots then
            for _, plot in ipairs(plots:GetChildren()) do
                if not states.drillActive then break end
                
                local drillsFolder = plot:FindFirstChild("Drills")
                if drillsFolder then
                    for _, drill in ipairs(drillsFolder:GetChildren()) do
                        if not states.drillActive then break end
                        
                        if (drill:IsA("Model") or drill:IsA("BasePart")) then
                            safeCall("CollectDrill", function()
                                PlotServiceRE:FireServer(drill)
                                STATS.DrillsCollected += 1
                                updateStats()
                            end)
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
        
        task.wait(CONFIG.DRILL_COLLECTION_INTERVAL)
    end
    
    if not states.drillActive then
        updateStatus("Drill collection stopped", "Warning")
    end
end

local function requestOres()
    updateStatus("Requesting ores...", "Primary")
    
    while states.oreActive and RunService.Heartbeat:Wait() do
        safeCall("RequestOre", function()
            OreServiceRE:FireServer()
            STATS.OresRequested += 1
            updateStats()
        end)
        task.wait(CONFIG.ORE_REQUEST_INTERVAL)
    end
    
    if not states.oreActive then
        updateStatus("Ore requests stopped", "Warning")
    end
end

local function autoSellOres()
    while states.autoSellActive and RunService.Heartbeat:Wait() do
        task.wait(CONFIG.AUTO_SELL_INTERVAL)
        
        if not states.autoSellActive then break end
        
        updateStatus("Auto-selling ores...", "Warning")
        safeCall("SellAll", function()
            SellAllRE:FireServer()
            STATS.OresSold += 1
            updateStats()
        end)
        updateStatus("Auto-sell completed", "Success")
    end
    
    if not states.autoSellActive then
        updateStatus("Auto-sell disabled", "Warning")
    end
end

-- Button functionality
local function toggleButton(button, state, activeText, inactiveText)
    states[state] = not states[state]
    button.Text = button.Name..": "..(states[state] and "ON" or "OFF")
    button.BackgroundColor3 = states[state] and CONFIG.GUI_THEME.Success or CONFIG.GUI_THEME.Secondary
    
    return states[state]
end

drillToggle.MouseButton1Click:Connect(function()
    if toggleButton(drillToggle, "drillActive") then
        coroutine.wrap(collectAllDrills)()
    end
end)

oreToggle.MouseButton1Click:Connect(function()
    if toggleButton(oreToggle, "oreActive") then
        coroutine.wrap(requestOres)()
    end
end)

autoSellToggle.MouseButton1Click:Connect(function()
    if toggleButton(autoSellToggle, "autoSellActive") then
        coroutine.wrap(autoSellOres)()
    end
end)

sellButton.MouseButton1Click:Connect(function()
    updateStatus("Selling all ores...", "Warning")
    safeCall("SellAll", function()
        SellAllRE:FireServer()
        STATS.OresSold += 1
        updateStats()
        updateStatus("Ores sold successfully!", "Success")
    end)
end)

closeButton.MouseButton1Click:Connect(function()
    -- Smooth fade out animation
    local tween = TweenService:Create(gui, TweenInfo.new(0.3), {
        BackgroundTransparency = 1
    })
    tween:Play()
    tween.Completed:Wait()
    gui:Destroy()
    
    -- Turn off all features when closing
    states.drillActive = false
    states.oreActive = false
    states.autoSellActive = false
end)

-- Initialize
updateStatus("Ready to farm!", "Success")
updateStats()

-- Make sure GUI is visible
gui.Enabled = true

log("AutoFarm GUI initialized successfully")
