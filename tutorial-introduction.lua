
local Introduction = [[

  Welcome to the Inspecting-a-live-mod tutorial!

  In this tutorial I will take you on an annotated tour of my mod
  "Eradicator's Hand Crank Generator Deluxe". That's a rather long
  name so I'll often call it just HCG hereafter.
  
  Hand Crank Generator is a fully functional mod that you can
  download and play with right now! It has extensive comments in
  the code to explain how and why it works.

  This tutorial assumes that you already know how LUA works and that
  you have have familiarized yourself with at least the basic concepts
  of Factorio modding. On that basis it aims to provide a rough overview
  on how real-life mods work. And shows you how to assemble the
  theoretical concepts you have learned so far into a working whole.

  If you want to give yourself a real challenge you can of course try to
  read this without any prior knowledge and try to learn on-the-go ;).
  
  First settings.lua shows creation of some basic setting prototypes.
  Then data.lua covers most basic operations like creating new item,
  recipe, building and technology prototypes. And how to interact with 
  prototypes of other mods. Finally in control.lua I explain how
  to make custom behavior for buildings - namely how to make the
  Hand Crank Generator produce power when the player presses a key
  on the keyboard.
  
  You can read the files on the web on GitHub or download and extract
  the mod locally to your harddrive.
  
  I recommend reading in the order that the files are loaded by the game. Have fun!
  
    Chapter 1     : settings.lua
    Chapter 2     : data.lua
    Bonus Chapter : migrations/2020-08-28_HCG_2.0.0.json
    Chapter 3     : control.lua

  HCG is available in full on GitHub or on the Factorio Mod Portal.

  Have fun!

  ]] -- this is just a very long string!
