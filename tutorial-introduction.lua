
local Introduction = [[

  Welcome to the Hand Crank Generator look-at-a-real-mod tutorial!
  
  Hand Crank Generator is a fully functional mod that has extensive
  comments in the code to explain how and why it works.
  
  This is not intended as a programming tutorial, so it does not
  explain how LUA works. You can either look that up somewhere else
  or try to learn on-the-go.

  The recommended order of reading is
  
    First : settings.lua
    Second: data.lua
    Third : control.lua
    
    Bonus : migrations/2020-08-28_HCG_2.0.0.json
    
  That is also the order in which the game will load those files.
  (Except for the migration which is loaded shortly before control.lua.)
  
  This tutorial mod covers most basic operations like creating new items,
  recipes, buildings and technologies. In addition control.lua explains how
  to make custom behavior for buildings - namely how to make the
  Hand Crank Generator produce power when the player presses a button.

  Have fun!

  ]] -- this is just a very long string!
