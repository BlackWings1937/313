local ContentItem = class("ContentItem", function(menuType,bagId,imgPath)
	local pNode = StateNode:create(menuType, bagId);
	return pNode;
end);

-- 重写New方法
ContentItem.new = function(...)
    local instance
    if ContentItem.__create then
        instance = ContentItem.__create(...)
    else
        instance = {}
    end

    for k, v in pairs(ContentItem) do instance[k] = v end
    instance.class = ContentItem
    instance:ctor(...);
    return instance
end

local XT_TAG_BG = 100
local XT_CELL_ICON = 101
local XT_CELL_PROGRESS_BG_TAG = 102
local XT_CELL_PROGRESS_LOAD_TAG = 103
local XT_CELL_PROGRESS_WORD_TAG = 104
local XT_CELL_NAME = 105

local TargetBagList = {187,255,169}

-- 已经创建初步初始化完成
function ContentItem:ctor(menuType,bagId,imgPath)
	self.m_imgPath = imgPath;
	self.m_offsetXY = cc.size(self:SCALE_1024(0.0), 0.0);
	self.uiScale = self:SCALE_1024(UI_SCALE_MULRIPLE_1920);
	self.isHD = ArmatureDataDeal:sharedDataDeal():getIsHdScreen()

	self.m_downPercent = 0;
	self.m_unzipPercent = 0;

	self.m_bagId = 0
	self.m_menuType = menuType
	self.m_isLock = false
	self.mainLayer = nil;
	self.copyItem = nil;
	self.isLongTouch = false--是否是长按
	self.isScrolling = false--外面是否在滚动
	
	self.longAction = nil
	self.isTouchEnd = false;

	if self.setLuaHandle == nil then
		self.scheduleInit = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
	  		if self.scheduleInit then
				cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleInit)
				self.scheduleInit = nil
			end
			self:initLuaHandle()
		end, 0.5, false)
	else
		self:initLuaHandle()
	end
end

function ContentItem:onEnter()

end

function ContentItem:onExit()
     if self.scheduleInit then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.scheduleInit)
		self.scheduleInit = nil
	end
	if(self.clearCallBack ~= nil) then
		self:clearCallBack();  -- 2018.8.31添加 。
	end
end

function ContentItem:initLuaHandle()
    if self.setLuaHandle == nil then
       return 
	end 
 	self:setLuaHandle(function(sType, pInfo, pInfo2)
		if sType == "onEnter" then
			self:onEnter();
		elseif sType == "onExit" then
			self:onExit();
		elseif sType == "onStateChange" then
			self:refreshData();
			self:onStateChangeLua()
		elseif sType == "onDownloadProgress" then
			self:onDownloadProgressLua(pInfo)
		elseif sType == "onUnZipProgress" then
			self:onUnZipProgressLua(pInfo)
		elseif sType == "onDownloadNetError" then
			self:onDownloadNetErrorLua(pInfo)
		elseif sType == "onPopViewClick" then
			self:onPopViewClickLua(pInfo, pInfo2)
		elseif sType == "longPressDeleteFinish" then
			self:refreshShowItem()
		end
	end);
end

function ContentItem:onStateChangeLua() --状态发生了改变
	self:changeDownLoadStateLua();
end	

function ContentItem:onDownloadProgressLua(percent)
	-- body
	self.m_downPercent = percent;
	self:changeDownLoadStateLua();
end

function ContentItem:onUnZipProgressLua(percent)
	-- body
	self.m_downPercent = 100;
	self.m_unzipPercent = percent;
	self:changeDownLoadStateLua();
end

function ContentItem:onDownloadNetErrorLua(onState)
	-- body
end

function ContentItem:onPopViewClickLua(clickType,popView)--修复按钮，更新按钮，非WiFi信号 取消的回调
	if popView == UpdateView and clickType == 1  then
		self:goToPlay();
	end
	self:changeDownLoadStateLua()
end

function ContentItem:refreshData()
	local datastr = self:getMenuDataForLua();
	if datastr and datastr ~= "" then
		self.m_itemInfo = json.decode(datastr);
	else
		self.m_itemInfo = nil;
	end
