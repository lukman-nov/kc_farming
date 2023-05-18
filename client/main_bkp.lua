local ESX, jobs = nil, nil
local PlayerData = {}
local duty = false
local spawnedFarms = 0
local prop = {}
local object = {}
local canHarvest = false

CreateThread(function()
	while ESX == nil do
		ESX = exports["es_extended"]:getSharedObject()
		Wait(10)
	end 
  PlayerData = ESX.GetPlayerData()
end)

function spawnProps(curentJob)
  CreateThread(function()
    while true do 
      local playerCoords = GetEntityCoords(GetPlayerPed(-1))
      local dist = #(playerCoords - Config.PropZones[curentJob])
      if duty and dist < 50 then
        for i = 1, 10 do
          local radius = 15
          local x = Config.PropZones[curentJob].x + math.random(-radius, radius)
          local y = Config.PropZones[curentJob].y + math.random(-radius, radius)
          local z = Config.PropZones[curentJob].z
          if (prop[i] == nil or prop[i].obj == nil) and spawnedFarms < 10 then
            ESX.TriggerServerCallback('kc_farming:checkIdentifier', function(canSpawn)
              if canSpawn then
                prop[i] = {
                  obj = CreateObject(GetHashKey(Config.Prop[curentJob]), vector3(x, y, z), true, false),
                  watering = false
                }
                PlaceObjectOnGroundProperly(prop[i].obj)
                FreezeEntityPosition(prop[i].obj, true)
                spawnedFarms = spawnedFarms + 1
                if DoesEntityExist(prop[i].obj) then
                  object[curentJob] = NetworkGetNetworkIdFromEntity(prop[i].obj)
                  exports.ox_target:addEntity(object[curentJob], {
                    {
                      name = 'watering',
                      icon = "fa-solid fa-shower",
                      label = 'Menyiram Tanaman',
                      event = 'kc_farming:wateringProgress',
                      args = {
                        job = curentJob,
                        prop = prop[i],
                        waitTime = Config.TimeToHarvest
                      },
                      canInteract = function(entity, distance, coords, name, bone)
                        if #(coords - GetEntityCoords(prop[i].obj)) < 5 then return true end
                      end,
                      distance = 2.0
                    }
                  })
                end
              end
            end, PlayerData.identifier)
          end
        end
      end
      Wait(12000)
    end
  end)
end

function Harvest(obj, curentJob, waitTime)
  CreateThread(function()
    while not obj.watering do 
      Wait(waitTime)
      if DoesEntityExist(obj.obj) then
        obj.watering = true
        local netId = NetworkGetNetworkIdFromEntity(obj.obj)
        exports.ox_target:addEntity(netId, {
          {
            name = 'harvest',
            icon = "fa-solid fa-hand",
            label = _U('harvest', curentJob),
            event = 'kc_farming:farmingProgress',
            args = {
              job = curentJob,
              obj = obj
            },
            canInteract = function(entity, distance, coords, name, bone)
              if #(coords - GetEntityCoords(obj.obj)) < 5 and obj.watering then return true end
            end,
            distance = 2.0
          }
        })
        local entityCoords = GetEntityCoords(obj.obj)
        Display(entityCoords, true, obj.obj)
      end
    end
  end)
end

function spawnNPC(x, y, z, heading, hash, model)
  RequestModel(GetHashKey(model))
  while not HasModelLoaded(GetHashKey(model)) do
    Wait(15)
  end
  ped = CreatePed(4, hash, x, y, z - 1, 3374176, false, true)
  SetEntityHeading(ped, heading)
  FreezeEntityPosition(ped, true)
  SetEntityInvincible(ped, true)
  SetBlockingOfNonTemporaryEvents(ped, true)
end

function Display(crds, displaying, obj)
  Citizen.CreateThread(function()
    for i = 1, 10 do
      while displaying and DoesEntityExist(obj) do
        Wait(5)
        local pcoords = GetEntityCoords(PlayerPedId())
        if GetDistanceBetweenCoords(crds.x, crds.y, crds.z, pcoords.x, pcoords.y, pcoords.z, true) < 15.0 then
          DrawText3D(crds.x, crds.y, crds.z + 1.0, 'Bisa dipanen')
        else
          Citizen.Wait(2000)
        end
      end
    end
  end)
end

function DrawText3D(x,y,z, text)
  local onScreen, _x, _y = World3dToScreen2d(x, y, z)
  SetTextScale(0.32, 0.32)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 255)
  SetTextEntry("STRING")
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(_x, _y)
  local factor = (string.len(text)) / 500
  DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 80)
end

