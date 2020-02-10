local BasePlayScene = requirePack("scripts.Common.BasePlayScene")
local Json = requirePack("scripts.Common.Dkjson")

local dragputWill =
    class(
    "dragputWill",
    function(...)
        return BasePlayScene.new(...)
    end
)
--重写 --[[new]]
g_tConfigTable.CREATE_NEW(dragputWill)
---------------------------------------------------------------------------------------------------
local winSize = g_tConfigTable.winSize
local M_TARGET_ZORDER = 100
---------------------------------------------------------------------------------------------------
function dragputWill:ctor(...)
    print("frank-----ctor")
	self:init()
	self:initData()
end



--拖动物
local dragThingsProperty = {
    name = "",
    --标志位
    maskBits = "",
    --拖动物的提示语音
    tipAudio = "",
    --顺序（乱序时不填）
    orderNo = 0,
    --拖动标签
    dragIndex = 0,
    playIndex = 0,
    --拖放结束标签
    endIndex = 0,
    --拖放结束的位置
    endX = 0,
    endY = 0,
    arm = nil,
    --状态tag
    dragSucess = false,
    --最初的位置
    bgPos = cc.p(0, 0),
    bgZorder = 0
}
--目标物
local dragTargetProperty = {
    name = "",
    --入场标签
    entranceIndex = 0,
    --入场后的闲置标签
    idleIndex = 0,
    --正确标签
    playRightIndex = 0,
    --拖完闲置
    endIndex = 0,
    --错误标签
    playWrongIndex = 0,
    --拖到目标区域后移动被拖物到此位置
    x = 0.0,
    y = 0.0,
    --拖放之前换骨骼（意义不明）
    tboneArray = {},
    --拖放之后换骨骼（没有写null）
    boneArray = {},
    --状态tag
    dragSucess = false,
    arm = nil
}


function dragputWill:initData()
    self.debug = true
    self.m_canTouch = false
    self.endstate = false
	self.step = 1
	self.m_clearCount = 0
	self.isEndPlaying = false
	self.speakArm = self.m_currbglayer:getNpcArmature("null")

    self.Cfg.inOrder = false
    
    self.Cfg.inOrderTarget=false  --拖动物可以任意，目标物按顺序播放（适应于多个拖动物，只有一个目标物）

	self.updateScheduler = nil
	self.tipScheduler = nil
	
	self.isFirstDrag=true
end

function dragputWill:init()
    --[解析json配置文件]
    local cfgPath = self.strCfgPath .. "config/" .. "dragputWill_"..self.sourceID..".json" --需要解析的文件路径
    self.Cfg = Json.parseFile(cfgPath)

    --[[StoryBgLayer]]
    self.m_currV4Scene:changeBgLayout(self.sourceID, false)
    self.m_currbglayer = StoryBgLayer.curBgLayer
end
---------------------------------------------------------------------------------------------------
--[[onEnter]]
function dragputWill:onEnter()
    print("frank-----onEnter")
    BasePlayScene.onEnter(self)
    if self.strCfgPath .. "bgimg/sounds/" .. self.Cfg.backgroundMusci then
        SoundUtil:getInstance():playBackgroundMusic(self.strCfgPath .. "bgimg/sounds/" .. self.Cfg.backgroundMusci, true)
    end

    self:enterScene()
end

--[[onExit]]
function dragputWill:onExit()
	print("exit")
	
    SoundUtil:getInstance():stopBackgroundMusic(false)
    BasePlayScene.onExit(self)
