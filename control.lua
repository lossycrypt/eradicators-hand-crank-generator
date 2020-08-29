
--[[

  Hello!
  
  The control stage of this tutorial mod is going to demonstrate the following things:
    
    > Initializing permanent data structures
    
    > Reacting to custom hotkeys
    
    > Reading mod startup settings
    
    > Interacting with the freeplay scenario remote interface
    
    > Interacting with entities
    
    
  And the following advanced topics:
    
    > Implementing a dynamic on_nth_tick handler that is
      deactivated when not needed to save performance
    

  Abbreviations used:
    
    > HCG = Hand Crank Generator
    
  Variables with short names:
    
    > e   = the table containing the data from an event
    > p   = a references to a LuaPlayer
    > hcg = a references to a HCG entity
    
  ]]

  
-- First i need to define a few functions that i want to call
-- when a new map starts or the mod is added to an old map.
  
-- The default "Freeplay" scenario offers a so called "remote interface"
-- which allows mods like this one to add extra items to the players
-- starting items. This is great because it handles all the complicated
-- stuff for me, for example inserting the items for the first player
-- into the ship wreckage. 

-- If you want to know more about the interface you can read the scenario file at:
-- Factorio\data\base\scenarios\freeplay\freeplay.lua

-- Not every scenario has this interface, so i have to check
-- if it exists! Additionally i also check if the functions i'm going
-- to use exist - in case they change in a future version.
local function has_expected_freeplay_interface()
  -- Does the interface exist at all?
  if not remote.interfaces.freeplay then return false end
  -- I want these four functions
  local expected_methods = {
    'get_created_items', 'set_created_items', -- change the player starting inventory
    'get_debris_items' , 'set_debris_items' , -- change which of those items spawn in the wreckage
    }
  for _,method in pairs(expected_methods) do
    -- If any of the methods is missing the check fails instantly.
    if not remote.interfaces.freeplay[method] then return false end
    end
  -- If nothing failed then everything is ok!
  return true
  end

  
-- This next functions uses the interface to add the items i want.
-- First i "get" the current list of items, because i don't want to
-- overwrite them, i just want to add to the list! Then i put my items
-- into the list. If the same item type is already in the list then the
-- larger count will be used. Finally i "set" the altered list back to
-- the freeplay interface.
local function add_item_to_freeplay(interface_method,new_items)
  local items = remote.call('freeplay','get_'..interface_method)
  for name,count in pairs(new_items) do
    if (not items[name]) or (items[name] and items[name] < count) then
      items[name] = count
      end
    end
  remote.call('freeplay','set_'..interface_method,items)
  end

  
-- So i've defined a few functions now, but i haven't used them yet!
-- I will define one final function that glues them together.
  
local function hcg_initializer()

  -- When a mod needs to store data permanently then it needs
  -- to be stored in a table called "global". Despite the name
  -- no other mod can access this data.
  
  -- Because i don't want players to be able to crank the HCG
  -- as fast as they can hit the button i need to store the time when
  -- they crank successfully. For that i will need to store
  -- a permanent table. Because hcg_initializer() will run several times
  -- the "or" construct preserves old data if there is any.
  global.last_crank_tick = global.last_crank_tick or {}
  
  -- If the scenario is freeplay-compatible then
  -- every player starts with one HCG. The first player
  -- will have to salvage it from the wreckage.
  if has_expected_freeplay_interface() then
    add_item_to_freeplay('created_items',{['er:hcg-item']=1})
    add_item_to_freeplay('debris_items' ,{['er:hcg-item']=1})

  -- If the scenario isn't compatible i try to give it to
  -- the player directly. And if that fails too i give up.
  else
    script.on_event(defines.events.on_player_created,function(e)
      local p = game.players[e.player_index]
      local simple_stack = {name='er:hcg-item', count=1}
      -- I call p.insert() so i don't have to guess what types
      -- of inventory a player has.
      if p.can_insert(simple_stack) then
        p.insert(simple_stack)
      else
        p.print(
            "[Mod Warning][Eradicator's Hand Crank Generator]:\n"
          .."You have seem to have no inventory so i couldn't give you an HCG.\n"
          .."This means you're probably playing an incompatible scenario.\n"
          .."Feel free to send me a bug report if you think this is not ok. "
          )
        end
      
      
      end)
    end
  end
  
-- Last but not least i tell the engine to run my initializing
-- function on every new map and on every mod update or change. To keep this
-- tutorial simple I am using the same function for both events.
script.on_init(hcg_initializer)
script.on_configuration_changed(hcg_initializer)



-- The basic setup is done, but the HCG still doesn't produce any energy!
-- So the next thing i do is to hook a function into the event that triggers
-- when the player presses the hotkey. I'll need some utility functions for
-- for that again.


-- Because i'll need to access the config values very often i create
-- a local cache. This will make cranking a bit less computaionally expensive
-- because i don't have to constantly ask the engine what these values are.
-- If i was using "per-map" or "per-player" settings this would be more complicated
-- because those can change anytime. Lucky for me "startup" settings never change
-- during control stage so i don't need to worry about that.
local function getconfig(name)
  return settings.startup['er:hcg-'..name].value
  end
local config = {
  crank_delay_in_ticks =
    getconfig'crank-delay-in-ticks',
  power_per_crank_in_watts =     
    getconfig'power-output-in-watts' * getconfig'run-time-per-crank-in-seconds',
  }

-- I don't need the distance measurement to be super precise, so i use
-- a computationally cheap but slightly inaccurate algorythm.
local function manhattan_distance(p,hcg)
  return math.abs(p.position.x-hcg.position.x) + math.abs(p.position.y-hcg.position.y)
  end

