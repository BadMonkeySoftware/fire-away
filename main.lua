-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------


local display      	= require('display')
local system        = require('system')
local native    	= require('native')
local json			= require("json")
local animation        = require('plugin.animation')
local gameCenter    = require("classes.helper_gamecenter")
-- globals
local platform 		= system.getInfo("platform")
local env 			= system.getInfo("environment")
print("Platform: " .. platform)
print("Env: " .. env) -- simulator
-- if platform ~= "HTML5" then
-- end

-- This library automatically loads and saves it's storage into databox.json inside Documents directory
-- And it uses iCloud KVS storage on iOS and tvOS
local databox = require('libs.databox')

-- initialize Databox variables
databox({
	isSoundOn = true,
	isMusicOn = true,
	isHelpShown = false,
	overscanValue = 0,
	colorTheme = "Basic_ColorPack",
	BasicRingsUnlocked = true,
	BasicRingsHighScore = 0,
	AdvancedRingsUnlocked = true,
	AdvancedRingsHighScore = 0,
	BasicColorPack = true,
	SunriseColorPack = true,
	SeashoreColorPack = true,
	FallColorPack = true,
    gems = 100
})

-- Declare globals that persist through each module
-- You must call this first in order to use the "store" API.
local store = require ( "store" ) -- Available in Corona build #261 or later
local googleIAPvBilling = false

-- hide status bar
display.setStatusBar(display.HiddenStatusBar)
-- system.activate('multitouch')
if system.getInfo('build') >= '2015.2741' then -- Allow the game to be opened using an old Corona version
    display.setDefault('isAnchorClamped', false) -- Needed for scenes/reload_game.lua animation
end
-- remove system gestures
if string.lower(platform) == "ios" then 
    native.setProperty("preferredScreenEdgesDeferringSystemGestures", true)
end
if string.lower(platform) == 'tvos' then
    system.setIdleTimer( false ) -- disable idle timer on TV
end

-- Hide navigation bar on Android
if string.lower(platform) == 'android' then
	native.setProperty('androidSystemUiVisibility', 'immersiveSticky')
    store = require( "plugin.google.iap.billing" )
	googleIAPvBilling = true
elseif store.availableStores.apple then
	-- iOS is supported
elseif ( env == "simulator" ) then
	platform = 'simulator'
else
	-- native.showAlert( "Notice", "In-app purchases are not supported on this system/device.", { "OK" } )
end

-- Interact with IAP product data
local productData = require( "libs.productData" )
productData.setProductList( platform )

-- This is needed for the storeUI controls.
local storeUI = require( "libs.storeUI" )
storeUI.setPlatform( string.lower(platform) )
storeUI.setStore( store )

