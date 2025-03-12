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
        Connections[#Connections]:Fire()
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

-- Create update notification GUI
local function CreateUpdateNotification(currentVersion, newVersion)
    -- Create ScreenGui
    local UpdateGui = Instance.new("ScreenGui")
    UpdateGui.Name = "XenonUpdateNotification"
    UpdateGui.Parent = game:GetService("CoreGui")
    
    -- Create main frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    MainFrame.Position = UDim2.new(0.5, -150, 1, 50) -- Start below screen
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = UpdateGui
    
    -- Add corner radius
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = MainFrame
    
    -- Create title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -20, 0, 40)
    Title.Position = UDim2.new(0, 10, 0, 10)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 22
    Title.Font = Enum.Font.GothamBold
    Title.Text = "🚀 New Update Available!"
    Title.Parent = MainFrame
    
    -- Create version info
    local VersionInfo = Instance.new("TextLabel")
    VersionInfo.Name = "VersionInfo"
    VersionInfo.Size = UDim2.new(1, -20, 0, 60)
    VersionInfo.Position = UDim2.new(0, 10, 0, 60)
    VersionInfo.BackgroundTransparency = 1
    VersionInfo.TextColor3 = Color3.fromRGB(200, 200, 200)
    VersionInfo.TextSize = 16
    VersionInfo.Font = Enum.Font.Gotham
    VersionInfo.Text = string.format("Current version: %s\nNew version: %s", currentVersion, newVersion)
    VersionInfo.TextYAlignment = Enum.TextYAlignment.Top
    VersionInfo.Parent = MainFrame
    
    -- Create update button
    local UpdateButton = Instance.new("TextButton")
    UpdateButton.Name = "UpdateButton"
    UpdateButton.Size = UDim2.new(0.8, 0, 0, 40)
    UpdateButton.Position = UDim2.new(0.1, 0, 1, -90)
    UpdateButton.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    UpdateButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    UpdateButton.TextSize = 16
    UpdateButton.Font = Enum.Font.GothamBold
    UpdateButton.Text = "Update Now"
    UpdateButton.Parent = MainFrame
    
    -- Add corner radius to button
    local ButtonCorner = Instance.new("UICorner")
    ButtonCorner.CornerRadius = UDim.new(0, 8)
    ButtonCorner.Parent = UpdateButton
    
    -- Create later button
    local LaterButton = Instance.new("TextButton")
    LaterButton.Name = "LaterButton"
    LaterButton.Size = UDim2.new(0.8, 0, 0, 30)
    LaterButton.Position = UDim2.new(0.1, 0, 1, -40)
    LaterButton.BackgroundTransparency = 1
    LaterButton.TextColor3 = Color3.fromRGB(150, 150, 150)
    LaterButton.TextSize = 14
    LaterButton.Font = Enum.Font.Gotham
    LaterButton.Text = "Remind me later"
    LaterButton.Parent = MainFrame
    
    -- Animate the frame in
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local tween = TweenService:Create(MainFrame, tweenInfo, {
        Position = UDim2.new(0.5, -150, 0.5, -100)
    })
    tween:Play()
    
    -- Button handlers
    UpdateButton.MouseButton1Click:Connect(function()
        -- Animate out
        local tweenOut = TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -150, 1, 50)
        })
        tweenOut:Play()
        tweenOut.Completed:Wait()
        UpdateGui:Destroy()
        
        -- Update script
        Notify("Updating Xenon", "Installing the latest version...", "rocket")
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
            Notify("Update Complete", "Xenon has been updated successfully!", "check")
        end
    end)
    
    LaterButton.MouseButton1Click:Connect(function()
        -- Animate out
        local tweenOut = TweenService:Create(MainFrame, TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -150, 1, 50)
        })
        tweenOut:Play()
        tweenOut.Completed:Wait()
        UpdateGui:Destroy()
    end)
    
    return UpdateGui
end

-- Version Check System
task.spawn(function()
    if ScriptVersion:sub(1, 1) == "v" then
        local PlaceFileName = getgenv().PlaceFileName

        local File = string.format(
            "https://raw.githubusercontent.com/XenonLoader/asdasdasd/refs/heads/main/Games/%s.lua",
            PlaceFileName
        )

        while task.wait(60) do
            local success, Result = pcall(function()
                return game:HttpGet(File)
            end)

            if not success or not Result then
                warn("Failed to fetch the latest version. Retrying in 60 seconds...")
                continue
            end

            local splitResult = Result:split('getgenv().ScriptVersion = "')
            if not splitResult[2] then
                continue
            end

            local versionMatch = splitResult[2]:split('"')[1]
            if not versionMatch or versionMatch == "" then
                continue
            end

            if versionMatch == ScriptVersion then
                continue
            end

            -- Show animated update notification
            CreateUpdateNotification(ScriptVersion, versionMatch)
            break
        end
    end
end)

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

Tab:CreateParagraph({Title = `{PlaceName} {ScriptVersion}`, Content = getgenv().Changelog or "Changelog Not Found"})

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
