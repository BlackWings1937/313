local isTest = false;
local ShowLayer = class("ShowLayer", function()
    local layer  = cc.Layer:create()
    layer:setContentSize(cc.size(768,1024))
    local winSize = cc.Director:getInstance():getWinSize()
    layer:setPosition(cc.p((winSize.width-768)*0.5,(winSize.height-1024)*0.5))

      if nil ~= layer then
        local function onNodeEvent(event)
            if "enter" == event then
                layer:onEnter()
            elseif "exit" == event then
                layer:onExit()
            end
        end
        layer:registerScriptHandler(onNodeEvent)
    end
    return layer
end)


-- 重写New方法
ShowLayer.new = function(...)
    local instance
    if ShowLayer.__create then
        instance = ShowLayer.__create(...)
    else
        instance = { }
    end

    for k, v in pairs(ShowLayer) do instance[k] = v end
    instance.class = ShowLayer
    instance:ctor(...);
    return instance
end


function ShowLayer:onEnter() 
    
end

function ShowLayer:onExit()
    g_tConfigTable.AnimationEngine:GetInstance():Dispose();
end

function ShowLayer:ctor(...)
	local tSdPath = ...
	self.sSdPath = tSdPath;
    self:init()
	self:gotoLayer()
end

function ShowLayer:init()

    self.StoryEngine = g_tConfigTable.AnimationEngine:GetInstance()




    self.storyNode = cc.Node:create();
    self.storyNode:setPosition(cc.p(384,512))
    self.storyNode:setContentSize(self:getContentSize());
    self:addChild(self.storyNode)


    self:setColor(cc.c3b(255,255,255))
    self.winSize = cc.Director:getInstance():getWinSize()
    
    self.ScaleMultiple = ArmatureDataDeal:sharedDataDeal():getUIItemScale_1024_1920() *0.8 

	local btn_close = ccui.Button:create()
    btn_close:setTouchEnabled(true)
    btn_close:loadTextures(THEME_IMG("third/ic_home_n.png"), THEME_IMG("third/ic_home_p.png"), THEME_IMG("third/ic_home_p.png"))
    btn_close:setAnchorPoint(cc.p(0,0.5))
	btn_close:setScale(self.ScaleMultiple) 
 
    local x =15
    local y = self.winSize.height - btn_close:getContentSize().height/2 * btn_close:getScale()-20
    -- local pos = self:getParent():convertToWorldSpace(cc.p(-200, y))
    -- local last_pos = self:convertToNodeSpace(pos)
    btn_close:setPosition(cc.p((self.winSize.width-768)*0.5-200,-(self.winSize.height-1024)*0.5+y))   
    
    btn_close:setPressedActionEnabled(true)     
    btn_close:setZoomScale(-0.12)
    btn_close:setTag(2017)
    self:addChild(btn_close,200)

    


    -- --屏幕点击特效
    -- local wx = (self.winSize.width-768)*0.5
    -- local wy = (self.winSize.height-1024)*0.5
    -- local colorLayer = cc.Layer:create()
    -- colorLayer:setPosition(cc.p(0,0))
    -- self:addChild(colorLayer,9999999)
    -- local function touchLayerCallFunc(eventType, x, y)
    --     if eventType == "began" then
    --         local tx = TouchArmature:create("xy_efface_touch", TOUCHARMATURE_NORMAL)
    --         tx:setPosition(cc.p(x-wx,y-wy))
    --         tx:setRectAndBeginPlay()
    --         colorLayer:addChild(tx)
    --         tx:playByIndex(0, LOOP_NO)
    --         tx:setLuaCallBack( function (eType)
    --             if eType == TouchArmLuaStatus_AnimEnd then
    --                 tx:removeFromParent()
    --                 tx = nil
    --             end
    --         end)
    --         return false
    --     end
    -- end
    -- colorLayer:registerScriptTouchHandler(touchLayerCallFunc, false, 0, true)
    -- colorLayer:setTouchEnabled(true)


    btn_close:addClickEventListener(function(sender)
        local mainLayer = self:getChildByTag(1)
        if(mainLayer ~= nil) then
            mainLayer:clickCloseLayer(function() 
                AudioEngine.stopMusic(true);--停止音乐
                XiaLingYingData:getInstance():setTargetBagId(0,"");
                xblStaticData:clearKeepFrom();
                xblStaticData:gotoSource(MOUDULE_XIALINGYING,MOUDULE_MAIN, "",STORY4V_TYPE_UNKNOW)
            end)
        else
            AudioEngine.stopMusic(true);--停止音乐
            XiaLingYingData:getInstance():setTargetBagId(0,"");
            xblStaticData:clearKeepFrom();
            xblStaticData:gotoSource(MOUDULE_XIALINGYING,MOUDULE_MAIN, "",STORY4V_TYPE_UNKNOW)
        end
        SimpleAudioEngine:getInstance():playEffect(UISOUND_A_BTN)
    end)    
    
    local function delayShowCloseBtn()
        --CC_GameLog(-(self.winSize.width-768)*0.5+15,"eiieiosososos")
        btn_close:setPositionX(-(self.winSize.width-768)*0.5+15)
    end
    performWithDelay(btn_close,delayShowCloseBtn, 1.0)

    if(isTest) then
        local btn_close1 = ccui.Button:create()
        btn_close1:setTouchEnabled(true)
        btn_close1:loadTextures(THEME_IMG("third/ic_back_n.png"), THEME_IMG("third/ic_back_p.png"), THEME_IMG("third/ic_back_p.png"))
        btn_close1:setAnchorPoint(cc.p(0,0.5))
        btn_close1:setScale(self.ScaleMultiple) 
    
        local x = 100
        local y = self.winSize.height - btn_close1:getContentSize().height/2 * btn_close1:getScale()-20
        btn_close1:setPosition(cc.p(-(self.winSize.width-768)*0.5+x, -(self.winSize.height-1024)*0.5+y))   
        btn_close1:setPressedActionEnabled(true)     
        btn_close1:setZoomScale(-0.12)
        btn_close1:setTag(2017)
        self:addChild(btn_close1,10)
        btn_close1:addClickEventListener(function(sender)
            self:addMainLayer(false)
        end)

        local btn_close1 = ccui.Button:create()
        btn_close1:setTouchEnabled(true)
        btn_close1:loadTextures(THEME_IMG("third/ic_back_n.png"), THEME_IMG("third/ic_back_p.png"), THEME_IMG("third/ic_back_p.png"))
        btn_close1:setAnchorPoint(cc.p(0,0.5))
        btn_close1:setScale(self.ScaleMultiple) 
    
        local x =300
        local y = self.winSize.height - btn_close1:getContentSize().height/2 * btn_close1:getScale()-20
        btn_close1:setPosition(cc.p(-(self.winSize.width-768)*0.5 + x, -(self.winSize.height-1024)*0.5 + y))   
        btn_close1:setPressedActionEnabled(true)     
        btn_close1:setZoomScale(-0.12)
        btn_close1:setTag(2017)
        self:addChild(btn_close1,10)
        btn_close1:addClickEventListener(function(sender)
            CC_GameLog("akkdkalliweieieikdkdkdkkdalkakak")
           -- self:removeChildByTag(1)
            if self.mainLayer then
                self.mainLayer.m_cxtLayer:removeFromParent()
                self.mainLayer:removeFromParent()
                self.mainLayer = nil
            end
            local function funx(preName)
                for key, _ in pairs(package.preload) do
                    if string.find(tostring(key), preName) == 1 then
                        package.preload[key] = nil
                    end
                end
                for key, _ in pairs(package.loaded) do
                    if string.find(tostring(key), preName) == 1 then
                        package.loaded[key] = nil
                    end
                end
            end
            funx("appscripts.MainLayer")
            funx("appscripts.ContentItem")
            funx("appscripts.ThemeItem")
            funx("appscripts.CopyItem")
            XiaLingYingData:getInstance():setTargetBagId(0,"");
        end)
    end
