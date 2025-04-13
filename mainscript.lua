AnalyticsService = game:GetService("AnalyticsService")
CollectionService = game:GetService("CollectionService")
DataStoreService = game:GetService("DataStoreService")
HttpService = game:GetService("HttpService")
Lighting = game:GetService("Lighting")
MarketplaceService = game:GetService("MarketplaceService")
Players = game:GetService("Players")
ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Link=ReplicatedStorage:FindFirstChild("Link") or #ReplicatedStorage:GetChildren()>2 and ReplicatedStorage or ReplicatedStorage:GetChildren()[1]
RunService = game:GetService("RunService")
ServerScriptService = game:GetService("ServerScriptService")
ServerStorage = game:GetService("ServerStorage")
SoundService = game:GetService("SoundService")
StarterGui = game:GetService("StarterGui")
StarterPack = game:GetService("StarterPack")
StarterPlayer = game:GetService("StarterPlayer")
TeleportService = game:GetService("TeleportService")
TweenService = game:GetService("TweenService")
Teams = game:GetService("Teams")
VirtualUser = game:GetService("VirtualUser")
Workspace = game:GetService("Workspace")
UserInputService = game:GetService("UserInputService")
VirtualInputManager = game:GetService("VirtualInputManager")
ContextActionService = game:GetService("ContextActionService")
GuiService = game:GetService("GuiService")
print("ClientMonsterTools.lua loaded")

game.Players.LocalPlayer.Idled:Connect(function()
VirtualUser:CaptureController()
VirtualUser:ClickButton2(Vector2.new())
print("Roblox Tried to kick you but we didn't let them kick you :D") end)
warn("[Anti Afk] - loaded successfully") 

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({Name = "Dylan Hub - 🐟 Fisch 🐟 (keyless)", HidePremium = false, SaveConfig = false, ConfigFolder = "OrionTest"})

local MainTab = Window:MakeTab({
	Name = "AUTO-FARM",
	Icon = nil,
	PremiumOnly = false
})

local autoCastEnabled = false
local autoCastThread

MainTab:AddToggle({
	Name = "Auto Cast",
	Default = false,
	Callback = function(Value)
		autoCastEnabled = Value

		if autoCastEnabled then
			autoCastThread = task.spawn(function()
				while autoCastEnabled do
					local player = game.Players.LocalPlayer
					local character = player.Character or player.CharacterAdded:Wait()

					local tool = character:FindFirstChildOfClass("Tool")
					if tool and not tool:FindFirstChild("bobber") then
						local castEvent = tool:FindFirstChild("events") and tool.events:FindFirstChild("cast")
						if castEvent then
							local randomValue = math.random(90, 99)
							castEvent:FireServer(randomValue)

							local hrp = character:FindFirstChild("HumanoidRootPart")
							if hrp then
								hrp.Anchored = false
							end
						end
					end

					task.wait(0)
				end
			end)
		else
			-- Stop the loop
			autoCastEnabled = false
		end
	end
})

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local autoClickEnabled = false
local autoClickThread

-- Create Toggle and capture its return (assumes your UI lib returns the toggle object)
local autoClickToggle = MainTab:AddToggle({
    Name = "Auto Shake",
    Default = false,
    Callback = function(Value)
        autoClickEnabled = Value

        if autoClickEnabled and not autoClickThread then
            autoClickThread = task.spawn(function()
                while autoClickEnabled do
                    xpcall(function()
                        local shakeui = PlayerGui:FindFirstChild("shakeui")
                        if not shakeui then return end

                        local safezone = shakeui:FindFirstChild("safezone")
                        local button = safezone and safezone:FindFirstChild("button")
                        if button then
                            GuiService.SelectedObject = button
                            if GuiService.SelectedObject == button then
                                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                            end
                            task.wait(0)
                            GuiService.SelectedObject = nil
                        end
                    end, function(err)
                        warn("AutoClick error:", err)
                    end)
                    task.wait(0)
                end
                autoClickThread = nil
            end)
        elseif not Value and autoClickThread then
            autoClickEnabled = false
        end
    end
})

-- === UI Navigation Support ===
task.defer(function()
    wait(1) -- wait for toggle UI to fully render

    -- Try to find the actual toggle button
    local toggleButton = nil
    if typeof(autoClickToggle) == "Instance" then
        toggleButton = autoClickToggle:FindFirstChildWhichIsA("GuiButton", true)
    elseif typeof(autoClickToggle) == "table" and autoClickToggle.Frame then
        toggleButton = autoClickToggle.Frame:FindFirstChildWhichIsA("GuiButton", true)
    end

    if toggleButton and toggleButton:IsA("GuiObject") then
        -- Set it as the selected object
        GuiService.SelectedObject = toggleButton

        -- Highlight when selected
        GuiService:GetPropertyChangedSignal("SelectedObject"):Connect(function()
            if GuiService.SelectedObject == toggleButton then
                toggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            else
                toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            end
        end)

        -- Allow Enter key or gamepad A to activate the toggle
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if (input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.ButtonA)
                and GuiService.SelectedObject == toggleButton then

                toggleButton:Activate()
            end
        end)
    end
end)

local autoReelEnabled = false
local autoReelConnection

MainTab:AddToggle({
    Name = "Auto Reel",
    Default = false,
    Callback = function(Value)
        autoReelEnabled = Value

        -- Disconnect existing connection if toggle is turned off
        if not autoReelEnabled and autoReelConnection then
            autoReelConnection:Disconnect()
            autoReelConnection = nil
            return
        end

        -- Hook to detect when the playerbar appears
        if autoReelEnabled then
            autoReelConnection = PlayerGui.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "playerbar" and descendant.Parent and descendant.Parent.Name == "bar" then
                    task.spawn(function()
                        -- Optional: Wait for bar animation if needed
                        descendant:GetPropertyChangedSignal("Position"):Wait()

                        -- Short delay to simulate perfect timing (adjust if needed)
                        task.wait(0)

                        -- Fire the perfect catch event (100 = perfect)
                        game.ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, false)
                    end)
                end
            end)
        end
    end
})

MainTab:AddParagraph("Note:","These 3 Feature's will help you afk farm money, sorry for no perfect catches becuz I'm just a beginner / compare this to a macro, macro is slow and doesn't have instant reel unlike mine. this script is like macro but more advanced. made by dylan144_xy on discord, if you like to suggest a feature's on my script feel free to message me on discord btw. credits: ui from orion-library")

OrionLib:Init()