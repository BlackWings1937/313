local BaseController = requirePack("scripts.MVC.SysForNormal.NormalController");

local LocalRecordManager = requirePack("scripts.Tools.LocalRecordManager");
local FileUtil = requirePack("scripts.Utils.FileUtil");



local NewYearController = class("NewYearController",function() 
    return BaseController.new();
end);
g_tConfigTable.CREATE_NEW(NewYearController);

NewYearController.DEBUG_IS_CLEAR_LOCAL_DATA = false;   -- 启动时是否清除本地数据
--NewYearController.DEBUG_IS_OPEN_DEBUG_DATA = false;    -- 启动测试数据 

function NewYearController:clearLocalData() --STR_FALSE


 --[[     ]]--  
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY ,self.STR_FALSE);
    self.localRecorder_:RecordUserDataToday(self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY,self.STR_FALSE);
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..3,self.STR_FALSE)
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..2,self.STR_FALSE)
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..1,self.STR_FALSE)
    self.localRecorder_:RecordFullAreaData("Gushi_LMMDress_" .."1_"..curIdStr,self.STR_FALSE);
    self.localRecorder_:RecordFullAreaData("Gushi_LMMDress_" .."2_"..curIdStr,self.STR_FALSE);
    self.localRecorder_:RecordFullAreaData("Gushi_LMMDress_" .."3_"..curIdStr,self.STR_FALSE);


end

function NewYearController:ctor()
    --print("Gushi_LMMDress_1:"..self.localRecorder_:RecordFullAreaData("Gushi_LMMDress_" .."1_"..curIdStr));

    self.activityDay_ = 0;
    self.localRecorder_ = nil;
    self.dayIndex_ = 1;
    self.unLockIndex_ = 1;

    self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY = "FIRST_ENTER_ACTIVITY";               -- 首次进入活动
    self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY = "FIRST_ENTER_TODAY";                     -- 当天首次进入本地记录事件
    self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE = "CHEER_TASK_";                          -- 庆祝任务完成
    self.STR_TRUE = "TRUE";
    self.STR_FALSE = "";

    self.isShowPaoPao_ = false;
end



function NewYearController:GetActivityDay()
    return self.activityDay_;
end

function NewYearController:SetActivityDay(d)
    self.activityDay_ = d;
end


function NewYearController:setActivityStartDate(year,month,day,hour,min,second)
    local tStart = os.time({ year=year,month=month,day=day, hour=hour, minute=min, second=second});
    local tNow = os.time(); -- 当前时间
    local dayStamp = 86400;          -- 一天的时间(秒)
    --local maxDay = 365;--self:GetActivityDay();

    local timeDt = tNow - tStart;

    --SetTaskComplieByDayIndex
    for i = 1,self:GetActivityDay(),1 do 
        local curIdStr = UInfoUtil:getInstance():getCurUidStr();
        local result = self.localRecorder_:GetFullAreaData("Gushi_LMMDress_"..i.."_"..curIdStr);
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

function NewYearController:tryUnlockNewItem()

end

