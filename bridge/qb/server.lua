if GetResourceState('qb-core') ~= 'started' then return end
QBCore = exports['qb-core']:GetCoreObject()
Framework = 'qb'

function GetPlayer(source)
  return QBCore.Functions.GetPlayer(source)
end

function GetPlayerFromIdentifier(identifier)
  local player = QBCore.Functions.GetPlayerByCitizenId(identifier)
  if not player then return false end
  return player
end

function GetPlayers()
  return QBCore.Functions.GetPlayers()
end

function getJob(src)
  local Player = GetPlayer(src)
  if Player ~= nil then
    return Player.PlayerData.job.name
  end
end

function RegisterCallback(name, cb)
  QBCore.Functions.CreateCallback(name, cb)
end