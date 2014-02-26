--
-- Created by IntelliJ IDEA.
-- User: fxl
-- Date: 14-2-23
-- Time: 下午6:56
-- To change this template use File | Settings | File Templates.
--

require "Cocos2d"
require "GuiConstants"
-- cclog
cclog = function(...)
    print(string.format(...))
end

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    cclog("----------------------------------------")
    cclog("LUA ERROR: " .. tostring(msg) .. "\n")
    cclog(debug.traceback())
    cclog("----------------------------------------")
end


local function main()
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    math.randomseed (os.time())
    require "ui.Class"
    require "ui.UIComponent"
    require "ui.Utils"
    require "ui.SceneController"
    require "ui.Scene"
    require "ui.Button"
    require "IndexScene"
    require "PlayScene"
    cc.SpriteFrameCache:getInstance():addSpriteFrames("atlas.plist")
    Soso.App:load()
end

xpcall(main, __G__TRACKBACK__)
