--
-- Created by IntelliJ IDEA.
-- User: xinlei.fan
-- Date: 13-4-19
-- Time: 上午10:26
-- To change this template use File | Settings | File Templates.
--
Soso.ui.Button = Soso.ui.UIComponent:extend({

    __className = "Soso.ui.Button",

    initWithCode = function(self,options)
        self:_super(options)
        self.rootNode:loadTextures(self._options.bg[1],self._options.bg[2],self._options.bg[3],1)
        self.rootNode:setTouchEnabled(true)
        self.rootNode:setTitleText(self._options.title)

    end,

    _createRootNode = function(self)
        self.inClick = false    --解决按钮连续点击做多次请求的问题
        local btn = ccui.Button:create()

        btn:addTouchEventListener(function(obj, event)
            if event == 2 then
                self:_click()
            end
        end)
        return btn
    end,

    _click = function(self)
        if self.inClick == false then
            self.inClick = true
            self._options:click(self)
            U:setTimeout(function()    --限制按钮连续点击
                self.inClick = false
            end, 1)
        end
    end,

    _disableClick = function(self)
        self._options:disableClick(self)
    end,

    setOpacity = function(self,opacity)
        self.rootNode:setOpacity(255 * opacity)
    end,


    getRootNode = function(self)
        if not self.rootNode then
            self.rootNode = self:_createRootNode()
        end
        return self.rootNode
    end,

    setTitle = function(self,title)
        self.rootNode:setTitleText(title)
    end,

    trigger =  function(self,type)
       self:_click()
    end,

    enable = function(self, isEnable)
        self.rootNode:setEnabled(isEnable)
    end,

    disable = function(self,isDisable)
        self.rootNode:setEnabled(not isDisable)
    end,


    setSelected = function(self, enable)
        self.rootNode:setSelected(enable)
    end,

    getBoundingBox = function(self)
        return self.rootNode:boundingBox()
    end,

    getDefaultOptions = function(self)
        return U:extend(false,self:_super(),{
            font      = nil,
            title     = "" ,
            fontSize  = 12,
            fontColor = nil,
            marginX   = 10,
            marginY   = 10,
            click     = function(that,self) U:debug("I am clicked") end,
            disableClick = function(that,self) U:debug("I am disableClicked") end,
            --     norma,    highlighted,    selected,       disabled
            bg        = {},
            preferredSize = nil,
            touchPriority = nil --- set this will lead to set a special touch priority.default is 0
        })
    end

})