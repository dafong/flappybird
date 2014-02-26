--
-- Created by IntelliJ IDEA.
-- User: xinlei.fan
-- Date: 13-4-19
-- Time: 上午10:26
-- To change this template use File | Settings | File Templates.
--
---
-- Global Scene Controller,manage transition between scene, shared data, and scene's life-circle
--


Soso.system = Soso.system or {}

Soso.system.SceneController = {

	--首页
    __indexScene       = "index",

    --当前页
    __currentScene     = "",

    --导演
	director          = cc.Director:getInstance(),

    visibleSize       = cc.Director:getInstance():getVisibleSize(),

    visibleOrigin     = cc.Director:getInstance():getVisibleOrigin(),

    inchanging        = false,

    __history         = {},

    --Route Table
	sceneTable         = {},

    moduleInterceptor = {},

    appWebView        = nil,

    _initRouteTable = function(self)
        self:route( "index",         Soso.scenes.IndexScene )
        self:route( "play" ,         Soso.scenes.PlayScene)
    end,

    route = function(self,path,sceneClass)
        if sceneClass then self.sceneTable[path] = sceneClass end
    end,

    registerModuleInterceptor = function(self,moduleName,interceptors )
        if interceptors then self.moduleInterceptor[moduleName] = interceptors end
    end,

    routeWithModule = function(self,modulename,callback)
        local router = {
            route = function(that,subpath,cls)
                self:route(modulename.."/"..subpath,cls)
            end,
            interceptor = function(that,interceptors)
                self:registerModuleInterceptor(modulename,interceptors)
            end
        }
        callback(router)
    end,
   
    registerEngineEventLisener = function()

    end,

    _createScene = function(self,sceneName,params)
        local sceneClass = self.sceneTable[sceneName]
        local instance  = sceneClass:new(params)
        if instance == nil then
            error("want to switch to a scene which we can't create instance: ["..sceneName.."]",2)
            return  nil
        else
            return instance
        end
    end,

    clearInChangeFlagWhenTimeout = function(self,secs)
        self.changingTimeoutId = U:setTimeout(function() self.inchanging = false  end,secs)
    end,

    stopTimeoutFunc           = function(self)
        U:clearInterval(self.changingTimeoutId)
    end,

    switchScene = function(self,params,onEnter)
        local scene    = self.director:getRunningScene()
        if params.newscene == true then
            scene    = cc.Scene:create()
            scene:registerScriptHandler(function(eventType)
                if eventType     == 'enter' then
                    onEnter(scene)
                end
            end)
        else
            scene:removeAllChildren(true)
            onEnter(scene)
        end

        if params.newscene then
            self.director:replaceScene(scene)
        end
        return scene
    end,

    switchTo = function(self,inSceneName,params)
            if self.inchanging then return end
            params = params or {}
            U:fdebug("Soso.App" , "BEGIN TO","----------------"..inSceneName.."----------------")
            self.inchanging = true
            self:clearInChangeFlagWhenTimeout(5)
            self:clearInSwitchScene(inSceneName)
            self:switchScene(params,function(scene)
                self:initializeScene(inSceneName,params,scene)
                self:stopTimeoutFunc()
                self.inchanging = false
                U:fdebug("Soso.App" , "END TO","----------------"..inSceneName.."----------------\n")
            end)
    end,

    initializeScene       = function(self,inSceneName,params,scene)
        U:debug("[Soso.App] [chage scene]  "..self.__currentScene.." --> ".. inSceneName)
        self.__currentScene = inSceneName

        ---TODO create the in scene instance
        local inScene =  self:_createScene(inSceneName,params)
        local sceneNode = inScene.rootNode
        sceneNode:setAnchorPoint(cc.p(0,0))
        sceneNode:setPosition(cc.p(self.visibleOrigin.x,self.visibleOrigin.y))
        scene:addChild(sceneNode)
    end,


    clearInSwitchScene    = function(self,inSceneName)
        ---TODO stop all actions in running
        self.director:getActionManager():pauseAllRunningActions()
        self.director:getActionManager():removeAllActions()
    end,

    getCommonResources = function(self)
        return {
            --            "common_box",
            --            "common_button"
        }
    end,

    load = function(self)
        self:_initRouteTable()
        self:registerEngineEventLisener()
        local scene1 = cc.Scene:createWithPhysics()
        --scene1:getPhysicsWorld():setDebugDrawMask(cc.PhysicsWorld.DEBUGDRAW_ALL);
        scene1:getPhysicsWorld():setGravity(cc.p(0,-900))
        scene1:registerScriptHandler(function(eventType)
           if eventType == "enter" then
               self:switchTo(self.__indexScene,{__indexScene = true})
           end
        end)
        local scene    = self.director:getRunningScene()
        if scene then
            self.director:replaceScene(scene1)
        else
            self.director:runWithScene(scene1)
        end
    end,

    getCurrentScene = function(self)
        return self.__currentScene
    end,


}

--add a shortcat for this
Soso.App = Soso.system.SceneController