end

function ContentItem:SCALE_1024(value)
	return ArmatureDataDeal:sharedDataDeal():transConver20_9Scale(value);
end

function ContentItem:CFG_SCALE(value)
	return ArmatureDataDeal:sharedDataDeal():transConfigScale(value, -1);
end

function ContentItem:createLable(str,pos,anchorPos,parentNode)
    local shadowLabelOutline = cc.Label:createWithSystemFont(str,"Arial",20)
    shadowLabelOutline:setPosition(pos)
    shadowLabelOutline:setAnchorPoint(anchorPos)
    shadowLabelOutline:setTextColor(cc.c4b(0, 0, 0, 255))
    parentNode:addChild(shadowLabelOutline)
    
    return shadowLabelOutline
end

function ContentItem:createItem(iconName,titleName,isLock)
	self.m_isLock = isLock
	self:refreshData();
	if type(self.m_itemInfo) ~= "table" then
		return;
	end

	local itemSize = cc.size(220,330)
	local posX = itemSize.width*0.5;
	local bgScaleSize = itemSize;
	self:setContentSize(bgScaleSize);

	local imgPath = self.m_imgPath;
	local itemInfo = self.m_itemInfo;

	local itemPath = THEME_IMG("transparent.png")--imgPath.."temp.png"--
	local bg = ccui.Button:create(itemPath,itemPath);
	bg:setSwallowTouches(false);
	bg:setTag(XT_TAG_BG);
	bg:setAnchorPoint(cc.p(0.5, 0));
	bg:setZoomScale(0)
	bg:setPosition(cc.p(posX, 0));
	bg:addTouchEventListener(function(sender, ntype)
		if ntype == ccui.TouchEventType.began then
			local arr = {}
			table.insert(arr,cc.DelayTime:create(2))
			table.insert(arr,cc.CallFunc:create(function() 
				self.longAction = nil
				self.isTouchEnd = false;
				self:onLongPress()
			end))
			self.isTouchEnd = true;
			self.longAction = cc.Sequence:create(arr)
			sender:runAction(self.longAction)
			self:onHighlight()
		elseif ntype == ccui.TouchEventType.moved then
			if(math.abs(sender:getTouchMovePosition().x-sender:getTouchBeganPosition().x) >= 60 or 
			   math.abs(sender:getTouchMovePosition().y-sender:getTouchBeganPosition().y) >= 60) then
				if(self.longAction) then
					sender:stopAction(self.longAction)
					self.longAction = nil
				end
			end
		elseif ntype == ccui.TouchEventType.ended then
			self:onUnHighlight()
			if(self.longAction) then
				sender:stopAction(self.longAction)
				self.longAction = nil
			end
			if(math.abs(sender:getTouchEndPosition().x-sender:getTouchBeganPosition().x) <= 20 and 
			   math.abs(sender:getTouchEndPosition().y-sender:getTouchBeganPosition().y) <= 20) then
				if(self.isTouchEnd) then
					SimpleAudioEngine:getInstance():playEffect(UISOUND_A_BTN)
					self:onClickContent()
				end
			end
		elseif ntype == ccui.TouchEventType.canceled then
			self:onUnHighlight()
			if(self.longAction) then
				sender:stopAction(self.longAction)
				self.longAction = nil
			end
		end
    end)
	self:addChild(bg, 0);

	if ArmatureDataDeal:sharedDataDeal():getIsHdScreen() then 
		bg:setScale(itemSize.width/8);
	else
		bg:setScale(itemSize.width/16);
    end

	-- local gui_title_di_sprite = cc.Sprite:create(imgPath.."gui_title_di.png");
	-- gui_title_di_sprite:setAnchorPoint(cc.p(1, 0));
	-- gui_title_di_sprite:setPosition(cc.p(itemSize.width,5))
	-- self:addChild(gui_title_di_sprite, 6);

	local iconSprite = cc.Sprite:create(imgPath..iconName)
	iconSprite:setAnchorPoint(cc.p(0.5,0.5))
	iconSprite:setPosition(cc.p(itemSize.width*0.5,itemSize.height*0.5));
	self:addChild(iconSprite,10)

	local nameSprite = cc.Sprite:create(imgPath..titleName)
	nameSprite:setAnchorPoint(cc.p(0.5,0.5))
	nameSprite:setPosition(cc.p(itemSize.width*0.5 + 13,31));
	nameSprite:setTag(XT_CELL_NAME)
	self:addChild(nameSprite,10)

	local sIcon = cc.Sprite:create(imgPath.."gui_xiazai.png");
	if(sIcon == nil) then
		sIcon = cc.Sprite:create(THEME_IMG("second/common/needpay.png"));
	end
	sIcon:setVisible(false)
	sIcon:setTag(XT_CELL_ICON);
	sIcon:setAnchorPoint(cc.p(0.5,0.5))
	sIcon:setPosition(cc.p(-300,0));
	self:addChild(sIcon, 7);
	
	local loadProgress = self:createDownLoadLayer();
	loadProgress:setPosition(cc.p(itemSize.width,5))
	self:addChild(loadProgress, 6);
	
	-- self.bgWaterProgress = self:createWaterProgress(self)
	-- self.bgWaterProgress:setVisible(false)

	self:updateIcon();
