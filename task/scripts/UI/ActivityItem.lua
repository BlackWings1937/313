local ArmatureUtil = requirePack("scripts.Utils.ArmatureUtil"); 
local SpriteUtil = requirePack("scripts.Utils.SpriteUtil"); 
local ScaleProcess = requirePack("scripts.UI.ScaleProcess");

local ActivityItem = class("ActivityItem",function(menuType,bagId) 
	local pNode = StateNode:create(menuType, bagId);--2 187,255,169
	return pNode;
end);
-- 重写New方法
ActivityItem.new = function(...)
    local instance
    if ActivityItem.__create then
        instance = ActivityItem.__create(...)
    else
        instance = {}
    end

    for k, v in pairs(ActivityItem) do instance[k] = v end
    instance.class = ActivityItem
    instance:ctor(...);
    return instance
end

function ActivityItem:ctor(menuType,bagId)

    self.menuType_ = menuType;
    self.bagId_ = bagId;

    self.arm_ = nil;
    self.downloadProcess_ = nil;
    self.decorationProcess_ = nil;
    self.bg_ = nil;

    self.data_ = {};
    self.dataDownload_ = {};

    self.controller_ = nil;

    self.isDownloading_ = false;
end

function ActivityItem:getDownLoadData()
    return self.dataDownload_;
end

function ActivityItem:setDownloadData(v)
    self.dataDownload_ = v;
    self.dataDownload_.process =(self.dataDownload_.downloadProcess*0.8+ self.dataDownload_.unZipProcess*0.2)/100;

    self:updateDownloadData();
end

function ActivityItem:updateDownloadData()
    self:UpdateDownloadInfo(self:getDownLoadData());
end

function ActivityItem:onDownloadProgressLua(p)
    local downloadData = self:getDownLoadData();
    downloadData.downloadProcess = p;
    print("downloadProcess:"..downloadData.downloadProcess);
    self:setDownloadData(downloadData);
end

function ActivityItem:onUnZipProgressLua(p)
    local downloadData = self:getDownLoadData();
    downloadData.unZipProcess = p;
    print("unZipProcess:"..downloadData.unZipProcess);

    self:setDownloadData(downloadData);
end

function ActivityItem:onStateChangeLua()
    local itemInfo = self:getCurMenuShowItem();
    local downloadData = self:getDownLoadData();
    downloadData.state = itemInfo.state;

    -- mark
    if itemInfo.state == DOWNLOAD_OK then
        self.spNeedFixIcon_:setVisible(false);
        self.spNeedUpdateIcon_:setVisible(false);

        downloadData.process = 0;
        downloadData.downloadProcess = 0;
        downloadData.unZipProcess = 0;
        self:setDownloadData(downloadData);
	elseif itemInfo.state == DOWNLOAD_WAIT then

	elseif itemInfo.state == DOWNLOADING or itemInfo.state == UNZIPING then

	elseif itemInfo.state == REPAIR_START or itemInfo.state == DOWNLOAD_START or itemInfo.state == UPDATE_START or itemInfo.state == ITEM_NOT_BUY then

	end
end

function ActivityItem:registerDownloadEvent()
    self:setLuaHandle(function(sType, pInfo, pInfo2)
       -- print("sType:"..sType);
        --dump(pInfo);
        --dump(pInfo2);
		if sType == "onEnter" then
            --self:onEnter();
		elseif sType == "onExit" then
            --self:onExit();
            print("activityItem onExit");
            self:unRegisterDownloadEvent(); 
        elseif sType == "onStateChange" then
            self:onStateChangeLua();
		elseif sType == "onDownloadProgress" then
            self:onDownloadProgressLua(pInfo);
		elseif sType == "onUnZipProgress" then
            self:onUnZipProgressLua(pInfo);
		elseif sType == "onDownloadNetError" then
			--self:onDownloadNetErrorLua(pInfo)
		elseif sType == "onPopViewClick" then
			--self:onPopViewClickLua(pInfo, pInfo2)
		elseif sType == "longPressDeleteFinish" then
			--self:refreshShowItem()
		end
	end);
end



function ActivityItem:unRegisterDownloadEvent()
    self:clearCallBack(); 
end

function ActivityItem:initDownloadStateByInfo( info )
    -- body
    local downloadData = self:getDownLoadData();
    downloadData.state = info.state;
    downloadData.process = 0;
    downloadData.downloadProcess = 0;
    downloadData.unZipProcess = 0;

    if info.state == UPDATE_START then 
        self.spNeedFixIcon_:setVisible(false);
        self.spNeedUpdateIcon_:setVisible(true);
        print("UPDATE_START");
    elseif  info.state == REPAIR_START then 
        self.spNeedFixIcon_:setVisible(true);
        self.spNeedUpdateIcon_:setVisible(false);
        print("REPAIR_START");

    else 
        self.spNeedFixIcon_:setVisible(false); -- debug
        self.spNeedUpdateIcon_:setVisible(false);
        print("NormalState");
    end
    self:setDownloadData(downloadData);

