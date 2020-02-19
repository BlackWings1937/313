local BaseController = requirePack("scripts.MVC.SysForNormal.NormalController");

local LocalRecordManager = requirePack("scripts.Tools.LocalRecordManager");
local FileUtil = requirePack("scripts.Utils.FileUtil");



local DragonController = class("DragonController",function() 
    return BaseController.new();
end);
g_tConfigTable.CREATE_NEW(DragonController);

DragonController.DEBUG_IS_CLEAR_LOCAL_DATA = false;   -- 启动时是否清除本地数据
--DragonController.DEBUG_IS_OPEN_DEBUG_DATA = false;    -- 启动测试数据 

function DragonController:clearLocalData() --STR_FALSE


 --[[     ]]--  
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY ,self.STR_FALSE);
    self.localRecorder_:RecordUserDataToday(self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY,self.STR_FALSE);
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..3,self.STR_FALSE)
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..2,self.STR_FALSE)
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..1,self.STR_FALSE)
    self.localRecorder_:RecordFullAreaData("Gushi_2MKonglong_" .."1_"..curIdStr,self.STR_FALSE);
    self.localRecorder_:RecordFullAreaData("Gushi_2MKonglong_" .."2_"..curIdStr,self.STR_FALSE);
    self.localRecorder_:RecordFullAreaData("Gushi_2MKonglong_" .."3_"..curIdStr,self.STR_FALSE);

    print("clear all data");
end

function DragonController:ctor()
    g_tConfigTable.Gushi_gotoFromType="2MKonglong";
    
    --g_tConfigTable.RunningModule55Activity = "Main";
    --print("Gushi_2MKonglong_1:"..self.localRecorder_:RecordFullAreaData("Gushi_2MKonglong_" .."1_"..curIdStr));

    self.activityDay_ = 0;
    self.localRecorder_ = nil;
    self.dayIndex_ = 1;
    self.unLockIndex_ = 1;

    self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY = "KLFIRST_ENTER_ACTIVITY";               -- 首次进入活动
    self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY = "KLFIRST_ENTER_TODAY";                     -- 当天首次进入本地记录事件
    self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE = "KLCHEER_TASK_";                          -- 庆祝任务完成
    self.STR_TRUE = "TRUE";
    self.STR_FALSE = "";

    self.isShowPaoPao_ = false;
end



function DragonController:GetActivityDay()
    return self.activityDay_;
end

function DragonController:SetActivityDay(d)
    self.activityDay_ = d;
end


function DragonController:setActivityStartDate(year,month,day,hour,min,second)
    local tStart = os.time({ year=year,month=month,day=day, hour=hour, minute=min, second=second});
    local tNow = os.time(); -- 当前时间
    local dayStamp = 86400;          -- 一天的时间(秒)
    --local maxDay = 365;--self:GetActivityDay();

    local timeDt = tNow - tStart;

    --SetTaskComplieByDayIndex
    for i = 1,self:GetActivityDay(),1 do 
        local curIdStr = UInfoUtil:getInstance():getCurUidStr();
        local result = self.localRecorder_:GetFullAreaData("Gushi_2MKonglong_"..i.."_"..curIdStr);
        if result ~= "" then 
            self:getData():SetTaskComplieByDayIndex(i);
            self.unLockIndex_ = i+1;
        end
    end
    self:getData():SetAimTaskIndex(self.unLockIndex_);


    if timeDt<0 then 
        self:getData():LockAllItems();
        self.dayIndex_  = -1;
    else
        self.dayIndex_ = math.ceil(timeDt/dayStamp);

       -- --[[]]-- self.dayIndex_  <= maxDay
        if true  then 
            local rear = math.min(self.unLockIndex_ ,self.dayIndex_);
            self:getData():ShinyItemByDayIndex(rear);
            self:getData():UnlockItemsByRange(1,rear);
        else
            self:getData():LockAllItems();
        end
    end
end

function DragonController:tryUnlockNewItem()

end

