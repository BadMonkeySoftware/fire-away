local _M = {}

function _M:init()

end
_M = {
    {
        name='SquareRing-2-Slots',
        rings = {"assets/game/basic/squareLeftSide.png", "assets/game/basic/squareRightSide.png"},
        width = 230,
        height = 230
    },
    {
        name='SquareRing-4-Sides',
        rings = {"assets/game/basic/squareLeft.png", "assets/game/basic/squareRight.png", "assets/game/basic/squareTop.png", "assets/game/basic/squareBottom.png"},
        width = 230,
        height = 230
    },
    {
        name='SquareRing-4-Corners',
        rings = {"assets/game/basic/squareTopLeft.png", "assets/game/basic/squareTopRight.png","assets/game/basic/squareBottomLeft.png", "assets/game/basic/squareBottomRight.png"},
        width = 230,
        height = 230
    },
    {
        name='CircleRing-2-Halves',
        rings = {"assets/game/basic/circleTop.png", "assets/game/basic/circleTopRight.png", "assets/game/basic/circleBottomLeft.png", "assets/game/basic/circleBottom.png"},
        width = 250,
        height = 250
    },
    {
        name='CircleRing-4-Cross', 
        rings = {"assets/game/basic/circleRight.png", "assets/game/basic/circleLeft.png", "assets/game/basic/circleTop.png", "assets/game/basic/circleBottom.png"},
        width = 250,
        height = 250
    },
    {
        name='CircleRing-2-C Shape',
        rings = {"assets/game/basic/circleLeft.png", "assets/game/basic/circleTopLeft.png", "assets/game/basic/circleTop.png", "assets/game/basic/circleTopRight.png", "assets/game/basic/circleBottomRight.png", "assets/game/basic/circleBottomLeft.png"},
        width = 250,
        height = 250
    },
}
return _M