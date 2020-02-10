local ContentItem = requirePack("appscripts.ContentItem")
local OpLayer = class("OpLayer", function()
    local layer  = cc.Layer:create()
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
OpLayer.new = function(...)
    local instance
    if OpLayer.__create then
        instance = OpLayer.__create(...)
    else
        instance = { }
    end

    for k, v in pairs(OpLayer) do instance[k] = v end
    instance.class = OpLayer
    instance:ctor(...);
    return instance
end

function OpLayer:onEnter() 
    
end

function OpLayer:onExit()
    

end

function OpLayer:ctor()
    self:init()
end

--初始化
function OpLayer:init()
    g_tConfigTable.AnimationEngine:GetInstance()
    AudioEngine.playMusic( g_tConfigTable.sTaskpath.."sounds/191128ge.mp3", true)

    self.scaleMultiple = ArmatureDataDeal:sharedDataDeal():getUIItemScale_1024_1920() * 0.8
    if ArmatureDataDeal:sharedDataDeal():getIsHdScreen() == false then
		self.scaleMultiple = self.scaleMultiple * 2
    end
        
    local winSize = cc.Director:getInstance():getWinSize()
 --    local imgPath = g_tConfigTable.sTaskpath.."image/gui_btn_tiaog.png" --
	-- local clickBtn = ccui.Button:create(imgPath,imgPath);
	-- clickBtn:setAnchorPoint(cc.p(0.5,0.5));
 --    clickBtn:setPosition(cc.p(386+winSize.width*0.5 - 50,512+winSize.height*0.5 - 42));
	-- clickBtn:setPressedActionEnabled(true)  
 --    clickBtn:setSwallowTouches(false);   
 --    clickBtn:setScale(self.scaleMultiple * 0.8)
	-- self:addChild(clickBtn,100000);
 --    clickBtn:addClickEventListener(function()
 --        Utils:GetInstance():baiduTongji("xialingying","ws_op_skip")--tong ji
 --        clickBtn:removeFromParent()
 --        self:showZhuanChang()
 --    end)

    Utils:GetInstance():baiduTongji("xialingying","ws_op_start")--tong ji

    self.stageNode = cc.Node:create();
    self.stageNode:setPosition(cc.p(384,512))
    self.stageNode:setContentSize(self:getContentSize());
    self:addChild(self.stageNode)
	
    local function callBack2()
        local finger = TouchArmature:create("point_all", TOUCHARMATURE_NORMAL);	
        finger:setScale(self.scaleMultiple*1.5)
        finger:setPosition(cc.p(384,500));
        finger:playByIndex(1,LOOP_YES);
        self:addChild(finger,100000);

        local imgPath = THEME_IMG("transparent.png") --
        local enterBtn = ccui.Button:create(imgPath,imgPath);
        enterBtn:setScale(25)
        enterBtn:setAnchorPoint(cc.p(0.5,0.5));
        enterBtn:setPosition(cc.p(384,500));
        enterBtn:setPressedActionEnabled(true)  
        enterBtn:setSwallowTouches(false);   
        self:addChild(enterBtn,100000);
        enterBtn:addClickEventListener(function()
            Utils:GetInstance():baiduTongji("xialingying","zq_op_enter")--tong ji
            finger:removeFromParent()
            enterBtn:removeFromParent()
            self:showZhuanChang()
        end)

        local arr = {}
        table.insert(arr,cc.DelayTime:create(10))
        table.insert(arr,cc.CallFunc:create(function()
            finger:removeFromParent()
            enterBtn:removeFromParent()
            self:showZhuanChang()
        end))
        self:runAction(cc.Sequence:create(arr))

        --self:showZhuanChang()
    end

    local function callBack1()
        local finger = TouchArmature:create("point_all", TOUCHARMATURE_NORMAL);	
        finger:setScale(self.scaleMultiple*1.5)
        finger:setPosition(cc.p(390,630));
        finger:playByIndex(1,LOOP_YES);
        self:addChild(finger,100000);

        local imgPath = THEME_IMG("transparent.png") --
        local enterBtn = ccui.Button:create(imgPath,imgPath);
        enterBtn:setScale(25)
        enterBtn:setAnchorPoint(cc.p(0.5,0.5));
        enterBtn:setPosition(cc.p(390,630));
        enterBtn:setPressedActionEnabled(true)  
        enterBtn:setSwallowTouches(false);   
        self:addChild(enterBtn,100000);
        enterBtn:addClickEventListener(function()
            finger:removeFromParent()
            enterBtn:removeFromParent()
            self:stopAllActions();
            self:playActionAmin("ganenhd002",callBack2)
        end)

        local arr = {}
        table.insert(arr,cc.DelayTime:create(10))
        table.insert(arr,cc.CallFunc:create(function()
            finger:removeFromParent()
            enterBtn:removeFromParent()
            --191225op2
            self:playActionAmin("ganenhd002",callBack2)
        end))
        self:runAction(cc.Sequence:create(arr))
    end

    local function callBack0()
        --191225op1
        self:playActionAmin("ganenhd001",callBack1)
    end
    
    callBack0()
end

function OpLayer:playActionAmin(jsonFile,callBack)
    local function tmpCallBack(eventName)
        if eventName == "Complie" then 
            if(callBack) then
                callBack()
            end
        end
    end
   
    self.tag_ = g_tConfigTable.AnimationEngine:GetInstance():PlayPackageAction(
        g_tConfigTable.sTaskpath.."sayHelloGuide/story/"..jsonFile..".json",
        self.stageNode ,
        g_tConfigTable.sTaskpath.."image/",
        g_tConfigTable.sTaskpath.."audio/",
        tmpCallBack
    )
    
end

--显示转场
function OpLayer:showZhuanChang()
    AudioEngine.stopMusic(true)--停止音乐
    local CustomEventType = requirePack("baseScripts.dataScripts.CustomEventType", false)
    CustomEventDispatcher:getInstance():msgBroadcastLua(CustomEventType.CE_COLLECT_SHOW_NEW_GOOD, 16, true)

    g_tConfigTable.AnimationEngine:GetInstance():Dispose();
    self.parent:addMainLayer(true)
    local arr = {}
    table.insert(arr,cc.DelayTime:create(0.5))
    table.insert(arr,cc.CallFunc:create(function()
        self:removeFromParent()
    end))
    self:runAction(cc.Sequence:create(arr))

    -- local  function callback()
    --     local CustomEventType = requirePack("baseScripts.dataScripts.CustomEventType", false)
    --     CustomEventDispatcher:getInstance():msgBroadcastLua(CustomEventType.CE_COLLECT_SHOW_NEW_GOOD, 16, true)
    
    --     g_tConfigTable.AnimationEngine:GetInstance():Dispose();
    --     self.parent:addMainLayer(true)
    --     self:removeFromParent()
    -- end 
    -- self:showOPOver(callback);
end  

--显示转场
function OpLayer:showOPOver(callBack)
    local changeSceneArm = TouchArmature:create(("home_ZC"), TOUCHARMATURE_NORMAL)
    changeSceneArm:setAnchorPoint( cc.p(0.5,0.5)) --动画的的锚点无意义
    changeSceneArm:setPosition(cc.p( cc.Director:getInstance():getWinSize().width/2, cc.Director:getInstance():getWinSize().height/2 ))--位置
    cc.Director:getInstance():getRunningScene():addChild( changeSceneArm , Max_INT() )  --层级最高 
    changeSceneArm:playByIndex(0, LOOP_NO)
    changeSceneArm:setLuaCallBack(function ( eType, pTouchArm, sEvent )
        if eType == TouchArmLuaStatus_AnimEnd then  
            changeSceneArm:removeFromParent()
            changeSceneArm = nil

            if(callBack) then
                callBack()
            end
        end     
    end)
end

return OpLayer