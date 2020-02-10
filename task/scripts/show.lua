local show = class("show", function() return cc.Node:create() end)
local LAYOUT_WIDTH = 768
local LAYOUT_HEIGHT = 1024
--------------------------------------------------------------------------------------------------
show.new = function(...)
    local instance
    if show.__create then
        instance = show.__create(...)
    else
        instance = {}
    end

    for k, v in pairs(show) do
        instance[k] = v
    end
    instance.class = show
    instance:ctor(...)
    return instance
end
---------------------------------------------------------------------------------------------------
-- 已经创建初步初始化完成
function show:ctor(...)
	local sTaskpath, num, mode, removeCallBackFunc  = ...
	self.m_currscene        = StoryEngineScene.curStoryEngineScene
	self.m_PlayerState      = STORY4V_PLAY_ING
	self.m_strCfgPath = sTaskpath
	self.removeCallBackFunc = removeCallBackFunc
	self.num = num
	self.mode = mode

	local function onNodeEvent(event)
		if event == "enter" then
			self:onEnter()
		elseif event == "exit" then
			self:onExit()
		end
	end
	self:registerScriptHandler(onNodeEvent)
---------------------------------------------------------------------------------------------------新增配置
	self.m_canTouch = false
	self.m_cleanNum = 0
	self.winSize = cc.Director:getInstance():getWinSize()

	--解析文件
    local cfgPath = self.m_strCfgPath .. "Drew/" .. "show.json" --需要解析的文件路径
	self.Cfg = requirePack("baseScripts.homeUI.JsonData", false).new():ReadJsonFileContentTable(cfgPath)

	self.db = self:createSprite(self.Cfg.dbpic,cc.p(self.Cfg.posx,self.Cfg.posy))

	for i=1,#self.Cfg.show do
		if self.Cfg.show[i].id == self.num then
			for j=1,#self.Cfg.show[i].gift do
				if self.Cfg.show[i].gift[j].name then
					self.Cfg.show[i].gift[j].pic = self:createSprite(self.Cfg.show[i].gift[j].name,cc.p(self.Cfg.giftPos[j].posx,self.Cfg.giftPos[j].posy))
				end
			end
		end
	end
	
	--[[ if mark == 1 then
		print("创建精灵")
		self.protagonist = self:createSprite(name,cc.p())
	elseif mark == 2 then 
		print("创建NPC")
		self.protagonist = self:createNpc(name,cc.p())
	end ]]
	self.closeBtn = self:createButton(self.Cfg.confirmBtn[4].name,cc.p(self.Cfg.confirmBtn[4].posx,self.Cfg.confirmBtn[4].posy),true)
	if self.mode == 0 then
		print("当前模式:",self.mode)
		self.confirmBtn = self:createButton(self.Cfg.confirmBtn[1].name,cc.p(self.Cfg.confirmBtn[1].posx,self.Cfg.confirmBtn[1].posy),true)
	elseif self.mode == 1 then
		print("当前模式:",self.mode)
		self.confirmBtn = self:createButton(self.Cfg.confirmBtn[2].name,cc.p(self.Cfg.confirmBtn[2].posx,self.Cfg.confirmBtn[2].posy),true)
		self.confirmBtn1 = self:createButton(self.Cfg.confirmBtn[3].name,cc.p(self.Cfg.confirmBtn[3].posx,self.Cfg.confirmBtn[3].posy),false)
	end

	self:createMap(self.Cfg.bgpic)
	self:refreshStartScene()
end
---------------------------------------------------------------------------------------------------
--进入
function show:onEnter()
	cc.Director:getInstance():getOpenGLView():setTouchMultiple(false)
	-- 触摸开始
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
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    listener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    listener:registerScriptHandler(onTouchCancelled,cc.Handler.EVENT_TOUCH_CANCELLED )
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithFixedPriority(listener,-2)
    self.m_listener       = listener
end

--退出
function show:onExit()
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListener(self.m_listener)
    self:removeAllChildren()  
