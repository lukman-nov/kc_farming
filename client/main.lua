local ESX = nil
local Duty = false
local IsDead = false
local Seeds = {}
local propCount = 0

Citizen.CreateThread(function()
	while ESX == nil do
		ESX = exports["es_extended"]:getSharedObject()
		Citizen.Wait(10)
	end 
  ESX.PlayerData = ESX.GetPlayerData()
end)

Citizen.CreateThread(function()
  for k, v in pairs(Config.TargetZones) do
    exports.ox_target:addBoxZone({
      coords = v.Coords,
      size = v.Size,
      rotation = v.Rot,
      options = {
        {
          name = k,
          event = 'kc_farming:getWater',
          icon = 'fa-solid fa-glass-water-droplet',
          label = 'Mengisi Air',
        }
      }
    })
  end
  
  exports.ox_target:addBoxZone({
    coords = vec3(2541.0620, 4810.0405, 33.6945),
    size = vec3(45, 70, 20),
    rotation = 225,
    options = {
      {
        name = 'plantProps',
        event = 'kc_farming:showSeedsMenu',
        icon = 'fa-brands fa-pagelines',
        label = 'Mulai Menanam',
        canInteract = function(entity, distance, coords, name, bone)
          return canTargetingZone(coords)
        end
      }
    }
  })
end)

function canTargetingZone(coords)
  local canPlant = false
  local object, dist = ESX.Game.GetClosestObject(coords)
  if Duty and dist > 2.0 then
    canPlant = true
  end
  return canPlant
end

Citizen.CreateThread(function()
  local blip = AddBlipForCoord(vector3(2541.0620, 4810.0405, 33.6945))
  SetBlipSprite (blip, Config.Blips.Sprite)
  SetBlipColour (blip, Config.Blips.Color)
  SetBlipDisplay(blip, Config.Blips.Display)
  SetBlipScale  (blip, Config.Blips.Scale)
  SetBlipAsShortRange(blip, true)
  BeginTextCommandSetBlipName('STRING')
  AddTextComponentSubstringPlayerName('Pertanian')
  EndTextCommandSetBlipName(blip)
end)

AddEventHandler('esx:onPlayerDeath', function(data)
  IsDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
  IsDead = false
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded',function(xPlayer)
  ESX.PlayerData = xPlayer
  Wait(3000)
  TriggerServerEvent('kc_farming:getDataServer')
end)

RegisterNetEvent('kc_farming:getDataClient')
RegisterNetEvent('kc_farming:getDataClient', function(data)
  if data[1] ~= nil then
    Duty = true
    Seeds = data
    for k, v in pairs(Seeds) do
      SpawnProps(v[1].entity, v[1].name)
    end
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
  elseif Config.Notify == 'ESX' then
    ESX.ShowNotification(msg, _type)
  end
end)

RegisterNetEvent('kc_farming:duty')
AddEventHandler('kc_farming:duty', function()
  if not Duty then
    Duty = true
    TriggerEvent('kc_farming:notify', 'success', 'Kamu sudah mengambil pekerjaan bertani', 'SUCCESS', 10000)
  else
    TriggerEvent('kc_lumberjack:notify', 'info', 'Kamu sudah mengambil pekerjaan ini', 'INFO', 6000)
  end
end)

RegisterNetEvent('kc_farming:getWater')
AddEventHandler('kc_farming:getWater', function()
  ESX.TriggerServerCallback('kc_farming:checkItem', function(hasItem)
    if hasItem then
      TriggerServerEvent('kc_farming:removeItem', 'watering_can', 1)
      exports['mythic_progbar']:Progress({
        duration = 3500,
        label = 'Mengisi Air',
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true,
        },
        animation = {
          animDict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@",
          anim = "weed_spraybottle_crouch_base_inspector",
          flags = 9,
        }
      }, function(status)
        if not status then
          TriggerServerEvent('kc_farming:giveItem', 'watering_can_full', 1)
        end
      end)
    else
      TriggerEvent('kc_farming:notify', 'error', 'Kamu tidak mempunyai KALENG AIR', 'ERROR', 5000)
    end
  end, 'watering_can', 1)
