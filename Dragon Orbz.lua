wait = task.wait

--Anti AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
	vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	wait(1)
	vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)

--GUI
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()

local gui = Library:Create({
	Name = "Dragon Orbz",
	Size = UDim2.fromOffset(600, 400),
	Theme = Library.Themes.Dark,
	Link = "https://github.com/deeeity/mercury-lib",
	ToggleKey = Enum.KeyCode.RightAlt,
})

local tab = gui:tab({
	Name = "Main",
	Icon = "rbxassetid://8677107889",
})

local misc = gui:tab({
	Name = "Teleports/Misc",
	Icon = "http://www.roblox.com/asset/?id=4799887091",
})

--Variables
getgenv().StartFarming = false
getgenv().SkillOnly = false
getgenv().TargetMob = ""
getgenv().MasteryFarm = false
getgenv().PercentHP = 0.2
getgenv().DistanceHM = 7
getgenv().getOrb = false
getgenv().ChooseWeapon = ""
getgenv().hpLeft = 0
getgenv().HighDistance = 30
getgenv().StopItNow = false

local VirtualInputManager = game:GetService("VirtualInputManager")

plr = game.Players.LocalPlayer
plrName = plr.Name
plrChar = plr.Character

--Functions
local ListOfMobs = {}
local ListOfWeapons = {}
local Spawns = {}
local add = false

local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
local File = pcall(function()
	AllIDs = game:GetService("HttpService"):JSONDecode(readfile("NotSameServers.json"))
end)
if not File then
	table.insert(AllIDs, actualHour)
	writefile("NotSameServers.json", game:GetService("HttpService"):JSONEncode(AllIDs))
end
function TPReturner()
	local Site
	if foundAnything == "" then
		Site = game.HttpService:JSONDecode(
			game:HttpGet("https://games.roblox.com/v1/games/" .. PlaceID .. "/servers/Public?sortOrder=Asc&limit=100")
		)
	else
		Site = game.HttpService:JSONDecode(
			game:HttpGet(
				"https://games.roblox.com/v1/games/"
					.. PlaceID
					.. "/servers/Public?sortOrder=Asc&limit=100&cursor="
					.. foundAnything
			)
		)
	end
	local ID = ""
	if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
		foundAnything = Site.nextPageCursor
	end
	local num = 0
	for i, v in pairs(Site.data) do
		local Possible = true
		ID = tostring(v.id)
		if tonumber(v.maxPlayers) > tonumber(v.playing) then
			for _, Existing in pairs(AllIDs) do
				if num ~= 0 then
					if ID == tostring(Existing) then
						Possible = false
					end
				else
					if tonumber(actualHour) ~= tonumber(Existing) then
						local delFile = pcall(function()
							delfile("NotSameServers.json")
							AllIDs = {}
							table.insert(AllIDs, actualHour)
						end)
					end
				end
				num = num + 1
			end
			if Possible == true then
				table.insert(AllIDs, ID)
				wait()
				pcall(function()
					writefile("NotSameServers.json", game:GetService("HttpService"):JSONEncode(AllIDs))
					wait()
					game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
				end)
				wait(4)
			end
		end
	end
end

function Teleport()
	while wait() do
		pcall(function()
			TPReturner()
			if foundAnything ~= "" then
				TPReturner()
			end
		end)
	end
end

function Notify(TitleMsg, Message, Timer)
	gui:Notification({
		Title = TitleMsg,
		Text = Message,
		Duration = Timer,
		Callback = function() end,
	})
end

local function getTheOrb()
	for i, v in pairs(game:GetService("Workspace").Resources.SpawnedOrbs:GetChildren()) do
		if v:IsA("Tool") and v:FindFirstChild("Handle") then
			Notify("Got something!", "You got " .. v.Name, 10)
			game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(v.Handle.CFrame)
			wait(0.1)
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
				game:GetService("Workspace").Resources.NPC.SetSpawn["North City"].CFrame
		elseif v:IsA("Model") and v:FindFirstChild("Part") then
			Notify("Got something!", "You got " .. v.Name, 10)
			game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(v.Part.CFrame)
			wait(0.1)
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
				game:GetService("Workspace").Resources.NPC.SetSpawn["North City"].CFrame
		end
	end
	for i, v in pairs(game:GetService("Workspace"):GetChildren()) do
		if v:IsA("Tool") and v:FindFirstChild("Handle") then
			Notify("Got something!", "You got " .. v.Name, 10)
			game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(v.Handle.CFrame)
			wait(0.1)
			game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
				game:GetService("Workspace").Resources.NPC.SetSpawn["North City"].CFrame
		end
	end
end

