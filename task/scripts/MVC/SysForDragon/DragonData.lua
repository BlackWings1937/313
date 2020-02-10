local BaseData = requirePack("scripts.MVC.SysForNormal.NormalData");


local DragonData = class("DragonData",function() 
    return BaseData.new();
end);
g_tConfigTable.CREATE_NEW(DragonData);

function DragonData:ctor()
    -- 定义所有使用过的成员在这里..
    self.data_ = nil;
end

function DragonData:initData()
    local data = {};
    data.ListOfItems = {};
    data.AimTaskIndex = nil;
    local count = self:getController():GetActivityDay();
    for i = 1,count ,1 do 
        local item = {};
        item.IsLock = true;
        item.IsShiny = false;
        item.IsComplie = false;
        item.Index = i;
        table.insert( data.ListOfItems,item );
    end
    self:setData(data);

end

--[[
    在这个方法中初始化所有sys需要的数据
    包括:
        本地
        服务器
]]--
function DragonData:Init()
    print("data init");
    self:initData();
    self:UpdateData();
end

--[[
    在这个方法中保存所有sys需要的数据
    包括:
        本地
        服务器
]]--
function DragonData:Dispose()
    print("data dispose");
end



function DragonData:LockAllItems()
    local data = self:GetData();
    local count = #data.ListOfItems;
    for i = 1,count,1 do 
        local item = data.ListOfItems[i];
        item.IsLock = true;
    end
    self:UpdateData();
end

function DragonData:SetAimTaskIndex(index)
    self.data_.AimTaskIndex = index;
end

function DragonData:GetAimTaskIndex()
    return self.data_.AimTaskIndex;
end

function DragonData:UnlockItemsByRange(st,et)
    st = math.max(1,math.min(self:getController():GetActivityDay(),st));
    et = math.max(1,math.min(self:getController():GetActivityDay(),et));
    et = math.max(st,et);
    local data = self:GetData();
    for i = st,et,1 do 
        local item = data.ListOfItems[i];
        item.IsLock = false;
    end
    self:UpdateData();
end

function DragonData:UnShinyAllItem()
    local data = self:GetData();
    local count = #data.ListOfItems;
    for i = 1,count,1 do 
        local item = data.ListOfItems[i];
        item.IsShiny = false;
    end
    self:UpdateData();
end

function DragonData:UnComplieAllItem()
    local data = self:GetData();
    for i = 1,count,1 do 
        local item = data.ListOfItems[i];
        item.IsComplie = false;
    end
    self:UpdateData();
end

function DragonData:ShinyItemByDayIndex(dayIndex)
    if dayIndex>0 and dayIndex<=self:getController():GetActivityDay() then 
        self:GetData().ListOfItems[dayIndex].IsShiny = true;
    end
    self:UpdateData();
end

function DragonData:SetTaskComplieByDayIndex(dayIndex)
    if dayIndex>0 and dayIndex<=self:getController():GetActivityDay() then 
        self:GetData().ListOfItems[dayIndex].IsComplie = true;
    end
    self:UpdateData();
end

return DragonData;