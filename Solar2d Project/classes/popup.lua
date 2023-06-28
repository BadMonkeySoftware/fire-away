
-- End Level Popup
-- simple popup window with buttons to restart or go to menu
-- if not classic then show stars with score

-- Import
-- include Corona's libraries
local composer      = require('composer')
local transition    = require('transition')
local easing        = require('easing')
local widget        = require('widget')
local graphics 		= require('graphics')
local display      	= require('display')
-- include helper libraries
local utilities 	= require "classes.utilities"
local ui        	= require "classes.ui"
local controller    = require('libs.controller')
local databox       = require('libs.databox')
local json			= require('json')
local overscan      = require('libs.overscan')
local relayout      = require('libs.relayout')
local sounds        = require('libs.sounds')
local gameOptions   = require('classes.game_options')
local game_options  = require('classes.game_options')

local _M = {}

local newShade = require('classes.shade').newShade

-- 
-- Set variables

function _M.newPopup(params)
    local _ContentWidth, _ContentHeight, _CenterX, _CenterY = relayout._W, relayout._H, relayout._CX, relayout._CY

	local popup = display.newGroup()
	params.group:insert(popup)
	popup.anchorChildren = true
	popup.visualButtons = {}
	popup.x, popup.y = params.x, params.y
    local panelHeight = params.height
    local panelWidth = params.width
    local titleFontSize = params.fontSize or 35
	local titleHeight = 50
	print("titleHeight ", titleHeight)
    -- popup.x = -_ContentWidth
    local greyHeight = panelHeight - titleHeight
    local greyY = math.round(panelHeight - greyHeight) / 2 

    local colorTable = {}
    for i, v in ipairs(gameOptions.colors) do
        if v.name == databox.colorTheme then
            colorTable = gameOptions.colors[i].colors
        end
    end
	local background = display.newRoundedRect(popup,0,0,panelWidth,panelHeight,12)
	background:setFillColor(unpack(utilities:hex2rgb(colorTable[1])))
	
	if params.showClose then
		popup.closeButton = widget.newButton(
			{
				width = 18,
				height = 18,
				x = panelWidth / 2 - 20, y = -(greyHeight / 2),
				defaultFile = ui.buttons.crossWhite,
				overFile = ui.buttons.crossGrey,
				onRelease = function()
					print("test")
					sounds.play('tap')
					popup:hide(false)
				end
			}
		)
		popup:insert(popup.closeButton)
	end
	popup.title = display.newEmbossedText({
		parent = popup,
		text = params.title,
		x = 0, y = -(greyHeight / 2),
		font = ui.fonts.mainFont,
		fontSize = titleFontSize
	})

	-- hide for start
	popup.alpha = 0

	local superParams = params
	function popup:show(params)
		-- Shade dims the background and makes it impossible to touch
		self.shade = newShade(superParams.group)
		self:toFront()

        -- set visual buttons
        controller.setVisualButtons(popup.visualButtons)
        -- transition.to(self, {time = 250, x = superParams.x, alpha = 1, transition = easing.outExpo})
        transition.to(self, superParams.showParams or {time = 250, xScale = 1, yScale = 1, alpha = 1, transition = easing.outExpo})
    end
    -- hide function for hiding
    function popup:hide(saveData)
		if saveData then
			popup.SaveData = true
		else
			popup.SaveData = nil
		end
		-- hide shader
        self.shade:hide()
		-- hide popup
        transition.to(self, superParams.hideParams or {time = 250, xScale = 0, yScale = 0, alpha = 0, transition = easing.outExpo, onComplete = params.onHide})
    end
    return popup
end
return _M