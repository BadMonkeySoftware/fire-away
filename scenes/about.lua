--
-- Import
local display       = require('display')
local composer      = require('composer')
local widget        = require('widget')
local system        = require('system')
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
    print("scene: create - about")
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
    -- background
    local background = display.newRect(group,display.contentCenterX,display.contentCenterY,_ContentWidth,_ContentHeight );
    background:setFillColor(unpack(utilities:hex2rgb(colorTable[4], 1)) )
    -- title
    local title = display.newEmbossedText({parent=group, text="ABOUT", x=display.contentCenterX, y=display.safeScreenOriginY + 25, font=ui.fonts.mainFont, fontSize=50,align="center"})
    title:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
    -- title:setFillColor(1,1,1,1)
    local color = 
    {
        highlight = { r=.27, g=.27, b=.27 },
        shadow = utilities:hex2rgb("#000")
    }
    title:setEmbossColor( color )

    local ySpacing = 80
    local buttonFontSize = 20
    -- How To Play button
    self.howToPlayButton = widget.newButton({
        x = 25 + display.screenOriginX, y = title.y + 100,
        width = 50, height = 50,
        label="How To Play",
        labelAlign="left",
        labelColor = { default = utilities:hex2rgb("#FFFFFF", 1), over = utilities:hex2rgb("#a2a2a2", 1)},
        labelXOffset = 50,
        fontSize = buttonFontSize,
        emboss = true,
        defaultFile = ui.buttons.question,
        overFile = ui.buttons.questionOver,
        onRelease = function()
            print("How To Play")
			sounds.play('tap')
            composer.gotoScene("scenes.tutorial",{time = 500, effect = 'slideRight'});
        end
    })
    self.howToPlayButton.anchorX = 0
    group:insert(self.howToPlayButton)
    -- Rate Fire Away
    self.rateButton = widget.newButton({
        x = self.howToPlayButton.x, y = self.howToPlayButton.y + ySpacing,
        width = 50, height = 50,
        label="Rate Fire Away!",
        labelAlign="left",
        labelColor = { default = utilities:hex2rgb("#FFFFFF", 1), over = utilities:hex2rgb("#a2a2a2", 1)},
        labelXOffset = 50,
        fontSize = buttonFontSize,
        emboss = true,
        defaultFile = ui.buttons.star,
        overFile = ui.buttons.starOver,
        onRelease = function()
            print("Rate Fire Away")
			sounds.play('tap')
            if platform == 'tvos' then
                system.openURL( gameOptions.constants.TVOS_REVIEW_URL )
            else
                system.openURL( gameOptions.constants.REVIEW_URL )
            end
        end
    })
    self.rateButton.anchorX = 0
    group:insert(self.rateButton)

    -- Email Us Button
    self.emailButton = widget.newButton({
        x = self.rateButton.x , y = self.rateButton.y + ySpacing,
        width = 50, height = 50,
        label="Email Us",
        labelAlign="left",
        labelColor = { default = utilities:hex2rgb("#FFFFFF", 1), over = utilities:hex2rgb("#a2a2a2", 1)},
        labelXOffset = 50,
        fontSize = buttonFontSize,
        emboss = true,
        defaultFile = ui.buttons.email,
        overFile = ui.buttons.emailOver,
        onRelease = function()
            print("Open Email")
			sounds.play('tap')
            system.openURL( gameOptions.constants.SUPPORT_URL )
        end
    })
    self.emailButton.anchorX = 0
    group:insert(self.emailButton)

    -- Credits
    local credits = display.newEmbossedText({parent=group, text="Credits:", x=display.contentCenterX, y=self.emailButton.y + ySpacing, font=ui.fonts.mainFont, fontSize=30,align="center"})
    credits:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
    local creditBox = widget.newButton({
        shape="rect",
        fillColor = { default=utilities:hex2rgb(colorTable[4], 1), over=utilities:hex2rgb("#A2A2A2", .75) },
        width=200, height = 75,
        x=self.rateButton.x, y=credits.y + 15,
        onRelease = function()
            local url = "https://soundimage.org/"
            system.openURL( url )
        end
    })
    creditBox.anchorX = 0
    creditBox.anchorY = 0
    group:insert(creditBox)
    local credits1 = display.newText({parent=group, text="GAME MENU", x=self.rateButton.x, y=credits.y + 30, font=ui.fonts.mainFont, fontSize=12,align="left"})
    credits1.anchorX = 0
    local credits2 = display.newText({parent=group, text="by Eric Matyas", x=self.rateButton.x, y=credits1.y + 16, font=ui.fonts.mainFont, fontSize=12,align="left"})
    credits2.anchorX = 0
    local credits3 = display.newText({parent=group, text="www.soundimage.org", x=self.rateButton.x, y=credits2.y + 16, font=ui.fonts.mainFont, fontSize=12,align="left"})
    credits3.anchorX = 0


    -- go back button
    local goBackButton = widget.newButton({
        x = _ContentWidth - 35 + display.screenOriginX, y = _ContentHeight * .9 + display.safeScreenOriginY,
        width = 50, height = 50,
        defaultFile = ui.buttons.goBack,
        overFile = ui.buttons.goBackOver,
        onRelease = function()
            print("Goto Main Menu")
            sounds.play("tap")
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