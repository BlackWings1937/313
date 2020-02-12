
local ArmatureUtil = requirePack("scripts.Utils.ArmatureUtil"); 
local SpriteUtil = requirePack("scripts.Utils.SpriteUtil"); 
local ScaleProcess = requirePack("scripts.UI.ScaleProcess");

local ActivityItem = requirePack("scripts.UI.ActivityItem");

local ActivityItemExist1 = class("ActivityItemExist1",function(menuType,bagId)
    local n = ActivityItem.new(menuType, bagId);
    return n;
end);

-- 重写New方法
ActivityItemExist1.new = function(...)
    local instance
    if ActivityItemExist1.__create then
        instance = ActivityItemExist1.__create(...)
    else
        instance = {}
    end

    for k, v in pairs(ActivityItemExist1) do instance[k] = v end
    instance.class = ActivityItemExist1
    instance:ctor(...);
    return instance
end

--[[
    初始化item
]]--

function ActivityItemExist1:Init(
    armName,
    btnBg,
    downloadProcessBg,
    downloadProcessContent,
    decorationProcess,
    lockImg,
    updateImg,
    fixImg,
    controller,
    bg)

    self.controller_ = controller;

 
    self.bg_ = TouchArmature:create(bg,TOUCHARMATURE_NORMAL);
    self:addChild(self.bg_);
    self.bg_:setPositionY(-22);
    self.bg_ :setVisible(false);


    self.downloadProcess_ = ScaleProcess.new();
    self.downloadProcess_:Init(downloadProcessBg,downloadProcessContent);
    self:addChild(self.downloadProcess_);
    self.downloadProcess_:Process(1);

    self.decorationProcess_ = SpriteUtil.Create(decorationProcess);
    self.decorationProcess_:setPositionX(-self.downloadProcess_:getContentSize().width/2);
    self.downloadProcess_:addChild(self.decorationProcess_);

    self.arm_ = armName;
    local ax,ay = armName:getPosition();
    --self:setPosition(cc.p(ax,ay));
    self:setZOrder(self.arm_:getZOrder()+1);


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

    self:registerDownloadEvent();

    self.spNeedUpdateIcon_ = nil;
    self.spNeedFixIcon_ = nil;
    self.spNeedUpdateIcon_ = SpriteUtil.Create(updateImg);--fixImg
    self.spNeedFixIcon_ = SpriteUtil.Create(fixImg);--fixImg
    self.downloadProcess_:setPosition(cc.p(3.8,-37-20));
    self.downloadProcess_:addChild(self.spNeedUpdateIcon_,1000);
    self.downloadProcess_:addChild(self.spNeedFixIcon_,1000);
    self.spNeedFixIcon_:setVisible(false);
    self.spNeedUpdateIcon_:setVisible(false);
    self.spNeedFixIcon_:setPositionX(-self.downloadProcess_:getContentSize().width/2);
    self.spNeedUpdateIcon_:setPositionX(-self.downloadProcess_:getContentSize().width/2);

    self:UpdateStateInit();

end

function ActivityItemExist1:updateItemView()

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

return ActivityItemExist1;