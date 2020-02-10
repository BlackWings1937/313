local FileUtil = requirePack("scripts.Utils.FileUtil");


local BaseData = requirePack("scripts.MVC.Base.BaseData");


local ChrismasData = class("ChrismasData",function() 
    return BaseData.new();
end);
g_tConfigTable.CREATE_NEW(ChrismasData);

ChrismasData.EnumViewType = {
    ["E_DECORATION"] = 1,
    ["E_RECORD_AUDIO"] = 2,
    ["E_FINISH"] = 3,
    ["E_SHARE"] = 4,
    ["E_GET_GIFT"] = 5,
    ["E_OLD"] = 6
}

function ChrismasData:ctor()
    -- 定义所有使用过的成员在这里..
end

function ChrismasData:initDebugData()

    -- judge vipself.data.VIP = 

    local data = {};
    data.IsVip =( UInfoUtil:getInstance():getVipLevel() ~= 0 );
    data.userName =  UInfoUtil:getInstance():getNickName();
    if data.userName == "" then 
        data.userName = "宝宝";
    end
    data.ViewType = ChrismasData.EnumViewType.E_DECORATION;
    data.DecorationStep  = 1;
    data.RecordAudioStep = 1;
    data.ListOfBackGroundOption = {
        {index = 1,iconName = "gui_heka01_vip.png",VipItem = true,jsonName = "Xmas112",RI = 1},
        {index = 2,iconName = "gui_heka03.png",VipItem = false,jsonName = "Xmas111",RI = 2},
        {index = 3,iconName = "gui_heka02.png",VipItem = false,jsonName = "Xmas110",RI = 3},
        {index = 4,iconName = "gui_heka04.png",VipItem = false,jsonName = "Xmas109",RI = 4}
    };
    data.ListOfDecorationOption = {
        {index = 6,iconName = "gui_ribbon_01_vip.png",VipItem = true,jsonName = "Xmas119",RI = 1},
        {index = 4,iconName = "gui_ribbon_02.png",VipItem = false,jsonName = "Xmas117",RI = 2},
        {index = 5,iconName = "gui_ribbon_03.png",VipItem = false,jsonName = "Xmas118",RI = 3},
        {index = 3,iconName = "gui_ribbon_04.png",VipItem = false,jsonName = "Xmas116",RI = 4},
        {index = 2,iconName = "gui_ribbon_05.png",VipItem = false,jsonName = "Xmas115",RI = 5},
        {index = 1,iconName = "gui_ribbon_06.png",VipItem = false,jsonName = "Xmas114",RI = 6},
    };
    data.ListOfWordOption = {
        {index = 4,iconName = "gui_youdian01-vip.png",VipItem = true,jsonName = "Xmas125",RI = 1},
        {index = 5,iconName = "gui_youdian02.png",VipItem = false,jsonName = "Xmas124",RI = 2},
        {index = 1,iconName = "gui_youdian03.png",VipItem = false,jsonName = "Xmas121",RI = 3},
        {index = 3,iconName = "gui_youdian04.png",VipItem = false,jsonName = "Xmas123",RI = 4},
        {index = 2,iconName = "gui_youdian05.png",VipItem = false,jsonName = "Xmas122",RI = 5},
    };
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    local oldCardDataPath = 
        GET_REAL_PATH_ONLY("",PathGetRet_ONLY_SD) .. "xialingyingTemp/".."User".. curIdStr.."OldChrismasCard.json" ;
    print("card:path"..oldCardDataPath);
    if FileUtil.Exists(oldCardDataPath)  then --  
        local str = FileUtil.LoadFileContent(oldCardDataPath);
        data.UserDecorationOptions = json.decode(str);
        print("card existxxxxxxxxxxxxxxxxxxxxxx");
    else 
        data.UserDecorationOptions = {
            [1] = -1,
            [2] = -1,
            [3] = -1,
            [4] = -1,
        };
        local str = json.encode(data.UserDecorationOptions);
        FileUtil.Write(oldCardDataPath,str); -- todo wait to save
        print("card UNexistxxxxxxxxxxxxxxxxxxxxxx");

    end
    data.TempDecorationOptions = {};
    data.TempDecorationOptions[1] = data.UserDecorationOptions[1];
    data.TempDecorationOptions[2] = data.UserDecorationOptions[2];
    data.TempDecorationOptions[3] = data.UserDecorationOptions[3];
    data.TempDecorationOptions[4] = data.UserDecorationOptions[4];

    self:setData(data);
end

function ChrismasData:ClearTempCardData()
    self:GetData().TempDecorationOptions = {
        [1] = -1,
        [2] = -1,
        [3] = -1,
        [4] = -1,
    };
end

function ChrismasData:IsFinishedCard()
    
    if self:GetData().UserDecorationOptions[1] ~= -1 
    and self:GetData().UserDecorationOptions[2] ~= -1 
    and self:GetData().UserDecorationOptions[3] ~= -1 
    and self:GetData().UserDecorationOptions[4] ~= -1
        then 
            return true;
        else 
            return false;
        end
end

function ChrismasData:SaveCardData()
    local data = self:GetData();
    
    data.UserDecorationOptions[1] = data.TempDecorationOptions[1];
    data.UserDecorationOptions[2] = data.TempDecorationOptions[2];
    data.UserDecorationOptions[3] = data.TempDecorationOptions[3];
    data.UserDecorationOptions[4] = data.TempDecorationOptions[4];

    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    local oldCardDataPath = 
    GET_REAL_PATH_ONLY("",PathGetRet_ONLY_SD) .. "xialingyingTemp/".."User".. curIdStr.."OldChrismasCard.json" ;
    print("save card:path"..oldCardDataPath);
    local str = json.encode(data.UserDecorationOptions);
    FileUtil.Write(oldCardDataPath,str); -- todo wait to save
end


function ChrismasData:SetUserDecorationOptionsByStepAndIndex(st,i)
    self:GetData().TempDecorationOptions[st] = i;
end

--[[
    在这个方法中初始化所有sys需要的数据
    包括:
        本地
        服务器
]]--
function ChrismasData:Init()
    self:initDebugData();
end

--[[
    在这个方法中保存所有sys需要的数据
    包括:
        本地
        服务器
]]--
function ChrismasData:Dispose()

end

function ChrismasData:CallBaiduEventEnd(eventName)
    print("-----------------------------------------baidu record1:"..eventName);

    if eventName ~= nil then 
        print("-----------------------------------------baidu record2:"..eventName);
        Utils:GetInstance():baiduTongji("xialingying",eventName)
    end
end

return ChrismasData;

--[[
function ChrismasData:getSkinList()
    local d = self:GetData();
    local indexOfBackGround = d.UserDecorationOptions[1];
    local indexOfDecoration = d.UserDecorationOptions[2];
    local indexOfWord = d.UserDecorationOptions[3];
    local t = {};

    for i = 1,#d.ListOfBackGroundOption,1 do 
        if indexOfBackGround == d.ListOfBackGroundOption[i].index then 
            t[1] = i;
        end
    end
    for i = 1,#d.ListOfDecorationOption,1 do 
        if indexOfDecoration == d.ListOfDecorationOption[i].index then 
            t[2] = i;
        end
    end
    for i = 1,#d.ListOfWordOption,1 do 
        if indexOfWord == d.ListOfWordOption[i].index then 
            t[3] = i;
        end
    end
    return t;
end
]]--