function DragonController:LmmSendChat()
    print("chat2 lmm -----------------------------------------------------------");
    if self:getView():IsRunningAction() then 
        return ;
    end

    if self.dayIndex_ == -1 then 
        self:getView():LmmClickUnOpenRandPlay();
        return ;
    end


    local rear = math.min(self.unLockIndex_ ,self.dayIndex_);

    if self.unLockIndex_>=4 then 
        -- 完成3个任务后
        local rand = math.random( 1,10 );
        if rand>=1 and rand<=3  then --
            -- 龙妹妹唱歌飘雪花

            print("pause Bgm");
            self:getView():LMMActivityEnd2(function(eventName)
                if eventName == "go" then 
                    self.isShowPaoPao_ = true;
                    self:getView():StartSendSnowBallSeq()
                elseif eventName == "out" then 
                    self:getView():StopSendSnowBallSeq();
                    self.isShowPaoPao_ = false;
                elseif eventName == "Complie" then 

                    print("Resume Bgm");
                end
            end);
        else 
            self:getView():LmmClickRandPlay(self.unLockIndex_);
        end
    else 
         -- 未完成3个任务
        if self.dayIndex_>= self.unLockIndex_ then 
            -- 还有任务可以完成
            local rand = math.random( 1,10 );
            if rand%2 == 1 then 
                self:getView():ClickLMMTipUpTask(rear);
            else 
                self:getView():LmmClickRandPlay(self.unLockIndex_,function() end)
            end
        else 
            -- 没有任务可以完成了随机播放
            self:getView():LmmClickRandPlay(self.unLockIndex_);
        end
        
    end
    --self:getView():LmmRandAct(rear);
end

function DragonController:SendChat(  )
    if self:getView():GetIsWaitingClick() then 
        print("wait for click don send chat");
        return ;
    end
    if self:getView():IsRunningAction() then 
        return ;
    end

    if self.dayIndex_ == -1 then 
        return ;
    end

    local rear = math.min(self.unLockIndex_ ,self.dayIndex_);
    if self.unLockIndex_>=4 then 
        -- 完成4个任务后
        --self:getView():XblClickRandPlay2();
        self:getView():XBLFreeChat(function()end);
    else
        -- 完成4个任务前

        if self.dayIndex_>= self.unLockIndex_ then 
            -- 当前还有可以再进行的任务
            if rear>0 and rear<=self:GetActivityDay() then -- 安全
                
                -- 检查当前目标任务是否完成，未完成就提醒
                local curIdStr = UInfoUtil:getInstance():getCurUidStr();
                local isTodayTaskComplie = (self.localRecorder_:GetFullAreaData("Gushi_2MKonglong_" .. rear .. "_"..curIdStr) ~= self.STR_FALSE);
                if isTodayTaskComplie then 
                    self:getView():XBLFreeChat(function()end);
                else 
                    -- 小伴龙概率提醒 1:提醒明天还有任务 2:随便闲聊
                    local rand = math.random( 1,10 );
                    if rand%2 == 0 then 
                        self:getView():XBLFreeChatSendTaskByDayIndex(rear,function() end);
                    else
                        self:getView():XBLFreeChat(function()end);
                    end
                end
            end
        else 
            -- 小伴龙概率提醒 1:提醒明天还有任务 2:随便闲聊
            local rand = math.random( 1,10 );
            if rand%2 == 0 then 
                if rear>0 and rear<=self:GetActivityDay() then 
                    self:getView():XBLFreeChatSendTaskNextDay(self.unLockIndex_,function() end);
                end
            else 
                self:getView():XBLFreeChat(function()end);
            end
        end
    end
end

function DragonController:StartSendChatSeq()
    self:RepeatForever(25,1321,function() 
        self:SendChat();
    end);
end

function DragonController:StopSendChatSeq(  )
    self:StopRepeatForever(1321);
end

function DragonController:IsCheerAllTask()
    local result1 = (self.localRecorder_:GetUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..1) == self.STR_TRUE);
    local result2 = (self.localRecorder_:GetUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..2) == self.STR_TRUE);
    local result3 = (self.localRecorder_:GetUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..3) == self.STR_TRUE);
    return (result1 and result2 and result3);
