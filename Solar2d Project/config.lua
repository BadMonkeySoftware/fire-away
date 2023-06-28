--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

local display      = require('display')
local system        = require('system')
local aspectRatio = display.pixelHeight / display.pixelWidth
-- local width = 1080 -- appleTV

local platform = system.getInfo("platform")
local width = 320
local height = width * aspectRatio

height = 480
if string.lower(platform) == 'tvos' then
	-- width = 1080
	-- height = 1080
	local normalW, normalH = 640, 960
	local w, h = display.pixelWidth, display.pixelHeight
	local scale = math.max(normalW / w, normalH / h)
	w, h = w * scale, h * scale
	width, height = w, h
end
-----
-- new for TV
----
application =
{
	content =
	{
		width = width,
		height = height, 
		scale = "letterbox",
		fps = 60,
		xAlign = "center",
		yAlign = "center",

		imageSuffix =
		{
			    ["@2x"] = 2.0,
				["@4x"] = 4.0
		},

	},
	notification = 
	{
		types = 
		{
			"badge",
			"sound",
			"alert"
		}
	},
	license = 
	{
		google = 
		{
			key = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnvC3qvVTnWY4TaYP0fLJtWJ9gmlVzwuUZzPGBwnAyc5XrDeI904ekypwDbpxmjlcef2qp8Tu0FdL/qQCDKVcNKuopzLhGLBTHIhXFfa4wRla8udceyl/N6QmT7n8Ja8xn26qO4sb3bdkXXoMmMijY3XgNW5sjWpwBlaG6flcJIgj6RxxzG9g3j7rr5LgViGopzjRwThUF33N9CuMq8CAxOTvkw0WoIZ9FAh3yGDaZHH7BVLRqMt361/kHPrcmkNx0qLqTaxIiFGMX6f/6UxPolCbY43l4f4Yx1qJ31V10gmD37QU3nNyYbGm9Vwt0ge0las3Er7ybHyum9UpI2EcEwIDAQAB",
		}
	}
}