end
--[[
    初始化item
]]--
function ActivityItem:Init(armName,btnBg,downloadProcessBg,downloadProcessContent,decorationProcess,lockImg,updateImg,fixImg,controller,bg)
    self.controller_ = controller;
    self.bg_ = SpriteUtil.Create(bg);
    self:addChild(self.bg_);
    
    self.downloadProcess_ = ScaleProcess.new();
    self.downloadProcess_:Init(downloadProcessBg,downloadProcessContent);
    self:addChild(self.downloadProcess_);
    self.downloadProcess_:Process(1);

    --self.downloadProcess_:setVisible(false);
    self.decorationProcess_ = SpriteUtil.Create(decorationProcess);
    self.decorationProcess_:setPositionX(-self.downloadProcess_:getContentSize().width/2);
    self.downloadProcess_:addChild(self.decorationProcess_);

    self.arm_ = TouchArmature:create(armName,TOUCHARMATURE_NORMAL);
    self:addChild(self.arm_);
    self.spLock_ = SpriteUtil.Create(lockImg);
    self:addChild(self.spLock_);

    self.btn_ = ccui.Button:create(btnBg,btnBg);
    self.btn_:addTouchEventListener(function(sender, ntype) 
        if ntype == ccui.TouchEventType.began then

		elseif ntype == ccui.TouchEventType.moved then

		elseif ntype == ccui.TouchEventType.ended then
            self:OnPlayClickItem();
		elseif ntype == ccui.TouchEventType.canceled then

		end
    end);
    self:addChild(self.btn_);
    
    
    self.arm_:setPosition(cc.p(1.3,8.2));
    self.downloadProcess_:setPosition(cc.p(3.8,-37));
    self.bg_:setPosition(cc.p(-0.3,-22));

    self:registerDownloadEvent();



    self.spNeedUpdateIcon_ = nil;
    self.spNeedFixIcon_ = nil;
    self.spNeedUpdateIcon_ = SpriteUtil.Create(updateImg);--fixImg
    self.spNeedFixIcon_ = SpriteUtil.Create(fixImg);--fixImg
    self.downloadProcess_:addChild(self.spNeedUpdateIcon_,1000);
    self.downloadProcess_:addChild(self.spNeedFixIcon_,1000);
    self.spNeedFixIcon_:setVisible(false);
    self.spNeedUpdateIcon_:setVisible(false);
    --self.spNeedFixIcon_:setPosition(cc.p(-25,-25));    
    --self.spNeedUpdateIcon_:setVisible(false);
    self.spNeedFixIcon_:setPositionX(-self.downloadProcess_:getContentSize().width/2);
    self.spNeedUpdateIcon_:setPositionX(-self.downloadProcess_:getContentSize().width/2);

    self:UpdateStateInit();
end

function ActivityItem:UpdateStateInit()
    local str = self:getMenuDataForLua();
    local obj = globalJsonDecode(str);
    self:initDownloadStateByInfo(obj);
end



function ActivityItem:updateItemView()

    self.downloadProcess_:setVisible((self:getDownLoadData().state ~= DOWNLOAD_OK));
    self.spLock_:setVisible(self.data_.IsLock);


    if self.data_.IsLock then 
        -- todo lock
        if self:getDownLoadData().state == DOWNLOAD_OK then 
            -- todo downloaded
            if self.data_.IsShiny then 
                -- is shiny
                if self.data_.IsComplie then 
                    -- 锁定了 下载了 是今天 完成了
                    ArmatureUtil.PlayLoop(self.arm_,7);
                else 
                    -- 锁定了 下载了 是今天 没完成
                    ArmatureUtil.PlayLoop(self.arm_,1);
                end
            else 
                -- not shiny
                if self.data_.IsComplie then 
                    -- 锁定了 下载了 不是今天 完成了
                    ArmatureUtil.PlayLoop(self.arm_,7);
                else 
                    -- 锁定了 下载了 不是今天 没完成
                    ArmatureUtil.PlayLoop(self.arm_,1);
                end
            end

        else 
            -- todo undownloaded
            if self.data_.IsShiny then 
                -- 锁定了 没下载 是今天
                ArmatureUtil.PlayLoop(self.arm_,1);
            else 
                -- 锁定了 没下载 不是今天
                ArmatureUtil.PlayLoop(self.arm_,1);
            end
        end
    else

        -- todo unlock
        if self:getDownLoadData().state == DOWNLOAD_OK then 
            -- todo downloaded
            if self.data_.IsShiny then 
                -- is shiny
                if self.data_.IsComplie then
                    -- 没有锁定 下载了 是今天 完成了 
                    ArmatureUtil.PlayLoop(self.arm_,7);
                    --[[
                    if self.isDownloading_ then 
                        ArmatureUtil.PlayAndStay (self.arm_,3,7)
                        self.arm_:setLuaCallBack(
                            function(eType, _tempArm, sEvent)
                                if eType == TouchArmLuaStatus_AnimEnd then
                                    self:OnPlayClickItem();
                                end
                            end)
                    else 
                        ArmatureUtil.PlayLoop(self.arm_,7);
                    end
                    ]]--
                else 
                    -- 没有锁定 下载了 是今天 没完成 
                    ArmatureUtil.PlayLoop(self.arm_,6);--
                    --[[
                    if self.isDownloading_ then 
                        ArmatureUtil.PlayAndStay (self.arm_,3,6)
                        self.arm_:setLuaCallBack(
                            function(eType, _tempArm, sEvent)
                                if eType == TouchArmLuaStatus_AnimEnd then
                                    self:OnPlayClickItem();
                                end
                            end)
                    else 
                        ArmatureUtil.PlayLoop(self.arm_,6);--
                    end
                    ]]--
                    
                end
            else 
                -- not shiny
                if self.data_.IsComplie then 
                    ArmatureUtil.PlayLoop(self.arm_,7);
                    --[[
                    if self.isDownloading_ then 
                        ArmatureUtil.PlayAndStay (self.arm_,3,7)
                        self.arm_:setLuaCallBack(
                            function(eType, _tempArm, sEvent)
                                if eType == TouchArmLuaStatus_AnimEnd then
                                    self:OnPlayClickItem();
                                end
                            end)
                    else 
                        ArmatureUtil.PlayLoop(self.arm_,7);
                    end
                    ]]--
                    -- is complie
                else 
                    ArmatureUtil.PlayLoop(self.arm_,5);--
                    --[[
                    if self.isDownloading_ then 
                        ArmatureUtil.PlayAndStay (self.arm_,3,5)
                        self.arm_:setLuaCallBack(
                            function(eType, _tempArm, sEvent)
                                if eType == TouchArmLuaStatus_AnimEnd then
                                    self:OnPlayClickItem();
                                end
                            end)
                        print("play transform ------------------------");
                    else
                        -- is complie
                        ArmatureUtil.PlayLoop(self.arm_,5);--
                        print("play not ------------------------");
                    end
                    ]]--
                end
            end
            self.isDownloading_ = false;
        else 
            -- todo undownloaded
            if self.data_.IsShiny then 
                -- is shiny
                ArmatureUtil.PlayLoop(self.arm_,2);
            else 
                -- not shiny
                ArmatureUtil.PlayLoop(self.arm_,1);
            end
        end
    end

   -- ArmatureUtil.PlayLoop(self.arm_,6);
    --[[]]--
