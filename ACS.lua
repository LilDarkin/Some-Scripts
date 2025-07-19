--Variables
getgenv().AutoRaid = false
getgenv().RaidMap = ''
getgenv().RaidDifficulty = ''

getgenv().RaidTeam = ''
getgenv().RaidChestTeam = ''
getgenv().RaidSwitchTeam = false
getgenv().RaidSwitchChestTeam = false
wait = task.wait

local enemies = workspace.Worlds.Raids.Enemies
local isRaidDone = true
local currentMapLoc = ''

local difficulties = {
    'Easy',
    'Medium',
    'Hard',
    'Impossible',
    'Nightmare',
    'Torment'
}

--Get Maps
local Maps = {}

for i, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.MainGui.Windows.RaidLobby.Main.Options.Worlds:GetChildren()) do
    if v:IsA('Frame') then
        table.insert(Maps, v.Name)
    end
end

wait(1)

--Instant Interact
game:GetService("ProximityPromptService").PromptButtonHoldBegan:Connect(function(prompt)
    prompt.HoldDuration = 0
end)

--Anti AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
    vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    wait(1)
    vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

-- Functions
local VirtualInputManager = game:GetService("VirtualInputManager")

local function equipOne()
    VirtualInputManager:SendKeyEvent(true, "One", false, game)
    wait()
    VirtualInputManager:SendKeyEvent(false, "One", false, game)
end

local function equipTwo()
    VirtualInputManager:SendKeyEvent(true, "Two", false, game)
    wait()
    VirtualInputManager:SendKeyEvent(false, "Two", false, game)
end

local function equipThree()
    VirtualInputManager:SendKeyEvent(true, "Three", false, game)
    wait()
    VirtualInputManager:SendKeyEvent(false, "Three", false, game)
end

local selectRoom = {
    [1] = workspace.Worlds.Hub.DungeonTemple.1.RaidRooms.Room4,
    [2] = true
}
local selectMap = {}
local selectDiff = {}
local startRoom = {
    [1] = workspace.Worlds.Hub.DungeonTemple.1.RaidRooms.Room4,
}

local function startSelectedMap()
    selectMap = {
        [1] = workspace.Worlds.Hub.DungeonTemple.1.RaidRooms.Room4,
        [2] = "TargetWorld",
        [3] = RaidMap,
    }

    selectDiff = {
        [1] = workspace.Worlds.Hub.DungeonTemple.1.RaidRooms.Room4,
        [2] = "Difficulty",
        [3] = RaidDifficulty,
    }

    game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Raid"):WaitForChild("SetInRaid")
        :FireServer(
            unpack(selectRoom))
    wait(1)
    game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Raid"):WaitForChild("SetRaidSetting")
        :FireServer(unpack(selectMap))
    wait(1)
    game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Raid"):WaitForChild("SetRaidSetting")
        :FireServer(unpack(selectDiff))
    wait(1)
    game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Raid"):WaitForChild("StartRaidFromRoom")
        :FireServer(unpack(startRoom))

    print('Starting Raid... ' .. RaidMap .. ' - ' .. RaidDifficulty)
end

local function checkMap()
    local raidLoc = ''
    local raids = workspace.Worlds.Raids:GetChildren()

    for _, raid in ipairs(raids) do
        local spawnFolder = raid:FindFirstChild("Spawns")
        if spawnFolder then
            local defaultFolder = spawnFolder:FindFirstChild("Default")
            if defaultFolder and #defaultFolder:GetChildren() > 0 then
                local spawnLocation = defaultFolder:GetChildren()[1]
                local spawnPosition = spawnLocation.Position or Vector3.new()

                -- Find the nearest enemy to this spawn point
                local nearestEnemy = nil
                local shortestDistance = math.huge

                for _, v in pairs(enemies:GetDescendants()) do
                    if v:IsA("Model") and v:FindFirstChild("HumanoidRootPart") then
                        local enemyRootPart = v:FindFirstChild("HumanoidRootPart")
                        local enemyPos = enemyRootPart.Position
                        local distance = (enemyPos - spawnPosition).Magnitude

                        if distance < shortestDistance then
                            shortestDistance = distance
                            nearestEnemy = v
                        end
                    end
                end
                raidLoc = raid
            end
        end
    end

    return raidLoc
end

