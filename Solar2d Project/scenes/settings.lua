--
-- Import
local display       = require('display')
local composer      = require('composer')
local widget        = require('widget')
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
    storeUI.hideGems()
    print("scene: create - settings")
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
    local colorTable = {}
    for i, v in ipairs(gameOptions.colors) do
        if v.name == databox.colorTheme then
            colorTable = gameOptions.colors[i].colors
        end
    end
    -- background
    local background = display.newRect(group,display.contentCenterX,display.contentCenterY,_ContentWidth,_ContentHeight );
    background:setFillColor(unpack(utilities:hex2rgb(colorTable[2], 1)) )
    -- title
    local title = display.newEmbossedText({parent=group, text="SETTINGS", x=display.contentCenterX, y=display.safeScreenOriginY + 25, font=ui.fonts.mainFont, fontSize=50,align="center"})
    -- title:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
    title:setFillColor(1,1,1,1)
    local color = 
    {
        highlight = { r=.27, g=.27, b=.27 },
        shadow = utilities:hex2rgb("#000")
    }
    title:setEmbossColor( color )

    local ySpacing = 80
    local buttonFontSize = 20
    -- Music button
    self.musicButtonOn = widget.newButton({
        x = 25 + display.screenOriginX, y = title.y + 100,
        width = 50, height = 50,
        label="Music On",
        labelAlign="left",
        labelColor = { default = utilities:hex2rgb("#FFFFFF", 1), over = utilities:hex2rgb("#a2a2a2", 1)},
        labelXOffset = 50,
        fontSize = buttonFontSize,
        emboss = true,
        defaultFile = ui.buttons.musicOn,
        overFile = ui.buttons.musicOnOver,
        onRelease = function()
            print("Stop Music")
			sounds.play('tap')
            sounds.isMusicOn = false
            databox.isMusicOn = false
            self.musicButtonOn.isVisible = false
            self.musicButtonOff.isVisible = true
            sounds.stop()
        end
    })
    self.musicButtonOn.anchorX = 0
    group:insert(self.musicButtonOn)
    self.musicButtonOff = widget.newButton({
        x = self.musicButtonOn.x, y = self.musicButtonOn.y,
        width = 50, height = 50,
        label="Music Off",
        labelAlign="left",
        labelColor = { default = utilities:hex2rgb("#FFFFFF", 1), over = utilities:hex2rgb("#a2a2a2", 1)},
        labelXOffset = 50,
        fontSize = buttonFontSize,
        emboss = true,
        defaultFile = ui.buttons.musicOff,
        overFile = ui.buttons.musicOffOver,
        onRelease = function()
            print("Play Music")
			sounds.play('tap')
            sounds.isMusicOn = true
            databox.isMusicOn = true
            self.musicButtonOn.isVisible = true
            self.musicButtonOff.isVisible = false
            sounds.playStream('menu_music')
        end
    })
    self.musicButtonOff.anchorX = 0
    group:insert(self.musicButtonOff)
    if databox.isMusicOn then
        self.musicButtonOn.isVisible = true
        self.musicButtonOff.isVisible = false
    else
        self.musicButtonOn.isVisible = false
        self.musicButtonOff.isVisible = true
    end

    -- Sound Button
    self.soundButtonOn = widget.newButton({
        x = self.musicButtonOn.x , y = self.musicButtonOn.y + ySpacing,
        width = 50, height = 50,
        label="Sound FX On",
        labelAlign="left",
        labelColor = { default = utilities:hex2rgb("#FFFFFF", 1), over = utilities:hex2rgb("#a2a2a2", 1)},
        labelXOffset = 50,
        fontSize = buttonFontSize,
        emboss = true,
        defaultFile = ui.buttons.soundOn,
        overFile = ui.buttons.soundOnOver,
        onRelease = function()
            print("Turn Sounds Off")
			sounds.play('tap')
            sounds.isSoundOn = false
            databox.isSoundOn = false
            self.soundButtonOn.isVisible = false
            self.soundButtonOff.isVisible = true
        end
    })
    self.soundButtonOn.anchorX = 0
    group:insert(self.soundButtonOn)
    self.soundButtonOff = widget.newButton({
        x = self.soundButtonOn.x, y = self.soundButtonOn.y,
        width = 50, height = 50,
        label="Sound FX Off",
        labelAlign="left",
        labelColor = { default = utilities:hex2rgb("#FFFFFF", 1), over = utilities:hex2rgb("#a2a2a2", 1)},
        labelXOffset = 50,
        fontSize = buttonFontSize,
        emboss = true,
        defaultFile = ui.buttons.soundOff,
        overFile = ui.buttons.soundOffOver,
        onRelease = function()
            print("Turn Sounds On")
			sounds.play('tap')
            sounds.isSoundOn = true
            databox.isSoundOn = true
            self.soundButtonOn.isVisible = true
            self.soundButtonOff.isVisible = false
        end
    })
    self.soundButtonOff.anchorX = 0
    group:insert(self.soundButtonOff)
    if databox.isSoundOn then
        self.soundButtonOn.isVisible = true
        self.soundButtonOff.isVisible = false
    else
        self.soundButtonOn.isVisible = false
        self.soundButtonOff.isVisible = true
    end

    local colorButtonText =string.sub(databox.colorTheme, 1, string.find( databox.colorTheme,"_") - 1)
    -- Color Theme Picker
    self.colorThemeButton = widget.newButton({
        x = self.soundButtonOn.x, y = self.soundButtonOn.y + ySpacing,
        width = 50, height = 50,
        label="Color Theme: " .. utilities:firstToUpper(colorButtonText),
        labelAlign="left",
        labelColor = { default = utilities:hex2rgb("#FFFFFF", 1), over = utilities:hex2rgb("#a2a2a2", 1)},
        labelXOffset = 50,
        fontSize = buttonFontSize,
        emboss = true,
        defaultFile = ui.buttons.colorPick,
        overFile = ui.buttons.colorPickOver,
        onRelease = function()
            print("Go to Theme Chooser")
			sounds.play('tap')
            composer.gotoScene("scenes.colorTheme",{time = 500, effect = 'slideRight'});
        end
    })
    self.colorThemeButton.anchorX = 0
    group:insert(self.colorThemeButton)
    -- Restore Purchases
    -- self.restoreButton = widget.newButton({
    --     x = self.colorThemeButton.x, y = self.colorThemeButton.y + ySpacing,
    --     width = 50, height = 50,
    --     label="Restore Purchases",
    --     labelAlign="left",
    --     labelColor = { default = utilities:hex2rgb("#FFFFFF", 1), over = utilities:hex2rgb("#a2a2a2", 1)},
    --     labelXOffset = 50,
    --     fontSize = buttonFontSize,
    --     emboss = true,
    --     defaultFile = ui.buttons.restore,
    --     overFile = ui.buttons.restoreOver,
    --     onRelease = function()
    --         print("Restore Purchases")
	-- 		sounds.play('tap')
    --         storeUI.restorePurchases()
    --     end
    -- })
    -- self.restoreButton.anchorX = 0
    -- group:insert(self.restoreButton)
    -- Reset Tutorial
    -- self.resetButton = widget.newButton({
    --     x = self.colorThemeButton.x, y = self.colorThemeButton.y + ySpacing,
    --     width = 50, height = 50,
    --     label="Reset Tutorial",
    --     labelAlign="left",
    --     labelColor = { default = utilities:hex2rgb("#FFFFFF", 1), over = utilities:hex2rgb("#a2a2a2", 1)},
    --     labelXOffset = 50,
    --     fontSize = buttonFontSize,
    --     emboss = true,
    --     defaultFile = ui.buttons.refresh,
    --     overFile = ui.buttons.refreshOver,
    --     onRelease = function()
    --         print("Reset Tutorial")
	-- 		sounds.play('tap')
    --         databox.isHelpShown = false
    --     end
    -- })
    -- self.resetButton.anchorX = 0
    -- group:insert(self.resetButton)



    -- go back button
    local goBackButton = widget.newButton({
        x = _ContentWidth - 35 + display.screenOriginX, y = _ContentHeight * .9 + display.safeScreenOriginY,
        width = 50, height = 50,
        defaultFile = ui.buttons.goBack,
        overFile = ui.buttons.goBackOver,
        onRelease = function()
            print("Goto Main Menu")
			sounds.play('tap')
            composer.gotoScene("scenes.menu",{time = 500, effect = 'slideLeft'});
        end
    })
    group:insert(goBackButton)

    title:toFront()
    group:insert(safeArea)
    safeArea.alpha = 0
end

function scene:show( event )
    if ( event.phase == "will") then
        storeUI.hideGems()
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