-- WHEN the moment comes to crank the HCG i first check if the HCG
-- can be cranked yet. It's also important to check if the
-- player is close enough. Without this check it would be possible
-- to crank from anywhere on the map! For a better experience
-- i also play a vanilla sound effect to indicate if cranking worked.
-- If the player is too far away i display a small flavour text.
-- The current tick is stored per HCG so that in multiplayer it's
-- not possible to crank the same HCG with more than one player.
-- The function also returns true or false to make it useable 
-- as "if try_to_crank() then" later.
local function try_to_crank(tick,p,hcg)
  local last_crank_tick = global.last_crank_tick[hcg.unit_number] or 0
  if last_crank_tick + config.crank_delay_in_ticks <= tick then
    if manhattan_distance(p,hcg) < 2 then
      global.last_crank_tick[hcg.unit_number] = tick
      hcg.energy = hcg.energy + config.power_per_crank_in_watts
      hcg.surface.play_sound{
        path = 'utility/crafting_finished',
        volume_modifier = 1.0,
        }
      hcg.last_user = p
      return true
      
    else
      p.create_local_flying_text{
        text = {"er:hcg.too-far-away"},
        position = {hcg.position.x, hcg.position.y-0.5},
        color = nil,
        time_to_live = 90,
        speed = 1.0,
        }
      p.play_sound{
        path = 'utility/cannot_build',
        volume_modifier = 1.0,
        }
      return false
      end
    end
    
  end
  
  
  
  
  
-- !!  
-- The next three functions implmement a dynamic on_nth_tick handler.
-- This is a somewhat ADVANCED TOPIC, so if you are a BEGINNING MODDER
-- you can SKIP the next three blocks and continue with script.on_event.
-- !!

-- The first function is the event handler itself. It iterates through
-- a stored list of (player,generator) pairs and tries to crank.
-- When using data that was stored some ticks ago it is very important
-- to check if the data is still "valid". In a multiplayer game for example
-- the player might not be currently online anymore, or have been removed from the
-- game completely. Or the generator might have simply been destroyed.

-- The most common reason for a player to have no character (avatar) is
-- if the player is offline. But it's also possible that a script is involved,
-- like the intro cinematic of the freeplay scenario.

-- If cranking fails then the data for that player is removed from the 
-- rotation. And if there are no players left that are currently cranking
-- then the handler is un-registered and the data storage cleared.
-- An nil value is much cheaper to detect later than if i simply left
-- the table empty.

local function auto_cranker(e)
  for pindex,data in pairs(global.auto_crankers) do
    if not (
     data.p.valid
     and data.hcg.valid
     and data.p.character
     and try_to_crank(e.tick,data.p,data.hcg)
     ) then
      global.auto_crankers[pindex] = nil
      end
    if table_size(global.auto_crankers) == 0 then
      global.auto_crankers = nil
      script.on_nth_tick(config.crank_delay_in_ticks,nil)
      end
    end
  end

-- While unregistering any unused on_tick handlers is better for performance
-- it's easy to accidentially cause BUGS and DESYNCS in multiplayer if done wrong.
-- This is because handler status is not stored when the game is saved and loaded.
-- So i have to manually reactivate the handler when the game is loaded, but
-- ONLY IF it had been active anyway. For this the current status of the handler
-- has to be stored in global. Because my handler needs additional data, i simply
-- check if there IS any data to process, and if yes reactivate the handler.

local function try_activate_auto_cranker()
  if global.auto_crankers ~= nil then
    script.on_nth_tick(config.crank_delay_in_ticks,auto_cranker)
    end
  end
script.on_load(try_activate_auto_cranker)

-- This function is what initially starts the auto-cranking mechanism by
-- storing the (player,generator) data to be processed. Because in multiplayer
-- each player should be able to crank only one generator i index the
-- data with the player.index - a number unique for each player. That way
-- if the player starts to crank a different HCG the data for the previous one
-- will simply be overwritten. I also store the references to the player
-- and HCG entity so that they are easier to access in the on_nth_tick handler.
-- Because global.auto_crankers is nil when there is nothing to do i also have
-- to create a new table if this player is the only one currently auto-cranking.
-- If there were other players already auto-cranking then the handler is already
-- running and does not need to be activated again.
  
local function add_auto_cranker(p,hcg)
  local new_cranker = {p=p,hcg=hcg}
  if global.auto_crankers ~= nil then
    global.auto_crankers[p.index] = new_cranker
  else
    global.auto_crankers = {[p.index] = new_cranker}
    try_activate_auto_cranker()
    end
  end
  
-- !!
-- The ADVANCED on_nth_tick section ENDS here.
  
  
  
  
  
-- The event handlers glues the cranking function and the hotkey together.
-- It has to check if the players mouse is actually hovering over an HCG,
-- and it also enforces the configured delay between crankings by storing
-- the current tick if cranking was successful.
script.on_event('er:hcg-crank-key',function(e)
  local p = game.players[e.player_index]
  local selected_entity = p.selected
  if selected_entity and (selected_entity.name == 'er:hcg-entity') then
    if not p.force.technologies['er:hcg-technology'].researched then
      try_to_crank(e.tick,p,selected_entity)
    else
      -- If the players team ("force") has researched the technology
      -- then instead of manual cranking the ADVANCED auto-cranker is
      -- started.
      add_auto_cranker(p,selected_entity)
      end
    end
  end)

  
  
-- Congratulations. You have finished the control statge tutorial!

-- This concludes this tutorial mod and hopefully you are now ready to
-- go forth and create exciting mods of your own!