function NewYearController:LmmSendChat()
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
            SoundUtil:getInstance():stopBackgroundMusic(
                g_tConfigTable.sTaskpath.."audio/public_bgm_0112.mp3"
            );
           -- SoundUtil:getInstance():pauseBackgroundMusic();
            print("pause Bgm");
            self:getView():LMMActivityEnd2(function(eventName)
                if eventName == "go" then 
                    self.isShowPaoPao_ = true;
                    self:getView():StartSendSnowBallSeq()
                elseif eventName == "out" then 
                    self:getView():StopSendSnowBallSeq();
                    self.isShowPaoPao_ = false;
                elseif eventName == "Complie" then 
                    --SoundUtil:getInstance():resumeBackgroundMusic();
                    SoundUtil:getInstance():playBackgroundMusic(
                        g_tConfigTable.sTaskpath.."audio/public_bgm_0112.mp3",
                        true
                    );
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

function NewYearController:SendChat(  )
    print("chat1 xbl -----------------------------------------------------------");
    if self:getView():IsRunningAction() then 
        return ;
    end

    if self.dayIndex_ == -1 then 
        if self.clearData_.PublicTime == 1 then 
            self:getView():XBLClickUnOpenRandPlay1();
        elseif self.clearData_.PublicTime == 2 then 
            self:getView():XBLClickUnOpenRandPlay2();
        end
        return ;
    end

    local rear = math.min(self.unLockIndex_ ,self.dayIndex_);
    if self.unLockIndex_>=4 then 
        -- 完成4个任务后
        self:getView():XblClickRandPlay2();
    else
        -- 完成4个任务前

        if self.dayIndex_>= self.unLockIndex_ then 
            -- 当前还有可以再进行的任务
            if rear>0 and rear<=self:GetActivityDay() then -- 安全
                
                -- 检查当前目标任务是否完成，未完成就提醒
                local curIdStr = UInfoUtil:getInstance():getCurUidStr();
                local isTodayTaskComplie = (self.localRecorder_:GetFullAreaData("Gushi_LMMDress_" .. rear .. "_"..curIdStr) ~= self.STR_FALSE);
                if isTodayTaskComplie then 
                    self:getView():XBLFreeChat(function()end);
                else 
                    self:getView():XBLFreeChatSendTaskByDayIndex(rear,function() end);
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

function NewYearController:StartSendChatSeq()
    print("startSeq ----------------------- :1321");
    self:RepeatForever(10,1321,function() 
        self:SendChat();
    end);
    self:RepeatForever(5,1322,function() 
        self:LmmSendChat();
    end);
end

function NewYearController:StopSendChatSeq(  )
    print("stopSeq ----------------------- :1321");
    self:StopRepeatForever(1321);
    self:StopRepeatForever(1322);
end

function NewYearController:IsCheerAllTask()
    local result1 = (self.localRecorder_:GetUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..1) == self.STR_TRUE);
    local result2 = (self.localRecorder_:GetUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..2) == self.STR_TRUE);
    local result3 = (self.localRecorder_:GetUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..3) == self.STR_TRUE);
    return (result1 and result2 and result3);
end


