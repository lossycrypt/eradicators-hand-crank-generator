-- Pre Ingame-ModSettings config code (Factorio version 0.13.x):

-- hcg = {}; require'config'; local config = hcg; hcg = nil --hack to not require any code in the config file itself
-- available config values read from config.lua:
-- config.run_time_in_seconds
-- config.run_time_per_crank_in_seconds
-- config.crank_delay_in_ticks
-- config.power_output_in_watts
-- config.start_with_item_in_quickbar
-- config.can_pick_up
-- config.game_speed

-- Ingame-ModSettings adaption wrapper (to keep main code unchanged from 0.13.x version):
local config = {
  run_time_in_seconds           = settings.startup.hcg__run_time_in_seconds           .value,
  run_time_per_crank_in_seconds = settings.startup.hcg__run_time_per_crank_in_seconds .value,
  crank_delay_in_ticks          = settings.startup.hcg__crank_delay_in_ticks          .value,
  power_output_in_watts         = settings.startup.hcg__power_output_in_watts         .value,
  start_with_item_in_quickbar   = settings.startup.hcg__start_with_item_in_quickbar   .value,
  can_pick_up                   = settings.startup.hcg__can_pick_up                   .value,
  recipe_enabled                = settings.startup.hcg__recipe_enabled                .value,
  recipe_is_easy                = settings.startup.hcg__recipe_is_cheap               .value,
  game_speed                    = settings.startup.hcg__game_speed                    .value,
}


data:extend({
  {
    type = "custom-input",
    name = "hcg-crank-key",
    key_sequence = "r",
    -- consuming = "script-only"
   
    -- 'consuming'
    -- available options:
    -- none: default if not defined
    -- all: if this is the first input to get this key sequence then no other inputs listening for this sequence are fired
    -- script-only: if this is the first *custom* input to get this key sequence then no other *custom* inputs listening for this sequence are fired. Normal game inputs will still be fired even if they match this sequence.
    -- game-only: The opposite of script-only: blocks game inputs using the same key sequence but lets other custom inputs using the same key sequence fire.
  },
  {
    type = "item",
    name = "hand-crank-generator",
    icon = "__HandCrankGenerator__/sprite/hcg_item.png",
    icon_size = 32,
    -- flags = {"goes-to-quickbar"},
    flags = {"goes-to-main-inventory"},
    subgroup = "energy",
    order = "z",
    place_result = "hand-crank-generator",
    stack_size = 1
  },

  {
    type = "recipe",
    name = "hand-crank-generator-expensive",
    enabled = true and (config.recipe_enabled and not config.recipe_is_easy) or false, --if the recipe is enabled by default. disabled recipes can later be enabled via technology or scripting.
    ingredients =
    {
      {"electric-engine-unit", 2},
      {"electronic-circuit"  , 2},
      {"advanced-circuit"    , 1},
      {"copper-cable"        ,10},
      {"steel-plate"         , 5},
    },
    result = "hand-crank-generator",
    -- result_count = 10, --if we don't specify a result count it will default to 1
    energy_required = 30, --time it takes in seconds at crafting speed 1 to make this
  },
  {
    type = "recipe",
    name = "hand-crank-generator-cheap",
    enabled = true and (config.recipe_enabled and config.recipe_is_easy) or false, -- only enable the recipe if both options are enabled
    ingredients =
    {
      {"iron-gear-wheel"    ,10},
      {"electronic-circuit" , 2},
      {"copper-cable"       ,10},
      {"iron-plate"         , 5},
      {"copper-plate"       , 5},
    },
    result = "hand-crank-generator",
    energy_required = 90, --time it takes in seconds at crafting speed 1 to make this
  },

})

data:extend{
  {
    type = "accumulator",
    name = "hand-crank-generator", --copied accumulator prototype from base game and removed parts we don't need
    icon = "__HandCrankGenerator__/sprite/hcg_item.png",
    icon_size = 32,
    flags = {"placeable-neutral", "player-creation"},
    -- minable = {hardness = 0.2, mining_time = 0.5, result = "hand-crank-generator"}, --done per config at the bottom
    max_health = 50,
    -- order = "z",
    corpse = "small-remnants",
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_box = {{-0.5, -1.3}, {0.5, 0.5}},
    energy_source =
      {
        type = "electric",
        usage_priority = "terciary",
        input_flow_limit = "0kW", --we don't want the generator to charge off the grid.
        buffer_capacity = tostring(math.ceil(config.run_time_in_seconds*config.power_output_in_watts*config.game_speed))..'J',
        output_flow_limit = tostring(config.power_output_in_watts)..'W',
      },
    picture =
      {
        filename = "__HandCrankGenerator__/sprite/hcg.png",
        priority = "extra-high",
        width = 64,
        height = 64,
        shift = {0.5, -0.475},
      },
    charge_cooldown = 1,
    -- charge_light = {intensity = 0.3, size = 7},
    discharge_animation =
      {
        filename = "__HandCrankGenerator__/sprite/hcg.png",
        width = 64,
        height = 64,
        line_length = 8,
        frame_count = 3*8,
        scale = 1.0,
        shift = {0.5, -0.475}, --this moves the picture half a tile to the left an up a bit because the picture is bigger than we want the hcg to appear in-game
        animation_speed = 0.25,
      },
    discharge_cooldown = 1,
    -- discharge_light = {intensity = 0.7, size = 7},
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
      { sound =
          { filename = "__HandCrankGenerator__/sound/tank-engine-slow.ogg", --base game sound slowed by 50%
            volume = 0.65 },
        -- idle_sound =
          -- { filename = "__base__/sound/accumulator-idle.ogg",
            -- volume = 4 },
        -- max_sounds_per_type = 5
      },
    circuit_wire_max_distance = 0, --we don't want this to connect to any circuits
    
    circuit_wire_connection_point =
    {
      shadow =
      {
        red   = {11*1/32,  4 * 1/32}, --one tile is 32 pixels. so shift the connection point 11 pixels left from the center of the entity, and 4 pixels down
        green = {11*1/32,  4 * 1/32},
      },
      wire =
      {
        -- red = {0.6875, 0.59375},
        -- green = {0.6875, 0.71875} 
        red   = {11*1/32, -4 * 1/32},
        green = {11*1/32, -4 * 1/32}
      }
    },
    -- circuit_connector_sprites = get_circuit_connector_sprites({0.46875, 0.5}, {0.46875, 0.8125}, 26),
    circuit_wire_max_distance = 2,
    -- default_output_signal = {type='item', name="hand-crank-generator"} --setting item-based signals as default is not currently possible, so we'll just comment this out and thus leave the default signal empty.
    
  },
  
  {
    type = "explosion",
    name = "hcg-crank-sound", --we want cranking the generator to make a sound so we'll spawn this later.
    flags = {"not-on-map"},
    animations =
      {{
        filename = "__core__/graphics/empty.png", --sound should not be visible
        priority = "low",
        width = 1,
        height = 1,
        frame_count = 1,
        line_length = 1,
        animation_speed = 1
      }},
    -- light = {intensity = 1, size = 50},
    sound =
      { aggregation =
          {
            max_count = 1,
            remove = true
          },
        variations =
          {{
              filename = "__core__/sound/crafting-finished.ogg", --reusing base game sound
              volume = 1.0
          }},
      },
  },
}

if config.can_pick_up == true then
  data.raw["accumulator"]["hand-crank-generator"].minable = 
    {hardness = 0.2, mining_time = 0.5, result = "hand-crank-generator"} --making the hcg pick-up-able afterwards if the config was set
end