local function checkifRaidDone()
    if currentMapLoc == '' then return false end

    local zoneNames = {}
    local ZoneCompletedChildren = currentMapLoc.ZonesCompleted

    -- Collect all zones containing "zone" in their names
    for _, folder in ipairs(currentMapLoc:GetChildren()) do
        if folder:IsA("Folder") and string.find(folder.Name:lower(), "zone") then
            if folder.name ~= "ZonesCompleted" then
                table.insert(zoneNames, folder.Name)
            end
        end
    end

    local allZonesCompleted = (#zoneNames == #ZoneCompletedChildren:GetChildren())

    return allZonesCompleted
end

local function checkIfChestSpawned()
    local chestFolder = currentMapLoc:GetDescendants()
    print('Checking if chest spawned')

    for _, v in pairs(chestFolder) do
        if v:IsA("Model") and v.Name == 'RaidChest' then
            return true
        end
    end
    return false
end

local function collectAllChests()
    local chestFolder = currentMapLoc:GetDescendants()
    print('Collecting Chests...')

    for _, v in pairs(chestFolder) do
        if v:IsA("Model") and v.Name == "RaidChest" then
            game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(
                v.HumanoidRootPart.CFrame * CFrame.new(0, 1, 0)
            )
            wait(1)
            VirtualInputManager:SendKeyEvent(true, "E", false, game)
            wait()
            VirtualInputManager:SendKeyEvent(false, "E", false, game)
            wait(4)
        end
    end
end

--Quit Raid
local quitRaid = {
    [1] = "Hub",
    [2] = "Raids"
}

local function exitRaid()
    print('Exiting Raid...')

    game:GetService("ReplicatedStorage"):WaitForChild("Remote"):WaitForChild("Player"):WaitForChild("Teleport")
        :FireServer(unpack(quitRaid))
end

-- Brick
local activeBrick = nil

local function createOrRecreateBrick()
    if not activeBrick or not activeBrick.Parent then
        activeBrick = Instance.new("Part")
        activeBrick.Name = "TeleportBrick"
        activeBrick.Size = Vector3.new(5, 2, 5) -- Size of the brick
        activeBrick.Anchored = true
        activeBrick.CanCollide = true
        activeBrick.BrickColor = BrickColor.new("Bright red") -- Color of the brick
        activeBrick.Parent = workspace
    end
end

local function moveBrickToHead(enemy)
    local head = enemy:FindFirstChild("Head")
    if head then
        createOrRecreateBrick()                                      -- Ensure the brick exists
        activeBrick.Position = head.Position + Vector3.new(0, 15, 0) -- Move brick above the enemy's head
    end
end

local function teleportPlayerToBrick()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart and activeBrick then
        humanoidRootPart.CFrame = activeBrick.CFrame * CFrame.new(0, 5, 0)
    end
end

local function checkProximityToBrick()
    local player = game.Players.LocalPlayer
    local character = player.Character
    local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")

    if humanoidRootPart and activeBrick then
        local distance = (humanoidRootPart.Position - activeBrick.Position).Magnitude
        return distance <= 60
    end

    return false
end

--UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

local gui = Library:create({
    Theme = Library.Themes.Serika,
})

local tab = gui:tab({
    Icon = "rbxassetid://6034996695",
    Name = "Raid",
})

tab:dropdown({
    Name = "Choose Map",
    StartingText = "...",
    Items = Maps,
    Description = "List of Available Map",
    Callback = function(v)
        RaidMap = v
    end,
})

tab:dropdown({
    Name = "Choose Difficulty",
    StartingText = "...",
    Items = difficulties,
    Description = "List of Available Difficulty",
    Callback = function(v)
        RaidDifficulty = v
    end,
})

tab:Toggle({
    Name = "Toggle Raid Farm",
    StartingState = false,
    Description = "Auto Raid Farm",
    Callback = function(state)
        AutoRaid = state
    end,
})

tab:dropdown({
    Name = "Choose Raid Team",
    StartingText = "...",
    Items = {
        "Team 1",
        "Team 2",
        "Team 3",
    },
    Description = nil,
    Callback = function(v)
        RaidTeam = v
    end,
})

tab:Toggle({
    Name = "Toggle Raid Switch Team",
    StartingState = false,
    Description = "Auto Switch Team",
    Callback = function(state)
        RaidSwitchTeam = state
    end,
})

tab:dropdown({
    Name = "Choose Raid Chest Team",
    StartingText = "...",
    Items = {
        "Team 1",
        "Team 2",
        "Team 3",
    },
    Description = nil,
    Callback = function(v)
        RaidChestTeam = v
    end,
})

tab:Toggle({
    Name = "Toggle Raid Switch Team",
    StartingState = false,
    Description = "Auto Chest Switch Team",
    Callback = function(state)
        RaidSwitchChestTeam = state
    end,
})

spawn(function()
    while wait() do
        if AutoRaid then
            currentMapLoc = ''

            if RaidSwitchTeam then
                if RaidTeam == 'Team 1' then
                    equipOne()
                elseif RaidTeam == 'Team 2' then
                    equipTwo()
                elseif RaidTeam == 'Team 3' then
                    equipThree()
                end
            end

            if isRaidDone then
                startSelectedMap()
            end

            if isRaidDone then
                isRaidDone = false
                wait(3)
                currentMapLoc = checkMap()
            end

            wait(3)

            repeat
                wait()
                for i, v in pairs(enemies:GetChildren()) do
                    if v:isA('Model') and v:FindFirstChild('HumanoidRootPart') then
                        moveBrickToHead(v)
                        wait(0.5)
                        teleportPlayerToBrick()

                        repeat
                            wait()
                            if v:FindFirstChild('HumanoidRootPart') then
                                if checkProximityToBrick() then
                                    teleportPlayerToBrick()
                                end
                            end
                        until not v:IsDescendantOf(enemies) or AutoRaid == false
                    end
                end
            until checkifRaidDone() or AutoRaid == false

            repeat
                wait(1)
            until checkIfChestSpawned() or AutoRaid == false

            if RaidSwitchChestTeam then
                if RaidChestTeam == 'Team 1' then
                    equipOne()
                elseif RaidChestTeam == 'Team 2' then
                    equipTwo()
                elseif RaidChestTeam == 'Team 3' then
                    equipThree()
                end
            end

            wait(1)

            collectAllChests()

            wait(1)

            exitRaid()
            isRaidDone = true

            wait(3)
        end
    end
end)
