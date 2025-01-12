
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
  
-- First I need to define a few functions that I want to call
-- when a new map starts or the mod is added to an old map.
  
-- The default "Freeplay" scenario offers a so called "remote interface"
-- which allows mods like this one to add extra items to the players
-- starting items. This is great because it handles all the complicated
-- stuff for me, for example inserting the items for the first player
-- into the ship wreckage. 

-- If you want to know more about the interface you can read the scenario file at:
-- Factorio\data\base\scenarios\freeplay\freeplay.lua

-- Not every scenario has this interface, so I have to check
-- if it exists! Additionally I also check if the functions i'm going
-- to use exist - in case they change in a future version.
local function has_expected_freeplay_interface()
  -- Does the interface exist at all?
  if not remote.interfaces.freeplay then return false end
  -- I want these four functions
  local expected_methods = {
    'get_created_items', 'set_created_items', -- change the player starting inventory
    'get_debris_items' , 'set_debris_items' , -- change which of those items spawn in the wreckage
    }
  -- When iterating though an array often the index is not relevant.
  -- By convention it is often named with a single _ underscore,
  -- but it's really still a normal variable that's just never used!
  for _,method in pairs(expected_methods) do
    -- If any of the methods is missing the check fails instantly.
    if not remote.interfaces.freeplay[method] then return false end
    end
  -- If nothing failed then everything is ok!
  return true
  end

  
-- This next functions uses the interface to add the items I want.
-- First I "get" the current list of items, because I don't want to
-- overwrite them, I just want to add to the list! Then I put my items
-- into the list. If the same item type is already in the list then the
-- larger count will be used. Finally I "set" the altered list back to
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

  
-- So i've defined a few functions now, but I haven't used them yet!
-- I will define one final function that glues them together.
  
local function hcg_initializer()

  -- When a mod needs to store data permanently then it needs
  -- to be stored in a table called "storage". No other mod can
  -- access this data.
  
  -- Because I don't want players to be able to crank the HCG
  -- as fast as they can hit the button I need to store the time when
  -- they crank successfully. For that I will need to store
  -- a permanent table. Because hcg_initializer() will run several times
  -- the "or" construct preserves old data if there is any.
  storage.last_crank_tick = storage.last_crank_tick or {}
  
  -- If the scenario is freeplay-compatible then
  -- every player starts with one HCG. The first player
  -- will have to salvage it from the wreckage.
  if has_expected_freeplay_interface() then
    add_item_to_freeplay('created_items',{['er-hcg-item']=1})
    add_item_to_freeplay('debris_items' ,{['er-hcg-item']=1})

  else
    -- If the scenario does NOT have a freeplay-compatible remote interface
    -- I just print a warning. There are lots of scenarios out there
    -- and I can't possibly know what they want to achive, so it's better
    -- not to mess around. Because on multiplayer servers any players
    -- who "just play there" have no control over the mods used it's pointless
    -- to spam warnings to them. Therefore i only print the message to
    -- adminstrators once - in singleplayer you are always administrator.

    -- Because I don't know what language the player runs factorio in
    -- I have to use a "localized string" to send a message to their
    -- console. The engine will automatically chose the right language.
    -- Special messages like this are defined in /locale/<language>/hcg.cfg.
    -- They can be named anything I like, so I'm using my prefix again.

    for _,p in pairs(game.connected_players) do
      if p.admin then
        p.print({'er-hcg.freeplay-interface-not-found'})
        end
      end

    -- In case nobody is on the server when this happens i'm also going to
    -- print the message to the log file.
    log({'er-hcg.freeplay-interface-not-found'})

    end
  end
  
-- Last but not least I tell the engine to run my initializing
-- function on every new map and on every mod update or change. To keep this
-- tutorial simple I am using the same function for both events.
script.on_init(hcg_initializer)
script.on_configuration_changed(hcg_initializer)

-- The basic setup is done, but the HCG still doesn't produce any energy!
-- So the next thing I do is to hook a function into the event that triggers
-- when the player presses the hotkey. I'll need some utility functions for
-- for that again.


-- Because i'll need to access the config values very often I create
-- a local cache. This will make cranking a bit less computaionally expensive
-- because I don't have to constantly ask the engine what these values are.
-- If I was using "per-map" or "per-player" settings this would be more complicated
-- because those can change anytime. Lucky for me "startup" settings never change
-- during control stage so I don't need to worry about that.
local function getconfig(name)
  return settings.startup['er-hcg-'..name].value
  end
local config = {
  crank_delay_in_ticks =
    getconfig'crank-delay-in-ticks',
  power_per_crank_in_watts =     
    getconfig'power-output-in-watts' * getconfig'run-time-per-crank-in-seconds',
  }

