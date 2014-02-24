--
-- Created by IntelliJ IDEA.
-- User: fxl
-- Date: 14-2-24
-- Time: 上午2:16
-- To change this template use File | Settings | File Templates.
--

Soso.scenes.PlayScene = Soso.scenes.Scene:extend({

    initWithCode = function(self,options)
        self:_super(options)
        self:addBg()
        self:addScore()
        self:addTip()
        self:addTutorial()
        self:addBird()
        self:addTouchLayer()
        self.isBegin = false
        self:addEdgeBox()
        self:addLandBox()
    end,

    addBg = function(self)
        local bg  = cc.Sprite:createWithSpriteFrameName("bg_night");
        bg:setScaleX(self._winsize.width/bg:getContentSize().width)
        bg:setScaleY(self._winsize.height/bg:getContentSize().height)
        bg:setAnchorPoint(ccp(0,0))
        bg:setPosition(ccp(0,0))

        local land1 = cc.Sprite:createWithSpriteFrameName("land")
        land1:getTexture():setAliasTexParameters()
        land1:setAnchorPoint(ccp(0,0))
        land1:setScaleY(1.15)
        land1:setPosition(ccp(0,0))

        local move1 = cc.MoveBy:create(3,ccp(-336,0))
        local seq1  = cc.Sequence:create(move1,cc.CallFunc:create(function()
            land1:setPosition(ccp(0,0))
        end))

        land1:runAction(cc.RepeatForever:create(seq1))


        local land2 = cc.Sprite:createWithSpriteFrameName("land")
        land2:setAnchorPoint(ccp(0,0))
        land2:setScaleY(1.15)
        land2:setPosition(ccp(336,0))

        local move2 = cc.MoveBy:create(3,ccp(-336,0))
        local seq2  = cc.Sequence:create(move2,cc.CallFunc:create(function()
            land2:setPosition(ccp(336,0))
        end))
        land2:runAction(cc.RepeatForever:create(seq2))
        self.rootNode:addChild(bg)
        self.rootNode:addChild(land2,1)
        self.rootNode:addChild(land1,1)
    end,

    addBird = function(self)
        local animation = cc.Animation:create()
        animation:setDelayPerUnit(0.2)
        animation:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("bird1_0"))
        animation:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("bird1_1"))
        animation:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("bird1_2"))


        self.bird = cc.Sprite:createWithSpriteFrameName("bird1_0")
        self.bird:setAnchorPoint(ccp(0.5,0.5))
        self.bird:setPosition(ccp(self._winsize.width/2 - 55,self._winsize.height-265))
        self.bird:runAction(cc.RepeatForever:create( cc.Animate:create(animation)))


        local up  = cc.MoveBy:create(0.4,ccp(0,10))
        local down= cc.MoveBy:create(0.4,ccp(0,-10))
        local seq = cc.Sequence:create(up,down)
        local repeate = cc.RepeatForever:create(seq)
        repeate:setTag(2)
        self.bird:runAction(repeate)

        local body = cc.PhysicsBody:createCircle(self.bird:getContentSize().width / 2-10)
        self.bird:setPhysicsBody(body)
        body:setEnable(false)
        body:setAngularVelocityLimit(0.36)
        self.rootNode:addChild(self.bird,3)
    end,

    addScore = function(self)
        self.score = cc.Sprite:createWithSpriteFrameName("font_048")
        self.score:setAnchorPoint(ccp(0.5,1))
        self.score:setPosition(ccp(self._winsize.width/2,self._winsize.height - 80))
        self.rootNode:addChild( self.score,2)
    end,

    addTip  = function(self)
        self.tip = cc.Sprite:createWithSpriteFrameName("text_ready")
        self.tip:setAnchorPoint(ccp(0.5,1))
        self.tip:setPosition(ccp(self._winsize.width/2,self._winsize.height - 160))
        self.rootNode:addChild(self.tip)
    end,

    addTutorial  = function(self)
        self.tutorial = cc.Sprite:createWithSpriteFrameName("tutorial")
        self.tutorial:setAnchorPoint(ccp(0.5,1))
        self.tutorial:setPosition(ccp(self._winsize.width/2,self._winsize.height - 240))
        self.rootNode:addChild(self.tutorial)
    end,


    addTouchLayer = function(self)
        self.control = cc.Layer:create()
        self.control:setTouchEnabled(true)
        self.control:registerScriptTouchHandler(function(type,x,y)
            if type == "began" then
                if not self.isBegin then
                    self:startGame()
                end
                self:appForceToBird()
            end
        end)
        self.rootNode:addChild(self.control)
    end,

    appForceToBird = function(self)
        local body = self.bird:getPhysicsBody()
        body:setVelocity(ccp(0,10))
        body:applyForce(cc.p(0,100),body:getPosition())
    end,

    startGame = function(self)
        self.isBegin = true
        self.tip:runAction(cc.FadeOut:create(0.4))
        self.tutorial:runAction(cc.FadeOut:create(0.4))

        self:startPipe()

        self.bird:stopActionByTag(2)
        self.bird:getPhysicsBody():setEnable(true)


    end,


    addEdgeBox = function(self)
        local node = cc.Node:create()
        node:setPosition(ccp(self._winsize.width/2,self._winsize.height/2))
        local body = cc.PhysicsBody:createEdgeBox(self._winsize)
        node:setPhysicsBody(body)
        self.rootNode:addChild(node)
    end,


    addLandBox = function(self)
        local node = cc.Node:create()
        node:setPosition(cc.p(self._winsize.width/2,128/2))
        local body = cc.PhysicsBody:createEdgeBox(CCSize(320,128))
        node:setPhysicsBody(body)
        self.rootNode:addChild(node)
    end,


    getRootNode = function(self)
        if not self.rootNode then
            self.rootNode = cc.Node:create()
            self.rootNode:setContentSize(self._winsize)
        end
        return self.rootNode
    end,

    startPipe = function(self)
        self.intervalId = U:setInterval(function()
            local height = self._winsize.height - 128 - 200

            local upheight = math.random(70,height-70)

            local downheight= height - upheight;


            local pipe_down = cc.Sprite:createWithSpriteFrameName("pipe_down")
            local pipeSize  = pipe_down:getContentSize()

            pipe_down:setAnchorPoint(ccp(0,0))
            pipe_down:setPosition(ccp(self._winsize.width,self._winsize.height-downheight))
            self.rootNode:addChild(pipe_down)

            local movedown = cc.MoveBy:create(4,ccp(-448,0))
            local seqdown = cc.Sequence:create(movedown,cc.CallFunc:create(function()
                pipe_down:removeFromParentAndCleanup(true)
            end))
            pipe_down:runAction(seqdown)

            local pipe_up   = cc.Sprite:createWithSpriteFrameName("pipe_up")
            pipe_up:setAnchorPoint(ccp(0,1))
            pipe_up:setPosition(ccp(self._winsize.width,self._winsize.height-downheight-200))
            self.rootNode:addChild(pipe_up)


            local moveup = cc.MoveBy:create(4,ccp(-448,0))
            local sequp = cc.Sequence:create(moveup,cc.CallFunc:create(function()
                pipe_up:removeFromParentAndCleanup(true)
            end))
            pipe_up:runAction(sequp)
        end,1.5)
    end




})