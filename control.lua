--TODO: store last_crank_tick in global to prevent potential desyncs

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
  game_speed                    = settings.startup.hcg__game_speed                    .value,
}

-- MAIN (same as in Factorio 0.13.x)
local last_crank_tick = {} --set this here so it is available between event calls

script.on_event(defines.events.on_player_created, function(event)
  --inserts the item into the players inventory when they first join the map
  --as we don't care about anything else we can just do a direct call to
  --insert into the inventory.
  --Calling .insert diretcly on the player object instead of trying to guess
  --what valid inventories a player might have. This circumvents some oddities
  --with scenario maps where the player.character is not created simultaneously
  --with the player as such.
  
  local player  = game.players[event.player_index] --"pointer" to the player object
  local success = false
  
  if (config.start_with_item_in_quickbar == false) then
    success = (player.insert{name="hand-crank-generator"} > 0) --bool
  else
    --Sandbox players and normal players have different inventories,
    --so we need to know the type if we want to insert into the quickbar
    local typ = player.controller_type
    local inv --variable to hold the pointer to the player inventory
    if typ == defines.controllers.god then
      inv = player.get_inventory(defines.inventory.god_quickbar   ) --freeplay
    elseif typ == defines.controllers.character then
      inv = player.get_inventory(defines.inventory.player_quickbar) --sandbox
      end
    if inv and inv.valid then
      success = (inv.insert{name="hand-crank-generator"} > 0) --bool
      end
    if success == false then
      --backup plan (quickbar full?)
      success = (player.insert{name="hand-crank-generator"} > 0) --bool
      end
    end

  if success == false then
    game.print('Failed to find inventory for Hand Crank Generator') --TODO: localize, fix for PvP scenario
  elseif (success == true) then
    -- game.print('success')
  end
end)

script.on_event("hcg-crank-key",function(event)
  --first we must find out if what the player has selected is a hcg at all
  local p = game.players[event.player_index]
  local hcg = p.selected
  if not hcg then return end --player's mouse isn't hovering over anything (.selected = nil)
  if hcg.name == "hand-crank-generator" then --every entity has a name, but we only want hcg's
    local lct = last_crank_tick[hcg.unit_number] or 0 --use the last stored tick or 0 (the unit_number uniquely identifies each hcg so they can be cranked individually)
    if lct + config.crank_delay_in_ticks > event.tick then return end --spamming the button too fast shouldn't do anything.
    local dist = math.abs(p.position.x-hcg.position.x)+math.abs(p.position.y-hcg.position.y) --the player should stand near the hcg
    if dist < 2 then
      --we now know that the selected entity is a hcg, hasn't been cranked recently and the player is standing close
      last_crank_tick[hcg.unit_number] = event.tick
      hcg.energy = math.min(hcg.electric_buffer_size, --prevent overloading
                            hcg.energy + --read current energy
                            (config.power_output_in_watts*config.run_time_per_crank_in_seconds*config.game_speed) --and add more according to config settings
                            )
      hcg.surface.create_entity{name = "hcg-crank-sound", position = hcg.position} --spawn the sound explosion onto the generator
    else
      p.print{"hcg.too-far-away"} --give the player a hint in his language when he's too far away.
    end
  end
end)
