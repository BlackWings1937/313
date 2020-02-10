local JsonScriptUtil = {};


JsonScriptUtil.INT_MAX_ENGINE_ZORDER = 100000;               -- 引擎显示对象最大zorder

JsonScriptUtil.IsBanPlay = false;

--[[
    设置当前项目剧情脚本读取相关路径
    参数:
    jsonPath:json文件路径
    imagePath:图片文件路径
    audioPath:音频资源路径
]]--
JsonScriptUtil.SetJsonPath = function(jsonPath,imagePath,audioPath)
    JsonScriptUtil.jsonPath_ = jsonPath;
    JsonScriptUtil.imagePath_ = imagePath;
    JsonScriptUtil.audioPath_ = audioPath;
end


--[[
    播放 json - [bgconfig]
    参数:
    n:舞台节点
    jsonName:bgconfig 名称
    cb: 播放完成回掉方法
    返回
    tag:json 动作唯一tag 或 -1 如果初始化失败的话
]]--
JsonScriptUtil.PlayBgConfig = function(n,jsonName,cb) 
    if JsonScriptUtil.IsBanPlay then 
        return;
    end
    --writeToFile("JsonScriptUtil.PlayBgConfig:"..jsonName);
    --writeToFile(debug.traceback(  ));
    return g_tConfigTable.AnimationEngine:GetInstance():PlayPackageBgConfig(
        JsonScriptUtil.jsonPath_..jsonName..".json",
		n,
		JsonScriptUtil.imagePath_,
		JsonScriptUtil.audioPath_ ,
		cb
    );
end

--[[
    播放 json - [action]
    参数:
    n:舞台节点
    jsonName:action 名称
    cb: 播放完成回掉方法
    返回
    tag:json 动作唯一tag 或 -1 如果初始化失败的话
]]--
JsonScriptUtil.PlayAction = function (n,jsonName,cb) 
    if JsonScriptUtil.IsBanPlay then 
        return;
    end
    --writeToFile("JsonScriptUtil.action:"..jsonName);
    --writeToFile(debug.traceback(  ));
    return g_tConfigTable.AnimationEngine:GetInstance():PlayPackageAction(
        JsonScriptUtil.jsonPath_..jsonName..".json",
		n,
		JsonScriptUtil.imagePath_,
		JsonScriptUtil.audioPath_ ,
		cb
    );
end

--[[
    播放 json - [action] [冻结ZOrder 变化]
    参数:
    n:舞台节点
    jsonName:action 名称
    cb: 播放完成回掉方法
    返回
    tag:json 动作唯一tag 或 -1 如果初始化失败的话
]]--
JsonScriptUtil.PlayActionFronzenZ = function (n,jsonName,cb) 
    if JsonScriptUtil.IsBanPlay then 
        return;
    end
    return g_tConfigTable.AnimationEngine:GetInstance():PlayScriptIntelligent(
        JsonScriptUtil.jsonPath_..jsonName..".json",
		n,
		JsonScriptUtil.imagePath_,
		JsonScriptUtil.audioPath_ ,
        cb,
        1,false,true
    );
end

--[[
    将动作跳跃到最后一帧
    参数:
    tag: 动作唯一tag
]]--
JsonScriptUtil.ProcessActionToEndByTag = function (tag)
    if JsonScriptUtil.IsBanPlay then 
        return;
    end
    g_tConfigTable.AnimationEngine:GetInstance():ProcessActionToEndByTag(tag);
end

--[[
    将动作移除
    参数:
    tag: 动作唯一tag
]]--
JsonScriptUtil.StopActionByTag = function (tag)

    g_tConfigTable.AnimationEngine:GetInstance():StopPlayStory(tag);
end



--[[
    获取动画引擎创建的npc 对象
    参数:
    n:舞台节点
    npcName: 动画 .fla 文件中定义的npc图层名称
    返回
    nil or 对应的Armature
]]--
JsonScriptUtil.GetNpcByName = function(n,npcName) 
    return n:getChildByName("AESOP*" .. npcName);
end


--[[
    终止节点中所有在运行的json
    参数:
    n:舞台节点
]]--
JsonScriptUtil.StopAllAction = function (n) 
    g_tConfigTable.AnimationEngine:GetInstance():StopAllActionsOnTheater(n);
end


--[[
    判断是否有动作正在节点上执行
]]--
JsonScriptUtil.IsActionRunning = function(n) 
    local listOfActions = g_tConfigTable.AnimationEngine:GetInstance().listOfScriptActions_;
    local count = #listOfActions;
    local nodeName = n:getName();--
    for i = 1,count,1 do 
        local action = listOfActions[i];
        if nodeName == action:GetTheaterName() then 
            return true;
        end
    end
    return false;
end



return JsonScriptUtil;