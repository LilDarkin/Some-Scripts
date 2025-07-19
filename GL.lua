-- For Grimoire's Legacy (Auto Mine only)

-- Anti AFK

loadstring(game:HttpGet("https://raw.githubusercontent.com/hassanxzayn-lua/Anti-afk/main/antiafkbyhassanxzyn"))();

-- Safe environment
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local rocks = workspace["Open World"]["Quest Cave"].Rocks
local replicatedStorage = game:GetService("ReplicatedStorage")
local wait = task.wait

-- Kill old AutoMine thread if it exists
if getgenv().AutoMineThread then
    getgenv().AutoMineRunning = false -- Stop the loop
    warn("[AutoMine] Stopping old instance...")
    task.wait(1)                      -- Let it stop before replacing
end

-- Toggle & state flags
getgenv().AutoMineRunning = true
getgenv().AutoMine = true

-- Save the thread globally
getgenv().AutoMineThread = task.spawn(function()
    warn("[AutoMine] Started.")
    while getgenv().AutoMineRunning and getgenv().AutoMine do
        wait(0.1)

        local questGui = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("Quests")
        if questGui and not questGui.Quest.Visible then
            replicatedStorage.Events.Dialog:FireServer("Roger", "On it!")
            wait(1)
        end

        for _, rock in pairs(rocks:GetChildren()) do
            if not getgenv().AutoMineRunning or not getgenv().AutoMine then return end
            if rock:IsA("MeshPart") then
                humanoidRootPart.CFrame = rock.CFrame + Vector3.new(0, 5, 0)
                wait(0.1)

                while getgenv().AutoMineRunning and getgenv().AutoMine and rock.Parent == rocks do
                    replicatedStorage.Events.MiscTools:FireServer("Pickaxe")
                    wait(0.5)
                end
            end
        end
    end
    warn("[AutoMine] Cleaned up.")
end)
