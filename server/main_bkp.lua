ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('kc_farming:harvest')
AddEventHandler('kc_farming:harvest', function(item)
  local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
  xPlayer.addInventoryItem(item, math.random(Config.HarvestCount[1], Config.HarvestCount[2]))
end)

RegisterServerEvent('kc_farming:giveItem')
AddEventHandler('kc_farming:giveItem', function(item, count)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  xPlayer.addInventoryItem(item, count)
end)

RegisterServerEvent('kc_farming:removeItem')
AddEventHandler('kc_farming:removeItem', function(item, count)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  xPlayer.removeInventoryItem(item, count)
end)

ESX.RegisterServerCallback('kc_farming:checkItem', function(source, cb, item, count)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  if xPlayer.getInventoryItem(item).count >= count then
    cb(true)
  else
    cb(false)
  end
end)

ESX.RegisterServerCallback('kc_farming:checkIdentifier', function(source, cb, identifier)
  local xPlayer = ESX.GetPlayerFromId(source)
  if xPlayer.identifier == identifier then
    cb(true)
  else
    cb(false)
  end
end)
