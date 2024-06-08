-- Multiversion file for pickpocket addon
print("Pickpocket multiversion.lua")

local playerMeta = FindMetaTable("Player")

function playerMeta:MultiversionAddMoney(amount)
	if self.AddMoney then
		return self:AddMoney(amount)
	else
		return self:addMoney(amount)
	end
end

function playerMeta:MultiversionNotify(type, text)
    print("Type de notification: ", type)
	if DarkRP && DarkRP.notify then
		DarkRP.notify(self, type, 4, text)
	else
		GAMEMODE:Notify(self, type, 4, text)
	end
end