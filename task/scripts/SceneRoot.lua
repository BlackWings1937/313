requirePack("baseScripts.homeUI.FrameWork.AnimationEngineLua.AnimationEngine");
requirePack("scripts.FrameWork.Global.GlobalFunctions");
local SceneTouches = requirePack("scripts.FrameWork.Scenes.SceneTouches");
local Controller = requirePack("scripts.MVC.SysForDragon.DragonController");
local View = requirePack("scripts.MVC.SysForDragon.DragonView");
local Data = requirePack("scripts.MVC.SysForDragon.DragonData");
local SceneRoot = class("SceneRoot", function(...)
    -- 创建sceneBase基类
    return SceneTouches.new(...);
end )
g_tConfigTable.CREATE_NEW(SceneRoot);
function SceneRoot:ctor()
    --self:setScale(0.5);
    local diff = 100;
   -- self:setPosition(cc.p(diff,diff+50));
    g_tConfigTable.SceneNow_ = self;
    print("SceneRoot hello world 123123~");
    g_tConfigTable.AnimationEngine.GetInstance();
    self.controller_ = Controller.new();
    self.controller_:Start(self,View,Data);
end

function SceneRoot:onExit()
    g_tConfigTable.AnimationEngine.GetInstance():Dispose();
    print("sceneRoot onexit ------------------------------- ");
    self.controller_:Stop();
    SceneTouches.onExit(self);
end

return SceneRoot;