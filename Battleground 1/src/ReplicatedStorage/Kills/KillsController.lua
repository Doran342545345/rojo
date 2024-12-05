local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage.Packages.Knit)


local KillController = Knit.CreateController {
    Name = "KillController",
}


function KillController:KnitStart()

    local function observeKills(Kills)
        print("Kills: ",Kills)
    end


    local killService = Knit.GetService("KillService")
    killService:GetKills()

    killService:GetKills():andThen(observeKills):await()
    killService.killsChanged:Connect(observeKills)

    print("KillController Started")
end

function KillController:KnitInit()
    print("KillController Initialized")
end



return KillController