end



-- function ContentItem:createWaterProgress( parent )
-- 	-- 创建水动画
-- 	self._startY = 20.0/UI_SCALE_MULRIPLE()
-- 	local size = parent:getContentSize()
-- 	local sp = addWaterEffect(THEME_IMG("new2ji/default_0.png"),size,self._startY)
-- 	sp:setPosition(cc.p(size.width*0.5,size.height*0.5))
-- 	parent:addChild(sp, 1000)
-- 	--
-- 	return sp
-- end


-- function ContentItem:isWaterPlaying( ... )
-- 	-- tablleview会滑动停止cell中的actions
-- 	local sp = self.bgWaterProgress._child
-- 	local isShow = self.bgWaterProgress:isVisible()
-- 	if sp and isShow then
-- 		-- 重新恢复动作,以及重新的位置更新
-- 		local ac = sp:getActionByTag(-9909987)
-- 		if not ac then
-- 			--
-- 			local cloneAnim = CreateSpriteFrameAnim("gui_iconloading_%03d.png",14)
-- 			ac = cc.RepeatForever:create(cloneAnim)
-- 			ac:setTag(-9909987)
-- 			sp:runAction(ac)
-- 		end
-- 	end
-- end


function ContentItem:updateWaterProgress( percent )
	-- 更新水动画进度条
	--print("updateWaterProgress",percent,self:getCurMenuShowItem().bagId,self:getCurMenuShowItem().state)
	local sp = self.bgWaterProgress._child
	local maxH = self.bgWaterProgress._maxHeight
	local srcPy = self.bgWaterProgress._srcPy
	--CC_GameLog(percent,"ieiwoowoeieiiwieieie")
	if sp and maxH and srcPy then
		-- 防止初始化的时候就看得到一点水动画
		--percent = 0
		local per = maxH*percent/100
		if per < self._startY then
			per = self._startY
		end
		sp:setPositionY(srcPy+per)
	end
end


