local BasePlayScene = requirePack("scripts.Common.BasePlayScene")
local Json = requirePack("scripts.Common.Dkjson")

local ChoosePlot =
    class(
    "ChoosePlot",
    function(...)
        return BasePlayScene.new(...)
    end
)

local function Log( ... )
	print("[NewScenePlay]--------------", ...)
end
--重写 --[[new]]
g_tConfigTable.CREATE_NEW(ChoosePlot)
---------------------------------------------------------------------------------------------------
local winSize = g_tConfigTable.winSize
local PlayAnimation = "play" --正常播放
local WaitClick = "waitclick" -- 等待点击
local LoopPlay = "loopPlay" --循环播放
local WaitMic = "waitMic" --点喊
---------------------------------------------------------------------------------------------------
function ChoosePlot:ctor(...)
    print("frank-----ctor")
    self:init()
    self:initData()
end

function ChoosePlot:initData()
    self.debug = true
    self.canTouch = false
    self.endstate = false
    self.step = 1
    self.isMain=true
    self.touchNum=0
    self.touchChooseNum=0 --小屋选择点击次数--
    -- self.speakArm = self.m_currbglayer:getNpcArmature("null")
end

function ChoosePlot:init()
    --[解析json配置文件]
    local cfgPath = self.strCfgPath .. "config/" .. "ChoosePlot_"..self.sourceID..".json" --需要解析的文件路径
    self.Cfg = Json.parseFile(cfgPath)

    --[[StoryBgLayer]]
    -- self.m_currV4Scene:changeBgLayout(self.sourceID, false)
    -- self.m_currbglayer = StoryBgLayer.curBgLayer
end
---------------------------------------------------------------------------------------------------
--[[onEnter]]
function ChoosePlot:onEnter()
    print("frank-----onEnter")
    BasePlayScene.onEnter(self)
    if self.strCfgPath .. "bgimg/sounds/" .. self.Cfg.backgroundMusci then
        SoundUtil:getInstance():playBackgroundMusic(self.strCfgPath .. "bgimg/sounds/" .. self.Cfg.backgroundMusci, true)
    end

    self:enterScene()
end

--[[onExit]]
function ChoosePlot:onExit()
    SoundUtil:getInstance():stopBackgroundMusic(false)
    BasePlayScene.onExit(self)
end
---------------------------------------------------------------------------------------------------
--[[进入]]
function ChoosePlot:enterScene()
    local func3 = function()
        self:initSceneInfo()
        self.canTouch = true
        for i=1, #self.Cfg.chooseList do	
            local info=self.Cfg.chooseList[i]
            self.Cfg.chooseList[i].arm:playByIndex(info.clickTipIndex, LOOP_YES, self.m_SoundPath) --等待点击
			self:createClickPromptMore(cc.p(self.Cfg.chooseList[i].arm:getPosition()), 1, 0.6, self.topNode,i)
        end 
         --增加选择等待点击前的统计
         self.touchChooseNum = self.touchChooseNum + 1
         self:upTjData(self.BagID,self.sourceID.."_touch"..self.touchChooseNum)
        -- self:createTipScheduler()
    end
    local func = function()
        self:playAnimation(self.stageNode, self.Cfg.startJsonName, func3)
       
    end
    self:InitBgConfig(self.stageNode, self.Cfg.bgconfigJson, func)
    ---------增加雪景---------------------
    if self.Cfg.addNpc ~= nil then
        self:setAddObj(self.Cfg.addNpcInfo)
    end 
    -- self:initSceneInfo()
    -- self:comeBack()
    -- 增加入场统计
    self:upTjData(self.BagID,self.sourceID)

end
--[[退出]]
function ChoosePlot:exitScene()
    self:closeTipScheduler()
    self:moduleSuccess()
    -- --增加用户完成游戏后的统计
    -- self:upTjData(self.Cfg.tjpreKey,self.sourceID.."_gameafter")
end


function ChoosePlot:initSceneInfo()
    for i=1, #self.Cfg.chooseList do
        self.Cfg.chooseList[i].arm=self.stageNode:getChildByName(self.Cfg.chooseList[i].npcName)
        self.Cfg.chooseList[i].fingerArm=nil
	end
