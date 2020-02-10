local BasePlayScene = requirePack("scripts.Common.BasePlayScene")
local Json = requirePack("scripts.Common.Dkjson")
local ContentItem = requirePack("scripts.ContentItem")
local CopyItem = requirePack("scripts.CopyItem")

local LMMDress =
    class(
    "LMMDress",
    function(...)
        return BasePlayScene.new(...)
    end
)
--重写[[new]]
g_tConfigTable.CREATE_NEW(LMMDress)
---------------------------------------------------------------------------------------------------
local winSize = g_tConfigTable.winSize

local TotalTask = 3
local BAG_ID_1 = 1
local BAG_ID_2 = 2
local BAG_ID_3 = 3

-- 22 23 24 138 19
local TargetBagList = {187,255,169}
---------------------------------------------------------------------------------------------------
function LMMDress:ctor(...)
	print("LMMDress-----ctor")
    self:init()
    self:initData()
end



function LMMDress:initData()
    self.debug = true
    self.m_canTouch = false
    self.endstate = false
    self.m_clearCount=0

    -- self.speakArm = self.m_currbglayer:getNpcArmature("null")

	self.updateScheduler = nil
    self.tipScheduler = nil

    self.menuType = 2 --去哪

    self.m_userInfo = nil
    self.m_itemList = {};


end

function LMMDress:init()
    --[解析json配置文件]
    local cfgPath = self.strCfgPath .. "config/" .. "LMMDress.json" --需要解析的文件路径
    self.Cfg = Json.parseFile(cfgPath)

    --[[StoryBgLayer]]
    -- self.m_currV4Scene:changeBgLayout(self.sourceID, false)
    -- self.m_currbglayer = StoryBgLayer.curBgLayer
end
---------------------------------------------------------------------------------------------------
--[[onEnter]]
function LMMDress:onEnter()
    print("frank-----onEnter")
    BasePlayScene.onEnter(self)
    if self.strCfgPath .. "bgimg/sounds/" .. self.Cfg.backgroundMusci then
        SoundUtil:getInstance():playBackgroundMusic(self.strCfgPath .. "bgimg/sounds/" .. self.Cfg.backgroundMusci, true)
    end

    self:enterScene()
end


function LMMDress:initBgInfo()
    for i=1, #self.Cfg.targetList do
        self.Cfg.targetList[i].arm=self.stageNode:getChildByName(self.Cfg.targetList[i].npcName)
        self.Cfg.targetList[i].clickArm=self.stageNode:getChildByName(self.Cfg.targetList[i].clickName)
        self.Cfg.targetList[i].isClick=false
    end
end


--[[onExit]]
function LMMDress:onExit()
    self:closeTipScheduler()
    SoundUtil:getInstance():stopBackgroundMusic(false)
    BasePlayScene.onExit(self)
