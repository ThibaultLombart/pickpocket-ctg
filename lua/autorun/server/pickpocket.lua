print("Pickpocket pickpocket.lua")

-- Fonction pour envoyer la progression au client
local function SendProgress(ply, progress)
    net.Start("PickpocketStart")
    net.WriteFloat(progress)
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
    target:MultiversionAddMoney(-moneyStolen)

    -- Ajouter l'argent au voleur
    ply:MultiversionAddMoney(moneyStolen)


    if(moneyStolen == 0) then
        ply:MultiversionNotify(1, "Vous avez tenté de voler cette personne mais elle n'avait rien sur elle !") // 1 = erreur
        target:MultiversionNotify(1, "Quelqu'un a tenté de vous voler mais vous n'aviez rien sur vous !") // 1 = erreur
    else
        ply:MultiversionNotify(0, "Vous avez volé "..tostring(moneyStolen).." pièces d'or !") // 0 = succès
        target:MultiversionNotify(1, "Quelqu'un vous a volé "..moneyStolen.." pièces d'or de votre poche !") // 1 = erreur
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

    ply:MultiversionNotify(1, "Votre main a glissé et vous n'avez pas réussi a voler cette personne !") // 1 = erreur
    target:MultiversionNotify(1, "Quelqu'un a tenté de vous voler mais sa main a glissé !") // 1 = erreur



    net.Start("PickpocketStop")
    net.WriteBool(false)
    net.Send(ply)
end

-- Exemple de fonction pour démarrer la progression
function StartPickpocket(ply,target)
    local progress = 0
    local totalTime = 10 -- Durée totale en secondes
    local increment = 1 / totalTime -- Valeur d'incrémentation par seconde

    SendProgress(ply, progress)

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
        SendProgress(ply, progress)
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