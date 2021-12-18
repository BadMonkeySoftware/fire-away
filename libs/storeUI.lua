local storeUI = {}

-- This is needed for the storeUI controls.
local system = require( "system" )
local widget = require( "widget" )
local display = require( "display" )
local native = require( "native" )
local timer = require( "timer" )
local easing = require( "easing" )

local transition	= require('transition')
local transition2	= require('transition2')
-- include helper classes and libraries
local utilities = require('classes.utilities')
local ui = require('classes.ui')
local gameOptions   = require('classes.game_options')
local databox       = require('libs.databox') -- Persistant storage, track level completion and settings

-- The store our UI is connected to.
local store = nil

-- The platform our UI is configured for.
local platform = nil

storeUI.descriptionArea = nil
storeUI.gemsIcon = nil
storeUI.gemsText = nil
-- Buttons for each of the products we've loaded
local productButtons = {}
storeUI.spinners = {}
local buttonHeight = 50
-------------------------------------------------------------------------------
-- Displays a warning indicating that store access is not available,
-- meaning that Corona does not support in-app purchases on this system/device.
-- To be called when the store.isActive property returns false.
-------------------------------------------------------------------------------
function storeUI.showStoreNotAvailableWarning()
	if platform == "simulator" then
		native.showAlert( "Notice", "In-app purchases are not supported by the Corona Simulator.", { "OK" } )
	else
		native.showAlert( "Notice", "In-app purchases are not supported on this system/device.", { "OK" } )
	end
end

-------------------------------------------------------------------------------
-- Prints the "Select an option..." prompt in the UI's console
-------------------------------------------------------------------------------
function storeUI.printOptionPrompt ( )
	storeUI.printToConsole( "Select an option..." )
end
-------------------------------------------------------------------------------
-- Sets up the text Area and description area for the Store UI
-------------------------------------------------------------------------------
function storeUI.initializeStoreMenu (gems)
    print("Initializing Store: " .. gems)
    if storeUI.gemsIcon == nil then
        storeUI.gemsIcon = display.newImageRect(ui.icons.gem, 35, 31)
        -- 16.457142857142857
        storeUI.gemsIcon.x = 20 + display.screenOriginX
        storeUI.gemsIcon.y = 10 + display.safeScreenOriginY
        storeUI.gemsIcon.anchorY = 0
        storeUI.gemsIcon.anchorX = 0

        display.getCurrentStage():insert(storeUI.gemsIcon)
    end
    if storeUI.gemsText == nil then
        storeUI.gemsText = display.newText({text="" .. gems, x=storeUI.gemsIcon.x + 40 , y=storeUI.gemsIcon.y-3, font = ui.fonts.dinPro, fontSize = 25 })
        storeUI.gemsText.anchorX = 0
        storeUI.gemsText.anchorY = 0
        display.getCurrentStage():insert(storeUI.gemsText)
    end
	-- Set up native text box for displaying current transaction status.
	-- storeUI.descriptionArea = native.newTextBox( display.contentCenterX, 150,
	-- 			display.contentWidth * .7, 0.75 * display.contentHeight )
	-- storeUI.printOptionPrompt()
	-- -- storeUI.descriptionArea:setTextColor( 0, 0.8, 0, 0.8 )
	-- storeUI.descriptionArea.size = 16
	-- storeUI.descriptionArea.hasBackground = false
	-- -- storeUI.descriptionArea.anchorX = 0
	-- storeUI.descriptionArea.anchorY = 0
    -- group:insert(storeUI.descriptionArea)
end


