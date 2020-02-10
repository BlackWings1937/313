local BaseData = requirePack("scripts.MVC.Base.BaseData");


local NormalData = class("NormalData",function() 
    return BaseData.new();
end);
g_tConfigTable.CREATE_NEW(NormalData);

function NormalData:ctor()
    -- 定义所有使用过的成员在这里..
end

--[[
    在这个方法中初始化所有sys需要的数据
    包括:
        本地
        服务器
]]--
function NormalData:Init()

end

--[[
    在这个方法中保存所有sys需要的数据
    包括:
        本地
        服务器
]]--
function NormalData:Dispose()

end

return NormalData;