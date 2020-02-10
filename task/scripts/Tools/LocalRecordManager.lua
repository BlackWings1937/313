local LocalRecordManager = class("LocalRecordManager",function() 
    return {};
end);
g_tConfigTable.CREATE_NEW(LocalRecordManager);

LocalRecordManager.STR_PREFIX = "FROM_LRM_";

function LocalRecordManager:ctor()
    self.userData_ = cc.UserDefault:getInstance() ;
end

function LocalRecordManager:record(strKey,strValue)
    if self.userData_ ~= nil then --LocalRecordManager.STR_PREFIX .. 
        self.userData_:setStringForKey(strKey,strValue);
        --writeToFile("set key:".. strKey .. " value:"..strValue);
        --print("set key:".. strKey .. " value:"..strValue);
    end
end

function LocalRecordManager:get(strKey)
    if self.userData_ ~= nil then 
       -- writeToFile("get key:"..  strKey .. " value:".. self.userData_:getStringForKey(LocalRecordManager.STR_PREFIX .. strKey));
       -- print("get key:".. strKey .. " value:".. self.userData_:getStringForKey(LocalRecordManager.STR_PREFIX .. strKey));
        return self.userData_:getStringForKey(strKey);
    end
    return nil;
end

-- -----    ------

--[[
    将数据保存到本地
    不调用这个方法，内存中的数据并不会写到内存中
]]--
function LocalRecordManager:SaveToLocal()
    if self.userData_ ~= nil then 
        self.userData_:flush();
    end
end

function LocalRecordManager:RecordFullAreaData(strKey,strValue)
    self:record(strKey,strValue);
end

function LocalRecordManager:GetFullAreaData(strKey)
    return self:get(strKey);
end

function LocalRecordManager:RecordUserData(strKey,strValue)
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    self:record(curIdStr.. "_" ..strKey,strValue);
end

function LocalRecordManager:GetUserData(strKey)
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    return self:get(curIdStr .. "_" .. strKey);
end

function LocalRecordManager:RecordUserDataToday(strKey,strValue)
    local time = os.date("%Y%m%d");
    self:RecordUserData(time .. "_" .. strKey,strValue);
end

function LocalRecordManager:GetUserDataToday(strKey)
    local time = os.date("%Y%m%d");
    return self:GetUserData(time .. "_" .. strKey);
end

return LocalRecordManager;