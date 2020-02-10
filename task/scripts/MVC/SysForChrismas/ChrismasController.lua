
local JsonScriptUtil = requirePack("scripts.Utils.JsonScriptUtil");
local FileUtil = requirePack("scripts.Utils.FileUtil");
local ChrismasView = requirePack("scripts.MVC.SysForChrismas.ChrismasView");
local ChrismasData = requirePack("scripts.MVC.SysForChrismas.ChrismasData");

local file =requirePack("baseScripts.homeUI.packageStory.filecon");


local BaseController = requirePack("scripts.MVC.Base.BaseController");


local ChrismasController = class("ChrismasController",function() 
    return BaseController.new();
end);
g_tConfigTable.CREATE_NEW(ChrismasController);

function ChrismasController:ctor()
    -- 定义所有使用过的成员在这里..
    self.rootNode_ = nil;                --玩法根节点

    self.isPlayBGM_ = true;

    self.isUploading_ = false;

    self.xblLeadWord_ = "";
end

--[[
    通过这个方法传入sys所有需要的外部参数
    初始化:
        View
        data
    参数:
    rootNode:sys根节点
]]--
function ChrismasController:Start(rootNode)

    print("cactch7748");
    local size1 = cc.Director:getInstance():getWinSize();
    dump(size1);
    local size2 = VisibleRect:winSize();
    dump(size2);
    print("width:"..size2.width);
    print("width:"..size2.height);

    JsonScriptUtil.SetJsonPath(
        g_tConfigTable.sTaskpath .. "sayHelloGuide/story/",
        g_tConfigTable.sTaskpath .. "image/",
        g_tConfigTable.sTaskpath .. "audio/"
    );

    self.rootNode_ = rootNode;

    self:setView(ChrismasView.new());--
    self:setData(ChrismasData.new());--
    
    self.rootNode_:addChild(self:getView());

    self:getView():setController(self);
    self:getData():setController(self);

    self:getView():Init();
    self:getData():Init();

    self:getData():SetUpdateDataCallBack(
        function(d) 
            self:getView():Update(d);
        end
    );
    self:getView():setPosition(cc.p(size2.width/2,size2.height/2));

    self:start();
end


function ChrismasController:start()
    local choseList = self:getData():GetData().TempDecorationOptions;
    if choseList[1] == -1 or choseList[2] == -1 or choseList[3] == -1  then 
        self:getData():UpdateData()
        self:getView():XblCueDecorationStep(1);
        self:getView():StartFingerTipSeq();
    else 
        self:getData():GetData().ViewType = ChrismasData.EnumViewType.E_OLD;
        --self:getView():setCardThingUpMode();
        self:getView():XblCueGetGift();
        self:getData():UpdateData();
        self:getView():StopAllJsonActions();
    end
end



--[[
    通过这个方法终止sys
    撤销:
        View
        data
]]--
function ChrismasController:Stop()
    self:getView():Dispose();
    self:getData():Dispose();
end

function ChrismasController:OnUserClickReCreateCard()
    self:getView():setCardThingDownMode();
    self:getData():GetData().ViewType = ChrismasData.EnumViewType.E_DECORATION;
    self:getData():GetData().DecorationStep = 1;
    self:getData():UpdateData()
    self:getView():XblCueDecorationStep(1);
    self:getView():StartFingerTipSeq();
    self:getView():ClearCardShowStatus();
    self:getData():ClearTempCardData();
end


--[[
    用户点击某一个装饰item
]]--
function ChrismasController:OnUserSelectDecorationItem(item)
    local step = self:getData():GetData().DecorationStep;
    self:getView():StopFingerTipSeq();

    self:getView():XblCue(item:GetData().jsonName);
    if step == 1 then 
        self:OnTryDecorationByIndex( item:GetData().index);
    else 
        self:getView():ShowItemFlyToAimByItem(item);
    end
    self:getData():SetUserDecorationOptionsByStepAndIndex(step,item:GetData().index);
    self:getView():ShowNextBtn();
    self:getView():StartToNextBtnHurrySeq();

    local eventName = ""
    if step == 1 then 
        eventName = "xmas19_click_background"
    elseif step == 2 then 
        eventName = "xmas19_click_element"
    elseif step == 3 then 
        eventName = "xmas19_advantage"
    end
    self:getData():CallBaiduEventEnd(eventName..item:GetData().RI);

