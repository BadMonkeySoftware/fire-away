--
-- Import
local display       = require('display')
local composer      = require('composer')
local widget        = require('widget')
local system        = require('system')
local timer        = require('timer')
local easing        = require('easing')
local animation        = require('plugin.animation')
local relayout      = require('libs.relayout')
local sounds        = require('libs.sounds')
local utilities     = require('classes.utilities')
local ui            = require('classes.ui')
local gameOptions   = require('classes.game_options')
local databox       = require('libs.databox') -- Persistant storage, track level completion and settings

-- 
-- Set variables

-- Layout
local _ContentWidth, _ContentHeight, _CenterX, _CenterY = relayout._W, relayout._H, relayout._CX, relayout._CY

-- Scene
local scene = composer.newScene()

-- Groups
local _groupMain 

--
-- Local functions


--
-- Scene events functions
function scene:create( event )
    print("scene: create - tutorial")
    -- _groupMain = display.newGroup()
    -- self.view:insert(_groupMain)
    local group = self.view
    local platform 		= string.lower(system.getInfo("platform"))

    local safeArea = display.newRect(
        display.safeScreenOriginX,
        display.safeScreenOriginY,
        display.safeActualContentWidth,
        display.safeActualContentHeight
    )
    safeArea.strokeWidth = 1
    safeArea:setFillColor(1,1,1,0)
    safeArea:translate( safeArea.width*0.5, safeArea.height*0.5 )
    local colorTable = {}
    for i, v in ipairs(gameOptions.colors) do
        if v.name == databox.colorTheme then
            colorTable = gameOptions.colors[i].colors
        end
    end
    colorTable = gameOptions.colors[1].colors
    self.screens = {}
    self.currentScreenNumber = 1
    -- background
    local background = display.newRect(group,display.contentCenterX,display.contentCenterY,_ContentWidth,_ContentHeight );
    background:setFillColor(unpack(utilities:hex2rgb(colorTable[1], 1)) )
    local color = 
    {
        highlight = { r=.27, g=.27, b=.27 },
        shadow = utilities:hex2rgb("#000")
    }
    local boxWidth = display.safeActualContentWidth * .9
    local boxHeight = _ContentHeight / 2
    local boxX = display.contentCenterX
    local boxY = display.contentCenterY - 25
    local uiGroup = display.newGroup()
    group:insert(uiGroup)
    local tutorial1 = display.newGroup()
    tutorial1.name = '1'
    table.insert(self.screens,tutorial1)
    group:insert(tutorial1)
    local tutorial1Title = display.newText({parent=tutorial1, text="Click anywhere to fire through the gaps", x=display.contentCenterX, y=display.safeScreenOriginY + 25, font=ui.fonts.dinPro, fontSize=20, width=200,align="center"})
    tutorial1Title:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
    tutorial1Title:toFront()
    local tutorial1Background = display.newRect(tutorial1, boxX, boxY, boxWidth, boxHeight)
    tutorial1Background:setFillColor(unpack(utilities:hex2rgb(colorTable[2], 1)) )
    tutorial1Background.strokeWidth = 1
    --gems
    --576x512
    local gemsIcon = display.newImageRect(uiGroup, ui.icons.gem, 15, 13.33)
    -- 16.457142857142857
    gemsIcon.x = boxX - boxWidth / 2 + 10
    gemsIcon.y = boxY - boxHeight / 2 + 10
    gemsIcon.anchorY = 0
    gemsIcon.anchorX = 0
    local gemsText = display.newText({parent=uiGroup, text="100", x=gemsIcon.x + 20 , y=gemsIcon.y -1, font = ui.fonts.dinPro, fontSize = 10 })
    gemsText.anchorX = 0
    gemsText.anchorY = 0
    -- hearts
    local heartIcon = display.newImageRect(uiGroup,ui.icons.heart, 15, 15)
    heartIcon.x = gemsIcon.x
    heartIcon.y = gemsIcon.y + 20
    heartIcon.anchorY = 0
    heartIcon.anchorX = 0
    local heartsText = display.newText({parent=uiGroup, text="5", x=heartIcon.x + 20 , y=heartIcon.y, font = ui.fonts.dinPro, fontSize = 10 })
    heartsText.anchorX = 0
    heartsText.anchorY = 0
    -- score
    local scoreLabel = display.newText({parent=uiGroup, text="0", x=boxX , y=boxY - boxHeight / 2 + 25, font = ui.fonts.dinPro, fontSize = 17 });
    --pause icon
    local pauseIcon = display.newImageRect(uiGroup,ui.buttons.pause,20, 20)
    pauseIcon.x = boxWidth - 20
    pauseIcon.y = boxY - boxHeight / 2 + 20
    -- rings
    local mainRing = display.newImageRect(uiGroup,"assets/game/square-2-slots.png",100,100)
    mainRing.x = boxX
    mainRing.y = boxY
    mainRing.rotation = 20
    local circleRing1 = display.newImageRect(uiGroup,"assets/game/circle-2-CShape.png",100,100)
    circleRing1.x = boxX
    circleRing1.y = boxY
    local circleRing2 = display.newImageRect(uiGroup,"assets/game/circle-2-Halves.png",100,100)
    circleRing2.x = boxX
    circleRing2.y = boxY
    local circleRing3 = display.newImageRect(uiGroup,"assets/game/circle-4-cross.png",100,100)
    circleRing3.x = boxX
    circleRing3.y = boxY
    circleRing1.alpha = 0
    circleRing2.alpha = 0
    circleRing3.alpha = 0

    -- ballshooter
    local cannon = display.newImageRect(uiGroup,ui.game.shooter,30,30)
    cannon.x = boxX
    cannon.y = boxY
    cannon.rotation = 20
    
    local vertices = { 0,-10, 30,-10, 30,-20, 50,0, 30,20, 30,10, 0,10 }
    

    function tutorial1:DoAnimation()
        print("Hello there")
        mainRing.rotation = 20
        cannon.rotation = 20
        local ball = display.newImageRect(tutorial1,ui.game.ball, 10, 10)
        ball.x, ball.y = boxX, boxY

        local w, h = display.contentWidth, display.contentHeight
        
        local cr = 500  -- Set a constant rate for movement (pixels per second)
        animation.to( ball, { x=display.contentCenterX + 50, y  = boxY - boxHeight / 2 + 5 }, {delay=500, time=1250, iterations=0, onCancel=function() 
            ball:removeSelf()
        end, onRepeat=function()
            ball.alpha = 0
            animation.pause(ball)
            scoreLabel.text = "1"
            timer.performWithDelay(750,function() 
                ball.alpha = 1
                ball.x, ball.y = boxX, boxY
                animation.resume(ball) 
                scoreLabel.text = "0"
            end,1);
        end} )

    end

    local tutorial2 = display.newGroup()
    tutorial2.name = '2'
    table.insert(self.screens,tutorial2)
    group:insert(tutorial2)
    local tutorial2Title = display.newText({parent=tutorial2, text="Don't hit the ring, or you will lose a life!", x=display.contentCenterX, y=display.safeScreenOriginY + 25, font=ui.fonts.mainFont, fontSize=20, width=200,align="center"})
    tutorial2Title:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
    local tutorial2Background = display.newRect(tutorial2, boxX, boxY, boxWidth, boxHeight)
    tutorial2Background:setFillColor(unpack(utilities:hex2rgb(colorTable[2], 1)) )
    tutorial2Background.strokeWidth = 1
    function tutorial2:DoAnimation()
        print("Doing 2nd Tutorial")
        scoreLabel.text = "1"
        mainRing.rotation = 50
        cannon.rotation = -40
        local ball = display.newImageRect(tutorial2, ui.game.ball, 10, 10)
        ball.x, ball.y = boxX, boxY
        -- transition.to(heartIcon,{xScale=2.0, yScale=2.0, time=1000, delay=1000, iterations=0, onRepeat=function ()
        --     transition.pause(heartIcon)
        --     timer.performWithDelay(2000,function ()
        --         transition.resume(heartIcon)
        --     end)
        -- end})
        animation.to( ball, { x=boxX - 30, y  = boxY - 30 }, {delay=500, time=500, iterations=0, onCancel=function() 
            print("2ndTutorial: Ball Cancel")
            ball:removeSelf()
        end, onRepeat=function()
            ball.alpha = 0
            heartsText.text = "4"
            animation.pause(ball)
            animation.to(heartIcon, {xScale=2.0, yScale=2.0}, {time=1000, iterations = 1,easing = easing.continuousLoop, onCancel = function ()
                print("2ndTutorial: HeartIcon Cancel")
                heartIcon.xScale = 1
                heartIcon.yScale = 1
            end, onComplete=function ()
                ball.x, ball.y = boxX, boxY
                ball.alpha = 1
                animation.resume(ball) 
                -- scoreLabel.text = "0"
            end})
            animation.to(heartsText, {x=heartsText.x + 10,xScale=2.0, yScale=2.0}, {time=1000, iterations = 1,easing = easing.continuousLoop, onCancel = function ()
                print("2ndTutorial: HeartText Cancel")
                heartsText.xScale = 1
                heartsText.yScale = 1
                heartsText.x = heartIcon.x + 20
                heartsText.text = "5"
            end, onComplete=function ()
                heartsText.text = "5"
                -- scoreLabel.text = "0"
            end})
            -- transition.scaleBy(heartIcon,{delay=500, x=1.0, yScale=1.0, time=500, iterations=1})
            -- scoreLabel.text = "1"
            -- timer.performWithDelay(3000,function() 
            --     ball.alpha = 1
            --     ball.x, ball.y = boxX, boxY
            --     animation.resume(ball) 
            --     scoreLabel.text = "0"
            -- end,1);
        end} )
    end
    local tutorial3 = display.newGroup()
    tutorial3.name = '3'
    table.insert(self.screens,tutorial3)
    group:insert(tutorial3)
    local tutorial3Title = display.newText({parent=tutorial3, text="Every 5 successful shots, the rings change and spin faster", x=display.contentCenterX, y=display.safeScreenOriginY + 25, font=ui.fonts.mainFont, fontSize=20, width=300,align="center"})
    tutorial3Title:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
    local tutorial3Background = display.newRect(tutorial3, boxX, boxY, boxWidth, boxHeight)
    tutorial3Background:setFillColor(unpack(utilities:hex2rgb(colorTable[4], 1)) )
    tutorial3Background.strokeWidth = 1
    function tutorial3:DoAnimation()
        print("Doing 3rd Animation")
        pauseIcon.alpha = 1
        heartsText.alpha = 1
        heartIcon.alpha = 1
        mainRing.alpha = 1
        cannon.alpha = 1
        scoreLabel.alpha = 1
        circleRing1.alpha = 0
        circleRing2.alpha = 0
        circleRing3.alpha = 0
        animation.to( mainRing, { alpha = 0 }, {delay=0, time=1000, iterations=0, onCancel=function() 
            mainRing.alpha = 1
        end, onRepeat=function()
            animation.pause(mainRing)
            animation.to( circleRing1, { alpha = 1 }, {delay=0, time=1000, onCancel=function() 
                circleRing1.alpha = 0
            end, onComplete=function()
                circleRing1.alpha = 0
                animation.to( circleRing2, { alpha = 1 }, {delay=0, time=1000, onCancel=function() 
                    circleRing2.alpha = 0
                end, onComplete=function()
                    circleRing2.alpha = 0
                    animation.to( circleRing3, { alpha = 1 }, {delay=0, time=1000, onCancel=function() 
                        circleRing3.alpha = 0
                    end, onComplete=function()
                        circleRing3.alpha = 0
                        mainRing.alpha = 1
                        animation.resume(mainRing)
                    end})
                end})
            end})
        end})

    end

    local tutorial4 = display.newGroup()
    tutorial4.name = '4'
    table.insert(self.screens,tutorial4)
    group:insert(tutorial4)
    -- local tutorial4Title = display.newText({parent=tutorial4, text="If you lose all 5 lives, you get a chance for 1 more life by watching a video or by spending 10 gems.", x=display.contentCenterX, y=display.safeScreenOriginY + 50, font=ui.fonts.mainFont, fontSize=20, width=300,align="center"})
    local tutorial4Title = display.newText({parent=tutorial4, text="If you lose all 5 lives, you get a chance for 1 more life by spending 10 gems.", x=display.contentCenterX, y=display.safeScreenOriginY + 50, font=ui.fonts.mainFont, fontSize=20, width=300,align="center"})
    tutorial4Title:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
    local tutorial4Background = display.newRect(tutorial4, boxX, boxY, boxWidth, boxHeight)
    tutorial4Background:setFillColor(unpack(utilities:hex2rgb(colorTable[1], 1)) )
    tutorial4Background.strokeWidth = 1
    function tutorial4:DoAnimation()
        print("Doing 4th Animation")
        -- hide the hearts
        heartsText.alpha = 0
        heartIcon.alpha = 0
        -- hide the score
        scoreLabel.alpha = 0
        mainRing.alpha = 0
        cannon.alpha = 0
        -- hide the pause button
        pauseIcon.alpha = 0
        -- insert title
        -- title
        local title = display.newEmbossedText({parent=tutorial4, text="GAME OVER", x=display.contentCenterX, y=gemsIcon.y + 25, font=ui.fonts.mainFont, fontSize=30,align="center"})
        title.anchorY = 0
        title:setFillColor(unpack(utilities:hex2rgb(colorTable[4])))
        -- scores
        local scoreLabel = display.newEmbossedText({parent=tutorial4, text="SCORE : ", x=display.contentCenterX, y=title.y + 70, font=ui.fonts.dinPro, fontSize=15,align="center"})
        scoreLabel.anchorX = 1
        scoreLabel:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
        scoreLabel:setEmbossColor( color )
        local scoreText = display.newEmbossedText({parent=tutorial4, text="10", x=display.contentCenterX, y=scoreLabel.y, font=ui.fonts.dinPro, fontSize=15,align="center"})
        scoreText.anchorX = 0
        scoreText:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
        scoreText:setEmbossColor( color )
        local bestScoreLabel = display.newEmbossedText({parent=tutorial4, text="BEST : ", x=display.contentCenterX, y=scoreLabel.y + 30, font=ui.fonts.dinPro, fontSize=15,align="center"})
        bestScoreLabel.anchorX = 1
        bestScoreLabel:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
        bestScoreLabel:setEmbossColor( color )
        local bestScoreText = display.newEmbossedText({parent=tutorial4, text="25", x=display.contentCenterX, y=bestScoreLabel.y, font=ui.fonts.dinPro, fontSize=15,align="center"})
        bestScoreText.anchorX = 0
        bestScoreText:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
        bestScoreText:setEmbossColor( color )
        -- "1" more life
        local rescueLabel = display.newEmbossedText({parent=tutorial4, text="One More Life:", x=display.contentCenterX, y=bestScoreLabel.y + 30, font=ui.fonts.dinPro, fontSize=17,align="center"})
        -- video button
        -- local videoButton = widget.newButton({
        --     shape="rect",
        --     label="FREE: Watch Video Ad",
        --     labelAlign = "center",
        --     labelColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#FFFFFF", 1) },
        --     font= ui.fonts.dinPro,
        --     fontSize = 15,
        --     fillColor = { default=utilities:hex2rgb(colorTable[1], 1), over=utilities:hex2rgb(colorTable[1], 1) },
        --     strokeWidth = 2,
        --     strokeColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#FFFFFF", 1) },
        --     width=175, height = 40,
        --     x = display.contentCenterX, y = rescueLabel.y + 50,
        --     isEnabled = false
        -- })
        -- tutorial4:insert(videoButton)
        -- spend button
        local rescueButton = widget.newButton({
            shape="rect",
            label="Spend 10 Gems",
            labelAlign = "center",
            labelColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#FFFFFF", 1) },
            font= ui.fonts.dinPro,
            fontSize = 15,
            fillColor = { default=utilities:hex2rgb(colorTable[1], 1), over=utilities:hex2rgb(colorTable[1], 1) },
            strokeWidth = 2,
            strokeColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#FFFFFF", 1) },
            width=175, height = 40,
            -- x = display.contentCenterX, y = videoButton.y + 50,
            x = display.contentCenterX, y = rescueLabel.y + 50,
            isEnabled = false
        })
        tutorial4:insert(rescueButton)

        -- local arrow1 = display.newPolygon( 0, videoButton.y, vertices )
        -- arrow1.anchorX = 1
        -- tutorial4:insert(arrow1)
        local arrow2 = display.newPolygon(tutorial4, 0, rescueButton.y, vertices )
        arrow2.anchorX = 1
        -- animation.to(arrow1,{ x = videoButton.x - videoButton.width / 2 }, {delay=0, time=2000, iterations=-1, easing = easing.inOutElastic, onCancel=function() 
        -- end, onRepeat=function ()
        --     animation.pause(arrow1)
        --     animation.to(arrow2,{ x = rescueButton.x - rescueButton.width / 2 }, {delay=0, time=2000, easing = easing.inOutElastic, onCancel=function() 
        --         -- arrow2:removeSelf()
        --     end, onComplete=function ()
        --         animation.resume(arrow1)
        --         arrow2.x = 0
        --     end})            
        -- end})
        animation.to(arrow2,{ x = rescueButton.x - rescueButton.width / 2 }, {delay=0, time=2000, iterations=-1, easing = easing.inOutElastic, onCancel=function() 
        end, onRepeat=function ()
            -- animation.pause(arrow2)

            -- timer.performWithDelay(750,function() 
            --     animation.resume(arrow2)
            -- end)
        end})
        -- home / Restart buttons
    end
    
    -- local tutorial5 = display.newGroup()
    -- tutorial5.name = '5'
    -- table.insert(self.screens,tutorial5)
    -- group:insert(tutorial5)
    -- local tutorial5Title = display.newText({parent=tutorial5, text="You can buy more gems from the store, or you can watch a free video once every 15 minutes", x=display.contentCenterX, y=display.safeScreenOriginY + 50, font=ui.fonts.mainFont, fontSize=20, width=300,align="center"})
    -- tutorial5Title:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
    -- local tutorial5Background = display.newRect(tutorial5, boxX, boxY, boxWidth, boxHeight)
    -- tutorial5Background:setFillColor(unpack(utilities:hex2rgb(colorTable[5], 1)) )
    -- tutorial5Background.strokeWidth = 1
    -- function tutorial5:DoAnimation()
    --     print("Doing 5th Animation")
    -- end
    
    -- tutorial1.alpha = 0
    -- tutorial2.alpha = 0
    -- tutorial3.alpha = 0
    -- tutorial4.alpha = 0
    -- tutorial5.alpha = 1

    self.goBackButton = widget.newButton({
        x = _ContentWidth - 35 + display.screenOriginX, y = _ContentHeight * .9 + display.safeScreenOriginY,
        width = 50, height = 50,
        defaultFile = ui.buttons.goBack,
        overFile = ui.buttons.goBackOver,
        onRelease = function()
            print("Goto Next Tutorial")
            sounds.play("tap")
            composer.gotoScene("scenes.about",{time = 500, effect = 'slideLeft'});
        end
    })
    group:insert(self.goBackButton)

    -- previous button
    self.previousButton = widget.newButton({
        x = 35 + display.screenOriginX, y = self.goBackButton.y - 70,
        width = 50, height = 50,
        defaultFile = ui.buttons.leftArrow,
        overFile = ui.buttons.leftArrowOver,
        onRelease = function()
            print("Goto Previous Tutorial")
            sounds.play("tap")
            self.currentScreenNumber = self.currentScreenNumber - 1
            scene:ShowHideScreens()
            -- composer.gotoScene("scenes.menu",{time = 500, effect = 'slideLeft'});
        end
    })
    group:insert(self.previousButton)

    self.nextButton = widget.newButton({
        x = _ContentWidth  - 35 + display.screenOriginX, y = self.goBackButton.y - 70,
        width = 50, height = 50,
        defaultFile = ui.buttons.rightArrow,
        overFile = ui.buttons.rightArrowOver,
        onRelease = function()
            print("Goto Next Tutorial")
            sounds.play("tap")
            self.currentScreenNumber = self.currentScreenNumber + 1
            scene:ShowHideScreens()
            -- composer.gotoScene("scenes.menu",{time = 500, effect = 'slideLeft'});
        end
    })
    group:insert(self.nextButton)

    scene:ShowHideScreens()
    uiGroup:toFront()
    group:insert(safeArea)
    safeArea.alpha = 0
