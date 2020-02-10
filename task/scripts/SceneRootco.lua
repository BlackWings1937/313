requirePack("baseScripts.homeUI.FrameWork.AnimationEngineLua.AnimationEngine");
requirePack("scripts.FrameWork.Global.GlobalFunctions");
local SceneTouches = requirePack("scripts.FrameWork.Scenes.SceneTouches");
local Controller = requirePack("scripts.MVC.SysForNewYear.NewYearController");
local View = requirePack("scripts.MVC.SysForNewYear.NewYearView");
local Data = requirePack("scripts.MVC.SysForNewYear.NewYearData");
local SceneRoot = class("SceneRoot", function(...)
    -- 创建sceneBase基类
    return SceneTouches.new(...);
end )
g_tConfigTable.CREATE_NEW(SceneRoot);
function SceneRoot:ctor()
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