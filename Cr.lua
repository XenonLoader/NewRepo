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
    print("Running Rayfield Testing")
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
        Image = Image or "info",
    })
end

getgenv().Notify = Notify

if not getgenv().PlaceFileName then
    local PlaceFileName = PlaceName:gsub("%b[]", "")
    PlaceFileName = PlaceFileName:gsub("[^%a]", "")
    getgenv().PlaceFileName = PlaceFileName
end

task.spawn(function()
    if ScriptVersion:sub(1, 1) == "v" then
        local PlaceFileName = getgenv().PlaceFileName

        local BindableFunction = Instance.new("BindableFunction")

        local Response = false

        local Button1 = "✅ Yes" 
        local Button2 = "❌ No"

        local File = `https://raw.githubusercontent.com/XenonLoader/asdasdasd/refs/heads/main/Games/{PlaceFileName}.lua`

        BindableFunction.OnInvoke = function(Button: string)
            Response = true

            if Button == Button1 then
                loadstring(game:HttpGet(File))()
            end
        end

        while task.wait(60) do
            local Result = game:HttpGet(File)

            if not Result then
                continue
            end

            Result = Result:split('getgenv().ScriptVersion = "')[2]
            Result = Result:split('"')[1]

            if Result == ScriptVersion then
                continue
            end

            SendNotification(`A new Xenon version {Result} has been detected!`, "Would you like to load it?", math.huge, Button1, Button2, BindableFunction)

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
    Icon = "rocket", -- Changed from snowflake to rocket
    LoadingTitle = "🚀 Xenon Hub Loading...", -- Updated loading title
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

local Tab: Tab = Window:CreateTab("Home", "rocket") -- Changed icon

Tab:CreateSection("🌟 Quick Start")

Tab:CreateLabel("Welcome to Xenon Hub!", "sparkles") -- Added sparkles icon

Tab:CreateSection("📱 Social")

Tab:CreateLabel("discord.gg/cF8YeDPt2G", "messages-square")

Tab:CreateSection("📊 Performance")

local PingLabel = Tab:CreateLabel("Ping: 0 ms", "activity") -- Changed to activity icon
local FPSLabel = Tab:CreateLabel("FPS: 0/s", "bar-chart") -- Changed to bar-chart icon

local Stats = game:GetService("Stats")

task.spawn(function()
    while getgenv().Flags == Flags and task.wait(0.25) do
        PingLabel:Set(`Ping: {math.floor(Stats.PerformanceStats.Ping:GetValue() * 100) / 100} ms`)
        FPSLabel:Set(`FPS: {math.floor(1 / Stats.FrameTime * 10) / 10}/s`)
    end
end)

Tab:CreateSection("📝 Changelog")

Tab:CreateParagraph({Title = `{PlaceName} {ScriptVersion}`, Content = getgenv().Changelog or "Changelog Not Found"})

-- Dev Mode Instructions Section
Tab:CreateSection("🛠️ Developer Mode")

Tab:CreateParagraph({
    Title = "How to Use Dev Mode",
    Content = [[
1. Before loading the script:
   • Set Version: getgenv().ScriptVersion = "v1.0.0-dev"
   • Enable Dev Mode: getgenv().DevMode = true

2. Features Available in Dev Mode:
   • Detailed debugging information
   • Performance monitoring
   • Test features access
   • Extended configuration options

3. Load the script normally after setting up]]
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