end

-- ----- 更新我的数据 -----
function ActivityItem:UpdateDataSelf(d)
    self.data_ = d;
    self:updateItemView();
end


-- -----------------------

-- ----- 更新下载数据 -----
function ActivityItem:UpdateDownloadInfo(d)
    self:updateItemView();
    self.downloadProcess_:Process(d.process);
end

-- -----------------------
function ActivityItem:ClickAnim()

    if self.data_.IsLock then
        if self.spLock_ ~= nil then
            self.spLock_:setScale(0.423);
            local scale = self.spLock_:getScale();
            print("lock scale:"..scale);
            self.spLock_:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.1,1.25*scale),
                cc.ScaleTo:create(0.1,0.8*scale),
                cc.ScaleTo:create(0.1,1*scale)
            ));
        end
    else

  
        local downloadData = self:getDownLoadData();
        if downloadData.state == DOWNLOAD_OK then 
            if self.data_.IsComplie then 
                ArmatureUtil.Play(self.arm_,11,function() -- mark
                    self:updateItemView();
                end);
            else 
                ArmatureUtil.Play(self.arm_,9,function() --
                    self:updateItemView();
                end);
            end
        else
            ArmatureUtil.Play(self.arm_,3,function() --
                self:updateItemView();
            end);
        end
             --[[ ]]--
    end
end
function ActivityItem:OnPlayClickItem()
    if self.data_.IsLock then
        if self.controller_ ~= nil then 
            self.controller_:OnUserClickLockItem(self.data_.Index);
        end
    else
        local downloadData = self:getDownLoadData();
        if downloadData.state == DOWNLOAD_OK then
            if self.controller_ ~= nil then

                self.controller_:OnUserClickEnterPackage( self.data_.Index,function(e)
                    if e == "Complie" then 
                        Utils:GetInstance():baiduTongji("qunahuodongMD","310_task"..self.data_.Index.."_enter"); 
                        g_tConfigTable.gotoFromType="LMMDress";
                        g_tConfigTable.TRY_ENTER_INDEXX = self.data_.Index;
                        local storyid = StoryEngineScene.curStoryEngineScene:getStoryID();
                        print("self story id:"..storyid);
                        xblStaticData:gotoSourceKeepFrom(9,9, self.bagId_, 2, storyid);
                    end
                end);
            end

        else
            if self.controller_ ~= nil then 
                self.controller_:OnUserClickDownloadingItem();
            end
            self:onClickItem();
            Utils:GetInstance():baiduTongji("qunahuodongMD","310_task"..self.data_.Index.."_xiazai");
            self.isDownloading_ = true;
        end
    end
    self:ClickAnim();
end

function ActivityItem:PlayLock()
    self.spLock_:setVisible(true);
end

function ActivityItem:PlayUnLock( cb )
    self.spLock_:setVisible(false);
    self:updateItemView();
    ArmatureUtil.Play(self.arm_,10,function() 
        self:updateItemView();
        if cb ~= nil then 
            cb();
        end
    end);
end



return ActivityItem;