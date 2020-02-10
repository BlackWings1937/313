--[[
    MVC View 基类
    子类通过重写:
    Init    方法 定义界面初始化，1.创建所有需要的显示对象 2.注册所有要使用的UI事件
    Dispose 方法 撤销界面       1.删除所有持有的显示对象 2.注销所有持有的UI事件
    Update  方法 根据数据 更新所有相关界面 显示对象 
]]--

local BaseView = class("BaseView",function()
    return cc.Node:create();
end);
g_tConfigTable.CREATE_NEW(BaseView);

function BaseView:ctor()
    self.controller_ = nil;
end

function BaseView:setController(v)
    self.controller_ = v;
end

function BaseView:getController()
    return self.controller_;
end

function BaseView:Init()

end

function BaseView:Dispose()

end

function BaseView:Update()

end

function BaseView:DelayCallBack(dt,cb)
    self:runAction(
        cc.Sequence:create(
            cc.DelayTime:create(dt),
            cc.CallFunc:create(function() 
                if cb ~= nil then 
                    cb();
                end
            end)));
end

function BaseView:RepeatForever(dt,tag,cb)
    local rep = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(dt),cc.CallFunc:create(function() 
        if cb ~= nil then 
            cb();
        end
    end)));
    rep:setTag(tag);
    self:runAction(rep);
end

function BaseView:StopRepeatForever(tag)
    self:stopActionByTag(tag);
end

return BaseView;