end


--[[
    复杂的要死的开场greeting
]]--
function DragonController:StartSceneGreeting()
    if self.dayIndex_ == -1 then 
        -- 如果在非法时间进入
        --[[
        if self.clearData_.PublicTime == 1 then 
            self:getView():XBLGreetingTipDate1();
        elseif  self.clearData_.PublicTime == 2 then
            self:getView():XBLGreetingTipDate2();
        end
        ]]--
        print("Error invaild time enter activity.....");
    elseif self.unLockIndex_ >= 4 and self.dayIndex_>=4 and self:IsCheerAllTask() then 
        -- 如果在活动结束后进入
        --[[
        self:getView():XBLNormalGreeting(function()
            
        end);
        ]]--
        print("Error activity is over.....");
    else 

        -- 正常时间进入活动
        local strIsEnterActivityBefore = self.localRecorder_:GetUserData(self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY );
        if strIsEnterActivityBefore == self.STR_FALSE then 
            -- 第一次进入活动
            self:getData():LockAllItems();
           -- Utils:GetInstance():baiduTongji("qunahuodongMD","310_op_start")
            self:getView():XBLSendTaskOrig(1,function() 
                self:getData():UnlockItemsByRange(1,1);
                --self:getView():XBLSendTaskByDayIndex(1);
            --    Utils:GetInstance():baiduTongji("qunahuodongMD","310_op_skip")
            end);
            self:getData():UnShinyAllItem();
            self:getData():ShinyItemByDayIndex(1);

            self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY ,self.STR_TRUE);
            self.localRecorder_:RecordUserDataToday(self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY,self.STR_TRUE);
        else 
            -- 第n次进入活动

                -- todo not first time enter activity
                local strIsFirstEnterToday = self.localRecorder_:GetUserDataToday(self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY);
                if strIsFirstEnterToday == self.STR_FALSE then 
                    -- 当日第一次进入活动
                    -- todo is first enter today
                    -- todo record teday come here before.
                    local rear = math.min(self.unLockIndex_ ,self.dayIndex_);
                    self:getView():XBLSendTaskOrig(rear, function() 
                        --self:getView():XBLSendTaskByDayIndex(rear);
                    end);
                    self.localRecorder_:RecordUserDataToday(self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY,self.STR_TRUE);
                else 
                    -- 当日第n次进入活动

                    -- 检查是否是重任务中推出来的，是的话，播放成功或者失败
                    local rear = g_tConfigTable.TRY_ENTER_INDEXX;
                    if rear ~= nil then 
                        rear =math.max(math.min(rear,self:GetActivityDay()),1) ;
                        if rear>0 and rear< self:GetActivityDay() then 
                            local curIdStr = UInfoUtil:getInstance():getCurUidStr();
                            local isTodayTaskComplie = (self.localRecorder_:GetFullAreaData("Gushi_2MKonglong_" .. rear .. "_"..curIdStr) ~= self.STR_FALSE);
                            local isCheerUp = (self.localRecorder_:GetUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..rear) == self.STR_TRUE);
                            if isCheerUp == false then 
                                if isTodayTaskComplie then 
                                   -- Utils:GetInstance():baiduTongji("qunahuodongMD","310_task"..rear.."_success")
                                    -- todo lock next ..
                                    local rearIndex = math.min(self.dayIndex_,self:getData():GetAimTaskIndex()) 
                                    if rearIndex ~=  g_tConfigTable.TRY_ENTER_INDEXX then 
                                        self:getView():ItemTempLock(rearIndex);
                                    end
                                    print("rear>0 and rear< self:GetActivityDay()");-- mark
                                    self:getView():XBLCheerTaskComplieByDayIndex(rear,function()
                                        local rearIndex = math.min(self.dayIndex_,self:getData():GetAimTaskIndex()) 
                                        if rearIndex > rear then 
                                            self:getView():XBLContinueTellTaskByIndex(rearIndex);
                                        else 
                                            self:getView():XBLContinueTellTaskTomorrowByIndex(rearIndex);
                                        end
                                    end);
                                    -- todo here add script ..
                                    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..rear,self.STR_TRUE)
                                    return ;
                                end
                            end
                        elseif rear == self:GetActivityDay() then 



                            local curIdStr = UInfoUtil:getInstance():getCurUidStr();
                            local isTodayTaskComplie = (self.localRecorder_:GetFullAreaData("Gushi_2MKonglong_" .. rear .. "_"..curIdStr) ~= self.STR_FALSE);
                            local isCheerUp = (self.localRecorder_:GetUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..rear) == self.STR_TRUE);
                            if isCheerUp == false then 

                                if isTodayTaskComplie then 

                                    local CustomEventType = requirePack("baseScripts.dataScripts.CustomEventType", false)
                                    CustomEventDispatcher:getInstance():msgBroadcastLua(CustomEventType.CE_COLLECT_SHOW_NEW_GOOD, 25, true)


                                    Utils:GetInstance():baiduTongji("qunahuodongMD","310_task"..rear.."_success")
                                    Utils:GetInstance():baiduTongji("qunahuodongMD","310_end_start")
                                    print("rear == self:GetActivityDay()");
                                    self:getView():XBLCheerTaskComplieByDayIndex(rear,function() 
                                        self:getView():SuccessResult(function()
                                        
                                        end);
                                    end);
                                    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..rear,self.STR_TRUE)
                                    return ;
                                end
                            end
                        end
                    end


                    -- 检查是否是活动之后进入的，是的话播放通用处理
                    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
                    if self.localRecorder_:GetFullAreaData("Gushi_2MKonglong_" .."3_"..curIdStr) ~= self.STR_FALSE then
                        self:getView():XBLFreeChat(function()end);
                    else 
                        -- 
                        if self.unLockIndex_>self.dayIndex_ then 
                            -- 如果今天的任务都已经完成 提醒明日任务
                            self:getView():XBLRemeberTaskByDayIndex(self.unLockIndex_,function (  )
                                -- body
                            end);
                        else 
                            -- 如果今日还有任务可以完成提醒今日任务
                            self:getView():XBLSendTaskByDayIndex(self.unLockIndex_,function (  )
                                -- body
                            end);
                        end
                    end
                end
        end
    end
