local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)
local profileStore = require(ServerStorage.Source.ProfileStore)

local Default_Profile = {
    Kills = 0,
    Items = {}
}
local KillDataStore = {}
local PlayerStore = profileStore.New("Kills",Default_Profile)
local Profiles: {[player]: typeof(PlayerStore:StartSessionAsync())} = {}

function KillDataStore.playerAdded(player)
    local profile = PlayerStore:StartSessionAsync(`{player.UserId}`, {
        Cancel = function()
            return player.Parent ~= Players
        end,
    })


    if profile ~= nil then
        profile:AddUserId(player.UserId)
        profile:Reconcile()

        profile.OnSessionEnd:Connect(function()
            Profiles[player] = nil
            player:Kick("Profile session end - Please rejoin")
        end)

        if player.Parent == Players then
            Profiles[player] = profile
            print(`Profile loaded for {player.DisplayName}!`)

        else
            profile:EndSession()
        end

    else
        player:Kick(`Profile load fail - Please rejoin`)
    end
end
for _, player in Players:GetPlayers() do
    task.spawn(KillDataStore.playerAdded, player)
 end


function KillDataStore.Test()
    return math.random(1,10)
end

function KillDataStore.Save(player)
    local profile = Profiles[player]
   if profile ~= nil then
      profile:EndSession()
   end
end

return KillDataStore