# Summary

Type: Mod / Example
Name: Hand Crank Generator
Description: Adds a small manual generator to the starting items.
License: CC-BY-NC-SA 4.0 (Factorio license applies to factorio assets)
Version: 1.0.X
Release: 2016-07-12 (initial)
Tested-With-Factorio-Version: 0.13.6
Category: SimpleExtension
Tags: Hotkey, Localization, Example Mod
Languages: English, Deutsch, 日本語

# Description

This is a quick mod i made after a joke on the IRC channel and while i work on my bigger mod project.
It adds a small generator that you can manually charge by cranking (pressing the hotkey) while hovering the mouse over it (same as rotating objects works).
You only get one at the start of each map and it can only be placed down once.
This might be useful for low-tech modpacks or the similarly spirited.
By default it takes 15 seconds to fully crank and then provids 20kW of power for 5 minutes, but these values can easily be changed in the config.
This mod is also intended as a small example for new modders who wish to know how hotkeys and their localization works. For this purpose the source files have more comments than usual ;).[/spoiler]

# Changelog

1.0.4 (2016-07-14):
  Fixed crash when attempting to crank entities without unit_number (ore, trees).
  Some minor adjustments to hcg detection logic.
  Made code available on github.

1.0.3 (2016-07-12):
  The HCG can now be connected to circuits.
  Slight tweaks to the localization.
  Crank delay is now per generator.

1.0.2 (2016-07-12):
  Fixed wrong version in info.json

1.0.1 (2016-07-12):
  Updated some comments. No actual code changes.

1.0.0 (2016-07-12): 
  Initial feature complete totally bugfree release. YARLY.

# Config capabilities

run_time_in_seconds           = 300   --how long it runs when fully cranked
run_time_per_crank_in_seconds = 10
crank_delay_in_ticks          = 20    --how often you can crank it
power_output_in_watts         = 20000
start_with_item_in_quickbar   = true  --if it should be in the quickbar or inventory
can_pick_up                   = false --if you want to move it again
game_speed                    = 1     --for people who don't play at default game.speed[/spoiler]
