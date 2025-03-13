local StartLoadTime = tick()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Player = Players.LocalPlayer

local getgenv: () -> ({[string]: any}) = getfenv().getgenv

local PlaceName: string = getgenv().PlaceName or game:GetService("AssetService"):GetGamePlacesAsync(game.GameId):GetCurrentPage()[1].Name

local getexecutorname = getfenv().getexecutorname
local identifyexecutor: () -> (string) = getfenv().identifyexecutor
local request = getfenv().request
local getconnections: (RBXScriptSignal) -> ({RBXScriptConnection}) = getfenv().getconnections
local queue_on_teleport: (Code: string) -> () = getfenv().queue_on_teleport
local setfpscap: (FPS: number) -> () = getfenv().setfpscap
local isrbxactive: () -> (boolean) = getfenv().isrbxactive
local setclipboard: (Text: string) -> () = getfenv().setclipboard
local firesignal: (RBXScriptSignal) -> () = getfenv().firesignal

if not getgenv().ScriptVersion then
    getgenv().ScriptVersion = "Dev Mode"
end

local ScriptVersion = getgenv().ScriptVersion

-- Function to compare version numbers
local function compareVersions(v1, v2)
    if not v1 or not v2 then return 0 end
    
    -- Remove 'v' prefix if exists
    v1 = tostring(v1):gsub("^v", "")
    v2 = tostring(v2):gsub("^v", "")
    
    -- Split versions into parts
    local v1Parts = v1:split(".")
    local v2Parts = v2:split(".")
    
    -- Compare each part
    for i = 1, math.max(#v1Parts, #v2Parts) do
        local v1Part = tonumber(v1Parts[i]) or 0
        local v2Part = tonumber(v2Parts[i]) or 0
        
        if v1Part < v2Part then
            return -1
        elseif v1Part > v2Part then
            return 1
        end
    end
    
    return 0
end

-- Create update notification GUI function
local function CreateUpdateNotification(currentVersion, newVersion, isDowngrade, changelog)
    -- Create ScreenGui
    local UpdateGui = Instance.new("ScreenGui")
    UpdateGui.Name = "XenonUpdateNotification"
    UpdateGui.Parent = game:GetService("CoreGui")
    
    -- Create main frame with blur effect
    local BlurEffect = Instance.new("BlurEffect")
    BlurEffect.Size = 10
    BlurEffect.Parent = game:GetService("Lighting")
    
    -- Create main frame (increased height to accommodate changelog)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 320, 0, 280)
    MainFrame.Position = UDim2.new(0.5, -160, 1.2, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = UpdateGui
    
    -- Add gradient
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 40)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    UIGradient.Parent = MainFrame
    
    -- Add corner radius
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    -- Add stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(60, 60, 80)
    Stroke.Thickness = 1.5
    Stroke.Parent = MainFrame
    
    -- Create icon
    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 32, 0, 32)
    Icon.Position = UDim2.new(0, 15, 0, 15)
    Icon.BackgroundTransparency = 1
    Icon.Image = isDowngrade and "rbxassetid://6031075938" or "rbxassetid://6026568198"
    Icon.Parent = MainFrame
    
    -- Create title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -70, 0, 30)
    Title.Position = UDim2.new(0, 55, 0, 15)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(240, 240, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Text = isDowngrade and "Version Mismatch Detected!" or "New Update Available!"
    Title.Parent = MainFrame
    
    -- Create version info
    local VersionInfo = Instance.new("TextLabel")
    VersionInfo.Name = "VersionInfo"
    VersionInfo.Size = UDim2.new(1, -30, 0, 50)
    VersionInfo.Position = UDim2.new(0, 15, 0, 55)
    VersionInfo.BackgroundTransparency = 1
    VersionInfo.TextColor3 = Color3.fromRGB(180, 180, 200)
    VersionInfo.TextSize = 14
    VersionInfo.Font = Enum.Font.Gotham
    VersionInfo.TextXAlignment = Enum.TextXAlignment.Left
    VersionInfo.Text = string.format("Current version: %s\n%s version: %s",
        currentVersion,
        isDowngrade and "Required" or "New",
        newVersion
    )
    VersionInfo.Parent = MainFrame
    
    -- Create changelog frame with scrolling
    local ChangelogFrame = Instance.new("ScrollingFrame")
    ChangelogFrame.Name = "ChangelogFrame"
    ChangelogFrame.Size = UDim2.new(0.9, 0, 0, 100)
    ChangelogFrame.Position = UDim2.new(0.05, 0, 0, 110)
    ChangelogFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
    ChangelogFrame.BorderSizePixel = 0
    ChangelogFrame.ScrollBarThickness = 4
    ChangelogFrame.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 80)
    ChangelogFrame.Parent = MainFrame
    
    -- Add corner radius to changelog frame
    local ChangelogCorner = Instance.new("UICorner")
    ChangelogCorner.CornerRadius = UDim.new(0, 6)
    ChangelogCorner.Parent = ChangelogFrame
    
    -- Create changelog text
    local ChangelogText = Instance.new("TextLabel")
    ChangelogText.Name = "ChangelogText"
    ChangelogText.Size = UDim2.new(1, -20, 1, -10)
    ChangelogText.Position = UDim2.new(0, 10, 0, 5)
    ChangelogText.BackgroundTransparency = 1
    ChangelogText.TextColor3 = Color3.fromRGB(200, 200, 220)
    ChangelogText.TextSize = 12
    ChangelogText.Font = Enum.Font.Gotham
    ChangelogText.TextXAlignment = Enum.TextXAlignment.Left
    ChangelogText.TextYAlignment = Enum.TextYAlignment.Top
    ChangelogText.TextWrapped = true
    ChangelogText.Text = changelog or "No changelog available"
    ChangelogText.Parent = ChangelogFrame
    
    -- Adjust scrolling frame content size
    ChangelogFrame.CanvasSize = UDim2.new(0, 0, 0, ChangelogText.TextBounds.Y + 10)
    
    -- Create update button
    local UpdateButton = Instance.new("TextButton")
    UpdateButton.Name = "UpdateButton"
    UpdateButton.Size = UDim2.new(0.85, 0, 0, 36)
    UpdateButton.Position = UDim2.new(0.075, 0, 1, -80)
    UpdateButton.BackgroundColor3 = isDowngrade and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(59, 130, 246)
    UpdateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    UpdateButton.TextSize = 14
    UpdateButton.Font = Enum.Font.GothamBold
    UpdateButton.Text = isDowngrade and "⚠️ Switch Version" or "🚀 Update Now"
    UpdateButton.Parent = MainFrame
    
    -- Add gradient to button
    local ButtonGradient = Instance.new("UIGradient")
    ButtonGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, isDowngrade and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(59, 130, 246)),
        ColorSequenceKeypoint.new(1, isDowngrade and Color3.fromRGB(220, 38, 38) or Color3.fromRGB(37, 99, 235))
    })
    ButtonGradient.Parent = UpdateButton
    
    -- Add corner radius to button
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 6)
    ButtonCorner.Parent = UpdateButton
    
    -- Create later button
    local LaterButton = Instance.new("TextButton")
    LaterButton.Name = "LaterButton"
    LaterButton.Size = UDim2.new(0.85, 0, 0, 30)
    LaterButton.Position = UDim2.new(0.075, 0, 1, -35)
    LaterButton.BackgroundTransparency = 1
    LaterButton.TextColor3 = Color3.fromRGB(130, 130, 150)
    LaterButton.TextSize = 13
    LaterButton.Font = Enum.Font.Gotham
    LaterButton.Text = isDowngrade and "Continue Anyway" or "Remind me later"
    LaterButton.Parent = MainFrame
    
    -- Animate the frame in
    local tweenInfo = TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local tween = TweenService:Create(MainFrame, tweenInfo, {
        Position = UDim2.new(0.5, -160, 0.5, -140)
    })
    tween:Play()
    
    -- Button hover effects
    UpdateButton.MouseEnter:Connect(function()
        TweenService:Create(UpdateButton, TweenInfo.new(0.3), {
            BackgroundColor3 = isDowngrade and Color3.fromRGB(220, 38, 38) or Color3.fromRGB(37, 99, 235)
        }):Play()
    end)
    
    UpdateButton.MouseLeave:Connect(function()
        TweenService:Create(UpdateButton, TweenInfo.new(0.3), {
            BackgroundColor3 = isDowngrade and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(59, 130, 246)
        }):Play()
    end)
    
    -- Button handlers
    UpdateButton.MouseButton1Click:Connect(function()
        -- Animate out
        local tweenOut = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -160, 1.2, 0)
        })
        tweenOut:Play()
        
        -- Remove blur and destroy GUI
        tweenOut.Completed:Connect(function()
            BlurEffect:Destroy()
            UpdateGui:Destroy()
            
            -- Update script
            Notify(isDowngrade and "Switching Version" or "Updating Xenon",
                  isDowngrade and "Switching to the required version..." or "Installing the latest version...",
                  isDowngrade and "alert-triangle" or "rocket")
            task.wait(1)
            local success, err = pcall(function()
                loadstring(game:HttpGet(string.format(
                    "https://raw.githubusercontent.com/XenonLoader/asdasdasd/refs/heads/main/Games/%s.lua",
                    getgenv().PlaceFileName
                )))()
            end)
            if not success then
                Notify("Update Failed", "Error: " .. tostring(err), "x")
            else
                Notify(isDowngrade and "Version Switch Complete" or "Update Complete",
                      isDowngrade and "Successfully switched to the required version!" or "Xenon has been updated successfully!",
                      "check")
            end
        end)
    end)
    
    LaterButton.MouseButton1Click:Connect(function()
        -- Animate out
        local tweenOut = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(0.5, -160, 1.2, 0)
        })
        tweenOut:Play()
        
        -- Remove blur and destroy GUI
        tweenOut.Completed:Connect(function()
            BlurEffect:Destroy()
            UpdateGui:Destroy()
        end)
    end)
    
    return UpdateGui