end

--进入不同的
function ShowLayer:gotoLayer()
    local curIdStr = UInfoUtil:getInstance():getCurUidStr()
    local strKey = curIdStr.."Tchristmas201956"
    local gUserData = cc.UserDefault:getInstance() 
    local isFirst =  gUserData:getStringForKey(strKey,"")
    if isFirst == "" then
        self:addOpLayer()
        local sResult = gUserData:setStringForKey( strKey, "1" )
        gUserData:flush()
    else
         self:addMainLayer(false)
    end
end


--播放剧情文件
function ShowLayer:PlayStoryAction(story_id,handle)

    CC_GameLog(story_id,"aiiellskdkkfaklkkslskkfjfjfjjf")
    CC_GameLog(debug.traceback())
    local storyPath      =     g_tConfigTable.sTaskpath.."sayHelloGuide/"..story_id..".json"--GET_REAL_PATH_ONLY("TestStory/audio/", PathGetRet_ONLY_SD)
    local animRes        =     g_tConfigTable.sTaskpath.."image/" --GET_REAL_PATH_ONLY("TestStory/anim/", PathGetRet_ONLY_SD)
    local audioRes       =     g_tConfigTable.sTaskpath.."audio/" --GET_REAL_PATH_ONLY("TestStory/story/info.json",PathGetRet_ONLY_SD)

    if not handle then
        handle = function(func_str,info)
            if func_str == "Complie" then

            elseif func_str == "Interupt" then

            end
            return nil
        end
    end
    local tag = nil
    if string.find(story_id,"bgconfig") then
        tag = self.StoryEngine:PlayPackageBgConfig(storyPath,self.storyNode,animRes,audioRes,handle)
    else
        tag = self.StoryEngine:PlayScriptIntelligent(storyPath,self.storyNode,animRes,audioRes,handle,2,false,true)
    end
    return tag
