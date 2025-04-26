local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- Remote Events
local PlotServiceRE = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("PlotService"):WaitForChild("RE"):WaitForChild("CollectDrill")
local OreServiceRE = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("RequestRandomOre")
local SellAllRE = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("OreService"):WaitForChild("RE"):WaitForChild("SellAll")

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "DaddyCDEX"
gui.ResetOnSpawn = false

-- Main Frame
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 330, 0, 260)
frame.Position = UDim2.new(0.5, -165, 0.5, -130)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Close Button
local closeBtn = Instance.new("TextButton", frame)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -35, 0, 5)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
local cCorner = Instance.new("UICorner", closeBtn)
cCorner.CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Title
local title = Instance.new("TextLabel", frame)
title.Text = "DADDY CDEX AUTO FARM"
title.Size = UDim2.new(1, -40, 0, 35)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(255, 100, 200)
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

local function makeButton(text, yPos, defaultColor)
    local btn = Instance.new("TextButton", frame)
    btn.Text = text
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Position = UDim2.new(0.05, 0, 0, yPos)
    btn.BackgroundColor3 = defaultColor or Color3.fromRGB(180, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 16
    local c = Instance.new("UICorner", btn)
    c.CornerRadius = UDim.new(0, 10)
    return btn
end

-- Stats
local startTime = tick()
local minedOre = 0

local antiAfkLabel = Instance.new("TextLabel", frame)
antiAfkLabel.Text = "Anti-AFK: ON"
antiAfkLabel.Position = UDim2.new(0.05, 0, 1, -60)
antiAfkLabel.Size = UDim2.new(0.9, 0, 0, 20)
antiAfkLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
antiAfkLabel.BackgroundTransparency = 1
antiAfkLabel.Font = Enum.Font.Gotham
antiAfkLabel.TextSize = 14

local runtimeLabel = Instance.new("TextLabel", frame)
runtimeLabel.Text = "Run Time: 0s"
runtimeLabel.Position = UDim2.new(0.05, 0, 1, -40)
runtimeLabel.Size = UDim2.new(0.9, 0, 0, 20)
runtimeLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
runtimeLabel.BackgroundTransparency = 1
runtimeLabel.Font = Enum.Font.Gotham
runtimeLabel.TextSize = 14

local minedOreLabel = Instance.new("TextLabel", frame)
minedOreLabel.Text = "Ore Mined: 0"
minedOreLabel.Position = UDim2.new(0.05, 0, 1, -20)
minedOreLabel.Size = UDim2.new(0.9, 0, 0, 20)
minedOreLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
minedOreLabel.BackgroundTransparency = 1
minedOreLabel.Font = Enum.Font.Gotham
minedOreLabel.TextSize = 14

-- Buttons
local drillButton = makeButton("AUTO DRILL: OFF", 45, Color3.fromRGB(255, 80, 120))
local oreButton = makeButton("AUTO ORE: OFF", 95, Color3.fromRGB(120, 120, 255))
local sellButton = makeButton("SELL ALL ORES", 145, Color3.fromRGB(255, 180, 60))

-- Logic
local drillActive = false
local oreActive = false

drillButton.MouseButton1Click:Connect(function()
    drillActive = not drillActive
    drillButton.Text = "AUTO DRILL: " .. (drillActive and "ON" or "OFF")
    drillButton.BackgroundColor3 = drillActive and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(255, 80, 120)

    if drillActive then
        coroutine.wrap(function()
            while drillActive and RunService.Heartbeat:Wait() do
                local plots = workspace:FindFirstChild("Plots")
                if plots then
                    for _, plot in ipairs(plots:GetChildren()) do
                        local drills = plot:FindFirstChild("Drills")
                        if drills then
                            for _, drill in ipairs(drills:GetChildren()) do
                                PlotServiceRE:FireServer(drill)
                            end
                        end
                    end
                end
                task.wait(1)
            end
        end)()
    end
end)

oreButton.MouseButton1Click:Connect(function()
    oreActive = not oreActive
    oreButton.Text = "AUTO ORE: " .. (oreActive and "ON" or "OFF")
    oreButton.BackgroundColor3 = oreActive and Color3.fromRGB(80, 160, 255) or Color3.fromRGB(120, 120, 255)

    if oreActive then
        coroutine.wrap(function()
            while oreActive and RunService.Heartbeat:Wait() do
                OreServiceRE:FireServer()
                minedOre += 1
                task.wait(0.1)
            end
        end)()
    end
end)

sellButton.MouseButton1Click:Connect(function()
    sellButton.Text = "SELLING..."
    sellButton.BackgroundColor3 = Color3.fromRGB(255, 100, 30)
    pcall(function()
        SellAllRE:FireServer()
    end)
    task.wait(1)
    sellButton.Text = "SELL ALL ORES"
    sellButton.BackgroundColor3 = Color3.fromRGB(255, 180, 60)
end)

-- Anti-AFK
player.Idled:Connect(function()
    VirtualUser = game:GetService("VirtualUser")
    VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- Runtime and Ore Tracker
RunService.Heartbeat:Connect(function()
    local elapsed = math.floor(tick() - startTime)
    runtimeLabel.Text = "Run Time: " .. elapsed .. "s"
    minedOreLabel.Text = "Ore Mined: " .. minedOre
end)