end

-- Version Check System
task.spawn(function()
    if ScriptVersion and ScriptVersion:sub(1, 1) == "v" and getgenv().PlaceFileName then
        -- Get the raw URL for the game script
        local rawUrl = string.format(
            "https://raw.githubusercontent.com/XenonLoader/asdasdasd/refs/heads/main/Games/%s.lua",
            getgenv().PlaceFileName
        )

        while task.wait(30) do -- Check every 30 seconds
            local success, result = pcall(function()
                return game:HttpGet(rawUrl)
            end)

            if not success or not result then
                warn("Failed to fetch version. Retrying in 30 seconds...")
                continue
            end

            -- Extract version from the script
            local versionMatch = nil
            local changelog = nil
            
            -- Find version in the script
            local versionStart = result:find('getgenv().ScriptVersion = "')
            if versionStart then
                local versionEnd = result:find('"', versionStart + 27)
                if versionEnd then
                    versionMatch = result:sub(versionStart + 27, versionEnd - 1)
                end
            end

            if not versionMatch then
                warn("Failed to extract version. Retrying in 30 seconds...")
                continue
            end

            -- Extract changelog
            local changelogStart = result:find('getgenv().Changelog = %[%[')
            if changelogStart then
                local changelogEnd = result:find('%]%]', changelogStart)
                if changelogEnd then
                    changelog = result:sub(changelogStart + 23, changelogEnd - 1)
                end
            end

            -- Compare versions
            local comparison = compareVersions(ScriptVersion, versionMatch)
            
            if comparison == 0 then
                -- Versions are equal, continue checking
                continue
            elseif comparison > 0 then
                -- Current version is higher than required (downgrade needed)
                CreateUpdateNotification(ScriptVersion, versionMatch, true, changelog or "No changelog available")
                break
            else
                -- Update available
                CreateUpdateNotification(ScriptVersion, versionMatch, false, changelog or "No changelog available")
                break
            end
        end
    end
end)