end


function ShowLayer:isAnyStoryPlaying()
    local count = #self.StoryEngine.listOfScriptActions_;
    local name = self.storyNode:getName();--
    for i = count, 1 , -1 do 
        if name == self.StoryEngine.listOfScriptActions_[i]:GetTheaterName() then 
            return true
        end
    end
    return false
end

--op的业务逻辑
function ShowLayer:addOpLayer()

    self.scaleMultiple = ArmatureDataDeal:sharedDataDeal():getUIItemScale_1024_1920() * 0.8
    if ArmatureDataDeal:sharedDataDeal():getIsHdScreen() == false then
        self.scaleMultiple = self.scaleMultiple * 2
    end
        
    local winSize = cc.Director:getInstance():getWinSize()

    Utils:GetInstance():baiduTongji("xialingying","xmas19_first_formal")--tong ji

    local function callBack3()
        local callBack = function(func_str,info)
            if func_str == "Complie" or   func_str == "Interupt" or func_str == "InternalINterupt" then
                CC_GameLog("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeiii")
                self:showZhuanChang()
            end
            return nil
        end
        Utils:GetInstance():baiduTongji("xialingying","xmas19_click_Lihe")
        self:PlayStoryAction("191225op2",callBack)
    end


    local function callBack2()
        local finger = TouchArmature:create("point_all", TOUCHARMATURE_NORMAL); 
        finger:setScale(self.scaleMultiple*1.5)
        finger:setPosition(cc.p(384,1024-750));
        finger:playByIndex(1,LOOP_YES);
        self:addChild(finger,100000);

        local imgPath = THEME_IMG("transparent.png") --
        local enterBtn = ccui.Button:create(imgPath,imgPath);
        enterBtn:setScale(25)
        enterBtn:setAnchorPoint(cc.p(0.5,0.5));
        enterBtn:setPosition(cc.p(384,1024-750));
        enterBtn:setPressedActionEnabled(true)  
        enterBtn:setSwallowTouches(false);   
        self:addChild(enterBtn,100000);
        enterBtn:addClickEventListener(function()
            finger:removeFromParent()
            enterBtn:removeFromParent()
            callBack3()
        end)
        local arr = {}
        table.insert(arr,cc.DelayTime:create(10))
        table.insert(arr,cc.CallFunc:create(function()
            finger:removeFromParent()
            enterBtn:removeFromParent()
            callBack3()
        end))
        finger:runAction(cc.Sequence:create(arr))

    end 

    local function callBack1()
        -- local finger = TouchArmature:create("point_all", TOUCHARMATURE_NORMAL); 
        -- finger:setScale(self.scaleMultiple*1.5)
        -- finger:setPosition(cc.p(390,1024-750));
        -- finger:playByIndex(1,LOOP_YES);
        -- self:addChild(finger,100000);

        local imgPath = THEME_IMG("transparent.png") --
        local enterBtn = ccui.Button:create(imgPath,imgPath);
        enterBtn:setScale(25)
        enterBtn:setAnchorPoint(cc.p(0.5,0.5));
        enterBtn:setPosition(cc.p(246,1024-785));
        enterBtn:setPressedActionEnabled(true)  
        enterBtn:setSwallowTouches(false);   
        self:addChild(enterBtn,100000);
        enterBtn:addClickEventListener(function()
            Utils:GetInstance():baiduTongji("xialingying","xmas19_click_santa")
        end)
        self.shendanbtn = enterBtn
        local callBack = function(func_str,info)
            if func_str == "Complie" or   func_str == "Interupt" or func_str == "InternalINterupt" then
                callBack2()
            end
            return nil
        end

        self:PlayStoryAction("191225op1",callBack)

    end

    local function callBack0()
        --191225op1
        self:PlayStoryAction("bgconfig_op",callBack1)
    end
    callBack0()
