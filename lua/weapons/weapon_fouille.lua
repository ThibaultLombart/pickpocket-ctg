if SERVER then
    AddCSLuaFile()
end

-- Nommez le SWEP
SWEP.PrintName = "Pickpocket"
SWEP.Author = "Thybax"
SWEP.Instructions = "Cliquez sur un joueur dans son dos pour fouiller ses poches."
SWEP.Category = "CTG - Pickpocket"

-- Définition des caractéristiques du SWEP
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = ""

-- Description du SWEP
SWEP.Description = "Cliquez sur un joueur dans son dos pour fouiller ses poches."

SWEP.Slot = 4
SWEP.SlotPos = 5

-- Configuration du SWEP
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.PickpocketCooldowns = {}  -- Table pour stocker les délais de pickpocket

-- Fonction pour le clic de la souris
function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1)

    local trace = self.Owner:GetEyeTrace()

    if IsValid(trace.Entity) and trace.Entity:IsPlayer() then
        local target = trace.Entity
        self:Pickpocket(target)
    end
end

-- Fonction pour le clic droit de la souris
function SWEP:SecondaryAttack()
    self:PrimaryAttack()
end

-- Fonction pour fouiller les poches de la cible
function SWEP:Pickpocket(target)
    if CLIENT then
        net.Start("PickpocketStart")
        net.WriteString(target:SteamID64())
        net.SendToServer()
    end
end