end)

RegisterNetEvent('kc_farming:showSeedsMenu')
AddEventHandler('kc_farming:showSeedsMenu', function(target)
  local seedList = {}

  ESX.TriggerServerCallback('kc_farming:getItems', function(data)
    if data and data[1] ~= nil then
      for k, v in pairs(data) do
        local disable = true
        if v.count >= 1 then
          seedList[v.label] = {
            description = 'Kamu mempunyai '..v.count,
            event = 'kc_farming:planting',
            args = {
              coords = target.coords,
              seed = v.name,
            }
          }

          lib.registerContext({
            id = 'Get_Jobs',
            title = 'Elite Farming',
            options = seedList
          })
          lib.showContext('Get_Jobs')
        end
      end
    else
      TriggerEvent('kc_farming:notify', 'error', 'Kamu tidak mempunyai Bibit Tanaman', 'ERROR', 5000)
    end
  end)
end)

RegisterNetEvent('kc_farming:planting')
AddEventHandler('kc_farming:planting', function(data)
  local playerCoords = GetEntityCoords(PlayerPedId())
  local x = playerCoords.x + 0.5
  local y = playerCoords.x + 0.5
  local z = playerCoords.x
  ESX.TriggerServerCallback('kc_farming:checkItem', function(hasItem)
    if hasItem then
      TriggerServerEvent('kc_farming:removeItem', data.seed, 1)
      exports['mythic_progbar']:Progress({
        duration = 7000,
        label = 'Menanam',
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true,
        },
        animation = {
          task = 'WORLD_HUMAN_GARDENER_PLANT'
        }
      }, function(status)
        if not status then
          Citizen.Wait(Config.GrowingPlanting)
          propCount = propCount + 1

          ESX.Game.SpawnObject(Config.Items[data.seed].prop, data.coords, function(object)
            PlaceObjectOnGroundProperly(object)
            FreezeEntityPosition(object, true)
            Seeds[tostring(propCount)] = {
              {
                entity = object,
                coords = data.coords,
                name = data.seed,
                harvest = false,
                watering = 0,
                fertilizer = 0,
                time = 3 * 60 * 1000
              }
            }
            exports.ox_target:addLocalEntity(object, {
              {
                name = 'pupukin',
                icon = "fa-solid fa-clipboard",
                label = 'Memeriksa Tanaman',
                event = 'kc_farming:checkTanaman',
                args = object
              }
            })

            TriggerServerEvent('kc_farming:saveEntity', Seeds)
            HasPlanting(object)
          end)
        end
      end)
    else
      TriggerEvent('kc_farming:notify', 'error', 'Kamu tidak mempunyai SEKOP', 'ERROR', 5000)
    end
  end, 'sekop', 1)
end)