function ContentItem:createDownLoadLayer()
	-- 进度条
	local imgPath = self.m_imgPath
	local pDownloadProgress = cc.Sprite:create(self.m_imgPath.."gui_title_di.png");
	if(pDownloadProgress == nil) then
		pDownloadProgress = cc.Sprite:create(THEME_IMG("second/common/progressbg.png"));
	end
	pDownloadProgress:setAnchorPoint(cc.p(1, 0));
	pDownloadProgress:setTag(XT_CELL_PROGRESS_BG_TAG);
	pDownloadProgress:setVisible(false);

	-- 下载中。
	local fontSize = 40;
	local px = pDownloadProgress:getContentSize().width*0.5;
	local py = pDownloadProgress:getContentSize().height*0.5
	local pLbDownload = cc.Label:createWithSystemFont("下载中", "", fontSize);
	pLbDownload:setTag(XT_CELL_PROGRESS_LOAD_TAG);
	pLbDownload:setColor(cc.c3b(255, 255, 255));
	pLbDownload:setPosition(cc.p(px,py));
	pDownloadProgress:addChild(pLbDownload, 3);

	local spriteprogress = cc.Sprite:create(self.m_imgPath.."xiazai_wancheng.png");
	if(spriteprogress == nil) then
		spriteprogress = cc.Sprite:create(THEME_IMG("second/common/progressbar.png"));
	end
	local pLoadprogress = cc.ProgressTimer:create(spriteprogress);
	pLoadprogress:setTag(XT_CELL_PROGRESS_WORD_TAG);
	pLoadprogress:setType(cc.PROGRESS_TIMER_TYPE_BAR);
	pLoadprogress:setMidpoint(cc.p(0, 0));
	pLoadprogress:setBarChangeRate(cc.p(1, 0));
	pLoadprogress:setAnchorPoint(cc.p(0.5,0.5));
	pLoadprogress:setPosition(cc.p(px,py));
	pLoadprogress:setPercentage(50);

	pDownloadProgress:addChild(pLoadprogress, 2);

	return pDownloadProgress;
end

function ContentItem:updateIcon()
	if type(self.m_itemInfo) ~= "table" then
		return;
	end

	local sIcon = self:getChildByTag(XT_CELL_ICON);
	if not sIcon then
		return;
	end

	local imgPath = self.m_imgPath;
	local itemInfo = self.m_itemInfo;	
	sIcon:setVisible(true);
	if itemInfo.state == ITEM_NOT_BUY then --未购买
		sIcon:setTexture(cc.Director:getInstance():getTextureCache():addImage(imgPath.."btn_xiazai.png"));
	elseif itemInfo.state == DOWNLOAD_START then --未下载
		sIcon:setTexture(cc.Director:getInstance():getTextureCache():addImage(imgPath.."btn_xiazai.png"));
	elseif itemInfo.state == UPDATE_START then --更新
		sIcon:setTexture(cc.Director:getInstance():getTextureCache():addImage(imgPath.."btn_gengxin.png"));
	elseif itemInfo.state == REPAIR_START then --需要修复
		sIcon:setTexture(cc.Director:getInstance():getTextureCache():addImage(imgPath.."btn_xiufu.png"));
	else
		local nameSprite = self:getChildByTag(XT_CELL_NAME);
		if(nameSprite ~= nil) then
			nameSprite:setPositionX(110)
		end
		sIcon:setVisible(false);
	end

	if(self.copyItem) then
		self.copyItem:updateIcon(itemInfo);
	end

	-- if(self.mainLayer) then
	-- 	self.mainLayer:hideIcon(itemInfo)
	-- end
end

