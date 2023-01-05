local ESX= nil

CreateThread(function()
  if GetResourceState('es_extended') ~= 'missing' and GetResourceState('es_extended') ~= 'unknown' then
    while GetResourceState('es_extended') ~= 'started' do Wait(0) end
    ESX = exports['es_extended']:getSharedObject()
  end
end)

RegisterNetEvent('kc_farming:harvest')
AddEventHandler('kc_farming:harvest', function(item)
  local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
  xPlayer.addInventoryItem(item, math.random(Config.HarvestCount))
end)
