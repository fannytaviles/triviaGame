----------------------------------------------- Results

local composer = require("composer")
local audio = require("audio")
local score = require( "data.score" )

local game = composer.newScene()

----------------------------------------------- Variables

local backgroundLayer
local tapsEnabled
local gameOver, retry, homeButton
local backgroundMusicPlay, musicPop
local currentResultValue, bestScoreValue

----------------------------------------------- Constants

local RESULTS_BACKGROUND_SIZE = display.viewableContentHeight * 0.55
local BACKGROUND_RESULTS = {102/255, 0/255, 102/255}
local SIZE_FONT = 30
local FONT_NAME_TEXT = "Myriad Pro Bold"
local FONT_NAME_RESULTS = "Myriad Pro"
local CORNER_RADIOUS_RESULTS = 15
local BACKGROUND_COLOR = {32/255, 32/255, 32/255} 
local STROKE_WIDTH_RESULTS = 7

----------------------------------------------- Functions

local function onRetryTapped(event)

    if tapsEnabled then
        audio.stop(backgroundMusicPlay)
        local musicPopPlay = audio.play(musicPop, {channel = 2})
        tapsEnabled = false
        local options = 
        {
            effect = "fade",
            time = 800,
        }
        composer.gotoScene("scenes.game", options)
    end

end


local function onHomeButtonTapped(event)

    if tapsEnabled then
        local musicPopPlay = audio.play(musicPop, {channel = 2})
        audio.stop(backgroundMusicPlay)
        tapsEnabled = false
        local options = {
            effect = "fade",
            time = 800,
        }
        composer.gotoScene("scenes.menu", options)
    end

end


local function buttonsTransitions()

    gameOver.alpha = 0
    transition.to(gameOver, {time=1000, delay = 700, alpha = 1})

    retry.alpha = 0
    transition.to(retry, {time=1000, delay = 700, alpha = 1})

    homeButton.alpha = 0
    transition.to(homeButton, {time=1000, delay = 700, alpha = 1})

end


local function initialize(event)

    currentResultValue.text = score.get() or 0
    bestScoreValue.text = score.load() or score.get()
    tapsEnabled = true
    local backgroundMusic = audio.loadStream( "sounds/background.m4r" )
    backgroundMusicPlay = audio.play(backgroundMusic, {channel = 3, loops = -1, fadein = 2000})
    musicPop = audio.loadStream("sounds/pop.mp3")

end

----------------------------------------------- Module functions

function game:create(event) 

    local sceneView = self.view

    backgroundLayer = display.newGroup() 
    sceneView:insert(backgroundLayer)

    local resultsGroup = display.newGroup( )
    sceneView:insert(resultsGroup)

    local background = display.newRect( display.contentCenterX, display.contentCenterY, display.viewableContentWidth, display.viewableContentHeight )
    background:setFillColor( unpack (BACKGROUND_COLOR))
    backgroundLayer:insert(background)

    gameOver = display.newImage( "images/gameOver.png" )
    gameOver.x = display.contentCenterX
    gameOver.y = display.viewableContentHeight * 0.125
    backgroundLayer:insert(gameOver)

    retry = display.newImage( "images/replay.png" )
    retry:scale(0.2, 0.2)
    retry.x = display.contentCenterX + (RESULTS_BACKGROUND_SIZE * 0.25)
    retry.y = display.viewableContentHeight * 0.9
    retry:addEventListener( "tap", onRetryTapped )
    backgroundLayer:insert(retry)

    homeButton = display.newImage("images/homeButton.png")
    homeButton:scale(0.2, 0.2)
    homeButton.x = display.contentCenterX - (RESULTS_BACKGROUND_SIZE * 0.25)
    homeButton.y = display.viewableContentHeight * 0.9
    homeButton:addEventListener( "tap", onHomeButtonTapped )
    backgroundLayer:insert(homeButton)

    resultsGroup.x = display.contentCenterX
    resultsGroup.y =  display.contentCenterY

    local resultsBackground = display.newRoundedRect( 0, 0, RESULTS_BACKGROUND_SIZE, RESULTS_BACKGROUND_SIZE, CORNER_RADIOUS_RESULTS )
    resultsBackground:setFillColor( unpack( BACKGROUND_RESULTS) )
    resultsBackground.strokeWidth = STROKE_WIDTH_RESULTS
    resultsGroup:insert(resultsBackground)

    local currentResultOptions = {
        text = "TU PUNTUACIÓN:",
        x = 0,
        y = -(RESULTS_BACKGROUND_SIZE * 0.3),
        width = RESULTS_BACKGROUND_SIZE * 0.75,
        font = FONT_NAME_TEXT,
        fontSize = SIZE_FONT,
        align = "center"
    }
    local currentResultText = display.newText( currentResultOptions )

    local currentResultValueOptions = {
        text = "",
        x = 0,
        y = -(RESULTS_BACKGROUND_SIZE * 0.1),
        width = RESULTS_BACKGROUND_SIZE * 0.75,
        font = FONT_NAME_RESULTS,
        fontSize = SIZE_FONT * 3,
        align = "center"
    }
    currentResultValue = display.newText( currentResultValueOptions)

    local bestScoreOptions = {
        text = "MEJOR PUNTUACIÓN:",
        x = 0,
        y = RESULTS_BACKGROUND_SIZE * 0.1,
        width = RESULTS_BACKGROUND_SIZE * 0.75,
        font = FONT_NAME_TEXT,
        fontSize = SIZE_FONT,
        align = "center"
    }
    local bestScoreText = display.newText( bestScoreOptions )

    local bestScoreValueOptions = {
        text = "",
        x = 0,
        y = (RESULTS_BACKGROUND_SIZE * 0.3),
        width = RESULTS_BACKGROUND_SIZE * 0.75,
        font = FONT_NAME_RESULTS,
        fontSize = SIZE_FONT * 3,
        align = "center"
    }
    bestScoreValue = display.newText( bestScoreValueOptions )

    resultsGroup:insert(currentResultText)
    resultsGroup:insert(currentResultValue)
    resultsGroup:insert(bestScoreText)
    resultsGroup:insert(bestScoreValue)

end


function game:destroy() 
	
end


function game:show( event ) 

    local sceneView = self.view
    local phase = event.phase

    if phase == "will" then 
        initialize(event)
        buttonsTransitions() 
    elseif phase == "did" then 

    end

end

function game:hide( event )

    local sceneView = self.view
    local phase = event.phase

    if phase == "will" then 

    elseif phase == "did" then 

    end

end

----------------------------------------------- Execution

game:addEventListener( "create" )
game:addEventListener( "destroy" )
game:addEventListener( "hide" )
game:addEventListener( "show" )

return game
