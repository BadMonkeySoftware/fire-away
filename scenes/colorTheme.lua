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
    print("scene: create - Color Theme")
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
    background:setFillColor(unpack(utilities:hex2rgb(colorTable[3], 1)) )
    -- title
    local title = display.newEmbossedText({parent=group, text="COLOR THEMES", x=display.contentCenterX, y=display.safeScreenOriginY + 25, font=ui.fonts.mainFont, fontSize=38,align="center"})
    title:setFillColor(unpack(utilities:hex2rgb(colorTable[4], 1)))
    -- title:setFillColor(1,1,1,1)
    local color = 
    {
        highlight = { r=.27, g=.27, b=.27 },
        shadow = utilities:hex2rgb("#000")
    }
    title:setEmbossColor( color )

    local ySpacing = 80
    local buttonFontSize = 20
    for i, colorPack in ipairs(gameOptions.colors) do        
        print("Name: " .. colorPack.name)
        local colorButtonText =string.sub(colorPack.name, 1, string.find( colorPack.name,"_") - 1)
        local colorButton = widget.newButton({
            label = colorButtonText .. " Colors",
            labelYOffset = - 20,
            labelColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#A2A2A2", .75) },
            x = display.contentCenterX, y = title.y + (i * 80),
            shape = "rect",
            width = 250,
            height = 60,
            emboss = true,
            fillColor = { default=utilities:hex2rgb(colorTable[3], 0.01), over=utilities:hex2rgb(colorTable[3], 0.01) },
            strokeColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#A2A2A2", .75) },
            strokeWidth = 2,
            onRelease = function ()
                databox.colorTheme = colorPack.name
                colorTable = gameOptions.colors[i].colors
                background:setFillColor(unpack(utilities:hex2rgb(colorTable[3], 1)) )
                title:setFillColor(unpack(utilities:hex2rgb(colorTable[4], 1)))
            end
        })
        group:insert(colorButton)
        local xOffset = 30
        for ci, color in ipairs(colorPack.colors) do
            local colorBox = display.newRect(colorButton,xOffset + (ci * 30),colorButton.height - 20,20,20)
            colorBox:setFillColor(unpack(utilities:hex2rgb(color)))
            colorBox.strokeWidth = 1
            colorBox:setStrokeColor(unpack(utilities:hex2rgb("#000000", 1)))
            
        end
    end


    -- go back button
    local goBackButton = widget.newButton({
        x = _ContentWidth - 35 + display.screenOriginX, y = _ContentHeight * .9,
        width = 50, height = 50,
        defaultFile = ui.buttons.goBack,
        overFile = ui.buttons.goBackOver,
        onRelease = function()
            print("Goto Settings")
			sounds.play('tap')
            composer.gotoScene("scenes.settings",{time = 500, effect = 'slideLeft'});
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