end

function ChrismasController:OnTryDecorationByIndex(index)
    local step = self:getData():GetData().DecorationStep;
    if step == 1 then 
        local oriOptionIndex = self:getData():GetData().TempDecorationOptions[step];
        dump(self:getData():GetData().TempDecorationOptions);
        print("option:" .. oriOptionIndex);
        self:getView():SwitchCardByIndex(index,oriOptionIndex);
    elseif step == 2 then 
        self:getView():SwitchDecorationByIndex(index);
    elseif step == 3 then 
        self:getView():SwitchWordByIndex(index);
    end
end

function ChrismasController:OnUserClickNextMove()
    local vType = self:getData():GetData().ViewType;
    if vType == ChrismasData.EnumViewType.E_DECORATION then 
        local step = self:getData():GetData().DecorationStep;

        local eventName = "";
        if step == 1 then 
            print("step=====================================1");
            eventName = "xmas19_next_background";
        elseif step == 2 then 
            eventName = "xmas19_next_element";
        elseif step == 3 then 
            eventName = "xmas19_next_advantage";
        end
        self:getData():CallBaiduEventEnd(eventName);

        if step < 3 then 
            step = step + 1;
            self:getData():GetData().DecorationStep = step;
            self:getData():UpdateData();
            self:getView():XblCueDecorationStep(step );
            self:getView():StartFingerTipSeq();
        else
            self:getData():GetData().ViewType = ChrismasData.EnumViewType.E_RECORD_AUDIO;
            self:getData():UpdateData();
            self:getView():XblCueRecodeAudio();
        end

        

    elseif vType == ChrismasData.EnumViewType.E_RECORD_AUDIO then 
        self:getData():GetData().ViewType = ChrismasData.EnumViewType.E_FINISH;
        self:getData():UpdateData();
        --self:getView():XblCueFinish();

        self:getData():CallBaiduEventEnd("xmas19_next_record");
    end
end

function ChrismasController:OnUserClickRecordAudio()
    
    self:deleteTmpAudio();
    self:getView():setViewAsRecordingMode();
    self:getView():XblCueLoveParent(function() 
        print("mark4");
        self.isUploading_ = true;
        self:getView():StartRecord(function()
            self.isUploading_  = false;
            print("mark2");
            
            self:getView():XblCueAudioToPoint(function() 
                self:getView():setViewAsRecordComplieMode();
                self:getData():SetUserDecorationOptionsByStepAndIndex(4,1);
                print("mark1");
                self:copyAudioToSave();
                self:OnUserPlayItsAudio();
                -- todo copy to aim

                self:getView():BtnNextStopHurry();
                self:getView():StartToNextBtnHurrySeq();
            end);
        end);
    end);


    self:getData():CallBaiduEventEnd("xmas19_click_record");
end

function ChrismasController:OnUserClickReRecordAudio ( )
    self:getData():UpdateData();
    self:getView():XblCueRecodeAudio();

    self:getData():CallBaiduEventEnd("xmas19_record_again");
end

function ChrismasController:deleteTmpAudio( )
    local path = GET_REAL_PATH_ONLY("menuinfo/lastmicaudio.wav",PathGetRet_ONLY_SD);
    if file.exists(path) then 
        file.remove(path);
    end

    if file.exists(path) then 
        writeToFile("file delete success");
    else
        writeToFile("file Delete fail");
    end
end

