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




function KillService.Client:GetKills(plr:Player)
    return self.Server:GetKills(plr)
end




function KillService:GetKills(player:Player): number
    local Kills = self._KillsPerPlayer[player] or self._StartingKills
    return Kills
end

function KillService:AddKills(plr:Player, amt: number)
    local currentKills = self:GetKills(plr)
    if amt > 0 then
            
        local newKills = currentKills + amt
        self._KillsPerPlayer[plr] = newKills
        self.Client.killsChanged:Fire(plr,newKills)
    end
end

function KillService:KnitStart()
    print("KillService Started")

    

end

function KillService:KnitInit()

    Players.PlayerAdded:Connect(function(player)
        local dataStoreKills = killsInit.Test()

        killsInit.playerAdded(player)

        self._KillsPerPlayer[player] = dataStoreKills
        print(self._KillsPerPlayer[player])
    end)

    Players.PlayerRemoving:Connect(function(player)

        local dataStoreKills = killsInit.Save(player)


        self._KillsPerPlayer[player] = nil
    end)
end


return KillService