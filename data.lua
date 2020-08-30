
--[[

  Hello!
  
  The data stage of this tutorial mod is going to demonstrate the following things:
    
    > Reading mod startup settings
    
    > Using simple functions to make repetitive code shorter
    
    > Using name prefixes to ensure compatibility with other mods
    
    > Creating an entity 
    
    > Creating an item to place the entity
    
    > Creating a recipe to craft the item
    
    > Conditionally Creating a technology to unlock the recipe
    
    > Bonus: Changing existing prototypes based on what other mods are installed

  Abbreviations used:
    
    > HCG = Hand Crank Generator
    
    > data "stage", settings "stage" = In factorio each "stage" of the startup process
        is divided into three "phases". I.e. the data stage consists of data.lua,
        data-updates.lua and data-final-fixes.lua. This mod does not use updates or 
        final-fixes.
    
  ]]


-- First I define three simple functions, one for reading startup settings
-- and one for creating paths to the .png files for each prototype.

-- Everytime I need a "name=" I put a prefix before it, so that
-- Other mods with similar names do not interfere with mine and vice versa.
-- I use "er:" because my name is eradicator, but that's kinda long.
-- The prefix can be any string you like. I use a second prefix "hcg-"
-- because I have more than one mod, and this makes it easier to see what
-- belongs where.

local function config(name)
  return settings.startup['er:hcg-'..name].value
  end

local function sprite(name)
  return '__eradicators-hand-crank-generator__/sprite/'..name
  end
  
local function sound(name)
  return '__eradicators-hand-crank-generator__/sound/'..name
  end

 

-- To add new prototypes to the game I descripe each prototype in a table.
-- Then each of these tables is put together into one large table, and that large
-- table is handed to data:extend() which will put it into data.raw where
-- the game engine can find them.

data:extend({


  -- This is the hotkey that will later be used to "crank" the generator.
  {
    type                = 'custom-input'    ,
    name                = 'er:hcg-crank-key',
    
    -- I "link" this hotkey to a vanilla hotkey, so that
    -- the player does not have to remember an extra hotkey.
    -- Linked hotkeys must define an empty key_sequence.
    linked_game_control = 'rotate'          ,
    key_sequence        = ''                ,
    
    -- Here I could block other mods or even vanilla from
    -- using the same hotkey, but as i'm linking to another
    -- hotkey i'm not doing that. Assigning "nil" in lua
    -- deletes the value, so this line has the same effect as
    -- writing nothing at all.
    consuming           =  nil              , 

    -- Properties that have a known default value do not have to be
    -- specified. The engine will automatically assign the
    -- default value at the end of the data stage automatically.

    -- For reference these are the possible values for "consuming":

    -- 'none'       : Default if not defined.
    -- 'all'        : If this is the first input to get this key sequence
    --                then no other inputs listening for this sequence are fired.
    -- 'script-only': If this is the first *custom* input to get this key sequence
    --                then no other *custom* inputs listening for this sequence
    --                are fired. Normal game inputs will still be fired even if
    --                they match this sequence.
    -- 'game-only'  : The opposite of script-only. Blocks game inputs using the
    --                same key sequence but lets other custom inputs using the
    --                same key sequence fire.
    },
  
  
  -- This is the item that is used to place the entity on the map.
  {
    type = 'item',
    name = 'er:hcg-item',
    
    -- In lua any function that is called with exactly one argument
    -- can be written without () brackets if the argument is a string or table.
    
    -- here we call sprite() which will return the full path:
    -- '__eradicators-hand-crank-generator__/sprite/hcg-item.png'
    
    icon      =  sprite 'hcg-item.png', -- sprite('hcg-item.png')
    icon_size =  64     ,
    subgroup  = 'energy',
    order     = 'z'     ,
    
    -- This is the name of the entity to be placed.
    -- For convenience the item, recipe and entity
    -- often have the same name, but this is not required.
    -- For demonstration purposes I will use explicit
    -- names here.
    place_result = 'er:hcg-entity',
    stack_size   =  1      ,
    },

  })
  

  
-- The next step is slightly more complicated. According to the "lore" of this
-- mod the player only gets a single HCG. But because some people might want
-- more than one there is a "mod setting" that enables a technology and recipe.

-- So I have to read the setting and only create the technology and recipe prototypes
-- if the setting is enabled.

