local CustomEventTypes = requirePack("baseScripts.dataScripts.CustomEventType", false)
local targetPlatform = cc.Application:getInstance():getTargetPlatform()

-- local GushiItem =
-- 	class(
-- 	"GushiItem",
-- 	function(showItem)
-- 		local sNode = StateNode:create(showItem)
-- 		sNode.showItem = showItem
-- 		return sNode
-- 	end
-- )


local GushiItem = class("GushiItem", function(bagId,imgPath)
	local pNode = StateNode:create(2, bagId);
	return pNode;
end);

g_tConfigTable.CREATE_NEW(GushiItem)

-- 已经创建初步初始化完成
function GushiItem:ctor(...)
	self.m_imgPath = imgPath;
	if self.setLuaHandle == nil then
		self.scheduleInit =
			cc.Director:getInstance():getScheduler():scheduleScriptFunc(
			function()
				if self.scheduleInit then
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleInit)
					self.scheduleInit = nil
				end
				self:onSetHandle()
			end,
			0.5,
			false
		)
	else
		self:onSetHandle()
	end

	self:init()
end

function GushiItem:onSetHandle()
	if self.setLuaHandle == nil then
		return
	end
	self:setLuaHandle(
		function(sType, pInfo, pInfo2, pInfo3)
			if sType == "onClickItemState" then
				self:onClickItemState()
			elseif sType == "onStateChange" then
				self:onStateChange()
			elseif sType == "onDownloadProgress" then
				self:onDownloadProgress(pInfo)
			elseif sType == "onUnZipProgress" then
				self:onUnZipProgress(pInfo)
			elseif sType == "onDownloadNetError" then
				self:onDownloadNetError(pInfo)
			elseif sType == "onPopViewClick" then
				--第一个参数是 1=取消0=确认，第二个参数是那个弹窗
				self:onPopViewClick(pInfo, pInfo2)
			elseif sType == "longPressDeleteFinish" then --长按删除完成回调
				self:longPressDeleteFinish(pInfo)
			elseif sType == "onEnter" then
			elseif sType == "onExit" then
				self:onExit()
			elseif sType == "icon" then	
		    if pInfo == iconTryLoadType_NeiZhi or pInfo == iconTryLoadType_Had or pInfo == iconTryLoadType_NewDownload then
		    	local pTex = globalTryLoadImage(pInfo3)
		    	if pTex and self.cell_logo then
		    		self.cell_logo:setTexture(pTex)
		    	end
		    end
		end
		end
	)
end

function GushiItem:onEnter()
end

function GushiItem:onExit()
	if self.scheduleInit then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleInit)
		self.scheduleInit = nil
	end
	self:clearCallBack() -- 2018.8.31添加 。
end

function GushiItem:onClickItemState() --点击时候的回调
end

function GushiItem:onLongPressDel() --长按删除
	self:onLongPressDelete()
end

function GushiItem:longPressDeleteFinish(delState) --删除完成
	self:refreshShowItem(self.showItem)
	self:changeCellStatePic()
end

function GushiItem:onStateChange() --状态发生了改变
	self:changeCellStatePic()
end

function GushiItem:onDownloadProgress(percent) --下载进度
	self.bgProgress:setVisible(true)
	self.loadprogress:setVisible(true)
	self.loadprogress:setPercentage(percent * 0.8)
	if percent >= 100 then
		self:changeCellStatePic()
	end
end

function GushiItem:onUnZipProgress(percent) --解压进度
	self.bgProgress:setVisible(true)
	self.loadprogress:setVisible(true)
	self.loadprogress:setPercentage(percent * 0.2 + 80)
	if percent >= 100 then
		self:changeCellStatePic()
	end
end

function GushiItem:onDownloadNetError(netState) --下载过程错误
	self:changeCellStatePic()
end

function GushiItem:onPopViewClick(clickType, popView) --修复按钮，更新按钮，非WiFi信号 取消的回调
	if popView == UpdateView and clickType == 1 then -- 1是取消
		-- if DownloadManager:getInstance():isHaveDownloading() == false then
		self:goToPlay()
	-- end
	end
	self:changeCellStatePic()
