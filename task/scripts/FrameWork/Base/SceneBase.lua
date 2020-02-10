-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
requirePack("scripts.FrameWork.Global.GlobalFunctions");
local SceneBase = class("SceneBase", function(...)
    local sTaskpath, sSource, eCallfrom, bIsMain, pStoryEngine, pParentNode = ...;
    local pStoryTmp = tolua.cast(pStoryEngine, "Ref")
    local pParentTmp = tolua.cast(pParentNode, "Ref")
    return PlayNodeBaseLua:createPlayBaseLua(sTaskpath, sSource, eCallfrom, bIsMain, pStoryTmp, pParentTmp)
end );

--[[
    创建New 方法
]]--
g_tConfigTable.CREATE_NEW(SceneBase);

function SceneBase:ctor(...)
    -- 复制全局变量
    local sTaskpath, sSource, eCallfrom, bIsMain, pStoryEngine, pParentNode = ...;
    g_tConfigTable.sTaskpath = sTaskpath;
    g_tConfigTable.Director.CurrentScene = self;
    self.m_parentNode = pParentNode;
    self.m_currbglayer = StoryBgLayer.curBgLayer
    self.m_currscene = StoryEngineScene.curStoryEngineScene
    self.m_currV4Scene = StoryV4Scene.curV4Scene
    -- 注册系统方法
    print("onexit -------------------1");

    self:setBaseCallBack( function(sType)
        if sType == "back" then
            self:onExit()
        elseif sType == "onExit" then
            print("onexit -------------------2");
            self:onExit()
        elseif sType == "onEnter" then
            self:onEnter()
        end
    end )

    -- 注册语音
    self.speak = Speak:create()
    self.speak:retain()
end

function SceneBase:onEnter()
end

function SceneBase:say(audio, arm, func)
    local cfg = self.m_currscene:getAudioCfgPath(audio);
    self.speak:sayCfgLua(arm, cfg, "", func);
end

function SceneBase:sayWithSubTitle(audio, title, arm, func)
    StoryBgLayer.curBgLayer:addSubtitle(title, CFG_X(383, 2), CFG_Y(936, 2), CFG_SCALE(1.0, 2), audio);
    -- say word
    self:say(audio, arm, function()
        self.m_currbglayer:removeSubtitle()
        func();
    end );
end

function SceneBase:getNpcByName(name)
    return self.m_currbglayer:getNpcArmature(name);
end

function SceneBase:onExit()
    if self.speak ~= nil then
        self.speak:cancelMyAction()
        self.speak:release()
        self.speak = nil
    end
end

function SceneBase:moduleSuccess(dt)
    self.m_PlayerState = STORY4V_PLAY_SUCCESS
    self:moduleEnd()
end

function SceneBase:moduleEnd()
    local function onModuleEndDo()
        self:onModuleEndDo()
    end
    performWithDelay(self, onModuleEndDo, 0.017)
end

function SceneBase:onModuleEndDo()
     self.m_currscene.isSpeakBusy = false
     self:moduleEndNormal(self.m_PlayerState)
    -- 下面那段代码在父节点函数实现

end

--[[
    判断当前类型支持哪个模块,返回true是支持，返回false是不支持，
    sEnterType 的值为： engine 是主引擎， v4Scene 是V4Scene场景， group 是group玩法
]]--

function SceneBase.JudgeSuportEnterModule(sEnterType)
    return true
end

return SceneBase;

