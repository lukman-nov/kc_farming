ESX = exports['es_extended']:getSharedObject()
local playerPlant

ESX.RegisterServerCallback('kc_farming:checkSeeds', function(source, cb, item, count)
  local xPlayer = ESX.GetPlayerFromId(source)
  
  if xPlayer.getInventoryItem(item).count >= count then
    cb(true)
  else
    cb(false)
  end
end)

ESX.RegisterServerCallback('kc_farming:checkItem', function(source, cb, item, count)
  local xPlayer = ESX.GetPlayerFromId(source)
  
  if xPlayer.getInventoryItem(item).count >= count then
    cb(true)
  else
    cb(false)
  end
end)

ESX.RegisterServerCallback('kc_farming:getItems', function(source, cb)
  local xPlayer = ESX.GetPlayerFromId(source)
  local playerItems = {}
  for k, v in pairs(Config.Items) do
    local items = xPlayer.getInventoryItem(k)
    if items.count > 0 then
      table.insert(playerItems, {
        name = items.name,
        label = items.label,
        count = items.count
      })
    end
  end
  cb(playerItems)
end)

RegisterServerEvent('kc_farming:removeItem')
AddEventHandler('kc_farming:removeItem', function(item, count)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  xPlayer.removeInventoryItem(item, count)
end)

RegisterServerEvent('kc_farming:giveItem')
AddEventHandler('kc_farming:giveItem', function(item, count)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  xPlayer.addInventoryItem(item, count)
end)

RegisterServerEvent('kc_farming:saveEntity')
AddEventHandler('kc_farming:saveEntity', function(data)
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)
  playerPlant = {}
  playerPlant[xPlayer.identifier] = data
end)

RegisterServerEvent('kc_farming:getDataServer')
AddEventHandler('kc_farming:getDataServer', function()
  local src = source
  local xPlayer = ESX.GetPlayerFromId(src)

  if playerPlant then
    if playerPlant[xPlayer.identifier] then
      TriggerClientEvent('kc_farming:getDataClient', src, playerPlant[xPlayer.identifier])
    end
  end
end)