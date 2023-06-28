-- PauseScreen
-- this is like a sceen but is more just an overlay that disables touch in shaded area
-- resume, restart, menu or level select, and sounds

-- Import
-- include Corona's libraries
local composer      = require('composer')
local display       = require('display')
local widget        = require('widget')
local json          = require('json')
local easing        = require('easing')
local system        = require('system')
-- include helper libraries
local utilities     = require('classes.utilities')
local ui            = require('classes.ui')
local controller    = require('libs.controller')
local databox       = require('libs.databox')
local overscan      = require('libs.overscan')
local relayout      = require('libs.relayout')
local sounds        = require('libs.sounds')

local _M = {}

local newPopup = require('classes.popup').newPopup --generic popup
-- 
-- Set variables

function _M.newPauseMenu(params)
    local _ContentWidth, _ContentHeight, _CenterX, _CenterY = relayout._W, relayout._H, relayout._CX, relayout._CY

    local popupHeight = 250
    local buttonOffset = 0
    local extraHeight = 0
    local platform = system.getInfo("platform")
    if string.lower(platform) == 'tvos' then
        _ContentWidth = 320
        extraHeight = 50
        _ContentHeight = 570
    end

    popupHeight = popupHeight + extraHeight
    buttonOffset = 0

    print("popupHeight: ", popupHeight)
    local pauseMenu = newPopup({
        group = params.group ,
        title = params.title,
        showClose = false,
        fontSize = 40, x = display.contentCenterX, y = display.contentCenterY,
        width = _ContentWidth * 0.75, height = popupHeight,
        showParams = {time = 250, x = display.contentCenterX, alpha = 1, transition = easing.outExpo},
        hideParams = {time = 250, x = -_ContentWidth, transition = easing.outExpo, onComplete = function ()
            params.onHide()
        end}
    })
    local start = -(popupHeight / 2 - 80) + 25
    local xOffset = 50
    -- Resume Game
    local resumeButton = widget.newButton(
        {
            width = 60,
            height = 60,
            x = 0, y = start,
            defaultFile = ui.buttons.playCircle,
            overFile = ui.buttons.playCircleOver,
            -- label = "Resume Game",
            -- font = ui.fonts.mainFont,
            -- emboss = true,
            -- labelColor = {
            --     default = utilities:hex2rgb('#FFFFFF', 1),
            --     over = utilities:hex2rgb('#000000', 0.5)
            -- },
            onRelease = function()
                sounds.play('tap')
                pauseMenu:hide()
            end
        }
    )	
    pauseMenu:insert(resumeButton)
    table.insert(pauseMenu.visualButtons, resumeButton)

    -- Sounds
    -- Sound Button
    pauseMenu.soundButtonOn = widget.newButton({
        x = -70 , y = resumeButton.y + 100,
        width = 30, height = 30,
        defaultFile = ui.buttons.soundOn,
        overFile = ui.buttons.soundOnOver,
        onRelease = function()
            print("Turn Sounds Off")
			sounds.play('tap')
            sounds.isSoundOn = false
            databox.isSoundOn = false
            pauseMenu.soundButtonOn.isVisible = false
            pauseMenu.soundButtonOff.isVisible = true
        end
    })
    pauseMenu.soundButtonOn.anchorX = 0.5
    pauseMenu:insert(pauseMenu.soundButtonOn)
    pauseMenu.soundButtonOff = widget.newButton({
        x = pauseMenu.soundButtonOn.x, y = pauseMenu.soundButtonOn.y,
        width = 25, height = 25,
        defaultFile = ui.buttons.soundOff,
        overFile = ui.buttons.soundOffOver,
        onRelease = function()
            print("Turn Sounds On")
			sounds.play('tap')
            sounds.isSoundOn = true
            databox.isSoundOn = true
            pauseMenu.soundButtonOn.isVisible = true
            pauseMenu.soundButtonOff.isVisible = false
        end
    })
    pauseMenu.soundButtonOff.anchorX = 0.5
    pauseMenu:insert(pauseMenu.soundButtonOff)
    if databox.isSoundOn then
        pauseMenu.soundButtonOn.isVisible = true
        pauseMenu.soundButtonOff.isVisible = false
    else
        pauseMenu.soundButtonOn.isVisible = false
        pauseMenu.soundButtonOff.isVisible = true
    end

    -- Music
    pauseMenu.musicButtonOn = widget.newButton({
        x = pauseMenu.soundButtonOn.x + xOffset, y = pauseMenu.soundButtonOn.y,
        width = 30, height = 30,
        defaultFile = ui.buttons.musicOn,
        overFile = ui.buttons.musicOnOver,
        onRelease = function()
            print("Stop Music")
			sounds.play('tap')
            sounds.isMusicOn = false
            databox.isMusicOn = false
            pauseMenu.musicButtonOn.isVisible = false
            pauseMenu.musicButtonOff.isVisible = true
            sounds.stop()
        end
    })
    pauseMenu.musicButtonOn.anchorX = 0.5
    pauseMenu:insert(pauseMenu.musicButtonOn)
    pauseMenu.musicButtonOff = widget.newButton({
        x = pauseMenu.musicButtonOn.x, y = pauseMenu.musicButtonOn.y,
        width = 30, height = 30,
        defaultFile = ui.buttons.musicOff,
        overFile = ui.buttons.musicOffOver,
        onRelease = function()
            print("Play Music")
			sounds.play('tap')
            sounds.isMusicOn = true
            databox.isMusicOn = true
            pauseMenu.musicButtonOn.isVisible = true
            pauseMenu.musicButtonOff.isVisible = false
            sounds.playStream('menu_music')
        end
    })
    pauseMenu.musicButtonOff.anchorX = 0.5
    pauseMenu:insert(pauseMenu.musicButtonOff)
    if databox.isMusicOn then
        pauseMenu.musicButtonOn.isVisible = true
        pauseMenu.musicButtonOff.isVisible = false
    else
        pauseMenu.musicButtonOn.isVisible = false
        pauseMenu.musicButtonOff.isVisible = true
    end

    -- Store Button
    pauseMenu.storeButton = widget.newButton({
        x = pauseMenu.musicButtonOn.x + xOffset, y = pauseMenu.musicButtonOn.y,
        width = 30, height = 30,
        defaultFile = ui.buttons.cart,
        overFile = ui.buttons.cartOver,
        onRelease = function()
            print("Goto store")
            sounds.play("tap")
            composer.showOverlay("scenes.store",{time=50, effect = 'fromBottom'});
            -- composer.gotoScene("scenes.store",{time = 50, effect = 'crossFade'})
        end
    })
    pauseMenu:insert(pauseMenu.storeButton)
    -- Home
    pauseMenu.homeButton = widget.newButton({
        x = pauseMenu.storeButton.x + xOffset, y = pauseMenu.storeButton.y,
        width = 30, height = 30,
        defaultFile = ui.buttons.home,
        overFile = ui.buttons.homeOver,
        onRelease = function()
            print("Goto store")
            sounds.play("tap")
            composer.gotoScene("scenes.menu",{time = 400, effect = 'zoomOutInFade'})
        end
    })
    pauseMenu:insert(pauseMenu.homeButton)
    -- pauseMenu.menuButton = widget.newButton(
    --     {
    --         width = 190,
    --         height = 49,
    --         x = 0, 
    --         y = start + spacing * (2 + buttonOffset),
    --         defaultFile = ui.buttons.yellowButton,
    --         overFile = ui.buttons.yellowButtonOver,
    --         label = "Main Menu",
    --         font = ui.fonts.mainFont,
    --         emboss = true,
    --         labelColor = {
    --             default = utilities:hex2rgb('#FFFFFF', 1),
    --             over = utilities:hex2rgb('#000000', 0.5)
    --         },
    --         onRelease = function()
    --             sounds.play('tap')
    --             composer.gotoScene('scenes.menu', {time=400, effect='slideRight'})
    --         end
    --     }
    -- )	
    -- pauseMenu:insert(pauseMenu.menuButton)
    -- table.insert(pauseMenu.visualButtons, pauseMenu.menuButton)



    -- relayout function for resizing panel
    function pauseMenu:relayout()
        pauseMenu.y = relayout._CY
        -- uncomment if helpers are needed
		-- appleTvRemoteHelp.x = relayout._CX - background.width / 2
		-- razerServalHelp.x = appleTvRemoteHelp.x
		-- gamepadHelp.x = appleTvRemoteHelp.x
		-- touchScreenHelp.x = appleTvRemoteHelp.x
		-- badge.x = relayout._W - background.width / 2 - 16
    end
    -- add pauseMenu to relayout
    relayout.add(pauseMenu)

    return pauseMenu
end

return _M