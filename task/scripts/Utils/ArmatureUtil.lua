local ArmatureUtil = {}

--[[
    播放一次某个动画的某个标签
    参数:
    n:要播放的动画
    i:要播放的标签
    cb:标签播放完一次的回掉
]]--
ArmatureUtil.Play = function(n,i,cb) 
    if n ~= nil then 
        n:playByIndex(i,LOOP_NO);
        n:setLuaCallBack(function ( eType, pTouchArm, sEvent )
            if eType == TouchArmLuaStatus_AnimPerEnd then
                if cb ~= nil then
                    cb(); 
                end
            end
        end)
    else 
        print("Error: ArmatureUtil.PlayLoop n == nil");
        print(debug.traceback(  ));
    end
end

--[[
    播放一个标签并停止在某一个标签
    参数:
    n:要播放的动画
    i:要播放的标签
    ni:播放完成后要保持的那个标签
]]--
ArmatureUtil.PlayAndStay = function(n,i,ni) 
    ArmatureUtil.Play(n,i,function() 
        ArmatureUtil.PlayLoop(n,ni);
    end)
end

--[[
    播放一个标签并保持循环
]]--
ArmatureUtil.PlayLoop = function(n,i) 
    if n ~= nil then 
        n:playByIndex(i,LOOP_YES);
    else 
        print("Error: ArmatureUtil.PlayLoop n == nil");
        print(debug.traceback(  ));
    end
end


return ArmatureUtil;