end

function DragonController:NullInfoOut(cb)
    self.isError_ = true;
    self.isShowPaoPao_ = true;
    self:DelayCallBack(0.5,function() 
        if self.clearData_.PublicTime == 1 then 
            self:getView():XBLClickUnOpenRandPlay1X(cb);
        elseif self.clearData_.PublicTime == 2 then 
            self:getView():XBLClickUnOpenRandPlay2X(cb);
        end
    end);
end


function DragonController:OnUserClickXBL()
    Utils:GetInstance():baiduTongji("qunahuodongMD","313_xbl_touch")
    if self.dayIndex_ == -1 then 
        self:getView():XblClickRandPlay();
        return ;
    end


    local rearIndex = math.min(self.dayIndex_,self:getData():GetAimTaskIndex());
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();

    if self.unLockIndex_>=4 then 
        self:getView():XblClickRandPlay();
    else 
        local isTodayTaskComplie = (self.localRecorder_:GetFullAreaData("Gushi_2MKonglong_" .. rearIndex .. "_"..curIdStr) ~= self.STR_FALSE);
        if isTodayTaskComplie == false then 
            self:getView():ClickXBLTipUpTask(rearIndex,function() end);
        else 
            if self.dayIndex_>= self.unLockIndex_ then
                self:getView():XblClickRandPlay();
            else
                local rand = math.random( 1,10 );
                if rand%3 == 1 then 
                    self:getView():XblClickRandPlay();
                else
                    self:getView():XBLRemenberNextDay();
                end
            end
        end
    end
end