end
---------------------------------------------------------------------------------------------------
--[[进入]]
function dragputWill:enterScene()
	local func3 = function()
        self.m_canTouch = true
        -- local info = self.Cfg.AnimationList[self.step]
		self:createDragPrompt(cc.p(self.Cfg.thingsList[1].bgPos), cc.p(self.Cfg.targetList[1].x, 1024-self.Cfg.targetList[1].y), 0.8, self.topNode)
        self:createTipScheduler()

         --------------增加拖动前统计----------------------
        self:upTjData(self.BagID,self.sourceID.."_game")
    end
	
	local func = function()
        -- self.AnimationEngine:RemoveEngineCreatedObjOnNode(self.stageNode) -- 清空舞台
        self:initBgInfo()
        if(string.find(self.Cfg.startJsonName, "json") ~= nil ) then 
            -- self.Cfg.thingsList[1].arm:setVisible(false)
            self:playAnimation(self.stageNode, self.Cfg.startJsonName, func3)
        else
            self:say(self.speakArm, self.Cfg.startJsonName,func3)
        end
    end
    self:InitBgConfig(self.stageNode, self.Cfg.bgconfigJson, func)
    ---------增加雪景---------------------
    if self.Cfg.addNpc ~= nil then
        self:setAddObj(self.Cfg.addNpcInfo)
    end 
end

function dragputWill:initBgInfo()
    for i=1, #self.Cfg.targetList do
		self.Cfg.targetList[i].arm=self.stageNode:getChildByName(self.Cfg.targetList[i].name)
        self.Cfg.targetList[i].hadBeenShot = false
        self.Cfg.targetList[i].bgPos=cc.p(self.Cfg.targetList[i].arm:getPosition())
        if(self.Cfg.targetList[i].x==0 or  self.Cfg.targetList[i].x=="" or self.Cfg.targetList[i].x == nil) then 
            self.Cfg.targetList[i].x=self.Cfg.targetList[i].arm:getPositionX()
            self.Cfg.targetList[i].y=self.Cfg.targetList[i].arm:getPositionY()
        end 
        -- self.Cfg.targetList[i].arm:playByIndex(self.Cfg.targetList[i].idleIndex, LOOP_YES, self.m_SoundPath)
    end
    for i=1, #self.Cfg.thingsList do
        self.Cfg.thingsList[i].arm=self.stageNode:getChildByName(self.Cfg.thingsList[i].name)
        print(self.Cfg.thingsList[i].arm)
        self.Cfg.thingsList[i].dragSucess = false
        self.Cfg.thingsList[i].bgPos = cc.p(self.Cfg.thingsList[i].arm:getPosition())
        self.Cfg.thingsList[i].bgZorder = self.Cfg.thingsList[i].arm:getLocalZOrder()
	end

end

--[[退出]]
function dragputWill:exitScene()
    self:closeTipScheduler()
    local func2 = function()
        self:moduleSuccess()
	end
    local func1 = function()
        self:zhenbang(func2)
    end
    -- local func = function()
    --     self:playAnimation(self.stageNode, self.Cfg.endJsonName, func1)
    -- end
    --------------增加完成拖动统计----------------------
    self:upTjData(self.BagID,self.sourceID.."_gameafter")

    if(string.find(self.Cfg.endJsonName, "json") ~= nil ) then 
        self.m_curThingInfo.arm:setVisible(false)
        self:playAnimation(self.stageNode, self.Cfg.endJsonName, func1)
    else
        --播放台词
        self.Cfg.targetList[1].arm:playByIndex(2, LOOP_YES, self.m_SoundPath)  --组装完成展示
        self:say(self.speakArm, self.Cfg.endJsonName,func1)
    end 
    -- -- self.AnimationEngine:RemoveEngineCreatedObjOnNode(self.stageNode) -- 清空舞台
    -- self:InitBgConfig(self.stageNode, self.Cfg.bgconfigJson03, func)
end
--[[Touch]]
---------------------------------------------------------------------------------------------------
function dragputWill:onTouchBegan(touch, event)
	if not self.m_canTouch then
        return false
    end
    print("onTouchBegan")
	self:removeFingerTip()
	self:closeTipScheduler()
    local touchLocation = self.stageNode:convertTouchToNodeSpace(touch)
    self.m_curThingInfo = self:getRightTouchThingInfo(touchLocation)
    if self.m_curThingInfo then
        -- self:doDragTipsCancel()
        self.m_canTouch = false
        self.canMove = true
        self.m_curThingInfo.arm:setLocalZOrder(100001)  --层级问题
        self.m_curThingInfo.arm:playByIndex(self.m_curThingInfo.dragIndex, LOOP_YES, self.m_SoundPath)
        return true
    else
        return false
    end
