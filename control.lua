hcg = {}; require'config'; local config = hcg; hcg = nil --hack to not require any code in the config file itself
local last_crank_tick = {} --set this here so it is available between event calls
-- available config values read from config.lua:
-- config.run_time_in_seconds
-- config.run_time_per_crank_in_seconds
-- config.crank_delay_in_ticks
-- config.power_output_in_watts
-- config.start_with_item_in_quickbar
-- config.can_pick_up
-- config.game_speed

script.on_event(defines.events.on_player_created, function(event)
  --inserts the item into the players inventory when they first join the map
  --as we don't care about anything else we can just do a direct call to
  --insert into the inventory. because the quickbar might be full we can still
  --test that and insert into the main inventory otherwise.
  if config.start_with_item_in_quickbar == true then 
    if game.players[event.player_index]
        .get_inventory(defines.inventory.player_quickbar)
        .insert{name="hand-crank-generator"} == 1 then return end --successfully inserted into quickbar,skip the rest!
  end
  game.players[event.player_index]
    .get_inventory(defines.inventory.player_main)     --put in main inventory if config or quickbar full
    .insert{name="hand-crank-generator"}
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
