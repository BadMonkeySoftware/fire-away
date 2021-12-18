-- Shade
-- Shades the background group and makes it impossible to touch.
-- Used to show the sidebar or the end level popup.
local display       = require('display')
local transition    = require('transition')
local relayout      = require('libs.relayout')

local _M = {}

function _M.newShade(group)
    local shade = display.newRect(group, display.contentCenterX, display.contentCenterY, relayout._W, relayout._H)
    shade:setFillColor(0) -- black
    shade.alpha = 0
    transition.to(shade, {time = 200, alpha = 0.5}) --fade in alpha
    
    -- prevent tapping
    function shade:tap() 
        return true
    end
    shade:addEventListener("tap")

    -- prevent touching
    function shade:touch()
        return true
    end
    shade:addEventListener("touch")

    function shade:hide()
        transition.to(self, {time = 200, alpha = 0, onComplete = function(object) 
            if object then
                object:removeSelf()
                object = nil
            end
        end})
    end

    relayout.add(shade)
    
    return shade
end

return _M