getgenv().gethui = function()
    return game:GetService("CoreGui")
end

getgenv().XenonConnections = getgenv().XenonConnections or {}

local function HandleConnection(Connection: RBXScriptConnection, Name: string)
    if getgenv().XenonConnections[Name] then
        getgenv().XenonConnections[Name]:Disconnect()
    end

    getgenv().XenonConnections[Name] = Connection
end

getgenv().HandleConnection = HandleConnection

getgenv().GetClosestChild = function(Children: {PVInstance}, Callback: ((Child: PVInstance) -> boolean)?, MaxDistance: number?)
    local Character = Player.Character

    if not Character then
        return
    end

    local HumanoidRootPart: Part = Character:FindFirstChild("HumanoidRootPart")

    if not HumanoidRootPart then
        return
    end

    local CurrentPosition: Vector3 = HumanoidRootPart.Position

    local ClosestMagnitude = MaxDistance or math.huge
    local ClosestChild

    for _, Child in Children do
        if not Child:IsA("PVInstance") then
            continue
        end

        if Callback and Callback(Child) then
            continue
        end

        local Magnitude = (Child:GetPivot().Position - CurrentPosition).Magnitude

        if Magnitude < ClosestMagnitude then
            ClosestMagnitude = Magnitude
            ClosestChild = Child
        end
    end

    return ClosestChild
