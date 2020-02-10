local cjson = require("cjson")
local ContentItem = requirePack("appscripts.ContentItem")
local CopyItem = requirePack("appscripts.CopyItem")
local JsonData = requirePack("baseScripts.homeUI.JsonData", false);  -- 用来读取数据
local CustomEventType = requirePack("baseScripts.dataScripts.CustomEventType", false)

requirePack("scripts.FrameWork.Global.GlobalFunctions");
g_tConfigTable.RootFolderPath = "scripts.";
requirePack("scripts.FrameWork.AnimationEngineLua.AnimationEngine");


local TotalTask = 5
local BAG_ID_1 = 1
local BAG_ID_2 = 2
local BAG_ID_3 = 3
local BAG_ID_4 = 4
local BAG_ID_5 = 5


local BAG_ID_22 = 22

-- 22 23 24 138 19

local TargetBagList = {22,23,24,264,19}
local MENU_TYPE_13 = 13
local LAYOUT_WIDTH = 768
local LAYOUT_HEIGHT = 1024

local TargetMenuTypeList = {MENU_TYPE_13,MENU_TYPE_13,MENU_TYPE_13,MENU_TYPE_GUSHI,MENU_TYPE_GEWU}

local MainLayer = class("MainLayer", function()
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
MainLayer.new = function(...)
    local instance
    if MainLayer.__create then
        instance = MainLayer.__create(...)
    else
        instance = { }
    end

    for k, v in pairs(MainLayer) do instance[k] = v end
    instance.class = MainLayer
    instance:ctor(...);
    return instance
end

function MainLayer:onEnter() 
    
end

function MainLayer:onExit()
	AudioEngine.stopMusic(true)--release资源就不会在win上停止后还播放
	g_tConfigTable.AnimationEngine:GetInstance():Dispose();
	SoundUtil:getInstance():soundListenDetectStop();
	SoundUtil:getInstance():setUploadAudioEnable(false)--恢复默认
end

function MainLayer:ctor(...)
	local tSdPath = ...
    self:init()
end

function MainLayer:init()
	self.m_sSdPath = nil
	self.m_winSize = nil
	self.m_jsonData = nil
	self.m_userInfo = nil
	self.m_savePath = nil
	self.m_isPlayIng = false;
	self.m_isIdleIng = true;
	self.m_isFinish = true;
	self.m_isClickExit = false
	self.m_bgJson = "";
	self.m_failJson = "";
	self.tag_ = -1;
	self.m_itemList = {};
	self.m_fingerEnd = nil;
	self.m_clickEnd = false;
	self.m_cxtLayer = nil
	self.m_clickPao = nil;
	self.m_clickFinger = nil;
	self.m_wenhaoArm = nil;
	self.m_gui_acquire_sprite = nil;
	self.m_gui_Notunlock_sprite = nil;
	g_tConfigTable.AnimationEngine:GetInstance()
	XueTangDataAdapter:getInstance():setWillPlayGame(false)
end

function MainLayer:createUI(sSdPath,isOp)
	self.m_jsonData = JsonData.new() --获取数据
	self.m_sSdPath = sSdPath;
	self.m_winSize = cc.Director:getInstance():getWinSize()
	self.m_dateIndex = self:getDateIndex();
	
	AudioEngine.playMusic(self.m_sSdPath.."sounds/191128ge.mp3", true) 
		
	local nUid = UInfoUtil:getInstance():getCurUidStr();
	self.activityId = XiaLingYingData:getInstance():getActivityId();
	self.subActivityId = XiaLingYingData:getInstance():getSubActivityId();
	CC_GameLog(self.activityId,self.subActivityId ,"eiiwwoeoiekskdkdkkdd")
	self.m_savePath = GET_REAL_PATH_ONLY("",PathGetRet_ONLY_SD) .. "xialingyingTemp/userInfo_"..nUid.."_"..self.activityId.."_"..self.subActivityId..".json";
	self.m_userInfo = self.m_jsonData:ReadJsonFileContentTable(self.m_savePath) or {};
	
	if self:isAllTaskPlay() then
		self.m_userInfo.playEnd = 1
	end


	if self:isAllTaskFinish() then
		CustomEventDispatcher:getInstance():msgBroadcastLua(CustomEventType.CE_COLLECT_SHOW_NEW_GOOD, 19, true)
	end

	self.ScaleMultiple = ArmatureDataDeal:sharedDataDeal():getUIItemScale_1024_1920() * 0.8
    if ArmatureDataDeal:sharedDataDeal():getIsHdScreen() == false then
		self.ScaleMultiple = self.ScaleMultiple * 2
	end


	local basePath = self.m_sSdPath.."image/"
	-- local rightPosX = (LAYOUT_WIDTH+self.m_winSize.width)*0.5 - 10 - self.ScaleMultiple * 75
	-- local rightPosY = (LAYOUT_HEIGHT+self.m_winSize.height)*0.5 - 20 - self.ScaleMultiple * 75
	
	local type = XiaLingYingData:getInstance():getTargetType()
	local bagId = XiaLingYingData:getInstance():getTargetBagId()
	CC_GameLog("eiiwoowowiieiei22333:",bagId)
	-- self:playBaseAmin("ganenhd000_xz",function() 	
	-- 	self:randomIdle(basePath);
	-- 	self:createEndBtn(basePath)
	-- 	if(isOp) then
	-- 		local arr = {}
	-- 		table.insert(arr,cc.DelayTime:create(0.8))
	-- 		table.insert(arr,cc.CallFunc:create(function() 
	-- 			self:createList(basePath,bagId);
	-- 		end))
	-- 		self:runAction(cc.Sequence:create(arr))
			
	-- 		self.m_isPlayIng = true;
	-- 		self:createAnimFirst("ganenhd004",function() 
	-- 			self.m_isPlayIng = false;
	-- 			self:playAnim(type,bagId);
	-- 		end);
	-- 	else
	-- 		self:createList(basePath,bagId);
	-- 		self:playAnim(type,bagId);
	-- 	end
	-- end);
	self:createList(basePath,bagId);
	self:randomIdle(basePath); --闲置
	--self:createEndBtn(basePath) --中间按钮
	self:playAnim(type,bagId);  --未完成任务得按钮提示
end


--创建按钮
function MainLayer:CreateButton(normal_res,selected_res,disable_res,callBack,scale)
    local button = ccui.Button:create(normal_res,selected_res,disable_res)
    local pre_scale = scale or self.ScaleMultiple
    local min_scale = pre_scale * 0.9
    button:setScale(pre_scale)
    button:setSwallowTouches(false)
    button:addTouchEventListener(function(ref, type)
        if type == ccui.TouchEventType.began then
            playNormalBtnSound()
            button:setScale(min_scale)
            --button:runAction(cc.ScaleTo:create(0.1, min_scale))
        elseif type == ccui.TouchEventType.moved then

        elseif type == ccui.TouchEventType.ended then

            button:runAction(cc.ScaleTo:create(0.05, pre_scale))
            if callBack then
                callBack()
            end
        elseif type == ccui.TouchEventType.canceled then
            button:runAction(cc.ScaleTo:create(0.05, pre_scale))
        end
    end)
    return button
end


--中间点击效果
function MainLayer:MiddleClick()
	if self.m_gui_acquire_sprite then
		self.m_gui_acquire_sprite:playByIndex(1,LOOP_NO)
        self.m_gui_acquire_sprite:setLuaCallBack(function(eType, pTouchArm, sEvent)
            if eType == TouchArmLuaStatus_AnimEnd then
                self.m_gui_acquire_sprite:playByIndex(0,LOOP_NO);
            end
        end)
	end
	-- if not self.parent:isAnyStoryPlaying() then
		if not self:isAllTaskFinish() then --不是所有任务完成
			local npc_1 = self.parent:getNpcByName("npc_pao") --雪花机点击效果
			if npc_1 then
				CC_GameLog("eiwiowoeikdkklslsskfkfjfjfj")
				npc_1:playByIndex(1,LOOP_NO)
		        npc_1:setLuaCallBack(function(eType, pTouchArm, sEvent)
		            if eType == TouchArmLuaStatus_AnimEnd then
		                npc_1:playByIndex(3,LOOP_NO);
		            end
		        end)
			end
			Utils:GetInstance():baiduTongji("xialingying","xmas19_click_unlockcannon")--tong ji
			self:createAnimFirst("Xmas076")
		else --所有任务完成
			local npc_1 = self.parent:getNpcByName("npc_pao") --雪花机点击效果
			if npc_1 then
				npc_1:playByIndex(5,LOOP_NO)
			end

			local function callBack( ... )
				npc_1:playByIndex(3,LOOP_NO)
			end
			Utils:GetInstance():baiduTongji("xialingying","xmas19_click_italiacannon")--tong ji
			self:createAnimFirst("191225end2a",callBack)
		end
	-- end
end

--
function MainLayer:createList(basePath,bagId)
	local mainbanArm = self.parent:getNpcByName("npc_mianban");

	local posx,posy = mainbanArm:getPosition()

	self.cpPosx = posx
	self.cpPosy = posy

	local cxtLayer = cc.Layer:create()
	cxtLayer:setContentSize(self:getContentSize());
	cxtLayer:setPosition(cc.p(-posx,-posy))
	mainbanArm:addChild(cxtLayer)
	self.m_cxtLayer = cxtLayer;

	
	
	-- local gui_bag_sprite = cc.Sprite:create(basePath.."gui_task01_bg.png");
	-- gui_bag_sprite:setScale(self.ScaleMultiple)
	-- gui_bag_sprite:setAnchorPoint(cc.p(0.5,0.5))
	-- gui_bag_sprite:setPosition(cc.p(posx,posy+55))
	-- cxtLayer:addChild(gui_bag_sprite,100001)
	
	local function CallBack( ... )
		self:MiddleClick()
	end
	local npc = self.parent:getNpcByName("npc_pao") --中间npc
	if npc then
		CC_GameLog("eiwiakdkdkalskkkkkkkkkkkkkkkkkkkkkkkkkkkjjfjfjf")
		self.parent:RegisterArmatureTouchEvent(npc,CallBack)
	end

	-- local npc_1 = self.parent:getNpcByName("npc_middle1") --雪花机点击效果
	-- if npc_1 then
	-- 	self.parent:RegisterArmatureTouchEvent(npc_1,nil,true)
	-- end

	-- local npc_2 = self.parent:getNpcByName("npc_middle2") --雪花机锁标志点击效果
	-- if npc_2 then
	-- 	self.parent:RegisterArmatureTouchEvent(npc_2,nil,true)
	-- end


	local gui_acquire_sprite = TouchArmature:create("191225hd_suo_mov", TOUCHARMATURE_NORMAL);	--cc.Sprite:create(basePath.."gui_lock.png");
	--gui_acquire_sprite:setPosition(cc.p(380+40,1024-420+40))
	--gui_acquire_sprite:setScale(self.ScaleMultiple)
	gui_acquire_sprite:playByIndex(0,LOOP_YES)
	gui_acquire_sprite:setAnchorPoint(cc.p(0.5,0.5))
	gui_acquire_sprite:setPosition(cc.p(80,75))
	npc:addChild(gui_acquire_sprite)
	self.m_gui_acquire_sprite = gui_acquire_sprite

	-- local gui_Notunlock_sprite = cc.Sprite:create(basePath.."gui_activate_task06.png");
	-- gui_Notunlock_sprite:setPosition(cc.p(size.width/2,size.height/2))
	-- --gui_Notunlock_sprite:setScale(self.ScaleMultiple)
	-- gui_Notunlock_sprite:setAnchorPoint(cc.p(0.5,0.5))
	-- gui_key_sprite:addChild(gui_Notunlock_sprite,1000002)
	-- self.m_gui_Notunlock_sprite = gui_Notunlock_sprite

	local isLock1 = false;
	local isLock2 = true;
	local isLock3 = true;

	local imageBgList = {
		{"gui_task01_bg.png","gui_task01_bg.png"},
		{"gui_task01_bg.png","gui_task01_bg.png"},
		{"gui_task01_bg.png","gui_task01_bg.png"},
		{"gui_task01_bg.png","gui_task01_bg.png"},
		{"gui_task01_bg.png","gui_task01_bg.png"}
	}

	local imageList = {
		{"gui_Nounlock_task01.png","gui_activate_task01.png","gui_task01_img.png"},
		{"gui_Nounlock_task02.png","gui_activate_task02.png","gui_task02_img.png"},
		{"gui_Nounlock_task03.png","gui_activate_task03.png","gui_task03_img.png"},
		{"gui_Nounlock_task04.png","gui_activate_task04.png","gui_task04_img.png"},
		{"gui_Nounlock_task05.png","gui_activate_task05.png","gui_task05_img.png"}
	}

	local posInfo = {
		{163,333},
		{334,186},
		{510,333},
		{449,505},
		{222,505}	
	}


	local scaleList = {

	}
	local curImageInfo = {}
	for i=1,TotalTask do
		local index = i
		local success1 = self.m_userInfo["success"..TargetBagList[index]]

		local bgImg = imageBgList[index][1]
		local imgName1 = imageList[index][1]
		local lock_state = true
		CC_GameLog(self.m_dateIndex,"eiiwoowoeieiiei")
		if self.m_dateIndex >= index then
			lock_state = false
			local success1 = self.m_userInfo["success"..TargetBagList[index]]
			if(success1 == 1) then
				bgImg = imageBgList[index][1]
				imgName1 = imageList[index][3]
			else
				bgImg = imageBgList[index][2]
				imgName1 = imageList[index][2]
			end	
		end
		local item = {
			bgName=bgImg,titleName = "gui_font_qq.png",imgName = imgName1,riqiName="",
			x2=posInfo[i][1],y2=posInfo[i][2],menuType = TargetMenuTypeList[i] ,bagId=TargetBagList[i],isLock = lock_state,scaleFac = 1.0
		}
		table.insert(curImageInfo,item)
	end
	for k,v in pairs(curImageInfo)do

		local item = ContentItem.new(v.menuType,v.bagId,basePath)
		item.mainLayer = self;
		item:setAnchorPoint(cc.p(0.5,0.5))
		item:setPosition(cc.p(-500,-500))
		item:createItem("gui_needupdate.png","gui_needupdate.png",false)--
		cxtLayer:addChild(item)


		CC_GameLog(v.menuType,v.bagId)
		dump(item.m_itemInfo)


		local copyItem = CopyItem.new(v.bagId,basePath)
		copyItem.mainLayer = self;
		copyItem.nodeItem = item;
		copyItem:setAnchorPoint(cc.p(0.5,0.5))
		copyItem:createItem(v.bgName,v.imgName,v.titleName,v.riqiName,v.isLock)
		copyItem:setPosition(cc.p(v.x2 - 5 ,1024-v.y2-54*2 ))

		copyItem:updateIcon(item.m_itemInfo)
		cxtLayer:addChild(copyItem,1000002)
		table.insert(self.m_itemList,copyItem)

		if(tonumber(bagId) == v.bagId) then
			local played = self.m_userInfo["played"..bagId]
			local success = self.m_userInfo["success"..bagId]
			if(success ~= nil and success == 1 and played ~= 1) then
				-- local arr = {}
				-- table.insert(arr,cc.DelayTime:create(1.2))
				-- table.insert(arr,cc.CallFunc:create(function()
				-- 	local gxArm = TouchArmature:create("20191128gejyr_shop_txhfli8x", TOUCHARMATURE_NORMAL);	
				-- 	gxArm:setPosition(cc.p(55,70));
				-- 	gxArm:playByIndex(0,LOOP_NO);
				-- 	copyItem:addChild(gxArm,1000);
				-- end))
				-- table.insert(arr,cc.DelayTime:create(1.5))
				-- table.insert(arr,cc.CallFunc:create(function()
				-- 	if(k == 1) then
				-- 		gui_progress01_sprite:runAction(cc.FadeIn:create(1))
				-- 	elseif(k == 2) then
				-- 		gui_progress02_sprite:runAction(cc.FadeIn:create(1))
				-- 	elseif(k == 3) then
				-- 		gui_progress03_sprite:runAction(cc.FadeIn:create(1))
				-- 	end
				-- 	copyItem:updateItem("gui_acquire_bg.png","gui_lovingheart_img.png")
				-- end))
				-- copyItem:runAction(cc.Sequence:create(arr))
			end
		end
	end
end


--是否所有任务玩过了
function MainLayer:isAllTaskPlay()
	local state = true
	for i=1,TotalTask do
		if self.m_userInfo["played"..TargetBagList[i]] ~= 1 then
			state = false
		end
	end
	return state
end

--是否所有任务完成了
function MainLayer:isAllTaskFinish( ... )
	local state = true
	for i=1,TotalTask do
		if self.m_userInfo["success"..TargetBagList[i]] ~= 1 then
			state = false
		end
	end
	return state
end

function MainLayer:showMddleClickEffect()
	local state = self:isAllTaskFinish()
	if state then

	end
end

--返回bagIndex
function MainLayer:getBagIndex(bagId)
	for i,v in ipairs(TargetBagList) do
		if tonumber(bagId) == tonumber(v) then
			return i
		end
	end
end

--截至当天的任务是否都完成了
function MainLayer:isDayAndBeforeTaskAllFinished()
	local curdayIndex = self.m_dateIndex <= 5 and self.m_dateIndex or 5
	local state = true
	for i=1,curdayIndex do
		if self.m_userInfo["success"..i] ~= 1 then
			state = false
		end
	end
	return state
end


--根据任务完成状态显示特效
function MainLayer:showFinishEffect()
	local state = self:isAllTaskFinish()
	if state then
	end
end

function MainLayer:hideIcon(itemInfo)
	for k,v in pairs(self.m_itemList)do
		if v.bagId == itemInfo.bagId then
			v:updateIcon(itemInfo)
		end
	end
end

function MainLayer:playLockAnim()
	self:createAnimFirst("Xmas073");
end

function MainLayer:playFreeDownAnim()
	if self:isPlaying() then
		self:createAnimFirst("Xmas074");
	end
end

function MainLayer:gotoTargetBagId(menuType,curBagId)
	print("jessica MainLayer:gotoTargetBagId",menuType,curBagId,self.m_isLock)
	if self.m_isLock then
		return
	end
	CC_GameLog(debug.traceback())
	--lf:createMaskView()
	self.parent:LockScreen()
	local bagId = curBagId
	--local menuType = MENU_TYPE_13

	if self.m_finger then
		self.m_finger:removeFromParent()
		self.m_finger = nil
	end

	-- if(self.m_userInfo["success"..curBagId] ~= 1) then
	-- 	Utils:GetInstance():baiduTongji("xialingying","wanchengqian_"..curBagId)
	-- else
	-- 	Utils:GetInstance():baiduTongji("xialingying","wanchenghou_"..curBagId)
	-- end
	
	local function CallBack( ... )
		CC_GameLog(menuType,curBagId,"eiiwoooooooooooooooooooooooooooooooooooooooooooooieieieiie")
		local bagIndex = self:getBagIndex(curBagId)
		local storyList = {"wanfaop1","wanfaop2","wanfaop3","wanfaop4","wanfaop5"}

		local function GoToBag( ... )
	        	self.m_isLock = false
				if(menuType == MENU_TYPE_GUSHI) then
					local gotoTemp = GET_REAL_PATH_ONLY("",PathGetRet_ONLY_SD) .. "xialingyingTemp/gotoTemp.json"
					local gotoList = {key=1}
					self.m_jsonData:WriteFilePath(gotoTemp,cjson.encode(gotoList));
					
					self.m_userInfo["success"..curBagId] = 1
				elseif(menuType == MENU_TYPE_GEWU) then
					self.m_userInfo["success"..curBagId] = 1		
				end
	        	local index = self:getBagIndex(bagId)
	        	self.m_userInfo["showGuide_"..index] = 1
	        	self:savePath()
	            --Utils:GetInstance():baiduTongji("xialingying","zq_op_enter")--tong ji
	            -- finger:removeFromParent()
	            -- enterBtn:removeFromParent()
				local storyid =310-- XiaLingYingData:getInstance():getCurBagId();

				if(menuType == MENU_TYPE_XUETANG) then
                        xblStaticData:gotoSourceKeepFrom(18, 7, bagId, menuType, storyid)
                elseif(menuType == MENU_TYPE_GUSHI) then
                        xblStaticData:gotoSourceKeepFrom(18, 9, bagId, menuType, storyid)
                elseif(menuType == MENU_TYPE_GEWU) then
                        xblStaticData:gotoSourceKeepFrom(18, 8, bagId, menuType, storyid)
                elseif(menuType == MENU_TYPE_BAOXIANG) then
                        xblStaticData:gotoSourceKeepFrom(18, 12, bagId, menuType, storyid)
                elseif(menuType == MENU_TYPE_CLASSICAL) then
                        xblStaticData:gotoSourceKeepFrom(18, 16, bagId, menuType, storyid)
                elseif(menuType == MENU_TYPE_13) then
                	   xblStaticData:gotoSourceKeepFrom(18, 18, bagId, menuType, storyid)
                end

				XiaLingYingData:getInstance():setTargetBagId(menuType,curBagId);
		end

		self:createAnimFirst(storyList[bagIndex],function() 
			GoToBag()
	        -- local finger = TouchArmature:create("point_all", TOUCHARMATURE_NORMAL); 
	        -- finger:setScale(self.ScaleMultiple*1.5)
	        -- finger:setPosition(cc.p(self.cpPosx,self.cpPosy+50));
	        -- finger:playByIndex(1,LOOP_YES);
	        -- self:addChild(finger,100000);
	        -- local imgPath = THEME_IMG("transparent.png") --
	        -- local enterBtn = ccui.Button:create(imgPath,imgPath);
	        -- enterBtn:setScale(25)
	        -- enterBtn:setAnchorPoint(cc.p(0.5,0.5));
	        -- enterBtn:setPosition(cc.p(self.cpPosx,self.cpPosy+50));
	        -- enterBtn:setPressedActionEnabled(true)  
	        -- enterBtn:setSwallowTouches(false);   
	        -- self:addChild(enterBtn,100000);
	        -- enterBtn:addClickEventListener(function()

	        -- end)
		end);


	end
	self.m_isLock = true
	self:createAnimFirst("Xmas075",function() 
		CallBack()
	end);
end


--创建手指动画
function MainLayer:createFingerTips(callBack)
    local finger = TouchArmature:create("point_all", TOUCHARMATURE_NORMAL); 
    finger:setScale(self.ScaleMultiple*1.5)
    finger:setPosition(cc.p(self.cpPosx,self.cpPosy+50));
    finger:playByIndex(1,LOOP_YES);
    self:addChild(finger,100000);
	if self.maskTouchLayer then
		self.maskTouchLayer:removeFromParent()
		self.maskTouchLayer = nil
	end
    local imgPath = THEME_IMG("transparent.png") --
    local enterBtn = ccui.Button:create(imgPath,imgPath);
    enterBtn:setScale(25)
    enterBtn:setAnchorPoint(cc.p(0.5,0.5));
    enterBtn:setPosition(cc.p(self.cpPosx,self.cpPosy+50));
    enterBtn:setPressedActionEnabled(true)  
    enterBtn:setSwallowTouches(false);   
    self:addChild(enterBtn,100000);
    enterBtn:addClickEventListener(function()
    	if callBack then
    		callBack()
    	end
    end)
end

function MainLayer:savePath()
	self.m_jsonData:WriteFilePath(self.m_savePath,cjson.encode(self.m_userInfo));
end

function MainLayer:playAnim(type,bagId)
	self.nextStoryState = false
	local TaskFirstEnter = {
		"Xmas067",
		"Xmas068",
		"Xmas069",
		"Xmas070",
		"Xmas071"		
	}


	local SuccessList = {
		"Xmas077",
		"Xmas078",
		"Xmas079",
		"Xmas080",
		"Xmas081",		
	}

	-- local FaillList = {
	-- 	"Xmas082",
	-- 	"Xmas083",
	-- 	"Xmas084",
	-- 	"Xmas085",
	-- 	"Xmas086",		
	-- }


	local NextList = 
	{
		"Xmas094",
		"Xmas095",
		"Xmas096",
		"Xmas097",
	}

	local function IsPreTaskAllFinished(taskId) --是否前面任务都完成
		local index = 1
		if taskId <= 1 then
			return true
		end
		taskId = taskId > 5 and 5 or taskId

		local state = true
		for i=1,taskId-1 do
			if i <= TotalTask then
				if self.m_userInfo["success"..TargetBagList[i]] ~= 1 then
					state = false
				end
			end
		end
		return state
	end


	--最近得未完成得任务
	local function getNearesUnFinishtTask(taskId)
		if taskId <= 1 then
			return 1
		end
		taskId = taskId >6 and 6 or taskId
		local state = true
		for i=taskId-1,1,-1 do
			if self.m_userInfo["success"..TargetBagList[i]] ~= 1 then 
				return i
			end
		end
		return 1
	end


	if(bagId == "") then --主界面直接进来
		local firstKey = "firstkey_"..self.activityId.."_"..self.subActivityId
		if(self.m_userInfo[firstKey] == nil or self.m_userInfo[firstKey] ~= 1) then
			self.m_userInfo[firstKey] = 1;
			self:savePath()
			local index = 0
			local playJson = nil
			self:showGuide(1)
			self:createAnimFirst(TaskFirstEnter[1]);
		else
			local index = 0
			local playJson = "Xmas093"
			--CC_GameLog(self.m_dateIndex,self.m_userInfo["success"..TargetBagList[self.m_dateIndex]],"2wiiwllsllllllllllllllllllllllllllllllllllllkkdkkdkjjjf")
			if self.m_dateIndex >= 1 and self.m_dateIndex <= 5 then
				if self.m_userInfo["success"..TargetBagList[self.m_dateIndex]] ~= 1 then
					self:showGuide(self.m_dateIndex)
					self:createAnimFirst(TaskFirstEnter[self.m_dateIndex]);
				else
					if IsPreTaskAllFinished(self.m_dateIndex) then --前面任务都完成了
						if self.m_dateIndex >= 5 then
							if self.m_gui_acquire_sprite then
								self.m_gui_acquire_sprite:setVisible(false)
							end
						end
						self:createAnimFirst("Xmas072");
					else
						local index = getNearesUnFinishtTask(self.m_dateIndex)
						self:showGuide(index)
						self:createAnimFirst("Xmas093");
					end
				end
			else
				if self:isAllTaskFinish() then
					if self.m_gui_acquire_sprite then
						self.m_gui_acquire_sprite:setVisible(false)
					end
					self:createAnimFirst("Xmas072");
				else
					local index = getNearesUnFinishtTask(self.m_dateIndex)
					self:showGuide(index)
					self:createAnimFirst("Xmas093");
				end
			end 
		end
	else --包返回来的
		local curBagId = tonumber(bagId)
		local success = self.m_userInfo["success"..bagId]
		CC_GameLog("eiiwowokdkallskdkdkfkkf",curBagId,success)
		if(success ~= nil and success == 1) then
			local index = 0
			local isLoop = false
			local playJson1 = nil;
			local playJson2 = nil;
			local playJson3 = nil;
			if(self.m_userInfo["played"..bagId] ~= 1) then
				self.m_userInfo["played"..bagId] = 1
				self:savePath()
				local bagIndex = self:getBagIndex(curBagId)
				playJson1 = SuccessList[bagIndex]
				--Utils:GetInstance():baiduTongji("xialingying","wanchengrenwu_"..curBagId)--tong ji

				self.m_isPlayIng = true
				self:createAnimFirst(playJson1,function() 
					if self.m_userInfo.openBox ~= 1 and self:isAllTaskFinish() then
						self.m_userInfo.openBox = 1;
						self:savePath()
						if self.m_gui_acquire_sprite then
							self.m_gui_acquire_sprite:setVisible(false)
						end
					    -- self:playBaseAmin("191128hd_endbg",function() 
						self:createAnimFirst("191225end1",function() 
							function callBack( ... )
								self:createAnimFirst("191225end2",function() 

								end)
							end
							self:createFingerTips( callBack )
						end);
						-- end);
					else
						local index = math.random(1,4)
						local storyid = NextList[index]
						if not self:isAllTaskFinish() then
							self.nextStoryState = true
							self:createAnimFirst( storyid )
						else
							if self.m_gui_acquire_sprite then
								self.m_gui_acquire_sprite:setVisible(false)
							end
						end
					end
				end)
			else
				CC_GameLog("eiwildlkdddddddddddddddddd",self.m_dateIndex)
				playJson2 = "Xmas093"
				if self.m_dateIndex >= 1 and self.m_dateIndex<= 5 then
					if self.m_userInfo["success"..TargetBagList[self.m_dateIndex]] ~= 1 then
						playJson2 = TaskFirstEnter[self.m_dateIndex]
						self:showGuide(self.m_dateIndex)
					else
						CC_GameLog("uiiiiooeoeooe:",IsPreTaskAllFinished(self.m_dateIndex))
						if IsPreTaskAllFinished(self.m_dateIndex) then --前面任务都完成了
							if self.m_dateIndex >= 5 then
								if self.m_gui_acquire_sprite then
									self.m_gui_acquire_sprite:setVisible(false)
								end
							end
							playJson2 = "Xmas072"
						else
							local index = getNearesUnFinishtTask(self.m_dateIndex)
							CC_GameLog("zzzzzzzzzzzzz:",index)
							self:showGuide(index)
							playJson2 = "Xmas093"
						end
					end
				else
					if self:isAllTaskFinish() then
						if self.m_gui_acquire_sprite then
							self.m_gui_acquire_sprite:setVisible(false)
						end
						playJson2 = "Xmas072"
					else
						local index = getNearesUnFinishtTask(self.m_dateIndex)
						self:showGuide(index)
						playJson2 = "Xmas093"
					end
				end 
				self:createAnimFirst(playJson2)
			end

		else --失败返回来的情况
			local bagIndex = self:getBagIndex(curBagId)
			CC_GameLog("hhhhhhhhhhhhhhhhhhhhhhhhhh")
			if bagIndex > 1 then
				if self.m_dateIndex >= 1 and self.m_dateIndex<= 5 then
					if self.m_userInfo["success"..TargetBagList[self.m_dateIndex]] ~= 1 then
						self:showGuide(self.m_dateIndex)
						self:createAnimFirst(TaskFirstEnter[self.m_dateIndex]);
					else
						if IsPreTaskAllFinished(self.m_dateIndex) then --前面任务都完成了
							self:createAnimFirst("Xmas072");
							if self.m_dateIndex >= 5 then
								if self.m_gui_acquire_sprite then
									self.m_gui_acquire_sprite:setVisible(false)
								end
							end
						else
							local index = getNearesUnFinishtTask(self.m_dateIndex)
							self:showGuide(index)
							self:createAnimFirst("Xmas093");
						end
					end
				else
					if self:isAllTaskFinish() then
						if self.m_gui_acquire_sprite then
							self.m_gui_acquire_sprite:setVisible(false)
						end
						self:createAnimFirst("Xmas072");
					else
						local index = getNearesUnFinishtTask(self.m_dateIndex)
						self:showGuide(index)
						self:createAnimFirst("Xmas093");
					end
				end	
			else
				self:createAnimFirst("Xmas082");
			end

		end
	end
end

--引导手势
function MainLayer:showGuide(index)
	if(index <= 0) then
		return;
	end

	if(self.m_finger ~= nil) then
		return;
	end

	if self.m_userInfo["showGuide_"..index] == 1 then
		return 
	end

	local pt1 = cc.p(50,55)
	local pt2 = cc.p(50,62)
	local itemLayer = self.m_itemList[index]

	CC_GameLog("MainLayer showGuide=="..index)
	writeToFile("MainLayer showGuide=="..index)

	local paoMov = TouchArmature:create("191128wf_antx_gx", TOUCHARMATURE_NORMAL);	
	paoMov:setScale(self.ScaleMultiple)
	paoMov:setPosition(pt2);
	paoMov:playByIndex(1,LOOP_YES);
	itemLayer:addChild(paoMov,100001);
	self.m_paoMov = paoMov;

	local finger = TouchArmature:create("point_all", TOUCHARMATURE_NORMAL);	
	finger:setScale(self.ScaleMultiple)
	finger:setPosition(pt1);
	finger:playByIndex(1,LOOP_YES);
	itemLayer:addChild(finger,100002);
	self.m_finger = finger;
end


--移除Notice
function MainLayer:reMoveNotice()
	if self.m_finger then
		self.m_finger:removeFromParent()
		self.m_finger = nil
	end

	if self.m_paoMov then
		self.m_paoMov:removeFromParent()
		self.m_paoMov = nil
	end	
	
end

function MainLayer:createMaskView()
    --触摸屏蔽层
    local winSize = VisibleRect:winSize()
    local maskTouchLayer = cc.Layer:create()
    maskTouchLayer:setContentSize(cc.size(winSize.width, winSize.height))
    local function touchLayerCallFunc(eventType, x, y)
       -- CC_GameLog_kaogu("aeeeekkkkkkkkkkkkkkkkkkkkkkkkkkkkkjfjfj")
        --在began触摸时，返回true，消息将被拦截，这样就实现了屏蔽层
        if eventType == "began" then
            return true
        elseif eventType == "moved" then
        elseif eventType == "ended" then 
        end
    end
    --这个函数的使用我在这篇博客中有说明(http://blog.csdn.net/tianxiawuzhei/article/details/46011101)
    maskTouchLayer:registerScriptTouchHandler(touchLayerCallFunc, false, 0, true)
    maskTouchLayer:setTouchEnabled(true)
    self.maskTouchLayer = maskTouchLayer
    self:addChild(self.maskTouchLayer,2000000)
end



--第一次进入珊瑚营地时，介绍营地和营地任务
function MainLayer:createAnimFirst(jsonFile,cbFunc)
	if(jsonFile == nil or jsonFile == "") then
		if(cbFunc) then
			cbFunc()
		end
		return
	end

	release_print("jsonFile======="..jsonFile)
	local function callBack(eventName)
		CC_GameLog(eventName,"ckkdkdldldl")
		if eventName == "Complie" then
			if(cbFunc) then
				cbFunc();
			else
				self.m_isPlayIng = false
			end
		elseif eventName == "InternalINterupt" then 
			if(cbFunc) then
				cbFunc();
			else
				self.m_isPlayIng = false
			end
		end
	end

	self:playActionAmin(jsonFile,callBack)
end

function MainLayer:playBaseAmin(jsonFile,callBack)
	if(jsonFile == nil or jsonFile == "") then
		if(callBack) then
			callBack("Complie")
		end
		return
	end

	local function playCallBack(eventName)
		if eventName == "Complie" then 
			self.m_isIdleIng = true
			if(callBack) then
				callBack(eventName)
			end
		elseif eventName == "InternalINterupt" then 
		end
	end

	g_tConfigTable.AnimationEngine:GetInstance():PlayPackageBgConfig(
		g_tConfigTable.sTaskpath.."sayHelloGuide/story/"..jsonFile..".json",
		self ,
		g_tConfigTable.sTaskpath.."image/",
		g_tConfigTable.sTaskpath.."audio/",
		playCallBack
	);
end

function MainLayer:playActionAmin(jsonFile,callBack)
	if(jsonFile == nil or jsonFile == "") then
		if(callBack) then
			callBack("Complie")
		end
		return
	end
	self.m_isIdleIng = false;
	if(self.tag_ and self.tag_ > -1) then
		g_tConfigTable.AnimationEngine:GetInstance():ProcessActionToEndByTag(self.tag_);
		g_tConfigTable.AnimationEngine:GetInstance():StopPlayStory(self.tag_);
	end
	self.tag_ = self.parent:PlayStoryAction(jsonFile,callBack)
end

--闲置语音
function MainLayer:randomIdle(basePath)
	local function clickCallBack1(flag)
		if self.m_isLock then
			return
		end
		CC_GameLog("iwiweoeokdkfkfjajfjkdsllkkdkdwweed")
		if not self:isDayAndBeforeTaskAllFinished() then
			local playJsonList = {"Xmas083","Xmas084"}
			local NextList = 
			{
				"Xmas094",
				"Xmas095",
				"Xmas096",
				"Xmas097",
			}
			if self.nextStoryState then
				for i,v in ipairs(NextList) do
					table.insert(playJsonList,v)
				end
			end
			local number = #playJsonList
			local index = math.random(number)
			local playJson = playJsonList[index]
			self:createAnimFirst(playJson);
		else
			local playJson = "Xmas093"
			self:createAnimFirst(playJson);
		end
	end	

	local function clickCallBack2()
		CC_GameLog(self:isPlaying(),self.m_isLock,"eiiwlwldddddddddddddddkk22")
		if self:isPlaying() == false and not self.m_isLock  then
			clickCallBack1(false)
			--Utils:GetInstance():baiduTongji("xialingying","xiaobanlong_click_1")--tong ji
			SimpleAudioEngine:getInstance():playEffect(UISOUND_A_BTN)
		end
	end


	local itemPath = THEME_IMG("transparent.png")--basePath.."temp.png" --
	local clickBtn1 = ccui.Button:create(itemPath,itemPath);
	clickBtn1:setAnchorPoint(cc.p(0.5,0.5));
	clickBtn1:setPosition(cc.p(495,1024-812));
	clickBtn1:setPressedActionEnabled(true)  
	clickBtn1:setSwallowTouches(false);   
	self:addChild(clickBtn1,100000);
	-- local size = clickBtn1:getContentSize()


	-- self.colorLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 255));
	-- self.colorLayer:setContentSize(cc.size(size.width, size.height));

	-- self.colorLayer:ignoreAnchorPointForPosition(false)
	-- self.colorLayer:setPosition(cc.p(size.width/2, size.height/2));
	-- clickBtn1:addChild(self.colorLayer)

	clickBtn1:addClickEventListener(clickCallBack2)
	
	local scale1 = 15
	if ArmatureDataDeal:sharedDataDeal():getIsHdScreen() then 
		scale1 = scale1 * 2
	end
	clickBtn1:setScale(scale1)

	local arr = {}
	table.insert(arr,cc.DelayTime:create(15))
	table.insert(arr,cc.CallFunc:create(function() 
		CC_GameLog(self:isPlaying(),"eiiwlwldddddddddddddddkk")
		if self:isPlaying() == false then
			clickCallBack1(true);
		end
	end))
	self:runAction(cc.RepeatForever:create(cc.Sequence:create(arr)))
