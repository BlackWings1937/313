local BaseController = requirePack("scripts.MVC.Base.BaseController");


local EmptyController = class("EmptyController",function() 
    return BaseController.new();
end);
g_tConfigTable.CREATE_NEW(EmptyController);

function EmptyController:ctor()
    -- 定义所有使用过的成员在这里..
end

--[[
    通过这个方法传入sys所有需要的外部参数
    初始化:
        View
        data
]]--
function EmptyController:Start()

end

--[[
    通过这个方法终止sys
    撤销:
        View
        data
]]--
function EmptyController:Stop()

end

return EmptyController;