end


function ShowLayer:showZhuanChang()
    AudioEngine.stopMusic(true)--停止音乐
    local CustomEventType = requirePack("baseScripts.dataScripts.CustomEventType", false)
    CustomEventDispatcher:getInstance():msgBroadcastLua(CustomEventType.CE_COLLECT_SHOW_NEW_GOOD, 16, true)
    self:addMainLayer(true)
end



--跑马灯亮
function ShowLayer:PaoMaEffect( ... )
    local pre_npc = "npc_caideng"
    local pre_num_npc = "npc_shuzi"
    local curIndex = 1
    local npcName = pre_npc .. curIndex

    local npc = self:getNpcByName(npcName)
    if npc then
        npc:playByIndex(2,LOOP_NO)
        npc:setLuaCallBack(function(eType, pTouchArm, sEvent)
            if eType == TouchArmLuaStatus_AnimEnd then
                npc:playByIndex(0,LOOP_NO);
            end
        end)
    end
    self.paomaState = true
    local action = cc.Repeat:create(
            cc.Sequence:create(
                cc.DelayTime:create(0.5),
                cc.CallFunc:create(function()
                        curIndex = curIndex + 1
                        local index = curIndex%5
                        index = index == 0 and 5 or index
                        local npcName = pre_npc .. index
                        local npc = self:getNpcByName(npcName)
                        if npc then
                            npc:playByIndex(2,LOOP_NO)
                            npc:setLuaCallBack(function(eType, pTouchArm, sEvent)
                                if eType == TouchArmLuaStatus_AnimEnd then
                                    if curIndex >= 5 then
                                        self.paomaState = false
                                    end
                                    npc:playByIndex(0,LOOP_NO);
                                end
                            end)
                        end
                    end)
                ,nil),
                5
            );
    self:runAction(action)
end


--当前第几天任务特效
function ShowLayer:showCurDayEffect(step)

end

--获得剧情Npc
function ShowLayer:getNpcByName(npc_name)
    if npc_name == "XBL" then
        return self.storyNode:getChildByName("XBL")
    end
    local npc = self.storyNode:getChildByName("AESOP*"..npc_name)
   -- CC_GameLog_kaogu(npc,"AESOP*"..npc_name,"aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaiieiieiewoowow")
    return npc
end


