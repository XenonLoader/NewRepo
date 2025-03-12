local function Notify(Text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Xenon Notification",
        Text = Text,
        Duration = 10
    })
end


-- Get and clean place name
local PlaceName = game:GetService("AssetService"):GetGamePlacesAsync(game.GameId):GetCurrentPage()[1].Name

getgenv().PlaceName = PlaceName

PlaceName = PlaceName:gsub("%b[]", "")
PlaceName = PlaceName:gsub("[^%a]", "")

-- Load analytics first
local analyticsSuccess = pcall(function()
    local analyticsCode = game:HttpGet("https://raw.githubusercontent.com/XenonLoader/NewRepo/refs/heads/main/Analytics.lua")
    return loadstring(analyticsCode)()
end)

-- Try to load game-specific script
local Success, Code = pcall(game.HttpGet, game, string.format(
    "https://raw.githubusercontent.com/XenonLoader/asdasdasd/refs/heads/main/Games/%s.lua",
    PlaceName
))

if Success and Code:find("ScriptVersion = ") then
    Notify("Game found, the script is loading.")
    getgenv().PlaceFileName = PlaceName
else
    Notify("Game not found, loading universal.")
    getgenv().ScriptVersion = "Universal"
    Code = game:HttpGet("https://raw.githubusercontent.com/XenonLoader/NewRepo/refs/heads/main/Core.lua")
end

-- Handle script execution
local function HandleScript(ScriptFunction)
    local Success = pcall(ScriptFunction)
    if Success then
        Notify("Script executed successfully loaded")
    end
    return Success
end

getgenv().XenonHandleFunction = HandleScript

-- Execute the loaded script
HandleScript(loadstring(Code))

return true