function ChrismasController:copyAudioToSave()
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    local path = GET_REAL_PATH_ONLY("menuinfo/lastmicaudio.wav",PathGetRet_ONLY_SD);
    if file.exists(path) then 
        local aimPath = GET_REAL_PATH_ONLY("",PathGetRet_ONLY_SD) .. "xialingyingTemp/".."user_"..curIdStr.."_cardAudio.wav"
        file.copy(path,aimPath);
    else 
        if self.xblLeadWord_ ~= "" then 
            path = g_tConfigTable.sTaskpath.. "sounds/"..self.xblLeadWord_ .. ".mp3";
        else
            path = g_tConfigTable.sTaskpath.. "sounds/Xmas127.mp3"
        end
        local str = "record fail path:"..path;
        print(str);
        writeToFile(str);
        local aimPath = GET_REAL_PATH_ONLY("",PathGetRet_ONLY_SD) .. "xialingyingTemp/".."user_"..curIdStr.."_cardAudio.wav"
        file.copy(path,aimPath);
    end

end

function ChrismasController:OnUserPlayItsAudio()
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    local aimPath = GET_REAL_PATH_ONLY("",PathGetRet_ONLY_SD) .. "xialingyingTemp/".."user_"..curIdStr.."_cardAudio.wav"
  
    local str = "Play path:"..aimPath;
    print(str);
    writeToFile(str);
   
    if file.exists(aimPath) then 
        self:getView():StartAudioAnim(); 
        
        SoundUtil:getInstance():playLua(aimPath,aimPath,function()
            self:getView():StopAudioAnim();
        end);
    end
    print("OnUserPlayItsAudio");
    writeToFile("OnUserPlayItsAudio");

    self:getData():CallBaiduEventEnd("xmas19_click_play");
end

function ChrismasController:OnUserClickBGMToggle(  )
    if self.isPlayBGM_  then 
        self.isPlayBGM_  = false;
    else
        self.isPlayBGM_  = true;
    end
    self:getView():setBGMToggle(self.isPlayBGM_);
    -- todo play or stop bgm
end

function ChrismasController:OnUserRecordSuccess()
    self:getData():CallBaiduEventEnd("xmas19_recordok");
end

function ChrismasController:TryUploadData(cb)
    self.strUploadResult = "";
    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    local aimPath = GET_REAL_PATH_ONLY("",PathGetRet_ONLY_SD) .. "xialingyingTemp/".."user_"..curIdStr.."_cardAudio.wav";

    UploadManager:GetInstance():UploadExDefaultUrlLua(
        aimPath,1,3,MOUDULE_XIALINGYING, XiaLingYingData:getInstance():getTargetBagId(),"recordAudio","",
        function(result) 
            print("result:"..result..":");
            writeToFile("result1:"..result);
            
            if result == "post fail" then 
                if cb ~= nil then 
                    writeToFile("11111111111111111111111111111");
                    cb(false);
                end
            else 
                local m1 = globalJsonDecode(result);
                self.strUploadResult = m1.shortcode;

                UploadManager:GetInstance():UploadExDefaultUrlLua(
                    cc.FileUtils:getInstance():getWritablePath().."ChrisMasCard.png",1,3,MOUDULE_XIALINGYING, XiaLingYingData:getInstance():getTargetBagId(),"cardScreenShot","",
                    function(lresult) 
                        print(lresult);
                        writeToFile("result2:"..lresult);
                        if lresult == "post fail" then 
                            if cb ~= nil then 
                                writeToFile("2222222222222222222222222222222222");
                                cb(false);
                            end
                        else 
                            local m2 = globalJsonDecode(lresult);
                            self.strUploadResult = self.strUploadResult.."|".. m2.shortcode;
                            if cb ~= nil then 
                                writeToFile("33333333333333333333333333333333333");

                                cb(true,self.strUploadResult);
                            end
                        end
                    end);
            end
        end
    );
end

