local BaseData = requirePack("scripts.MVC.Base.BaseView");

local NormalView = class("NormalView",function() 
    return BaseData.new();
end);
g_tConfigTable.CREATE_NEW(NormalView);

function NormalView:ctor()
    -- 定义所有使用过的成员在这里..
end

--[[
    方法 定义界面初始化
    包括:
        创建所有需要的显示对象 
        注册所有要使用的UI事件
]]--
function NormalView:Init()

end

--[[
    方法 撤销界面       
    包括:
        删除所有持有的显示对象 
        注销所有持有的UI事件
]]--
function NormalView:Dispose()

end

return NormalView;