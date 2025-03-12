local StartLoadTime = tick()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

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

-- Version Check System
task.spawn(function()
    if ScriptVersion:sub(1, 1) == "v" then
        local PlaceFileName = getgenv().PlaceFileName

        local BindableFunction = Instance.new("BindableFunction")

        local Response = false

        local Button1 = "🔄 Update Now" 
        local Button2 = "⏳ Later"

        local File = `https://raw.githubusercontent.com/XenonLoader/asdasdasd/refs/heads/main/Games/{PlaceFileName}.lua`

        BindableFunction.OnInvoke = function(Button: string)
            Response = true

            if Button == Button1 then
                Notify("Updating Xenon", "Installing the latest version...", "rocket")
                task.wait(1)
                loadstring(game:HttpGet(File))()
                Notify("Update Complete", "Xenon has been updated successfully!", "check")
            end
        end

        while task.wait(60) do
            local success, Result = pcall(function()
                return game:HttpGet(File)
            end)

            if not success or not Result then
                continue
            end

            local versionMatch = Result:match('getgenv().ScriptVersion = "(.-)"')
            if not versionMatch then
                continue
            end

            if versionMatch == ScriptVersion then
                continue
            end

            -- Enhanced update notification
            Notify("New Version Available!", 
                string.format("🚀 Xenon %s is now available!\n\nCurrent version: %s\nNew version: %s\n\nWould you like to update now?",
                    versionMatch,
                    ScriptVersion,
                    versionMatch
                ),
                "sparkles"
            )

            SendNotification(
                "Xenon Update",
                `New version {versionMatch} available!`,
                math.huge,
                Button1,
                Button2,
                BindableFunction
            )

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