function ContentItem:changeDownLoadStateLua()
	local itemInfo = self:getCurMenuShowItem();
	if itemInfo == nil then
		return;
	end

	local pDownloadProgress = self:getChildByTag(XT_CELL_PROGRESS_BG_TAG);
	if pDownloadProgress == nil then
		return;
	end

	local pLbDownload = pDownloadProgress:getChildByTag(XT_CELL_PROGRESS_LOAD_TAG);
	local pLoadprogress = pDownloadProgress:getChildByTag(XT_CELL_PROGRESS_WORD_TAG);
	if itemInfo.state == DOWNLOAD_OK then
		self.m_downPercent = 0;
		self.m_unzipPercent = 0;
		pDownloadProgress:setVisible(false);
	elseif itemInfo.state == DOWNLOAD_WAIT then
		pDownloadProgress:setVisible(true);
		pLbDownload:setString("等待中");
		pLoadprogress:setPercentage(0);
	elseif itemInfo.state == DOWNLOADING or itemInfo.state == UNZIPING then
		pDownloadProgress:setVisible(true);
		local progressValue = (self.m_downPercent * 80 + self.m_unzipPercent * 20) / 100;
		pLoadprogress:setPercentage(progressValue);
		if progressValue >= 100 then
			pDownloadProgress:setVisible(false);
		elseif progressValue < 80 and progressValue > 0 then
			pLbDownload:setString("下载中");
		elseif progressValue >= 80 and progressValue < 100 then
			pLbDownload:setString("下载中");
		else
			pLbDownload:setString("等待中");
		end
	elseif itemInfo.state == REPAIR_START or itemInfo.state == DOWNLOAD_START or itemInfo.state == UPDATE_START or itemInfo.state == ITEM_NOT_BUY then
		pDownloadProgress:setVisible(false);
	end
	-- local state = itemInfo.state
	-- if state == DOWNLOAD_START or state == UPDATE_START or state == REPAIR_START or state == ITEM_NOT_BUY then
	-- 	-- self.bgWaterProgress:setVisible(false)
	-- 	self.bgProgress:setVisible(true)
	-- 	self.loadprogress:setVisible(true)
	-- elseif  state == DOWNLOADING  or  state == UNZIPING then
	-- 	self.bgWaterProgress:setVisible(true)
	-- 	local progressValue = (self.m_downPercent * 80 + self.m_unzipPercent * 20) / 100;
	-- 	self:updateWaterProgress(progressValue)
	-- 	-- if state == DOWNLOADING then
	-- 	-- 	--
	-- 	-- 	local per = self.m_downPercent 
	-- 	-- 	self:updateWaterProgress(per*0.8)
	-- 	-- else
	-- 	-- 	local per = self.m_unzipPercent*100
	-- 	-- 	self:updateWaterProgress(per*0.2+80)
	-- 	-- end
	-- elseif  state == DOWNLOAD_WAIT then
	-- 	self.bgWaterProgress:setVisible(true)
	-- 	self:updateWaterProgress(0)
	-- elseif state == DOWNLOAD_OK then
	-- 	self.m_downPercent = 0;
	-- 	self.m_unzipPercent = 0;
	-- 	self.bgWaterProgress:setVisible(false)
	-- end

	local nameSprite = self:getChildByTag(XT_CELL_NAME);
	if(nameSprite) then
		if(itemInfo.state == DOWNLOAD_WAIT or 
		   itemInfo.state == DOWNLOADING or 
		   itemInfo.state == UNZIPING) then
			nameSprite:setVisible(false)
		else
			nameSprite:setVisible(true)
		end
	end

	if(self.copyItem) then
		self.copyItem:changeDownLoadStateLua(itemInfo,self.m_downPercent,self.m_unzipPercent);
	end

	-- -- 处理水波纹因为滑动导致的停止
	-- self:isWaterPlaying()

	self:updateIcon(itemInfo);
end

--返回bagIndex
function ContentItem:getBagIndex(bagId)
	for i,v in ipairs(TargetBagList) do
		if tonumber(bagId) == tonumber(v) then
			return i
		end
	end
end


function ContentItem:onClickContent()
	dump(self.m_itemInfo)
	if type(self.m_itemInfo) ~= "table" then
		return;
	end
	-- if(self.mainLayer ~= nil and self.mainLayer:isPlaying() and  self.m_itemInfo.state ~= DOWNLOAD_OK) then --下載OK，跳過
	-- 	return
	-- end

	local bagIndex = self:getBagIndex(self.m_itemInfo.bagId)

	-- if(self.mainLayer ~= nil and self.m_isLock) then
	-- 	self.mainLayer:playLockAnim()
	-- 	Utils:GetInstance():baiduTongji("xialingying","xmas19_tast"..bagIndex.."_undone")
	-- 	return;
	-- end
	SimpleAudioEngine:getInstance():playEffect("allaudios/animationSound/ui001.mp3")
	if XueTangDataAdapter:getInstance():isWillPlayGame() then
		return;
	end
	self:refreshData();
	--Utils:GetInstance():baiduTongji("xialingying","click_bagId")--tong ji
	--Utils:GetInstance():baiduTongji("xialingying","click_bagId_"..self.m_itemInfo.eMenuType.."_"..self.m_itemInfo.bagId)--tong ji


	if self.m_itemInfo.state == ITEM_NOT_BUY then
		
	elseif self.m_itemInfo.state == DOWNLOAD_OK then
		local bagInt=DownloadManager:getInstance():getMenuStatus(self.m_itemInfo.eMenuType, self.m_itemInfo.bagId)
		print("返回状态",bagInt)
		if DownloadManager:getInstance():getMenuStatus(self.m_itemInfo.eMenuType, self.m_itemInfo.bagId) == 0 then
			print("可开始玩了哈")
			self:goToPlay()
			-- Utils:GetInstance():baiduTongji("xialingying","xmas19_tast"..bagIndex.."_done")
			-- self.mainLayer:reMoveNotice()
		end
	else
		if self.m_itemInfo.state ~= DOWNLOADING and self.m_itemInfo.state ~= DOWNLOAD_WAIT then
			self.m_downPercent = 0;
			self.m_unzipPercent = 0;
		end
		if(self.mainLayer ~= nil) then
			CC_GameLog("eiwiwodkklalsdkdkkdkfjaskljeiiwoisalskdk")
			-- self.mainLayer:reMoveNotice()
			-- self.mainLayer:playFreeDownAnim();
		end
		-- Utils:GetInstance():baiduTongji("xialingying","xmas19_tast"..bagIndex.."_undone")
		self:onClickItem();
	end