local function skill(tool)
	if plr.PlayerGui.Ability.Background:FindFirstChild("BackpackTitle") then
		for i, v in pairs(plr.PlayerGui.Ability.Background:GetChildren()) do
			if v:IsA("Frame") and v:FindFirstChild("Locked") and v.Name ~= "Meditation" then
				if v.Locked.Visible == false then
					function getNil(name, class)
						for _, v in pairs(getnilinstances()) do
							if v.ClassName == class and v.Name == name then
								return v
							end
						end
					end

					args = {
						[1] = v.Name,
						[2] = tool,
						[3] = {
							["mouseHit"] = CFrame.new(Vector3.new(0, 0, 0)),
							["Camera"] = workspace.Camera,
							["Mouse"] = getNil("Instance", "PlayerMouse"),
						},
					}

					game
						:GetService("ReplicatedStorage").Packages.Knit.Services.AbilityService.RF.Ability
						:InvokeServer(unpack(args))
				end
			end
		end
	end
end

local function getMaps()
	for i, v in pairs(game:GetService("Workspace").Resources.NPC.SetSpawn:GetChildren()) do
		if v:IsA("Part") then
			add = true
			for index, value in ipairs(Spawns) do
				if v.Name == value then
					add = false
				end
			end
			if add == true then
				table.insert(Spawns, v.Name)
			end
		end
	end

	table.sort(Spawns, function(a, b)
		return a < b
	end)
end

local function getMobs()
	for i, v in pairs(game:GetService("Workspace").Resources.SpawnedAI:GetChildren()) do
		if v:IsA("Model") then
			add = true
			for index, value in ipairs(ListOfMobs) do
				if v.Name == value then
					add = false
				end
			end
			if add == true then
				table.insert(ListOfMobs, v.Name)
			end
		end
	end

	table.sort(ListOfMobs, function(a, b)
		return a < b
	end)
end

local function getWeapons()
	for i, v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do
		if v:IsA("Tool") then
			add = true
			for index, value in ipairs(ListOfMobs) do
				if v.Name == value then
					add = false
				end
			end
			if add == true then
				table.insert(ListOfWeapons, v.Name)
			end
		end
	end

	table.sort(ListOfWeapons, function(a, b)
		return a < b
	end)
end

getMaps()
getWeapons()
getMobs()

--Main
local WeaponDropdown = tab:dropdown({
	Name = "Weapon to use",
	StartingText = "...",
	Items = ListOfWeapons,
	Description = "List of Available Weapon(s)",
	Callback = function(v)
		ChooseWeapon = v
	end,
})

local MobDropdown = tab:dropdown({
	Name = "Target Mob",
	StartingText = "...",
	Items = ListOfMobs,
	Description = "List of Available Mobs",
	Callback = function(v)
		TargetMob = v
	end,
})

tab:Button({
	Name = "REFRESH",
	Description = "Refresh all dropdowns",
	Callback = function()
		plrChar.Humanoid:UnequipTools()
		Notify("Please Wait!", "Refreshing...", 3)
		MobDropdown:Clear()
		WeaponDropdown:Clear()
		wait()
		for k in pairs(ListOfWeapons) do
			ListOfWeapons[k] = nil
		end
		for k in pairs(ListOfMobs) do
			ListOfMobs[k] = nil
		end
		wait(1)
		getWeapons()
		getMobs()
		wait(1)
		WeaponDropdown:AddItems(ListOfWeapons)
		MobDropdown:AddItems(ListOfMobs)
	end,
})

tab:Toggle({
	Name = "Auto Farm",
	StartingState = false,
	Description = "With Auto Quest | Turn off Skill Only before using",
	Callback = function(state)
		StartFarming = state

		if SkillOnly then
			Notify("ERROR!", "Turn Off Skill Only or it might broke", 5)
		end

		if state == false then
			StopItNow = true
			VirtualInputManager:SendKeyEvent(false, "C", false, game)
		else
			StopItNow = false
		end
	end,
})

local SkillTab = tab:Toggle({
	Name = "Skill Only",
	StartingState = false,
	Description = "Same as Auto Farm but abilities only | Turn off Auto Farm before using",
	Callback = function(state)
		if StartFarming then
			Notify("ERROR!", "Turn Off Auto Farm or it might broke", 5)
		end

		SkillOnly = state

		if state == false then
			StopItNow = true
			VirtualInputManager:SendKeyEvent(false, "C", false, game)
		else
			StopItNow = false
		end
	end,
})

tab:Toggle({
	Name = "Mastery Farm",
	StartingState = false,
	Description = "Will use ability (For Auto Farm)",
	Callback = function(state)
		MasteryFarm = state
	end,
})

