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

local storeUI = require( "libs.storeUI" )
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
    print("scene: create - menu")
    -- _groupMain = display.newGroup()
    -- self.view:insert(_groupMain)
    local group = self.view
    -- main screen
    -- width => 1080
    -- Height => 2080
    -- buttons at bottom
    -- w,h = 190
    -- main Play button
    -- w,h = 390
    -- Create a vector rectangle sized exactly to the "safe area"
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
    local background = display.newRect(group, display.contentCenterX,display.contentCenterY,_ContentWidth,_ContentHeight );
    background:setFillColor(unpack(utilities:hex2rgb(colorTable[1], 1)) )

    storeUI.initializeStoreMenu (databox.gems)
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
    -- print("Gems Y " .. gemsIcon.y)
    --50
    local fromTop = _ContentHeight * .1
    -- title
    local title = display.newEmbossedText({parent=group, text="FIRE AWAY", x=display.contentCenterX, y=storeUI.gemsIcon.y + 50, font=ui.fonts.mainFont, fontSize=50,align="center"})
    title.anchorY = 0
    title:setFillColor(unpack(utilities:hex2rgb(colorTable[4])))
    local color = 
    {
        highlight = { r=.27, g=.27, b=.27 },
        shadow = utilities:hex2rgb("#000")
    }
    title:setEmbossColor( color )
    local playButton = widget.newButton({
        x = display.contentCenterX, y = display.contentCenterY,
        width = 125, height = 125,
        defaultFile = ui.buttons.playCircle,
        overFile = ui.buttons.playCircleOver,
        onRelease = function()
            sounds.play('tap')
            composer.gotoScene("scenes.levels",{time=500, effect="slideLeft"})
            -- composer.gotoScene('scenes.reload_game', {params = {level = 'classic', groupNumber = nil}, time = 500, effect = 'slideLeft'})
        end
    })
    playButton:setFillColor(unpack(utilities:hex2rgb(colorTable[4])))
    group:insert(playButton)

    -- circle parts rotating
    local circleGroup = display.newGroup()
    circleGroup.x = display.contentCenterX
    circleGroup.y = display.contentCenterY
    group:insert(circleGroup)
    local circlePart = display.newImageRect(circleGroup,"assets/game/circle-300.png",125,125)
    circlePart.anchorX = 0.5
    circlePart.anchorY = 1
    local circlePart2 = display.newImageRect(circleGroup,"assets/game/circle-300.png",125,125)
    circlePart2.anchorX = 0.5
    circlePart2.anchorY = 1
    circlePart2.rotation = -45
    local circlePart3 = display.newImageRect(circleGroup,"assets/game/circle-300.png",125,125)
    circlePart3.anchorX = 0.5
    circlePart3.anchorY = 1
    circlePart3.rotation = -225
    local circlePart4 = display.newImageRect(circleGroup,"assets/game/circle-300.png",125,125)
    circlePart4.anchorX = 0.5
    circlePart4.anchorY = 1
    circlePart4.rotation = -180

    transition.to(circleGroup, {time = 4000, rotation=360, iterations=-1})

    local xOffset = 60
    -- bottom buttons
    -- start at middle
    local storeButton = widget.newButton({
        x = display.contentCenterX, y = _ContentHeight * .9 + display.screenOriginY,
        width = 50, height = 50,
        defaultFile = ui.buttons.cart,
        overFile = ui.buttons.cartOver,
        onRelease = function()
            print("Goto store")
            sounds.play("tap")
            composer.gotoScene("scenes.store",{time = 500, effect = 'fromBottom'})
        end
    })
    group:insert(storeButton)
    local settingsButton = widget.newButton({
        x = storeButton.x - xOffset * 2, y = storeButton.y,
        width = 50, height = 50,
        defaultFile = ui.buttons.settings,
        overFile = ui.buttons.settingsOver,
        onRelease = function()
            print("Goto settings")
            sounds.play("tap")
            storeUI.hideGems()
            composer.gotoScene("scenes.settings",{time = 500, effect = 'slideRight'})
        end
    })
    group:insert(settingsButton)
    local infoButton = widget.newButton({
        x = storeButton.x - xOffset, y = storeButton.y,
        width = 45, height = 45,
        defaultFile = ui.buttons.information,
        overFile = ui.buttons.informationOver,
        onRelease = function()
            print("Goto info")
            sounds.play("tap")
            storeUI.hideGems()
            composer.gotoScene("scenes.about",{time = 500, effect = 'slideRight'});
        end
    })
    group:insert(infoButton)
    local achievementsButton = widget.newButton({
        x = storeButton.x + xOffset, y = storeButton.y,
        width = 50, height = 50,
        defaultFile = ui.buttons.trophy,
        overFile = ui.buttons.trophyOver,
        onRelease = function()
            print("Goto achievements")
            sounds.play("tap")
            -- Display the player's achievements
            gameCenter:openAchievements()
        end
    })
    group:insert(achievementsButton)
    local leaderboardButton = widget.newButton({
        x = storeButton.x + xOffset * 2, y = storeButton.y,
        width = 50, height = 50,
        defaultFile = ui.buttons.leaderboard,
        overFile = ui.buttons.leaderboardOver,
        onRelease = function()
            print("Goto leaderboard")
            sounds.play("tap")
            -- Display the leaderboards
            gameCenter:openLeaderboard(nil)
        end
    })
    group:insert(leaderboardButton)
    
    -- move title to front
    title:toFront()
    -- show safe area at top
    group:insert(safeArea)
    safeArea.alpha = 0
    -- safeArea:toBack()
    local level1 = "BasicRings"
    local level2 = "AdvancedRings"
    if databox.isMusicOn then        
        sounds.playStream('menu_music')
    end
end

function scene:show( event )
    if ( event.phase == "will") then
        storeUI.showGems()
    elseif ( event.phase == "did" ) then 
    end
      
end

function scene:hide( event )
    if ( event.phase == "will") then
		-- Take control over the menu button on tvOS
		system.deactivate('controllerUserInteraction')
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