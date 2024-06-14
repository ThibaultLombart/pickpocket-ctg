print("Pickpocket nets.lua")

-- Nets
// Nets pour voler
util.AddNetworkString("PickpocketStart")
util.AddNetworkString("PickpocketStop")

// Nets pour celui qui se fait voler
util.AddNetworkString("PickpocketStealStart")
util.AddNetworkString("PickpocketStealStop")

-- Données locales
local pickpocketCooldown = 60*5  -- Cooldown en secondes (ici 5 minutes)
local pickpocketListing = {}  -- Table pour stocker les délais de pickpocket
local pickpocketListUsage = {} -- Table avec tout ceux qui utilisent le pickpocket en ce moment
 
-- Nets reçus
net.Receive("PickpocketStart", function(len, ply)
    local target = player.GetBySteamID64(net.ReadString())

    if(pickpocketListUsage[ply:SteamID64()] == nil) then
        pickpocketListUsage[ply:SteamID64()] = false
    end

    if(pickpocketListUsage[ply:SteamID64()] == true) then
        return
    end

    pickpocketListUsage[ply:SteamID64()] = true

    if not IsValid(target) or not target:IsPlayer() then
        pickpocketListUsage[ply:SteamID64()] = false
        return
    end

    -- On vérifie si le joueur est derrière la cible
    if not IsBehind(ply, target) then
        ply:ChatPrint("Vous devez être collé derrière la personne pour la voler.")
        pickpocketListUsage[ply:SteamID64()] = false
        return
    end

    -- On vérifie si le pickpocket est en cooldown
    if IsPickpocketOnCooldown(ply, target) then
        ply:ChatPrint("Vous devez attendre ".. tostring( math.ceil(pickpocketListing[ply:SteamID64()][target:SteamID64()] - CurTime()) ) .." secondes avant de voler à nouveau cette personne.")
        pickpocketListUsage[ply:SteamID64()] = false
        return
    end

    pickpocketListUsage[ply:SteamID64()] = false

    -- On démarre le pickpocket
    AddPickpocket(ply:SteamID64(), target:SteamID64(), CurTime() + pickpocketCooldown)
    StartPickpocket(ply, target)
end)

-- Fonctions

-- Fonction pour ajouter un vol
function AddPickpocket(steamIDRobber, steamIDRobbed, duration)
    if not pickpocketListing[steamIDRobber] then
        pickpocketListing[steamIDRobber] = {}
    end
    pickpocketListing[steamIDRobber][steamIDRobbed] = duration
end

// Fonction pour vérifier si la personne est dans le dos de sa cible et collée à elle
function IsBehind(ply, target)
    local plyPos = ply:GetPos()
    local targetPos = target:GetPos()

    local plyForward = ply:EyeAngles():Forward()
    local targetForward = target:EyeAngles():Forward()

    local dotProduct = plyForward:Dot(targetForward)

    return dotProduct > 0.8 and plyPos:Distance(targetPos) < 125
end

// Fonction pour vérifier si le pickpocket est en cooldown
function IsPickpocketOnCooldown(ply, target)
    local plySteamID = ply:SteamID64()
    local targetSteamID = target:SteamID64()

    if not pickpocketListing[plySteamID] or not pickpocketListing[plySteamID][targetSteamID] then
        return false
    end

    return pickpocketListing[plySteamID][targetSteamID] > CurTime()
end
