--[[
    MVC Data 基类
    子类通过重写:
    Init    方法 定义data初始化 1.从本地或者网络当前线程请求相关数据初始化Data
    Dispose 方法 撤销界面       1.将内存数据保存到对应文件或发送给服务器
]]--

local BaseData = class("BaseData");
g_tConfigTable.CREATE_NEW(BaseData);

function BaseData:ctor() 
    self.cbOfUpdateData_ = nil;                                                                -- 更新数据的回掉方法
    self.data_           = nil;                                                                -- 用来更新界面的数据
    self.controller_ = nil;

end


function BaseData:setController(v)
    self.controller_ = v;
end

function BaseData:getController()
    return self.controller_;
end

function BaseData:setData(d)
    self.data_ = d;
end

function BaseData:GetData()
    return self.data_;
end

--[[
    更新数据给注册放
    通常有数据变更的时候调用这个方法
]]--
function BaseData:UpdateData()
    if self.cbOfUpdateData_ ~= nil then 
        self.cbOfUpdateData_(self.data_);
    end
end

--[[
    设置数据更新时的回掉
    参数:
    cb:数据更新需要通知的方法
]]--
function BaseData:SetUpdateDataCallBack(cb)
    self.cbOfUpdateData_ = cb;
end

function BaseData:Init()

end

function BaseData:Dispose()

end

function BaseData:DelayCallBack(dt,cb)
    if self:getController()~=nil then 
        self:getController():DelayCallBack(dt,cb);
    end
end

function BaseData:RepeatForever(dt,tag,cb)
    if self:getController()~=nil then 
        self:getController():RepeatForever(dt,tag,cb)
    end
end

function BaseData:StopRepeatForever(tag)
    if self:getController()~=nil then 
        self:getController():StopRepeatForever(tag)
    end
end

return BaseData;