-- I don't need the distance measurement to be super precise, so I use
-- a computationally cheap but slightly inaccurate algorithm.
local function manhattan_distance(p,hcg)
  return math.abs(p.position.x-hcg.position.x) + math.abs(p.position.y-hcg.position.y)
  end

-- WHEN the moment comes to crank the HCG I first check if the HCG
-- can be cranked yet. It's also important to check if the
-- player is close enough. Without this check it would be possible
-- to crank from anywhere on the map! For a better experience
-- I also play a vanilla sound effect to indicate if cranking worked.
-- If the player is too far away I display a small flavour text.
-- The current tick is stored per HCG so that in multiplayer it's
-- not possible to crank the same HCG with more than one player.
-- The function also returns true or false to make it useable 
-- as "if try_to_crank() then" later.
local function try_to_crank(tick,p,hcg)
  local last_crank_tick = storage.last_crank_tick[hcg.unit_number] or 0
  if last_crank_tick + config.crank_delay_in_ticks <= tick then
    if manhattan_distance(p,hcg) < 2 then
      storage.last_crank_tick[hcg.unit_number] = tick
      hcg.energy = hcg.energy + config.power_per_crank_in_watts
      hcg.surface.play_sound{
        path = 'utility/crafting_finished',
        volume_modifier = 1.0,
        }
      hcg.last_user = p
      return true
      
    else
      p.create_local_flying_text{
        text = {"er-hcg.too-far-away"},
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
-- An nil value is much cheaper to detect later than if I simply left
-- the table empty.

local function auto_cranker(e)
  for pindex,data in pairs(storage.auto_crankers) do
    if not (
     data.p.valid
     and data.hcg.valid
     and data.p.character
     and try_to_crank(e.tick,data.p,data.hcg)
     ) then
      storage.auto_crankers[pindex] = nil
      end
    if table_size(storage.auto_crankers) == 0 then
      storage.auto_crankers = nil
      script.on_nth_tick(config.crank_delay_in_ticks,nil)
      end
    end
  end

-- While unregistering any unused on_tick handlers is better for performance
-- it's easy to accidentially cause BUGS and DESYNCS in multiplayer if done wrong.
-- This is because handler status is not stored when the game is saved and loaded.
-- So I have to manually reactivate the handler when the game is loaded, but
-- ONLY IF it had been active EVEN IF the game had never been saved and loaded but
-- had been running continuously instead. For this the current status of the handler
-- has to be stored in storage. Because my handler needs additional data, I simply
-- check if there IS any data to process, and if yes reactivate the handler.

local function try_activate_auto_cranker()
  if storage.auto_crankers ~= nil then
    script.on_nth_tick(config.crank_delay_in_ticks,auto_cranker)
    end
  end
script.on_load(try_activate_auto_cranker)

-- This function is what initially starts the auto-cranking mechanism by
-- storing the (player,generator) data to be processed. Because in multiplayer
-- each player should be able to crank only one generator I index the
-- data with the player.index - a number unique for each player. That way
-- if the player starts to crank a different HCG the data for the previous one
-- will simply be overwritten. I also store the references to the player
-- and HCG entity so that they are easier to access in the on_nth_tick handler.
-- Because storage.auto_crankers is nil when there is nothing to do I also have
-- to create a new table if this player is the only one currently auto-cranking.
-- If there were other players already auto-cranking then the handler is already
-- running and does not need to be activated again.
  
local function add_auto_cranker(p,hcg)
  local new_cranker = {p=p,hcg=hcg}
  if storage.auto_crankers ~= nil then
    storage.auto_crankers[p.index] = new_cranker
  else
    storage.auto_crankers = {[p.index] = new_cranker}
    try_activate_auto_cranker()
    end
  end
  
-- !!
-- The ADVANCED on_nth_tick section ENDS here.
-- !!
  
  
  
  
  
-- The event handlers glues the cranking function and the hotkey together.
-- It has to check if the players mouse is actually hovering over an HCG,
-- and it also enforces the configured delay between crankings by storing
-- the current tick if cranking was successful.
script.on_event('er-hcg-crank-key',function(e)
  local p = game.players[e.player_index]
  local selected_entity = p.selected
  if selected_entity and (selected_entity.name == 'er-hcg-entity') then
    -- If the auto-crank technology is disabled or not researched, then
    -- crank manually.
    if not settings.startup["er-hcg-recipe-enabled"].value
      or not p.force.technologies['er-hcg-technology'].researched then
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

-- It is important to remember that in Factorio every game behaves as
-- if it was a multiplayer game. In singleplayer you just happen to 
-- be the only one who can join the "server".

-- This concludes this tutorial mod and hopefully you are now ready to
-- go forth and create exciting mods of your own!
