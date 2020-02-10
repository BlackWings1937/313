-- requirePack("baseScripts.homeUI.FrameWork.Global.GlobalFunctions")
-- requirePack("baseScripts.homeUI.FrameWork.AnimationEngineLua.AnimationEngine")
g_tConfigTable.NewRootFolderPath = "scripts."
requirePack("scripts.FrameWork.AnimationEngineLua.AnimationEngine")
requirePack("scripts.Common.GFunctions")  --通用方法 重写g_tConfigTable方法
-------------------------------------- 每个玩法必须拥有的声明方法 -----------------------------------

local BasePlayScene =
    class(
    "BasePlayScene",
    function(...)
        local sTaskpath, sSource, eCallfrom, bIsMain, pStoryEngine, pParentNode = ...
        local pStoryTmp = tolua.cast(pStoryEngine, "Ref")
        local pParentTmp = tolua.cast(pParentNode, "Ref")
        return PlayNodeBaseLua:createPlayBaseLua(sTaskpath, sSource, eCallfrom, bIsMain, pStoryTmp, pParentTmp)
    end
)
-- 判断当前类型支持哪个模块,返回true是支持，返回false是不支持，
-- sEnterType 的值为： engine 是主引擎， v4Scene 是V4Scene场景， group 是group玩法
function BasePlayScene.JudgeSuportEnterModule(sEnterType)
    -- if sEnterType == "engine" then
    -- 	return false
    -- end
    return true
end

--[[new]]
g_tConfigTable.CREATE_NEW(BasePlayScene)
g_tConfigTable.Debug = true
g_tConfigTable.isTest = false
local FINGER_SPEED = 128