end
---------------------------------------------------------------------------------------------------
--[[进入]]
function LMMDress:enterScene()
    -- local func3 = function()
    --     self.m_canTouch = true
    --     local randNum=math.random(1,#self.Cfg.targetList)
    --     local info = self.Cfg.targetList[randNum]
    --     self:createClickPrompt(cc.p(info.clickArm:getPosition()), 1, 0.6, self.topNode)
    --     self:createTipScheduler()
    -- end
    -- -- local func2 = function()
    -- --     self:playAnimation(self.stageNode, self.Cfg.beforeJsonName, func3)
    -- -- end
    -- -- local func1 = function()
    -- --     self.AnimationEngine:RemoveEngineCreatedObjOnNode(self.stageNode) -- 清空舞台
    -- --     self:InitBgConfig(self.stageNode, self.Cfg.bgconfigJson02, func2)
    -- -- end
    local func = function()
        -- self:playAnimation(self.stageNode, "lmmxnpd011.json")
        self:createUI()
    end
    -- local func = function()
    --     -- self:initBgInfo()
    --     -- self:say(self.speakArm, "lsjn01025",func3) --------开场白-------------
    -- end

    self:InitBgConfig(self.stageNode, self.Cfg.bgconfigJson, func)
    
    --------获取包信息---------------
    -- self:getBagListInfo()
end
--[[退出]]
function LMMDress:exitScene()
    self:closeTipScheduler()
    local func2 = function()
        self:moduleSuccess()
	end
    -- local func1 = function()
    --     self:zhenbang(func2)
    -- end
    -- local func = function()
    --     self:playAnimation(self.stageNode, self.Cfg.endJsonName, func1)
    -- end
    -- self.AnimationEngine:RemoveEngineCreatedObjOnNode(self.stageNode) -- 清空舞台
    -- self:InitBgConfig(self.stageNode, self.Cfg.bgconfigJson03, func)
    self:playAnimation(self.stageNode, self.Cfg.endJsonName, func2)

end
--[[Touch]]
---------------------------------------------------------------------------------------------------
function LMMDress:onTouchBegan(touch, event)
    -- if not self.m_canTouch then
    --     return false
    -- end
    -- self:closeTipScheduler()
    -- self:removeFingerTip()
    -- local function playEnd()
    --     self:checkEnd()
    -- end 
    -- for i=1, #self.Cfg.targetList do  --在有效的四个点击区域内点击判断
    --     local info=self.Cfg.targetList[i]
    --     if self:hasClicked(self.stageNode:getChildByName(info.clickName), touch, self.stageNode)  and not info.isClick then
    --             self.m_clearCount=self.m_clearCount+1
    --             info.isClick=true
    --             self.m_canTouch = false
    --             self:playArm(info.arm, info.playIndex, info.endIndex,playEnd)  --云动画---
    --             self:playArm(self.Cfg.toolsArm, info.szPlayIndex, 0)  --扇子动画---
    --         return true
    --     end
    -- end
    -- return false
end

function LMMDress:checkEnd()
    if self.m_clearCount >= self.Cfg.targetCount then
        self.m_canTouch = false
        local shanDianArm=self.stageNode:getChildByName("AESOP*xg_shandian") --
        shanDianArm:playByIndex(1,LOOP_YES,self.m_SoundPath)
        self:exitScene()
    else
        self.m_canTouch = true
        self:createTipScheduler()
    end
end

function LMMDress:onTouchMoved(touch, event)
end

function LMMDress:onTouchEnded(touch, event)
    -- local func1 = function()
    -- end
    -- local func = function()
    --     self.step = self.step + 1
    --     if self.step > #self.Cfg.AnimationList then
    --         self:exitScene()
    --     else
    --         self.canTouch = true
    --         local info = self.Cfg.AnimationList[self.step]
    --         self:createDragPrompt(cc.p(info.pos1x, 1024 - info.pos1y), cc.p(info.pos2x, 1024 - info.pos2y), 0.8, self.topNode)
    --     end
    -- end
    -- self.canTouch = false

    -- self:playAnimation(self.stageNode, self.Cfg.AnimationList[self.step].endJsonName, func)
    
end
--[[gameFunc]]
---------------------------------------------------------------------------------------------------
----------------在UI层显示-----------------------------------------------------------------------------------
function LMMDress:createUI()
    local basePath = self.strCfgPath.."bgimg/"
    local bagId=310
    self.m_dateIndex = self:getDateIndex();



    self:showGushiList(basePath,bagId)

   

end 
-----显示故事ID路线-------
function LMMDress:showGushiList(basePath,bagId)
    local cxtLayer = cc.Layer:create()
	cxtLayer:setContentSize(self:getContentSize());
	cxtLayer:setPosition(cc.p(0,0))
	self.topNode:addChild(cxtLayer)
    self.m_cxtLayer = cxtLayer;
    
    local isLock1 = false;
	local isLock2 = true;
	local isLock3 = true;

	local imageBgList = {
		{"gui_s1.png","gui_s1.png"},
		{"gui_s1.png","gui_s1.png"},
		{"gui_s1.png","gui_s1.png"}
	}

	local imageList = {
		{"gui_huanwan.png","gui_logo_1.png","gui_qipao_1.png"},
		{"gui_qunzi.png","gui_logo_2.png","gui_qipao_2.png"},
		{"gui_bangzi.png","gui_logo_3.png","gui_qipao_3.png"},
	}

	local posInfo = {
		{442,665},
		{297,540},
		{480,502}
    }

    local curImageInfo = {}
	for i=1,TotalTask do
		local index = i
		-- local success1 = self.m_userInfo["success"..TargetBagList[index]]

		local bgImg = imageBgList[index][1]
		local imgName1 = imageList[index][1]
		local lock_state = true
		print(self.m_dateIndex,"eiiwoowoeieiiei")
		if self.m_dateIndex >= index then
			lock_state = false
			local success1 =1 --self.m_userInfo["success"..TargetBagList[index]]
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
			x2=posInfo[i][1],y2=posInfo[i][2],menuType = self.menuType ,bagId=TargetBagList[i],isLock = lock_state,scaleFac = 1.0
		}
		table.insert(curImageInfo,item)
    end
    
    for k,v in pairs(curImageInfo)do

		local item = ContentItem.new(v.menuType,v.bagId,basePath)
		item.mainLayer = self;
		item:setAnchorPoint(cc.p(0.5,0.5))
		item:setPosition(cc.p(-500,-500))
		item:createItem("btn_xiazai.png","btn_xiazai.png",false)--
		cxtLayer:addChild(item)

        dump(v)
		-- print(v.menuType,v.bagId)
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
			-- local played = self.m_userInfo["played"..bagId]
			-- local success = self.m_userInfo["success"..bagId]
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

