
--BASE SETTINGS--

--default settings get you 5 minutes of 20kW for 10 seconds of button mashing (30 presses)

--how long a fully charged generator can sustain maximum output (default 5 minutes)
hcg.run_time_in_seconds           = 300

--how many seconds the generator will run at max output for one cranking (default 10 seconds)
hcg.run_time_per_crank_in_seconds = 10

--you can crank the generator once in this many ticks (default: 20 ticks == 0.3 seconds)
hcg.crank_delay_in_ticks          = 20

--the maximum power output of the generator in watts (default: 20 kiloWatt)
hcg.power_output_in_watts         = 20000

--if the player starts with the item in the quickbar (true) or in the main inventory (false)
hcg.start_with_item_in_quickbar   = true

--if the generator can be picked up again after placing it (default false)
hcg.can_pick_up                   = false

--ADVANCED SETTINGS--

--if you play at a non-default speed adjust this to make the "in_seconds" settings represent
--actual seconds again.
hcg.game_speed                    = 1