if config 'recipe-enabled' then data:extend({

  
  
  -- This is the recipe that can craft the item.
  {
    type = 'recipe',
    name = 'er:hcg-recipe',
    
    -- Recipes can have up to two different difficulties.
    -- Expensive is usually only used in "marathon" games.
    
    normal = {
      -- This only changes if the recipe is available from the start.
      -- Disabled recipes can later be unlocked by researching a technology.
      enabled = false,
      
      -- By the way: I put a lot of spaces everywhere so that the content of
      -- tables aligns better because I find it easier to read, but this is not nessecary.
      ingredients = {
        {'iron-gear-wheel'    ,10},
        {'electronic-circuit' , 2},
        {'copper-cable'       ,10},
        {'iron-plate'         , 5},
        {'copper-plate'       , 5},
        },
        
      result = 'er:hcg-item',
      
      -- Recipes always produce one item if nothing else is defined.
      -- result_count = 1,

      -- This is the TIME in seconds at crafting speed 1 to craft the item.
      -- So handcrafting a HCG will take 30 seconds, and an assembling-machine-1
      -- with only 0.5 crafting speed would need 60 seconds.
      -- Despite being called "energy" it does not affect the power consumed by
      -- assembline machines.
      energy_required = 30,
      },

    
    -- Here we basically define the recipe again, but with slightly different ingredients.
    expensive = {
      enabled = false,
      
      -- The order of item ingredients does not matter.
      -- The game sorts them alphabetiacally later.
      ingredients = {
        {'electric-engine-unit', 2},
        {'electronic-circuit'  , 2},
        {'advanced-circuit'    , 1},
        {'copper-cable'        ,10},
        {'steel-plate'         , 5},
        },
    
      result = 'er:hcg-item',
      energy_required = 90,
      
      },

    },
    
    
  -- This is the technology that will unlock the recipe.
  {
    name = 'er:hcg-technology',
    type = 'technology',
    
    -- Technology icons are quite large, so it is important
    -- to specify the size. As all icons are squares this is only one number.
    icon = sprite 'hcg-technology.png',
    icon_size = 128,
    
    -- Deciding one a recipe becomes available is an important balancing decision.
    prerequisites = {"electric-energy-distribution-1"},
    
    effects = {
      { type   = 'unlock-recipe',
        recipe = 'er:hcg-recipe'
        },
        
      -- The "nothing" effect is used to implement research effects
      -- that the engine does not support directly. It places a marker
      -- with a description in the technology menu so that the player
      -- knows what is going to happen. The actual effect has to be implemented
      -- by the mod in control stage.
      { type = 'nothing',
        effect_description = {'er:hcg.auto-cranking'},
        },
        
      },
      
    unit = {
      count = 150,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack"  , 1},
        },
      time = 30,
      },
    
    order = "c-e-b2",
    },

  }) end -- this is the "end" of the mod-setting check

  

  
-- Sometimes it's nessecary to prepare data outside of a prototype definition.
-- Because the HCG should be connectable to the circuit network the engine needs
-- to know where the cables should go.

-- Vanilla offers a premade function that makes it very easy to generate the
-- required data. But in the case of the HCG none of the premade connectors
-- has quite the right angle. So I take the template, make a copy of it and then
-- remove the yellow "base" from the connector so that only the cable attachments
-- remain. If I removed the base without copying the table first it would affect
-- EVERY entity in the game that uses this function afterwards.

-- Vanilla includes the "util" module that has some useful functions.

-- It doesn't look awesome, but it gets the job done.

local no_base_connector_template = util.table.deepcopy(universal_connector_template)
no_base_connector_template. connector_main   = nil --remove base
no_base_connector_template. connector_shadow = nil --remove base shadow
  
local connector = circuit_connector_definitions.create(no_base_connector_template,{{
  -- The "variation" determines in which direction the connector is drawn. I look
  -- at the file "factorio\data\base\graphics\entity\circuit-connector\hr-ccm-universal-04a-base-sequence.png"
  -- and count from the left top corner starting with 0 to get the angle I want.
  variation     = 25,
  main_offset   = util.by_pixel(7.0, -4.0), -- Converts pixels to tile fractions
  shadow_offset = util.by_pixel(7.0, -4.0), -- automatically for easier shifting.
  show_shadow   = true
  }})