end
function scene:ShowHideScreens()
    if self.currentScreenNumber == 1 then
        self.previousButton.alpha = 0
        self.nextButton.alpha = 1
        self.goBackButton.alpha = 0
    elseif self.currentScreenNumber == #self.screens then
        self.previousButton.alpha = 1
        self.nextButton.alpha = 0
        self.goBackButton.alpha = 1
    else
        self.previousButton.alpha = 1
        self.nextButton.alpha = 1
        self.goBackButton.alpha = 0
    end
    animation.cancel()
    for i,v in ipairs(self.screens) do
        -- print("Screen: " .. v.name)
        animation.cancel(v)
        if i == self.currentScreenNumber then
            v.alpha = 1
            v:DoAnimation()
        else
            v.alpha = 0
        end
    end
end
function scene:show( event )
    if ( event.phase == "will") then
    elseif ( event.phase == "did" ) then 
    end
      
end

function scene:hide( event )
    if ( event.phase == "will") then
    elseif ( event.phase == "did" ) then 
    end
      
end

function scene:destroy( event )
    if ( event.phase == "will") then
        animation.cancel()
    elseif ( event.phase == "did" ) then 
    end
      
end

--
-- Scene event listeners
scene:addEventListener( "create", scene)
scene:addEventListener( "show", scene)
scene:addEventListener( "hide", scene)
scene:addEventListener( "destroy", scene)

return scene