end

function dragputWill:onTouchMoved(touch, event)
    if not self.canMove then
        return
    end
    local touchLocation = self.stageNode:convertTouchToNodeSpace(touch)
    local oldTouchLocation = touch:getPreviousLocationInView()
    oldTouchLocation = self.stageNode:convertToNodeSpace(cc.Director:getInstance():convertToGL(oldTouchLocation))
    local translation = cc.pSub(touchLocation, oldTouchLocation)

    local thingsArm = self.m_curThingInfo.arm
    thingsArm:setPosition(cc.pAdd(cc.p(thingsArm:getPosition()), translation))
end

function dragputWill:onTouchEnded(touch, event)
    if not self.canMove then
        return
    end
    local touchLocation = self.stageNode:convertTouchToNodeSpace(touch)
    local oldTouchLocation = touch:getPreviousLocationInView()
    oldTouchLocation = self.stageNode:convertToNodeSpace(cc.Director:getInstance():convertToGL(oldTouchLocation))
    local translation = cc.pSub(touchLocation, oldTouchLocation)

    local thingsArm = self.m_curThingInfo.arm
    thingsArm:setPosition(cc.pAdd(cc.p(thingsArm:getPosition()), translation))

  

    for k, v in pairs(self.Cfg.targetList) do
        local goTagetDistanse = cc.pGetDistance(cc.p(v.arm:getPosition()), cc.p(thingsArm:getPosition()))
        print("goTagetDistanse:"..goTagetDistanse)
        if goTagetDistanse <= self.Cfg.checkSpan and not self.m_curThingInfo.dragSucess  then
            self.canMove = false
        
           if self.m_curThingInfo.maskBits == v.maskBits then 
                print("位置正确", v.name)
                if self:isRightOrder() or self.Cfg.inOrderTarget then
                    self.m_curTargetInfo = v
                    -- self.Cfg.targetList[k].isPut = true
                    self.m_curThingInfo.dragSucess = true
                    local actionTo = cc.MoveTo:create(0.3, cc.p(v.x, 1024-v.y))
                    local function tFunction()
                        print("移动后处理")
                        self:changeBoneAfterMoveToTaget()
                    end
                    thingsArm:stopAllActions()
                    thingsArm:runAction(cc.Sequence:create(actionTo, cc.CallFunc:create(tFunction)))
                    -- self.isSpeaking = true
                    -- self:speakwithNpc(self.Cfg.speakNpc, self.m_curThingInfo.tipAudio)
                end
                -- else
                -- print("位置不对要返回")
                -- self.m_curThingInfo.dragSucess = true
                -- self.isSpeaking = true
                -- self:speakwithNpc(self.Cfg.speakNpc, self.m_curThingInfo.tipAudio)
                -- local actionTo = cc.MoveTo:create(0.1, cc.p(self.m_curThingInfo.bgPos))  --飞回原处
                -- local function tFunction()
                --     self.m_curThingInfo.arm:playByIndex(self.m_curThingInfo.playIndex, LOOP_NO, self.m_SoundPath)
                --     v.arm:playByIndex(self.m_curThingInfo.tPlayIndex, LOOP_NO, self.m_SoundPath)
                --     v.arm:setLuaCallBack(
                --         function(eType, pTouchArm, sEvent)
                --             if eType == TouchArmLuaStatus_AnimEnd then
                --                 self.m_curThingInfo.arm:playByIndex(self.m_curThingInfo.endIndex, LOOP_YES, self.m_SoundPath)
                --                 v.arm:playByIndex(self.m_curThingInfo.tIdleIndex, LOOP_YES, self.m_SoundPath)
                --                 self.m_curThingInfo.arm:runAction(cc.MoveTo:create(0.1, self.m_curThingInfo.bgPos))
                --                 self.m_canTouch = true
                --                 self.m_curThingInfo.dragSucess = false
                --             end
                --         end
                --     )
                -- end
                -- thingsArm:stopAllActions()
                -- thingsArm:runAction(cc.Sequence:create(actionTo, cc.CallFunc:create(tFunction)))
                return
            end
        end
    end

    print("取消移动返回")
    if self.m_curThingInfo.dragSucess then
        return
    end
    self.m_curThingInfo.arm:setLocalZOrder(self.m_curThingInfo.bgZorder)
    self.m_curThingInfo.arm:playByIndex(self.m_curThingInfo.idleIndex, LOOP_YES, self.m_SoundPath)

    self.m_curThingInfo.arm:stopAllActions()
    self.m_curThingInfo.arm:runAction(cc.MoveTo:create(0.1, self.m_curThingInfo.bgPos))
    self.m_canTouch = true
    
    self:createTipScheduler()
