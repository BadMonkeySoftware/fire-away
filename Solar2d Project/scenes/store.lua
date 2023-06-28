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

-- Interact with IAP product data
local productData = require( "libs.productData" )
-- This is needed for the storeUI controls.
local storeUI = require( "libs.storeUI" )
-- 
-- Set variables
local store
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
    local group = self.view
    print("scene: create - store")
    local products = productData.getList()
    print("# of Products: " .. #products)
    for i = 1, #products do
        print("product: " .. products[i])        
    end
    -- store = storeUI.getStore()
    -- local platform 		= string.lower(system.getInfo("platform"))
    -- local env 			= string.lower(system.getInfo("environment"))

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
    background:setFillColor(unpack(utilities:hex2rgb(colorTable[5], 1)) )
    
    -- title
    local title = display.newEmbossedText({parent=group, text="STORE", x=display.contentCenterX, y=storeUI.gemsIcon.y + 50, font=ui.fonts.mainFont, fontSize=50,align="center"})
    title.anchorY = 0
    title:setFillColor(unpack(utilities:hex2rgb(colorTable[4])))
    -- title:setFillColor(1,1,1,1)
    local color = 
    {
        highlight = { r=.27, g=.27, b=.27 },
        shadow = utilities:hex2rgb("#000")
    }
    title:setEmbossColor( color )

    local ySpacing = 80
    local buttonFontSize = 20
    -- loop through products and setData on productData lib
    storeUI.refreshProductFields( productData, group )



    -- go back button
    local goBackButton = widget.newButton({
        x = _ContentWidth - 35 + display.screenOriginX, y = _ContentHeight * .9 + display.safeScreenOriginY,
        width = 50, height = 50,
        defaultFile = ui.buttons.goBack,
        overFile = ui.buttons.goBackOver,
        onRelease = function()
            print("Goto Main Menu")
            sounds.play("tap")
            local prevScene = composer.getSceneName( "previous" )
            print(prevScene)
            if prevScene == "scenes.reload_game" then
                composer.hideOverlay("slideDown", 50)
            else
                composer.gotoScene("scenes.menu",{time = 500, effect = 'slideDown'});
            end
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
    local sceneGroup = self.view
    local phase = event.phase
    local parent = event.parent  -- Reference to the parent scene object
    local prevScene = composer.getSceneName( "previous" )
    if ( phase == "will" ) and prevScene == "scenes.reload_game" then
        -- Call the "resumeGame()" function in the parent scene
        parent:storeWasHidden()
    end
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