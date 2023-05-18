Config                 = {}
Config.Locale          = GetConvar('esx:locale', 'id')
Config.Notify = 'okokNotify'
Config.GrowingPlanting = 1000
Config.HarvestCount = {15, 20}

Config.Blips = {
  Sprite = 88, Color = 69, Display = 4, Scale = 0.8,
}

Config.TargetZones = {
  GetWater = {
    Coords = vector3(2503.78, 4799.7, 35.0),
    Size = vector3(3.5, 3.5, 3.5),
    Rot = 333
  }
}

Config.Items = {
  ['bibit_padi'] = {
    label = 'Bitit Padi',
    get = 'beras',
		prop = 'prop_veg_grass_01_c',
  },

	['bibit_tebu'] = {
		label = 'Bibit tebu',
		get = 'gula',
		prop = 'prop_plant_01a'
	},

	['bibit_coklat'] = {
		label = 'Bibit Coklat',
		get = 'coklat',
		prop = 'prop_veg_crop_04_leaf'
	},

	['bibit_teh'] = {
		label = 'Bibit Teh',
		get = 'teh',
		prop = 'prop_cat_tail_01'
	},

	['bibit_kopi'] = {
		label = 'Bibit Kopi',
		get = 'kopi',
		prop = 'prop_bush_med_06'
	},

	['bibit_cabai'] = {
		label = 'Bibit Cabai',
		get = 'cabai',
		prop = 'prop_veg_crop_02'
	},

	['bibit_gandum'] = {
		label = 'Bibit Gandum',
		get = 'tepung_terigu',
		prop = 'prop_veg_crop_04_leaf'
	},
}