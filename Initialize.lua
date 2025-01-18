-- loadstring(game:HttpGet("https://raw.githubusercontent.com/XenonLoader/NewRepo/refs/heads/main/Initialize.lua"))()

local function Notify(Text)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Xenon Notification",
		Text = Text,
		Duration = 10
	})
end

local PlaceName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name

if PlaceName:find("]") then
	PlaceName = PlaceName:split("]")[2]
end

if PlaceName:find(")") then
	PlaceName = PlaceName:split(")")[2]
end

PlaceName = PlaceName:gsub("[^%a]", "")

local Code = game:HttpGet(`https://raw.githubusercontent.com/XenonLoader/asdasdasd/refs/heads/main/Games/{PlaceName}.lua`)

if Code then
	Notify("Game found, the script is loading.")
	loadstring(Code)()
else
	Notify("Could not find a script for this game.")
end
