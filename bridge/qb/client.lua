if GetResourceState('qb-core') ~= 'started' then return end
QBCore = exports['qb-core']:GetCoreObject()
Framework, PlayerLoaded, PlayerData = 'qb', nil, {}

AddStateBagChangeHandler('isLoggedIn', '', function(_bagName, _key, value, _reserved, _replicated)
  if value then
    PlayerData = QBCore.Functions.GetPlayerData()
  else
    table.wipe(PlayerData)
    DeleteAllPlant()
  end
  PlayerLoaded = value
end)

AddEventHandler('onResourceStart', function(resourceName)
  if GetCurrentResourceName() ~= resourceName or not LocalPlayer.state.isLoggedIn then return end
  PlayerData = QBCore.Functions.GetPlayerData()
  PlayerLoaded = true
  TriggerServerEvent('kc_farming:getDataServer')
end)


RegisterNetEvent('QBCore:Client:OnMoneyChange', function()
	PlayerData = QBCore.Functions.GetPlayerData()
end)

RegisterNetEvent('QBCore:Player:SetPlayerData', function(newPlayerData)
  if source ~= '' and GetInvokingResource() ~= 'qb-core' then return end
  PlayerData = newPlayerData
end)

function ServerCallback(name, cb, ...)
  QBCore.Functions.TriggerCallback(name, cb,  ...)
end

function Notify(msg, _type, time)
  QBCore.Functions.Notify(msg, _type, time)
end