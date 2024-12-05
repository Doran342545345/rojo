local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)


for _,v in pairs(ServerStorage.Source:GetDescendants()) do
    if v:IsA("ModuleScript") and v.Name:match("Service$") then
        require(v)
    end
end



Knit.Start():andThen(function()
    print("Knit Server Started")
end):catch(warn)