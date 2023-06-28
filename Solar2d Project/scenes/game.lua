--
-- Import
local display       = require('display')
local composer      = require('composer')
local native        = require('native')
local physics       = require('physics')
local system        = require('system')
local widget        = require('widget')
local timer         = require('timer')
local transition    = require('transition')
local graphics      = require('graphics')
-- local gameNetwork   = require("gameNetwork")
local gameCenter    = require("classes.helper_gamecenter")
local relayout      = require('libs.relayout')
local mathHelper 	= require('libs.mathHelper') -- extra math functions
local sounds        = require('libs.sounds')
local utilities     = require('classes.utilities')
local ui            = require('classes.ui')
local gameOptions   = require('classes.game_options')
local databox       = require('libs.databox') -- Persistant storage, track level completion and settings
local controller    = require('libs.controller') -- Gamepad support
local eachframe     = require('libs.eachframe') -- enterFrame manager
local storeUI       = require('libs.storeUI')

-- 
-- Set variables
local rings1
local rings2
local rings3
local rings4
local background = {}
-- Layout
local _ContentWidth, _ContentHeight, _CenterX, _CenterY = relayout._W, relayout._H, relayout._CX, relayout._CY

-- Scene
local scene = composer.newScene()

-- Groups
local _groupMain 

--
-- Local functions

local newPauseMenu = require('classes.pause_screen').newPauseMenu -- pause menu dialog
local newEndLevelPopup = require('classes.end_level_popup').newEndLevelPopup -- Win/Lose dialog windows

local superSelf = scene
local function onLocalCollision( self, event )

    if ( event.phase == "began" ) then
        -- print( self.name .. ": collision began with " .. event.other.name )
        local hitX, hitY = event.x, event.y
        display.remove(event.target)
        local particle = display.newImageRect(_groupMain, "assets/game/particle-circle.png",20,20)
        particle.x, particle.y = hitX, hitY
        particle.alpha = 0.5
        transition.scaleBy(particle, {time= 250, xScale = 10, yScale=10})
        transition.scaleBy(particle, {delay=250, time= 250, xScale = 0, yScale=0, alpha=0, onComplete=function()
            particle:removeSelf()
        end})
        if event.other.name == 'safeZone' then
            sounds.play("score")
            -- increase score
            scene.score = scene.score + 1
            scene.scoreLabel.text = "" .. scene.score
            -- if score is multiple of 5 then speed up
            if scene.score % 5 == 0 then
                scene:UpdateBackgroundColors()
                scene:GetRandomRings()
                -- scene:RotateRings(false)
            end
        elseif event.other.name == 'rings' then
            sounds.play("impact")
            -- decrement lives
            scene.lives = scene.lives - 1
            -- check if game over
            if scene.lives <= 0 then
                scene.heartsText.text = "0"
                scene:gameOver()
            else
                scene.heartsText.text = "" .. scene.lives
            end
        end
        return true
    elseif ( event.phase == "ended" ) then
        print( self.name .. ": collision ended with " .. event.other.name )
        return true
    end
end
local function gameArea(event)
    local force = 200
    if event.phase == "began"  then
        scene:setIsPaused(scene.isPaused)
        -- print("Fire Ball")
        -- print(scene.cannon.rotation)
        local dir = math.rad(scene.cannon.rotation-90)
        local xDest = scene.cannon.x - (math.cos(math.rad(scene.cannon.rotation+90)) * 1600 )
        local yDest = scene.cannon.y - (math.sin(math.rad(scene.cannon.rotation+90)) * 1600 )
        -- print("xDest: " .. xDest .. "      yDest: " .. yDest)
        local ball = display.newImageRect(_groupMain, "assets/game/ball.png",20,20)
        ball.x, ball.y = display.contentCenterX, display.contentCenterY
        ball:setFillColor(unpack(utilities:hex2rgb("#FFFFFF", 1)))
        ball.name = 'ball'
        physics.addBody(ball, { density=1.0, friction=0.3, bounce=0.2, filter={ groupIndex = -2 } })
        ball.isBullet = true
        ball.collision = onLocalCollision
        ball:addEventListener("collision")
        -- timer.performWithDelay(1000,function() 
            -- ball:applyLinearImpulse(xDest,yDest,ball.x, ball.y)
            ball:applyLinearImpulse(force * math.cos(dir), force * math.sin(dir), ball.x, ball.y)
        -- end)
        return true
    end
