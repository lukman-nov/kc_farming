if GetResourceState('es_extended') ~= 'started' then return end
ESX = exports['es_extended']:getSharedObject()
Framework, PlayerLoaded, PlayerData = 'esx', false, {}

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
  PlayerLoaded = true
  
  TriggerEvent('kc_farming:getDataServer')
end)

RegisterNetEvent('esx:onPlayerLogout', function()
  table.wipe(PlayerData)
  PlayerLoaded = false
  DeleteAllPlant()
end)

RegisterNetEvent('esx:setJob', function(job)
  PlayerData.job = job
end)

AddEventHandler('onResourceStart', function(resourceName)
  if GetCurrentResourceName() ~= resourceName or not ESX.PlayerLoaded then return end
  PlayerData = ESX.GetPlayerData()
  PlayerLoaded = true
end)

function GetPlayer(source)
  return ESX.GetPlayerFromId(source)
end

function RegisterCallback(name, cb, ...)
  ESX.RegisterServerCallback(name, cb,  ...)
end