end

function MainLayer:getTime() 
	return os.time()
end

function MainLayer:getDateIndex()
	local nLocalTime = self:getTime();

	local dayStamp = 86400;
	local startTime1 = 1576857600
	local startTime2 = startTime1 + dayStamp * 1
	local startTime3 = startTime1 + dayStamp * 2
	local startTime4 = startTime1 + dayStamp * 3
	local startTime5 = startTime1 + dayStamp * 4
	local startTime6 = startTime1 + dayStamp * 5
	local startTime7 = startTime1 + dayStamp * 7

	if nLocalTime < startTime1 then
		return 1
	elseif nLocalTime >= startTime1 and nLocalTime < startTime2 then --12月21号
		return 1
	elseif nLocalTime >= startTime2 and nLocalTime < startTime3 then --12月22号
		return 2
	elseif nLocalTime >= startTime3 and nLocalTime < startTime4 then --12月23号
		return 3
	elseif nLocalTime >= startTime4 and nLocalTime < startTime5 then --12月24号
		return 4
	elseif nLocalTime >= startTime5 and nLocalTime < startTime6 then --12月25号
		return 5
	elseif nLocalTime >= startTime6 and nLocalTime < startTime7 then --12月26号
		return 6
	else
		return 7   --12月27号
	end
end

function MainLayer:clickCloseLayer(callBack)
	if self.m_isClickExit then
		return
	end
	-- CC_GameLog("tddaaa",self.m_dateIndex <= 5 , not self.parent:isAnyStoryPlaying())
	if(self.m_dateIndex <= 5 and not self.parent:isAnyStoryPlaying()) then
		self.m_isClickExit = true
		self:playActionAmin("Xmas085",callBack)
	else
		callBack()
	end
end

function MainLayer:isPlaying()
	return self.parent:isAnyStoryPlaying()
end

return MainLayer