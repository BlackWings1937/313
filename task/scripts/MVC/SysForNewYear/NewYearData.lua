local BaseData = requirePack("scripts.MVC.SysForNormal.NormalData");


local NewYearData = class("NewYearData",function() 
    return BaseData.new();
end);
g_tConfigTable.CREATE_NEW(NewYearData);

function NewYearData:ctor()
    -- 定义所有使用过的成员在这里..
    self.data_ = nil;
end

function NewYearData:initData()
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
function NewYearData:Init()
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
function NewYearData:Dispose()
    print("data dispose");
end



function NewYearData:LockAllItems()
    local data = self:GetData();
    local count = #data.ListOfItems;
    for i = 1,count,1 do 
        local item = data.ListOfItems[i];
        item.IsLock = true;
    end
    self:UpdateData();
end

function NewYearData:SetAimTaskIndex(index)
    self.data_.AimTaskIndex = index;
end

function NewYearData:GetAimTaskIndex()
    return self.data_.AimTaskIndex;
end

function NewYearData:UnlockItemsByRange(st,et)
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

function NewYearData:UnShinyAllItem()
    local data = self:GetData();
    local count = #data.ListOfItems;
    for i = 1,count,1 do 
        local item = data.ListOfItems[i];
        item.IsShiny = false;
    end
    self:UpdateData();
end

function NewYearData:UnComplieAllItem()
    local data = self:GetData();
    for i = 1,count,1 do 
        local item = data.ListOfItems[i];
        item.IsComplie = false;
    end
    self:UpdateData();
end

function NewYearData:ShinyItemByDayIndex(dayIndex)
    if dayIndex>0 and dayIndex<=self:getController():GetActivityDay() then 
        self:GetData().ListOfItems[dayIndex].IsShiny = true;
    end
    self:UpdateData();
end

function NewYearData:SetTaskComplieByDayIndex(dayIndex)
    if dayIndex>0 and dayIndex<=self:getController():GetActivityDay() then 
        self:GetData().ListOfItems[dayIndex].IsComplie = true;
    end
    self:UpdateData();
end

return NewYearData;