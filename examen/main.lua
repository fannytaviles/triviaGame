-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )

display.setStatusBar( display.HiddenStatusBar )

local options = {
    effect = "fade",
    time = 800,
}

composer.gotoScene( "scenes.menu", options )