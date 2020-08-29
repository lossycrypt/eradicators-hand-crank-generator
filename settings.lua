
--[[

  Hello!
  
  The settings stage of this tutorial mod is going to demonstrate the following things:
    
    > Creating mod startup settings

  Abbreviations used:
    
    > HCG = Hand Crank Generator
    
  ]]


-- Mod settings make it possible to let the player decide about certain
-- aspects of a mod themselfs. Every setting has to be defined in settings stage.
-- During data stage you can only read "startup" type settings, while during
-- control stage you can read all types of settings.

-- It's important to always set minimum, maximum and default so that the player
-- can not enter unexpected values.

-- The goal here is to let the user fully customize the output of the HCG.
-- The default settings should produce 20kW power for 5 minutes at the cost of 
-- cranking for 10 seconds. Which is equal to 30 presses of the hotkey.


data:extend{

  --How long a fully charged generator can sustain maximum output (default 5 minutes).
  { name          = 'er:hcg-run-time-in-seconds',
    type          = 'int-setting' ,
    setting_type  = 'startup'     ,
    default_value = 300           ,
    minimum_value = 1             ,
    maximum_value = 10^16         ,
    -- The order can be any string you want. It will be compared to all other order strings
    -- like in a dictionary, and the settings will be sorted accordingly in the menu.
    order         = 'a'           ,
    },
    
  --How many seconds the generator will run at max output for one cranking (default 10 seconds).
  { name          = 'er:hcg-run-time-per-crank-in-seconds',
    type          = 'int-setting' ,
    setting_type  = 'startup'     ,
    default_value =  10           ,
    minimum_value =  1            ,
    maximum_value =  10^16        ,
    order         = 'b'           ,
    },
    
  --How many ticks must pass between two crankings (default: 20 ticks == 0.3 seconds).
  { name          = 'er:hcg-crank-delay-in-ticks',
    type          = 'int-setting' ,
    setting_type  = 'startup'     ,
    default_value =  20           ,
    minimum_value =  1            ,
    maximum_value =  10^16        ,
    order         = 'c'           ,
    },                            
    
  --The maximum power output of the generator in watts (default: 20 kiloWatt).
  { name          = 'er:hcg-power-output-in-watts',
    type          = 'int-setting' ,
    setting_type  = 'startup'     ,
    default_value =  20000        ,
    minimum_value =  1            ,
    maximum_value =  10^16        ,
    order         = 'd-a'         ,
    },

  --If additional generators can be crafted. In data state this will
  --determine if the recipe and technology are created.
  { name          = 'er:hcg-recipe-enabled',
    type          = 'bool-setting',
    setting_type  = 'startup'     ,
    default_value =  true         ,
    order         = 'g-a'         ,
    },
     
  }
  