-- databox.gems = 100
-------------------------------------------------------------------------------
-- This callback is set up by store.init()
-------------------------------------------------------------------------------
local function transactionCallback( event )

	-- Log transaction info.
	print("***************************************************************************************")
	print( "transactionCallback: Received event " .. tostring( event.name ) )
	print( "state: " .. tostring( event.transaction.state ) )
	print( "errorType: " .. tostring( event.transaction.errorType ) )
	print( "errorString: " .. tostring( event.transaction.errorString ) )
	-- Apple pops up You're All set
	-- then this happens
	local startX, startY = display.contentCenterX, display.contentCenterY
	if #storeUI.spinners > 0 then
		for i = #storeUI.spinners, 1, -1 do
			local spinner = storeUI.spinners[i]
			startX, startY = spinner.x, spinner.y
			spinner:removeSelf()
			table.remove(storeUI.spinners, i)
		end
	end
	if event.transaction.state == "purchased" then
		storeUI.printToConsole( "Transaction successful!" )
		print("***************************************************************************************")
		print( "receipt: " .. tostring( event.transaction.receipt ) )
		print( "signature: " .. tostring( event.transaction.signature ) )
		print( "productIdentifier: " .. tostring( event.transaction.productIdentifier ) )
		print("***************************************************************************************")
		local product = event.transaction.productIdentifier
		if product == "com.BadMonkeySoftware.fireaway.25_gems_apple" or product == "com.badmonkeysoftware.fireaway.25_gems_google" then
			-- databox.gems = databox.gems + 25
			storeUI.addGemsFromPurchase(databox.gems, 25, startX, startY)
		elseif product == "com.BadMonkeySoftware.fireaway.75_gems_apple" or product == "com.badmonkeysoftware.fireaway.75_gems_google" then
			-- databox.gems = databox.gems + 75
			storeUI.addGemsFromPurchase(databox.gems, 75, startX, startY)
		elseif product == "com.BadMonkeySoftware.fireaway.200_gems_apple" or product == "com.badmonkeysoftware.fireaway.200_gems_google" then
			-- databox.gems = databox.gems + 200
			storeUI.addGemsFromPurchase(databox.gems, 200, startX, startY)
		elseif product == "com.BadMonkeySoftware.fireaway.500_gems_apple" or product == "com.badmonkeysoftware.fireaway.500_gems_google" then
			-- databox.gems = databox.gems + 500
			storeUI.addGemsFromPurchase(databox.gems, 500, startX, startY)
		end
	elseif  event.transaction.state == "restored" then
		-- Reminder: your app must store this information somewhere
		-- Here we just display some of it
		storeUI.printToConsole( "Restoring transaction:" ..
								"\n   Original ID: " .. tostring( event.transaction.originalTransactionIdentifier ) ..
								"\n   Original date: " .. tostring( event.transaction.originalDate ) )
		storeUI.printToConsole( "productIdentifier: " .. tostring( event.transaction.productIdentifier ) )
		print( "receipt: " .. tostring( event.transaction.receipt ) )
		print( "transactionIdentifier: " .. tostring( event.transaction.transactionIdentifier ) )
		print( "date: " .. tostring( event.transaction.date ) )
		print( "originalReceipt: " .. tostring( event.transaction.originalReceipt ) )

	elseif event.transaction.state == "consumed"  then
		-- Consume notifications is only supported by the Google Android Marketplace.
		-- Apple's app store does not support this.
		-- This is your opportunity to note that this object is available for purchase again.
		storeUI.printToConsole( "Consuming transaction:" ..
								"\n   Original ID: " .. tostring( event.transaction.originalTransactionIdentifier ) ..
								"\n   Original date: " .. tostring( event.transaction.originalDate ) )
		print( "productIdentifier: " .. tostring( event.transaction.productIdentifier ) )
		print( "receipt: " .. tostring( event.transaction.receipt ) )
		print( "transactionIdentifier: " .. tostring( event.transaction.transactionIdentifier ) )
		print( "date: " .. tostring( event.transaction.date ) )
		print( "originalReceipt: " .. tostring( event.transaction.originalReceipt ) )
		local product = event.transaction.productIdentifier
		if product == "com.badmonkeysoftware.fireaway.25_gems_google" then
			-- databox.gems = databox.gems + 25
			storeUI.addGemsFromPurchase(databox.gems, 25, startX, startY)
		elseif product == "com.badmonkeysoftware.fireaway.75_gems_google" then
			-- databox.gems = databox.gems + 75
			storeUI.addGemsFromPurchase(databox.gems, 75, startX, startY)
		elseif product == "com.badmonkeysoftware.fireaway.200_gems_google" then
			-- databox.gems = databox.gems + 200
			storeUI.addGemsFromPurchase(databox.gems, 200, startX, startY)
		elseif product == "com.badmonkeysoftware.fireaway.500_gems_google" then
			-- databox.gems = databox.gems + 500
			storeUI.addGemsFromPurchase(databox.gems, 500, startX, startY)
		end
	elseif  event.transaction.state == "refunded" then
		-- Refunds notifications is only supported by the Google Android Marketplace.
		-- Apple's app store does not support this.
		-- This is your opportunity to remove the refunded feature/product if you want.
		storeUI.printToConsole( "A previously purchased product was refunded by the store:" ..
								"\n	   For product ID = " .. tostring( event.transaction.productIdentifier ) )

	elseif event.transaction.state == "cancelled" then
		storeUI.printToConsole( "Transaction cancelled by user." )

	elseif event.transaction.state == "failed" then        
		storeUI.printToConsole( "Transaction failed, type: " .. 
			tostring( event.transaction.errorType ) .. " " .. tostring( event.transaction.errorString ) )
		
	else
		storeUI.printToConsole( "Unknown event" )
	end

	if store.availableStores.apple then
		-- Tell the store we are done with the transaction.
		-- If you are providing downloadable content, do not call this until
		-- the download has completed.
		store.finishTransaction( event.transaction )
	end
