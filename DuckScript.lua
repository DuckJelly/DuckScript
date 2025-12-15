local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "",
    LoadingTitle = "TB3",
    LoadingSubtitle = "",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = false
})

-- Main Tab
local MainTab = Window:CreateTab("Main")
local MainSection = MainTab:CreateSection("Toggles")

MainTab:CreateToggle({Name = "Infinite Jump", CurrentValue = false, Callback = function(Value)
    local InfiniteJumpEnabled = Value
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if InfiniteJumpEnabled then game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping") end
    end)
end})

MainTab:CreateToggle({Name = "Fly", CurrentValue = false, Callback = function(Value)
    local FlyEnabled = Value
    local char = game.Players.LocalPlayer.Character
    local hum = char:WaitForChild("Humanoid")
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.new(0,0,0)
    bv.Parent = char.HumanoidRootPart
    repeat task.wait() bv.Velocity = Vector3.new(0,50,0) until not FlyEnabled
    bv:Destroy()
end})

MainTab:CreateSlider({Name = "Walkspeed", Range = {16, 500}, Increment = 1, CurrentValue = 16, Callback = function(Value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
end})

-- Dupe Tab (Gun/Item Dupe)
local DupeTab = Window:CreateTab("Dupe")
local DupeSection = DupeTab:CreateSection("Gun Dupe (Equip First)")

DupeTab:CreateButton({Name = "Market Gun Dupe", Callback = function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local Player = Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Backpack = Player:WaitForChild("Backpack")
    local Tool = Character:FindFirstChildOfClass("Tool")
    if not Tool then return Rayfield:Notify({Title = "Error", Content = "Equip a gun first!", Duration = 3}) end
    Tool.Parent = Backpack
    task.wait(0.5)
    local ToolName = Tool.Name
    local ToolId = nil

    local function getPing()
        local t0 = tick()
        local temp = Instance.new("BoolValue", ReplicatedStorage)
        temp.Name = "PingTest_" .. tostring(math.random(10000,99999))
        task.wait(0.1)
        local t1 = tick()
        temp:Destroy()
        return math.clamp((t1 - t0) * 1000, 50, 300)
    end

    local ping = getPing()
    local delay = 0.25 + ((math.clamp(ping, 0, 300) / 300) * 0.03)

    local marketconnection = ReplicatedStorage.MarketItems.ChildAdded:Connect(function(item)
        if item.Name == ToolName then
            local owner = item:WaitForChild("owner", 2)
            if owner and owner.Value == Player.Name then ToolId = item:GetAttribute("SpecialId") end
        end
    end)

    task.spawn(function() ReplicatedStorage.ListWeaponRemote:FireServer(ToolName, 99999) end)
    task.wait(delay)
    task.spawn(function() ReplicatedStorage.BackpackRemote:InvokeServer("Store", ToolName) end)
    task.wait(3)
    if ToolId then task.spawn(function() ReplicatedStorage.BuyItemRemote:FireServer(ToolName, "Remove", ToolId) end) end
    task.spawn(function() ReplicatedStorage.BackpackRemote:InvokeServer("Grab", ToolName) end)
    marketconnection:Disconnect()
    Rayfield:Notify({Title = "Dupe Success", Content = ToolName .. " Duplicated!", Duration = 3})
end})

DupeTab:CreateButton({Name = "Auto Gun Dupe (Loop)", Callback = function()
    _G.AutoDupe = not _G.AutoDupe
    while _G.AutoDupe do task.wait(5) -- Run dupe above every 5s
        loadstring(game:HttpGet("https://raw.githubusercontent.com/dkhub43221/scripts/refs/heads/main/thabronx.lua"))() -- Placeholder, replace with dupe func
    end
end})

-- Farm Tab
local FarmTab = Window:CreateTab("Farm")
FarmTab:CreateToggle({Name = "Construction Autofarm", CurrentValue = false, Callback = function(Value)
    _G.Farm = Value
    while _G.Farm do task.wait()
        -- Insert construction autofarm logic from earlier script
        local player = game.Players.LocalPlayer
        if not player:GetAttribute("WorkingJob") then
            player.Character.HumanoidRootPart.CFrame = workspace.ConstructionStuff["Start Job"].CFrame
            fireproximityprompt(workspace.ConstructionStuff["Start Job"].Prompt)
        end
        -- Add wood equip, build, grab logic...
    end
end})

-- Combat Tab
local CombatTab = Window:CreateTab("Combat")
CombatTab:CreateToggle({Name = "ESP", CurrentValue = false, Callback = function(Value)
    -- Basic ESP code from snippet
end})

CombatTab:CreateToggle({Name = "Aimbot", CurrentValue = false, Callback = function(Value)
    -- Aimbot loop from snippet
end})

-- TP Tab
local TPTab = Window:CreateTab("TP")
TPTab:CreateButton({Name = "Gun Shop", Callback = function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1000, 50, -500) -- Adjust coords
end})

Rayfield:Notify({Title = "Loaded", Content = "Unbranded TB3 Hub Ready!", Duration = 3})
