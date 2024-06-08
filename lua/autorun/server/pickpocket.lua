print("Pickpocket pickpocket.lua")

-- Fonction pour envoyer la progression au client
local function SendStart(ply, duration)
    net.Start("PickpocketStart")
    net.WriteFloat(duration)
    net.Send(ply)
end

-- Fonction pour stopper la progression (Success)
local function StopProgressSuccessfuly(ply,target)
    timer.Remove("PickpocketTimer")
    timer.Remove("MovementCheckTimer")


    local min = 1
    local max = 3000

    -- Récuperer l'argent de la target
    local moneyTarget = target:getDarkRPVar("money")

    -- Calculer le montant à voler
    if(moneyTarget < max) then
        max = moneyTarget
    end

    if(moneyTarget == 0) then
        max = 0
        min = 0
    end

    local moneyStolen = math.random(min, max)

    -- Retirer l'argent de la target
    target:addMoney(-moneyStolen)

    -- Ajouter l'argent au voleur
    ply:addMoney(moneyStolen)


    if(moneyStolen == 0) then
        ply:ChatPrint("Vous avez tenté de voler mais vous n'avez rien trouvé sur la personne !")
        target:ChatPrint("Quelqu'un a tenté de vous voler mais n'a rien trouvé sur vous !")
    else
        ply:ChatPrint("Vous avez volé "..tostring(moneyStolen).." pièces d'or !")
        target:ChatPrint("Quelqu'un vous a volé "..tostring(moneyStolen).." pièces d'or de votre poche !")
    end
    


    -- Stopper la progression
    net.Start("PickpocketStop")
    net.Send(ply)
end

-- Fonction pour stopper la progression (Failed)
local function StopProgressFailed(ply,target)
    timer.Remove("PickpocketTimer")
    timer.Remove("MovementCheckTimer")

    -- Joue le son préchargé à la position de la cible pour toutes les entités à proximité
    target:EmitSound("soundGoldBag.wav")

    ply:ChatPrint("Votre main a glissé et vous n'avez pas réussi a voler cette personne !")
    target:ChatPrint("Quelqu'un a tenté de vous voler mais sa main a glissé !")

    net.Start("PickpocketStop")
    net.WriteBool(false)
    net.Send(ply)
end

-- Exemple de fonction pour démarrer la progression
function StartPickpocket(ply,target)
    local progress = 0
    local totalTime = 10 -- Durée totale en secondes
    local increment = 1 / totalTime -- Valeur d'incrémentation par seconde

    SendStart(ply, totalTime)

    target.LastPosition = target:GetPos()  -- Stocke la position actuelle de la cible
    -- Timer pour vérifier si la cible bouge
    local movementCheckTimer = timer.Create("MovementCheckTimer", 1, 0, function()
        if not IsValid(target) or not target:IsPlayer() or not IsBehind(ply,target) then
            -- Annule le vol si la cible n'est plus valide ou si elle bouge

            StopProgressFailed(ply,target)
            return
        end
    end)

    timer.Create("PickpocketTimer", 1, totalTime, function()
        if not IsValid(ply) then return end
        progress = progress + increment * 100 -- Progression en pourcentage
        if progress >= 100 then
            StopProgressSuccessfuly(ply,target)
            timer.Remove("PickpocketTimer")
        end
    end)
end

-- Fonction pour vérifier si la position de la cible a changé
--[[
function IsPositionChanged(target)
    local currentPosition = target:GetPos()
    local lastPosition = target.LastPosition or currentPosition
    target.LastPosition = currentPosition  -- Met à jour la dernière position
    return currentPosition ~= lastPosition
end
]]--