function DragonController:OnClickBwl() -- XBLTellGetBwl XBLTellGetSjl XBLTellGetJl BwlShowOff SjlShowOff JlShowOff
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    if self.localRecorder_:GetFullAreaData("Gushi_2MKonglong_" .."1_"..curIdStr) ~= self.STR_FALSE then
        self:getView():BwlShowOff();
        Utils:GetInstance():baiduTongji("qunahuodongMD","313_long1_touch")
    else 
        self:getView():XBLTellGetBwl();
        Utils:GetInstance():baiduTongji("qunahuodongMD","313_gujia1_touch")
    end
end
function DragonController:OnClickJl()
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    if self.localRecorder_:GetFullAreaData("Gushi_2MKonglong_" .."3_"..curIdStr) ~= self.STR_FALSE then
        self:getView():JlShowOff();
        Utils:GetInstance():baiduTongji("qunahuodongMD","313_long3_touch")
    else 
        self:getView():XBLTellGetJl();
        Utils:GetInstance():baiduTongji("qunahuodongMD","313_gujia3_touch")
    end
end
function DragonController:OnClickSjl()
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    
    if self.localRecorder_:GetFullAreaData("Gushi_2MKonglong_" .."2_"..curIdStr) ~= self.STR_FALSE then
        self:getView():SjlShowOff();
        Utils:GetInstance():baiduTongji("qunahuodongMD","313_long2_touch")
    else 
        self:getView():XBLTellGetSjl();
        Utils:GetInstance():baiduTongji("qunahuodongMD","313_gujia2_touch")
    end
end

function DragonController:OnUserClickLMM()
    Utils:GetInstance():baiduTongji("qunahuodongMD","313_txy_touch")
    self:getView():TXYTell();
end

function DragonController:OnUserClickLockItem(index)
    if self:getView():GetIsDontTouchActivityItems() then 
        self:getView():XBLTipNoData();
        return ;
    end
    if self.dayIndex_ == -1 then 
        --self:getView():ItemLockedUnOpen();
        print("invaild activity day:"..self.dayIndex_);
        return ;
    end
    if index <= self.dayIndex_ then 
        self:getView():XBLTellLockedToday(function() end);
    else 
        self:getView():XBLTellItemLocked(function() end);
    end
    
end
function DragonController:OnUserClickDownloadingItem()
    if self:getView():GetIsDontTouchActivityItems() then 
        self:getView():XBLTipNoData();
        return ;
    end
    self:getView():XBLTellItemDownloading(function() end);

end
function DragonController:OnUserClickEnterPackage(i,enterCb)
    if self:getView():GetIsDontTouchActivityItems() then 
        self:getView():XBLTipNoData();
        return ;
    end
    if self.unLockIndex_>=4 then
        enterCb("Complie");
    else
        --XBLTellItemEnter
        self:getView():XBLTellItemEnter(enterCb);
    end
end
--
function DragonController:initClearData()
    local path = g_tConfigTable.sTaskpath .. "Clear.cfg";
    if FileUtil.Exists(path) then 
        local str = FileUtil.LoadFileContent(path);
        self.clearData_ = json.decode(str);
    else 
        self.clearData_ = {};
        self.clearData_.IsClear = false;
        self.clearData_.Date = {};
        self.clearData_.Date.Year = 2020;
        self.clearData_.Date.Month = 1;
        self.clearData_.Date.Day = 1;
        self.clearData_.Date.Hour = 1;
        self.clearData_.Date.Min = 1;
        self.clearData_.Date.Sec = 1;
        self.clearData_.PublicTime = 1;
        local str = json.encode(self.clearData_);
        FileUtil.Write(path,str);
    end
end

