--Variables
getgenv().Farm = false
getgenv().ClickB = false
getgenv().AutoSkill = false
getgenv().AutoEgg = false
getgenv().TargetMob = ""
getgenv().TargetWorld = ""
getgenv().OwnTycoon = ""
local plr = game.Players.LocalPlayer
local plrName = plr.Name
local plrRP = plr.Character.HumanoidRootPart
wait = task.wait
local VirtualInputManager = game:GetService("VirtualInputManager")
local Luh = {
	[1] = "RequestAction",
	[2] = "Combat",
	[3] = "Combat",
}

local RedPrismEgg = {
	[1] = "HatchEgg",
	[2] = "Red Prism",
	[3] = "Multiple",
}

local function Attack()
	game
		:GetService("ReplicatedStorage").Modules.ServiceLoader.NetworkService.Events.Objects.UpdateMelee
		:FireServer(unpack(Luh))
end
local function SkillFunc()
	if
		game:GetService("Players").LocalPlayer.PlayerGui.Display.HUD.Right.Skills.Container["1"].Level.Text
		== "UNLOCKED"
	then
		if
			game:GetService("Players").LocalPlayer.PlayerGui.Display.HUD.Right.Skills.Container["1"].Toggle.Timer.Text
			== ""
		then
			VirtualInputManager:SendKeyEvent(true, "Z", false, game)
			wait()
			VirtualInputManager:SendKeyEvent(false, "Z", false, game)
		end
	end

	if
		game:GetService("Players").LocalPlayer.PlayerGui.Display.HUD.Right.Skills.Container["2"].Level.Text
		== "UNLOCKED"
	then
		if
			game:GetService("Players").LocalPlayer.PlayerGui.Display.HUD.Right.Skills.Container["2"].Toggle.Timer.Text
			== ""
		then
			VirtualInputManager:SendKeyEvent(true, "X", false, game)
			wait()
			VirtualInputManager:SendKeyEvent(false, "X", false, game)
		end
	end

	if
		game:GetService("Players").LocalPlayer.PlayerGui.Display.HUD.Right.Skills.Container["3"].Level.Text
		== "UNLOCKED"
	then
		if
			game:GetService("Players").LocalPlayer.PlayerGui.Display.HUD.Right.Skills.Container["3"].Toggle.Timer.Text
			== ""
		then
			VirtualInputManager:SendKeyEvent(true, "C", false, game)
			wait()
			VirtualInputManager:SendKeyEvent(false, "C", false, game)
		end
	end

	if
		game:GetService("Players").LocalPlayer.PlayerGui.Display.HUD.Right.Skills.Container["4"].Level.Text
		== "UNLOCKED"
	then
		if
			game:GetService("Players").LocalPlayer.PlayerGui.Display.HUD.Right.Skills.Container["4"].Toggle.Timer.Text
			== ""
		then
			VirtualInputManager:SendKeyEvent(true, "V", false, game)
			wait()
			VirtualInputManager:SendKeyEvent(false, "V", false, game)
		end
	end

	if
		game:GetService("Players").LocalPlayer.PlayerGui.Display.HUD.Right.Skills.Container["5"].Level.Text
		== "UNLOCKED"
	then
		if
			game:GetService("Players").LocalPlayer.PlayerGui.Display.HUD.Right.Skills.Container["5"].Toggle.Timer.Text
			== ""
		then
			VirtualInputManager:SendKeyEvent(true, "F", false, game)
			wait()
			VirtualInputManager:SendKeyEvent(false, "F", false, game)
		end
	end
end

--Get Tycoon
for i, v in pairs(game:GetService("Workspace").Tycoons:GetDescendants()) do
	if v:IsA("ObjectValue") and v.Name == "Owner" then
		if tostring(v.Value) == plrName then
			OwnTycoon = v.Parent.Parent.Name
			break
		end
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

--UI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

local gui = Library:create({
	Theme = Library.Themes.Serika,
})

local tab = gui:tab({
	Icon = "rbxassetid://6034996695",
	Name = "Main",
})

tab:dropdown({
	Name = "Choose a Mob",
	StartingText = "...",
	Items = {
		{ "G General", "G General" },
		{ "G Soldier", "G Soldier" },
		{ "G Captain", "G Captain" },
		{ "G Chief", "G Chief" },
		{ "M Colby", "M Colby" },
		{ "M Admiral", "M Admiral" },
		{ "M Soldier", "M Soldier" },
		{ "M Cadet", "M Cadet" },
	},
	Description = "List of Available Mob",
	Callback = function(v)
		TargetMob = v
	end,
})

tab:dropdown({
	Name = "Choose World",
	StartingText = "...",
	Items = {
		{ "Home", "Home" },
		{ "Red Line", "Red Line" },
	},
	Description = "List of Available World",
	Callback = function(v)
		TargetWorld = v
	end,
})

tab:Toggle({
	Name = "Toggle Farm",
	StartingState = false,
	Description = nil,
	Callback = function(state)
		Farm = state
	end,
})

tab:Toggle({
	Name = "Toggle Auto Click",
	StartingState = false,
	Description = "Get close to Spawner to work",
	Callback = function(state)
		ClickB = state
	end,
})

tab:Toggle({
	Name = "Toggle Auto Egg",
	StartingState = false,
	Description = "Won't work if Auto Farm is ON | Red Prism EGG",
	Callback = function(state)
		AutoEgg = state
	end,
})

tab:Toggle({
	Name = "Toggle Auto Skill",
	StartingState = false,
	Description = "Auto Skill",
	Callback = function(state)
		AutoSkill = state
	end,
})

spawn(function()
	while wait() do
		if AutoSkill then
			SkillFunc()
		end

		if AutoEgg then
			game
				:GetService("ReplicatedStorage").Modules.ServiceLoader.NetworkService.Events.Objects.UpdatePets
				:FireServer(unpack(RedPrismEgg))
		end

		if ClickB then
			fireproximityprompt(
				game:GetService("Workspace").Tycoons[OwnTycoon].Tycoon.Objects["1"].Spawners.Start.Model.Proximity.Attachment.TycoonSpawn
			)
		end

		if Farm then
			for i, v in pairs(game:GetService("Workspace").Enemies[TargetWorld].Units:GetChildren()) do
				if v:IsA("Model") then
					if v:FindFirstChild("Head") and v.Head:FindFirstChild("Overhead") then
						if v.Head.Overhead.Health.Current.Value > 0 then
							if v.Head.Overhead:FindFirstChild("Name").Text == TargetMob then
								repeat
									wait()
									if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
										game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame
											* CFrame.new(0, -6.5, 0)
										game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(
											game.Players.LocalPlayer.Character.HumanoidRootPart.Position,
											v.HumanoidRootPart.Position
										)
										Attack()
										if AutoSkill then
											SkillFunc()
										end
									end
								until game
										:GetService("Players").LocalPlayer.PlayerGui.Display.Notifications
										:FindFirstChildWhichIsA("Frame") or Farm == false

								for _, z in
									pairs(
										game
											:GetService("Players").LocalPlayer.PlayerGui.Display.Notifications
											:GetChildren()
									)
								do
									if z:IsA("Frame") then
										z:Destroy()
									end
								end
							end
						end
					end
				end
			end
		end
	end
end)
