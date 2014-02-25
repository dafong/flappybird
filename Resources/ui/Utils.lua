--
-- Utility functions
--
U = {}
U.noop = function(self) end
U.log = function(self, ...) U:debug(unpack(arg)) end

U.isNil = function(self,s)
    if s~=nil then
        if type(s) == "string" then
            return s == ""
        end
        if type(s) == "table" then
            return next(s) == nil
        end
        return false
    end
    return true
end



U.debug = function(self,msg,...)

        if type(msg) == "table" then
            print("[debug] ----------debug table----------")
            print_table(msg)
            return
        end
        if msg ~= nil then
            if {...} ~= nil and #{...} ~= 0 then
                print("[debug] "..string.format(msg,...))
            else
                print("[debug] "..msg)
            end
        else
            print("[debug] nil")
        end

end

U.fdebug = function(self,module,action,msg,...)
    if Soso.DEBUG then
        local m = "["..string.rep(" ",12 - string.len(module)-2)..module.."]"
        local a = "["..string.rep(" ",18 - string.len(action)-2)..action.."]"
        local s = msg or ""
        if msg ~= nil then
            if {...} ~= nil and #{...} ~= 0 then
                s = string.format(msg,...)
            end
        end
        CCLOG("[debug] %s %s %s",m,a,s)
    end
end

---
-- 检测一个object 是否是UIComponent的实例
-- @param self
-- @param t
--
U.isUI = function(self, t)
    return Class:isInstanceObject(t) and t:instanceof(Soso.ui.UIComponent)
end

U.round = function(self, num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

--- Used for the custom scroll controll in HSlider and VSlider
-- @param self
-- @param x
-- @param y
-- @param ui
--
U.isXYInUIRect = function(self, x, y, ui)
    local n, p, s = ui, nil, nil
    if U:isUI(ui) then
        n = ui.rootNode
    end
    rect = n:boundingBox()
    p = n:getParent():convertToNodeSpace(cc.p(x, y))
    return rect:containsPoint(p)
end


U.isXInUIRect = function(self,x,ui)
    local n, p, s = ui, nil, nil
    if U:isUI(ui) then
        n = ui.rootNode
    end
    rect = n:boundingBox()
    p = n:convertToNodeSpace(cc.p(x, 0))
    p.y = rect:getMinY()
    return rect:containsPoint(p)
end

U.isYInUIRect = function(self,y,ui)
    local n, p, s = ui, nil, nil
    if U:isUI(ui) then
        n = ui.rootNode
    end
    rect = n:boundingBox()
    p = n:convertToNodeSpace(cc.p(0, y))
    p.x = rect:getMinX()
    return rect:containsPoint(p)
end

--- setTimeout
-- @param self
-- @param func
-- @param secs
--
U.setTimeout = function(self, func, secs)
    if not secs then secs = 0 end
    local id
    id = CCDirector:getInstance():getScheduler():scheduleScriptFunc(function()
        CCDirector:getInstance():getScheduler():unscheduleScriptEntry(id)
        func()
    end, secs, false)
end

U.setInterval = function(self,func, secs)
    return CCDirector:getInstance():getScheduler():scheduleScriptFunc(function()
        func()
    end, secs, false)
end

U.clearInterval = function(self,id)
    if id then
        CCDirector:getInstance():getScheduler():unscheduleScriptEntry(id)
    end
end


-- 判断一个点是否在一个由 ‘顺时针’ 方向的顶点围成的区域里面
U.regionContainsPoint = function(self, vertices, point)
    assert (type(vertices) == "table" and #vertices >= 3, "vertices must be a 3 or greater size table")

    local base, cmp
    vertices[0] = vertices[#vertices]
    for i = 1, #vertices do
        base = ccpSub(vertices[i], vertices[i-1])
        cmp = ccpSub(point, vertices[i-1])
        if ccpCross(cmp, base) < 0 then return false end
    end
    return true
end

-- 去除空白字符串
U.trim = function(self, str)
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end

--
-- Print table contents
-- @param table sth
--
function print_table(sth)
    if type(sth) ~= "table" then
        U:debug(sth)
        return
    end

    local space, deep = string.rep(' ', 4), 0
    local function _dump(t)
        local temp = {}
        for k, v in pairs(t) do
            local key = tostring(k)

            if type(v) == "table" then
                deep = deep + 2
                U:debug(string.format("%s[%s] => Table", string.rep(space, deep - 1), k))
                U:debug(string.format("%s(",string.rep(space, deep)))

                -- the _dump is going on duing to lots of the UICompoenent and LayoutManager extends
                if key ~= "__parent" then
                    _dump(v)
                end

                U:debug(string.format("%s)", string.rep(space, deep)))
                deep = deep - 2
            else
                if type(v) ~= "string" then
                    v = tostring(v)
                end

                U:debug(string.format("%s[%s] => %s",
                    string.rep(space, deep + 1),
                    key,
                    v)) --print.
            end
        end
    end

    U:debug("Table")
    U:debug("(")
    _dump(sth)
    U:debug(")")
end

--
-- Split string to table
-- @param string s
-- @param char delim
--
U.split = function(self,s, delim)
    if U:isNil(s) then return nil end
    assert (type (delim) == "string" and string.len (delim) > 0,
        "bad delimiter")

    local start = 1
    local t = {}  -- results table

    -- find each instance of a string followed by the delimiter

    while true do
        local pos = string.find (s, delim, start, true) -- plain find

        if not pos then
            break
        end

        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end -- while

    -- insert final one (after last delimiter)

    table.insert (t, string.sub (s, start))

    return t

end

--[[
-- 扩展对象，用于设定默认值
-- extend(target,{aa='aa'},...)
-- target.aa=='aa'
--
-- extend(target,{aa='aa'},{aa='aa1'},...)
-- target.aa=='aa1'
--
-- ]]

U.extend = function(self,isDeepCopy,target,...)
    if not (target and type(target) == "table") then
        error("U.extend: target must be a table")
    end

    if not isDeepCopy then
       for i,k in ipairs({ ... }) do
           for key,value in pairs(k) do
               target[key] = value
           end
       end
    else
        for i, k in ipairs({ ... }) do
            if k and type(k) ~= "table" then
                target[#target + 1] = k
            else -- handle argument
                for key, value in pairs(k) do
                    local src = target[key]
                    if not src then -- src is nil
                        target[key] = value
                    else -- src is not nil
                        if type(src) == "table" then -- sFrc is a table
                            target[key] = U:extend(true,src, value)
                        elseif type(value) == "table" then
                            target[key] = U:extend(true,{src}, value)
                        else
                            target[key] = value
                        end
                    end
                end
            end
        end
    end
    return target
end


U.urlencode = function(self, str)
    if (str) then
        str = string.gsub (str, "\n", "\r\n")
        str = string.gsub (str, "([^(%w|_| |.)])",
            function (c) return string.format ("%%%02X", string.byte(c)) end)
        str = string.gsub (str, " ", "+")
    end
    return str
end