--[[
    复杂的要死的开场greeting
]]--
function NewYearController:StartSceneGreeting()
    print("markunlockDate:" .. self.unLockIndex_);
    print("markDayIndex:" .. self.dayIndex_);
    if self.dayIndex_ == -1 then 
        if self.clearData_.PublicTime == 1 then 
            self:getView():XBLGreetingTipDate1();
        elseif  self.clearData_.PublicTime == 2 then
            self:getView():XBLGreetingTipDate2();
        end
    elseif self.unLockIndex_ >= 4 and self.dayIndex_>=4 and self:IsCheerAllTask() then 
        self:getView():XBLNormalGreeting(function()
            
        end);
    else 
        --print("Gushi_LMMDress_1:"..self.localRecorder_:RecordFullAreaData("Gushi_LMMDress_" .."1_"..curIdStr));
        -- if self.dayIndex_ < 1 or self.dayIndex_ > self:GetActivityDay() then 
        --     return ;
        -- end
        
        --self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY 
        local strIsFirstEnterActivity = self.localRecorder_:GetUserData(self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY );
        if strIsFirstEnterActivity == self.STR_FALSE then 
            self:getData():LockAllItems();
            Utils:GetInstance():baiduTongji("qunahuodongMD","310_op_start")
            -- todo first enter activity
            self:getView():XBLSendTask(function() 
                self:getData():UnlockItemsByRange(1,1);
                self:getView():XBLSendTaskByDayIndex(1);
                Utils:GetInstance():baiduTongji("qunahuodongMD","310_op_skip")
            end);
            self:getData():UnShinyAllItem();
            self:getData():ShinyItemByDayIndex(1);
            self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY ,self.STR_TRUE);
            self.localRecorder_:RecordUserDataToday(self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY,self.STR_TRUE);
        else 
            print("11111111111111111111111");
        
            local func = function() 
                -- todo not first time enter activity
                local strIsFirstEnterToday = self.localRecorder_:GetUserDataToday(self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY);
                if strIsFirstEnterToday == self.STR_FALSE then 
                    print("22222222222222222222222222222222");
                    local rear = math.min(self.unLockIndex_ ,self.dayIndex_);
                    -- todo is first enter today
                    self:getView():XBLSendTaskByDayIndex(rear);
                    -- todo record teday come here before.
                    self.localRecorder_:RecordUserDataToday(self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY,self.STR_TRUE);
                else 
                    -- todo not first enter today
                    print("33333333333333333333333");
                    -- 1 try cheer complie
                    local rear = g_tConfigTable.TRY_ENTER_INDEXX;
                    if rear ~= nil then 
                        print("4444444444444444444444444444444");
                        rear =math.max(math.min(rear,self:GetActivityDay()),1) ;
                        if rear>0 and rear< self:GetActivityDay() then 
                            print("rear:".. rear .."5555555555555555555555555555555555"..self.localRecorder_:GetUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..rear));
        
                            --self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE;
                            --self.dayIndex_;
                            local curIdStr = UInfoUtil:getInstance():getCurUidStr();
                            local isTodayTaskComplie = (self.localRecorder_:GetFullAreaData("Gushi_LMMDress_" .. rear .. "_"..curIdStr) ~= self.STR_FALSE);
                            local isCheerUp = (self.localRecorder_:GetUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..rear) == self.STR_TRUE);
                            if isCheerUp == false then 
                                print("6666666666666666666666666666666666");
                                if isTodayTaskComplie then 
                                    print("7777777777777777777777777777777777777777");
                                    Utils:GetInstance():baiduTongji("qunahuodongMD","310_task"..rear.."_success")
                                    -- todo lock next ..
                                    local rearIndex = math.min(self.dayIndex_,self:getData():GetAimTaskIndex()) 
                                    if rearIndex ~=  g_tConfigTable.TRY_ENTER_INDEXX then 
                                        self:getView():ItemTempLock(rearIndex);
                                    end

                                    self:getView():XBLCheerTaskComplieByDayIndex(rear,function()
                                        local rearIndex = math.min(self.dayIndex_,self:getData():GetAimTaskIndex()) 
                                        if rearIndex > rear then 

                                            -- todo unlock next
                                            --self:getView():ItemTempLock(rearIndex);

                                            print("8888888888888888888888888888888888888888");
        
                                            self:getView():XBLContinueTellTaskByIndex(rearIndex);
                                        else 
                                            print("9999999999999999999999999999999999999999999999");
        
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
                            local isTodayTaskComplie = (self.localRecorder_:GetFullAreaData("Gushi_LMMDress_" .. rear .. "_"..curIdStr) ~= self.STR_FALSE);
                            local isCheerUp = (self.localRecorder_:GetUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..rear) == self.STR_TRUE);
                            if isCheerUp == false then 

                                print("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
                                if isTodayTaskComplie then 
                                    Utils:GetInstance():baiduTongji("qunahuodongMD","310_task"..rear.."_success")
                                    Utils:GetInstance():baiduTongji("qunahuodongMD","310_end_start")
                                    self:getView():XBLCheerTaskComplieByDayIndex(rear,function() 

                                        print("pause Bgm");
                                        SoundUtil:getInstance():stopBackgroundMusic(
                                            g_tConfigTable.sTaskpath.."audio/public_bgm_0112.mp3"
                                        );
                                        --SoundUtil:getInstance():pauseBackgroundMusic();
                                        self.isShowPaoPao_ = true;
                                        print("bbbbbbbbbbbbbbbbbbbbbbbbb");
                                        self:getView():LMMActivityEnd(function(eventName) 
                                            print("ccccccccccccccccccccccccccccccc"..eventName);
                                            if eventName == "go" then 
                                                self:getView():StartSendSnowBallSeq()
                                            elseif eventName == "out" then 
                                                self:getView():StopSendSnowBallSeq();
                                                self.isShowPaoPao_ = false;
                                                --g_tConfigTable.SceneNow_:moduleSuccess();
                                            end

                                            if eventName == "Complie" then 
                                                --SoundUtil:getInstance():resumeBackgroundMusic();
                                                SoundUtil:getInstance():playBackgroundMusic(
                                                    g_tConfigTable.sTaskpath.."audio/public_bgm_0112.mp3",
                                                    true
                                                );
                                                print("resume Bgm");
                                                Utils:GetInstance():baiduTongji("qunahuodongMD","310_end_skip")

                                            end
                                        end);
                                        -- todo here add script ..
                                        self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..rear,self.STR_TRUE)
                                    end);
                                    return ;
                                end
                            end
                        end
                    end
                    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
                    if self.localRecorder_:GetFullAreaData("Gushi_LMMDress_" .."3_"..curIdStr) ~= self.STR_FALSE then
                        -- 3 try remeber task
                       ---self:getView():LMMActivityEnd2(function(eventName)
                       ---    if eventName == "go" then 
                       ---    else 
                       ---    end
                       ---end);
                       self:getView():XBLNormalGreeting(function()
        
                       end);
                    else 
                        if self.unLockIndex_>self.dayIndex_ then 
                            self:getView():XBLRemeberTaskByDayIndex(self.unLockIndex_,function (  )
                                -- body
                            end);
                        else 
                            self:getView():XBLSendTaskByDayIndex(self.unLockIndex_,function (  )
                                -- body
                            end);
                        end
                    end
                end
            end

            func();
        end
    end
