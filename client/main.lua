local Duty = false
local Seeds = {}
local propCount = 0
local inSideZone = false
local onProgress = false

Citizen.CreateThread(function()
  for k, v in pairs(Config.WaterZone) do
    exports.ox_target:addBoxZone({
      coords = v.Coords,
      size = v.Size,
      rotation = v.Rot,
      options = {
        {
          name = k,
          event = 'kc_farming:getWater',
          icon = 'fa-solid fa-glass-water-droplet',
          label = _K('refuel_water'),
        }
      }
    })
  end

  for k, v in pairs(Config.FarmZone) do
    local box = lib.zones.box({
      coords = v.Coords,
      size = v.Size,
      rotation = v.Rot,
      debug = false,
      inside = inside,
      onEnter = onEnter,
      onExit = onExit
    })

    function onEnter(self)
      lib.showTextUI(_K('farm_zone'), {
        position = "right-center",
        icon = "wheat-awn",
        style = {
          borderRadius = 5,
          backgroundColor = '#3d85c6',
          color = 'white'
        }
      })
      inSideZone = true
    end
    
    function onExit(self)
      lib.hideTextUI()
      inSideZone = false
    end
    
    local blips = AddBlipForCoord(v.Coords)
    SetBlipSprite (blips, 88)
    SetBlipColour (blips, 69)
    SetBlipDisplay(blips, 4)
    SetBlipScale  (blips, 0.8)
    SetBlipAsShortRange(blips, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(_K('farm_zone'))
    EndTextCommandSetBlipName(blips)
  end

  for k, v in pairs(Config.Shops) do
    local blips = AddBlipForCoord(v.Coords)
    SetBlipSprite (blips, 628)
    SetBlipColour (blips, 69)
    SetBlipDisplay(blips, 4)
    SetBlipScale  (blips, 0.8)
    SetBlipAsShortRange(blips, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(v.Label)
    EndTextCommandSetBlipName(blips)

    local hash = GetHashKey(v.Model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
      Wait(15)
    end
    local ped = CreatePed(4, hash, v.Coords.x, v.Coords.y, v.Coords.z - 1, 3374176, false, true)
    SetEntityHeading(ped, v.Heading)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    if DoesEntityExist(ped) then
      exports.ox_target:addModel(hash, {
        {
          name = k,
          label = v.Label,
          icon = 'fa-solid fa-hand',
          onSelect = function()
            exports.ox_inventory:openInventory('shop',  { id = 1, type = k })
          end
        }
      })
    end
  end
end)

RegisterNetEvent('kc_farming:clientReconnect')
AddEventHandler('kc_farming:clientReconnect', function(data)
  for k, v in pairs(data) do
    local hash = GetHashKey(Config.Items[v.name].prop)

    RequestModel(hash)
    while not HasModelLoaded(hash) do
      Wait(1)
    end

    ServerCallback('kc_farming:planting', function(netId)
      local object = NetworkGetEntityFromNetworkId(netId)
      if DoesEntityExist(object) then
        PlaceObjectOnGroundProperly(object)
        FreezeEntityPosition(object, true)
        local netId = ObjToNet(object)
    
        Seeds[object] = {
          netIds = netId,
          coords = v.coords,
          name = v.name,
          harvest = v.harvest,
          watering = v.watering,
          fertilizer = v.fertilizer,
          time = v.time
        }
    
        exports.ox_target:addEntity(netId, {
          {
            name = 'checkPlant',
            icon = "fa-solid fa-clipboard",
            label = _K('check_plant'),
            event = 'kc_farming:checkTanaman',
            args = {
              entity = object
            },
            canInteract = function(entity, distance, coords, name, bone)
              if #(data.coords - coords) < 10 then return true end  
            end
          }
        })
        TriggerServerEvent('kc_farming:saveEntity', Seeds)
        HasPlanting(object)
      end
    end, hash, data.coords)
  end
end)

RegisterNetEvent('kc_farming:notify')
AddEventHandler('kc_farming:notify', function(_type, msg, title, time)
  if time == nil then time = 5000 end

  if Config.Notify == 'mythic_notify' then
    if _type == 'info' then _type = 'inform' end
    exports['mythic_notify']:DoHudText(_type, msg)
  elseif Config.Notify == 'okokNotify' then
    exports['okokNotify']:Alert(title, msg , time, _type)
  elseif Config.Notify == 'lib' then
    lib.notify({ title = title, description = msg, duration = time, type = _type })
  elseif Config.Notify == 'default' then
    Notify(msg, _type, time)
  end
end)

RegisterNetEvent('kc_farming:getWater')
AddEventHandler('kc_farming:getWater', function()
  ServerCallback('kc_farming:checkItem', function(hasItem)
    if hasItem then
      
      local hash = 'prop_wateringcan'
      local ped = PlayerPedId()

      RequestModel(hash)
      while not HasModelLoaded(hash) do
        Wait(1)
      end
      
      local x, y, z = table.unpack(GetEntityCoords(ped))
      local prop = CreateObject(hash, x+0.4, y+0.4, z, true, false, true)
      FreezeEntityPosition(prop, true)
      PlaceObjectOnGroundProperly(prop)
      SetPedCurrentWeaponVisible(PlayerPedId(), 0, 1, 1, 1)
      local px, py, pz = table.unpack(GetEntityCoords(prop))
      TaskTurnPedToFaceCoord(ped, vector3(px, py, pz), 20 * 1000)
      Wait(1000)
      
      local progressStatus = lib.progressBar({
        duration = 15 * 1000,
        label = _K('refuel_water'),
        useWhileDead = false,
        canCancel = false,
        disable = {
          car = true,
          move = true,
          combat = true
        },
        anim = {
          dict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@",
          clip = "weed_spraybottle_crouch_base_inspector",
          flag = 9,
        },
      })
      
      if progressStatus then
        DeleteEntity(prop)
        TriggerServerEvent('kc_farming:setDurability', 'watering_can', 100)
      end
    else
      TriggerEvent('kc_farming:notify', 'error', _K('not_have_item', "Kaleng Air"), 'ERROR', 5000)
    end
  end, 'watering_can', 1)
end)

RegisterNetEvent('kc_farming:duty')
AddEventHandler('kc_farming:duty', function()
  Duty = not Duty
end)

RegisterNetEvent('kc_farming:planting')
AddEventHandler('kc_farming:planting', function(data)
  if onProgress then return end
  if not inSideZone then return TriggerEvent('kc_farming:notify', 'error', _K('not_in_zone'), 'ERROR', 5000) end
  data.coords = data.coords + GetEntityForwardVector(PlayerPedId())
  if not canTargetingZone(data.coords, GetHashKey(Config.Items[data.seed].prop)) then return TriggerEvent('kc_farming:notify', 'error', _K('to_close'), 'ERROR', 5000) end
  Citizen.CreateThread(function()
    ServerCallback('kc_farming:checkItem', function(hasItem)
      if hasItem then
        onProgress = true
        TriggerServerEvent('kc_farming:removeItem', data.seed, 1)
        
        local progressStatus = lib.progressBar({
          duration = 5000,
          label = _K('planting'),
          useWhileDead = false,
          canCancel = false,
          disable = {
            car = true,
            move = true,
            combat = true
          },
          anim = {
            scenario = 'WORLD_HUMAN_GARDENER_PLANT'
          },
        })
        
        if progressStatus then
          Wait(2000)
          Planting(data)
        end
      else
        TriggerEvent('kc_farming:notify', 'error', _K('not_have_item', 'Sekop'), 'ERROR', 5000)
      end
    end, 'shovel', 1)
  end)
end)

RegisterNetEvent('kc_farming:checkTanaman')
AddEventHandler('kc_farming:checkTanaman', function(target)
  local propsList = {}
  for k, v in pairs(Seeds) do
    if target.args.entity == k or target.entity == k then
      local label = _K('plant', v.name:gsub('_seeds', ''))

      local desc = _K('progress_min', toPercent(v.time), convertMin(v.time))
      if v.time < 60000 then
        desc = _K('progress_sec', toPercent(v.time), convertMin(v.time))
      end 
      
      if v.harvest then
        desc = _K('can_harvest')
      end

      lib.registerContext({
        id = 'check_plant',
        title = label..' | '..target.entity,
        options = {
          {
            title = _K('harvest'),
            description = desc,
            progress = toPercent(v.time),
            colorScheme = 'teal',
            icon = 'hand',
            event = 'kc_farming:harvest',
            args = {
              entity = k,
              harvest = v.harvest,
              watering = v.watering,
              fertilizer = v.fertilizer,
              time = v.time
            }
          },
          {
            title = _K('give_fertilizer'),
            icon = 'prescription-bottle-medical',
            description = _K('fertilizer_progress', .math.floor(v.fertilizer)..'%'),
            progress = math.floor(v.fertilizer),
            event = 'kc_farming:memberikanPupuk',
            args = {
              entity = k,
              harvest = v.harvest,
              watering = v.watering,
              fertilizer = v.fertilizer,
              time = v.time
            }
          },
          {
            title = _K('watering'),
            icon = 'shower',
            description = _K('watering_progress', math.floor(v.watering)..'%'),
            progress = math.floor(v.watering),
            event = 'kc_farming:wateringProgress',
            args = {
              entity = k,
              harvest = v.harvest,
              watering = v.watering,
              fertilizer = v.fertilizer,
              time = v.time
            }
          },
        }
      })
      lib.showContext('check_plant')
    end
  end
end)

RegisterNetEvent('kc_farming:wateringProgress')
AddEventHandler('kc_farming:wateringProgress', function(data)
  ServerCallback('kc_farming:checkDurability', function(durability)
    if durability == nil then
      return TriggerEvent('kc_farming:notify', 'error', _K('not_enough_water'), 'ERROR', 5000)
    end
    if durability >= Config.WateringDurability then
      TaskTurnPedToFaceCoord(PlayerPedId(), GetEntityCoords(data.entity), 20 * 1000)
      Wait(1000)

      local progressStatus = lib.progressBar({
        duration = 4000,
        label = _K('watering'),
        useWhileDead = false,
        canCancel = false,
        disable = {
          car = true,
          move = true,
          combat = true
        },
        anim = {
          dict = "timetable@gardener@filling_can",
          clip = "gar_ig_5_filling_can"
        },
        prop = {
          model = "prop_wateringcan",
          bone = 60309,
          pos = { x = 0.13, y = -0.05, z = 0.2 },
          rot = { x = 30.0, y = 220.0, z = 185.0000 },
        }
      })

      if progressStatus then
        TriggerServerEvent('kc_farming:setDurability', 'watering_can', durability - Config.WateringDurability)
        for k, v in pairs(Seeds) do
          if data.entity == k then
            v.watering = 100
          end
        end
      end
    else
      TriggerEvent('kc_farming:notify', 'error', _K('not_enough_water'), 'ERROR', 5000)
    end
  end, 'watering_can')
end)

RegisterNetEvent('kc_farming:memberikanPupuk')
AddEventHandler('kc_farming:memberikanPupuk', function(data)
  ServerCallback('kc_farming:checkItem', function(hasItem)
    if hasItem then
      TaskTurnPedToFaceCoord(PlayerPedId(), GetEntityCoords(data.entity), 20 * 1000)
      Wait(1000)
      
      local progressStatus = lib.progressBar({
        duration = 5000,
        label = _K('give_fertilizer'),
        useWhileDead = false,
        canCancel = false,
        disable = {
          car = true,
          move = true,
          combat = true
        },
        anim = {
          dict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@",
          clip = "weed_spraybottle_crouch_base_inspector",
          flag = 9,
        },
      })

      if progressStatus then
        TriggerServerEvent('kc_farming:removeItem', 'fertilizer', 1)
        for k, v in pairs(Seeds) do
          if data.entity == k then
            v.fertilizer = 100
          end
        end
      end
    else
      TriggerEvent('kc_farming:notify', 'error', _K('not_have_item', 'Pupuk'), 'ERROR', 5000)
    end
  end, 'fertilizer', 1)
end)

RegisterNetEvent('kc_farming:harvest')
AddEventHandler('kc_farming:harvest', function(data)
  if data.harvest then
    for k, v in pairs(Seeds) do
      if data.entity == k then
        local label = _K('harvesting', v.name:gsub('_seeds', ''))
        local randomHarvest = math.random(Config.HarvestCount[1], Config.HarvestCount[2])
        ServerCallback('kc_farming:checkWeight', function(canHarvest)
          if canHarvest then
            ServerCallback('kc_farming:checkItem', function(hasItem)
              if hasItem then
                TaskTurnPedToFaceCoord(PlayerPedId(), GetEntityCoords(data.entity), 20 * 1000)
                Wait(1000)

                local progressStatus = lib.progressBar({
                  duration = 5000,
                  label = label,
                  useWhileDead = false,
                  canCancel = false,
                  disable = {
                    car = true,
                    move = true,
                    combat = true
                  },
                  anim = {
                    scenario = 'WORLD_HUMAN_GARDENER_PLANT'
                  },
                })

                if progressStatus then
                  Citizen.Wait(1000)
                  exports.ox_target:removeLocalEntity(data.entity, 'pupukin')
                  TriggerServerEvent('kc_farming:giveItem', Config.Items[v.name].get, randomHarvest)
                  table.removekey(Seeds, data.entity)
                  TriggerServerEvent('kc_farming:saveEntity', Seeds)
                  if DoesEntityExist(data.entity) then
                    ESX.Game.DeleteObject(data.entity)
                  else
                    local entity = NetToObj(v.netIds)
                    ESX.Game.DeleteObject(entity)
                  end
                end
              else
                TriggerEvent('kc_farming:notify', 'error', _K('not_have_item', 'Sekop'), 'ERROR', 5000)
              end
            end, 'shovel', 1)
          else
            TriggerEvent('kc_farming:notify', 'error', _K('inventory_full'), 'ERROR', 5000)
          end
        end, Config.Items[v.name].get, randomHarvest)
      end
    end
  else
    TriggerEvent('kc_farming:notify', 'error', _K('not_ready_harvest'), 'ERROR', 5000)
  end
end)

function Planting(data)
  Citizen.CreateThread(function()
    Citizen.Wait(1000)
    propCount = propCount + 1

    local hash = GetHashKey(Config.Items[data.seed].prop)
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do
      Wait(1)
    end

    ServerCallback('kc_farming:planting', function(netId)
      local object = NetworkGetEntityFromNetworkId(netId) 
      if DoesEntityExist(object) then
        PlaceObjectOnGroundProperly(object)
        FreezeEntityPosition(object, true)

        Seeds[object] = {
          netIds = netId,
          coords = data.coords,
          name = data.seed,
          harvest = false,
          watering = 0,
          fertilizer = 0,
          time = 3 * 60 * 1000
        }

        exports.ox_target:addEntity(netId, {
          {
            name = 'pupukin',
            icon = "fa-solid fa-clipboard",
            label = _K('check_plant'),
            event = 'kc_farming:checkTanaman',
            distance = 1.5,
            args = {
              entity = object
            },
            canInteract = function(entity, distance, coords, name, bone)
              if #(data.coords - coords) < 10 then return true end  
            end
          }
        })
        
        TriggerServerEvent('kc_farming:saveEntity', Seeds)
        HasPlanting(object)
      end
    end, hash, data.coords)
  end)
end

function canTargetingZone(coords, hash)
  local canPlanting = false
  local entity = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.3, hash, false)
  local entityCoords = GetEntityCoords(entity or PlayerPedId())
  print(#(entityCoords-coords))
  return (entity == 0 and #(entityCoords-coords) >= 1.3)
end

function DeleteAllPlant()
  if Seeds then
    TriggerServerEvent('kc_farming:deletePlant')
    Seeds = {}
  end
end

function table.removekey(table, key)
   local element = table[key]
   table[key] = nil
   return element
end

function GetCurrentWeather()
  local weather = GetWeatherTypeTransition()
  local currentWeather = ""

  if (weather == 1420204096) then
    currentWeather = 'Rain'
  elseif (weather == -1233681761) then
    currentWeather = 'ThunderStorm'
  end

  return currentWeather
end

function HasPlanting(entity)
  onProgress = false
  Citizen.CreateThread(function()
    local start = false
    local Sleep = 1000
    for k, v in pairs(Seeds) do
      if entity == k then
        start = true
        while start do 
          local weather = GetCurrentWeather()
          if weather == "Rain" or weather == "ThunderStorm" then
            v.watering = 100
          end
          
          if v.watering > 0 or v.fertilizer > 0 then
            v.watering = v.watering - 0.5
            v.fertilizer = v.fertilizer - 0.15

            if v.watering < 0 or v.fertilizer < 0 then
              v.time = v.time - 0
            elseif v.watering < 50 and v.fertilizer < 50 then
              v.time = v.time - 100
            elseif v.watering < 50 or v.fertilizer < 50 then
              v.time = v.time - 250
            elseif v.watering > 50 and v.fertilizer > 50 then
              v.time = v.time - 1000
            end
          end

          if v.watering < 0 then
            v.watering = 0
          elseif v.fertilizer < 0 then
            v.fertilizer = 0
          end

          if v.time < 0 then
            v.harvest = true
            start = false
          end
          TriggerServerEvent('kc_farming:saveEntity', Seeds)
          Citizen.Wait(Sleep)
        end
      end
    end
  end)
end

function convertMin(ms)
  local min = ms / 60000
  return math.floor(min)
end

function convertSec(ms)
  local sec = ms / 1000
  return math.floor(sec)
end

function toPercent(ms)
  local percent = (180000 - ms) / 1800
  return math.floor(percent)
end

if Config.Debug then
  RegisterCommand('farming', function()
    TriggerEvent('kc_farming:duty')
  end)

  RegisterCommand('getData', function()
    TriggerServerEvent('kc_farming:getDataServer')
  end)

  RegisterCommand('printfarming', function()
    print(json.encode(Seeds, {indent=true}))
  end)

  RegisterCommand('delplant', function()
    DeleteAllPlant()
  end)
end