end
---------------------------------------------------------------------------------------------------
function show:createMap(name)  
	local bgimgPath = self.m_strCfgPath .. "bgimg/".."UI/" .. tostring(name)  --添加地图板块
	self.bgimg = cc.Sprite:create(bgimgPath)
    self.bgimg:setAnchorPoint(cc.p(0.5,0.5))
	self.bgimg:setScale(CFG_SCALE(1))
	self.bgimg:setPosition(LAYOUT_WIDTH* 0.5, LAYOUT_HEIGHT * 0.5)
	self:addChild(self.bgimg,1)
end
---------------------------------------------------------------------------------------------------
function show:createSprite(name,pos)--创建UI
	local bgimgPath = self.m_strCfgPath .. "bgimg/".."UI/" .. tostring(name)  
	local UI = cc.Sprite:create(bgimgPath)
    UI:setAnchorPoint(cc.p(0.5,0.5))
	UI:setScale(CFG_SCALE(0.427))
	UI:setPosition(cc.p(--[[ CFG_X ]](pos.x +UI:getContentSize().width*0.5*CFG_SCALE(0.427)), 1024-(pos.y +UI:getContentSize().height*0.5*CFG_SCALE(0.427))))
	self:addChild(UI,10)
	return UI
end
---------------------------------------------------------------------------------------------------
function show:createNpc(name,pos) --创建npc
	local npc = TouchArmature:create(name, TOUCHARMATURE_NORMAL) 
	npc:setScale(CFG_SCALE(1.0))
	npc:setPosition(cc.p(--[[ CFG_X ]](pos.x),1024-(pos.y)))   
    self:addChild(npc, 10)  
    return npc
end
---------------------------------------------------------------------------------------------------
function show:createButton(btnPic,pos,bool) --创建按钮
	local function adsCloseCallBack( ref, ntype )
		if ntype == ccui.TouchEventType.ended then
			ref:setScale(CFG_SCALE(0.427, 3))
			if bool then
				self:removeFromParent()
				if self.removeCallBackFunc then
					self.removeCallBackFunc()
				end
			else
				print("跳转到H5")
			end
		elseif ntype == ccui.TouchEventType.began then
			ref:setScale(CFG_SCALE(0.3843, 3))
		elseif ntype ==  ccui.TouchEventType.canceled then
			ref:setScale(CFG_SCALE(0.427, 3))
		end
	end
	local pic = self.m_strCfgPath .. "bgimg/".."UI/" .. tostring(btnPic)  
	local Btn = ccui.Button:create(pic,pic)
	Btn:setAnchorPoint(cc.p(0.5, 0.5))
	Btn:setPosition(cc.p(--[[ CFG_X ]](pos.x +Btn:getContentSize().width*0.5*CFG_SCALE(0.427)), 1024-(pos.y +Btn:getContentSize().height*0.5*CFG_SCALE(0.427))))
	Btn:setScale(CFG_SCALE(0.427, 3))
	Btn:addTouchEventListener(adsCloseCallBack)
	self:addChild(Btn, 10)
	return Btn
end
---------------------------------------------------------------------------------------------------
function show:refreshStartScene()
	self.m_canTouch = true
end
---------------------------------------------------------------------------------------------------
function show:onTouchBegan(touch, event)	
end
function show:onTouchMoved(touch, event)
end
function show:onTouchEnded(touch, event)
end
function show:onTouchCancelled(touch, event)
	self:onTouchEnded(touch, event)
end
---------------------------------------------------------------------------------------------------
function show:refreshEndScene()
	self:moduleSuccess()
end
---------------------------------------------------------------------------------------------------
function show:moduleSuccess(dt)
	self.m_PlayerState = STORY4V_PLAY_SUCCESS
	self:moduleEnd()
end

function show:moduleEnd()
	print("show moduleEnd")
	local function onModuleEndDo()
		self:onModuleEndDo()
	end
	performWithDelay(self,onModuleEndDo, 0.017)
end

function show:onModuleEndDo()
	self.m_currscene.isSpeakBusy =false
	self:moduleEndNormal(self.m_PlayerState)--下面那段代码在父节点函数实现

	--self:removeFromParent()
end

return show