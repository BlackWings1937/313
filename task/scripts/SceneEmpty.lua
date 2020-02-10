requirePack("scripts.FrameWork.Global.GlobalFunctions");
local SceneTouches = requirePack("scripts.FrameWork.Scenes.SceneTouches");
local SceneEmpty = class("SceneEmpty", function(...)
    -- 创建sceneBase基类
    return SceneTouches.new(...);
end )
g_tConfigTable.CREATE_NEW(SceneEmpty);
function SceneEmpty:ctor()
    print("SceneEmpty hello world 123123~");
end

function SceneEmpty:initScene()

end

return SceneEmpty;