-- When adding only a single prototype I like to put all the { brackets on one line.
data:extend{{

  -- This is the actual Hand Crank Generator Entity.
  -- Because there is no base prototype that behaves exactly as
  -- I want I chose a type that is close enough and add
  -- a control.lua script to control the exact behavior.

  -- At the beginning it's easiest to copy the whole prototype
  -- of a vanilla entity and remove / change the bits you don't need.
  
    type      = 'accumulator'  ,
    name      = 'er:hcg-entity',
    flags     = {'placeable-neutral', 'player-creation'},
    icon      = sprite 'hcg-item.png',
    icon_size = 64,

    -- In earlier versions the HCG could not be picked up once placed - because it was damaged
    -- during the crash landing. But some people complained that that was too inconvenient!
    minable = {
      mining_time = 0.5,
      result      = 'er:hcg-item'
      },
    
    max_health = 150,
    corpse = 'small-remnants', --what remains when the entity is destroyed.
    
    -- Tall entities should have different size "on the ground" than
    -- their visible size.
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_box = {{-0.5, -1.3}, {0.5, 0.5}},
    
    
    energy_source = {
      type                   = 'electric',
      
      -- Making the HCG lower priority than normal generators
      -- ensures that it doesn't waste energy while steam power is available.
      usage_priority         = 'tertiary',
      
      -- Because the HCG is technically an accumulator, so it's natural
      -- behavior is to take energy from the grid and store it. But as
      -- I want it to be only charged by hand I have to prevent that.
      input_flow_limit       = '0kW',
      
      -- The mod settings take numbers, but prototypes must define energy
      -- related values as strings, so I have to convert them.
      buffer_capacity        = tostring(
        math.ceil(
          config'run-time-in-seconds' * config'power-output-in-watts'
          )
        )..'J',
        
      output_flow_limit      = tostring(
        config'power-output-in-watts'
        )..'W',
      
      -- Sometimes it's useful to hide the "missing cable" and "no power" icons.
      -- But I don't need that for HCG.
      -- render_no_network_icon = false,
      -- render_no_power_icon   = false,    
      },
      
    
    -- I want the HCG to look fancy! For that I need an animation.
    -- In factorio and many other sprite-based 2D games animations are
    -- stored as a single large picture - a so called "sprite sheet".
    -- This sprite sheet contains all frames of the animation, so i
    -- have to tell the engine how large each frame is, and how many
    -- frames there are in total.
    discharge_animation = {
      filename        = sprite 'hcg-animation.png',
      width           = 128,
      height          = 128,
      
      --The sprite sheet has 3 rows with 8 pictures each. So there
      --are 24 frames in total. But the code is much nicer to read
      --if I just write this as a formula.
      line_length     =   8,
      frame_count     = 3*8,
      
      -- Originally vanilla graphics had 32 pixels per 1 tile. But later
      -- High resolution graphics with 64 pixels per tile were added.
      -- The HCG is rendered in high resolution, so it has to be shown at half
      -- the size to fit with the original 32 pixel standard.
      scale           = 0.5,
      
      -- Shift is used when the center of a picture is
      -- not the visual center of the entity. I.e. because
      -- the picture also contains a shadow. Shift values
      -- are given in tiles.
      shift           = {0.5, -0.475},
      
      -- By using a lower animation speed I can have a slow animation
      -- with fewer frames than i'd need at full speed.
      animation_speed = 0.25, 
      },
      
    -- The rotating "dis/charge" animation should stop immedeatly if
    -- the player stops cranking/the hcg is empty. So I set this to one tick.
    charge_cooldown    = 1,
    discharge_cooldown = 1,
    
    -- Accumulator type entities need a single still image
    -- for when they're not dis-/charging. But I can just recycle
    -- the first frame of the animation!
    picture = {
      filename = sprite 'hcg-animation.png',
      priority = 'extra-high',
      width    = 128,
      height   = 128,
      shift    = {0.5, -0.475},
      scale    = 0.5,
      },

      
    --Vanilla factorio comes with some predefined sound groups for
    --when you drive into a building at full speed yet again.
    
    --They are stored in a seperate file so I need to load that file.
    --Normally require() should only be used at the beginning of a
    --source code file so the result can be used multiple times
    --throughout the file. I am making an exception here for the sake
    --of keeping the tutorial in a readable non-confusing order.
    --You shouldn't do this, but it gives me a chance to show you
    --that require() behaves like any other function and returns
    --the result of reading a file. In this case a table of tables,
    --of which I am only interested in a single sub-table.
    vehicle_impact_sound = require("__base__/prototypes/entity/demo-sounds")['generic_impact'],
      
    working_sound = {
      sound = {
        filename = sound  'tank-engine-slow.ogg', --base game sound slowed by 50%
        volume = 0.65
        },
      },
        
    -- Some people told me that they'd like to use the HCG as a timer
    -- so I added circuit connections. But because it's a bonus feature
    -- I limit the maximum range to just two tiles.
    circuit_wire_max_distance     = default_circuit_wire_max_distance,
    
    -- Here I use the data that I prepared above.
    circuit_wire_connection_point = connector.points ,
    circuit_connector_sprites     = connector.sprites,

    -- For completition I assign a default signal like all
    -- vanilla entities do.
    default_output_signal = {type='item', name='er:hcg-item'},
    
  }}


-- Congratulations. You have finished the data statge tutorial!
  
  
-- As a little bonus: Now that i'm done with setting up everything for
-- an unmodded vanilla games I will add some special behavior if certain
-- other mods are installed.




-- The mod "AAI Industries" restructures the start of the tech tree,
-- so i'm going to change the prerequisites of the hcg-technology 
-- to make it available earlier and reduce the research cost to 
-- fit into the balancing of "AAI Industries". But only if it is
-- installed and has created a technology named "electricity".

-- After a prototype has been created with data:extend() it can 
-- be accessed in "data.raw". First I store a reference to the
-- technology so the manipulation code is easier to write. Then
-- I change only the attributes that I need to.

-- Because I am changing a technology that I created only a few lines
-- above I know exactly what to expect. But when manipulting prototypes
-- that other mods have created care must be taken to not accidentially
-- overwrite or delete data.
if mods['aai-industry'] and data.raw.technology['electricity'] then
  if config 'recipe-enabled' then
    local hcg_technology = data.raw.technology['er:hcg-technology']  
    hcg_technology.prerequisites = {'electricity'}
    hcg_technology.unit.count = 70
    hcg_technology.unit.time  = 15
    hcg_technology.unit.ingredients = {{"automation-science-pack", 1}}
    end
  end