RegisterNetEvent('kc_farming:notify')
AddEventHandler('kc_farming:notify', function(type, msg)
  if Config.UseMythicNotify then
    exports['mythic_notify']:DoHudText(type, msg)
  else
    ESX.ShowNotification(msg)
  end
end)

RegisterNetEvent('kc_farming:getJob')
AddEventHandler('kc_farming:getJob', function()
  if jobs == nil and not duty then
    local coords = GetEntityCoords(GetPlayerPed(-1))

    for k, v in pairs(Config.Zones) do
      if #(coords - v.loc) < 10.0 then
        jobs = v.job
        duty = true
        spawnProps(jobs)
      end
    end
    TriggerEvent('kc_farming:notify', 'inform', _U('have_job', jobs))
  end
end)

RegisterNetEvent('kc_farming:leaveJob')
AddEventHandler('kc_farming:leaveJob', function()
  if jobs and duty then
    for k,v in pairs(Config.PropZones[jobs]) do
      for i = 1, 10 do
        DeleteEntity(prop[i].obj)
      end
    end
    TriggerEvent('kc_farming:notify', 'inform', _U('finish_job', jobs))
    spawnedFarms = 0
    jobs = nil
    duty = false
    prop = {}
    object = {}
    canHarvest = false
  else
    TriggerEvent('kc_farming:notify', 'error', _U('not_job'))
  end
end)

RegisterNetEvent('kc_farming:getWater')
AddEventHandler('kc_farming:getWater', function()
  ESX.TriggerServerCallback('kc_farming:checkItem', function(hasItem)
    if hasItem then
      TriggerServerEvent('kc_farming:removeItem', 'watering_can', 1)
      Wait(500)
      exports['mythic_progbar']:Progress({
        duration = 5000,
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
      TriggerEvent('kc_farming:notify', 'error', 'Kamu tidak mempunyai kaleng air')
    end
  end, 'watering_can', 1)
end)

RegisterNetEvent('kc_farming:wateringProgress')
AddEventHandler('kc_farming:wateringProgress', function(target)
  ESX.TriggerServerCallback('kc_farming:checkItem', function(hasItem)
    if hasItem then
      local netIds = NetworkGetNetworkIdFromEntity(target.args.prop.obj)
      exports.ox_target:removeEntity(netIds, 'watering')
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
        }
      }, function(status)
        if not status then
          TriggerServerEvent('kc_farming:removeItem', 'watering_can_full', 1)
          Harvest(target.args.prop, target.args.job, target.args.waitTime)
        end
      end)
    else
      TriggerEvent('kc_farming:notify', 'error', 'Kamu tidak mempunyai Penyiram Tanaman Terisi')
    end
  end, 'watering_can_full', 1)
end)

RegisterNetEvent('kc_farming:farmingProgress')
AddEventHandler('kc_farming:farmingProgress', function(target)
  ESX.TriggerServerCallback('kc_farming:checkItem', function(hasItem)
    if hasItem then
      exports['mythic_progbar']:Progress({
        duration = 5000,
        label = _U('harvest', target.args.job),
        useWhileDead = false,
        canCancel = false,
        controlDisables = {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true,
        },
        animation = {
          animDict = "amb@world_human_gardener_plant@female@base",
          anim = "base_female",
        }
      }, function(status)
        if not status then
          for i = 1, 10 do
            if prop[i].obj == target.args.obj.obj then
              TriggerServerEvent('kc_farming:harvest', target.args.job)
              DeleteEntity(prop[i].obj)
              spawnedFarms = spawnedFarms - 1
              prop[i] = {}
            end
          end
        end
      end)
    else
      TriggerEvent('kc_farming:notify', 'error', 'Kamu tidak mempunyai Skop')
    end
  end, 'trowel', 1)
end)

CreateThread(function()
  exports.ox_target:addModel({'player_one'}, {
    {
      name = 'onduty',
      icon = 'fa-solid fa-file-pen',
      label = _U('get_job'),
      event = 'kc_farming:getJob',
    },
    {
      name = 'offduty',
      icon = 'fa-solid fa-file-pen',
      label = _U('end_job'),
      event = 'kc_farming:leaveJob',
    },
  })

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
end)

CreateThread(function()
  for _, v in pairs(Config.Peds) do
    spawnNPC(v.x, v.y, v.z, v.heading, v.hash, v.model)
  end
end)

CreateThread(function()
  for k, v in pairs(Config.Zones) do
    local blip = AddBlipForCoord(v.loc)
    SetBlipSprite (blip, Config.Blips.Sprite)
    SetBlipColour (blip, Config.Blips.Color)
    SetBlipDisplay(blip, Config.Blips.Display)
    SetBlipScale  (blip, Config.Blips.Scale)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(_U('land', v.job))
    EndTextCommandSetBlipName(blip)
  end
end)
