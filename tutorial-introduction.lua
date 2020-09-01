
local Introduction = [[

  Welcome to the Hand Crank Generator look-at-a-real-mod tutorial!

  Hand Crank Generator is a fully functional mod that has extensive
  comments in the code to explain how and why it works.

  This tutorial assumes that you already know how LUA works and that
  you have have familiarized yourself with at least the basic concepts
  of Factorio modding. On that basis it aims to provide a rough overview
  on how real-life mods work. And shows you how to assemble the
  theoretical concepts you have learned so far into a working whole.

  If you want to give yourself a real challenge you can of course try to
  read this without any prior knowledge and try to learn on-the-go ;).
  
  Data stage covers most basic operations like creating new items,
  recipes, buildings and technologies. In addition control.lua explains how
  to make custom behavior for buildings - namely how to make the
  Hand Crank Generator produce power when the player presses a button.
  
  The recommended order of reading is
  
    First : settings.lua
    Second:     data.lua
    Third :  control.lua
    
    Bonus : migrations/2020-08-28_HCG_2.0.0.json
    
  That is also the order in which the game will load those files.
  (Except for the migration which is loaded shortly before control.lua.)
  

  Have fun!

  ]] -- this is just a very long string!