end
-- Connect to store at startup, if available.
if googleIAPvBilling then
	store.init( "google", transactionCallback )
	print( "Using Google's Android In-App Billing system." )
elseif store.availableStores.apple then
	store.init( "apple", transactionCallback )
	print( "Using Apple's In-App Purchase system." )
elseif platform == "simulator" then
	print ("Notice: " .. "In-app purchases are not supported in the Corona Simulator. Using dummy products.")
  	-- native.showAlert( "Notice", "In-app purchases are not supported in the Corona Simulator. Using dummy products.", { "OK" } )
else
  	native.showAlert( "Notice", "In-app purchases are not supported on this system/device.", { "OK" } )
end
-------------------------------------------------------------------------------
-- Handler to receive product information 
-- This callback is set up by store.loadProducts()
-------------------------------------------------------------------------------
local function onLoadProducts( event )
	-- Debug info for testing
	print( "In onLoadProducts()" )

	productData.setData( event, string.lower(platform))
end

-------------------------------------------------------------------------------
-- Displays in-app purchase options.
-- Loads product information from store if possible. 
-------------------------------------------------------------------------------
if env == "simulator" or store.isActive then
	if store.canLoadProducts then
		-- Property "canLoadProducts" indicates that localized product information such as name and price
		-- can be retrieved from the store (such as iTunes). Fetch all product info here asynchronously.
		print ( "Loading products from Real store" )
		store.loadProducts( productData.getList( ), onLoadProducts )
		print ( "After store.loadProducts, waiting for callback" )
	else
		-- Unable to retrieve products from the store because:
		-- 1) The store does not support apps fetching products, such as Google's Android Marketplace.
		-- 2) No store was loaded, in which case we could load dummy items or display no items to purchase
		-- So, we'll call onLoadProducts with the dummy product data
		print ( "Loading dummy products" )
		local dummyData = 
		{
			name = tostring( productData.getDummyProductList( ) ),
			products = productData.getDummyProductData( ),
			invalidProducts = {},
		}
		onLoadProducts( dummyData )
	end
end

local aspectRatio = display.pixelHeight / display.pixelWidth
print("Aspect Ration: ", aspectRatio)
print("Scale Factor: ", display.pixelWidth / display.actualContentWidth )
-- For if your app is in landscape orientation:
print( "Landscape Scale Factor: ",display.pixelWidth / display.actualContentHeight )
print("pixelHeight: " .. display.pixelHeight)
print("pixelWidth: " .. display.pixelWidth)
print("screenOriginX: " , display.screenOriginX, "screenOriginY: " , display.screenOriginY)
print("actualContentWidth (_ContentWidth): " .. display.actualContentWidth)
print("(_CenterX): " .. display.actualContentWidth / 2)
print("actualContentHeight (_ContentHeight): " .. display.actualContentHeight)
print("(_CenterX): " .. display.actualContentHeight / 2)
print("contentWidth: " .. display.contentWidth)
print("contentCenterX: " .. display.contentCenterX)
print("contentHeight: " .. display.contentHeight)
print("contentCenterY: " .. display.contentCenterY)
print("safeScreenOriginX: " .. display.safeScreenOriginX)
print("safeScreenOriginY: " .. display.safeScreenOriginY)
print("safeActualContentWidth: " .. display.safeActualContentWidth)
print("safeActualContentHeight: " .. display.safeActualContentHeight)

