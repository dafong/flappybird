--
-- Created by IntelliJ IDEA.
-- User: xinlei.fan
-- Date: 13-4-19
-- Time: 上午10:26
-- To change this template use File | Settings | File Templates.
--
Soso = Soso or {}

Soso.ui = Soso.ui or {}

Soso.ui.UIComponent = Class:extend({

    __className = "Soso.ui.UIComponent",

    -------Refrence Count----------

    retain = function(self)
        self.rootNode:retain()
    end,

    release = function()
        self.rootNode:release()
    end,

    ------ Create and Init --------
    ---
    -- TODO overwite the new method ,add _director and _winsize property
    new = function(self, ...)
        self._director = Soso.App.director
        self._winsize  = Soso.App.visibleSize
        return self:_super(...)
    end,

    ---
    -- TODO initialize method
    init = function(self, options, ...)
        self:initWithCode(options, unpack({ ... }))
    end,

    ----
    -- TODO when initialize with code ,overwrite this method and call self:_super() before render the ui
    initWithCode = function(self, options, ...)
        self._options  = U:extend(false,self:getDefaultOptions(), options)

        self.rootNode  = self:getRootNode()
        if self._options.nodeEventAware then
            self.rootNode:registerScriptHandler(function(eventType)
                if eventType     == 'enter' then
                    self:onEnter()
                elseif eventType == 'exit' then
                    self:onExit()
                elseif eventType == 'enterTransitionFinish' then
                    self:onEnterTransitionDidFinish()
                elseif eventType == 'exitTransitionStart' then
                    self:onExitTransitionDidStart()
                end
            end)
        end
    end,

    ---
    -- TODO in the future
    initWithCCB = function(self, options, ...)
        self._options = U:extend(true,self:getDefaultOptions(), options)
    end,

    ------ Root and Children--------

    ---
    -- TODO return the CCNode represent  the UIComponent
    getRootNode = function(self)
        if not self.rootNode then
            self.rootNode = cc.Node:create()
        end
        return self.rootNode
    end,

	---
	-- TODO Add child
	addChild = function(self, child,constraint,zorder)
        zorder = zorder or 0
		if U:isUI(child) then
            child.__parent = self
            self:getRootNode():addChild(child:getRootNode(),zorder)
        else
            self:getRootNode():addChild(child,zorder)
		end
	end,

    removeChild = function(self, child, isCleanUp)
        self:getRootNode():removeChild(child, isCleanUp)
    end,

    ---
    -- TODO Remove from parent
    removeFromParentAndCleanup = function(self,isCleanUp)
        self:getRootNode():removeFromParentAndCleanup(isCleanUp)
    end,

    ------ Visible and Invisible -------

    ---
    -- TODO is this visible
    isVisible = function(self)
        return self:getRootNode():isVisible()
    end,

    ---
    -- TODO is this have a visible parent
    hasVisibleParents = function(self)
        local parent = self:getRootNode():getParent()
        while parent do
             if not parent:isVisible() then
                 return false
             end
             parent = parent:getParent()
        end
        return true
    end,

    ---
    -- TODO set the visible
    setVisible = function(self,isVisible)
        self:getRootNode():setVisible(isVisible)
    end,

    setOpacity = function(self,iopacity)
        self:getRootNode():setOpacity(iopacity)
    end,

    ------ Size and Position and AnchorPoint------
    ---
    -- TODO Set ui content scale
    setScale      = function(self,scale)
        self:getRootNode():setScale(scale)
    end,

    ---
    -- TODO Get ui content size
    setContentSize = function(self, size)
        self:getRootNode():setContentSize(size)
        self:needLayout()
    end,

    ---
    -- TODO Get ui content size
    getContentSize = function(self)
        return self:getRootNode():getContentSize()
    end,

    ---
	-- TODO Set ui position
	setPosition = function(self,p)
		self:getRootNode():setPosition(p)
	end,

    ---
    -- TODO Set ui positin in X
    setPositionX = function(self, x)
        self:getRootNode():setPositionX(x)
    end,

	---
	-- TODO Get ui position
	getPosition = function(self)
		return self:getRootNode():getPosition()
	end,

    ---
	-- TODO Set ui anchor point
	setAnchorPoint = function(self,point)
		self:getRootNode():setAnchorPoint(point)
	end,

    ---
    -- TODO Get ui anchor point
    getAnchorPoint = function(self)
        return self:getRootNode():getAnchorPoint()
    end,

    ---
    -- TODO Is this node is ignore anchorpoint when position
    isIgnoreAnchorPointForPosition = function(self)
        self:getRootNode():isIgnoreAnchorPointForPosition()
    end,

    ------------- Layout --------------

    ---
    -- TODO Set the layout constraint
	setLayoutConstraint = function(self,constraint)
        self.layoutConstraint = constraint
    end,

    ---
    -- TODO Get the layout constraint
    getLayoutConstraint = function(self)
        return self.layoutConstraint
    end,

    ---
    -- TODO Set the Layout the current UIComponent
    setLayout = function(self,layout)
        self.layout = layout
        self.layout:setParent(self)
    end,

    ---
    -- TODO Get the Layout
    getLayout = function(self)
        return self.layout
    end,

    ---
    -- TODO Relayout the current UI Component
    needLayout = function(self)
        self.layout:update()
        if self.__parent then
            self.__parent:needLayout()
        end
    end,

    -------- Enter Action and Exit Action -------------

    ---
    -- TODO ccnode run some action
    runAction     = function(self,action)
        self.rootNode:runAction(action)
    end,

    ---
    -- TODO Set the enter action
    setEnterAction = function(self,action)
        self.rootNode:getActionManager():addAction(action,self.rootNode,true)
        self.enterAction = action
    end,

    ---
    -- TODO Set the exit action
    setExitAction = function(self,action)
        self.rootNode:getActionManager():addAction(action,self.rootNode,true)
        self.exitAction = action
    end,

    ------ Default option --------

    getDefaultOptions = function(self)
        return {
            nodeEventAware = false,
            layout         = "absolute", --- { "absolute" , "dock" , "row" , "column" , "grid" }
            layoutOptions  = {},
            constraint     = {},
        }
    end,

    ------ UI Event Callback --------

    onEnter = function(self)
        if self._options.onEnter then self._options:onEnter(self) end
    end,

    onEnterTransitionDidFinish = function(self)
        if self.enterAction then
            self.rootNode:getActionManager():resumeTarget(self.rootNode)
        end
    end,

    onExit = function(self)
        if self._options.onExit then self._options:onExit(self) end
    end,

    onPostExit = function(self)
        if self.exitAction then
            self.rootNode:getActionManager():resumeTarget(self.rootNode)
        end
        if self._options.onPostExit then self._options:onPostExit(self) end
    end,

    onExitTransitionDidStart = function(self) end,

    -------- Event ---------
    onEvent = function(self,t,c,triggerOnce,g)
        Soso.system.EventManager:addListener(t,c,triggerOnce,g)
    end,

    fireEvent = function(self,t,a)
        local event = Soso.system.Event:new(t,a)
        event:fire()
    end,

    unEvent = function(self,t,c)
        Soso.system.EventManager:removeListener(t,c)
    end,

    clearEvent = function(self,t)
        Soso.system.EventManager:removeAllListener(t)
    end
})

