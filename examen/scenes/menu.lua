----------------------------------------------- Menu

local composer = require("composer")
local audio = require("audio")

local game = composer.newScene()

----------------------------------------------- Variables

local buttonsLayer, playButtonGroup
local backgroundLayer
local tapsEnabled
local timerPlayButton, playButton
local backgroundMusicPlay
local musicPop

----------------------------------------------- Constants

local BACKGROUND_COLOR = {50/255, 50/255, 50/255} 

----------------------------------------------- Functions

local function removePlayButton()

    timer.cancel( timerPlayButton )
    display.remove(playButtonGroup) 
    playButtonGroup = nil

end


local function onPlayButtonTimer(event)

    transition.to(playButton, {time=1000, xScale = 0.2, yScale = 0.2, 
        onComplete = function(obj)
            transition.to(obj, {time=1000, xScale=0.15, yScale=0.15})
        end
    })

end


local function onPlayButtonTapped(event)

    if tapsEnabled then
        tapsEnabled = false
        local musicPopPlay = audio.play(musicPop, {channel = 2})
        audio.stop(backgroundMusicPlay)
        local options = 
        {
            effect = "fromRight",
            time = 800,
        }
        composer.gotoScene("scenes.game", options)
    end

end


local function createPlayButton()

    playButtonGroup = display.newGroup() 
    buttonsLayer:insert(playButtonGroup) 

    playButton = display.newImage( "images/play.png" )
    playButton:scale(0.15, 0.15)
    playButton.x = display.contentCenterX
    playButton.y = display.viewableContentHeight * 0.8
    playButton:addEventListener( "tap", onPlayButtonTapped )
    playButtonGroup:insert(playButton)

    transition.to(playButton, {time=1000, xScale = 0.2, yScale = 0.2, 
        onComplete = function(obj)
            transition.to(obj, {time=1000, xScale=0.15, yScale=0.15})
        end
    })
    timerPlayButton = timer.performWithDelay( 2000, onPlayButtonTimer, 0 )

end


local function initialize(event)

    local backgroundMusic = audio.loadStream( "sounds/background.m4r" )
    musicPop = audio.loadStream("sounds/pop.mp3")
    backgroundMusicPlay = audio.play(backgroundMusic, {channel = 1, loops = -1, fadein = 2000})
    tapsEnabled = true

end

----------------------------------------------- Module functions

function game:create(event) 

    local sceneView = self.view

    backgroundLayer = display.newGroup() 
    sceneView:insert(backgroundLayer)

    local background = display.newRect( display.contentCenterX, display.contentCenterY, display.viewableContentWidth, display.viewableContentHeight )
    background:setFillColor( unpack (BACKGROUND_COLOR))
    backgroundLayer:insert(background)

    local logoImage = display.newImage( "images/inicio.png" )
    logoImage.x = display.contentCenterX
    logoImage.y = display.viewableContentHeight * 0.35
    backgroundLayer:insert(logoImage)

    buttonsLayer = display.newGroup()
    sceneView:insert(buttonsLayer)

end


function game:destroy() 
	
end


function game:show( event ) 

    local sceneView = self.view
    local phase = event.phase

    if phase == "will" then 
        initialize(event)
        createPlayButton() 
    elseif phase == "did" then 

    end

end


function game:hide( event )

    local sceneView = self.view
    local phase = event.phase

    if phase == "will" then 

    elseif phase == "did" then 
        removePlayButton()
    end

end

----------------------------------------------- Execution
game:addEventListener( "create" )
game:addEventListener( "destroy" )
game:addEventListener( "hide" )
game:addEventListener( "show" )

return game