end
--
-- Scene events functions
function scene:create( event )
    self.currentTimer = nil
    -- physics.setDrawMode( "normal" )  -- The default Corona renderer (no collision outlines)
    -- physics.setDrawMode( "hybrid" )  -- Overlays collision outlines on normal display objects
    -- physics.setDrawMode( "debug" )   -- Shows collision engine outlines only
    physics.start()
    physics.setGravity(0, 0) -- Default gravity is too boring
    physics.setReportCollisionsInContentCoordinates( true )
    -- physics.setTimeStep( 1/60 )
    -- physics.setScale(30);
    physics.setTimeScale( 0.1 )
    print("scene: create - game")
    -- _groupMain = display.newGroup()
    -- self.view:insert(_groupMain)
    local group = self.view
	self.levelId = event.params.level
    self.speedIncrement = 0
    local safeArea = display.newRect(
        display.safeScreenOriginX,
        display.safeScreenOriginY,
        display.safeActualContentWidth,
        display.safeActualContentHeight
    )
    safeArea.strokeWidth = 1
    safeArea:setFillColor(1,1,1,0)
    safeArea:translate( safeArea.width*0.5, safeArea.height*0.5 )
    -- safeArea.name = "safeZone"
    -- physics.addBody( safeArea,"static")
    print("safeArea=> w: " .. safeArea.width .. "   h: " .. safeArea.height)

    -- background
    self.background = display.newRect(group,display.contentCenterX,display.contentCenterY,_ContentWidth,_ContentHeight );
    scene:UpdateBackgroundColors()
    self.physicsGroup = display.newGroup()
    group:insert(self.physicsGroup)
    local uiGroup = display.newGroup()
    group:insert(uiGroup)
    _groupMain = display.newGroup()
    group:insert(_groupMain)
    -- top UI
    -- local gemsIcon = display.newImageRect(uiGroup, ui.icons.gem, 35, 31)
    -- -- 16.457142857142857
    -- gemsIcon.x = 20
    -- gemsIcon.y = 10 + display.safeScreenOriginY
    -- gemsIcon.anchorY = 0
    -- gemsIcon.anchorX = 0
    -- self.gemsText = display.newText({parent=uiGroup, text="" .. databox.gems, x=gemsIcon.x + 40 , y=gemsIcon.y-3, font = ui.fonts.dinPro, fontSize = 25 })
    -- self.gemsText.anchorX = 0
    -- self.gemsText.anchorY = 0

    -- Hearts
    self.lives = 5
    self.usedExtraLife = false
    local heartIcon = display.newImageRect(uiGroup,ui.icons.heart, 35, 35)
    heartIcon.x = storeUI.gemsIcon.x
    heartIcon.y = storeUI.gemsIcon.y + 40
    heartIcon.anchorY = 0
    heartIcon.anchorX = 0
    self.heartsText = display.newText({parent=uiGroup, text="" .. self.lives, x=heartIcon.x + 40 , y=heartIcon.y, font = ui.fonts.dinPro, fontSize = 25 })
    self.heartsText.anchorX = 0
    self.heartsText.anchorY = 0

    -- Score
    self.score = 0
    self.scoreLabel = display.newText({parent=uiGroup, text="" .. self.score, x=display.contentCenterX , y=50 + display.safeScreenOriginY, font = ui.fonts.dinPro, fontSize = 30 });

	-- Preload End Level Popup and PauseMenu
    self.endLevelPopup = newEndLevelPopup({group = group, levelId = self.levelId, onHide = function ()
        self.usedExtraLife = true
        self.lives = 1
        self.heartsText.text = "" .. self.lives
        databox.gems = databox.gems - 10
        -- self.gemsText.text = "" .. databox.gems
        storeUI.updateGemsText(databox.gems)
        self:setIsPaused(false)
        controller.setVisualButtons()
    end})
    self.pauseMenu = newPauseMenu({group = group,title='PAUSED!', levelId = self.levelId, onHide = function ()
        self:setIsPaused(false)
        controller.setVisualButtons()
    end})
    -- Pause Button
    self.pauseButton = widget.newButton({
        x= _ContentWidth - 40, y = 40 + display.safeScreenOriginY, width = 40, height=40,
        defaultFile = ui.buttons.pause, overFile = ui.buttons.pauseOver,
        onRelease = function()
            sounds.play("tap")
            self.pauseMenu:show()
            self:setIsPaused(true)
        end
    })
    uiGroup:insert(self.pauseButton)

    -- push pause and end level Menu to front
	self.pauseMenu:toFront()
    self.endLevelPopup:toFront()

    -- Rotating shooter
    self.cannon = display.newImageRect(self.physicsGroup,ui.game.shooter,50,50)
    -- physics.addBody(self.cannon, "dynamic", { radius = 10, filter={ groupIndex = -2 }})
    self.cannon.x = display.contentCenterX
    self.cannon.y = display.contentCenterY
    -- start rotating cannon
    local cannonSpeed = 50
    transition.to(self.cannon, {time = 4000, rotation=360, iterations=-1, tag="GameTrans"})
    -- self.cannon.angularVelocity = cannonSpeed

	-- make safeZone boundaries

	local topLine = display.newRect(self.physicsGroup, display.contentCenterX, display.safeScreenOriginY, display.safeActualContentWidth, 1)
    -- topLine:setFillColor(unpack(_gameAreaColor))
	topLine.name = 'safeZone'
	topLine.alpha = 0
	local bottomLine = display.newRect(self.physicsGroup, display.contentCenterX, display.safeActualContentHeight, display.safeActualContentWidth, 1)
	bottomLine.name = 'safeZone'
    bottomLine.alpha = 0
	local leftLine = display.newRect(self.physicsGroup, display.contentCenterX - display.safeActualContentWidth / 2 + 1, display.contentCenterY, 1, display.safeActualContentHeight)
	leftLine.name = 'safeZone'
    leftLine.alpha = 0
	local rightLine = display.newRect(self.physicsGroup, display.contentCenterX + display.safeActualContentWidth / 2 + -1 , display.contentCenterY, 1, display.safeActualContentHeight)
	rightLine.name = 'safeZone'
    rightLine.alpha = 0
	physics.addBody(topLine, "static")
	physics.addBody(bottomLine, "static")
	physics.addBody(leftLine, "static")
	physics.addBody(rightLine, "static")

    -- Rotating rings own class?
    -- circle parts rotating
    local circleGroup = display.newGroup()
    group:insert(circleGroup)
    self.rings = {}
    --ringController:getNewRing()
    self.loadedRings = require("levels." .. self.levelId)
    scene:GetRandomRings()

	self.background:addEventListener("touch", gameArea) -- for ios touch

    -- transition.to(circleGroup, {time = 4000, rotation=-360, iterations=-1})
    -- uiGroup:toFront()
    safeArea.alpha = 0
