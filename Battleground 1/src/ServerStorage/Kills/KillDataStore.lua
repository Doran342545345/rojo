local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local profileStore = require(ServerStorage.Source.ProfileStore)

local Default_Profile = {
    Kills = 0,
    Items = {}
}
local KillDataStore = {}
local PlayerStore = profileStore.New("Kills", Default_Profile)
local Profiles: {[Player]: any} = {}
local loadingPlayers = {}

function KillDataStore.playerAdded(player)
    if loadingPlayers[player] then
        return
    end
    loadingPlayers[player] = true

    local success, profile = pcall(function()
        return PlayerStore:StartSessionAsync(`{player.UserId}`, {
            Cancel = function()
                return player.Parent ~= Players
            end,
        })
    end)

    if success and profile then
        profile:AddUserId(player.UserId)
        profile:Reconcile()

        profile.OnSessionEnd:Connect(function()
            Profiles[player] = nil
            player:Kick("Profile session ended unexpectedly. Please rejoin.")
        end)

        if player.Parent == Players then
            Profiles[player] = profile
            print(`Profile loaded for {player.DisplayName}`)
        else
            profile:EndSession()
        end
    else
        warn("Failed to start session for: ", player.Name)
        player:Kick("Failed to load profile. Please rejoin.")
    end

    loadingPlayers[player] = nil
end

function KillDataStore.GetKills(player)
    local profile = Profiles[player]
    if profile then
        return profile.Data.Kills or 0
    else
        warn(`No profile found for {player.Name}`)
        return 0
    end
end

function KillDataStore.AddKills(player,amt)
    local profile = Profiles[player]
    if profile then
        profile.Data.Kills = profile.Data.Kills + amt
    else
        warn(`No profile found for {player.Name}`)
        return 0
    end
end


function KillDataStore.Save(player)
    local profile = Profiles[player]
    if profile then
        local success, err = pcall(function()
            profile:EndSession()
        end)

        if success then
            print(`Profile successfully saved for {player.Name}`)
        else
            warn(`Failed to save profile for {player.Name}: {err}`)
        end
    else
        warn(`No active profile to save for {player.Name}`)
    end
end


for _, player in Players:GetPlayers() do
    task.spawn(KillDataStore.playerAdded, player)
end

Players.PlayerAdded:Connect(KillDataStore.playerAdded)

Players.PlayerRemoving:Connect(function(player)
    local success, err = pcall(function()
        KillDataStore.Save(player)
    end)

    if not success then
        warn(`Failed to save profile for {player.Name}: {err}`)
    end
end)

return KillDataStore
