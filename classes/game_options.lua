
local gameOptions = {}
gameOptions.states = {

    WAITING_FOR_PLAYER_INPUT = 0,
    PLAYER_IS_AIMING = 1,
    BALLS_ARE_RUNNING = 2,
    ARCADE_PHYSICS_IS_UPDATING = 3,
    PREPARING_FOR_NEXT_MOVE = 4,
    STOPPING_BALLS = 5,
    POWERUPS_LOADING = 6
}
gameOptions.colors = {
    {name = "Basic_ColorPack",      colors = {"#03D7D8", "#FF3E40", "#D1DD01", "#F75A00", "#22D668"} },
    {name = "Sunrise_ColorPack",    colors = {"#BF3C3E", "#D94748", "#F89152", "#DDB732", "#B1CAB5"} },
    {name = "Seashore_ColorPack",   colors = {"#59DEEE", "#7EDACB", "#63AFAE", "#DBC9B1", "#C2B49D"} },
    {name = "Fall_ColorPack",       colors = {"#A02408", "#D45C11", "#733549", "#4C1C0F", "#DA9418"} }
}
gameOptions.constants = {
    TVOS_REVIEW_URL = "https://itunes.apple.com/app/fire-away/id1132722499?mt=8",
    REVIEW_URL = "http://badmonkeysoftware.com/fire-away-review/",
    SUPPORT_URL = "mailto:support@badmonkeysoftware.com",
    MOREAPPS_URL = "http://badmonkeysoftware.com/"
}
gameOptions.options= {

    -- score panel height / game height
    scorePanelHeight=0.08,

    -- launch panel height / game height
    launchPanelHeight=0.18,

    -- ball size / game width
    ballSize=0.04,

    -- ball speed, in pixels/second
    ballSpeed=800,
    ballSpeedTV=2000,
    -- block slots on a line
    blocksPerLine=11,
    -- blocksPerLine=7, original
    -- blockLines high
    blockLinesHigh=14,
    -- blockLines=8, //original
    -- max amount of blocks per line
    maxBlocksPerLine=6,
    -- number of balls to start
    numberOfBalls=6,

    -- //probability 0 -> 100 of having an extra ball in each line
    extraBallProbability=60,
    -- predictive trajectory length, in pixels
    trajectoryLength=1000
}
return gameOptions