end

function NewYearController:NullInfoOut(cb)
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


function NewYearController:OnUserClickXBL()
    if self.isShowPaoPao_ then 
        return;
    end

    if self.dayIndex_ == -1 then 
        if self.clearData_.PublicTime == 1 then 
            self:getView():XBLClickUnOpenRandPlay1();
        elseif self.clearData_.PublicTime == 2 then 
            self:getView():XBLClickUnOpenRandPlay2();
        end
        return ;
    end
    print(" NewYearController:OnUserClickXBL:"..self.unLockIndex_);
    local rearIndex = math.min(self.dayIndex_,self:getData():GetAimTaskIndex());
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();

    if self.unLockIndex_>=4 then 
        self:getView():XblClickRandPlay2();
        print("XblClickRandPlay2");

    else 
        print("Gushi_LMMDress_" .. rearIndex .. "_"..curIdStr);
        local isTodayTaskComplie = (self.localRecorder_:GetFullAreaData("Gushi_LMMDress_" .. rearIndex .. "_"..curIdStr) ~= self.STR_FALSE);
        if isTodayTaskComplie == false then 
            self:getView():ClickXBLTipUpTask(rearIndex,function() end);
            print("ClickXBLTipUpTask");

        else 
            self:getView():XblClickRandPlay();
            print("XblClickRandPlay");
        end
    end
    print("OnUserClickXBL end:");


end

function NewYearController:OnUserClickLMM()
    if self.isShowPaoPao_ then 
        return;
    end

    if self.dayIndex_ == -1 then 
        self:getView():LmmClickUnOpenRandPlay();
        return ;
    end
    print(" NewYearController:OnUserClickXBL");
    local rearIndex = math.min(self.dayIndex_,self:getData():GetAimTaskIndex());
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();


    if self.unLockIndex_>=4 then 
        self:getView():LmmClickRandPlay(self.unLockIndex_);
    else 
        local isTodayTaskComplie = (self.localRecorder_:GetFullAreaData("Gushi_LMMDress_" .. rearIndex .. "_"..curIdStr) ~= self.STR_FALSE);
        if isTodayTaskComplie == false then 
            self:getView():ClickLMMTipUpTask(rearIndex,self.unLockIndex_,function() end);
        else 
            self:getView():LmmClickRandPlay(self.unLockIndex_,function() end)
        end
    end


end

function NewYearController:OnUserClickLockItem(index)
    if self.isShowPaoPao_ then 
        return;
    end
    if self.dayIndex_ == -1 then 
        self:getView():ItemLockedUnOpen();
        return ;
    end
    if index <= self.dayIndex_ then 
        self:getView():XBLTellLockedToday(function() end);
    else 
        self:getView():XBLTellItemLocked(function() end);
    end
    
end
function NewYearController:OnUserClickDownloadingItem()
    if self.isShowPaoPao_ then 
        return;
    end
    self:getView():XBLTellItemDownloading(function() end);

end
function NewYearController:OnUserClickEnterPackage(i,enterCb)
    if self.isShowPaoPao_ then 
        return;
    end
    if self.unLockIndex_>=4 then 
        self:getView():XBLTellItemEnter2(i,function(e) 
            if enterCb~=nil then 
                enterCb(e);
            end
        end);
    else
        local curIdStr = UInfoUtil:getInstance():getCurUidStr();
        local result = self.localRecorder_:GetFullAreaData("Gushi_LMMDress_"..i.."_"..curIdStr);
        if result ~= self.STR_FALSE then 
            self:getView():XBLTellItemEnter2(i,function(e) 
                if enterCb~=nil then 
                    enterCb(e);
                end
            end);
        else 
            self:getView():XBLTellItemEnter(i,function(e) 
                if enterCb~=nil then 
                    enterCb(e);
                end
            end);
        end

    end
end
--
function NewYearController:initClearData()
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

