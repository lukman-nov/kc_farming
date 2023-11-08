if GetResourceState('ox_inventory') ~= 'started' then return end
local inventory = exports.ox_inventory
local playerPlant = {}

CreateThread(function()
  for k, v in pairs(Config.Shops) do
    inventory:RegisterShop(k, {
      name = v.Label,
      inventory = v.Items,
      locations = {
        v.Coords
      },
    })
  end
end)

RegisterCallback('kc_farming:planting', function(source, cb, hash, coords)
  local x, y, z = table.unpack(coords)
  local object = CreateObject(hash, x, y, z, true, true, true)
  Wait(100)
  local netId = NetworkGetNetworkIdFromEntity(object)
  cb(netId)
end)

RegisterCallback('kc_farming:checkItem', function(source, cb, item, count)
  local player = GetPlayer(source)
  local item = inventory:GetItem(source, item)
  if item.count >= count then
    cb(true)
  else
    cb(false)
  end
end)

RegisterCallback('kc_farming:checkWeight', function(source, cb, item, count)
  if inventory:CanCarryItem(source, item, count) then
    cb(true)
  else
    cb(false)  
  end
end)

RegisterCallback('kc_farming:getItems', function(source, cb)
  local player = GetPlayer(source)
  local playerItems = {}
  for k, v in pairs(Config.Items) do
    local items = inventory:GetItem(source, k)
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

RegisterCallback('kc_farming:checkDurability', function(source, cb, itemName)
  local itemSlot = inventory:GetSlotsWithItem(source, itemName)
  if itemSlot[1].metadata then
    if itemSlot.metadata.durability then
      cb(itemSlot.metadata.durability)
    else
      cb(nil)
    end
  else
    cb(nil)
  end
end)

RegisterServerEvent('kc_farming:setDurability')
AddEventHandler('kc_farming:setDurability', function(itemName, durability)
  local item = inventory:GetSlotsWithItem(source, itemName)
  local metadata = {}
  metadata.durability = durability
  
  inventory:SetMetadata(source, item[1].slot, metadata)
end)

RegisterServerEvent('kc_farming:removeItem')
AddEventHandler('kc_farming:removeItem', function(item, count)
  inventory:RemoveItem(source, item, amount)
end)

RegisterServerEvent('kc_farming:giveItem')
AddEventHandler('kc_farming:giveItem', function(item, count)
  inventory:AddItem(source, item, amount)
end)

RegisterServerEvent('kc_farming:saveEntity')
AddEventHandler('kc_farming:saveEntity', function(data)
  local src = source
  local player = GetPlayer(src)
  playerPlant[player.identifier] = data
end)

RegisterServerEvent('kc_farming:getDataServer')
AddEventHandler('kc_farming:getDataServer', function()
  local src = source
  local player = GetPlayer(src)

  if playerPlant then
    if playerPlant[player.identifier] then
      TriggerClientEvent('kc_farming:clientReconnect', src, playerPlant[player.identifier])
    end
  end
end)

RegisterServerEvent('kc_farming:deletePlant')
AddEventHandler('kc_farming:deletePlant', function()
  local player = GetPlayer(source)
  if playerPlant then
    if playerPlant[player.identifier] then
      for k, v in pairs(playerPlant[player.identifier]) do
        local entity = NetworkGetEntityFromNetworkId(v.netIds)
        DeleteEntity(entity)
      end
    end
  end
end)

exports('plant', function(event, item, inventory, slot, data)
  if event == 'usingItem' then
    local ped = GetPlayerPed(inventory.id)
    local playerCoords = GetEntityCoords(ped)
    TriggerClientEvent('kc_farming:planting', inventory.id, {
      coords = vector3(playerCoords.x, playerCoords.y, playerCoords.z -0.2),
      seed = item.name,
    })
  end
end)

RegisterServerEvent('kc_farming:printToSvConsole')
AddEventHandler('kc_farming:printToSvConsole', function(msg)
  print(msg)
end)