end

function GushiItem:SCALE_1024(s)
	return ArmatureDataDeal:sharedDataDeal():transConver20_9Scale(s)
end

----------------------------------------------------------------------------------------------------------------------------------
function GushiItem:init()
	self.UI_SCALE_MULRIPLE_1920 = ArmatureDataDeal:sharedDataDeal():getUIItemScale_1920()
	self.UI_SCALE_MULRIPLE = ArmatureDataDeal:sharedDataDeal():getUIItemScale()
	self.nScale = self:SCALE_1024(self.UI_SCALE_MULRIPLE_1920 / 2)
	self.itemScale = self:SCALE_1024(self.UI_SCALE_MULRIPLE / 2)
	self.x_offset = self:SCALE_1024(10.0)
	self.y_offset = self:SCALE_1024(30.0)
end

----------------------------------------------------------------------------------------------------------------------------------
function GushiItem:onShowCellContent(showItem, cellSize, menuType, fType, topId, pParent, parent)
	self.showItem = showItem
	self.cellSize = cellSize
	self.menuType = menuType
	self.fType = fType
	self.topId = topId
	self.parent = parent
	self.pParent = pParent

	self.isHD = ArmatureDataDeal:sharedDataDeal():getIsHdScreen()
	self.HDScale = 1
	if self.isHD then
		self.HDScale = 1
	else
		self.HDScale = CFG_SCALE(0.5)
	end

	self:setContentSize(cellSize)
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setPosition(cc.p(cellSize.width / 2, cellSize.height / 2 + 19))

	if fType == 1 and self.topId == 1 then
		local topbg = self:createSprite(THEME_IMG("new2ji/folder/bg_zhi.png"), CFG_SCALE(1.0), cc.p(cellSize.width / 2, cellSize.height / 2 - CFG_SCALE(15)), cc.p(0.5, 0.5), self)
	end

	local unselectedBg = THEME_IMG("new2ji/folder/bg_common_top.png")
	local selectedBg = THEME_IMG("new2ji/folder/bg_common_top.png")
	if fType == 1 then
		if self.topId >= 1 and self.topId <= 3 then
			local ipath = "new2ji/folder/bg_icon_0" .. self.topId .. ".png"
			unselectedBg = THEME_IMG(ipath)
			selectedBg = THEME_IMG(ipath)
		end
	end

	local bg = ccui.Button:create(unselectedBg, selectedBg)
	bg:setSwallowTouches(true)
	bg:setAnchorPoint(cc.p(0.5, 0.5))
	bg:defaultSetting()
	bg:setZoomScale(0)
	bg:addTouchEventListener(
		function(ref, ntype)
			if ntype == ccui.TouchEventType.ended then
				self:onTouchEnd(bg)
			elseif ntype == ccui.TouchEventType.began then
				self:onTouchBegan(bg)
			elseif ntype == ccui.TouchEventType.canceled then
				self:onTouchCancel(bg)
			end
		end
	)
	bg:setScale(CFG_SCALE(1.0) * self.HDScale)
	bg:setPosition(cc.p(cellSize.width / 2, cellSize.height / 2))
	self:addChild(bg)

	self.cell_logo = nil
	local cell_pic_pos = cc.p(cellSize.width / 2, cellSize.height / 2)
	if self.cell_logo == nil then
		local scale = CFG_SCALE(0.43) * cellSize.width / CFG_SCALE(110)
		if self.topId >= 1 and self.topId <= 3 then
			--
			scale = scale*1.1
		end
		self.cell_logo = self:createSprite(THEME_IMG("new2ji/folder/defaultlogo.png"), scale, cell_pic_pos, cc.p(0.5, 0.5), self)
	end
	self:startTryLoadLogo()
	if fType == 1 then
		if self.topId ~= 1 then
			self.cellName_bg = cc.Scale9Sprite:create(THEME_IMG("new2ji/folder/bg_default.png"))
			self.cellName_bg:setContentSize(cc.size(CFG_SCALE(14) * #self.showItem.sBagName / 3 + CFG_SCALE(25), CFG_SCALE(24)))
			self.cellName_bg:setScaleY(self.HDScale)
			self.cellName_bg:setAnchorPoint(cc.p(0.5, 0.5))
			self.cellName_bg:setPosition(cc.p(cellSize.width / 2, -CFG_SCALE(4)))
			self:addChild(self.cellName_bg)
		else
			self.cellName_bg = cc.Sprite:create(THEME_IMG("new2ji/folder/bg_one.png"))
			self.cellName_bg:setScale(CFG_SCALE(0.43) * self.HDScale)
			self.cellName_bg:setAnchorPoint(cc.p(0.5, 0.5))
			self.cellName_bg:setPosition(cc.p(cellSize.width / 2, -CFG_SCALE(6)))
			self:addChild(self.cellName_bg)
		end
	end
	self.cell_name = cc.LabelTTF:create(self.showItem.sBagName, "Arial", 28)
	if fType == 0 or fType == 2 then
		self.cell_name:setColor(cc.c3b(76, 89, 112))
	end
	self.cell_name:setScale(0.5)
	self.cell_name:setAnchorPoint(cc.p(0.5, 0.5))
	self.cell_name:setPosition(cc.p(cellSize.width / 2, -CFG_SCALE(4)))
	self:addChild(self.cell_name)
	--上层遮罩
	if fType == 1 then
		if self.topId == 1 then
			--self.cell_ltop = self:createSprite(THEME_IMG("new2ji/folder/bg_common_top.png"), CFG_SCALE(1.22), cell_pic_pos, cc.p(0.5, 0.5), self)
		else
			--self.cell_ltop = self:createSprite(THEME_IMG("new2ji/folder/bg_common_top.png"), CFG_SCALE(1.0), cell_pic_pos, cc.p(0.5, 0.5), self)
		end
	else
		self.cell_ltop = self:createSprite(THEME_IMG("new2ji/folder/bg_common_top.png"), CFG_SCALE(1.0), cell_pic_pos, cc.p(0.5, 0.5), self)
	end

	--//获取当前下载状态的
	local state = self:getCurDownState()
	local downImg = ""
	self.download_start_pic = nil
	if state == UPDATE_START then
		downImg = THEME_IMG("new2ji/btn_gengxin.png")
	elseif state == REPAIR_START then
		downImg = THEME_IMG("new2ji/btn_xiufu.png")
	elseif state == ITEM_NOT_BUY then
		downImg = THEME_IMG("new2ji/btn_gouwuche.png")
	else
		downImg = THEME_IMG("new2ji/btn_xiazai.png")
	end
	local pos2 = cc.p(cellSize.width - CFG_SCALE(35), CFG_SCALE(10))
	self.download_start_pic = self:createSprite(downImg, CFG_SCALE(0.38), pos2, cc.p(0, 0), self)
	self.download_start_pic:setLocalZOrder(2)

	self.bgProgress, self.loadprogress = self:createProgress()
	self.bgProgress:setVisible(false)

	local downloading_picPos = cc.p(self.bgProgress:getContentSize().width / 2, self.bgProgress:getContentSize().height / 2)
	local dscale = 1.0
	if self.isHD then
		dscale = 1
	else
		dscale = 2
	end
	self.downloading_pic = self:createSprite(THEME_IMG("new2ji/msg_zhong.png"), dscale, downloading_picPos, cc.p(0.5, 0.5), self.bgProgress)
	self.downloading_pic:setLocalZOrder(6)

	self.download_wait_pic = self:createSprite(THEME_IMG("new2ji/msg_dengdai.png"), dscale, downloading_picPos, cc.p(0.5, 0.5), self.bgProgress)
	self.download_wait_pic:setLocalZOrder(6)

	if fType == 1 then
		local imagePath = THEME_IMG("new2ji/folder/default_0" .. self.topId .. ".png")
		if self.topId >= 1 and self.topId <= 3 then
			local qizi = self:createSprite(imagePath, CFG_SCALE(0.48), cc.p(-CFG_SCALE(5), cellSize.height+CFG_SCALE(10)), cc.p(0, 1), self)
		else
			local qizi = self:createSprite(imagePath, CFG_SCALE(0.48), cc.p(CFG_SCALE(5), cellSize.height - CFG_SCALE(8)), cc.p(0, 1), self)
		end
	end

	self.vipMarkLayer = VipMarkLayer:createSprite(1,self.nScale,"");
	self.vipMarkLayer:setPositionLua(30,20);
	self:addChild(self.vipMarkLayer,100);

	if(self.showItem == nil or self.showItem.nVipMark == 0) then
		self.vipMarkLayer:setVisible(false)
	end

	--修改状态显示
	self:changeCellStatePic()
end

----------------------------------------------------------------------------------------------------------------------------------
function GushiItem:createSprite(img, sca, pos, anchorPos, parentNode)
	local sp = cc.Sprite:create(img)
	if sp == nil then
		sp = cc.Sprite:create(THEME_IMG("new2ji/folder/defaultlogo.png"))
	end
	sp:setScale(sca * self.HDScale)
	sp:setPosition(pos)
	sp:setAnchorPoint(anchorPos)
	parentNode:addChild(sp)

	return sp
end


------------進度條----------------------------------------------------------------------------------------------------------------------
function GushiItem:createProgress()
	local bgProgress = cc.Sprite:create(THEME_IMG("new2ji/msg_bg.png"))
	bgProgress:setScale(CFG_SCALE(0.43) * self.HDScale)
	bgProgress:setPosition(cc.p(self.cellSize.width / 2 - 2, 0))

	self:addChild(bgProgress, 6)

	local Progress = cc.ProgressTimer:create(cc.Sprite:create(THEME_IMG("new2ji/msg_jindu.png")))
	Progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	Progress:setMidpoint(cc.p(0, 0))
	Progress:setBarChangeRate(cc.p(1, 0))
	Progress:setPosition(cc.p(bgProgress:getContentSize().width / 2, bgProgress:getContentSize().height / 2))
	Progress:setPercentage(0)

	bgProgress:addChild(Progress)
	return bgProgress, Progress
end

----------------------------------------------------------------------------------------------------------------------------------
function GushiItem:showVip()
end

------------------更改状态----------------------------------------------------------------------------------------------------------------
function GushiItem:changeCellStatePic()
	if not self.download_start_pic then
		return
	end

	local state = self:getCurDownState()
	--print(" =========changeCellStatePic ========= state=",state)
	if state == DOWNLOAD_START or state == UPDATE_START or state == REPAIR_START or state == ITEM_NOT_BUY then
		self.cell_name:setVisible(true)
		if self.fType == 1 then
			self.cellName_bg:setVisible(true)
		end
		self.download_start_pic:setVisible(true)
		self.downloading_pic:setVisible(false)
		self.download_wait_pic:setVisible(false)
		self.bgProgress:setVisible(false)
	elseif state == DOWNLOADING or state == UNZIPING then
		self.cell_name:setVisible(false)
		if self.fType == 1 then
			self.cellName_bg:setVisible(false)
		end
		self.download_start_pic:setVisible(false)
		self.downloading_pic:setVisible(true)
		self.download_wait_pic:setVisible(false)
		self.bgProgress:setVisible(true)
		self.loadprogress:setVisible(true)
		--修改图片文字
		local pTex = cc.Director:getInstance():getTextureCache():addImage(THEME_IMG("new2ji/msg_zhong.png"))
		--print("=========changeCellStatePic ========= state=",state,UNZIPING)

		if state == UNZIPING then
			pTex = cc.Director:getInstance():getTextureCache():addImage(THEME_IMG("new2ji/msg_zhong.png"))
		end
		self.downloading_pic:setTexture(pTex)
	elseif state == DOWNLOAD_WAIT then
		self.cell_name:setVisible(false)
		if self.fType == 1 then
			self.cellName_bg:setVisible(false)
		end
		self.download_start_pic:setVisible(false)
		self.downloading_pic:setVisible(false)
		self.download_wait_pic:setVisible(true)
		self.bgProgress:setVisible(true)
		self.loadprogress:setVisible(false)
	elseif state == DOWNLOAD_OK then
		self.cell_name:setVisible(true)
		if self.fType == 1 then
			self.cellName_bg:setVisible(true)
		end
		self.download_start_pic:setVisible(false)
		self.downloading_pic:setVisible(false)
		self.download_wait_pic:setVisible(false)
		self.bgProgress:setVisible(false)
		self.loadprogress:setVisible(false)
	end
	--print("self.showItem.vipResLeftTime ",self.showItem.nVipState,self.showItem.vipResLeftTime,Utils:GetInstance():checkIsVip())
	if self.showItem.nVipState ~= 0 and not Utils:GetInstance():checkIsVip() then
		self.download_start_pic:setScale(self.nScale * 0.65)
		if self.showItem.vipResLeftTime > 0 then
			self.download_start_pic:setVisible(false)
		else
			self.download_start_pic:setVisible(true)
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------
function GushiItem:refreshShowItem(showItem)
	self.showItem = showItem
	self:refreshShowItemInfo(showItem)
end

----------------------------------------------------------------------------------------------------------------------------------
function GushiItem:refeshShow(showItem)
	self.showItem = showItem
	self:startTryLoadLogo()
	local state = self:getCurDownState()
	local pTex_pic = nil
	if state == UPDATE_START then
		pTex_pic = cc.Director:getInstance():getTextureCache():addImage(THEME_IMG("new2ji/btn_gengxin.png"))
	elseif state == REPAIR_START then
		pTex_pic = cc.Director:getInstance():getTextureCache():addImage(THEME_IMG("new2ji/btn_xiufu.png"))
	elseif state == ITEM_NOT_BUY then
		pTex_pic = cc.Director:getInstance():getTextureCache():addImage(THEME_IMG("new2ji/btn_gouwuche.png"))
	else
		pTex_pic = cc.Director:getInstance():getTextureCache():addImage(THEME_IMG("new2ji/btn_xiazai.png"))
	end
	self.download_start_pic:setTexture(pTex_pic)
	self:changeCellStatePic()
	--修改状态显示
end

function GushiItem:OnTouchClick() --点击
	playNormalBtnSound() --平常的点击按钮
	
	self.pParent:sendbaiduTongji(self.showItem.bagId)--发送百度统计
	if self.fType == 1 then
		self.pParent:sendDisbaiduTongji(self.showItem.bagId,"top")
	elseif self.fType == 2 then
		self.pParent:sendDisbaiduTongji(self.showItem.bagId,"folder")
	else
		self.pParent:sendDisbaiduTongji(self.showItem.bagId,"jihe")
	end

	local state = self:getCurDownState()
	if state == DOWNLOAD_OK then
		self:goToPlay()
	-- elseif state == ITEM_NOT_BUY then
	-- 	XueTangDataAdapter:getInstance():setPlayContentInfo("tuijian", self.showItem.bagId)

	-- 	local isOld = false
	-- 	if self.showItem.coin < 0 then
	-- 		if self.showItem.bagId == "3" or self.showItem.bagId == "8" or self.showItem.bagId == "6" then
	-- 			isOld = true
	-- 		end
	-- 	elseif self.showItem.coin == 0 then
	-- 		isOld = true
	-- 	end
	-- 	if isOld or not Utils:GetInstance():startShowCoinBuyView(math.abs(tonumber(self.showItem.coin)), MENU_TYPE_XUETANG, self.showItem.bagId) then
	-- 		local mapId = self.pParent:getXueTangMapId(self.showItem.bagId)
	-- 		XueTangDataAdapter:getInstance().m_buyType = 2
	-- 		CustomEventDispatcher:getInstance():msgBroadcastLua(CustomEventTypes.CE_XT_GOTO_CONTENT, self.showItem) --播放语音的消息
	-- 		CustomEventDispatcher:getInstance():msgBroadcast(CE_OPEN_XT_BUYDISLOG, 0, 2, mapId)
	-- 	else
	-- 		XueTangDataAdapter:getInstance().m_buyType = 1
	-- 	end
	else
		self:onClickItem()
	end

	local serverTime = UInfoUtil:getInstance():getServerTime();
	IMenuDataAdapter:getInstance():updateLastTouchBagId(self.menuType, self.showItem.bagId)
	IMenuDataAdapter:getInstance():setOneContentHadPlay(self.menuType, self.showItem.bagId, serverTime) -- 8.4.2 按照降序，客户端来计算时间
end
----------------------------------------------------------------------------------------------------------------------------------
--点击开始
function GushiItem:onTouchBegan(bg)
	self:onHighlight()
	self.isLongTouch = false
	local function callback()
		self.isLongTouch = true
		self.longAct = nil
		--长按
		self:onLongPress()
	end
	self.longAct = performWithDelay(self, callback, 2.0)
end
----------------------------------------------------------------------------------------------------------------------------------
--点击结束
function GushiItem:onTouchEnd(bg)
	self:onUnHighlight()
	if self.isLongTouch == false then
		SimpleAudioEngine:getInstance():playEffect(UISOUND_A_BTN)
		self:OnTouchClick()
		--点击状态
		if self.longAct then
			self:stopAction(self.longAct)
			self.longAct = nil
		end
	end
end
----------------------------------------------------------------------------------------------------------------------------------
--点击取消
function GushiItem:onTouchCancel(bg)
	self:onUnHighlight()
	if self.isLongTouch == false then
		SimpleAudioEngine:getInstance():playEffect(UISOUND_A_BTN)
		--点击状态
		if self.longAct then
			self:stopAction(self.longAct)
			self.longAct = nil
		end
	end
end
----------------------------------------------------------------------------------------------------------------------------------
--高亮
function GushiItem:onHighlight()
	self:stopAllActions()
	local act = cc.ScaleTo:create(0.05, 0.9)
	self:runAction(act)
end

----------------------------------------------------------------------------------------------------------------------------------
--取消高亮
function GushiItem:onUnHighlight()
	self:stopAllActions()
	local act = cc.ScaleTo:create(0.05, 1.0)
	self:runAction(act)
end

----------------------------------------------------------------------------------------------------------------------------------
--长按删除的
function GushiItem:onLongPress()
	self:onLongPressDelete()
end
----------------------------------------------------------------------------------------------------------------------------------
function GushiItem:changeState()
end

----------------------------------------------------------------------------------------------------------------------------------
function GushiItem:changeSp()
end

function GushiItem:goToPlay()
	-- h5节点或文件夹类型
	if self.fType == 0 or self.fType == 2 then
		--找到所属的父文件夹包id
		local pBagId = self.pParent:getFolderBagId(self.showItem.bagId)
		if pBagId then
			MenuItemNetData:getInstance():setPackageSortValueWithTime(self.menuType, pBagId)
		end
	end
	XueTangDataAdapter:getInstance():setWillPlayGame(true)
	HomeUILayer:getCurInstance():getNormalUIItem():stopAndSetToXBLvision()
	CustomEventDispatcher:getInstance():msgBroadcast(CE_GOTO_CONTENT, self.menuType, 0, self.showItem.bagId)
	self.parent:removeFromParent()
	self.pParent:savePlayBagJson(self.showItem.bagId)
	self.pParent:playEffectByClose(true)
end
----------------------------------------------------------------------------------------------------------------------------------
--检查是否 显示 下载
function GushiItem:checkLoading()
	local netState = DownloadManager:getInstance():getMyNetState()
	-- 0 = 无网络 1=是wifi, 2= 手机网络 ，非WiFi
	if netState == 0 then
		-- end
		-- if not self.subMenu.isShowDownloadError  then
		--    self.subMenu.isShowDownloadError = true
		self:runAction(
			cc.Sequence:create(
				cc.DelayTime:create(1),
				cc.CallFunc:create(
					function()
						showTipsErji("网络较差，请检查网络设置", self.menuType)
					end
				)
			)
		)
	end
end

return GushiItem
