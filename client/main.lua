local ESX, jobs = nil, nil
local PlayerData = {}
local duty = false
local spawnedFarms = 0

CreateThread(function()
	while ESX == nil do
		ESX = exports["es_extended"]:getSharedObject()
		Wait(10)
	end 
  PlayerData = ESX.GetPlayerData()
end)

function spawnProps(curentJob)
  if spawnedFarms < 20 then
    local modelHash = Config.Prop
    for k, v in pairs(Config.PropZones[curentJob]) do
      local prop = GetClosestObjectOfType(v.pos, 3.0, GetHashKey(modelHash), false, 0, 0)
      if prop == 0 then
        ESX.Game.SpawnObject(modelHash, v.pos, function(obj)
          PlaceObjectOnGroundProperly(obj)
          Wait(200)
          FreezeEntityPosition(obj, true)
          spawnedFarms = spawnedFarms + 1
        end)
      end
    end
  end
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
        TriggerEvent('kc_farming:startFarming', jobs)
      end
    end
    TriggerEvent('kc_farming:notify', 'inform', _U('have_job', jobs))
  end
end)

RegisterNetEvent('kc_farming:leaveJob')
AddEventHandler('kc_farming:leaveJob', function()
  if jobs and duty then
    for k,v in pairs(Config.PropZones[jobs]) do
      local prop = GetClosestObjectOfType(v.pos, 10.0, GetHashKey(Config.Prop), false, 0, 0)
      DeleteEntity(prop)
    end
    TriggerEvent('kc_farming:notify', 'inform', _U('finish_job', jobs))
    exports.ox_target:removeModel(Config.Prop, 'harvest')
    spawnedFarms = 0
    jobs = nil
    duty = false
  else
    TriggerEvent('kc_farming:notify', 'error', _U('not_job'))
  end
end)

RegisterNetEvent('kc_farming:farmingProgress')
AddEventHandler('kc_farming:farmingProgress', function(curentJob)
  exports['mythic_progbar']:Progress({
    duration = Config.Duration,
    label = _U('harvest', curentJob),
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
      TriggerServerEvent('kc_farming:harvest', curentJob)
      local playerLoc = GetEntityCoords(GetPlayerPed(-1))
      local prop = GetClosestObjectOfType(playerLoc, 5.0, GetHashKey(Config.Prop), false, 0, 0)
      DeleteEntity(prop)
      spawnedFarms = spawnedFarms - 1
    end
  end)
end)

RegisterNetEvent('kc_farming:startFarming')
AddEventHandler('kc_farming:startFarming', function(curentJob)
  if duty then
    spawnProps(curentJob)
    exports.ox_target:addModel(Config.Prop, {
      {
        name = 'harvest',
        icon = "fa-solid fa-hand",
        label = _U('harvest', curentJob),
        onSelect = function()
          TriggerEvent('kc_farming:farmingProgress', curentJob)
        end,
      }
    })
  end
end)

CreateThread(function()
  while true do 
    local Sleep = 2000
    if jobs then
      Sleep = 100000
      spawnProps(jobs)
    end
    Wait(Sleep)
  end
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
