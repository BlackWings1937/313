--[[
    MVC controller 基类
    子类通过重写 Start Stop 方法 关闭和启动系统
]]--

local BaseController = class("BaseController")
g_tConfigTable.CREATE_NEW(BaseController);

function BaseController:ctor()
    self.view_ = nil;
    self.data_ = nil;
end

function BaseController:getView()
    return self.view_;
end

function BaseController:getData()
    return self.data_;
end

function BaseController:setView(v)
    self.view_ = v;
end

function BaseController:setData(v)
    self.data_ = v;
end

function BaseController:Start()

end

function BaseController:Stop()

end

function BaseController:DelayCallBack(dt,cb)
    if self:getView()~=nil then 
        self:getView():DelayCallBack(dt,cb);
    end
end

function BaseController:RepeatForever(dt,tag,cb)
    if self:getView()~=nil then 
        self:getView():RepeatForever(dt,tag,cb)
    end
end

function BaseController:StopRepeatForever(tag)
    if self:getView()~=nil then 
        self:getView():StopRepeatForever(tag)
    end
end

return BaseController;