--function DragonController
function DragonController:RefreshData()
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY ,self.STR_FALSE);
    self.localRecorder_:RecordUserDataToday(self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY,self.STR_FALSE);
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..3,self.STR_FALSE)
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..2,self.STR_FALSE)
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..1,self.STR_FALSE)
    self.localRecorder_:RecordFullAreaData("Gushi_2MKonglong_" .."1_"..curIdStr,self.STR_FALSE);
    self.localRecorder_:RecordFullAreaData("Gushi_2MKonglong_" .."2_"..curIdStr,self.STR_FALSE);
    self.localRecorder_:RecordFullAreaData("Gushi_2MKonglong_" .."3_"..curIdStr,self.STR_FALSE);


    self.clearData_.IsClear = false;
    local path = g_tConfigTable.sTaskpath .. "Clear.cfg";
    local str = json.encode(self.clearData_);
    FileUtil.Write(path,str);
end
--[[
    通过这个方法传入sys所有需要的外部参数
    初始化:
        View
        data
]]--
function DragonController:Start(rootNode,view,data)



    Utils:GetInstance():baiduTongji("qunahuodongMD","313_enter1_touchafter")

    self:initClearData();

    self.localRecorder_ = LocalRecordManager.new();

    local strPt = self.localRecorder_:GetUserData("PT");
    if strPt ~= self.clearData_.PublicTime.."" then 
        self:RefreshData();
        self.localRecorder_:RecordUserData("PT",""..self.clearData_.PublicTime);
    end

    if DragonController.DEBUG_IS_CLEAR_LOCAL_DATA then 
        self:clearLocalData();
    end
    SoundUtil:getInstance():playBackgroundMusic(
        g_tConfigTable.sTaskpath.."audio/bgm_no_8.mp3",
        true
    );
    self:SetActivityDay(3); -- 设置活动时长
    BaseController.Start(self,rootNode,view,data);

    -- 检查是否拉取到数据
    if view:TestItemHasInfo() == false then 
        -- todo broken net mode
        print("broken net mode");
         -- GetIsDontTouchActivityItems SetIsDontTouchActivityItems
        self:DelayCallBack(0.1,function()
            print("tell No data");
            self:getView():XBLTellNoData();
            self:getView():SetIsDontTouchActivityItems(true);
            print("tell No data end");

        end);
        
        --return ;
    else 
        self:DelayCallBack(0.1,function()
            self:StartSceneGreeting();
        end);
    
        self:DelayCallBack(10,function()
            self:StartSendChatSeq();
        end);
    end

    self:setActivityStartDate(
        self.clearData_.Date.Year,
        self.clearData_.Date.Month ,
        self.clearData_.Date.Day ,
        self.clearData_.Date.Hour,
        self.clearData_.Date.Min ,
        self.clearData_.Date.Sec ); -- 设置活动日期
end


--[[
    通过这个方法终止sys
    撤销:
        View
        data
]]--
function DragonController:Stop()
    SoundUtil:getInstance():stopBackgroundMusic(
        g_tConfigTable.sTaskpath.."audio/bgm_no_8.mp3"
    );
    print("stop playBgm---------------------------");
    if self.localRecorder_ ~= nil then 
        self.localRecorder_:SaveToLocal();
    end
    BaseController.Stop(self);
end

return DragonController;

--[[

    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY ,self.STR_TRUE);
    self.localRecorder_:RecordUserDataToday(self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY,self.STR_TRUE);
    g_tConfigTable.TRY_ENTER_INDEXX = 1;

    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    self.localRecorder_:RecordFullAreaData("Gushi_2MKonglong_" .."1_"..curIdStr,self.STR_TRUE);
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE.."_1",self.STR_FALSE)



    测图标
        self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY ,self.STR_TRUE);
    self.localRecorder_:RecordUserDataToday(self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY,self.STR_TRUE);
    g_tConfigTable.TRY_ENTER_INDEXX = 1;

    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    self.localRecorder_:RecordFullAreaData("Gushi_2MKonglong_" .."1_"..curIdStr,self.STR_TRUE);
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE.."_1",self.STR_FALSE)
   -- self.localRecorder_:RecordFullAreaData("Gushi_2MKonglong_".. "2_"..curIdStr,self.STR_TRUE);
]]--

--[[
    1.完成网络侦测部分
    2.上传包，大体验证台本
]]--