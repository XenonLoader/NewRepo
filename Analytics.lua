local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer

-- Discord Webhook Configuration
local WEBHOOK_URL = "https://discord.com/api/webhooks/1299795611226341458/1ZxmOW7RXdF62O7YToSClC4AvH3yERPxjmjrjfGZgm8Lc2DpJavGoKoIc0hzmwl6r7QG"

-- Get system info
local function GetSystemInfo()
    local success, info = pcall(function()
        return {
            Executor = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "Unknown",
            Place = {
                Id = game.PlaceId,
                Name = getgenv().PlaceName or "Unknown",
                JobId = game.JobId
            },
            User = {
                Name = Player.Name,
                Id = Player.UserId,
                AccountAge = Player.AccountAge,
                MembershipType = tostring(Player.MembershipType)
            },
            Script = {
                Version = getgenv().ScriptVersion or "Unknown",
                Mode = getgenv().DevMode and "Development" or "Production"
            }
        }
    end)

    return success and info or {
        Executor = "Unknown",
        Place = { Id = game.PlaceId, Name = "Unknown", JobId = "Unknown" },
        User = { Name = "Unknown", Id = 0, AccountAge = 0, MembershipType = "None" },
        Script = { Version = "Unknown", Mode = "Unknown" }
    }
end

-- Format data for Discord embed
local function FormatDiscordEmbed(eventName, eventData, systemInfo)
    local fields = {}
    
    -- Add system info fields
    table.insert(fields, {
        name = "Executor",
        value = systemInfo.Executor,
        inline = true
    })
    
    table.insert(fields, {
        name = "Place",
        value = string.format("Name: %s\nID: %s", systemInfo.Place.Name, systemInfo.Place.Id),
        inline = true
    })
    
    table.insert(fields, {
        name = "User",
        value = string.format("Name: %s\nID: %s\nAge: %d days", 
            systemInfo.User.Name, 
            systemInfo.User.Id, 
            systemInfo.User.AccountAge),
        inline = true
    })
    
    -- Add event data if present
    if eventData then
        for key, value in pairs(eventData) do
            table.insert(fields, {
                name = key,
                value = tostring(value),
                inline = true
            })
        end
    end
    
    return {
        embeds = {{
            title = "Xenon Script Event: " .. eventName,
            description = "Script Version: " .. systemInfo.Script.Version,
            color = 3447003, -- Blue color
            fields = fields,
            footer = {
                text = "Mode: " .. systemInfo.Script.Mode .. " | Time: " .. os.date("%Y-%m-%d %H:%M:%S")
            }
        }}
    }
end

-- Send analytics data
local function TrackEvent(eventName, eventData)
    if not eventName then return end
    
    local systemInfo = GetSystemInfo()
    local webhookData = FormatDiscordEmbed(eventName, eventData, systemInfo)

    -- Send to Discord webhook asynchronously
    task.spawn(function()
        local success, response = pcall(function()
            return HttpService:RequestAsync({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(webhookData)
            })
        end)

        if getgenv().DevMode then
            if success then
                print("[Analytics] Event tracked:", eventName)
            else
                warn("[Analytics] Failed to track event:", response)
            end
        end
    end)
end

-- Initialize analytics
local function Initialize()
    TrackEvent("script_loaded")

    -- Track when player leaves
    Players.PlayerRemoving:Connect(function(player)
        if player == Player then
            TrackEvent("script_unloaded")
        end
    end)

    -- Track feature usage
    if getgenv().Flags then
        for flagName, flagInfo in pairs(getgenv().Flags) do
            if typeof(flagInfo.CurrentValue) == "boolean" then
                flagInfo.Callback = function(newValue)
                    TrackEvent("feature_toggle", {
                        feature = flagName,
                        state = newValue
                    })
                end
            end
        end
    end
end

-- Export analytics functions
getgenv().XenonAnalytics = {
    TrackEvent = TrackEvent
}

-- Initialize analytics
Initialize()

return true
