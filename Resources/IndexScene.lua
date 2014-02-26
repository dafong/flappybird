--
-- Created by IntelliJ IDEA.
-- User: fxl
-- Date: 14-2-24
-- Time: 上午12:41
-- To change this template use File | Settings | File Templates.
--
Soso.scenes.IndexScene = Soso.scenes.Scene:extend({


    initWithCode = function(self,options)
        self:_super(options)
        self:addContent()
        self:addBird()
        self:addButton()
    end,


    addContent = function(self)

        local bg  = cc.Sprite:createWithSpriteFrameName("bg_day");
        bg:setScaleX(self._winsize.width/bg:getContentSize().width)
        bg:setScaleY(self._winsize.height/bg:getContentSize().height)
        bg:setAnchorPoint(cc.p(0,0))
        bg:setPosition(cc.p(0,0))

        local land1 = cc.Sprite:createWithSpriteFrameName("land")
        land1:getTexture():setAliasTexParameters()
        land1:setAnchorPoint(cc.p(0,0))
        land1:setScaleY(1.15)
        land1:setPosition(cc.p(0,0))

        local move1 = cc.MoveBy:create(3,cc.p(-336,0))
        local seq1  = cc.Sequence:create(move1,cc.CallFunc:create(function()
            land1:setPosition(cc.p(0,0))
        end))

        land1:runAction(cc.RepeatForever:create(seq1))


        local land2 = cc.Sprite:createWithSpriteFrameName("land")
        land2:setAnchorPoint(cc.p(0,0))
        land2:setScaleY(1.15)
        land2:setPosition(cc.p(336,0))

        local move2 = cc.MoveBy:create(3,cc.p(-336,0))
        local seq2  = cc.Sequence:create(move2,cc.CallFunc:create(function()
            land2:setPosition(cc.p(336,0))
        end))
        land2:runAction(cc.RepeatForever:create(seq2))


        local flappybird = cc.Sprite:createWithSpriteFrameName("title")
        flappybird:setAnchorPoint(cc.p(0.5,0))
        flappybird:setPosition(cc.p(self._winsize.width/2,360))


        self.rootNode:addChild(bg)
        self.rootNode:addChild(land2)
        self.rootNode:addChild(land1)

        self.rootNode:addChild(flappybird)

    end,

    addButton = function(self)

        local rbtn = Soso.ui.Button:new({
            bg = {"button_rate"},
            click = function()

            end
        })
        rbtn:setPosition(cc.p(self._winsize.width/2,240))
        self.rootNode:addChild(rbtn.rootNode)


        local playBtn = Soso.ui.Button:new({
            bg = {"button_play"},
            click = function()
                self.rootNode:runAction(cc.Sequence:create(cc.FadeOut:create(1),cc.CallFunc:create(function()
                    Soso.App:switchTo("play")
                end)))
            end
        })
        playBtn:setAnchorPoint(cc.p(0,0))
        playBtn:setPosition(cc.p(30,120))
        self.rootNode:addChild(playBtn.rootNode)

        local scoreBtn = Soso.ui.Button:new({
            bg = {"button_score"},
            click = function()

            end
        })
        scoreBtn:setAnchorPoint(cc.p(1,0))
        scoreBtn:setPosition(cc.p(self._winsize.width-30,120))
        self.rootNode:addChild(scoreBtn.rootNode)
    end,


    addBird = function(self)
        local animation = cc.Animation:create()
        animation:setDelayPerUnit(0.2)
        animation:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("bird1_0"))
        animation:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("bird1_1"))
        animation:addSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("bird1_2"))


        local node = cc.Sprite:createWithSpriteFrameName("bird1_0")
        node:setAnchorPoint(cc.p(0.5,0))
        node:setPosition(cc.p(self._winsize.width/2,290))
        node:runAction(cc.RepeatForever:create( cc.Animate:create(animation)))

        local up  = cc.MoveBy:create(0.4,cc.p(0,10))
        local down= cc.MoveBy:create(0.4,cc.p(0,-10))
        local seq = cc.Sequence:create(up,down)

        node:runAction( cc.RepeatForever:create(seq))


        self.rootNode:addChild(node)
    end


})