function LMMDress:getDateIndex()
	local nLocalTime = self:getTime();
    print(nLocalTime)
	local dayStamp = 86400;
	local startTime1 = 1578931200  --2020-01-14
	local startTime2 = startTime1 + dayStamp * 1
    local startTime3 = startTime1 + dayStamp * 2
    local startTime4 = startTime1 + dayStamp * 3


	if nLocalTime < startTime1 then
		return 1
	elseif nLocalTime >= startTime1 and nLocalTime < startTime2 then --1月15号
		return 1
	elseif nLocalTime >= startTime2 and nLocalTime < startTime3 then --1月16号
		return 2
	elseif nLocalTime >= startTime3 and nLocalTime < startTime4 then --1月17号
		return 3
	else
		return 3   --12月27号
	end
end

function LMMDress:getTime() 
	return os.time()
end




function LMMDress:getBagListInfo()
    local version=self:getAPPVersionAsNumber()
    -- print(v,self.BagID)
    -- local bagListInfo=MenuItemNetData:getInstance():startToGetPackageMenuDataLua(2,self.BagID,v,true,false,0) ---并没有获得数据
	-- dump(bagListInfo)
	

	local fun = function (nMenuType, sParentBagId, sIdList, isScuess)
		if isScuess then
				print("网络菜单列表 ",sIdList)
				--writeToFile("网络诗人列表   "..sIdList)
				-- self:dealNetMenuList(sIdList)
		end
	end
	MenuItemNetData:getInstance():startToGetPackageMenuDataLua(2, 310, version, true, fun, cc.Node:create())

end 




--获取版本号。 从 8.7.1 开始 有这个方法
function LMMDress:getAPPVersionAsNumber()
    local version =  Utils:GetInstance():getXBLVersion()
    local versionTable = string.split(version,".")
    local number =  ""
    for i=1,#versionTable do
        number = number..versionTable[i]
    end
    return tonumber(number)
end




function LMMDress:createXbl()
    --创建一个小伴龙
    self.xbl = TouchArmature:create("XBL6ZH", TOUCHARMATURE_NORMAL,1)
    self.xbl:setScale(0.3)--缩放
    self.xbl:setPosition(cc.p(-1858, 877)) --位置
    self.stageNode:addChild(self.xbl,20)
    self.xbl:setRectAndBeginPlay(1)
    self.xbl:playByIndex(1, LOOP_YES)
    self.xbl:setTouchEnable(true)
    self.xbl:setSwallowTouches(false)
end 
function LMMDress:createXbl()
    
end 

function LMMDress:createTipScheduler()
    if self.tipScheduler then
        return
    end
    local schedulerfunc = function()
        self:say(self.speakArm, "lsjn01025")  ---长时间不操作提示
        -- self:createClickPrompt(cc.p(self.Cfg.targetList[self.target[self.step].key].arm:getPosition()), 1, 0.6, self.topNode)
        for i = 1, #self.Cfg.targetList do
            if(self.Cfg.targetList[i].isClick ~=true) then 
                local info=self.Cfg.targetList[i]
                self:createClickPrompt(cc.p(info.clickArm:getPosition()), 1, 0.6, self.topNode)
                return
            end 
        end
    end
    self.tipScheduler = self.scheduler:scheduleScriptFunc(schedulerfunc, 20.0, false)
end

function LMMDress:closeTipScheduler()
    if self.tipScheduler then
        self.scheduler:unscheduleScriptEntry(self.tipScheduler)
        self.tipScheduler = nil
    end
end

return LMMDress
