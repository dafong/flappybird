--
-- Created by IntelliJ IDEA.
-- User: fxl
-- Date: 14-2-24
-- Time: 上午2:16
-- To change this template use File | Settings | File Templates.
--
require "AudioEngine"
Soso.scenes.PlayScene = Soso.scenes.Scene:extend({

    initWithCode = function(self,options)
        self:_super(options)
        self.bgs = { "bg_day" , "bg_night" }
        self.birds = { "bird0_","bird1_","bird2_", }
        self.pipes = {}
        self.count = 0
        self.isOver = false
        self:addBg()
        self:addScore()
        self:addTip()
        self:addTutorial()
        self:addBird()
        self:addTouchLayer()
        self.isBegin = false
        self:addEdgeBox()
        self:addLandBox()
        self.pipewidth =  cc.Sprite:createWithSpriteFrameName("pipe_down"):getContentSize().width

    end,

    addBg = function(self)
        local bg  = cc.Sprite:createWithSpriteFrameName(self.bgs[math.random(1,2)]);
        bg:setScaleX(self._winsize.width/bg:getContentSize().width)
        bg:setScaleY(self._winsize.height/bg:getContentSize().height)
        bg:setAnchorPoint(cc.p(0,0))
        bg:setPosition(cc.p(0,0))

        self.land1 = cc.Sprite:createWithSpriteFrameName("land")
        self.land1:getTexture():setAliasTexParameters()
        self.land1:setAnchorPoint(cc.p(0,0))
        self.land1:setScaleY(1.15)
        self.land1:setPosition(cc.p(0,0))

        local move1 = cc.MoveBy:create(3,cc.p(-336,0))
        local seq1  = cc.Sequence:create(move1,cc.CallFunc:create(function()
            self.land1:setPosition(cc.p(0,0))
        end))

        self.land1:runAction(cc.RepeatForever:create(seq1))


        self.land2 = cc.Sprite:createWithSpriteFrameName("land")
        self.land2:setAnchorPoint(cc.p(0,0))
        self.land2:setScaleY(1.15)
        self.land2:setPosition(cc.p(336,0))

        local move2 = cc.MoveBy:create(3,cc.p(-336,0))
        local seq2  = cc.Sequence:create(move2,cc.CallFunc:create(function()
            self.land2:setPosition(cc.p(336,0))
        end))
        self.land2:runAction(cc.RepeatForever:create(seq2))
        self.rootNode:addChild(bg)
        self.rootNode:addChild(self.land2,1)
        self.rootNode:addChild(self.land1,1)
    end,

    addBird = function(self)
        local animation = cc.Animation:create()
        animation:setDelayPerUnit(0.15)
        local name =  self.birds[math.random(1,3)]
        animation:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(name.."0"))
        animation:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(name.."1"))
        animation:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(name.."2"))


        self.bird = cc.Sprite:createWithSpriteFrameName(name.."0")
        self.bird:setAnchorPoint(cc.p(0.5,0.5))
        self.bird:setPosition(cc.p(self._winsize.width/2 - 55,self._winsize.height-265))
        self.bird:runAction(cc.RepeatForever:create( cc.Animate:create(animation)))


        local up  = cc.MoveBy:create(0.4,cc.p(0,10))
        local down= cc.MoveBy:create(0.4,cc.p(0,-10))
        local seq = cc.Sequence:create(up,down)
        local repeate = cc.RepeatForever:create(seq)
        repeate:setTag(2)
        self.bird:runAction(repeate)

        local body = cc.PhysicsBody:createCircle(self.bird:getContentSize().width / 2-10)
        body:setMass(1)
        self.bird:setPhysicsBody(body)

        body:setEnable(false)
        self.rootNode:addChild(self.bird,3)

    end,

    addScore = function(self)
        self.score = cc.Node:create()

        local zero = cc.Sprite:createWithSpriteFrameName("font_0")
        zero:setAnchorPoint(cc.p(0,0))
        zero:setPosition(cc.p(0,0))

        self.score:setContentSize(zero:getContentSize())
        self.score:addChild(zero)
        self.score:setAnchorPoint(cc.p(0.5,1))
        self.score:setPosition(cc.p(self._winsize.width/2,self._winsize.height - 80))
        self.rootNode:addChild(self.score,2)
    end,

    addTip  = function(self)
        self.tip = cc.Sprite:createWithSpriteFrameName("text_ready")
        self.tip:setAnchorPoint(cc.p(0.5,1))
        self.tip:setPosition(cc.p(self._winsize.width/2,self._winsize.height - 160))
        self.rootNode:addChild(self.tip)
    end,

    addTutorial  = function(self)
        self.tutorial = cc.Sprite:createWithSpriteFrameName("tutorial")
        self.tutorial:setAnchorPoint(cc.p(0.5,1))
        self.tutorial:setPosition(cc.p(self._winsize.width/2,self._winsize.height - 240))
        self.rootNode:addChild(self.tutorial)
    end,

    addTouchLayer = function(self)
        self.control = cc.Layer:create()
        self.control:setTouchEnabled(true)
        self.control:registerScriptTouchHandler(function(type,x,y)
            if type == "began" then
                if not self.isBegin then
                    AudioEngine.playEffect("audio/sfx_wing.caf")
                    self:startGame()
                end
                if not self.isOver then
                    AudioEngine.playEffect("audio/sfx_wing.caf")
                    self:appForceToBird()
                end
            end
        end)
        self.rootNode:addChild(self.control)
    end,

    appForceToBird = function(self)
        local body = self.bird:getPhysicsBody()
        body:setVelocity(cc.p(0,300))
    end,

    startGame = function(self)
        self.isBegin = true
        self.tip:runAction(cc.FadeOut:create(0.4))
        self.tutorial:runAction(cc.FadeOut:create(0.4))

        self:startPipe()

        self.bird:stopActionByTag(2)
        self.bird:getPhysicsBody():setEnable(true)
        self.bird:setRotation(30)
        self.birdRotateFunc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            local v = self.bird:getPhysicsBody():getVelocity()
            self.bird:setRotation(-math.min(math.max(-90, v.y * 0.4 + 60), 30))

        end, 0, false)

        self.hitTestFunc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            for p,v in pairs(self.pipes) do
                local x,y =p:getPosition()
                if p:getTag()~=-1 then
                    if p:getTag() == 1 and x + self.pipewidth <  self._winsize.width/2 - 55 then
                        self:addScoreNum()
                        p:setTag(-1)
                    else


                    end

                    local x,y  = self.bird:getPosition()
                    rect = {
                        x = x - 14,
                        y = y - 14,
                        width  = 27,
                        height = 27
                    }
                    local rect2 = p:getBoundingBox()
                    if cc.rectIntersectsRect(rect,rect2) then
                        self:gameOver()
                        break
                    end
                end
            end
        end, 0, false)

        local event = cc.EventListenerPhysicsContactWithBodies:create(self.bird:getPhysicsBody(),self.landbody)
        event:registerScriptHandler(function(event, contact)
            self:contactLand()
        end,cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
        self.rootNode:getEventDispatcher():addEventListenerWithSceneGraphPriority(event,self.rootNode)

    end,

    addScoreNum = function(self)
        self.score:removeFromParent()
        self.score = cc.Node:create()
        self.score:setAnchorPoint(cc.p(0.5,1))
        self.rootNode:addChild(self.score,2)
        self.count  =  self.count + 1
        local temp  = tostring(self.count)
        local width = 0
        local nums  = {}

        for i=1,string.len(temp),1 do
            local s = string.sub(temp,i,i)
            local num = cc.Sprite:createWithSpriteFrameName(string.format("font_%s",s))
            num:setAnchorPoint(0,0)
            table.insert(nums,num)
            width = width + num:getContentSize().width
        end

        width = width + (string.len(temp)-1)*5
        self.score:setContentSize({width=width,height=44})

        local left = 0

        for i,n in ipairs(nums) do
            n:setPosition(cc.p(left,0))
            left = left + 5 +n:getContentSize().width
            self.score:addChild(n)
        end
        self.score:setPosition(self._winsize.width/2,self._winsize.height-80)
        AudioEngine.playEffect("audio/sfx_point.aif")
    end,

    addEdgeBox = function(self)
        local node = cc.Node:create()
        node:setPosition(cc.p(self._winsize.width/2,self._winsize.height/2))
        local body = cc.PhysicsBody:createEdgeBox(self._winsize)
        node:setPhysicsBody(body)
        self.rootNode:addChild(node)
    end,


    addLandBox = function(self)
        local node = cc.Node:create()
        self.landbody = cc.PhysicsBody:createEdgeSegment(cc.p(0,128),cc.p(320,128))
        node:setPhysicsBody(self.landbody)
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
            local height = self._winsize.height - 128 - 120

            local upheight = math.random(70,height-70)

            local downheight= height - upheight;


            local pipe_down = cc.Sprite:createWithSpriteFrameName("pipe_down")
            pipe_down:setTag(2)
            self.pipes[pipe_down]={}
            pipe_down:setAnchorPoint(cc.p(0,0))
            pipe_down:setPosition(cc.p(self._winsize.width,self._winsize.height-downheight))
            self.rootNode:addChild(pipe_down)

            local movedown = cc.MoveBy:create(4,cc.p(-448,0))
            local seqdown = cc.Sequence:create(movedown,cc.CallFunc:create(function()
                self.pipes[pipe_down]=nil
                pipe_down:removeFromParent()
            end))
            pipe_down:runAction(seqdown)

            local pipe_up   = cc.Sprite:createWithSpriteFrameName("pipe_up")
            pipe_up:setTag(1)
            self.pipes[pipe_up]={}
            pipe_up:setAnchorPoint(cc.p(0,1))
            pipe_up:setPosition(cc.p(self._winsize.width,self._winsize.height-downheight-120))
            self.rootNode:addChild(pipe_up)

            local moveup = cc.MoveBy:create(4,cc.p(-448,0))
            local sequp = cc.Sequence:create(moveup,cc.CallFunc:create(function()
                self.pipes[pipe_up]=nil
                pipe_up:removeFromParent()
            end))
            pipe_up:runAction(sequp)
        end,1.5)
    end,

    gameOver = function(self)
        AudioEngine.playEffect("audio/sfx_hit.caf")
        self.isOver = true
        U:clearInterval(self.intervalId)
        for p,e in pairs(self.pipes) do p:stopAllActions() end
        self.land1:stopAllActions()
        self.land2:stopAllActions()
        self.bird:stopAllActions()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.hitTestFunc)
        self.bird:getPhysicsBody():setVelocity(cc.p(0,0))
    end,

    contactLand = function(self)
        AudioEngine.playEffect("audio/sfx_die.caf")
        self.bird:getPhysicsBody():setEnable(false)
        self.bird:setPosition(cc.p(self._winsize.width/2-55,128 + 12))
        if not self.isOver then
           self:gameOver()
        end
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.birdRotateFunc)
        self.bird:setRotation(90)
        self:showGameOver()
    end,

    showScoreOnPanel = function(self,panel)
        self.tempcount = 0

        self.scoreonpanel = cc.Node:create()
        panel:addChild(self.scoreonpanel)
        self.scoreonpanel:setAnchorPoint(cc.p(1,1))
        self:addScoreOnPanelInPosition("0",self.scoreonpanel,0)
        local pz = panel:getContentSize()
        self.scoreonpanel:setPosition(pz.width-30,pz.height-40)

        self.calscorefunc = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            if self.tempcount == self.count then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.calscorefunc)

                local goldmetal = cc.Sprite:createWithSpriteFrameName("medals_1")
                goldmetal:setOpacity(0)
                goldmetal:setPosition(cc.p(52,60))
                panel:addChild(goldmetal)
                U:setTimeout(function()
                    goldmetal:runAction(cc.FadeIn:create(0.3))
                    local playBtn = Soso.ui.Button:new({
                        bg = {"button_play"},
                        click = function()
                            self.rootNode:runAction(cc.Sequence:create(cc.FadeOut:create(0.5),cc.CallFunc:create(function()
                                Soso.App:switchTo("play")
                            end)))
                        end
                    })
                    playBtn:setAnchorPoint(cc.p(0,0))
                    playBtn:setPosition(cc.p(30,120))
                    self.rootNode:addChild(playBtn.rootNode,4)


                    local rankBtn = Soso.ui.Button:new({
                        bg = {"button_score"},
                        click = function()

                        end
                    })
                    rankBtn:setAnchorPoint(cc.p(1,0))
                    rankBtn:setPosition(cc.p(self._winsize.width-30,120))
                    self.rootNode:addChild(rankBtn.rootNode,4)
                end,0.3)
                return
            end
            self.tempcount = self.tempcount + 1
            self.scoreonpanel:removeFromParent()
            self.scoreonpanel = cc.Node:create()
            self.scoreonpanel:setAnchorPoint(cc.p(1,1))
            panel:addChild(self.scoreonpanel)

            self:addScoreOnPanelInPosition(self.tempcount,self.scoreonpanel,0)

            local pz = panel:getContentSize()
            self.scoreonpanel:setPosition(pz.width-30,pz.height-40)

        end,0,false)
    end,

    showGameOver = function(self)
        local displayScore = function()
            local scorep = cc.Sprite:createWithSpriteFrameName("score_panel")
            scorep:setPosition(cc.p(self._winsize.width/2,-100))


            local best = cc.Node:create()
            best:setAnchorPoint(cc.p(1,1))
            scorep:addChild(best)
            self:addScoreOnPanelInPosition("1024",best,0)
            local pz = scorep:getContentSize()
            best:setPosition(pz.width-30,pz.height-80)

            local move = cc.MoveTo:create(0.3,cc.p(self._winsize.width/2,self._winsize.height- 300))

            scorep:runAction(cc.Sequence:create(move,cc.CallFunc:create(function()
               self:showScoreOnPanel(scorep)
            end)))
            self.rootNode:addChild(scorep)
        end
        self.score:setVisible(false)
        local gameover = cc.Sprite:createWithSpriteFrameName("text_game_over")
        gameover:setAnchorPoint(cc.p(0.5,1))
        gameover:setPosition(cc.p(self._winsize.width/2,self._winsize.height - 160))
        gameover:setOpacity(0)
        self.rootNode:addChild(gameover)

        local move = cc.Sequence:create(cc.MoveBy:create(0.1,cc.p(0,10)),cc.MoveBy:create(0.2,cc.p(0,-10)))
        local show = cc.Sequence:create(cc.FadeIn:create(0.2),cc.CallFunc:create(function()
            displayScore()
        end))
        gameover:runAction(cc.Spawn:create(move,show))
    end,



    addScoreOnPanelInPosition = function(self,count,panel,padding)
        padding=padding or 0

        local temp  = tostring(count)
        local nums  = {}
        local width = 0
        for i=1,string.len(temp),1 do
            local s = string.sub(temp,i,i)
            local num = cc.Sprite:createWithSpriteFrameName(string.format("number_score_0%s",s))
            num:setAnchorPoint(0,0)
            table.insert(nums,num)
            width = width + num:getContentSize().width
        end

        panel:setContentSize({width=width,height=14})
        local left = 0

        for i,n in ipairs(nums) do
            n:setPosition(cc.p(left,0))
            left = left  +n:getContentSize().width
            panel:addChild(n)
        end
    end

})