-------------------------------------------------------------------------------
-- Process and display product information obtained from store.
-- Constructs a button for each item
-------------------------------------------------------------------------------
function storeUI.addProductFields( productData, group )
	-- Display product purchasing options
	print ( "Loading product list" )
	if ( not productData.validProducts  ) or ( #productData.validProducts  <= 0 ) then
		-- There are no products to purchase. This indicates that in-app purchasing is not supported.
		local noProductsLabel = display.newText(group,
					"Sorry!\nIn-App purchases are not supported on this device.",
					display.contentWidth / 2, display.contentHeight / 3,
					display.contentWidth / 2, 0,
					native.systemFont, 16 )
		noProductsLabel:setFillColor( 0, 0, 0 )
		noProductsLabel.anchorX = 0
		noProductsLabel.anchorY = 0
		storeUI.showStoreNotAvailableWarning( )
	else
		-- Products for purchasing have been received. Create options to purchase them below.
		print( "Product list loaded" )
		print( "Country: " .. tostring( system.getPreference( "locale", "country" ) ) )
		print( "Found " .. #productData.validProducts  .. " valid items " )
		
		local buttonSpacing = 5

		-- display the valid products in buttons 
		for i=1, #productData.validProducts  do            
			-- Debug:  print out product info 
			print( "Item " .. tostring( i ) .. ": " .. tostring( productData.validProducts[i].productIdentifier )
							.. " (" .. tostring( productData.validProducts[i].price ) .. ")" )
			print( productData.validProducts[i].title .. ",  ".. productData.validProducts[i].description )

			-- create and position product button
            local yStart = 150 + display.safeScreenOriginY
            local buttonX = display.contentCenterX
            local buttonY = yStart + (i * buttonSpacing + ( 2 * i - 1 ) * buttonHeight / 2)
			local myButton = storeUI.newBuyButton( productData.validProducts[i], buttonX, buttonY )
			-- myButton.x = display.contentWidth - myButton.width - buttonSpacing
			myButton.x = buttonX
			myButton.y = buttonY
            group:insert(myButton)
			productButtons[i] = myButton
		end
        
		-- Debug: Display invalid prodcut info loaded from the store.
		--        You would not normally do this in a release build of your app.
		for i=1, #productData.invalidProducts do
			native.showAlert( "Notice", "Item " .. tostring( productData.invalidProducts[i] ) .. " is invalid.", {"OK"} )
			print( "Item " .. tostring( productData.invalidProducts[i] ) .. " is invalid." )
		end
	end
end

-------------------------------------------------------------------------------
-- Clears product infomation currently displayed.
-- Used for chaning the products currently displayed.
-------------------------------------------------------------------------------
function storeUI.clearProductFields( )
	-- Remove all the product buttons
	for i = 1, #productButtons do
		display.remove( productButtons[i] )
	end
end

-------------------------------------------------------------------------------
-- Refreshes the current product field display
-------------------------------------------------------------------------------
function storeUI.refreshProductFields( productData, group )
	storeUI.clearProductFields( )
	storeUI.addProductFields( productData, group )
end

-------------------------------------------------------------------------------
-- Utility function to hide gems.
-------------------------------------------------------------------------------
function storeUI.hideGems()
    print("Hiding Gems")
    storeUI.gemsIcon.alpha = 0
    storeUI.gemsText.alpha = 0
end
-------------------------------------------------------------------------------
-- Utility function to show gems.
-------------------------------------------------------------------------------
function storeUI.showGems()
    storeUI.gemsIcon.alpha = 1
    storeUI.gemsText.alpha = 1
end

-------------------------------------------------------------------------------
-- Utility function to update Gems Amount.
-------------------------------------------------------------------------------
function storeUI.updateGemsText(gems)
    storeUI.gemsText.text = "" .. gems
end
function storeUI.addGemsFromPurchase(origGems, newGems, startX, startY)
    local finalGems = origGems + newGems
    for i = 1, newGems do 
        timer.performWithDelay(10 * i, function()
            local newGemsText = tostring(origGems + i)
            local gem = display.newImageRect(ui.icons.gem, 35, 31) 
            gem.x, gem.y = (startX or display.contentCenterX) + math.random(-50, 50), (startY or display.contentCenterY) + math.random(-40, 40) 
            -- gem.rotation = math.random(0, 360) 
            gem.anchorY = 0
            gem.anchorX = 0
            transition.to(gem, {time = 750, x = storeUI.gemsIcon.x, y = storeUI.gemsIcon.y, transition = easing.inBack, onComplete = function ()
                gem:removeSelf()
                storeUI.gemsText.text = newGemsText
            end})
        end)
        -- transition2.moveSine(gem, {
        --     radiusY = 500,
        --     time = 5000,
        --     iterations = 0,
        -- })
        -- transition2.moveSine(gem, {
        --     radiusX = 150,
        --     time = 2500,
        --     iterations = 0,
        -- })
    end
    databox.gems = finalGems
    -- storeUI.gemsText.text = "" .. finalGems
end
-------------------------------------------------------------------------------
-- Utility function to build a buy button.
-------------------------------------------------------------------------------
function storeUI.newBuyButton ( product, x, y)
	--	Handler for buy button 
    local colorTable = {}
    for i, v in ipairs(gameOptions.colors) do
        if v.name == databox.colorTheme then
            colorTable = gameOptions.colors[i].colors
        end
    end

	local buyThis = function ( productId )

		function printWaitingForTransaction( )
			storeUI.printToConsole( "Waiting for transaction on " .. tostring( productId ) .. " to complete..." )
            local spinner = widget.newSpinner{
                x = x or display.contentCenterX,
                y = y or display.contentCenterY,
                width=75,height=75,
                deltaAngle = 10,
                incrementEvery = 50
            }
            spinner:start()
            table.insert(storeUI.spinners, spinner)
            -- storeUI.descriptionArea = native.newTextBox( display.contentCenterX, 150, display.contentWidth, 75 )
            -- storeUI.descriptionArea:setTextColor( 0, 0.8, 0, 0.8 )
            -- storeUI.descriptionArea.size = 16
            -- storeUI.descriptionArea.hasBackground = true
            -- -- storeUI.descriptionArea.anchorX = 0
            -- storeUI.descriptionArea.anchorY = 0
            -- storeUI.descriptionArea.text = "Waiting on transaction to complete"
		end

		-- Check if it is possible to purchase the item, then attempt to buy it.
        if platform == 'simulator' then
            print("Bought ")
            local spinner = widget.newSpinner{
                x = x or display.contentCenterX,
                y = y or display.contentCenterY,
                width=75,height=75,
                deltaAngle = 10,
                incrementEvery = 50
            }
            spinner:start()
            local startX, startY = spinner.x, spinner.y
            timer.performWithDelay(1000, function ()
                spinner:removeSelf()
                storeUI.addGemsFromPurchase(databox.gems, 25, startX, startY)
            end)
        elseif not isAndroid and not store.isActive then
			storeUI.showStoreNotAvailableWarning( )
			timer.performWithDelay( 2000, storeUI.printOptionPrompt )
		elseif not store.canMakePurchases then
			native.showAlert( "Notice", "Store purchases are not available, please try again later", { "OK" } )
			timer.performWithDelay( 2000, storeUI.printOptionPrompt )
		elseif productId then
			print( "Ka-ching! Purchasing " .. tostring( productId ) )
    		if platform == "android" then
      			-- Google IAP v3 only allows purchases one at a time, so we don't pass a table here.
      			-- store.purchase( productId )
      			store.consumePurchase( productId )
                -- when purchase is complete store.init() is called which is front initialization
            else
                -- Corona's default store library requires a table to be passed here, even for only 1 item.
                store.purchase( {productId} )
                -- when purchase is complete store.init() is called which is front initialization
    		end
    		timer.performWithDelay( 1, printWaitingForTransaction )
		end
		
	end

	function buyThis_closure ( product )            
		-- Closure wrapper for buyThis() to remember which button
		return function ( event )
			buyThis( product.productIdentifier )
			return true
		end        
	end
	local label = product.title .. "  -  " .. product.localizedPrice
	-- On Android, the name of the app is included in the title 
	-- of all in-app products. We remove this for the sake of clarity
	if platform == "android" then
		label = string.gsub( label, "%b()", "" )
	end

	local myButton = widget.newButton
	{ 
		-- defaultFile = buttonDefault, 
		-- overFile = buttonOver,
        shape="rect",
		label = "", 
        labelColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#A2A2A2", 1) },
        labelAlign = "center",
		font= ui.fonts.dinPro,
		fontSize = 18, 
		emboss = false,
        fillColor = { default=utilities:hex2rgb(colorTable[5], 1), over=utilities:hex2rgb(colorTable[5], .75) },
        strokeWidth = 2,
        strokeColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#A2A2A2", .75) },
        width=250, height = buttonHeight,
        -- x=display.contentCenterX, y=basicRingsButton.y + 60,
        -- onRelease = function()
        --     -- sounds.play("tap")
        --     -- composer.gotoScene('scenes.reload_game', {params = {level = "AdvancedRings"}})
        -- end
		--onEvent = handleButtonEvent( product )
		-- onPress = describeThis_closure( product ),
		onRelease = buyThis_closure( product ),
	}
	-- myButton.anchorX = 0 	-- left
	myButton:setLabel( label )
	return myButton
end

-------------------------------------------------------------------------------
-- Sets which platform we want our store UI will be used with.
-------------------------------------------------------------------------------
function storeUI.setPlatform( platformToUse )
	platform = platformToUse
end

-------------------------------------------------------------------------------
-- Tell the store UI which store API to use
-------------------------------------------------------------------------------
function storeUI.setStore( storeToUse )
	store = storeToUse
end
function storeUI.getStore()
	return store
end
-------------------------------------------------------------------------------
-- Restores purchases previously made. when complete calls store.init() callback
-------------------------------------------------------------------------------
function storeUI.restorePurchases()
    storeUI.printToConsole("Restore Purchases")
    store.restore()
end
-------------------------------------------------------------------------------
-- Print info to the storeUI's debug console
-------------------------------------------------------------------------------
function storeUI.printToConsole( message )
	if storeUI.descriptionArea ~= nil then
		storeUI.descriptionArea.text = message
		print( storeUI.descriptionArea.text )
	else
		print( "Store UI console unavailable. Printing message to stdout." )
		print( message )
	end
end

-- Return storeUI library for external use
return storeUI