RegisterNetEvent('kc_farming:checkTanaman')
AddEventHandler('kc_farming:checkTanaman', function(target)
  local propsList = {}
  for k, v in pairs(Seeds) do
    if target.entity == v[1].entity then
      local label = 'Tanaman '..v[1].name:gsub('bibit_', '')

      local desc = 'Progress Panen '..toPercent(v[1].time)..'% | '..convertMin(v[1].time)..' menit'
      if v[1].time < 60000 then
        desc = 'Progress Panen '..toPercent(v[1].time)..'% | '..convertSec(v[1].time)..' detik'
      end 

      if v[1].harvest then
        desc = 'Siap dipanen'
      end

      lib.registerContext({
        id = 'check_plant',
        title = label..' | '..v[1].entity,
        options = {
          {
            title = 'Panen',
            description = desc,
            icon = 'hand',
            event = 'kc_farming:harvest',
            args = {
              entity = v[1].entity,
              harvest = v[1].harvest,
              watering = v[1].watering,
              fertilizer = v[1].fertilizer,
              time = v[1].time
            }
          },
          {
            title = 'Memberikan Pupuk',
            icon = 'prescription-bottle-medical',
            description = 'Pemberian Pupuk '..math.floor(v[1].fertilizer)..'%',
            event = 'kc_farming:memberikanPupuk',
            args = {
              entity = v[1].entity,
              harvest = v[1].harvest,
              watering = v[1].watering,
              fertilizer = v[1].fertilizer,
              time = v[1].time
            }
          },
          {
            title = 'Menyiram',
            icon = 'shower',
            description = 'Penyiraman '..math.floor(v[1].watering)..'%',
            event = 'kc_farming:wateringProgress',
            args = {
              entity = v[1].entity,
              harvest = v[1].harvest,
              watering = v[1].watering,
              fertilizer = v[1].fertilizer,
              time = v[1].time
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
  ESX.TriggerServerCallback('kc_farming:checkItem', function(hasItem)
    if hasItem then
      exports['mythic_progbar']:Progress({
        duration = 5000,
        label = 'Menyiram Tanaman',
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true,
        },
        animation = {
          animDict = "timetable@gardener@filling_can",
          anim = "gar_ig_5_filling_can",
        },
        prop = {
          model = 'prop_wateringcan',
          bone = 60309,
          coords = { x = 0.13, y = -0.05, z = 0.2 },
          rotation = { x = 30.0, y = 220.0, z = 185.0000 },
        },
      }, function(status)
        if not status then
          TriggerServerEvent('kc_farming:removeItem', 'watering_can_full', 1)
          for k, v in pairs(Seeds) do
            if data.entity == v[1].entity then
              v[1].watering = 100
            end
          end
        end
      end)
    else
      TriggerEvent('kc_farming:notify', 'error', 'Kamu tidak mempunyai KALENG AIR TERISI', 'ERROR', 5000)
    end
  end, 'watering_can_full', 1)
end)

RegisterNetEvent('kc_farming:memberikanPupuk')
AddEventHandler('kc_farming:memberikanPupuk', function(data)
  ESX.TriggerServerCallback('kc_farming:checkItem', function(hasItem)
    if hasItem then
      exports['mythic_progbar']:Progress({
        duration = 5000,
        label = 'Memberikan Pupuk',
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true,
        },
        animation = {
          animDict = "timetable@gardener@filling_can",
          anim = "gar_ig_5_filling_can",
        }
      }, function(status)
        if not status then
          TriggerServerEvent('kc_farming:removeItem', 'pupuk', 1)
          for k, v in pairs(Seeds) do
            if data.entity == v[1].entity then
              v[1].fertilizer = 100
            end
          end
        end
      end)
    else
      TriggerEvent('kc_farming:notify', 'error', 'Kamu tidak mempunyai PUPUK', 'ERROR', 5000)
    end
  end, 'pupuk', 1)
end)

RegisterNetEvent('kc_farming:harvest')
AddEventHandler('kc_farming:harvest', function(data)
  if data.harvest then
    for k, v in pairs(Seeds) do
      if v[1].entity == data.entity then
        local label = 'Memanen '..v[1].name:gsub('bibit_', '')
        ESX.TriggerServerCallback('kc_farming:checkItem', function(hasItem)
          if hasItem then
            exports['mythic_progbar']:Progress({
              duration = 7000,
              label = label,
              useWhileDead = false,
              canCancel = false,
              controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
              },
              animation = {
                task = 'WORLD_HUMAN_GARDENER_PLANT'
              }
            }, function(status)
              if not status then
                Citizen.Wait(1000)
                exports.ox_target:removeLocalEntity(data.entity, 'pupukin')
                TriggerServerEvent('kc_farming:giveItem', Config.Items[v[1].name].get, math.random(Config.HarvestCount[1], Config.HarvestCount[2]))
                ESX.Game.DeleteObject(data.entity)
              end
            end)
          else
            TriggerEvent('kc_farming:notify', 'error', 'Kamu tidak mempunyai Skop')
          end
        end, 'sekop', 1)
      end
    end
  else
    TriggerEvent('kc_farming:notify', 'error', 'Tanaman ini belum bisa dipanen', 'ERROR', 5000)
  end
end)

function HasPlanting(entity)
  Citizen.CreateThread(function()
    local start = false
    local Sleep = 1000
    for k, v in pairs(Seeds) do
      if v[1].entity == entity then
        start = true
        while start do 
          if v[1].watering > 0 or v[1].fertilizer > 0 then
            v[1].watering = v[1].watering - 0.5
            v[1].fertilizer = v[1].fertilizer - 0.2

            if v[1].watering < 0 or v[1].fertilizer < 0 then
              v[1].time = v[1].time - 0
            elseif v[1].watering < 50 or v[1].fertilizer < 50 then
              v[1].time = v[1].time - 250
            elseif v[1].watering < 50 and v[1].fertilizer < 50 then
              v[1].time = v[1].time - 100
            elseif v[1].watering > 50 and v[1].fertilizer > 50 then
              v[1].time = v[1].time - 1000
            end
          end

          if v[1].watering < 0 then
            v[1].watering = 0
          elseif v[1].fertilizer < 0 then
            v[1].fertilizer = 0
          end

          if v[1].time < 0 then
            v[1].harvest = true
            start = false
          end
          Citizen.Wait(Sleep)
        end
      end
    end
  end)
end

function SpawnProps(entity, name)
  if DoesEntityExist(entity) then
    ESX.Game.SpawnObject(Config.Items[name].prop, data.coords, function(object)
      PlaceObjectOnGroundProperly(object)
      FreezeEntityPosition(object, true)
      exports.ox_target:addLocalEntity(object, {
        {
          name = 'pupukin',
          icon = "fa-solid fa-clipboard",
          label = 'Memeriksa Tanaman',
          event = 'kc_farming:checkTanaman'
        }
      })
    end)
  end
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

RegisterCommand('farming', function()
  TriggerEvent('kc_farming:getJob')
  -- TriggerServerEvent('kc_farming:getDataServer')
end)

-- RegisterCommand('debugfarming', function()
--   -- for k, v in pairs(Seeds) do
--   --   print(json.encode(v[1]))
--   -- end
  
--       exports['mythic_progbar']:Progress({
--         duration = 5000,
--         label = 'Menyiram Tanaman',
--         useWhileDead = false,
--         canCancel = false,
--         controlDisables = {
--           disableMovement = true,
--           disableCarMovement = true,
--           disableMouse = false,
--           disableCombat = true,
--         },
--         animation = {
--           animDict = "timetable@gardener@filling_can",
--           anim = "gar_ig_5_filling_can",
--         },
--         prop = {
--           model = 'prop_wateringcan',
--           bone = 60309,
--           coords = { x = 0.13, y = -0.05, z = 0.2 },
--           rotation = { x = 30.0, y = 220.0, z = 185.0000 },
--         },
--       }, function(status)
--         -- if not status then
--         --   TriggerServerEvent('kc_farming:removeItem', 'watering_can_full', 1)
--         --   for k, v in pairs(Seeds) do
--         --     if data.entity == v[1].entity then
--         --       v[1].watering = 100
--         --     end
--         --   end
--         -- end
--       end)
-- end)

-- RegisterCommand('delplant', function()
--   if Seeds ~= nil then
--     for k, v in pairs(Seeds) do
--       ESX.Game.DeleteObject(v[1].entity)
--     end
--   else
--     local playerCoords = GetEntityCoords(PlayerPedId())
--     local prop = ESX.Game.GetClosestObject(playerCoords)
--     ESX.Game.DeleteObject(prop)
--   end
-- end)