--function NewYearController
function NewYearController:RefreshData()
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY ,self.STR_FALSE);
    self.localRecorder_:RecordUserDataToday(self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY,self.STR_FALSE);
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..3,self.STR_FALSE)
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..2,self.STR_FALSE)
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE..1,self.STR_FALSE)
    self.localRecorder_:RecordFullAreaData("Gushi_LMMDress_" .."1_"..curIdStr,self.STR_FALSE);
    self.localRecorder_:RecordFullAreaData("Gushi_LMMDress_" .."2_"..curIdStr,self.STR_FALSE);
    self.localRecorder_:RecordFullAreaData("Gushi_LMMDress_" .."3_"..curIdStr,self.STR_FALSE);


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
function NewYearController:Start(rootNode,view,data)

    --[[
    local strVersion =  Utils:GetInstance():getXBLVersion()
    writeToFile("version:"..strVersion);
    print("version:"..strVersion);
    if 
    strVersion == "8.7.0" or 
    strVersion == "8.7.1" or 
    strVersion == "8.7.2" or 
    strVersion == "8.7.3" or 
    strVersion == "8.7.4" or 
    strVersion == "8.7.5" or 
    strVersion == "8.7.6" or 
    strVersion == "8.7.7" 
    then 
        print("path1:"..g_tConfigTable.sTaskpath.."node_con_2_310.info");
        writeToFile("path1:"..g_tConfigTable.sTaskpath.."node_con_2_310.info");
        MenuItemNetData:getInstance():copyDefaultInfoToSaveInfo(g_tConfigTable.sTaskpath .. "node_con_2_310.info", 2, 310, true );
        MenuItemNetData:getInstance():startToGetPackageMenuDataLua(2,"310",strVersion,true,function() 
            print("get gift ok start");
            writeToFile("get gift ok start");
            if self:getView() ~= nil then 
                print("update start");
                writeToFile("update start");
                self:getView():UpdateItemStateList();
                print("update stop");
                writeToFile("update stop");
            end
            print("get gift ok end");
            writeToFile("get gift ok end");
    
        end,cc.Node:create());
    end
    ]]--


    Utils:GetInstance():baiduTongji("qunahuodongMD","310_enter_touchafter")

    self:initClearData();

    self.localRecorder_ = LocalRecordManager.new();

    local strPt = self.localRecorder_:GetUserData("PT");
    if strPt ~= self.clearData_.PublicTime.."" then 
        self:RefreshData();
        self.localRecorder_:RecordUserData("PT",""..self.clearData_.PublicTime);
    end

    if NewYearController.DEBUG_IS_CLEAR_LOCAL_DATA then 
        self:clearLocalData();
    end
    SoundUtil:getInstance():playBackgroundMusic(
        g_tConfigTable.sTaskpath.."audio/public_bgm_0112.mp3",
        true
    );

    self:SetActivityDay(3); -- 设置活动时长
    BaseController.Start(self,rootNode,view,data);
    
    if self.isError_ then 
        return;
    end


    self:setActivityStartDate(
        self.clearData_.Date.Year,
        self.clearData_.Date.Month ,
        self.clearData_.Date.Day ,
        self.clearData_.Date.Hour,
        self.clearData_.Date.Min ,
        self.clearData_.Date.Sec ); -- 设置活动日期
        
    self:DelayCallBack(0.1,function()
        self:StartSceneGreeting();
    end);
    self:StartSendChatSeq();


    print("playBgm---------------------------");
end


--[[
    通过这个方法终止sys
    撤销:
        View
        data
]]--
function NewYearController:Stop()
    SoundUtil:getInstance():stopBackgroundMusic(
        g_tConfigTable.sTaskpath.."audio/public_bgm_0112.mp3"
    );
    print("stop playBgm---------------------------");

    self.localRecorder_:SaveToLocal();
    BaseController.Stop(self);
end

return NewYearController;

--[[

    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY ,self.STR_TRUE);
    self.localRecorder_:RecordUserDataToday(self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY,self.STR_TRUE);
    g_tConfigTable.TRY_ENTER_INDEXX = 1;

    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    self.localRecorder_:RecordFullAreaData("Gushi_LMMDress_" .."1_"..curIdStr,self.STR_TRUE);
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE.."_1",self.STR_FALSE)



    测图标
        self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_FIRST_ENTER_ACTIVITY ,self.STR_TRUE);
    self.localRecorder_:RecordUserDataToday(self.STR_LOCAL_EVENT_FIRST_ENTER_TODAY,self.STR_TRUE);
    g_tConfigTable.TRY_ENTER_INDEXX = 1;

    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    self.localRecorder_:RecordFullAreaData("Gushi_LMMDress_" .."1_"..curIdStr,self.STR_TRUE);
    self.localRecorder_:RecordUserData(self.STR_LOCAL_EVENT_CHEER_TASK_COMPLIE.."_1",self.STR_FALSE)
   -- self.localRecorder_:RecordFullAreaData("Gushi_LMMDress_".. "2_"..curIdStr,self.STR_TRUE);
]]--