end

function ContentItem:autoClickContent()
	if type(self.m_itemInfo) ~= "table" then
		return;
	end
	
	if XueTangDataAdapter:getInstance():isWillPlayGame() then
		return;
	end
	self:refreshData();

	if self.m_itemInfo.state == ITEM_NOT_BUY then
	elseif self.m_itemInfo.state == DOWNLOAD_OK then
	else
		if self.m_itemInfo.state ~= DOWNLOADING and self.m_itemInfo.state ~= DOWNLOAD_WAIT then
			self.m_downPercent = 0;
			self.m_unzipPercent = 0;
		end
		self:setIsShowRepairView(false)
		self:setIsShowUpdateView(false)
		self:onClickItem();
	end
end

function ContentItem:goToPlay()
	XueTangDataAdapter:getInstance():setWillPlayGame(true);
	if self.setIsAutoStopDownLoad then
		self:setIsAutoStopDownLoad(true);
	end
	print("ContentItem:goToPlay()")
	if(self.mainLayer ~= nil) then	
		CC_GameLog(self.copyItem.m_bagId,"ieiowowwwwwwwwwwwwwwwwwwwwwwweiieiei",self.copyItem.eMenuType)
		-- self.mainLayer:gotoTargetBagId(self.m_itemInfo.eMenuType,self.copyItem.m_bagId);	
		xblStaticData:gotoSourceKeepFrom(9, 9, self.copyItem.m_bagId, self.m_itemInfo.eMenuType, 310)
	end
end  

function ContentItem:refreshShowItem()
	if type(self.m_itemInfo) ~= "table" then
		return;
	end
	local msi = IMenuDataAdapter:getInstance():getMenuShowItemByInfo(self.m_itemInfo.eMenuType, self.m_itemInfo.bagId);
	if(msi == nil) then
		msi = MenuItemNetData:getInstance():getOneMenuShowItem(self.m_itemInfo.eMenuType,self.m_itemInfo.bagId);
	end
	self.showItem = msi
	if(msi ~= nil) then
		IMenuDataAdapter:getInstance():changeMenuItemState(msi);
		self:refreshShowItemInfo(msi)
		self:refreshData();
		self:changeDownLoadStateLua();
	end
end

function ContentItem:isDownIng()
	if self.m_itemInfo.state == DOWNLOADING or 
	   self.m_itemInfo.state == DOWNLOAD_WAIT then
		return true;
	else
		return false;
	end
end

function ContentItem:onLongPress()
	if XueTangDataAdapter:getInstance():isWillPlayGame() then
		return
	end
	if self.onLongPressDelete then
		self:onLongPressDelete()
	end
end

--高亮
function ContentItem:onHighlight()
    self:stopAllActions()
  	local act = cc.ScaleTo:create(0.05,0.9)
    self:runAction(act)
end

--取消高亮
function ContentItem:onUnHighlight()
    self:stopAllActions()
    local act = cc.ScaleTo:create(0.05,1.0)
    self:runAction(act)
end

return ContentItem