end

if not firesignal and getconnections then
    firesignal = function(Signal: RBXScriptSignal)
        local Connections = getconnections(Signal)
        if #Connections > 0 then
            Connections[#Connections]:Fire()
        end
    end
end

local UnsupportedName = " (Executor Unsupported)"

local function ApplyUnsupportedName(Name: string, Condition: boolean)
    return Name..if Condition then "" else UnsupportedName
end

getgenv().ApplyUnsupportedName = ApplyUnsupportedName

local OriginalFlags = {}

if getgenv().Flags then
    for FlagName: string, FlagInfo in getgenv().Flags do
        if typeof(FlagInfo.CurrentValue) ~= "boolean" then
            continue
        end

        OriginalFlags[FlagName] = FlagInfo.CurrentValue
        FlagInfo:Set(false)
    end
end

if getgenv().Rayfield then
    getgenv().Rayfield:Destroy()
end

local Rayfield

if getgenv().RayfieldTesting then
    Rayfield = loadstring(getgenv().RayfieldTesting)()
else
    repeat
        pcall(function()
            Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/XenonLoader/NewRepo/refs/heads/main/Rayfield.luau"))()
        end)
        task.wait()
    until Rayfield
end

getgenv().Initiated = nil

local function SendNotification(Title: string, Text: string, Duration: number?, Button1: string?, Button2: string?, Callback: BindableFunction?)
    StarterGui:SetCore("SendNotification", {
        Title = Title,
        Text = Text,
        Duration = Duration or 10,
        Button1 = Button1,
        Button2 = Button2,
        Callback = Callback
    })
end

local Flags: {[string]: {["CurrentValue"]: any, ["CurrentOption"]: {string}}} = Rayfield.Flags

getgenv().Flags = Flags

local function Notify(Title: string, Content: string, Image: string)
    if not Rayfield then
        return
    end

    Rayfield:Notify({
        Title = Title,
        Content = Content,
        Duration = 10,
        Image = Image or "rocket",
    })
end

getgenv().Notify = Notify

if not getgenv().PlaceFileName then
    local PlaceFileName = PlaceName:gsub("%b[]", "")
    PlaceFileName = PlaceFileName:gsub("[^%a]", "")
    getgenv().PlaceFileName = PlaceFileName
end

local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

HandleConnection(Player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.zero)
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightMeta, false, game)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightMeta, false, game)
end), "AntiAFK")

type Tab = {
    CreateSection: (self: Tab, Name: string) -> Section,
    CreateDivider: (self: Tab) -> Divider,
}

local Window = Rayfield:CreateWindow({
    Name = `Xenon | {PlaceName} | {ScriptVersion or "Dev Mode"}`,
    Icon = "rocket",
    LoadingTitle = "🚀 Xenon Hub Loading...",
    LoadingSubtitle = PlaceName,
    Theme = "DarkBlue",
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Xenon",
        FileName = `{getgenv().PlaceFileName or `DevMode-{game.PlaceId}`}-{Player.Name}`
    },
    Discord = {
        Enabled = true,
        Invite = "cF8YeDPt2G",
        RememberJoins = true
    },
})

getgenv().Window = Window

local Tab: Tab = Window:CreateTab("Home", "rocket")

Tab:CreateSection("🌟 Quick Start")

Tab:CreateLabel("Welcome to Xenon Hub!", "sparkles")

Tab:CreateSection("📱 Social")

Tab:CreateLabel("discord.gg/cF8YeDPt2G", "messages-square")

Tab:CreateSection("📊 Performance")

local Stats = game:GetService("Stats")
local RunService = game:GetService("RunService")

-- Performance Labels
local PingLabel = Tab:CreateLabel("Ping: 0 ms", "activity")
local FPSLabel = Tab:CreateLabel("FPS: 0/s", "bar-chart")
local MemoryLabel = Tab:CreateLabel("Memory: 0 MB", "database")
local ServerTimeLabel = Tab:CreateLabel("Server Time: 00:00:00", "clock")
local PlayersLabel = Tab:CreateLabel("Players: 0/0", "users")
local UptimeLabel = Tab:CreateLabel("Uptime: 0m 0s", "timer")
local CPULabel = Tab:CreateLabel("CPU Usage: 0%", "cpu")
local GraphicsLabel = Tab:CreateLabel("Graphics: Level 0", "layers")