tab:Slider({
	Name = "Custom % Health (1-9 means 10-90)",
	Default = 2,
	Min = 1,
	Max = 9,
	Callback = function(perzent)
		PercentHP = tonumber("0." .. perzent)
	end,
})

tab:Slider({
	Name = "Distance before using Ability",
	Default = 30,
	Min = 1,
	Max = 70,
	Callback = function(distance)
		HighDistance = distance
	end,
})

tab:Slider({
	Name = "Distance behind the mob",
	Default = 5,
	Min = 1,
	Max = 10,
	Callback = function(distance)
		DistanceHM = distance
	end,
})

tab:Button({
	Name = "FIX???",
	Description = "If auto farming is BUG click this idk if it will work lol XD",
	Callback = function()
		for i, v in pairs(game:GetService("Workspace").Live.Characters[plrName].HumanoidRootPart:GetChildren()) do
			if v:IsA("BodyVelocity") then
				v:Destroy()
			end
		end
		wait(0.1)
		if StopItNow == false then
			StopItNow = true
			wait(3)
			StopItNow = false
		end
	end,
})

--Misc
misc:dropdown({
	Name = "Teleport to",
	StartingText = "...",
	Items = Spawns,
	Description = "List of Available Maps",
	Callback = function(v)
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame =
			game:GetService("Workspace").Resources.NPC.SetSpawn[v].CFrame
	end,
})

misc:Toggle({
	Name = "Get ORB",
	StartingState = false,
	Description = "Snipe spawned ORB and Dragon Ball | Not recommended while auto farming",
	Callback = function(state)
		getOrb = state
	end,
})

misc:Button({
	Name = "Snipe Orb/Dragon Ball",
	Description = "Self-explanatory",
	Callback = function()
		getTheOrb()
	end,
})

misc:Button({
	Name = "REJOIN SERVER",
	Description = "Self-explanatory",
	Callback = function()
		local ts = game:GetService("TeleportService")

		local p = game:GetService("Players").LocalPlayer

		ts:Teleport(game.PlaceId, p)
	end,
})

misc:Button({
	Name = "Server-Hop",
	Description = "Self-explanatory",
	Callback = function()
		Teleport()
	end,
})