function ChrismasController:OnUserClickShare( ... )
    if self.isUploading_ == false then 
        self.isUploading_ = true;
        writeToFile("result0.5:" );
        self:TryUploadData(function(result,str)
            self.isUploading_ = false; 
            writeToFile("result3.5:"..self.strUploadResult );
            if result then 
                writeToFile("result3:"..self.strUploadResult );
                UInfoUtil:getInstance():startToShowWeiXinDingYueLua(
                    103,-- debug
                    self.strUploadResult
                    ,function(d) 
                         if d == 2 then 
                            self:getData():CallBaiduEventEnd("xmas19_share_success");
                         else 
                            --self:getView():XblCueShowToParent();
                         end
                         
                    end);
    
                    self:getView():runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function() 
                        self:getData():GetData().ViewType = ChrismasData.EnumViewType.E_GET_GIFT;
                        self:getData():UpdateData();
                        self:getView():XblCueSendForParent(function()
                           self:getView():StartXBLCueGetGift();
                        end);
                    end)));
                    
            else
                --self:getView():XblCueShowToParent();
                self:getView():XblCueSendForParent(function()
                    self:getView():StartXBLCueGetGift();
                end);
                self:getData():GetData().ViewType = ChrismasData.EnumViewType.E_GET_GIFT;
                self:getData():UpdateData();
                writeToFile("result4:"..self.strUploadResult );
            end
           -- 
        end);
        self:getData():CallBaiduEventEnd("xmas19_click_share");
    end
end

function ChrismasController:OnUserClickSendCard( ... )
    if self.isUploading_ == false then 
        self.isUploading_ = true;
        writeToFile("result0.5:" );
        self:TryUploadData(function(result,str)
            self.isUploading_ = false; 
            writeToFile("result3.5:"..self.strUploadResult );
            if result then 
                writeToFile("result3:"..self.strUploadResult );
                UInfoUtil:getInstance():startToShowWeiXinDingYueLua(
                    103,-- debug
                    self.strUploadResult
                    ,function(d) 
                         if d == 2 then 
                            self:getData():CallBaiduEventEnd("xmas19_share_success");
                         else 
                            --self:getView():XblCueShowToParent();
                         end
                         
                    end);
    
                    self:getView():runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function() 
                        self:getData():GetData().ViewType = ChrismasData.EnumViewType.E_GET_GIFT;
                        self:getData():UpdateData();
                        self:getView():XblCueSendForParent(function()
                           self:getView():StartXBLCueGetGift();
                        end);
                    end)));
                    
            else
                --self:getView():XblCueShowToParent();
                self:getView():XblCueSendForParent(function()
                    self:getView():StartXBLCueGetGift();
                end);
                self:getData():GetData().ViewType = ChrismasData.EnumViewType.E_GET_GIFT;
                self:getData():UpdateData();
                writeToFile("result4:"..self.strUploadResult );
            end
           -- 
        end);
        self:getData():CallBaiduEventEnd("xmas19_task1_send");
    end
end

function ChrismasController:OnUserClickCheckAll(  )
    -- body
    self:getView():closeCheckAllBtn();
    self:getView():closeRecordAudioBtn();
    self:getView():setComplieUIItemVisible(false);
    self:getView():XblCueFinish(false,function() 

            self:getView():XblCueShowToParent();
            self:getData():GetData().ViewType = ChrismasData.EnumViewType.E_SHARE;
            self:getData():UpdateData();
            self:getView():screenShotCardByData(self:getData():GetData().TempDecorationOptions);
    end);
    
    self:getData():SaveCardData();

    self:getData():CallBaiduEventEnd("xmas19_task1_done");
end

function ChrismasController:OnUserClickBackToMain( ... )
    if self.isUploading_ == false then 
        self:getData():CallBaiduEventEnd("xmas19_click_getgift");

        self:getView():StopAllJsonActions();
        self:isSuccess(true);
        xblStaticData:clearKeepFrom();
        xblStaticData:gotoSource(MOUDULE_XIALINGYING,MOUDULE_XIALINGYING, "21",STORY4V_TYPE_UNKNOW);
    end