--cc.p(CFG_X(),CFG_GL_Y())
-- cc.Sequence:create
--cc.DelayTime:create
--cc.CallFunc:create
--cc.Spawn:create
--cc.pGetDistance
-------------------------------------------------------------------------------------------------
-- 已经创建初步初始化完成
function BasePlayScene:ctor(...)
    local sTaskpath, sSource, eCallfrom, bIsMain, pStoryEngine, pParentNode = ...

    --设置基础回调，返回，和重新开始，onEnter,onExit 的通知回调
    self:setBaseCallBack(
        function(sType)
            if sType == "back" then
                --self:onExit()
                performWithDelay(self, self.moduleEnd, 0.17)
            elseif sType == "onExit" then
                self:onExit()
            elseif sType == "onEnter" then
                self:onEnter()
            end
        end
    )
    -- 复制全局变量
    self.m_isMain = bIsMain
    self.m_parentNode = pParentNode
    self.m_currscene = StoryEngineScene.curStoryEngineScene
    self.m_currV4Scene = StoryV4Scene.curV4Scene
    self.m_PlayerState = STORY4V_PLAY_ING
    self.strCfgPath = sTaskpath
    self.sourceID = sSource
    self.m_SoundPath = self.strCfgPath .. "animation/sounds/" --声音的路径 音效

    local stringT = self:stringSplit(self.strCfgPath, "/")
    self.BagID = stringT[#stringT - 1]
    -- 注册语音
    self.speak = Speak:create()
    self.speak:retain()
    self.speakTable = {} --存储临时speak，以防打断没释放掉

    self.scheduleList = {}

    local node1 = cc.Node:create()
    local node2 = cc.Node:create()
    self:addChild(node1)
    self:addChild(node2)
    self.stageNode = node1 --舞台节点
    self.topNode = node2 --顶层节点 放点击提示等

    self.ui_node = cc.Node:create()--UI层节点（与topNode不同，这个不会缩放）
	self.stageUI = cc.Node:create()--UI舞台
	self:addChild(self.ui_node)
	self:addChild(self.stageUI)

    self.fingerArm = nil --手指提示
    self.blockNum = 1 --用于处理随机数
    self.ostime = 0

    --动画播放引擎Date
    g_tConfigTable.sTaskpath = self.strCfgPath --路径
    self.stageNode:setPosition(g_tConfigTable.Director.midPos) --设置舞台节点位置
    self.topNode:setPosition(g_tConfigTable.Director.midPos) --同步节点位置
    self.AnimationEngine = g_tConfigTable.NewAnimationEngine:GetInstance() --新的动画播放引擎

    self.scheduler = cc.Director:getInstance():getScheduler()
end
---------------------------------------------------------------------------------------------------
--[[onEnter]]
function BasePlayScene:onEnter()
    self:createTouch()
    --! 跳关的开关
    if g_tConfigTable.isFrankTest then
        self:createButton(
            self,
            function(...)
                self:moduleSuccess()
            end
        )
    end
end
--[[onExit]]
function BasePlayScene:onExit()
    self.AnimationEngine:Dispose() --!撤销动画引擎
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListener(self.m_listener) --!移除点击监听
    self:removeAllChildren()
    if self.speak ~= nil then
        self.speak:cancelMyAction()
        self.speak:release()
        self.speak = nil
    end
    for _, v in pairs(self.speakTable) do
        if v ~= nil then
            v.speakObj:cancelMyAction()
            v.speakObj:release()
            v = nil
        end
    end

    for _, v in pairs(self.scheduleList) do
        if v ~= nil then
            self.scheduler:unscheduleScriptEntry(v)
            v = nil
        end
    end
end
---------------------------------------------------------------------------------------------------
--[[退出]]
function BasePlayScene:moduleSuccess(dt)
    self.AnimationEngine:Dispose() --!撤销动画引擎

    self.m_PlayerState = STORY4V_PLAY_SUCCESS
    self:moduleEnd()
end

function BasePlayScene:moduleEnd()
    print("BasePlayScene moduleEnd")
    local function onModuleEndDo()
        self:onModuleEndDo()
    end
    performWithDelay(self, onModuleEndDo, 0.017)
end

function BasePlayScene:onModuleEndDo()
    self.m_currscene.isSpeakBusy = false
    self:moduleEndNormal(self.m_PlayerState)

    -- self.m_parentNode:onChildEnd("BasePlayScene", self.m_PlayerState, ranking)
    -- self:removeFromParent()
end
---------------------------------------------------------------------------------------------------
--*[[function]]
---------------------------------------------------------------------------------------------------
function BasePlayScene:InitBgConfig(node, jsonName, callback)
    local tag =
        self.AnimationEngine:PlayPackageBgConfig(
        g_tConfigTable.sTaskpath .. "scene/" .. self.sourceID .. "/" .. jsonName,
        node,
        g_tConfigTable.sTaskpath .. "animation/",
        --g_tConfigTable.sTaskpath .. "audio/",
        g_tConfigTable.sTaskpath .. "animation/sounds/",
        function(eventName)
            if eventName == "Complie" then
                if callback then
                    self:CorrectionNode() --每次播放完动画 后同步节点位置
                    self:displayNameAndZOrder()
                    -- self:drawRect() --画框
                    callback()
                end
            end
        end
    )
    print("PlayPackageBgConfig -----------", jsonName)
    return tag
end
--*[[新的动画播放 node:舞台节点 动画json名,回调]]
function BasePlayScene:playAnimation(node, jsonName, callback, Ename, callback1)
    local tag =
        self.AnimationEngine:PlayPackageAction(
        g_tConfigTable.sTaskpath .. "scene/" .. self.sourceID .. "/" .. jsonName,
        node,
        g_tConfigTable.sTaskpath .. "animation/",
         --g_tConfigTable.sTaskpath .. "audio/",
        g_tConfigTable.sTaskpath .. "animation/sounds/",
        function(eventName)
            if eventName == Ename then
                print("xxxxxxxxxxxxxxxEname", Ename)
                self:CorrectionNode() --每次播放完动画 后同步节点位置
                if callback1 then
                    callback1()
                end
            end
            if eventName == "Complie" then
                if callback then
                    self:CorrectionNode() --每次播放完动画 后同步节点位置
                    self:displayNameAndZOrder()
                    -- self:drawRect() --画框
                    callback()
                end
            end
        end
    )
    print("PlayPackageAction -----------", jsonName)
    return tag
end
function BasePlayScene:playAnimationNotchangeZOrder(node, jsonName, callback)
    local tag =
        self.AnimationEngine:PlayScriptIntelligent(
        g_tConfigTable.sTaskpath .. "scene/" .. self.sourceID .. "/" .. jsonName,
        node,
        g_tConfigTable.sTaskpath .. "animation/",
         --g_tConfigTable.sTaskpath .. "audio/",
        g_tConfigTable.sTaskpath .. "animation/sounds/",
        function(eventName)
            if eventName == "Complie" then
                if callback then
                    self:CorrectionNode() --每次播放完动画 后同步节点位置
                    self:displayNameAndZOrder()
                    -- self:drawRect() --画框
                    callback()
                end
            end
        end,
        1,
        false,
        true
    )
    print("playAnimationNotchangeZOrder -----------", jsonName)
    return tag
end
-- *[[停止当前自由点击播放 By tag]]
function BasePlayScene:stopFreeClick(clickList)
    if clickList then
        for k, v in pairs(clickList) do
            if v.tag then
                print("frank stop----------stop", v.tag)
                self.AnimationEngine:StopPlayStory(v.tag)
                v.tag = nil
            end
        end
    end
end

--*[[同步top节点 舞台节点位置]]
function BasePlayScene:CorrectionNode()
    self.topNode:setAnchorPoint(self.stageNode:getAnchorPoint())
    self.topNode:setRotation(self.stageNode:getRotation())
    self.topNode:setScaleX(self.stageNode:getScaleX())
    self.topNode:setScaleY(self.stageNode:getScaleY())
    self.topNode:setRotationSkewX(self.stageNode:getRotationSkewX())
    self.topNode:setRotationSkewY(self.stageNode:getRotationSkewY())
    self.topNode:setContentSize(self.stageNode:getContentSize())
    self.topNode:setPosition(cc.p(self.stageNode:getPosition()))
end

--*[[创建点击手指提示]]
function BasePlayScene:createClickPrompt(Point, Index, Scale, layer)
    if self.fingerArm ~= nil then
        return
    end
    self.fingerArm = TouchArmature:create("point_all", TOUCHARMATURE_NORMAL, "")
    self.fingerArm:setPosition(cc.p(Point))
    self.fingerArm:setScale(CFG_SCALE(Scale))
    self.fingerArm:setLocalZOrder(1001)
    layer:addChild(self.fingerArm)

    self.fingerArm:playByIndex(Index, LOOP_YES, self.m_SoundPath)
end

--*[创建拖动手提提示]
function BasePlayScene:createDragPrompt(p1, p2, Scale, layer)
    if self.fingerArm ~= nil then
        return
    end
    self.fingerArm = TouchArmature:create("point_all", TOUCHARMATURE_NORMAL, "")
    self.fingerArm:setPosition(cc.p(p1))
    self.fingerArm:setScale(CFG_SCALE(Scale))
    self.fingerArm:setLocalZOrder(1001)
    layer:addChild(self.fingerArm)

    local function callback1()
        self.fingerArm:playByIndex(2, LOOP_NO, self.m_SoundPath)
    end
    local function callback2()
        self.fingerArm:setPosition(cc.p(p1))
    end

    local time = cc.pGetDistance(p1, p2) / FINGER_SPEED
    local moveAction = cc.MoveTo:create(time, p2)
    local spawn = cc.Spawn:create(cc.CallFunc:create(callback1), cc.FadeIn:create(0.5))
    local sequence = cc.Sequence:create(spawn, moveAction, cc.DelayTime:create(0.5), cc.FadeOut:create(0.5), cc.CallFunc:create(callback2))
    local action = cc.RepeatForever:create(sequence)
    self.fingerArm:runAction(action)
end

--*[[移除手指提示]]
function BasePlayScene:removeFingerTip()
    if self.fingerArm ~= nil then
        self.fingerArm:stopAllActions()
        self.fingerArm:removeFromParent()
        self.fingerArm = nil
    end
end

--*[[显示舞台的子节点 名称 层级]]
function BasePlayScene:displayNameAndZOrder()
    print("displayNameAndZOrder",g_tConfigTable.isTest)
    if not g_tConfigTable.isTest then
        return
    end
    print("----------------displayNameAndZOrder---------------")
    local nodelist = self.stageNode:getChildren()
    for k, v in pairs(nodelist) do
        print("frank--------", v:getName(), v:getLocalZOrder())
    end
    print("listSize------------------------", #nodelist)
    print("---------------------------------------------------")
end
--*[[显示舞台的子TouchArmaturede  Rect]]
function BasePlayScene:drawRect()
    local nodelist = self.stageNode:getChildren()
    for k, v in pairs(nodelist) do
        if string.find(v:getName(), "npc") ~= nil or string.find(v:getName(), "XBL") ~= nil then
            self:drawNpcRect(v, self.topNode)
        end
    end
end

--*[[显示NPC的大小]]
function BasePlayScene:drawNpcRect(arm, layer)
    local x, y, width, height = 0, 0, 0, 0
    x, y, width, height = arm:getBoundingBoxValue(x, y, width, height)

    local drawNode = cc.DrawNode:create()
    drawNode:retain()
    drawNode:drawRect(cc.p(x, y), cc.p(x + width, y + height), cc.c4f(1, 0, 1, 1))
    layer:addChild(drawNode, 10000)
end

function BasePlayScene:GetCameraPosByNode(node)
    local size = node:getContentSize()
    local anchorPoint = node:getAnchorPoint()

    return cc.p(anchorPoint.x * size.width, size.height * anchorPoint.y)
end

--[[显示真棒]]
function BasePlayScene:zhenbang(callback)
    -- end_finish|0|384,328|1.000|null|0,0|0,0

    self.zbArm = TouchArmature:create("end_finish", TOUCHARMATURE_NORMAL, "")
    self.zbArm:setPosition(cc.p(768 / 2, CFG_GL_Y(328)))

    self.zbArm:setScale(CFG_SCALE(1.000))
    self.topNode:addChild(self.zbArm, 1234)

    self.zbArm:playByIndex(1, LOOP_NO)
    self.zbArm:setLuaCallBack(
        function(eType, _tempArm, sEvent)
            if eType == TouchArmLuaStatus_AnimEnd then
                self.zbArm:playByIndex(0, LOOP_YES)
                if callback then
                    callback()
                end
            end
        end
    )
end
-----------------------------------------------------------------------------------------------------
--*[[创建Touch监听]]
function BasePlayScene:createTouch()
    local function onTouchBegan(touch, event)
        return self:onTouchBegan(touch, event)
    end
    -- 触摸移动
    local function onTouchMoved(touch, event)
        self:onTouchMoved(touch, event)
    end
    -- 触摸结束
    local function onTouchEnded(touch, event)
        self:onTouchEnded(touch, event)
    end
    -- 触摸取消
    local function onTouchCancelled(touch, event)
        self:onTouchCancelled(touch, event)
    end

    -- 添加触摸事件
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchCancelled, cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener, -2)
    self.m_listener = listener
end
--[[touch]]
function BasePlayScene:onTouchBegan(touch, event)
    return false
end

function BasePlayScene:onTouchMoved(touch, event)
end

function BasePlayScene:onTouchEnded(touch, event)
end

function BasePlayScene:onTouchCancelled(touch, event)
    self:onTouchEnded(touch, event)
end
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--[[func]]
--[[获得被点击NPC]]
function BasePlayScene:getDrapArmInfo(touch, list, layer)
    local touchPoint = layer:convertTouchToNodeSpace(touch)
    local drapInfo = nil
    for i = 1, #list do
        local x, y, width, height = 0, 0, 0, 0
        x, y, width, height = list[i].Arm:getBoundingBoxValue(x, y, width, height)
        local targetRect = cc.rect(x, y, width, height)
        if cc.rectContainsPoint(targetRect, touchPoint) then
            drapInfo = list[i]
            break
        end
    end
    return drapInfo
end

--[[判断是否被点击]]
function BasePlayScene:hasClicked(arm, touch, layer)
    local touchPoint = layer:convertTouchToNodeSpace(touch)
    local drapInfo = false
    local x, y, width, height = 0, 0, 0, 0
    x, y, width, height = arm:getBoundingBoxValue(x, y, width, height)
    local targetRect = cc.rect(x, y, width, height)
    if cc.rectContainsPoint(targetRect, touchPoint) then
        drapInfo = true
    end

    return drapInfo
end
---[[根据touc移动arm位置]]
function BasePlayScene:setNewPositionByTouch(arm, touch, layer)
    local touchLocation = layer:convertTouchToNodeSpace(touch)
    local oldTouchLocation = touch:getPreviousLocationInView()
    oldTouchLocation = layer:convertToNodeSpace(cc.Director:getInstance():convertToGL(oldTouchLocation))
    local dis = cc.pSub(touchLocation, oldTouchLocation)
    local newPos = cc.pAdd(cc.p(arm:getPosition()), dis)
    arm:setPosition(newPos)
end
--[[判断是否被包含]]
function BasePlayScene:armContainsPoint(arm, touch, bool, layer)
    --true  触点   arm, touch, bool
    --false  arm锚点位置  arm, pos, bool
    if bool then
        touch = layer:convertTouchToNodeSpace(touch)
    end
    local x, y, width, height = 0, 0, 0, 0
    x, y, width, height = arm:getBoundingBoxValue(x, y, width, height)
    local targetRect = cc.rect(x, y, width, height)
    if cc.rectContainsPoint(targetRect, touch) then
        return true
    else
        return false
    end
end
--*[[语音说话]]
function BasePlayScene:say(arm, audio, callBack)
    local needNewSpeak = true
    local speak
    if next(self.speakTable) ~= nil then
        for k, v in pairs(self.speakTable) do
            if v.Arm == arm then
                needNewSpeak = false
                speak = v.speakObj
            end
        end
    end
    if needNewSpeak then
        speak = Speak:create()
        speak:retain()
        speak:cancelMyAction()
        table.insert(self.speakTable, {speakObj = speak, Arm = arm})
    end

    if callBack == "" or callBack == nil or callBack == "null" then
        callBack = function()
        end
    end
    local cfgFolder = self.m_currscene:getAudioCfgPath(audio)
    speak:sayCfgLua(arm, cfgFolder, "", callBack)
end

---*[[播动画]]
function BasePlayScene:playArm(arm, playIndex, idleIndex, callbackFunc, event, func)
    arm:playByIndex(playIndex, LOOP_NO, self.m_SoundPath)
    if event ~= nil then
        arm:setCustomEventLuaCallBack(
            function(eType, _tempArm, sEvent)
                if eType == TouchArmLuaStatus_AnimEnd then
                    if event == sEvent then
                        if func then
                            func()
                        end
                    end
                end
            end
        )
    end
    arm:setLuaCallBack(
        function(eType, _tempArm, sEvent)
            if eType == TouchArmLuaStatus_AnimEnd then
                if idleIndex ~= "null" and idleIndex ~= "" and idleIndex ~= nil then
                    arm:playByIndex(idleIndex, LOOP_YES, self.m_SoundPath)
                end
                if callbackFunc then
                    callbackFunc()
                end
            end
        end
    )
end

--  {arm , {1},loop_yes ,func}
--  {arm , "audio" ,func}
--*[[单个npc连续播放动画]]
function BasePlayScene:playArmActions(arm, t_Index, loop, callback)
    local func
    func = function(arm, t_Index, _step, loop, callback)
        local recursive = function()
            _step = _step + 1
            func(arm, t_Index, _step, loop, callback)
        end
        local dalay = function()
            if _step == #t_Index then
                self:playAction(arm, t_Index[_step], loop, callback)
            else
                self:playAction(arm, t_Index[_step], LOOP_NO, recursive)
            end
        end
        self:delayFrame(dalay)
    end

    func(arm, t_Index, 1, loop, callback)
end

function BasePlayScene:playAction(arm, idx, loop, callBack)
    local func = function(_tempArm)
        if callBack then
            callBack(_tempArm)
        end
    end
    arm:playByIndex(idx, loop, self.m_SoundPath)
    if loop == LOOP_YES then
        func(arm)
    else
        arm:setLuaCallBack(
            function(eType, _tempArm, sEvent)
                if eType == TouchArmLuaStatus_AnimEnd then
                    func(arm)
                end
            end
        )
    end
end
--[[换骨骼 动画]]
function BasePlayScene:changeBones(arm, boneName, boneImg, boneAni)
    if boneName == "" or boneImg == "" then
        return
    end
    if boneAni ~= nil and boneAni ~= "" and boneAni ~= "null" then
        arm:changeOneSkinToArmature(boneName, boneImg, boneAni)
    else
        arm:ChangeOneSkin(boneName, boneImg)
    end
end
--[[取一个数的整数部分]]
function BasePlayScene:getIntPart(x)
    if x <= 0 then
        return math.ceil(x)
    end

    if math.ceil(x) == x then
        x = math.ceil(x)
    else
        x = math.ceil(x) - 1
    end
    return x
end
--[[取一个数的每一位]]
function BasePlayScene:getEveryDigit(num, digit)
    local t = num
    local a, b, c, d, e, f, g, h, i
    a = self:getIntPart(t % 10) --个位
    b = self:getIntPart(t / 10 % 10)
    --十位
    c = self:getIntPart(t / 100 % 10)
    --百位
    d = self:getIntPart(t / 1000 % 10)
    --千位
    e = self:getIntPart(t / 10000 % 10)
    --万位
    f = self:getIntPart(t / 100000 % 10)
    --十万位
    g = self:getIntPart(t / 1000000 % 10)
    --百万位
    h = self:getIntPart(t / 10000000 % 10)
    --千万位
    i = self:getIntPart(t / 100000000 % 10)
    --亿位

    if digit == 4 then
        return a, b, c, d
    end
    if digit == 3 then
        return a, b, c
    end
end

function BasePlayScene:removeNpc(arm)
    if arm ~= nil then
        arm:stopAllActions()
        arm:removeFromParent()
        arm = nil
    end
end

function BasePlayScene:stringSplit(s, p)
    local rt = {}
    string.gsub(
        s,
        "[^" .. p .. "]+",
        function(w)
            table.insert(rt, w)
        end
    )
    return rt
end

------读文件-------
function BasePlayScene:readFile(filePath)
    local hFile, err = io.open(filePath, "r")
    if hFile and not err then
        local xmlText = hFile:read("*a")
        io.close(hFile)
        return xmlText
    else
        print(err)
        return nil
    end
end

function BasePlayScene:writeFile(filePath, content)
    local hFile, err = io.open(filePath, "w+")
    if hFile and not err then
        hFile:write(content)
        hFile:flush()
        io.close(hFile)
        return true
    else
        print(err)
        return false
    end
end
------写文件-------
function BasePlayScene:tableToJson(t_t, filePath)
    local jsonencode = json.encode(t_t)
    self:writeFile(filePath, jsonencode)
end

function BasePlayScene:createArm(name, scale, pos, zOrder, tag, parent, Index)
    local arm = TouchArmature:create(name, TOUCHARMATURE_NORMAL, tag)
    arm:setScale(CFG_SCALE(scale))
    arm:setPosition(pos)
    parent:addChild(arm, zOrder)
    if Index ~= nil and Index ~= "" then
        arm:playByIndex(Index, LOOP_YES, self.m_SoundPath)
    end
    return arm
end

function BasePlayScene:resetRandomSeed()
    if self.blockNum >= 7 then
        self.blockNum = 1
    else
        self.blockNum = self.blockNum + 1
    end
    self.ostime = os.time()
    self.ostime = self.ostime * self.blockNum

    math.randomseed(tostring(self.ostime):reverse():sub(1, 6))
end

--[[随机返回true false  1/percentage]]
function BasePlayScene:getTrueOrFalse(percentage)
    self:resetRandomSeed()
    local num = math.random(100000000)
    if num % percentage == 0 then
        return true
    else
        return false
    end
end

function BasePlayScene:getArmWidth(arm)
    local x, y, width, height = 0, 0, 0, 0
    x, y, width, height = arm:getBoundingBoxValue(x, y, width, height)
    return width
end

function BasePlayScene:getArmHeight(arm)
    local x, y, width, height = 0, 0, 0, 0
    x, y, width, height = arm:getBoundingBoxValue(x, y, width, height)
    return height
end

function BasePlayScene:rectangleAndLineSegment(arm, oldPoint, newPoint)
    local x, y, width, height = 0, 0, 0, 0
    x, y, width, height = arm:getBoundingBoxValue(x, y, width, height)
    --  p3  p4
    --  p1  p2
    x = arm:getPositionX()
    y = arm:getPositionY()
    local p1 = cc.p(x - width * 0.5, y - height * 0.5)
    local p2 = cc.p(x + width * 0.5, y - height * 0.5)
    local p3 = cc.p(x - width * 0.5, y + height * 0.5)
    local p4 = cc.p(x + width * 0.5, y + height * 0.5)

    if self:IsSegmentIntersect(p1, p3, oldPoint, newPoint) or self:IsSegmentIntersect(p2, p4, oldPoint, newPoint) or self:IsSegmentIntersect(p3, p4, oldPoint, newPoint) then
        -- print("..............", arm:getPositionX(), x)
        -- print("oldPoint...", oldPoint.x, oldPoint.y)
        -- print("newPoint...", newPoint.x, newPoint.y)
        -- print("p1...", p1.x, p1.y)
        -- print("p2...", p2.x, p2.y)
        -- print("p3...", p3.x, p3.y)
        -- print("p4...", p4.x, p4.y)
        -- print("-------------------")
        return true
    else
        return false
    end
end

function BasePlayScene:IsSegmentIntersect(pt1, pt2, pt3, pt4)
    local s, t, ret = 0, 0, false
    ret, s, t = self:IsLineIntersect(pt1, pt2, pt3, pt4, s, t)

    if ret and s >= 0.0 and s <= 1.0 and t >= 0.0 and t <= 1.0 then
        return true
    end

    return false
end

function BasePlayScene:IsLineIntersect(A, B, C, D, s, t)
    if ((A.x == B.x) and (A.y == B.y)) or ((C.x == D.x) and (C.y == D.y)) then
        return false, s, t
    end

    local BAx = B.x - A.x
    local BAy = B.y - A.y
    local DCx = D.x - C.x
    local DCy = D.y - C.y
    local ACx = A.x - C.x
    local ACy = A.y - C.y

    local denom = DCy * BAx - DCx * BAy
    s = DCx * ACy - DCy * ACx
    t = BAx * ACy - BAy * ACx

    if (denom == 0) then
        if (s == 0 or t == 0) then
            return true, s, t
        end

        return false, s, t
    end

    s = s / denom
    t = t / denom

    return true, s, t
end

function BasePlayScene:createButton(node, callFunc)
    local resetBtn = ccui.Button:create(g_tConfigTable.sTaskpath .. "bgimg/button.png")
    -- resetBtn:setTitleText("Visit URL")
    resetBtn:setPosition(cc.p(g_tConfigTable.winSize.width - resetBtn:getContentSize().width, g_tConfigTable.winSize.height - resetBtn:getContentSize().height))
    resetBtn:addClickEventListener(
        function(...)
            print("CreateBUttonCreateBUttonCreateBUttonCreateBUtton")
            if callFunc then
                callFunc()
            end
        end
    )
    self:addChild(resetBtn, 1000000)
end

function BasePlayScene:savaScheduler(value, bool)
    print("savaScheduler-----value", value)
    if bool then
        table.insert(self.scheduleList, value)
    else
        for k, v in pairs(self.scheduleList) do
            if v == value then
                table.remove(self.scheduleList, k)
                break
            end
        end
    end
    dump(self.scheduleList)
end

--增加埋点数据
function BasePlayScene:upTjData(preKey,key,type) 
    if(type==nil or type=="") then 
        type="qunabagMD"
    end 
    -- writeToFile("BasePlayScene:统计"..preKey.."_"..key)
    DataClond:shareMgr():youbanTongJi(type, preKey.."_"..key)
    print(preKey.."_"..key)
end

-----------增加场景NPC----------------------------
function BasePlayScene:setAddObj(tableArr)
	if  tableArr.npcName  ~= nil then
		print("下雪")
		self.addNpcArm = TouchArmature:create(tableArr.npcName, TOUCHARMATURE_NORMAL, "")--
		self.addNpcArm:setPosition(cc.p(tableArr.NpcX,1024-tableArr.NpcY))
		self.addNpcArm:setScale(tableArr.NpcScale)
		self.topNode:addChild(self.addNpcArm,999)
	end
end

-- function BasePlayScene:startScheduler(func)
--     local function tFunction()
--         if func then
--             func()
--         end
--     end
--     self.tipScheduler = self.scheduler:scheduleScriptFunc(tFunction, 30.0, false)
-- end

-- ---------------------------------------------------------------------------------------------------
-- function BasePlayScene:stopScheduler()
--     if self.tipScheduler then
--         self.scheduler:unscheduleScriptEntry(self.tipScheduler)
--         self.tipScheduler = nil
--     end
-- end
return BasePlayScene
