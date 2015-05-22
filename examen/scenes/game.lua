----------------------------------------------- Examen

local composer = require("composer")
local audio = require("audio")
local score = require( "data.score" )

local game = composer.newScene()

----------------------------------------------- Variables

local answersLayer, dynamicAnswersGroup
local backgroundLayer
local statusBarGroup, questionText
local selectQuestion, questionSelected
local imageOptions
local tapsEnabled
local answerGroup
local currentAnswer
local currentQuestion
local currentTime, timerCount, timerFunction
local questionGroup
local dragEnabled
local questionResult
local musicClic, musicPop

----------------------------------------------- Constants

local STATUS_BAR_HEIGHT = 60
local HEIGHT_QUESTION_BACKGROUND = 150
local WIDTH_QUESTION_BACKGROUND = display.viewableContentWidth * 0.75
local SIZE_FONT = 30
local FONT_NAME = "Myriad Pro"
local CORNER_RADIOUS_QUESTION = 15
local BACKGROUND_COLOR = {32/255, 32/255, 32/255} 
local STROKE_WIDTH_QUESTION = 7
local PURPLE_COLOR = {102/255, 0/255, 102/255}
local TOTAL_ANSWERS = 5

----------------------------------------------- Functions

local function onButtonTapped(event)

    if currentQuestion <= TOTAL_ANSWERS and tapsEnabled then
        tapsEnabled = false
        local musicPopPlay = audio.play(musicPop, {channel = 1, loops = 0 })
        local target = event.target
        target[2].alpha = 1
        transition.to(target[2], {time = 250, alpha = 0})

        if selectQuestion[questionSelected].answer == currentAnswer then
            transition.to(questionResult[1], {time = 500, alpha = 1, 
                onComplete = function(obj)
                        transition.to(obj, {time=250, alpha = 0})
                end
            })
            score.add(10)
        else
            transition.to(questionResult[2], {time = 250, alpha = 1, 
                onComplete = function(obj)
                    transition.to(obj, {time=250, alpha = 0})
                end
            })
        end

        table.remove(selectQuestion, questionSelected )

        if currentQuestion < TOTAL_ANSWERS then
            questionSelected = math.random(1, #selectQuestion)
            questionText.text = selectQuestion[questionSelected].question
            currentQuestion = currentQuestion + 1
            questionGroup.x = display.contentCenterX
            questionGroup.y = -(display.viewableContentHeight * 0.25)
            transition.to(questionGroup, {time = 600, y = display.viewableContentHeight * 0.25, 
                onComplete = function()
                    local musicClicPlay = audio.play(musicClic, {channel = 1, loops = 0 })
                    tapsEnabled = true
                end
            })
        else
            dragEnabled = false
            local highScore = score.load() or 0
            if score.get() > highScore then
                    score.save()
            end

            local options = {
                    effect = "fromBottom",
            time = 800,
            }
            composer.gotoScene("scenes.results", options)
        end
    end

end

local function onAnswerTouched(event)

    if dragEnabled then
        local phase = event.phase
        local target = event.target
        if target.tapsEnabled then
            if phase == "began" then
                transition.cancel(target)
                target:toFront( )
                target.x = event.x
                target.y = event.y
                target.onSlot = false
                if target.slot then
                    target.slot.isEmpty = true
                    target.slot = nil
                end
                display.getCurrentStage():setFocus( event.target )
                target.isMoving = true
            elseif phase == "moved" then
                if target.isMoving then
                    target.x = event.x
                    target.y = event.y		
                end
            elseif phase == "ended" then
                local musicPopPlay = audio.play(musicPop, {channel = 2, loops = 0 })
                local currentSlot = answerGroup
                if target.x < (currentSlot.x + currentSlot.contentWidth * 0.5) and
                    target.x > (currentSlot.x - currentSlot.contentWidth * 0.5) and
                    target.y < (currentSlot.y + currentSlot.contentHeight * 0.5) and
                    target.y > (currentSlot.y - currentSlot.contentHeight * 0.5) then
                        if currentSlot.isEmpty then 
                                currentAnswer = target.char
                                currentSlot.isEmpty = false
                                target.onSlot = true
                                target.slot = currentSlot
                        end
                end

                if currentSlot.isEmpty then
                    currentAnswer = ""
                    currentSlot.alpha = 0.5
                else
                    currentSlot.alpha = 0
                end

                if target.slot then
                    transition.to(target, {time = 200, x = target.slot.x, y = target.slot.y, xScale = 0.7, yScale = 0.7, 
                        onStart = function() 
                            target.tapsEnabled = false 
                        end, 
                        onComplete = function() 
                            target.tapsEnabled = true 
                        end})
                else
                    transition.to(target, {time = 500, x = target.initX, y = target.initY, xScale = 0.9, yScale = 0.9, 
                        onStart = function() 
                            target.tapsEnabled = false 
                        end,
                        onComplete = function() 
                            target.tapsEnabled = true 
                        end})
                end
                display.getCurrentStage():setFocus( nil )
            end
        end
    end
end


local function removeDynamicAnswers()

    display.remove(dynamicAnswersGroup) 
    dynamicAnswersGroup = nil
    timer.cancel(timerFunction)

end


local function onBackButtonTapped()

    local options = 
    {
            effect = "fromLeft",
            time = 800,
    }
    composer.gotoScene("scenes.menu", options)

end


local function countTime(event)

    currentTime = currentTime - 1
    timerCount.text = currentTime .. "”"

    if currentTime <= 0 then
        timer.cancel(timerFunction)
        local options = 
        {
                        effect = "fromBottom",
                time = 800,
        }
        composer.gotoScene( "scenes.results", options )
    end

end


local function createDynamicAnswers()

    dynamicAnswersGroup = display.newGroup() 
    answersLayer:insert(dynamicAnswersGroup) 

    timerFunction = timer.performWithDelay( 1000, countTime, 0 )

    questionGroup.x = display.contentCenterX
    questionGroup.y = -(display.viewableContentHeight * 0.25)
    transition.to(questionGroup, {time = 1500, y = display.viewableContentHeight * 0.25, 
        onComplete = function()
            local musicClicPlay = audio.play(musicClic, {channel = 1, loops = 0 })
            tapsEnabled = true
            dragEnabled = true
        end
    })

    local answerImage = display.newImage( "images/question.png" )
    answerImage:scale(0.35, 0.35)
    answerImage.x = display.contentCenterX
    answerImage.y = display.contentCenterY
    answerImage.alpha = 0
    answerImage.isEmpty = true
    answerGroup = answerImage
    dynamicAnswersGroup:insert(answerImage)
    transition.to(answerImage, {time = 1000, alpha = 0.5, delay = 500})

    local buttonGroup = display.newGroup( )
    buttonGroup.x = display.viewableContentWidth * 0.6125
    buttonGroup.y = display.viewableContentHeight * 0.6125
    buttonGroup.alpha = 0
    dynamicAnswersGroup:insert(buttonGroup)
    transition.to(buttonGroup, {time = 1000, alpha = 1, delay = 500})
    buttonGroup:addEventListener("tap", onButtonTapped)

    local buttonImageOff = display.newImage( "images/buttonOff.png" )
    buttonImageOff:scale( 0.125, 0.125 )
    buttonGroup:insert( buttonImageOff )

    local buttonImageOn = display.newImage( "images/buttonOn.png" )
    buttonImageOn:scale( 0.125, 0.125 )
    buttonImageOn.alpha = 0
    buttonGroup:insert( buttonImageOn )

    for indexAnswers = 1, TOTAL_ANSWERS do
        local optionsX = display.screenOriginX + (display.viewableContentWidth / (TOTAL_ANSWERS + 1)) * indexAnswers
        local optionsY = display.viewableContentHeight * 0.85
        local options = display.newImage( "images/" .. imageOptions[indexAnswers] .. ".png" )
        options:scale(0, 0)
        options.tapsEnabled = true
        options.y = optionsY
        options.x = optionsX
        options.initX = optionsX
        options.initY = optionsY
        options.onSlot = false
        options.char = imageOptions[indexAnswers]
        transition.to(options, {time = 500, delay = 100 * indexAnswers, xScale = 1.5, yScale = 1.5, 
            onComplete = function(obj)
                transition.to(obj, {time = 500, xScale = 0.5, yScale = 0.5,
                    onComplete = function(obj)
                        transition.to(obj, {time = 500, xScale = 0.9, yScale = 0.9})
                    end
                })
            end
        })
        options:addEventListener("touch", onAnswerTouched)
        dynamicAnswersGroup:insert(options)
    end

    local correctImage = display.newImage("images/correcto.png")
    correctImage.alpha = 0
    questionResult:insert(correctImage)

    local wrongImage = display.newImage("images/incorrecto.png")
    wrongImage.alpha = 0
    questionResult:insert(wrongImage)

end


local function initialize(event)
    selectQuestion = {
        {question = "¿Quién acaba de lanzar su primer libro llamado ELNET?", answer="nacho"},
        {question ="¿Quién tiene un blog llamado YO SOY VIERNES?", answer="nacho"},
        {question ="¿Quién cumple años el 6 de octubre?", answer="nacho"},
        {question ="¿Quién cumple años el 12 de febrero?", answer="cholo"},
        {question ="¿Quién cumple años el 26 de enero?", answer="pablo"},
        {question ="¿Quién tiene dos hijos llamados Roque y Mena?", answer="nacho"},
        {question ="¿Quién tiene una hija llamada Lucía?", answer="cholo"},
        {question ="¿Quién tiene una hija llamada Emma?", answer="sanchez"},
        {question ="¿Quién es el baterista de la banda?", answer="cesareo"},
        {question ="¿Quién toca el bajo en la banda?", answer="pablo"},
    }

    imageOptions = {
        [1] = "nacho",
        [2] = "sanchez",
        [3] = "cesareo",
        [4] = "pablo",
        [5] = "cholo"
    }

    currentQuestion = 1
    currentTime = 50
    timerCount.text = currentTime .. "”"
    currentAnswer = ""
    questionSelected = math.random(1, #selectQuestion)
    questionText.text = selectQuestion[questionSelected].question
    score.set(0)
    tapsEnabled = false
    dragEnabled = false
    musicClic = audio.loadStream("sounds/click.mp3")
    musicPop = audio.loadStream("sounds/pop.mp3")
    
end

----------------------------------------------- Module functions

function game:create(event) 

    local sceneView = self.view

    backgroundLayer = display.newGroup() 
    sceneView:insert(backgroundLayer)

    questionGroup = display.newGroup( )
    sceneView:insert(questionGroup)

    answersLayer = display.newGroup()
    sceneView:insert(answersLayer)

    statusBarGroup = display.newGroup()
    sceneView:insert(statusBarGroup)

    questionResult = display.newGroup( )
    sceneView:insert(questionResult)

    local background = display.newRect( display.contentCenterX, display.contentCenterY, display.viewableContentWidth, display.viewableContentHeight )
    background:setFillColor( unpack (BACKGROUND_COLOR))
    backgroundLayer:insert(background)

    local questionBackground = display.newRoundedRect( 0, 0, WIDTH_QUESTION_BACKGROUND, HEIGHT_QUESTION_BACKGROUND, CORNER_RADIOUS_QUESTION )
    questionBackground.strokeWidth = STROKE_WIDTH_QUESTION
    questionBackground:setStrokeColor( unpack( PURPLE_COLOR ) )
    questionBackground.alpha = 0.75
    questionGroup:insert(questionBackground)

    local questionOptions = {
        text = "",
        x = 0,
        y = 0,
        width = WIDTH_QUESTION_BACKGROUND * 0.75,
        font = FONT_NAME,
        fontSize = SIZE_FONT,
        align = "center"
    }
    questionText = display.newText(questionOptions)
    questionText:setFillColor( 0 )
    questionGroup:insert(questionText)

    local backgroundStatusBar = display.newRect(display.contentCenterX, 0, display.viewableContentWidth, STATUS_BAR_HEIGHT)
    backgroundStatusBar.anchorY = 0
    backgroundStatusBar:setFillColor( unpack( PURPLE_COLOR ) )
    statusBarGroup:insert(backgroundStatusBar)

    local backButton = display.newImage( "images/backButton.png")
    backButton:scale( 0.15, 0.15 )
    backButton.x = STATUS_BAR_HEIGHT
    backButton.y = STATUS_BAR_HEIGHT * 0.5
    backButton:addEventListener( "tap", onBackButtonTapped )
    statusBarGroup:insert(backButton)

    local scoreText = score.init({
       fontSize = SIZE_FONT * 1.5,
       font = FONT_NAME,
       x = display.contentCenterX,
       y = STATUS_BAR_HEIGHT * 0.5,
       maxDigits = 2,
       filename = "scorefile.txt",
    })
    statusBarGroup:insert(scoreText)

    timerCount = display.newText("", display.viewableContentWidth - STATUS_BAR_HEIGHT, STATUS_BAR_HEIGHT * 0.5, FONT_NAME, SIZE_FONT * 1.5)
    timerCount.anchorX = 1
    statusBarGroup:insert(timerCount)

    questionResult.x = display.contentCenterX
    questionResult.y = display.contentCenterY
    
end

function game:destroy() 
	
end


function game:show( event ) 
    local sceneView = self.view
    local phase = event.phase

    if phase == "will" then 
        initialize(event)
        createDynamicAnswers() 
    elseif phase == "did" then 

    end
end

function game:hide( event )
    local sceneView = self.view
    local phase = event.phase

    if phase == "will" then 

    elseif phase == "did" then 
        removeDynamicAnswers()
    end
end

----------------------------------------------- Execution
game:addEventListener( "create" )
game:addEventListener( "destroy" )
game:addEventListener( "hide" )
game:addEventListener( "show" )

return game
