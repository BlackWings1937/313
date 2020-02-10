-- MBUtiel——解释鹊桥配置文件的工具类
--      使用前需要使用LoadProtocalFile，加载一份鹊桥生成的配置文件
--      主要函数：
--          GetNPCName              —— 获取NPC协议下的NPC名字
--          GetActionNPCName        —— 获取动作协议下的NPC名字
--          GetActionIndex          —— 获取动作协议下，动画填写的动画标签
--          ShouldChangeArmature    —— 是否应该更换Armature
--          CreateArmatureByNpcName —— 创建touchArmature 
--
g_tConfigTable.NewRootFolderPath = "baseScripts.homeUI.";
local FileUtil = requirePack(g_tConfigTable.NewRootFolderPath.."FrameWork.Util.FileUtil");
local TouchArmatureTmp = requirePack(g_tConfigTable.NewRootFolderPath.."FrameWork.Util.TouchArmatureTmp");

local MBUtil = {};

MBUtil.protocalFileName_ = nil;
MBUtil.protocalDict_ = nil;
MBUtil.armatureProtocals_ = {};

---------------------------------------------------------------------------
----------------------------------外部接口----------------------------------
---------------------------------------------------------------------------

-- 加载一个配置文件
-- 参数:
--      @ path: 配置文件的绝对路径 
MBUtil.LoadProtocalFile = function (path)
    local jsonStr = FileUtil.LoadFileContent(path);
    MBUtil.armatureProtocals_ = json.decode(jsonStr);
    MBUtil.protocalDict_ =  MBUtil.armatureProtocals_["Animation"];
    MBUtil.protocalFileName_ = protocalFileName;
end

-- 获取一个NPC美术名字
-- 参数:
--      progNPCName：NPC程序名字
-- 返回值：
--      返回指定NPC程序名字对应的美术名字，如果不存在，返回nil
MBUtil.GetNPCName = function (progNPCName)
    local result = nil;
    local armatureProtocal = MBUtil.protocalDict_[progNPCName];
    if armatureProtocal ~= nil then
        result = armatureProtocal.AnimName;
    end
    if result == nil then 
        result = "MISS_PROTOCAL:"..progNPCName;
    end
    return result;
end

-- 获取一个动作协议的NPC名字
-- 参数：
--      progNPCName: NPC程序名字
--      progActionName: 程序标签名字
-- 返回值：
--      rresult: 动作协议NPC名字
MBUtil.GetActionNpcName = function ( progNPCName, progActionName )
    local result = nil;
    local armatureProtocal = MBUtil.protocalDict_[progNPCName];
    if armatureProtocal ~= nil then
        local actions = armatureProtocal.Actions;
        local actionProtocal = actions[progActionName];
        if actionProtocal ~= nil then
            result = actionProtocal.AnimNPCName;
        end
    end
    if result == nil then 
        result = "MISS_PROTOCAL:"..progNPCName.."INDEX:"..progActionName;
    end
    return result;
end

-- 获取一个动画的美术名字
-- 参数：
--      progNPCName：NPC程序名字
--      progActionName：标签程序名字
-- 返回值：
--      result: <动画美术名字>
MBUtil.GetActionIndex = function (progNPCName, progActionName)
    local result = nil;
    local armatureProtocal = MBUtil.protocalDict_[progNPCName];
    if armatureProtocal ~= nil then
        local actions = armatureProtocal.Actions;
        local actionProtocal = actions[progActionName];
        if actionProtocal ~= nil then
            result = actionProtocal.AnimName;
        end
    end
    if result == nil then 
        result = 0;--"MISS_PROTOCAL:"..progNPCName.."INDEX:"..progActionName;
    end
    return result;
end

-- 比较指定动作协议上的NPC名字是否对应NPC协议的NPC名字，判断是否需要更换Armature
-- （注意，如果progNPCName和progActionName都不存在会导致无论如何都返回true）
-- 参数：
--      progNPCName: NPC程序名字
--      progActionName: 标签程序名字
-- 返回值：
--      bool类型的返回值，表示是否需要更换Armature
MBUtil.ShouldChangeArmature = function(progNPCName, progActionName)
    local defaultNPCName = MBUtil.GetNPCName(progNPCName);
    local actionNPCName = MBUtil.GetActionNpcName(progNPCName, progActionName);
    
    if actionNPCName == nil or defaultNPCName == nil then
        print("MBUtil::Warnning:: progNPCName或者progActionName不存在!");
    end

    return defaultNPCName ~= actionNPCName;
end


-- 创建一个TouchArmatureMB
-- 参数：
--      @ progName: 程序NPC名字
--      @ size: 创建NPC大小，可选 
-- 返回值：
--      一个TouchArmatureMB，如果NPC名字不存在，返回nil
MBUtil.CreateArmatureByNpcName = function( progName, size )
    local result = nil;
    local info = MBUtil.armatureProtocals_.Animation[progName];
    if info == nil then
        print("MBUtil::ERROR:: 没有" .. progName .. "的NPC角色" );
        result = TouchArmatureTmp.new();
        if size ~= nil then
            result:Init("PROTOCAL_MISS:"..progName,size);
        else
            result:Init("PROTOCAL_MISS:"..progName,cc.size(100,150));
        end
    else
        if info.NPCComplie == "true"  then --
            result = TouchArmature:create(MBUtil.GetNPCName(progName), TOUCHARMATURE_NORMAL, "");
        else
           result = TouchArmatureTmp.new();
           if size ~= nil then
               result:Init(info.AnimName,size);
           else
               result:Init(info.AnimName,cc.size(100,150));
           end
       end
    end
    return result;
end

-- 创建一个TouchArmatureMB
-- 参数：
--      @ progName: 程序NPC名字
--      @ ActionName:程序定义的动作名称
--      @ size: 创建NPC大小，可选 
-- 返回值：
--      一个TouchArmatureMB，如果NPC名字不存在，返回nil
MBUtil.CreateArmatureByActionNpcName = function(progName,ActionName, size )
    local result = nil;
    print("MBUtil.CreateArmatureByActionNpcName");
    local info = MBUtil.armatureProtocals_.Animation[progName];
    if info == nil then
        result = TouchArmatureTmp.new();
        if size ~= nil then
            result:Init("PROTOCAL_MISS:"..progName,size);
        else
            result:Init("PROTOCAL_MISS:"..progName,cc.size(100,150));
        end
    else

        if info.NPCComplie == "true"  then --
            result = TouchArmature:create(MBUtil.GetActionNpcName(progName, ActionName), TOUCHARMATURE_NORMAL, "");
       elseif  info.NPCComplie == "false"  then 
           result = TouchArmatureTmp.new();
           if size ~= nil then
               result:Init(info.AnimName,size);
           else
               result:Init(info.AnimName,cc.size(100,150));
           end
       end
    end
    return result;
end

return MBUtil;