-- Create composer
local composer = require('composer')
composer.recycleOnSceneChange = true -- Automatically remove scenes from memory


-- Add support for back button on Android and Window Phone
-- When it's pressed, check if current scene has a special field gotoPreviousScene
-- If it's a function - call it, if it's a string - go back to the specified scene
if platform == 'Android' or platform == 'WinPhone' then
	Runtime:addEventListener('key', function(event)
		if event.phase == 'down' and event.keyName == 'back' then
			local scene = composer.getScene(composer.getSceneName('current'))
            if scene then
				if type(scene.gotoPreviousScene) == 'function' then
                	scene:gotoPreviousScene()
                	return true
				elseif type(scene.gotoPreviousScene) == 'string' then
					composer.gotoScene(scene.gotoPreviousScene, {time = 500, effect = 'slideRight'})
					return true
				end
            end
		end
	end)
end


-- Add support for controllers so the game is playable on Android TV, Apple TV and with a MFi controller
require('libs.controller') -- Activate by requiring


local colorPreference = system.getPreference( "app", "CurrentColorPack", "string" )
if colorPreference ~= nil then
	databox.colorTheme = colorPreference
	system.deletePreferences( "app", { "CurrentColorPack" } )
-- system.deletePreferences( "app", { "CurrentColorPack", "myNumber", "myString" } )
end
-- if colorPreference == nil and databox["colorTheme"] == nil then
-- 	print("Color Theme is nil")
-- 	databox.colorTheme = "Basic_ColorPack" 
-- else
-- 	print("Color Theme is not nil")
-- end
-- print("ColorTheme: " .. databox.colorTheme) 
-- PlayerPrefs.GetString ("CurrentColorPack", "Basic_ColorPack")
-- This library manages sound files and music files playback
-- Inside it there is a list of all used audio files
local audio = require('audio')
-- this allows music mixed with Apple Music playing too
-- if audio.getSessionProperty( audio.OtherAudioIsPlaying ) == 1 then
	audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
--    end
local sounds = require('libs.sounds')
sounds.isSoundOn = databox.isSoundOn
sounds.isMusicOn = databox.isMusicOn
-- sounds.isMusicOn = false

-- This library helps position elements on the screen during the resize event
require('libs.relayout')

-- This library deals with the overscan issue that is present on many TVs
local overscan = require('libs.overscan')
if databox.overscanValue then
	overscan.compensate(databox.overscanValue)
else
	overscan.compensate(1)
end

-- Read the preferences that were written to storage above
print("****************************************************************************************")
print("Setting Preferences....")
local BasicRings_BestScore = system.getPreference( "app", "BasicRings_BestScore", "number" )
if BasicRings_BestScore then
	print("BasicRings_BestScore: " .. BasicRings_BestScore)
	if BasicRings_BestScore > databox.BasicRingsHighScore then
		databox.BasicRingsHighScore = BasicRings_BestScore	
	end
end
local AdvancedRings_BestScore = system.getPreference( "app", "AdvancedRings_BestScore", "number" )
if AdvancedRings_BestScore then
	print("AdvancedRings_HighScore: " .. AdvancedRings_BestScore)
	if AdvancedRings_BestScore > databox.AdvancedRingsHighScore then
		databox.AdvancedRingsHighScore = AdvancedRings_BestScore	
	end
