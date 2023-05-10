Config                 = {}
Config.Locale          = GetConvar('esx:locale', 'id')
Config.UseMythicNotify = true
Config.Prop            = 'prop_veg_crop_04_leaf'
Config.Duration        = 5000
Config.HarvestCount    = 2

Config.Blips = {
  Sprite = 88, Color = 69, Display = 4, Scale = 0.8,
}

Config.Zones = {
  { job = 'beras', loc = vector3(2149.9883, 5112.8877, 46.5777) },
  { job = 'gula', loc = vector3(2501.3093, 4801.2344, 34.7330) },
  { job = 'coklat', loc = vector3(2600.5166, 4711.9102, 33.9308) },
  { job = 'teh', loc = vector3(1993.7390, 4923.2373, 42.9420) },
  { job = 'garam', loc = vector3(295.9206, 6633.2363, 29.2147) },
  { job = 'kopi', loc = vector3(293.2093, 6484.9204, 29.8319) },
  { job = 'cabai', loc = vector3(747.9730, 6454.0820, 31.9701) }
}

Config.Peds = {
  { x = 2149.9883, y = 5112.8877, z = 46.5777, heading = 45.1082, hash = 0x9B22DBAF, model = 'player_one' },
  { x = 2501.3093, y = 4801.2344, z = 34.7330, heading = 63.1579, hash = 0x9B22DBAF, model = 'player_one' },
  { x = 2600.5166, y = 4711.9102, z = 33.9308, heading = 106.2389, hash = 0x9B22DBAF, model = 'player_one' },
  { x = 1993.7390, y = 4923.2373, z = 42.9420, heading = 106.2389, hash = 0x9B22DBAF, model = 'player_one' },
  { x = 295.9206, y = 6633.2363, z = 29.2147, heading = 106.2389, hash = 0x9B22DBAF, model = 'player_one' },
  { x = 293.2093, y = 6484.9204, z = 29.8319, heading = 106.2389, hash = 0x9B22DBAF, model = 'player_one' },
  { x = 747.9730, y = 6454.0820, z = 31.9701, heading = 106.2389, hash = 0x9B22DBAF, model = 'player_one' },
}

Config.PropZones = {
  beras = vector3(2152.7278, 5161.5503, 53.6565),
  gula = vector3(2525.8760, 4813.4121, 33.8532),
  coklat = vector3(2627.9578, 4715.3091, 34.7169),
  teh = vector3(2004.9004, 4899.0371, 42.7522),
  garam = vector3(272.5452, 6648.8193, 29.7619),
  kopi = vector3(260.6996, 6462.3882, 31.3090),
  cabai = vector3(723.1858, 6464.1787, 30.5948)
}