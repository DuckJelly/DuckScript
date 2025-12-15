local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "TB3_Hub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting
TweenService:Create(blur, TweenInfo.new(0.5), {Size = 24}):Play()

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 360, 0, 140)
frame.Position = UDim2.new(0.5, -180, 0.5, -70)
frame.BackgroundColor3 = Color3.fromRGB(25, 15, 50)
frame.BorderSizePixel = 0
frame.Parent = gui

local outline = Instance.new("UIStroke")
outline.Thickness = 3
outline.Color = Color3.fromRGB(147, 0, 255)
outline.Parent = frame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(147, 0, 255)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local function typeTitle(t, s)
    s = s or 0.1
    title.Text = ""
    for i = 1, #t do
        title.Text = t:sub(1, i)
        task.wait(s)
    end
end

task.spawn(function()
    while true do
        typeTitle("TB3 Hub")
        task.wait(0.5)
        title.Text = ""
        task.wait(0.5