-- Format memory size
local function FormatMemory(memory)
    if memory < 1000 then
        return string.format("%.1f KB", memory)
    else
        return string.format("%.1f MB", memory / 1024)
    end
end

-- Format time
local function FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    if hours > 0 then
        return string.format("%02dh %02dm %02ds", hours, minutes, secs)
    else
        return string.format("%02dm %02ds", minutes, secs)
    end
end

local StartTime = tick()

task.spawn(function()
    while getgenv().Flags == Flags and task.wait(0.25) do
        -- Update ping and FPS
        PingLabel:Set(`Ping: {math.floor(Stats.PerformanceStats.Ping:GetValue() * 100) / 100} ms`)
        FPSLabel:Set(`FPS: {math.floor(1 / Stats.FrameTime * 10) / 10}/s`)
        
        -- Update memory usage
        local memoryUsage = Stats:GetTotalMemoryUsageMb()
        MemoryLabel:Set(`Memory: {FormatMemory(memoryUsage)}`)
        
        -- Update server time
        local serverTime = os.date("*t")
        ServerTimeLabel:Set(`Server Time: {string.format("%02d:%02d:%02d", serverTime.hour, serverTime.min, serverTime.sec)}`)
        
        -- Update players count
        local playerCount = #Players:GetPlayers()
        local maxPlayers = Players.MaxPlayers
        PlayersLabel:Set(`Players: {playerCount}/{maxPlayers}`)
        
        -- Update uptime
        local uptime = tick() - StartTime
        UptimeLabel:Set(`Uptime: {FormatTime(uptime)}`)

        -- Update CPU usage
        local cpuUsage = Stats:GetTotalMemoryUsageMb()
        CPULabel:Set(`CPU Usage: {math.floor(Stats.PerformanceStats.CPU:GetValue())}%`)

        -- Update graphics quality
        local graphicsQuality = settings().Rendering.QualityLevel
        GraphicsLabel:Set(`Graphics: Level {graphicsQuality}`)
    end
end)

Tab:CreateSection("📝 Changelog")

-- Fetch changelog from game file
local function GetGameChangelog()
    -- Check if PlaceFileName exists
    if not getgenv().PlaceFileName then
        return "• Changelog not available - Place file name not found"
    end

    local success, Result = pcall(function()
        return game:HttpGet(string.format(
            "https://raw.githubusercontent.com/XenonLoader/asdasdasd/refs/heads/main/Games/%s.lua",
            tostring(getgenv().PlaceFileName) -- Ensure string conversion
        ))
    end)

    if success and Result then
        local changelogStart = Result:find('getgenv().Changelog = %[%[')
        if changelogStart then
            local changelogEnd = Result:find('%]%]', changelogStart)
            if changelogEnd then
                return Result:sub(changelogStart + 23, changelogEnd - 1)
            end
        end
    end
    return "• Changelog not available"
end

-- Create changelog paragraph with nil checks
Tab:CreateParagraph({
    Title = string.format(
        "%s %s",
        tostring(PlaceName or "Unknown Place"),
        tostring(ScriptVersion or "Unknown Version")
    ),
    Content = GetGameChangelog()
})

getgenv().CreateFeature = function(Tab: Tab, FeatureName: string)
    if not Features[FeatureName] then
        return warn(`The feature '{FeatureName}' does not exist in the Features.`)
    end
    
    for _, Data in Features[FeatureName] do
        Tab[`Create{Data.Element}`](Tab, Data.Info)
    end
end

getgenv().CreateUniversalTabs = function()
    Rayfield:LoadConfiguration()

    task.wait(1)

    for FlagName: string, CurrentValue: boolean? in OriginalFlags do
        local FlagInfo = Flags[FlagName]

        if not FlagInfo then
            continue
        end

        FlagInfo:Set(CurrentValue)
    end

    Notify("Welcome to Xenon", `Loaded in {math.floor((tick() - StartLoadTime) * 10) / 10}s`, "rocket")
end

local XenonStarted = getgenv().XenonStarted

if XenonStarted then
    XenonStarted()
end

return true