end
function scene:GetRandomRings()
    for x = #self.rings, 1, -1 do
        local ring = self.rings[x]
        ring:removeSelf()
    end
    self.rings = {}
    local randomNum = math.random( 1, #self.loadedRings)
    -- randomNum = 1
    local selectedRing = self.loadedRings[randomNum]
    if selectedRing.name == self.currentRing then
        if randomNum == #self.loadedRings then
            randomNum = randomNum - 1
        else
            randomNum = randomNum + 1
        end
        selectedRing = self.loadedRings[randomNum]
    end
    self.currentRing = selectedRing.name
    timer.performWithDelay(10,function ()
        for i = 1, #selectedRing.rings, 1 do
            local r = selectedRing.rings[i]
            local ringOutline = graphics.newOutline( 2, r )
            local ring = display.newImageRect(self.physicsGroup, r, selectedRing.width, selectedRing.height)
            ring.x = display.contentCenterX 
            ring.y = display.contentCenterY
            ring.name = "rings"
            physics.addBody( ring,"static", {outline = ringOutline} )
            table.insert(self.rings, ring)
        end
        scene:RotateRings(false)
    end)
    
end
function scene:RotateRings(firstTime)
    local minTimer = 1000
    local maxTimer = 7000
    local increment = 900
    if self.currentTimer == nil then
        self.currentTimer = maxTimer
    else
        -- self.currentTimer = self.currentTimer - 500
        if self.currentTimer <= 1600 then
            self.currentTimer = self.currentTimer - 100
        else
            self.currentTimer = self.currentTimer - increment
        end
        self.currentTimer = mathHelper.clamp(self.currentTimer, minTimer, maxTimer) 
    end
    print("Timer: " .. self.currentTimer)
    local rotation = -360
    -- self.speedIncrement = self.speedIncrement + 1
    for i = 1, #self.rings, 1 do
        local ring = self.rings[i]
        timer.performWithDelay(10,function ()
            transition.cancel(ring)
            -- ring.rotation = 0
            if firstTime == false then
                rotation = ring.rotation - 360--(self.speedIncrement * 360)
            end
            transition.to(ring, {time = self.currentTimer, rotation=rotation, iterations=-1, tag="GameTrans"})
        end)
    end
end
function scene:UpdateBackgroundColors()
    print("ColorTheme: " .. databox.colorTheme)
    local colorTable = {}
    for i, v in ipairs(gameOptions.colors) do
        if v.name == databox.colorTheme then
            colorTable = gameOptions.colors[i].colors
        end
    end
    local randomIndex = math.random( 1,5)
    self.background:setFillColor(unpack(utilities:hex2rgb(colorTable[randomIndex], 1)) )
end

function scene:storeWasHidden()
    print("Store was hidden. refresh whatever")
    self.endLevelPopup:showHideButtons()
    -- storeUI.hideGems()
    -- storeUI.showGems()
end
function scene:setIsPaused(isPaused)
	self.isPaused = isPaused
	-- self.cannon.isPaused = self.isPaused -- Pause adding trajectory points
	if self.isPaused then
        transition.pause("GameTrans")
		physics.pause()
	else
		physics.start()
        transition.resume("GameTrans")
	end
end
function scene:gameOver()
    if not self.isPaused then
        -- print("Params: " .. tostring(gameWon) )
        print("YOU LOSE")
        sounds.play('lose')
        scene:setIsPaused(true)
        self.endLevelPopup:show({score=scene.score, noMoreLives = self.usedExtraLife})
        -- databox save level

    end
end
function scene:show( event )
    if ( event.phase == "will") then
    elseif ( event.phase == "did" ) then 
    end
      
end

function scene:hide( event )
    if event.phase == 'will' then
		eachframe.remove(self)
		controller.onMotion = nil
		controller.onRotation = nil
		controller.onKey = nil
		controller.onKeyUp = nil
		if self.endLevelCheckTimer then
			timer.cancel(self.endLevelCheckTimer)
		end
        if self.shootTimer then
            print("Cancelling timer")
            timer.cancel(self.game.shootTimer)
        end
	elseif event.phase == 'did' then
		physics.stop()
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