end

function dragputWill:onTouchCancelled(touch, event)
    if self.m_curThingInfo.dragSucess then
        return
    end
    self.m_currbglayer:playNpcXianzhi(self.m_curThingInfo.name)
    self.m_curThingInfo.arm:setLocalZOrder(self.m_curThingInfo.bgZorder)

    self.m_curThingInfo.arm:stopAllActions()
    self.m_curThingInfo.arm:runAction(cc.MoveTo:create(0.1, self.m_curThingInfo.bgPos))
    self.m_canTouch = true
end
--[[gameFunc]]
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------

function dragputWill:getRightTouchThingInfo(pos)
    local tmpThingsProperty = nil
    local x, y, width, height = 0, 0, 0, 0
    for k, v in pairs(self.Cfg.thingsList) do
        if not v.dragSucess then
            x, y, width, height = v.arm:getBoundingBoxValue(x, y, width, height)
            local BoundingBox = cc.rect(x, y, width, height)
            if cc.rectContainsPoint(BoundingBox, pos) then
                tmpThingsProperty = v
                break
            end
        end
    end
    return tmpThingsProperty
end

--------------------------暂不用-------------------------------------------------------------------------
function dragputWill:findProperTargetInfo(maskBits)
    local targetInfo = nil
    for k, v in pairs(self.Cfg.targetList) do
        if tonumber(v.maskBits) == tonumber(maskBits) then
            targetInfo = v
            break
        end
    end
    return targetInfo
end

---------------------------------------------------------------------------------------------------
--按需修改配对逻辑
function dragputWill:isRightOrder()
    if self.Cfg.inOrder then
        return self.m_clearCount + 1 == self.m_curThingInfo.orderNo
    else
        return true
    end
end

-------------------------------暂不用--------------------------------------------------------------------
function dragputWill:changeTargetBoneImg()
    for k, v in pairs(self.Cfg.targetList) do
        if v.tboneArray ~= "null" and v.tboneArray ~= "" then
            local tmpArray = string.split(v.tboneArray, ",")
            local boneName = tmpArray[1]
            local boneImg = tmpArray[2]
            v.arm:playByIndex(v.idleIndex, LOOP_YES, self.m_SoundPath)
            v.arm:ChangeOneSkin(boneName, boneImg)
        end
    end
end

