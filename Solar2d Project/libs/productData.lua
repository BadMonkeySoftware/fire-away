-------------------------------------------------------------------------------
--  Product IDs should match the In App Purchase products set up in iTunes Connect.
--  We cannot get them from the iTunes store so here they are hard coded;
--  your app could obtain them dynamically from your server.
-------------------------------------------------------------------------------
local native = require('native')

-- Create table for productData library
local productData = {}

-- To be assigned a product list from one of the arrays below after we've connected to a store.
-- Will be nil if no store is supported on this system/device.
local currentProductList = nil

-- Tables with data on valid and invalid products
-- Assigned by productData.setData()
productData.validProducts = {}
productData.invalidProducts = {}


-- Product IDs for the "apple" app store.
local appleProductList =
{
	-- These Product IDs must already be set up in your store
	-- We'll use this list to retrieve prices etc. for each item
	-- Note, this simple test only has room for about 6 items, please adjust accordingly
	-- The iTunes store will not validate bad Product IDs.
	-- "com.BadMonkeySoftware.fireaway.AdvancedRings_LevelPack_apple",
	-- "com.BadMonkeySoftware.fireaway.Fall_ColorPack_apple",
	-- "com.BadMonkeySoftware.fireaway.UnlockAll_ColorPack_apple",
	"com.BadMonkeySoftware.fireaway.25_gems_apple",
	"com.BadMonkeySoftware.fireaway.75_gems_apple",
	"com.BadMonkeySoftware.fireaway.200_gems_apple",
	"com.BadMonkeySoftware.fireaway.500_gems_apple",
}

-- Non-subscription product IDs for the "google" Android Marketplace.
local googleProductList =
{
	-- Real Product IDs for the "google" Android Marketplace.
	-- A managed product that can only be purchased once per user account. Google Play manages the transaction info.
    -- "com.badmonkeysoftware.fireaway.advancedrings_levelpack_google",
	-- "com.badmonkeysoftware.fireaway.fall_colorpack_google",
    -- "com.badmonkeysoftware.fireaway.unlockall_colorpack_google",

	-- A product that isn't managed by Google Play. The app must store transaction info itself.
	-- In Google IAP V3, unmanaged products are treated like managed products and need to be explicitly consumed.
	"com.badmonkeysoftware.fireaway.25_gems_google",
	"com.badmonkeysoftware.fireaway.75_gems_google",
	"com.badmonkeysoftware.fireaway.200_gems_google",
	"com.badmonkeysoftware.fireaway.500_gems_google",

	-- A bad product ID. For testing what actually happens in this case.
	"com.badmonkeysoftware.fireaway.100_gems_google",
}

-- Dummy product list to display in the simulator.
local dummyProductList =
{
	"dummy.25gems",
	"dummy.75gems",
	"dummy.200gems",
	"dummy.500gems",
	-- "dummy.advancedRings",
	-- "dummy.fallColorPack",
	-- "dummy.unlockAll",
}
function productData.getDummyProductList( )
	return dummyProductList
end

-- Dummy product data for use in the simulator
local dummyProductData = 
{ 
	{
		title = "25 Gems",
		description = "Receive 25 Gems which can be used to get extra lives when available.",
		productIdentifier = dummyProductList[1],
        price = "$0.99",
        localizedPrice = "$0.99",
	},

	{
		title = "75 Gems",
		description = "Receive 75 Gems which can be used to get extra lives when available.",
		productIdentifier = dummyProductList[2],
        price = "$1.99",
        localizedPrice = "$1.99",
	},
	{
		title = "200 Gems",
		description = "Receive 200 Gems which can be used to get extra lives when available.",
		productIdentifier = dummyProductList[1],
        price = "$3.99",
        localizedPrice = "$3.99",
	},

	{
		title = "500 Gems",
		description = "Receive 500 Gems which can be used to get extra lives when available.",
		productIdentifier = dummyProductList[2],
        price = "$6.99",
        localizedPrice = "$6.99",
	},
	-- {
	-- 	title = "Advanced Rings Level",
	-- 	description = "More rings that are a little more challenging. Triangle, Octagon and Star",
	-- 	productIdentifier = dummyProductList[3],
    --     price = "$0.99",
    --     localizedPrice = "$0.99"
	-- },
	-- {
	-- 	title = "Fall Color Theme",
	-- 	description = "Change all screens to this season color theme.",
	-- 	productIdentifier = dummyProductList[3],
    --     price = "$0.99",
    --     localizedPrice = "$0.99"
	-- },
	-- {
	-- 	title = "Unlock All Color Packs",
	-- 	description = "This will unlock all available and future Color Theme Packs.",
	-- 	productIdentifier = dummyProductList[3],
    --     price = "$2.99",
    --     localizedPrice = "$2.99"
	-- },
}
-------------------------------------------------------------------------------
-- Returns the product data for the dummy product list.
-------------------------------------------------------------------------------
function productData.getDummyProductData( )
	return dummyProductData
end

-------------------------------------------------------------------------------
-- Returns the product list for the platform we're running on.
-------------------------------------------------------------------------------
function productData.getList()
	return currentProductList
end

-------------------------------------------------------------------------------
-- Sets the product data that we wish to use for this platform.
-------------------------------------------------------------------------------
function productData.setData( data, platform)
    if ( data.isError ) then
      print( "Error in loading products " 
        .. data.errorType .. ": " .. data.errorString )
      return
    end
    print( "data, data.name", data, data.name )
    print( data.products )
    print( "#data.products", #data.products )
    --   io.flush( )  -- remove for production

    -- save for later use
    productData.validProducts = {}
    if ( platform == "android" ) then
        for i,n in ipairs(googleProductList) do
            for x = 1, #data.products do
                local product = data.products[x]
                if product.productIdentifier == n then
                    table.insert(productData.validProducts, product)
                end
            end
        end
    elseif ( platform == "ios" or platform == "tvos" or platform == "macos" ) then
        for i,n in ipairs(appleProductList) do
            for x = 1, #data.products do
                local product = data.products[x]
                if product.productIdentifier == n then
                    table.insert(productData.validProducts, product)
                end
            end
        end
    elseif ( platform == "simulator" ) then
        productData.validProducts = data.products
    else
    end
--   productData.validProducts = data.products
  productData.invalidProducts = data.invalidProducts
end

-------------------------------------------------------------------------
-- Sets the product list that we wish to use for this platform.
-------------------------------------------------------------------------------
function productData.setProductList( platform )
	-- Set up the product list for this platform
	if ( string.lower(platform) == "android" ) then
	    currentProductList = googleProductList
	elseif ( string.lower(platform) == "ios" or string.lower(platform) == "tvos" or string.lower(platform) == "macos" ) then
		currentProductList = appleProductList
	elseif ( platform == "simulator" ) then
		currentProductList = dummyProductList
	else
		-- Platform doesn't support IAP
		native.showAlert( "Notice", "In-app purchases are not supported on this system/device.", { "OK" } )
	end
end


-- Return product data library for external use
return productData