end
--[[Touch]]
---------------------------------------------------------------------------------------------------
function ChoosePlot:onTouchBegan(touch, event)
    local touchPoint = self.stageNode:convertTouchToNodeSpace(touch)
    if not self.canTouch then
        return false
    end
    self:closeTipScheduler()
   
    local WaitClickInfo = nil --等待点击
    local FreeClick = nil --自由点击

  
    -- --[[获取当前自由点击列表]]
    if(self.isMain) then
        if self.Cfg.MainFreeClick then
            -- dump(self.Cfg.MainFreeClick)
            for k, v in pairs(self.Cfg.MainFreeClick) do
                FreeClick = v
            end
        end
    else
        if self.Cfg.FreeClick then
            -- dump(self.Cfg.FreeClick)
            for k, v in pairs(self.Cfg.FreeClick) do
                if v.step == self.step then
                    FreeClick = v
                    break
                end
            end
        end

        --[[获取等待点击npc info]]
        if self.Cfg.AnimationList then
            -- dump(self.Cfg.AnimationList)
            for k, v in pairs(self.Cfg.AnimationList) do
                if v.step == self.step and v.state == WaitClick then
                    WaitClickInfo = v
                    break
                end
            end
        end
    end 

    


    if(self.isMain) then
        for i=1, #self.Cfg.chooseList do  --在有效的点击区域内点击判断
            print("主场景list")
            local info = self.Cfg.chooseList[i]
            local x, y, width, height = 0, 0, 0, 0
            print("自由选择",info.npcName)
            x, y, width, height = self.stageNode:getChildByName(info.npcName):getBoundingBoxValue(x, y, width, height)
            local targetRect = cc.rect(x, y, width, height)
            if cc.rectContainsPoint(targetRect, touchPoint) then
                self:deleteAllFingerTip()
                self:stopFreeClick(FreeClick.clickList) --停止其他当前的播放
                info.isClick=true
                print("isClick",self.Cfg.chooseList[i].isClick)
                self.sceneChild=i
                --增加选择等待点击前的统计
                self:upTjData(self.BagID,self.sourceID.."_touch"..self.touchChooseNum.."after")


                self:AnimationOrWaitClick("main")  ------进入子场景剧情---------
                -- self:comeBack(self.sceneChild)
                return false
            end

        end 
    end


    --[[等待点击]]
    if WaitClickInfo then
        print("等待点击".. WaitClickInfo.nodeName)
        local x, y, width, height = 0, 0, 0, 0
        local targetRect = nil
        if WaitClickInfo.usePoint then
            x, y, width, height = self.fingerArm:getBoundingBoxValue(x, y, width, height)
            targetRect = cc.rect(x, y, width, height)
        else
            local x, y, width, height = 0, 0, 0, 0
            x, y, width, height = self.stageNode:getChildByName(WaitClickInfo.nodeName):getBoundingBoxValue(x, y, width, height)
            targetRect = cc.rect(x, y, width, height)
        end
        if cc.rectContainsPoint(targetRect, touchPoint) then
            print("wait----------click", WaitClickInfo.nodeName)
            self.canTouch = false
            self:closeTipScheduler()
            self:removeFingerTip()
            -- --增加等待点击后的统计
            self:upTjData(self.BagID,self.sourceID.."_touch"..self.touchNum.."after")
            if FreeClick then
                self:stopFreeClick(FreeClick.clickList)
            end
            self.step = self.step + 1
            if self.loopPlayTag then
                self.AnimationEngine:StopPlayStory(self.loopPlayTag)
            end
            self:AnimationOrWaitClick(self.sceneChild)
            return false
        end
    end

     --[[自由点击]]
     if FreeClick then
        for k, v in pairs(FreeClick.clickList) do
            local x, y, width, height = 0, 0, 0, 0
            print("自由点击",v.nodeName)
            x, y, width, height = self.stageNode:getChildByName(v.nodeName):getBoundingBoxValue(x, y, width, height)
            local targetRect = cc.rect(x, y, width, height)
            if cc.rectContainsPoint(targetRect, touchPoint) then
                print("free----------click", v.nodeName)
                --动画播放完回调
                local func = function()
                    v.tag = nil
                end
                self:stopFreeClick(FreeClick.clickList) --停止其他当前的播放
                --[获得随机播放的json]
                local t_JsonName = self:stringSplit(v.JsonName, "/") --npc 随机播放
                self:resetRandomSeed() --重设随机种子
                local num = math.random(#t_JsonName)
                if v.NotchangeZOrder then
                    v.tag = self:playAnimationNotchangeZOrder(self.stageNode, t_JsonName[num], func)
                else
                    v.tag = self:playAnimation(self.stageNode, t_JsonName[num], func)
                end
                return false
            end
        end
    end

    return false

    
end
function ChoosePlot:deleteAllFingerTip()
    for i=1, #self.Cfg.chooseList do	
        self:removeFingerTipByName(i)
    end 
end 
function ChoosePlot:onTouchMoved(touch, event)
    
end

function ChoosePlot:onTouchEnded(touch, event) 

end
----------返回主场景------------------------------
function ChoosePlot:comeBack()
    print("返回了主场景")
    self.isMain=true
    -------正确选项--------------------
    if(self.Cfg.chooseList[self.sceneChild].istrue) then 
        self:exitScene()
        return false
    end
    self.sourceID=self.Cfg.scene
    self.step=1
    local func3 = function()
        self:initSceneInfo()
        self.canTouch = true
        -- dump(self.Cfg.chooseList)
        -- self:createTipScheduler()
        for i=1, #self.Cfg.chooseList do	
            local info=self.Cfg.chooseList[i]
            print(i,info.isClick)
            if(not info.isClick) then 
                self.Cfg.chooseList[i].arm:playByIndex(info.clickTipIndex, LOOP_YES, self.m_SoundPath) --等待点击
			    self:createClickPromptMore(cc.p(self.Cfg.chooseList[i].arm:getPosition()), 1, 0.6, self.topNode,i)
            else
                self.Cfg.chooseList[i].arm:playByIndex(info.idleIndex, LOOP_YES, self.m_SoundPath) --闲置
            end 
            
        end 
        --增加选择等待点击前的统计
        self.touchChooseNum = self.touchChooseNum + 1
        self:upTjData(self.BagID,self.sourceID.."_touch"..self.touchChooseNum)
    end
    local func = function()
        -- self:playAnimation(self.stageNode, self.Cfg.chooseJsonName, func3)
      
        self:playAnimationNotchangeZOrder(self.stageNode, self.Cfg.chooseJsonName, func3)
    end
    self.AnimationEngine:RemoveEngineCreatedObjOnNode(self.stageNode) -- 清空舞台
    self:InitBgConfig(self.stageNode, self.Cfg.bgconfigJson, func)
end 
-- *[[根据state判断是播动画还是进去等待点击]] 进入子场景
function ChoosePlot:AnimationOrWaitClick(fromtype)
    print("进入了子场景",self.sceneChild,self.step)
    self.isMain=false
    self.canTouch = false
    self.sourceID=self.Cfg.chooseList[self.sceneChild].scene
    self.Cfg.AnimationList=clone(self.Cfg.chooseList[self.sceneChild].AnimationList)
    self.Cfg.FreeClick=clone(self.Cfg.chooseList[self.sceneChild].FreeClick)

    -- dump(self.Cfg.chooseList[self.sceneChild].AnimationList)
    -- -- dump( self.Cfg.AnimationList)
    -- dump(self.Cfg.chooseList[self.sceneChild].FreeClick)
    -- -- dump( self.Cfg.FreeClick)
    if(fromtype=="main") then 
        -- 增加进入子场景统计
        self:upTjData(self.BagID,self.sourceID)
    end 

    if self.step > #self.Cfg.AnimationList then
        -- self:exitScene()
        ------返回主场景----------
        self:comeBack()
        return
    end
    for k, v in pairs(self.Cfg.AnimationList) do
        local playfunc = function()
            v.tag = nil
            self.step = self.step + 1
            if self.step > #self.Cfg.AnimationList then
                 self:comeBack()
            else
                self:AnimationOrWaitClick(self.sceneChild)
            end
        end
        if v.step == self.step then
            if v.state == PlayAnimation then
                local func = function()
                    --------------------调试--------------------------------------------------
                    if v.NotchangeZOrder then
                        v.tag = self:playAnimationNotchangeZOrder(self.stageNode, v.JsonName, playfunc)
                    else
                        print("xxxxxx", v.JsonName)
                        v.tag = self:playAnimation(self.stageNode, v.JsonName, playfunc)
                    end
                end
                if v.needclear then --TODO 是否需要清空之前舞台
                    self.AnimationEngine:RemoveEngineCreatedObjOnNode(self.stageNode) -- 清空舞台
                    self:InitBgConfig(self.stageNode, v.bgconfig, func)
                else
                    func()
                end
            elseif v.state == WaitClick then
                 --增加等待点击前的统计
                self.touchNum = self.touchNum + 1
                self:upTjData(self.BagID,self.sourceID.."_touch"..self.touchNum)

                if v.posX then
                    self:createClickPrompt(cc.p(v.posX, v.posY), 1, 0.6, self.topNode) --TODO 创建手指提示
                else
                    local arm = self.stageNode:getChildByName(v.nodeName)
                    self:createClickPrompt(cc.p(arm:getPosition()), 1, 0.6, self.topNode) --TODO 创建手指提示
                end
                self.canTouch = true
            elseif v.state == WaitMic then
                ------出现麦克风之前统计--------------
                self:upTjData(self.BagID,self.sourceID.."_sound")

                self:addMic()
            elseif v.state == LoopPlay then
                self:playLoop(v)
                playfunc()
            end
            break
        end
    end
end
--[[循环播放]]
function ChoosePlot:playLoop(playInfo)
    local func = function()
        self.loopPlayTag = nil
        self:playLoop(playInfo)
    end
    if playInfo.NotchangeZOrder then
        self.loopPlayTag = self:playAnimationNotchangeZOrder(self.stageNode, playInfo.JsonName, func)
    else
        self.loopPlayTag = self:playAnimation(self.stageNode, playInfo.JsonName, func)
    end
end

--[[麦克风收音]]
function ChoosePlot:addMic()
    SoundUtil:getInstance():soundListenStartLua(
        Utils:GetInstance().sourceType,
        Utils:GetInstance().sourceId,
        false,
        function(iEndType)
            self:soundListenCallBack(iEndType)
        end
    )
    -- 开始录音
    -- Utils:GetInstance():addListenTips(CCP(0, 0), self.topNode)

    SoundUtil:getInstance():pauseBackgroundMusic() --暂停背景音乐播放
    self.tipsArm = TouchArmature:create("voicetips", TOUCHARMATURE_NORMAL)
    local cameraPos = self:GetCameraPosByNode(self.stageNode)
    self.tipsArm:playByIndexOnlyArmature(0)
    self.tipsArm:setPosition(cameraPos.x + winSize.width / 2 - 55, cameraPos.y - 70)
    self.tipsArm:setScale(0.7)
    self.topNode:addChild(self.tipsArm, 1000)
end

--[[麦克风收音回调]]
function ChoosePlot:soundListenCallBack(iEndType)
    -- 2:正常声音，1：声音持续时间较长，0：未监听到声音 3、刚有声音发出

    local iMicType = Utils:GetInstance():doGetMicType()
    print("addMic------", "iMicType", iMicType, "iEndType", iEndType)
    if iEndType >= 0 then
        self.step = self.step + 1
        if self.step > #self.Cfg.AnimationList then
            self:exitScene()
        else
            self:AnimationOrWaitClick(self.sceneChild)
        end
    end

    SoundUtil:getInstance():soundListenStop()
    if self.tipsArm then
        self.tipsArm:removeFromParent()
    end
    -- Utils:GetInstance():removeListenTips(self.topNode)
    SoundUtil:getInstance():resumeBackgroundMusic() --恢复暂停的背景音乐

    ------出麦克风消失后统计--------------
    self:upTjData(self.BagID,self.sourceID.."_soundafter")
end


--*[[创建多个点击手指提示]]
function ChoosePlot:createClickPromptMore(Point, Index, Scale, layer,fingerArmName_i)

    local fingerArm=self.Cfg.chooseList[fingerArmName_i].fingerArm
    print("创建手指提示：",fingerArm)
    if fingerArm ~= nil then
        return
    end
    fingerArm = TouchArmature:create("point_all", TOUCHARMATURE_NORMAL, "")
    fingerArm:setPosition(cc.p(Point))
    fingerArm:setScale(CFG_SCALE(Scale))
    fingerArm:setLocalZOrder(1001)
    layer:addChild(fingerArm)
	self.Cfg.chooseList[fingerArmName_i].fingerArm=fingerArm
    fingerArm:playByIndex(Index, LOOP_YES, self.m_SoundPath)
end

--*[[移除指定手指提示]]
function ChoosePlot:removeFingerTipByName(fingerArmName_i)
	print("移除手指提示："..fingerArmName_i)
	local fingerArm=self.Cfg.chooseList[fingerArmName_i].fingerArm
	print(fingerArm)
    if fingerArm ~= nil then
        fingerArm:stopAllActions()
        fingerArm:removeFromParent()
        fingerArm = nil
    end
end


function ChoosePlot:createTipScheduler()
    if self.tipScheduler then
        return
    end
    local schedulerfunc = function()
        -- self:say(self.speakArm, "newgs257111")  ---长时间不操作提示
    end
    self.tipScheduler = self.scheduler:scheduleScriptFunc(schedulerfunc, 30.0, false)
end

function ChoosePlot:closeTipScheduler()
    if self.tipScheduler then
        self.scheduler:unscheduleScriptEntry(self.tipScheduler)
        self.tipScheduler = nil
    end
end
--[[gameFunc]]
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
return ChoosePlot
