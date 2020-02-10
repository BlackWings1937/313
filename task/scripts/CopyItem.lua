-- 重写New方法
local CopyItem = class("CopyItem", function()
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

CopyItem.new = function(...)
    local instance
    if CopyItem.__create then
        instance = CopyItem.__create(...)
    else
        instance = {}
    end

    for k, v in pairs(CopyItem) do instance[k] = v end
    instance.class = CopyItem
    instance:ctor(...);
    return instance
end

local XT_TAG_BG = 100
local XT_CELL_ICON = 101
local XT_CELL_PROGRESS_BG_TAG = 102
local XT_CELL_PROGRESS_LOAD_TAG = 103
local XT_CELL_PROGRESS_WORD_TAG = 104
local XT_CELL_NAME = 105
local XT_CELL_IMAGE = 106
local XT_CELL_BGNAME = 107
local XT_CELL_IX = 108


-- 已经创建初步初始化完成
function CopyItem:ctor(bagId,imgPath)
	self.m_imgPath = imgPath;
	self.isHD = ArmatureDataDeal:sharedDataDeal():getIsHdScreen()

	self.m_bagId = bagId
	self.m_isLock = false
	self.mainLayer = nil;
	self.nodeItem = nil

	self.longAction = nil
	self.isTouchEnd = false;
end

function CopyItem:createLable(str,pos,anchorPos,parentNode)
    local shadowLabelOutline = cc.Label:createWithSystemFont(str,"Arial",20)
    shadowLabelOutline:setPosition(pos)
    shadowLabelOutline:setAnchorPoint(anchorPos)
    shadowLabelOutline:setTextColor(cc.c4b(0, 0, 0, 255))
    parentNode:addChild(shadowLabelOutline)
    
    return shadowLabelOutline
end



function CopyItem:createItem(bgName,iconName,titleName,riqiName,isLock,isNotPlay)
	self.m_isLock = isLock

	CC_GameLog("dkdklslaieiiekslskdk")
	local itemSize = cc.size(220*0.472,220*0.472)
	local posX = itemSize.width*0.5;
	local bgScaleSize = itemSize;
	self:setContentSize(bgScaleSize);

	-- self.colorLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 255));
	-- self.colorLayer:setContentSize(cc.size(100, 100));

	-- self.colorLayer:ignoreAnchorPointForPosition(false)
	-- self.colorLayer:setPosition(cc.p(55, 60));
	-- self:addChild(self.colorLayer)

	local imgPath = self.m_imgPath;
	local itemInfo = self.m_itemInfo;

	self.ScaleMultiple = 0.427--ArmatureDataDeal:sharedDataDeal():getUIItemScale_1024_1920() * 0.8
    if ArmatureDataDeal:sharedDataDeal():getIsHdScreen() == false then
		self.ScaleMultiple = self.ScaleMultiple * 2
	end

	local lockSprite = nil
	if(self.m_isLock) then
		-- lockSprite = TouchArmature:create("20191128ge_suo", TOUCHARMATURE_NORMAL);	
		-- lockSprite:setPosition(cc.p(itemSize.width*0.5,itemSize.height*0.5 + 10));
		-- lockSprite:playByIndex(0,LOOP_YES);
		-- lockSprite:setScale(self.ScaleMultiple)
		-- self:addChild(lockSprite,10);
	end

	local itemPath = THEME_IMG("transparent.png")--imgPath.."temp.png"--
	local bg = ccui.Button:create(itemPath,itemPath);
	bg:setSwallowTouches(false);
	bg:setTag(XT_TAG_BG);
	bg:setAnchorPoint(cc.p(0.5, 0));
	bg:setZoomScale(0)
	bg:setPosition(cc.p(posX, 0));

	-- self.colorLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 255));
	-- self.colorLayer:setContentSize(cc.size(100, 100));

	-- self.colorLayer:ignoreAnchorPointForPosition(false)
	-- self.colorLayer:setPosition(cc.p(55, 60));
	-- bg:addChild(self.colorLayer)

	bg:addTouchEventListener(function(sender, ntype)
		if ntype == ccui.TouchEventType.began then
			CC_GameLog("eiielskkdlkalsalkfkjfjfkskslkslkkdkdk")
			local arr = {}
			table.insert(arr,cc.DelayTime:create(2))
			table.insert(arr,cc.CallFunc:create(function() 
				self.longAction = nil
				self.isTouchEnd = false;
				self.nodeItem:onLongPress()
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
					if(self.m_isLock) then
						if(lockSprite) then
							lockSprite:playByIndex(1,LOOP_NO);
							lockSprite:setLuaCallBack(function(eType, pTouchArm, sEvent)
								if eType == TouchArmLuaStatus_AnimEnd then
									lockSprite:playByIndex(0,LOOP_NO);
								end
							end)
						end
						-- if(self.mainLayer and self.mainLayer:isPlaying() == false) then
						-- 	self.mainLayer:playLockAnim()
						-- end
					else
						print("ssssssssssssssssssssssssssssssssssssssssssssssss")
						if self.nodeItem:isDownIng() == false then
							self.nodeItem.copyItem = self;
						end
						self.nodeItem:onClickContent()
					end
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

	local bgImgSprite = cc.Sprite:create(imgPath..bgName)
	bgImgSprite:setTag(XT_CELL_IMAGE)
	bgImgSprite:setScale(self.ScaleMultiple)
	bgImgSprite:setAnchorPoint(cc.p(0.5,0.5))
	bgImgSprite:setPosition(cc.p(itemSize.width*0.5,itemSize.height*0.5 + 10));
	self:addChild(bgImgSprite,6)

	local iconSprite = cc.Sprite:create(imgPath..iconName)
	iconSprite:setTag(XT_CELL_IX)
	iconSprite:setScale(self.ScaleMultiple)
	iconSprite:setAnchorPoint(cc.p(0.5,0.5))
	iconSprite:setPosition(cc.p(itemSize.width*0.5,itemSize.height*0.5 + 10));
	self:addChild(iconSprite,6)

	-- local nameSprite = nil
	-- if(self.m_isLock) then
	-- 	nameSprite = cc.Sprite:create(imgPath..riqiName)
	-- else
	-- 	nameSprite = cc.Sprite:create(imgPath..titleName)
	-- end
	-- nameSprite:setAnchorPoint(cc.p(0.5,0.5))
	-- nameSprite:setPosition(cc.p(itemSize.width*0.5,15));
	-- nameSprite:setTag(XT_CELL_NAME)
	-- nameSprite:setScale(self.ScaleMultiple)
	-- self:addChild(nameSprite,6)

	local sIcon = cc.Sprite:create(imgPath.."gui_needupdate.png");
	if(sIcon == nil) then
		sIcon = cc.Sprite:create(THEME_IMG("second/common/needpay.png"));
	end
	sIcon:setVisible(false)
	sIcon:setTag(XT_CELL_ICON);
	sIcon:setScale(self.ScaleMultiple)
	sIcon:setAnchorPoint(cc.p(0.5,0.5))
	sIcon:setPosition(cc.p(15,15));
	self:addChild(sIcon, 7);
		

	-- self.colorLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 255));
	-- self.colorLayer:setContentSize(cc.size(5000, 100));

	-- self.colorLayer:ignoreAnchorPointForPosition(false)
	-- self.colorLayer:setPosition(cc.p(55, 60));
	-- self:addChild(self.colorLayer)


	-- local loadProgress = self:createDownLoadLayer();
	-- loadProgress:setPosition(cc.p(itemSize.width*0.5,15))
	-- self:addChild(loadProgress, 6);

	self.bgWaterProgress = self:createWaterProgress(self)
	self.bgWaterProgress:setVisible(false)

end



function CopyItem:createWaterProgress( parent )
	-- 创建水动画
	self._startY = 20.0/UI_SCALE_MULRIPLE()
	local size = parent:getContentSize()
	local sp = addWaterEffect(THEME_IMG("new2ji/default_0.png"),size,self._startY)
	sp:setPosition(cc.p(size.width*0.5,size.height*0.5+10))
	parent:addChild(sp, 1000)
	--
	return sp
end


function CopyItem:isWaterPlaying( ... )
	-- tablleview会滑动停止cell中的actions
	local sp = self.bgWaterProgress._child
	local isShow = self.bgWaterProgress:isVisible()
	if sp and isShow then
		-- 重新恢复动作,以及重新的位置更新
		local ac = sp:getActionByTag(-9909987)
		if not ac then
			--
			local cloneAnim = CreateSpriteFrameAnim("gui_iconloading_%03d.png",14)
			ac = cc.RepeatForever:create(cloneAnim)
			ac:setTag(-9909987)
			sp:runAction(ac)
		end
	end
end


function CopyItem:updateWaterProgress( percent )
	-- 更新水动画进度条
	--print("updateWaterProgress",percent,self:getCurMenuShowItem().bagId,self:getCurMenuShowItem().state)
	local sp = self.bgWaterProgress._child
	local maxH = self.bgWaterProgress._maxHeight
	local srcPy = self.bgWaterProgress._srcPy
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


function CopyItem:updateItem(bgName,iconName)
	local imgPath = self.m_imgPath;
	local bgImgSprite = self:getChildByTag(XT_CELL_IMAGE)
	if(bgImgSprite) then
		bgImgSprite:removeFromParent()
	end

	local iconSprite = self:getChildByTag(XT_CELL_IX)
	if(iconSprite) then
		iconSprite:removeFromParent()
	end

	local itemSize = cc.size(100,120)
	local bgImgSprite = cc.Sprite:create(imgPath..bgName)
	bgImgSprite:setTag(XT_CELL_IMAGE)
	bgImgSprite:setScale(self.ScaleMultiple)
	bgImgSprite:setAnchorPoint(cc.p(0.5,0.5))
	bgImgSprite:setPosition(cc.p(itemSize.width*0.5,itemSize.height*0.5 + 10));
	self:addChild(bgImgSprite,6)

	local iconSprite = cc.Sprite:create(imgPath..iconName)
	iconSprite:setTag(XT_CELL_IX)
	iconSprite:setScale(self.ScaleMultiple)
	iconSprite:setAnchorPoint(cc.p(0.5,0.5))
	iconSprite:setPosition(cc.p(itemSize.width*0.5,itemSize.height*0.5 + 10));
	self:addChild(iconSprite,6)
end
function CopyItem:createDownLoadLayer()
	-- 进度条
	local imgPath = self.m_imgPath
	local pDownloadProgress = cc.Sprite:create(self.m_imgPath.."gui_title_di.png");
	if(pDownloadProgress == nil) then
		pDownloadProgress = cc.Sprite:create(THEME_IMG("second/common/progressbg.png"));
	end
	pDownloadProgress:setScale(self.ScaleMultiple)
	pDownloadProgress:setAnchorPoint(cc.p(0.5, 0.5));
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

function CopyItem:updateIcon(itemInfo)
	if(itemInfo == nil) then
		return;
	end
	
	local sIcon = self:getChildByTag(XT_CELL_ICON);
	if not sIcon then
		return;
	end
	
	--CC_GameLog(itemInfo.bagId,itemInfo.state,DOWNLOAD_START,ITEM_NOT_BUY,UPDATE_START,REPAIR_START,DOWNLOAD_OK,"eiielslskffjjfksslskslks")
	local imgPath = self.m_imgPath;
	--sIcon:setVisible(true);
	if itemInfo.state == ITEM_NOT_BUY then --未购买
		sIcon:setTexture(cc.Director:getInstance():getTextureCache():addImage(imgPath.."gui_needupdate.png"));
	elseif itemInfo.state == DOWNLOAD_START then --未下载
		sIcon:setTexture(cc.Director:getInstance():getTextureCache():addImage(imgPath.."gui_needupdate.png"));
	elseif itemInfo.state == UPDATE_START then --更新
		sIcon:setTexture(cc.Director:getInstance():getTextureCache():addImage(imgPath.."gui_needrefresh.png"));
	elseif itemInfo.state == REPAIR_START then --需要修复
		sIcon:setTexture(cc.Director:getInstance():getTextureCache():addImage(imgPath.."gui_xiufu.png"));
	else
		sIcon:setVisible(false);
	end
end

function CopyItem:changeDownLoadStateLua(itemInfo,downPercent,unzipPercent)
	if itemInfo == nil then
		return;
	end
	
	-- local pDownloadProgress = self:getChildByTag(XT_CELL_PROGRESS_BG_TAG);
	-- if pDownloadProgress == nil then
	-- 	return;
	-- end
	
	-- local pLbDownload = pDownloadProgress:getChildByTag(XT_CELL_PROGRESS_LOAD_TAG);
	-- local pLoadprogress = pDownloadProgress:getChildByTag(XT_CELL_PROGRESS_WORD_TAG);
	-- if itemInfo.state == DOWNLOAD_OK then
	-- 	pDownloadProgress:setVisible(false);
	-- elseif itemInfo.state == DOWNLOAD_WAIT then
	-- 	pDownloadProgress:setVisible(true);
	-- 	pLbDownload:setString("等待中");
	-- 	pLoadprogress:setPercentage(0);
	-- elseif itemInfo.state == DOWNLOADING or itemInfo.state == UNZIPING then
	-- 	pDownloadProgress:setVisible(true);
	-- 	local progressValue = (downPercent * 80 + unzipPercent * 20) / 100;
	-- 	pLoadprogress:setPercentage(progressValue);
	-- 	if progressValue >= 100 then
	-- 		pDownloadProgress:setVisible(false);
	-- 	elseif progressValue < 80 and progressValue > 0 then
	-- 		pLbDownload:setString("下载中");
	-- 	elseif progressValue >= 80 and progressValue < 100 then
	-- 		pLbDownload:setString("下载中");
	-- 	else
	-- 		pLbDownload:setString("等待中");
	-- 	end
	-- elseif itemInfo.state == REPAIR_START or itemInfo.state == DOWNLOAD_START or itemInfo.state == UPDATE_START or itemInfo.state == ITEM_NOT_BUY then
	-- 	pDownloadProgress:setVisible(false);
	-- end

	local state = itemInfo.state
	if state == DOWNLOAD_START or state == UPDATE_START or state == REPAIR_START or state == ITEM_NOT_BUY then
		self.bgWaterProgress:setVisible(false)
	elseif  state == DOWNLOADING  or  state == UNZIPING then
		self.bgWaterProgress:setVisible(true)
		local progressValue = (downPercent * 80 + unzipPercent * 20) / 100;
		self:updateWaterProgress(progressValue)
		-- if state == DOWNLOADING then
		-- 	--
		-- 	local per = downPercent*100
		-- 	self:updateWaterProgress(per*0.8)
		-- else
		-- 	local per = unzipPercent*100 --self:getUnZipPercent()
		-- 	self:updateWaterProgress(per*0.2+80)
		-- end
	elseif  state == DOWNLOAD_WAIT then
		self.bgWaterProgress:setVisible(true)
		self:updateWaterProgress(0)
	elseif state == DOWNLOAD_OK then
		self.bgWaterProgress:setVisible(false)
	end

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

	-- 处理水波纹因为滑动导致的停止
	self:isWaterPlaying()

	self:updateIcon(itemInfo);
end

--高亮
function CopyItem:onHighlight()
    self:stopAllActions()
  	local act = cc.ScaleTo:create(0.05,0.9)
    self:runAction(act)
end

--取消高亮
function CopyItem:onUnHighlight()
    self:stopAllActions()
    local act = cc.ScaleTo:create(0.05,1.0)
    self:runAction(act)
end
	
return CopyItem