--主界面业务逻辑
function ShowLayer:addMainLayer(isOp)
    if self.shendanbtn then
        self.shendanbtn:removeFromParent()
        self.shendanbtn = nil
    end
    CC_GameLog("eiwiowowoieieiei111")
    local function callBack()
        CC_GameLog("eiiwlsldlkdkfkfkfjfj")
        self:registerCaidengTouchEvent()
        local npc = self:getNpcByName("npc_mianban")
        if npc then
            local npc_juqing_diban = self:getNpcByName("npc_5quan")
            if npc_juqing_diban then
                npc_juqing_diban:setVisible(false)
            end
            local winSize = cc.Director:getInstance():getWinSize()
            local MainLayer = requirePack("appscripts.MainLayer");
            local mainLayer = MainLayer.new();
            mainLayer.parent = self
            mainLayer:setContentSize(cc.size(768,1024))
            mainLayer:createUI(self.sSdPath,isOp);
            mainLayer:setTag(1)   
            -- self.colorLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 255));
            -- self.colorLayer:setContentSize(cc.size(200, 200));
            -- self.colorLayer:setPosition(cc.p(0, 0));
            -- mainLayer:addChild(self.colorLayer)
            mainLayer:setPosition(cc.p(0,0))
            self:addChild(mainLayer);
            local posx,posy = npc:getPosition()
            self.mainLayer = mainLayer

            local arr = {}
            table.insert(arr,cc.DelayTime:create(12))
            table.insert(arr,cc.CallFunc:create(function() 
                self:PaoMaEffect()
            end))
            self:runAction(cc.RepeatForever:create(cc.Sequence:create(arr)))
           -- mainLayer:setPosition(cc.p(-posx,-posy))
        end
    end

    if not isOp then
        self:PlayStoryAction("bgconfig_xz",callBack)
    else
        CC_GameLog("eiwiowowoieieiei")
        callBack()
    end

end

--注册彩灯点击事件
function ShowLayer:registerCaidengTouchEvent( ... )
    local pre_npc = "npc_caideng"
    local pre_num_npc = "npc_shuzi"
    for i=1,5 do
        local npcName = pre_npc .. i
        local npc = self:getNpcByName(npcName)
        if npc then
            local function callBack()
                if self.paomaState then
                    return
                end
                Utils:GetInstance():baiduTongji("xialingying","xmas19_click_light")
                npc:playByIndex(1,LOOP_NO)
                npc:setLuaCallBack(function(eType, pTouchArm, sEvent)
                    if eType == TouchArmLuaStatus_AnimEnd then
                        npc:playByIndex(0,LOOP_NO);
                    end
                end)

            end
            self:RegisterArmatureTouchEvent(npc,callBack)
        end
        local npcName1 = pre_num_npc .. i
        local npc2 = self:getNpcByName(npcName1)
        if npc2 then
            npc2:setVisible(false)
            local function callBack()
            end
            self:RegisterArmatureTouchEvent(npc2,callBack)
        end
    end
end



--锁住屏幕
function ShowLayer:LockScreen()
    self.lock_screen = true
end

--npc的注册点击事件
function ShowLayer:RegisterArmatureTouchEvent(armature,callBack,isSwallow)
    local _swallow = isSwallow and isSwallow or false
    armature.one_click = false --防止重复点击问题
    armature:setTouchEnable(true)
    armature:setSwallowTouches(_swallow)   
    armature:setRectAndContent(0)
    armature:removeLuaCallBack()
    local pre_scale = armature:getScale()
    local min_scale = pre_scale * 0.9
    armature:setLuaTouchCallBack(function(nType, pTouchArm, pTouch)
        if nType == TouchArmLuaStatus_TouchBegan then
            if not self.lock_screen then
                armature:runAction(cc.ScaleTo:create(0.05, min_scale))
            end
        elseif (nType == TouchArmLuaStatus_TouchEnded) then
            if not self.lock_screen then
                armature:runAction(cc.ScaleTo:create(0.05, pre_scale))
                local x,y,width,height = 0,0,0,0
                x,y,width,height       = armature:getBoundingBoxValue(x,y,width,height)
                local BoundingBox      = cc.rect(x,y,width,height)
                local cPos = armature:getParent():convertTouchToNodeSpace(pTouch)
                CC_GameLog(x,y,width,height,"eiiwlsldlkdk",cPos.x,cPos.y)
                if cc.rectContainsPoint(BoundingBox, cPos) then
                    CC_GameLog("eiiwooeifksslksalsklskfjf")
                    playNormalBtnSound()
                    if callBack then
                        callBack()
                    end
                end
            end
        end
    end)
end


return ShowLayer