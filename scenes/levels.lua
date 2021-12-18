--
-- Import
local display       = require('display')
local composer      = require('composer')
local native        = require('native')
local system        = require('system')
local widget        = require('widget')
local transition    = require('transition')
-- local gameNetwork   = require("gameNetwork")
local gameCenter    = require("classes.helper_gamecenter")
local relayout      = require('libs.relayout')
local sounds        = require('libs.sounds')
local utilities     = require('classes.utilities')
local ui            = require('classes.ui')
local gameOptions   = require('classes.game_options')
local databox       = require('libs.databox') -- Persistant storage, track level completion and settings
local storeUI       = require('libs.storeUI')


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
    print("scene: create - levels")
    -- _groupMain = display.newGroup()
    -- self.view:insert(_groupMain)
    local group = self.view
    local safeArea = display.newRect(
        display.safeScreenOriginX,
        display.safeScreenOriginY,
        display.safeActualContentWidth,
        display.safeActualContentHeight
    )
    safeArea.strokeWidth = 1
    safeArea:setFillColor(1,1,1,0)
    safeArea:translate( safeArea.width*0.5, safeArea.height*0.5 )
    print("safeArea=> w: " .. safeArea.width .. "   h: " .. safeArea.height)
    local colorTable = {}
    for i, v in ipairs(gameOptions.colors) do
        if v.name == databox.colorTheme then
            colorTable = gameOptions.colors[i].colors
        end
    end
    -- background
    local background = display.newRect(group,display.contentCenterX,display.contentCenterY,_ContentWidth,_ContentHeight );
    background:setFillColor(unpack(utilities:hex2rgb(colorTable[5], 1)) )
    -- top UI
    -- local gemsIcon = display.newImageRect(group, ui.icons.gem, 35, 31)
    -- -- 16.457142857142857
    -- gemsIcon.x = 20
    -- gemsIcon.y = 10 + display.safeScreenOriginY
    -- gemsIcon.anchorY = 0
    -- gemsIcon.anchorX = 0
    -- local gemsText = display.newText({parent=group, text="" .. databox.gems, x=gemsIcon.x + 40 , y=gemsIcon.y-3, font = ui.fonts.dinPro, fontSize = 25 })
    -- gemsText.anchorX = 0
    -- gemsText.anchorY = 0

    -- title
    local title = display.newEmbossedText({parent=group, text="LEVELS", x=display.contentCenterX, y=storeUI.gemsIcon.y + 50, font=ui.fonts.mainFont, fontSize=50,align="center"})
    title.anchorY = 0
    title:setFillColor(unpack(utilities:hex2rgb(colorTable[4])))
    local color = 
    {
        highlight = { r=.27, g=.27, b=.27 },
        shadow = utilities:hex2rgb("#000")
    }
    title:setEmbossColor( color )

    local bestLabel = display.newText({parent=group, text="BEST ", align="right", width=250, font= ui.fonts.dinPro, fontSize = 20, x=display.contentCenterX, y= title.y + 105})
    -- Levels button list
    local bestBasicScore = databox.BasicRingsHighScore or 0
    local basicRingsButton = widget.newButton({
        shape="rect",
        label="Basic Rings",
        labelAlign = "left",
        labelColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#A2A2A2", 1) },
        font= ui.fonts.dinPro,
        fontSize = 20,
        fillColor = { default=utilities:hex2rgb(colorTable[5], 1), over=utilities:hex2rgb(colorTable[5], .75) },
        strokeWidth = 2,
        strokeColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#A2A2A2", .75) },
        width=250, height = 50,
        x=display.contentCenterX, y=title.y + 150,
        onRelease = function()
            sounds.play("tap")
            composer.gotoScene('scenes.reload_game', {params = {level = "BasicRings"}})
        end
    })
    -- basicRingsButton.anchorChildren = true
    group:insert(basicRingsButton)
    local basicBestScoreLabel = display.newText({ parent=basicRingsButton, x=120, y=35,text="" .. bestBasicScore, align="right", width=250, height=50, font= ui.fonts.dinPro, fontSize = 20 })
    -- bestLabel.andhorY=0
    -- bestLabel.andhorX=0
    -- basicRingsButton:insert(bestLabel)

    local bestAdvancedScore = databox.AdvancedRingsHighScore or 0
    local advancedRingsButton = widget.newButton({
        shape="rect",
        label="Advanced Rings",
        labelAlign = "left",
        labelColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#A2A2A2", 1) },
        font= ui.fonts.dinPro,
        fontSize = 20,
        fillColor = { default=utilities:hex2rgb(colorTable[5], 1), over=utilities:hex2rgb(colorTable[5], .75) },
        strokeWidth = 2,
        strokeColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#A2A2A2", .75) },
        width=250, height = 50,
        x=display.contentCenterX, y=basicRingsButton.y + 60,
        onRelease = function()
            sounds.play("tap")
            composer.gotoScene('scenes.reload_game', {params = {level = "AdvancedRings"}})
        end
    })
    -- basicRingsButton.anchorChildren = true
    group:insert(advancedRingsButton)
    local advancedBestScoreLabel = display.newText({ parent=advancedRingsButton, x=120, y=35,text=""..bestAdvancedScore, align="right", width=250, height=50, font= ui.fonts.dinPro, fontSize = 20 })
    


    -- go back button
    local goBackButton = widget.newButton({
        x = _ContentWidth - 35 + display.screenOriginX, y = _ContentHeight * .9 + display.safeScreenOriginY,
        width = 50, height = 50,
        defaultFile = ui.buttons.goBack,
        overFile = ui.buttons.goBackOver,
        onRelease = function()
            print("Goto Main Menu")
            sounds.play("tap")
            composer.gotoScene("scenes.menu",{time = 500, effect = 'slideRight'});
        end
    })
    group:insert(goBackButton)

    -- move title to front
    title:toFront()
    -- show safe area at top
    group:insert(safeArea)
    safeArea.alpha = 0
    -- safeArea:toBack()
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