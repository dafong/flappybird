---
--
-- by xinlei.fan
--

Class = {
    __className = "Class",
    __type = "class"
}

function Class:extend(t)
    local NewClass = t
    setmetatable(NewClass,{ __index = self } )
    local _supero  = self
    for k,v in pairs(t) do
        if type(t[k]) == "function" then
            local tempfunc      = t[k];
            if _supero[k] and type(_supero[k]) == "function" then
                NewClass[k]     = function(that,...)
                    local s     = that._super
                    that._super = _supero[k]
                    ret         = tempfunc(that,unpack({ ... }))
                    that._super = s
                    return ret
                end
            else
                NewClass[k]     = function(that,...)
                    local s
                    if that._super ~= nil then  s = that._super else that._super = function(them,...) end  end
                    ret         = tempfunc(that,unpack({ ... }))
                    that._super = s
                    return ret
                end
            end
        end
    end
    return NewClass
end

function Class:new(...)
    local instance = { __type = 'object' }
    setmetatable(instance,{ __index = self })
    instance:init(unpack({ ... }))
    return instance
end

function Class:instanceof(ClassObject)
    if Class:isClassObject(self)    then error("you can't call this method on ClassObject",1) return false end
    if Class:isInstanceObject(self) then return self:_instanceof(self,ClassObject) end
    return false
end

function Class:_instanceof(t,ClassObject)
    prototype      = getmetatable(t)
    if prototype then
        pProtoType = prototype.__index
        if pProtoType and pProtoType == ClassObject then return true else return self:_instanceof(pProtoType,ClassObject) end
    else
        return false;
    end
end

function Class:isClassObject(t)    return t and t.__type and type(t.__type) == 'string' and t.__type == "class"  end

function Class:isInstanceObject(t) return t and t.__type and type(t.__type) == 'string' and t.__type == "object"  end
