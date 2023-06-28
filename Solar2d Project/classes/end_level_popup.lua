-- simple popup window with buttons to restart or go to menu
-- if not classic then show stars with score

-- Import
-- include Corona's libraries
local composer      = require('composer')
local transition    = require('transition')
local easing        = require('easing')
local display      	= require('display')
local widget        = require('widget')
local graphics 		= require('graphics')
local system        = require('system')
-- End Level Popup

-- include helper libraries
local utilities 	= require "classes.utilities"
local controller    = require('libs.controller')
local databox       = require('libs.databox')
local json			= require('json')
local overscan      = require('libs.overscan')
local relayout      = require('libs.relayout')
local sounds        = require('libs.sounds')
local ui            = require('classes.ui')
local gameOptions   = require('classes.game_options')
local gameCenter    = require("classes.helper_gamecenter")
-- This is needed for the storeUI controls.
local storeUI       = require('libs.storeUI')
local _M = {}

local newShade = require('classes.shade').newShade

-- 
-- Set variables

function _M.newEndLevelPopup(params)
    local _ContentWidth, _ContentHeight, _CenterX, _CenterY = relayout._W, relayout._H, relayout._CX, relayout._CY

    local platform = system.getInfo("platform")
    if string.lower(platform) == 'tvos' then
        _ContentWidth = 320
        _ContentHeight = 570
    end
	local popup = display.newGroup()
	params.group:insert(popup)
	popup.anchorChildren = true

	popup.x, popup.y = display.contentCenterX, display.contentCenterY
    local visualButtons = {}
    local panelHeight = 470
	-- print ("endLevelpanelHeight: ", panelHeight)

    local panelWidth = _ContentWidth * 0.9
	if string.lower(platform) == 'tvos' then
		panelWidth = 320
	end
	-- leaderboardId
	local leaderBoardId = params.levelId .. "_BestScore"
    local colorTable = {}
    for i, v in ipairs(gameOptions.colors) do
        if v.name == databox.colorTheme then
            colorTable = gameOptions.colors[i].colors
        end
    end
    -- background
    local background = display.newRect(popup,display.contentCenterX,display.contentCenterY,_ContentWidth,_ContentHeight + 50 );
    background:setFillColor(unpack(utilities:hex2rgb(colorTable[1], 1)) )

    -- title
    local title = display.newEmbossedText({parent=popup, text="GAME OVER", x=display.contentCenterX, y=storeUI.gemsIcon.y + 50, font=ui.fonts.mainFont, fontSize=50,align="center"})
    title.anchorY = 0
    title:setFillColor(unpack(utilities:hex2rgb(colorTable[4])))
    local color = 
    {
        highlight = { r=.27, g=.27, b=.27 },
        shadow = utilities:hex2rgb("#000")
    }
    title:setEmbossColor( color )
    -- score
    local scoreLabel = display.newEmbossedText({parent=popup, text="SCORE : ", x=display.contentCenterX, y=title.y + 100, font=ui.fonts.dinPro, fontSize=20,align="center"})
    scoreLabel.anchorX = 1
    scoreLabel:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
    scoreLabel:setEmbossColor( color )
    local scoreText = display.newEmbossedText({parent=popup, text="", x=display.contentCenterX, y=scoreLabel.y, font=ui.fonts.dinPro, fontSize=20,align="center"})
    scoreText.anchorX = 0
    scoreText:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
    scoreText:setEmbossColor( color )
    local bestScoreLabel = display.newEmbossedText({parent=popup, text="BEST : ", x=display.contentCenterX, y=scoreLabel.y + 30, font=ui.fonts.dinPro, fontSize=20,align="center"})
    bestScoreLabel.anchorX = 1
    bestScoreLabel:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
    bestScoreLabel:setEmbossColor( color )
    local bestScoreText = display.newEmbossedText({parent=popup, text="", x=display.contentCenterX, y=bestScoreLabel.y, font=ui.fonts.dinPro, fontSize=20,align="center"})
    bestScoreText.anchorX = 0
    bestScoreText:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
    bestScoreText:setEmbossColor( color )
	-- High Score Text -- only if current score is better than Best
	local lblHighScore = display.newEmbossedText({parent=popup, text="NEW HIGH SCORE!!", x=display.contentCenterX, y=bestScoreLabel.y + 30, font=ui.fonts.dinPro, fontSize=20,align="center"})
	lblHighScore:setEmbossColor( color )
	lblHighScore.alpha = 0

	local rescueLabel = display.newEmbossedText({parent=popup, text="One More Life:", x=display.contentCenterX, y=lblHighScore.y + 30, font=ui.fonts.dinPro, fontSize=22,align="center"})
	local notEnoughGemsLabel = display.newEmbossedText({parent=popup, text="Not Enough Gems to Get One More Try", width=225, x=display.contentCenterX, y=lblHighScore.y + 50, font=ui.fonts.dinPro, fontSize=22,align="center"})
    notEnoughGemsLabel.alpha = 0
	local noLivesLeftLabel = display.newEmbossedText({parent=popup, text="No More Lives Left", x=display.contentCenterX, y=rescueLabel.y, font=ui.fonts.dinPro, fontSize=22,align="center"})
	noLivesLeftLabel:setFillColor(unpack(utilities:hex2rgb(colorTable[4])))
	noLivesLeftLabel.alpha = 0
	local noLivesLeftLabel2 = display.newEmbossedText({parent=popup, text="Please Try Again", x=display.contentCenterX, y=noLivesLeftLabel.y + 25, font=ui.fonts.dinPro, fontSize=22,align="center"})
	noLivesLeftLabel2:setFillColor(unpack(utilities:hex2rgb(colorTable[4])))
	noLivesLeftLabel2.alpha = 0
    local rescueButton = widget.newButton({
        shape="rect",
        label="Spend 10 Gems",
        labelAlign = "left",
        labelColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#A2A2A2", 1) },
        font= ui.fonts.dinPro,
        fontSize = 20,
        fillColor = { default=utilities:hex2rgb(colorTable[1], 1), over=utilities:hex2rgb(colorTable[5], .75) },
        strokeWidth = 2,
        strokeColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#A2A2A2", .75) },
        width=250, height = 50,
        x = display.contentCenterX, y = rescueLabel.y + 55,
        -- defaultFile = ui.buttons.home,
        -- overFile = ui.buttons.homeOver,
        onRelease = function()
            print("Goto Main Menu")
            sounds.play("tap")
			popup:hide()
        end
    })
    popup:insert(rescueButton)
    local storeButton = widget.newButton({
        shape="rect",
        label="Go To Store To Buy More",
        labelAlign = "left",
        labelColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#A2A2A2", 1) },
        font= ui.fonts.dinPro,
        fontSize = 20,
        fillColor = { default=utilities:hex2rgb(colorTable[1], 1), over=utilities:hex2rgb(colorTable[5], .75) },
        strokeWidth = 2,
        strokeColor = { default=utilities:hex2rgb("#FFFFFF", 1), over=utilities:hex2rgb("#A2A2A2", .75) },
        width=250, height = 50,
        x = display.contentCenterX, y = rescueLabel.y + 55,
        -- defaultFile = ui.buttons.home,
        -- overFile = ui.buttons.homeOver,
        onRelease = function()
            print("Goto Store")
            sounds.play("tap")
            composer.showOverlay("scenes.store",{time=50, effect = 'fromBottom'});
        end
    })
    popup:insert(storeButton)
    storeButton.isVisible = false

    local xOffset = 60
    -- bottom buttons
    local homeButton = widget.newButton({
        x = display.contentCenterX - 85, y = _ContentHeight * .9 + display.screenOriginY,
        width = 50, height = 50,
        defaultFile = ui.buttons.home,
        overFile = ui.buttons.homeOver,
        onRelease = function()
            print("Goto Main Menu")
            sounds.play("tap")
            composer.gotoScene("scenes.menu",{time = 500, effect = 'slideRight'});
        end
    })
    popup:insert(homeButton)
    local restartButton = widget.newButton({
        x = homeButton.x + xOffset, y = homeButton.y,
        width = 45, height = 45,
        defaultFile = ui.buttons.refresh,
        overFile = ui.buttons.refreshOver,
        onRelease = function()
            print("Goto info")
            sounds.play("tap")
            composer.gotoScene('scenes.reload_game', {params = {level = params.levelId}})
            -- composer.gotoScene("scenes.reload_game",{time = 500, effect = 'slideRight'});
        end
    })
    popup:insert(restartButton)
    local achievementsButton = widget.newButton({
        x = restartButton.x + xOffset, y = homeButton.y,
        width = 50, height = 50,
        defaultFile = ui.buttons.trophy,
        overFile = ui.buttons.trophyOver,
        onRelease = function()
            print("Goto achievements")
            sounds.play("tap")
            -- Display the player's achievements
            gameCenter:openAchievements()
        end
    })
    popup:insert(achievementsButton)
    local leaderboardButton = widget.newButton({
        x = achievementsButton.x + xOffset, y = homeButton.y,
        width = 50, height = 50,
        defaultFile = ui.buttons.leaderboard,
        overFile = ui.buttons.leaderboardOver,
        onRelease = function()
            print("Goto leaderboard")
            sounds.play("tap")
            -- Display the leaderboards
            gameCenter:openLeaderboard(nil)
        end
    })
    popup:insert(leaderboardButton)
	function popup:showHideButtons()
        if databox.gems <10 then
			rescueButton.isVisible = false
            storeButton.isVisible = true
            rescueLabel.alpha = 0
            notEnoughGemsLabel.alpha = 1
        else
            rescueButton.isVisible = true
            storeButton.isVisible = false
            rescueLabel.alpha = 1
            notEnoughGemsLabel.alpha = 0
		end
    end
	function popup:show(options)
		-- Shade dims the background and makes it impossible to touch
		self.shade = newShade(params.group)
		self:toFront()
		local levelLabel = params.levelId .. "HighScore"
		local bestScore = 0
		if options.noMoreLives then
			rescueButton.isVisible = false
			rescueLabel.alpha = 0
			noLivesLeftLabel.alpha = 1
			noLivesLeftLabel2.alpha = 1
        else
            popup:showHideButtons()
		end
		if databox[levelLabel] then
			bestScore = databox[levelLabel]
		else
			bestScore = tonumber(options.score)
			databox[levelLabel] = bestScore
		end
		
		
		if options.score > bestScore then
			-- Show Confetti
			lblHighScore.alpha = 1
			-- up and down Movement
			transition.to(lblHighScore, {time=300, xScale=1.5,  yScale=1.5})
			transition.to(lblHighScore, {time=300, xScale=1,    yScale=1, delay=300})
			transition.to(lblHighScore, {time=300, xScale=1.5,  yScale=1.5, delay=600})
			transition.to(lblHighScore, {time=300, xScale=1,    yScale=1, delay=900})
			transition.to(lblHighScore, {time=300, xScale=1.5,  yScale=1.5, delay=1200})
			transition.to(lblHighScore, {time=300, xScale=1,    yScale=1, delay=1500})
			-- set databox to new score
			bestScore = tonumber(options.score)
			databox[levelLabel] = bestScore
		end
		print("Your Score: " .. options.score)
		scoreText.text = "" .. tostring(options.score)
		bestScoreText.text = "" .. tostring(bestScore)
		-- Submit to Leaderboard
		gameCenter:submitScore(options.score, leaderBoardId)
		-- Submit Achievement
		if options.score >= 1 or bestScore >= 1 then
			gameCenter:submitAchievement("achievement_starter__get_1_point")			
		end
		if options.score >= 15 or bestScore >= 15 then
			gameCenter:submitAchievement("achievement_getting_there__15_points")			
		end
		if options.score >= 50 or bestScore >= 50 then
			gameCenter:submitAchievement("achievement_all_star__50_points")			
		end
		if options.score >= 100 or bestScore >= 100 then
			gameCenter:submitAchievement("achievement_fire_away_master__100_points")			
		end

		controller.setVisualButtons(visualButtons)
		self.x = display.contentCenterX
		transition.to(self, {time = 50, alpha = 1, transition = easing.outExpo, onComplete = function()
			relayout.add(self)
		end})
	end
    popup.alpha = 0
	-- hide function for hiding
    function popup:hide()
		-- if saveData then
		-- 	popup.SaveData = true
		-- else
		-- 	popup.SaveData = nil
		-- end
		-- hide shader
        self.shade:hide()
		-- hide popup
        transition.to(self, params.hideParams or {time = 50, alpha = 0, transition = easing.outExpo, onComplete = params.onHide})
    end
    return popup
end
return _M