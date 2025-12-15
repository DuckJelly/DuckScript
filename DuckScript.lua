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
frame.BackgroundColor3 = Color3.fromRGB(25, 15, 50) -- Dark purple
frame.BorderSizePixel = 0
frame.Parent = gui

local outline = Instance.new("UIStroke")
outline.Thickness = 3
outline.Color = Color3.fromRGB(147, 0, 255) -- Purple
outline.Parent = frame

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(147, 0, 255) -- Purple
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
    for _ = 1, 3 do -- Run animation 3 times
        typeTitle("TB3 Hub")
        task.wait(0.5)
        title.Text = ""
        task.wait(0.5)
    end
    gui:Destroy()
    blur:Destroy()
    -- Load the main hub
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
    local Window = Rayfield:CreateWindow({
        Name = "TB3 Hub",
        LoadingTitle = "TB3 Hub",
        LoadingSubtitle = "",
        ConfigurationSaving = {Enabled = false},
        Discord = {Enabled = false},
        KeySystem = false
    })

    -- Main Tab
    local MainTab = Window:CreateTab("Main")
    local MainSection = MainTab:CreateSection("Toggles")

    MainTab:CreateToggle({
        Name = "Infinite Jump",
        CurrentValue = false,
        Callback = function(Value)
            local InfiniteJumpEnabled = Value
            game:GetService("UserInputService").JumpRequest:Connect(function()
                if InfiniteJumpEnabled then
                    game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
                end
            end)
        end
    })

    MainTab:CreateToggle({
        Name = "Fly",
        CurrentValue = false,
        Callback = function(Value)
            local FlyEnabled = Value
            local char = game.Players.LocalPlayer.Character
            local hum = char:WaitForChild("Humanoid")
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new(0,0,0)
            bv.Parent = char.HumanoidRootPart
            repeat task.wait() bv.Velocity = Vector3.new(0,50,0) until not FlyEnabled
            bv:Destroy()
        end
    })

    MainTab:CreateSlider({
        Name = "Walkspeed",
        Range = {16, 500},
        Increment = 1,
        CurrentValue = 16,
        Callback = function(Value)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    })

    -- Dupe Tab
    local DupeTab = Window:CreateTab("Dupe")
    local DupeSection = DupeTab:CreateSection("Gun Dupe (Equip First)")

    DupeTab:CreateButton({
        Name = "Market Gun Dupe",
        Callback = function()
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
                    if owner and owner.Value = Player.Name then ToolId = item:GetAttribute("SpecialId") end
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
        end
    })

    DupeTab:CreateToggle({
        Name = "Auto Gun Dupe (Loop)",
        CurrentValue = false,
        Callback = function(Value)
            _G.AutoDupe = Value
            while _G.AutoDupe do
                -- Call the dupe function
                local ReplicatedStorage = game:GetService("ReplicatedStorage")
                local Players = game:GetService("Players")
                local Player = Players.LocalPlayer
                local Character = Player.Character or Player.CharacterAdded:Wait()
                local Backpack = Player:WaitForChild("Backpack")
                local Tool = Character:FindFirstChildOfClass("Tool")
                if not Tool then task.wait(5) continue end
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
                        if owner and owner.Value = Player.Name then ToolId = item:GetAttribute("SpecialId") end
                    end
                end)
                task.spawn(function() ReplicatedStorage.ListWeaponRemote:FireServer(ToolName, 99999) end)
                task.wait(delay)
                task.spawn(function() ReplicatedStorage.BackpackRemote:InvokeServer("Store", ToolName) end)
                task.wait(3)
                if ToolId then task.spawn(function() ReplicatedStorage.BuyItemRemote:FireServer(ToolName, "Remove", ToolId) end) end
                task.spawn(function() ReplicatedStorage.BackpackRemote:InvokeServer("Grab", ToolName) end)
                marketconnection:Disconnect()
                task.wait(5)
            end
        end
    })

    -- Farm Tab
    local FarmTab = Window:CreateTab("Farm")
    FarmTab:CreateToggle({
        Name = "Construction Autofarm",
        CurrentValue = false,
        Callback = function(Value)
            _G.Farm = Value
            local jobnigga = workspace.ConstructionStuff["Start Job"].CFrame
            local function startjob()
                if not game.Players.LocalPlayer:GetAttribute("WorkingJob") or game.Players.LocalPlayer:GetAttribute("WorkingJob") == false then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = jobnigga
                    fireproximityprompt(workspace.ConstructionStuff["Start Job"].Prompt)
                end
            end
            local function autoequipwood()
                if game:GetService("Players").LocalPlayer.Backpack.PlyWood then
                    game:GetService("Players").LocalPlayer.Backpack.PlyWood.Parent = game:GetService("Players").LocalPlayer.Character
                end
            end
            local function wood()
                for i, v in pairs(workspace.ConstructionStuff:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and v.ActionText == "Wall" then
                        fireproximityprompt(v)
                    end
                end
            end
            local function grabwood()
                for i, v in pairs(workspace.ConstructionStuff["Grab Wood"]:GetChildren()) do
                    if v:IsA("ProximityPrompt") and v.ActionText == "Wood" then
                        fireproximityprompt(v)
                    end
                end
            end
            local function mainautofarm()
                for i, v in pairs(workspace.ConstructionStuff:GetDescendants()) do
                    if v:IsA("Part") and string.find(v.Name, "Prompt") then
                        local text = v:FindFirstChild("Attachment"):FindFirstChild("Gui"):FindFirstChild("Label").Text 
                        if not string.find(text, "RESETS") then
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                        end
                    end
                end
                if not (game.Players.LocalPlayer.Backpack:FindFirstChild("PlyWood") or game.Players.LocalPlayer.Character:FindFirstChild("PlyWood")) then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1728, 371, -1177)
                end
            end
            while _G.Farm do task.wait(0.25)
                pcall(startjob)
                pcall(wood)
                pcall(grabwood)
                pcall(autoequipwood)
                pcall(mainautofarm)
            end
        end
    })

    -- Combat Tab
    local CombatTab = Window:CreateTab("Combat")
    CombatTab:CreateToggle({
        Name = "ESP",
        CurrentValue = false,
        Callback = function(Value)
            _G.ESP = Value
            local function createESP(plr)
                local box = Instance.new("BoxHandleAdornment")
                box.Name = "ESPBox"
                box.Adornee = plr.Character
                box.AlwaysOnTop = true
                box.ZIndex = 0
                box.Size = Vector3.new(4, 5, 2)
                box.Transparency = 0.5
                box.Color3 = Color3.fromRGB(147, 0, 255)
                box.Parent = plr.Character
            end
            for _, p in pairs(game.Players:GetPlayers()) do
                if p ~= player then createESP(p) end
            end
            game.Players.PlayerAdded:Connect(function(p)
                p.CharacterAdded:Wait()
                createESP(p)
            end)
            while _G.ESP do task.wait(1) end
            for _, p in pairs(game.Players:GetPlayers()) do
                if p.Character:FindFirstChild("ESPBox") then p.Character.ESPBox:Destroy() end
            end
        end
    })

    CombatTab:CreateToggle({
        Name = "Aimbot",
        CurrentValue = false,
        Callback = function(Value)
            _G.Aimbot = Value
            local camera = workspace.CurrentCamera
            local function getClosestPlayer()
                local closest = nil
                local dist = math.huge
                for _, p in pairs(game.Players:GetPlayers()) do
                    if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
                        local pos, onScreen = camera:WorldToViewportPoint(p.Character.Head.Position)
                        if onScreen then
                            local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)).Magnitude
                            if mag < dist then
                                dist = mag
                                closest = p
                            end
                        end
                    end
                end
                return closest
            end
            while _G.Aimbot do task.wait()
                local target = getClosestPlayer()
                if target then
                    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, target.Character.Head.Position)
                end
            end
        end
    })

    -- TP Tab
    local TPTab = Window:CreateTab("TP")
    TPTab:CreateButton({
        Name = "Gun Shop",
        Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-947, 22, -1050) -- Approximate gun shop
        end
    })
    TPTab:CreateButton({
        Name = "Construction Site",
        Callback = function()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1728, 371, -1177)
        end
    })
    -- Add more TPs as needed

    Rayfield:Notify({Title = "Loaded", Content = "TB3 Hub Ready!", Duration = 3})
end)