end

function ChrismasController:OnUserRealBackHome()
    if self.isUploading_ == false then 
        local eventName = "";
        if self:getData():GetData().ViewType == ChrismasData.EnumViewType.E_DECORATION then 
            print("print -------------------->step:"..self:getData():GetData().DecorationStep);
            if self:getData():GetData().DecorationStep == 1 then 
                eventName = "xmas19_cancel_background";
            elseif self:getData():GetData().DecorationStep == 2 then 
                eventName = "xmas19_cancel_element";
            elseif self:getData():GetData().DecorationStep == 3 then 
                eventName = "xmas19_cancel_advantage";
            end
        else
            print("print -------------------->step:"..4);
            eventName = "xmas19_cancel_record";
        end
        if eventName ~= "" then 
            self:getData():CallBaiduEventEnd(eventName);
        end
    
        local step = self:getView():GetProcessStep();
    
        self:getView():StopAllJsonActions();
        self:isSuccess((step >= 4));
        xblStaticData:clearKeepFrom();
        xblStaticData:gotoSource(MOUDULE_XIALINGYING,MOUDULE_XIALINGYING, "21",STORY4V_TYPE_UNKNOW);
        if (step >= 4) then 
            print("get gift");
        else 
            print("dont get gift");
        end
    end
end

function ChrismasController:OnUserClickBackHome()
    if self:getData():IsFinishedCard() then 
        self:OnUserRealBackHome();
    else
        local step = self:getView():GetProcessStep();
        if step>=4  then 
            self:OnUserRealBackHome();
        else
            self:getView():ShowLeaveViewByStep(step);
        end
    end
end

function ChrismasController:isSuccess(suc)
    local nUid = UInfoUtil:getInstance():getCurUidStr();
    local activityId = XiaLingYingData:getInstance():getActivityId();
    local subActivityId = XiaLingYingData:getInstance():getSubActivityId();
    local savePath = GET_REAL_PATH_ONLY(
        "",
        PathGetRet_ONLY_SD) .. "xialingyingTemp/userInfo_"..nUid.."_"..activityId.."_"..subActivityId..".json";
    
    local cjson = require("cjson")
    local JsonData = requirePack("baseScripts.homeUI.JsonData", false);  -- 用来读取数据
    local jsonData = JsonData.new() --获取数据
    local userInfo = jsonData:ReadJsonFileContentTable(savePath) or {};
    local bagId = XiaLingYingData:getInstance():getTargetBagId()
    if(userInfo["success"..bagId] == nil) then
        if (suc) then
            userInfo["success"..bagId] = 1
        else
            userInfo["success"..bagId] = 0
        end
    else
        if (suc) then
            userInfo["success"..bagId] = 1
        end
    end
    jsonData:WriteFilePath(savePath,cjson.encode(userInfo));
end

function ChrismasController:GetIsSuccess()
    local nUid = UInfoUtil:getInstance():getCurUidStr();
    local activityId = XiaLingYingData:getInstance():getActivityId();
    local subActivityId = XiaLingYingData:getInstance():getSubActivityId();
    local savePath = GET_REAL_PATH_ONLY(
        "",
        PathGetRet_ONLY_SD) .. "xialingyingTemp/userInfo_"..nUid.."_"..activityId.."_"..subActivityId..".json";
    
    local cjson = require("cjson")
    local JsonData = requirePack("baseScripts.homeUI.JsonData", false);  -- 用来读取数据
    local jsonData = JsonData.new() --获取数据
    local userInfo = jsonData:ReadJsonFileContentTable(savePath) or {};
    local bagId = XiaLingYingData:getInstance():getTargetBagId()
    if(userInfo["success"..bagId] == nil) then
        return false;
    else
        if userInfo["success"..bagId] == 1 then 
            return true;
        else
            return false;
        end
    end
end


return ChrismasController;