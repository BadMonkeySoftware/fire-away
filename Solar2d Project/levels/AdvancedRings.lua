local _M = {}

function _M:init()

end
_M = {
    {
        name='TriangleRing-3-Sides',
        rings = {"assets/game/advanced/triagSideLeft.png", "assets/game/advanced/triagSideRight.png", "assets/game/advanced/triangleSideBottom.png"},
        width = 250,
        height = 250
    },
    {
        name='TriangleRing-3-Corners',
        rings = {"assets/game/advanced/triagTopCorner.png", "assets/game/advanced/triagLeftCorner.png", "assets/game/advanced/triagRightCorner.png"},
        width = 250,
        height = 250
    },
    {
        name='TriangleRing-2-Sides',
        rings = {"assets/game/advanced/triagSideLeftCombined.png", "assets/game/advanced/triagSideRightCombined.png"},
        width = 250,
        height = 250
    },
    {
        name='OctogonRing-3-Openings',
        rings = {"assets/game/advanced/oct1.png", "assets/game/advanced/oct2.png", "assets/game/advanced/oct3.png", "assets/game/advanced/oct5.png", "assets/game/advanced/oct7.png"},
        width = 250,
        height = 250
    },
    {
        name='OctogonRing-2-Halves',
        rings = {"assets/game/advanced/oct2.png", "assets/game/advanced/oct3.png", "assets/game/advanced/oct6.png", "assets/game/advanced/oct7.png"},
        width = 250,
        height = 250
    },
    {
        name='OctogonRing-2-C Shape',
        rings = {"assets/game/advanced/oct1.png", "assets/game/advanced/oct2.png", "assets/game/advanced/oct3.png", "assets/game/advanced/oct4.png", "assets/game/advanced/oct6.png", "assets/game/advanced/oct8.png"},
        width = 250,
        height = 250
    },
    {
        name='StarRing-1-OpeningSide',
        rings = {"assets/game/advanced/starTopRight.png", "assets/game/advanced/starBottomRight.png", "assets/game/advanced/starBottomLeft.png", "assets/game/advanced/starTopLeft.png"},
        width = 250,
        height = 250
    },
    {
        name='StarRing-2-OpeningSide',
        rings = {"assets/game/advanced/starBottomRight.png", "assets/game/advanced/starBottomLeft.png", "assets/game/advanced/starTopLeft.png"},
        width = 250,
        height = 250
    },
    {
        name='OctogonRing-2-SidesTogether',
        rings = {"assets/game/advanced/starTopRight.png", "assets/game/advanced/starBottomLeft.png", "assets/game/advanced/starTopLeft.png"},
        width = 250,
        height = 250
    },
}
return _M