end
-- isSoundOn = true,
-- 	isMusicOn = true,
-- 	isHelpShown = false,
-- 	overscanValue = 0,
-- 	colorTheme = "Basic_ColorPack",
-- 	BasicRingsUnlocked = true,
-- 	 = 0,
-- 	AdvancedRingsUnlocked = true,
-- 	 = 0,
-- 	BasicColorPack = true,
-- 	SunriseColorPack = true,
-- 	SeashoreColorPack = true,
-- 	FallColorPack = true,
--     gems = 100
-- PlayerPrefs.SetInt ("isSoundEnabled", 0);
-- PlayerPrefs.SetInt ("isMusicEnabled", 0);
-- PlayerPrefs.SetInt ("Posted1stHighScore.Level." + bestScoreLevelName + "." + userId,1);
-- PlayerPrefs.SetInt("isRescued",1);
-- PlayerPrefs.SetString("videoLastPlayed", System.DateTime.Now.ToBinary().ToString());
-- PlayerPrefs.SetInt (currentLevel + "_BestScore", bestScore);
-- PlayerPrefs.SetInt ("LastScore", score);
-- PlayerPrefs.SetInt ("seenTutorialPart2", 1);
-- PlayerPrefs.SetInt ("seenTutorialPart1", 1);
-- PlayerPrefs.SetInt ("seenTutorialPart4",1);
-- PlayerPrefs.SetInt ("seenTutorialPart3",1);
-- PlayerPrefs.SetInt ("seenTutorialPart3.LifeGivenBack",1);
-- PlayerPrefs.SetInt (levelPackPurchased + ".Unlocked", 1);
-- PlayerPrefs.SetInt (colorPackPurchased + ".Unlocked", 1);
-- PlayerPrefs.SetInt ("AdvancedRings_LevelPack" + ".Unlocked", 1);
-- PlayerPrefs.SetInt ("currentGems", 100);
-- PlayerPrefs.SetInt ("BetaTester", 1);
-- PlayerPrefs.SetInt ("BetaTesterCheck", 1);
-- PlayerPrefs.SetInt ("BasicRings_LevelPack.Unlocked", 1);
-- PlayerPrefs.SetInt ("Basic_ColorPack" + ".Unlocked", 1);
-- PlayerPrefs.SetInt ("Sunrise_ColorPack" + ".Unlocked", 1);
-- PlayerPrefs.SetInt ("Seashore_ColorPack" + ".Unlocked", 1);
-- //	PlayerPrefs.SetInt ("AdvancedRings_LevelPack" + ".Unlocked", 0);

-- //   PlayerPrefs.SetInt ("Fall_ColorPack" + ".Unlocked", 0);
-- //	PlayerPrefs.SetInt ("UnlockAll_ColorPack.Unlocked", 0);
-- PlayerPrefs.SetInt ("currentGems", currentGems);
-- PlayerPrefs.SetInt ("InitialGemsGiven",1);
-- PlayerPrefs.SetInt ("currentLives", _currentLives);
-- //Set Current Color Theme and apply throughout game
-- PlayerPrefs.SetString ("CurrentColorPack", colorPackName);

-- PlayerPrefs.GetInt("UnlockAll_ColorPack.Unlocked", 0)
-- PlayerPrefs.GetString ("CurrentColorPack", "Basic_ColorPack")
-- PlayerPrefs.GetString ("videoLastPlayed", "not played")
print("****************************************************************************************")


-- function to suppress popup errors and log them
-- local function myUnhandledErrorListener( event )

--     local iHandledTheError = true

--     if iHandledTheError then
--         print( "Handling the unhandled error", event.errorMessage )
--     else
--         print( "Not handling the unhandled error", event.errorMessage )
--     end

--     return iHandledTheError
-- end

-- Runtime:addEventListener("unhandledError", myUnhandledErrorListener)

local function onSystemEvents( event ) 
    if ( event.type == "applicationStart" ) then
        gameCenter:init()
        -- Show menu scene
        composer.gotoScene("scenes.menu" );
		-- composer.gotoScene('scenes.game', {params = {level = "BasicRings"}})

    elseif event.type == "applicationResume" then
        gameCenter:init()
    end
    return true
end
Runtime:addEventListener( "system", onSystemEvents )