---------------------------------------------------------------------------------------------------
function dragputWill:changeBoneAfterMoveToTaget()
    if self.m_curTargetInfo.boneArray ~= "null" and self.m_curTargetInfo.boneArray ~= ""   then
        local tmpArray = string.split(self.m_curTargetInfo.boneArray, ",")
        local boneName = tmpArray[1]
        local boneImg = tmpArray[2]
        if #tmpArray == 3 then
            local boneAni = tmpArray[3]
            self.m_curTargetInfo.arm:changeOneSkinToArmature(boneName, boneImg, boneAni)
        else
            self.m_curTargetInfo.arm:ChangeOneSkin(boneName, boneImg) --todo
        end
    end
 
    if(self.m_curTargetInfo.playRightIndex~="" and self.m_curTargetInfo.playRightIndex ~= nil) then 
        self.m_curThingInfo.arm:playByIndex(self.m_curThingInfo.playIndex, LOOP_NO, self.m_SoundPath)
        self.m_curTargetInfo.arm:playByIndex(self.m_curTargetInfo.playRightIndex, LOOP_NO, self.m_SoundPath)
        self.m_curTargetInfo.arm:setLuaCallBack(
            function(eType, pTouchArm, sEvent)
                if eType == TouchArmLuaStatus_AnimEnd then
                    self:onProcAniEnd(self.m_curTargetInfo.arm)  ---同时进行
                end
            end
        )
    else
        --播放json动画表现
        -- self.Cfg.thingsList[1].arm:setVisible(false)
        self:playAnimation(self.stageNode, self.m_curThingInfo.jsonname, function()
            self:onProcAniEnd()
        end)
    end
end

function dragputWill:onProcAniEnd(npcTouchArmature)
    self.m_clearCount = self.m_clearCount + 1

    if(self.m_curTargetInfo.idleIndex ~= nil) then 
        self.m_curTargetInfo.arm:playByIndex(self.m_curTargetInfo.idleIndex, LOOP_YES, self.m_SoundPath)
    end 
    -------返回--------
    self.m_curThingInfo.arm:setLocalZOrder(self.m_curThingInfo.bgZorder)
    self.m_curThingInfo.arm:playByIndex(self.m_curThingInfo.endIndex, LOOP_YES, self.m_SoundPath)
    local endPos = self.m_curThingInfo.bgPos
    local function tFunction()
        print("checkend")  
        self:checkEnd()
    end
    local action = cc.Sequence:create(cc.MoveTo:create(0.1, endPos), cc.CallFunc:create(tFunction))
    self.m_curThingInfo.arm:stopAllActions()
    self.m_curThingInfo.arm:runAction(action)
end

---------------------------------------------------------------------------------------------------
function dragputWill:checkEnd()
    if self.m_clearCount >= self.Cfg.targetCount then
        -- self:stopTimer()
        --记录选择的物品
        if(self.Cfg.needWrite) then 
            local gift = {self.m_curThingInfo.name}
            -- self:tableToJson(gift,self.strCfgPath .. "config/gift.json")
            g_tConfigTable.gift_id=self.m_curThingInfo.name
            print("g_tConfigTable.gift_id:",g_tConfigTable.gift_id)
        end 
        self:exitScene()
    else
        self.m_canTouch = true
        self:createTipScheduler()
    end
end

function dragputWill:createTipScheduler()
    if self.tipScheduler then
        return
    end
    local schedulerfunc = function()
        -- self:say(self.speakArm, "newgs257012")  ---长时间不操作提示
        if(string.find(self.Cfg.tipJsonName, "json") ~= nil ) then 
            self:playAnimation(self.stageNode, self.Cfg.tipJsonName)
        end
        for i = 1, #self.Cfg.targetList do
            if(self.Cfg.targetList[i].dragSucess ~=true) then 
                --播对应的动画效果
                self.m_nextIndex=i
                self:createDragPrompt(cc.p(self.Cfg.thingsList[i].bgPos), cc.p(self.Cfg.targetList[i].x, 1024-self.Cfg.targetList[i].y), 0.8, self.topNode)
                return
            end 
        end
    end
    self.tipScheduler = self.scheduler:scheduleScriptFunc(schedulerfunc, 20.0, false)
end

function dragputWill:closeTipScheduler()
    if self.tipScheduler then
        self.scheduler:unscheduleScriptEntry(self.tipScheduler)
        self.tipScheduler = nil
    end
end


return dragputWill
