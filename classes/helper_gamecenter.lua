--
-- Import

local json = require("json")
local utilities = require("classes.utilities")
local system = require("system")
--
--

local env = system.getInfo("environment")
local platform = string.lower(system.getInfo("platform"))
-- "platform" returns the operating system platform tag, which can be one of:

-- android — all Android devices and the Android emulator.
-- ios — all iOS devices and the Xcode iOS Simulator.
-- macos — macOS desktop apps.
-- tvos — Apple's tvOS (Apple TV).
-- win32 — Win32 desktop apps.
-- html5 — HTML5 apps.
local gamecenter = {}
gamecenter.gpgs = nil           -- Google plugin.gpgs.v2 placeholder
gamecenter.gameNetwork = nil    -- ios game network placeholder
local googleLeaderBoards = {
    ["BasicRings_BestScore"]= "CgkIw9DzursTEAIQBg",
    ["AdvancedRings_BestScore"]= "CgkIw9DzursTEAIQCA"
}
local googleAchievements = {
    ["achievement_starter__get_1_point"]             = "CgkIw9DzursTEAIQAQ",
    ["achievement_getting_there__15_points"]         = "CgkIw9DzursTEAIQAg",
    ["achievement_all_star__50_points"]              = "CgkIw9DzursTEAIQAw",
    ["achievement_fire_away_master__100_points"]     = "CgkIw9DzursTEAIQBA",
    ["achievement_10_points_without_losing_a_life"]  = "CgkIw9DzursTEAIQBQ",
    ["achievement_25_points_without_losing_a_life"]  = "CgkIw9DzursTEAIQCQ"
}
    
local leaderboard_basic_rings_high_score            = "CgkIw9DzursTEAIQBg"; -- <GPGSID>
local leaderboard_advanced_rings_high_score         = "CgkIw9DzursTEAIQCA"; -- <GPGSID>

local achievement_starter__get_1_point              = "CgkIw9DzursTEAIQAQ"; -- <GPGSID>
local achievement_getting_there__15_points          = "CgkIw9DzursTEAIQAg"; -- <GPGSID>
local achievement_all_star__50_points               = "CgkIw9DzursTEAIQAw"; -- <GPGSID>
local achievement_fire_away_master__100_points      = "CgkIw9DzursTEAIQBA"; -- <GPGSID>
local achievement_10_points_without_losing_a_life   = "CgkIw9DzursTEAIQBQ"; -- <GPGSID>
local achievement_25_points_without_losing_a_life   = "CgkIw9DzursTEAIQCQ"; -- <GPGSID>
--
-- Google Play Games listener
gamecenter.gpgsInitListener = function(event)

    if not event.isError then
        if ( event.name == "login" ) then
            gamecenter.loggedIntoGC = true
            print( json.prettify(event) )
        end
    end
end
function gamecenter.initCallback( event )
    if ( event.type == "showSignIn" ) then
        -- This is an opportunity to pause your game or do other things you might need to do while the Game Center Sign-In controller is up.
    elseif ( event.data ) then
        gamecenter.loggedIntoGC = true
        -- native.showAlert( "Success!", "", { "OK" } )
    end
end

--
-- Submit score
function gamecenter:submitScore(score, leaderBoardId)

    if env == "device" then
        if gamecenter.gpgs then
            gamecenter.gpgs.leaderboards.submit({
                leaderboardId = googleLeaderBoards[leaderBoardId],
                score = score,
                listener = function() print("submittedScore") end
            })
        elseif gamecenter.gameNetwork then
            gamecenter.gameNetwork.request( "setHighScore", {
                    localPlayerScore = { category=leaderBoardId, value=score },
                    listener = function( event )
                        if ( event.type == "setHighScore" ) then
                            print("submittedScore")
                        end
                    end
            })
        end
    end
end

--
-- Open leaderboards
function gamecenter:openLeaderboard(leaderBoardId)

    if env == "device" then
        if gamecenter.gpgs then
            gamecenter.gpgs.leaderboards.show( {leaderboardId = leaderBoardId} )
        elseif gamecenter.gameNetwork then

            gamecenter.gameNetwork.show( "leaderboards", {
                leaderboard = {category = leaderBoardId },
                listener = gamecenter.onGameNetworkPopupDismissed } )
        else
            gamecenter:init()
        end
    end
end
--
-- Open Achievements
function gamecenter:openAchievements()

    if env == "device" then
        if gamecenter.gpgs then
            gamecenter.gpgs.achievements.show(gamecenter.onGameNetworkPopupDismissed )
        elseif gamecenter.gameNetwork then
            gamecenter.gameNetwork.show( "achievements", { listener=gamecenter.onGameNetworkPopupDismissed } )
        else
            gamecenter:init()
        end
    end
end
--
-- Submit Achievement
function gamecenter:submitAchievement(achievement)

    if env == "device" then
        if gamecenter.gpgs then
            gamecenter.gpgs.achievements.unlock({
                achievementId = googleAchievements[achievement],
                listener = function() print("unlockAchievement: " .. achievement) end
            })
        elseif gamecenter.gameNetwork then
            gamecenter.gameNetwork.request( "unlockAchievement", {
                    achievement =
                    {
                        identifier = achievement,
                        percentComplete = 100,
                        showsCompletionBanner = true
                    },
                    listener = function( event )
                        if ( event.type == "unlockAchievement" ) then
                            print("unlockAchievement: " .. achievement)
                        end
                    end
            })
        end
    end
end

function gamecenter.onGameNetworkPopupDismissed( event )
    -- Game Center popup was closed
    for k,v in pairs( event ) do
        print( k,v )
    end
end
--
-- Init
function gamecenter:init()
    print("GameCenter init")
    if env == "device" then
        if platform == 'ios' or platform == 'macos' or platform == 'tvos' then
            gamecenter.gameNetwork = require( "gameNetwork" )
            gamecenter.gameNetwork.init( "gamecenter", gamecenter.initCallback )
        elseif platform == 'android' then
            gamecenter.gpgs = require("plugin.gpgs.v2")
            gamecenter.gpgs.login({ userInitiated = true, listener = gamecenter.gpgsInitListener })
        end
    end
end

--
-- Return
return gamecenter