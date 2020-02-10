--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
requirePack("scripts.FrameWork.Global.GlobalFunctions");
requirePack("scripts.FrameWork.Box2D.Box2dManager");
local SceneBase = requirePack("scripts.FrameWork.Base.SceneBase");

local ScenePhysic = class("ScenePhysic",function (...)
    
    return SceneBase.new(...);
end);

g_tConfigTable.CREATE_NEW(ScenePhysic);

-----------------常量--------------------------
ScenePhysic.ACTION_TAG_DELETE_PHYSIC_WORLD = 1001;

-----------------重写方法----------------------
function ScenePhysic:ctor(...)
    
end

function ScenePhysic:initPhysic(pathOfPeFile,gravity)
    g_tConfigTable.Box2dManager.getInstance(self,pathOfPeFile,gravity);
end

function ScenePhysic:onEnter()
    SceneBase.onEnter(self);
end

function ScenePhysic:onExit()
    SceneBase.onExit(self);
end

-- 清理物理内容
function ScenePhysic:DisposePhysic(cb)
    if self:getActionByTag(ScenePhysic.ACTION_TAG_DELETE_PHYSIC_WORLD) == nil then 
        local seq = cc.Sequence:create(
            cc.DelayTime:create(0.016),
            cc.CallFunc:create(function ()
                g_tConfigTable.Box2dManager.clear();
            end),
            cc.DelayTime:create(0.016),
            cc.CallFunc:create(function ()
                if cb~= nil then 
                cb();
                end
            end),
            nil);
        seq:setTag(ScenePhysic.ACTION_TAG_DELETE_PHYSIC_WORLD);
        self:runAction(seq);
    end
end

-- 结束的表现
function ScenePhysic:moduleEnd()
    self:DisposePhysic(function ()
        ScenePhysic.moduleEnd(self);
    end);
end


return ScenePhysic;
--endregion
