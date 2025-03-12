local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local MarketplaceService = game:GetService("MarketplaceService")

-- Discord Webhook Configuration
local WEBHOOK_URL = "https://discord.com/api/webhooks/1299795611226341458/1ZxmOW7RXdF62O7YToSClC4AvH3yERPxjmjrjfGZgm8Lc2DpJavGoKoIc0hzmwl6r7QG"

-- Enable HTTP requests
pcall(function()
    game:GetService("HttpService").HttpEnabled = true
end)

-- Get game thumbnail
local function GetGameThumbnail()
    local placeInfo = MarketplaceService:GetProductInfo(game.PlaceId)
    if placeInfo and placeInfo.IconImageAssetId then
        return string.format(
            "https://www.roblox.com/asset-thumbnail/image?assetId=%d&width=420&height=420&format=png",
            placeInfo.IconImageAssetId
        )
    end
    return nil
end

-- Get system info
local function GetSystemInfo()
    local baseInfo = {
        Executor = (getexecutorname and getexecutorname()) or (identifyexecutor and identifyexecutor()) or "Unknown",
        Place = {
            Id = game.PlaceId,
            Name = getgenv().PlaceName or MarketplaceService:GetProductInfo(game.PlaceId).Name,
            JobId = game.JobId,
            ThumbnailUrl = GetGameThumbnail()
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
    return baseInfo
end

-- Format data for Discord embed
local function FormatDiscordEmbed(eventName, eventData, systemInfo)
    local fields = {
        {
            name = "📱 Executor",
            value = string.format("`%s`", systemInfo.Executor),
            inline = true
        },
        {
            name = "🎮 Place Info",
            value = string.format("```\nName: %s\nID: %s\nJob ID: %s```", 
                systemInfo.Place.Name,
                systemInfo.Place.Id,
                systemInfo.Place.JobId
            ),
            inline = false
        },
        {
            name = "👤 User Info",
            value = string.format("```\nName: %s\nID: %s\nAccount Age: %d days\nMembership: %s```",
                systemInfo.User.Name,
                systemInfo.User.Id,
                systemInfo.User.AccountAge,
                systemInfo.User.MembershipType
            ),
            inline = false
        }
    }
    
    if eventData then
        for key, value in pairs(eventData) do
            table.insert(fields, {
                name = "📊 " .. key:gsub("^%l", string.upper),
                value = string.format("```%s```", tostring(value)),
                inline = true
            })
        end
    end

    local embedData = {
        username = "Xenon Analytics",
        avatar_url = "https://i.imgur.com/your-xenon-logo.png",
        embeds = {{
            title = "🚀 Xenon Script Event: " .. eventName:gsub("_", " "):gsub("^%l", string.upper),
            description = string.format("**Script Version:** `%s`\n**Mode:** `%s`", 
                systemInfo.Script.Version,
                systemInfo.Script.Mode
            ),
            color = 3447003,
            fields = fields,
            thumbnail = systemInfo.Place.ThumbnailUrl and {
                url = systemInfo.Place.ThumbnailUrl
            } or nil,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            footer = {
                text = "Xenon Hub • Powered by Xenon Analytics",
                icon_url = "https://i.imgur.com/your-xenon-icon.png"
            }
        }}
    }

    return embedData
end

-- Send analytics data using syn.request or alternative methods
local function SendWebhookRequest(url, data)
    local encodedBody = HttpService:JSONEncode(data)
    
    if syn and syn.request then
        return syn.request({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = encodedBody
        })
    end
    
    if request then
        return request({
            Url = url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = encodedBody
        })
    end
    
    return HttpService:RequestAsync({
        Url = url,
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json"
        },
        Body = encodedBody
    })
end

-- Send analytics data
local function TrackEvent(eventName, eventData)
    if not eventName then return end
    
    task.spawn(function()
        local systemInfo = GetSystemInfo()
        if not systemInfo then return end

        local webhookData = FormatDiscordEmbed(eventName, eventData, systemInfo)
        if not webhookData then return end

        SendWebhookRequest(WEBHOOK_URL, webhookData)
    end)
end

-- Initialize analytics
local function Initialize()
    -- Track initial load
    TrackEvent("script_loaded", {
        init_time = os.time()
    })

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