spawn(function()
	while wait() do
		if getOrb then
			getTheOrb()
		end

		if StartFarming then
			for i, v in pairs(game:GetService("Workspace").Resources.SpawnedAI:GetChildren()) do
				if
					v:IsA("Model")
					and v.Name == TargetMob
					and v:FindFirstChild("Humanoid")
					and v:FindFirstChild("HumanoidRootPart")
				then
					VirtualInputManager:SendKeyEvent(true, "C", false, game)

					repeat
						wait()
						if StartFarming then
							if
								game:GetService("Workspace").Live.Characters:FindFirstChild(plrName)
								and game
									:GetService("Workspace").Live.Characters[plrName]
									:FindFirstChild("HumanoidRootPart")
								and game
										:GetService("Workspace").Live.Characters[plrName].HumanoidRootPart
										:FindFirstChild("BodyVelocity")
									== nil
							then --It will make you float
								char = game.Players.LocalPlayer.Character
								hm = char.HumanoidRootPart
								bv = Instance.new("BodyVelocity")
								bv.Parent = hm
								bv.MaxForce = Vector3.new(100000, 100000, 100000)
								bv.Velocity = Vector3.new(0, 0, 0)
								wait()
							end

							hpLeft = v.Humanoid.MaxHealth * PercentHP --Get the required health to use Ability

							game
								:GetService("ReplicatedStorage").Packages.Knit.Services.CharacterService.RF.SetTarget
								:InvokeServer(v)

							if game.Players.LocalPlayer.Backpack:FindFirstChild(ChooseWeapon) then -- Check if exist in the backpack and equip
								wait(1)
								game.Players.LocalPlayer.Character.Humanoid:EquipTool(
									game.Players.LocalPlayer.Backpack[ChooseWeapon]
								)
							end

							if plr.PlayerGui.Ability.Background:FindFirstChild("BackpackTitle") == nil then --Its for bug purposes
								plrChar.Humanoid:UnequipTools()
							end

							if getOrb then --Will get the spawned ORB/Dragon Balls
								getTheOrb()
							end

							if
								game:GetService("Players").LocalPlayer.PlayerGui.ActiveQuest.Background.Background.Visible
								== false
							then
								if TargetMob == "Destroyer" or TargetMob == "Oscar" then
									game
										:GetService("ReplicatedStorage").Packages.Knit.Services.QuestService.RF.AcceptQuest
										:InvokeServer("Elite Freezer Force Quest")
								else
									game
										:GetService("ReplicatedStorage").Packages.Knit.Services.QuestService.RF.AcceptQuest
										:InvokeServer(TargetMob .. " Quest")
								end
							end

							if plr.PlayerGui.Ability.Background:FindFirstChild("BackpackTitle") then
								if
									game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
									and v:FindFirstChild("Humanoid")
									and v:FindFirstChild("HumanoidRootPart")
								then
									if MasteryFarm then
										if v.Humanoid.Health <= hpLeft then
											game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame
												* CFrame.new(0, HighDistance, 0)
											skill(ChooseWeapon)
										else
											game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(
												v.HumanoidRootPart.CFrame
													- v.HumanoidRootPart.CFrame.lookVector * DistanceHM
											)

											game
												:GetService("ReplicatedStorage").Packages.Knit.Services.CombatService.RF.MeleeAttack
												:InvokeServer("Punch")
										end
									elseif MasteryFarm == false then
										game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(
											v.HumanoidRootPart.CFrame
												- v.HumanoidRootPart.CFrame.lookVector * DistanceHM
										)
										game
											:GetService("ReplicatedStorage").Packages.Knit.Services.CombatService.RF.MeleeAttack
											:InvokeServer("Punch")
									end
								end
							end
						end

					until v.Humanoid.Health == 0 or StartFarming == false or StopItNow == true

					for i, v in
						pairs(game:GetService("Workspace").Live.Characters[plrName].HumanoidRootPart:GetChildren())
					do
						if v:IsA("BodyVelocity") then
							v:Destroy()
						end
					end
				end
			end
		end

		if SkillOnly then
			for i, v in pairs(game:GetService("Workspace").Resources.SpawnedAI:GetChildren()) do
				if
					v:IsA("Model")
					and v.Name == TargetMob
					and v:FindFirstChild("Humanoid")
					and v:FindFirstChild("HumanoidRootPart")
				then
					VirtualInputManager:SendKeyEvent(true, "C", false, game)

					repeat
						wait()

						if SkillOnly then
							if
								game:GetService("Workspace").Live.Characters:FindFirstChild(plrName)
								and game
									:GetService("Workspace").Live.Characters[plrName]
									:FindFirstChild("HumanoidRootPart")
								and game
										:GetService("Workspace").Live.Characters[plrName].HumanoidRootPart
										:FindFirstChild("BodyVelocity")
									== nil
							then --It will make you float
								char = game.Players.LocalPlayer.Character
								hm = char.HumanoidRootPart
								bv = Instance.new("BodyVelocity")
								bv.Parent = hm
								bv.MaxForce = Vector3.new(100000, 100000, 100000)
								bv.Velocity = Vector3.new(0, 0, 0)
								wait()
							end

							hpLeft = v.Humanoid.MaxHealth * PercentHP --Get the required health to use Ability

							game
								:GetService("ReplicatedStorage").Packages.Knit.Services.CharacterService.RF.SetTarget
								:InvokeServer(v)

							if game.Players.LocalPlayer.Backpack:FindFirstChild(ChooseWeapon) then -- Check if exist in the backpack and equip
								wait(1)
								game.Players.LocalPlayer.Character.Humanoid:EquipTool(
									game.Players.LocalPlayer.Backpack[ChooseWeapon]
								)
							end

							if plr.PlayerGui.Ability.Background:FindFirstChild("BackpackTitle") == nil then --Its for bug purposes
								plrChar.Humanoid:UnequipTools()
							end

							if getOrb then --Will get the spawned ORB/Dragon Balls
								getTheOrb()
							end

							if
								game:GetService("Players").LocalPlayer.PlayerGui.ActiveQuest.Background.Background.Visible
								== false
							then
								if TargetMob == "Destroyer" or TargetMob == "Oscar" then
									game
										:GetService("ReplicatedStorage").Packages.Knit.Services.QuestService.RF.AcceptQuest
										:InvokeServer("Elite Freezer Force Quest")
								else
									game
										:GetService("ReplicatedStorage").Packages.Knit.Services.QuestService.RF.AcceptQuest
										:InvokeServer(TargetMob .. " Quest")
								end
							end

							if plr.PlayerGui.Ability.Background:FindFirstChild("BackpackTitle") then
								if
									game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
									and v:FindFirstChild("Humanoid")
									and v:FindFirstChild("HumanoidRootPart")
								then
									game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.HumanoidRootPart.CFrame
										* CFrame.new(0, HighDistance, 0)
									skill(ChooseWeapon)
								end
							end
						end

					until v.Humanoid.Health == 0 or SkillOnly == false or StopItNow == true

					for i, v in
						pairs(game:GetService("Workspace").Live.Characters[plrName].HumanoidRootPart:GetChildren())
					do
						if v:IsA("BodyVelocity") then
							v:Destroy()
						end
					end
				end
			end
		end
	end
end)
