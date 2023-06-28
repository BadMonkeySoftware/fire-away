-- This a helper buffer scene.
-- It reloads game scene (game scene can't reload by itself) and shows a loading animation.

local composer      = require('composer')
local transition    = require('transition')
local native        = require('native')
local display       = require('display')
local relayout      = require('libs.relayout')
local timer         = require('timer')
local ui            = require('classes.ui')

local scene = composer.newScene()

function scene:create()
    local _W, _H, _CX, _CY = relayout._W, relayout._H, relayout._CX, relayout._CY
    -- local _ballImage 		= ui.game.ball

    local group = self.view

    local level = 1
    local score = 3000
    local gameWon = true
    local stars = 2
    local background = display.newRect(group, display.contentCenterX, display.contentCenterY, _W, _H)
    background.fill = {
        type = 'gradient',
        color1 = {0.2, 0.45, 0.8},
        color2 = {0.35, 0.4, 0.5}
    }
    relayout.add(background)

    local label = display.newText({
		parent = group,
		text = 'LOADING...',
		x = _W - 32, y = _H - 32,
		font = native.systemFontBold,
		fontSize = 32
	})
    label.anchorX, label.anchorY = 1, 1
    relayout.add(label)

    -- circle parts rotating
    local circleGroup = display.newGroup()
    circleGroup.x = display.contentCenterX
    circleGroup.y = display.contentCenterY
    group:insert(circleGroup)
	relayout.add(circleGroup)
    local circlePart = display.newImageRect(circleGroup,"assets/game/circle-300.png",125,125)
    circlePart.anchorX = 0.5
    circlePart.anchorY = 1
    local circlePart2 = display.newImageRect(circleGroup,"assets/game/circle-300.png",125,125)
    circlePart2.anchorX = 0.5
    circlePart2.anchorY = 1
    circlePart2.rotation = -45
    local circlePart3 = display.newImageRect(circleGroup,"assets/game/circle-300.png",125,125)
    circlePart3.anchorX = 0.5
    circlePart3.anchorY = 1
    circlePart3.rotation = -225
    local circlePart4 = display.newImageRect(circleGroup,"assets/game/circle-300.png",125,125)
    circlePart4.anchorX = 0.5
    circlePart4.anchorY = 1
    circlePart4.rotation = -180

    transition.to(circleGroup, {time = 1000, rotation=360, iterations=-1})
end

function scene:show(event)
    if event.phase == 'will' then
        -- print("Params: " .. event.params)
        -- Preload the scene
        -- composer.loadScene('scenes.game', {params = event.params})
        composer.loadScene('scenes.game', {params = {level = event.params.level}})
    elseif event.phase == 'did' then
        -- Show it after a moment
        print("Loading " .. event.params.level)
        timer.performWithDelay(100, function()
            composer.gotoScene('scenes.game', {params = {level = event.params.level}})
        end)
    end
end

scene:addEventListener('create')
scene:addEventListener('show')

return scene
