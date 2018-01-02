--BASE SETTINGS--
--default settings get you 5 minutes of 20kW for 10 seconds of button mashing (30 presses)

data:extend{

  --how long a fully charged generator can sustain maximum output (default 5 minutes)
  { name = 'hcg__run_time_in_seconds',
    type = 'int-setting',
    setting_type = 'startup',
    default_value = 300,
    minimum_value = 1,
    maximum_value = 10^16,
    order = 'a',
    },
  --how many seconds the generator will run at max output for one cranking (default 10 seconds)
  { name = 'hcg__run_time_per_crank_in_seconds',
    type = 'int-setting',
    setting_type = 'startup',
    default_value = 10,
    minimum_value = 1,
    maximum_value = 10^16,
    order = 'b',
    },
  --you can crank the generator once in this many ticks (default: 20 ticks == 0.3 seconds)
  { name = 'hcg__crank_delay_in_ticks',
    type = 'int-setting',
    setting_type = 'startup',
    default_value = 20,
    minimum_value = 1,
    maximum_value = 10^16,
    order = 'c',
    },
  --the maximum power output of the generator in watts (default: 20 kiloWatt)
  { name = 'hcg__power_output_in_watts',
    type = 'int-setting',
    setting_type = 'startup',
    default_value = 20000,
    minimum_value = 1,
    maximum_value = 10^16,
    order = 'd-a',
    },
  --if the player starts with the item in the quickbar (true) or in the main inventory (false)
  { name = 'hcg__start_with_item_in_quickbar',
    type = 'bool-setting',
    setting_type = 'startup',
    default_value = false,
    order = 'e',
    },
  --if the generator can be picked up again after placing it (default false)
  { name = 'hcg__can_pick_up',
    type = 'bool-setting',
    setting_type = 'startup',
    default_value = false,
    order = 'f',
    },
  --if additional generators can be crafted (default false)
  { name = 'hcg__recipe_enabled',
    type = 'bool-setting',
    setting_type = 'startup',
    default_value = false,
    order = 'g-a',
    },
  --if the recipe is cheap
  { name = 'hcg__recipe_is_cheap',
    type = 'bool-setting',
    setting_type = 'startup',
    default_value = false,
    order = 'g-b',
    },

  --ADVANCED SETTINGS--
  
  --if you play at a non-default speed adjust this to make the "in_seconds" settings represent
  --actual seconds again.
  { name = 'hcg__game_speed',
    type = 'double-setting',
    setting_type = 'startup',
    default_value = 1.0,
    minimum_value = 0.0001,
    maximum_value = 10^16,
    order = 'd-b',
    },
    
    
    
  }
  
