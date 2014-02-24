--
-- Created by IntelliJ IDEA.
-- User: xinlei.fan
-- Date: 13-4-19
-- Time: 上午10:26
-- To change this template use File | Settings | File Templates.
--

Soso.scenes = Soso.scenes or {}
Soso.scenes.Scene = Soso.ui.UIComponent:extend({

	__className = "Soso.scenes.Scene",

    getCommonResources = function(self)
        return {
        }
    end,

    getModulesResources = function(self)
        return {

        }
    end,

	initWithCode = function(self, options)
		self:_super(options)
	end,


	getRootNode = function(self)
		if not self.rootNode then
			self.rootNode = cc.Node:create()
            self.rootNode:setContentSize(self._winsize)
		end
		return self.rootNode 
	end,

    getDefaultOptions = function(self)
		return {
			transition     = false,
            nodeEventAware = true,
            exitDuration   = 0.3,
            layout         = "absolute"
		}
	end
})