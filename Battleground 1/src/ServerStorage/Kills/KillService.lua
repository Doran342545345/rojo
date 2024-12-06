local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local killsInit = require(script.Parent.KillDataStore)
local Knit = require(ReplicatedStorage.Packages.Knit)



local KillService = Knit.CreateService { 
    Name = "KillService",
    Client = {
        killsChanged = Knit.CreateSignal(),
    },
    _KillsPerPlayer = {},
    _StartingKills = 0,
}



local function leaderstats(plr)
    local dataStoreKills = 0
    local success, errorMessage = pcall(function()
        dataStoreKills = killsInit.GetKills(plr)
    end)

    if not success then
        warn("Failed to retrieve kills: " .. errorMessage)
        dataStoreKills = 0
    end

    -- Update _KillsPerPlayer
    KillService._KillsPerPlayer[plr] = dataStoreKills

    -- Create leaderstats
    local leaderstats = Instance.new("Folder")
    leaderstats.Parent = plr
    leaderstats.Name = "leaderstats"

    local kills = Instance.new("IntValue", leaderstats)
    kills.Name = "Kills"
    kills.Value = dataStoreKills


    kills.Changed:Connect(function(value)
        killsInit.AddKills(plr,value)
    end)

end


local function autoSave()
    while task.wait(60) do -- Save every 60 seconds
        for player, kills in pairs(KillService._KillsPerPlayer) do
            pcall(function()
                killsInit.Save(player)
            end)
        end
    end
end

task.spawn(autoSave)




function KillService.Client:GetKills(plr:Player)
    return self.Server:GetKills(plr)
end




function KillService:GetKills(player:Player): number
    local Kills = self._KillsPerPlayer[player] or self._StartingKills
    return Kills
end

function KillService:AddKills(plr: Player, amt: number)
    if typeof(amt) ~= "number" or amt <= 0 then
        warn("Invalid kill amount from client")
        return
    end

    local currentKills = self:GetKills(plr)
    local newKills = currentKills + amt
    self._KillsPerPlayer[plr] = newKills

    -- Update leaderstats
    local leaderstats = plr:FindFirstChild("leaderstats")
    if leaderstats then
        local kills = leaderstats:FindFirstChild("Kills")
        if kills then
            kills.Value = newKills
        end
    end

    -- Notify clients
    self.Client.killsChanged:Fire(plr, newKills)
end



function KillService:KnitStart()
    print("KillService Started")

    

end

function KillService:KnitInit()

    Players.PlayerAdded:Connect(function(player)

        killsInit.playerAdded(player)
        leaderstats(player)
    end)
end


return KillService