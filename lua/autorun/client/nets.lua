-- Réception des données du serveur pour la progression du pickpocket
net.Receive("PickpocketStart", function()
    LocalPlayer().PickpocketProgress = 0

    local start = CurTime()
    local duration = net.ReadFloat()

        -- Crée un timer pour mettre à jour la progression
        timer.Create("PickpocketTimer", 0.05, 0, function()
            local progress = (CurTime() - start) / duration * 100
            LocalPlayer().PickpocketProgress = progress

            if LocalPlayer().PickpocketProgress >= 100 then
                LocalPlayer().PickpocketProgress = 100
                timer.Remove("PickpocketTimer")
            end
        end)
end)

-- Réinitialise la progression à 0
net.Receive("PickpocketStop", function()
    -- Réinitialise la progression à 0
    LocalPlayer().PickpocketProgress = -1
    -- Arrête le timer s'il est toujours en cours
    timer.Remove("PickpocketTimer")
end)

-- Initialisation de la progression
hook.Add("Initialize", "InitPickpocketProgress", function()
    LocalPlayer().PickpocketProgress = -1
end)

-- Dessine la barre de progression
hook.Add("HUDPaint", "DrawPickpocketProgress", function()
    local progress = LocalPlayer().PickpocketProgress or -1
    local screenWidth, screenHeight = ScrW(), ScrH()
    local width, height = screenWidth * 0.2, screenHeight * 0.025  -- Utilise 20% de la largeur et 2.5% de la hauteur de l'écran
    local x, y = (screenWidth - width) / 2, screenHeight * 0.8  -- Centre la barre horizontalement et place à 80% de la hauteur de l'écran

    -- Dessine la barre si la progression est valide (supérieure ou égale à 0)
    if progress >= 0 then
        draw.RoundedBox(8, x, y, width, height, Color(0, 0, 0, 150))
        draw.RoundedBox(8, x + 2, y + 2, (width - 4) * (progress / 100), height - 4, Color(182, 0, 0))
    end
end)