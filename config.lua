Config                 		= {}
Config.Locale          		= 'id'
Config.Notify 				 		= 'okokNotify' -- use 'mythic_notify', 'okokNotify', 'lib' or 'default' (default framework)
Config.HarvestCount 	 		= {25, 35}
Config.HarvestTime				= 1 -- waktu panen (menit)
Config.WateringTime				= 0.5 -- mengurangi air perdetik semakin besar angkanya semakin harus sering disiram
Config.FertilizerTime			= 0.15 -- mengurangi pupuk perdetik semakin besar angkanya semakin harus sering dikasih pupuk
Config.WateringDurability = 5 -- penggunaan air
Config.Debug 							= true
Config.CheckForUpdates		= true

Config.Shops = {
	["FarmingSS"]= {
		Model = "A_M_M_Hillbilly_01",
		Label = "Farm Equipment Store",
		Coords = vector3(2028.0490, 4978.8511, 41.1187),
		Heading = 227.0400,
		Items = {
			{ name = 'watering_can', price = 15000 },
			{ name = 'shovel', price = 15000 },
			{ name = 'fertilizer', price = 500 },
			{ name = 'rice_seeds', price = 100 },
			{ name = 'sugarcane_seeds', price = 100 },
			{ name = 'chocolate_seeds', price = 100 },
			{ name = 'tea_seeds', price = 100 },
			{ name = 'coffee_seeds', price = 100 },
			{ name = 'chili_seeds', price = 100 }
		}
	}
}

Config.Blips = {
	{
		Coords = vector3(2032.7, 4877.31, 50.41),
		Sprite = 88, 
		Color = 69, 
		Display = 4,
		Scale = 0.8,
	},
	{
		Coords = vector3(2541.0620, 4810.0405, 33.6945),
		Sprite = 88, 
		Color = 69, 
		Display = 4,
		Scale = 0.8,
	},
}

Config.WaterZone = {
  GetWater = {
    Coords = vector3(2503.78, 4799.7, 35.0),
    Size = vector3(3.5, 3.5, 3.5),
    Rot = 333
  },
  GetWater2 = {
    Coords = vector3(2042.59, 4856.18, 43.13),
    Size = vector3(3.5, 3.5, 3.5),
    Rot = 316
  }
}

Config.FarmZone = {
  [1] = {
    Coords = vector3(2541.0620, 4810.0405, 33.6945),
    Size = vector3(45, 70, 20),
    Rot = 225
  },
  [2] = {
    Coords = vector3(2032.7, 4877.31, 42.41),
    Size = vector3(35, 33, 20),
    Rot = 316
  }
}

Config.Items = {
  ['rice_seeds'] = {
    label = 'Rice Seeds',
    get = 'beras',
		prop = 'prop_veg_grass_01_c',
  },

	['sugarcane_seeds'] = {
		label = 'Sugarcane Seeds',
		get = 'gula',
		prop = 'prop_plant_01a'
	},

	['chocolate_seeds'] = {
		label = 'Chocolate Seeds',
		get = 'cokelat',
		prop = 'prop_veg_crop_04_leaf'
	},

	['tea_seeds'] = {
		label = 'Tea Seeds',
		get = 'teh',
		prop = 'prop_cat_tail_01'
	},

	['coffee_seeds'] = {
		label = 'Coffee seeds',
		get = 'kopi',
		prop = 'prop_bush_med_06'
	},

	['chili_seeds'] = {
		label = 'Chili Seeds',
		get = 'cabai',
		prop = 'prop_veg_crop_02'
	},
}