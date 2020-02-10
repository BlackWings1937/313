local JsonConfig = {};
JsonConfig.SendTasksList = {
    "lmmxnpd011",
    "lmmxnpd012",
    "lmmxnpd013"
}
JsonConfig.RemeberTask = {
    "lmmxnpd011",
    "lmmxnpd042",
    "lmmxnpd044",
}
--JsonConfig.ToDayTaskComplie = "lmmxnpd026";

JsonConfig.CheerTaskComplie = {
    "lmmxnpd031x",
    "lmmxnpd033x",
    "lmmxnpd035x",
}
JsonConfig.ContinueTellTask = {
    "lmmxnpd011",
    "lmmxnpd040",
    "lmmxnpd041",
}
JsonConfig.ConinueTellTaskTomorrow = {
    "lmmxnpd042",
    "lmmxnpd044",
}

JsonConfig.ClickXBLTipUp = {
    "lmmxnpd017",
    "lmmxnpd019",
    "lmmxnpd021",
} -- 小伴龙提醒

JsonConfig.ClickLmmTipUp = {
    "lmmxnpd018",
    "lmmxnpd020",
    "lmmxnpd022",
}-- 龙妹妹提醒

--[[

]]--

JsonConfig.ClickLmmRandSayA = { 
    "lmmxnpd024A",
    "lmm01005A",
    "lmm01006A",
    "xianzhi1A",
    "xianzhi2A",
    "xianzhi3A",
    "xianzhi4A",
}

JsonConfig.ClickLmmRandSayB = {
    "lmmxnpd024B",
    "lmm01005B",
    "lmm01006B",
    "xianzhi1B",
    "xianzhi2B",
    "xianzhi3B",
    "xianzhi4B",
}

JsonConfig.ClickLmmRandSayC = {
    "lmmxnpd024C",
    "lmm01005C",
    "lmm01006C",
    "xianzhi1C",
    "xianzhi2C",
    "xianzhi3C",
    "xianzhi4C",
}

JsonConfig.ClickLmmRandSayD = {
    "lmmxnpd024D",
    "lmm01005D",
    "lmm01006D",
    "xianzhi1D",
    "xianzhi2D",
    "xianzhi3D",
    "xianzhi4D",

    "lmm01004",
    "lmm01008",
    "lmm01009",
    "lmmxnpd052",
}



local ArmatureUtil = requirePack("scripts.Utils.ArmatureUtil"); 
local PathsUtil = requirePack("scripts.Utils.PathsUtil"); 
local SpriteUtil = requirePack("scripts.Utils.SpriteUtil"); 
local ButtonUtil = requirePack("scripts.Utils.ButtonUtil"); 
local JsonScriptUtil = requirePack("scripts.Utils.JsonScriptUtil");
local JAManager = requirePack("scripts.Tools.JAManager");

local NormalView = requirePack("scripts.MVC.SysForNormal.NormalView");
local ScaleProcess = requirePack("scripts.UI.ScaleProcess");
local ActivityItem = requirePack("scripts.UI.ActivityItem");
local SnowBall = requirePack("scripts.UI.SnowBall");

local NewYearView = class("NewYearView",function() 
    return NormalView.new();
end);
g_tConfigTable.CREATE_NEW(NewYearView);

function NewYearView:ctor()
    -- 定义所有使用过的成员在这里..
    self.listOfActivityItems_ = {};
    self.jaManager_ = nil;

    self.isShowPaoPao_ = false;

    self.isTellEnterPackage_ = false;
end

--[[
    方法 定义界面初始化
    包括:
        创建所有需要的显示对象 
        注册所有要使用的UI事件
]]--
function NewYearView:Init()
    self.jaManager_ = JAManager.new();
    self.jaManager_:SetStageNode(self);
    self.jaManager_:PlayBgConfig("bgconfig_zjm2");



    local time = os.date("%Y%m%d");
    --dump(time);
    --writeToFile("time--------------------------------:"..time);
    print("View init:"..time);

    -- create bg config SpriteUtil.Create(PathsUtil.ImagePath(""));
    self.spBg_ = SpriteUtil.Create(PathsUtil.ImagePath("191212lmm_bg.png"));
    self:addChild(self.spBg_);
    self.spBg_:setScale(1);
    self.spBg_:setPosition(cc.p(768/2,1024/2));

    -- create path
    --[[]]--
    self.armPathBG_ =  TouchArmature:create("191212lmm_lujin_yinying_twxm",TOUCHARMATURE_NORMAL);
    self:addChild(self.armPathBG_);
    self.armPathBG_:setPosition(SpriteUtil.ToFlashPoint(378,567));
   -- self.armPathBG_:setScale(0.42);



    self.armPath_ =  TouchArmature:create("19212lmm_luj_twxm",TOUCHARMATURE_NORMAL);
    self:addChild(self.armPath_);
    self.armPath_:setPosition(SpriteUtil.ToFlashPoint(378,567));
    self.armPath_:setScale(0.42);

    -- create stage
    self.spStage_ =  SpriteUtil.Create(PathsUtil.ImagePath("gui_wutai.png"));
    self:addChild(self.spStage_);
    SpriteUtil.SetLhPos(self.spStage_,cc.p(268,348));

    self.xbl_ = self:getChildByName("XBL");
    self.lmm_ = JsonScriptUtil.GetNpcByName(self,"npc_lmm");
    if self.xbl_ ~= nil then 
        print("self.xbl_ ~= nil");
        self.xbl_:setLuaTouchCallBack(function(nType, pTouchArm, pTouch)
            if nType == TouchArmLuaStatus_TouchEnded then 
            end
        end);
        local x,y = self.xbl_:getPosition();
        self.btnXBL_ = ButtonUtil.Create(
            PathsUtil.ImagePath("btnXbl.png"),
            PathsUtil.ImagePath("btnXbl.png"),
            function()
                print("click xbl");
                self:getController():OnUserClickXBL();
            end);
        self:addChild(self.btnXBL_);
        self.btnXBL_:setPosition(cc.p(x,y));
        self.btnXBL_:setScale(1);
    end
    if self.lmm_ ~= nil then 
        print("self.lmm_ ~= nil");
        self.lmm_:setLuaTouchCallBack(function(nType, pTouchArm, pTouch)
            if nType == TouchArmLuaStatus_TouchEnded then 
            end
        end);

        local x,y = self.lmm_:getPosition();
        self.btnLMM_ = ButtonUtil.Create(
            PathsUtil.ImagePath("btnXbl.png"),
            PathsUtil.ImagePath("btnXbl.png"),
            function()
                print("click lmm");
                self:getController():OnUserClickLMM();
            end);
        self:addChild(self.btnLMM_);
        self.btnLMM_:setPosition(cc.p(x,y));
        self.btnLMM_:setScale(1);

    end--
    --[[
    self:DelayCallBack(3,function()
        -- self:StartSceneGreeting();
        ArmatureUtil.PlayLoop(JsonScriptUtil.GetNpcByName(self,"npc_hg"));

        self:DelayCallBack(3,function()
            -- self:StartSceneGreeting();
            ArmatureUtil.PlayLoop(JsonScriptUtil.GetNpcByName(self,"npc_hg"));
        end);
    end);
]]--
    local commenTable = {};
    commenTable.ImageBtnItem                  =PathsUtil.ImagePath("btnItem.png") ;
    commenTable.ImageProcessBg                = PathsUtil.ImagePath("gui_jindu_bg.png");
    commenTable.ImageProcessContent           =PathsUtil.ImagePath("gui_jindu_s.png") ;
    commenTable.ImageDecorationProcess            =PathsUtil.ImagePath("gui_needdown.png") ;
    commenTable.ImageLock                         = PathsUtil.ImagePath("gui_lock_1.png") ;
    commenTable.ImageBg                         =   PathsUtil.ImagePath("gui_s1.png");
    commenTable.ImageUpdate                         =   PathsUtil.ImagePath("btn_gengxin.png");
    commenTable.ImageFix                         =   PathsUtil.ImagePath("btn_xiufu.png");
    commenTable.MenuType = 2;

    local itemList = {--187,255,169
        {ArmName = "191212lmm_huangguana1_twxm",BagId = 187,Pos = SpriteUtil.ToFlashPoint(439,673)},
        {ArmName = "191212lmm_gzq1_twxm",BagId = 255,Pos = SpriteUtil.ToFlashPoint(296,551)},
        {ArmName = "191212lmm_mfb1_twxm",BagId = 169,Pos = SpriteUtil.ToFlashPoint(470,514)},
    };
    local count = #itemList;
    for i = 1,count ,1 do 
        local data = itemList[i];
        local ai = ActivityItem.new(commenTable.MenuType,data.BagId);

        local str = ai:getMenuDataForLua();
        --if  i == 1 then 
        --    str = "";
        --end
        if str == "" then 
            local dcount = #self.listOfActivityItems_;
            if dcount>0 then 
                for z = 1,dcount ,1 do 
                    dump(self.listOfActivityItems_);
                    print("z:"..z);
                    local dItem = self.listOfActivityItems_[z];
                    if dItem ~= nil then 
                        dItem:setVisible(false);
                    end
                end
            end

            self:getController():NullInfoOut(function() 
               -- g_tConfigTable.SceneNow_:moduleSuccess();
            end);
            return;
        end

        self:addChild(ai);
        table.insert(self.listOfActivityItems_,ai);
        ai:Init(
            data.ArmName,
            commenTable.ImageBtnItem ,          
            commenTable.ImageProcessBg         ,
            commenTable.ImageProcessContent    ,
            commenTable.ImageDecorationProcess ,
            commenTable.ImageLock,
            commenTable.ImageUpdate,
            commenTable.ImageFix,
            self:getController(),
            commenTable.ImageBg                
        );
        ai:setPosition(data.Pos);
    end
end

function NewYearView:UpdateItemStateList()
    if self.listOfActivityItems_ ~= nil then 
        local count = #self.listOfActivityItems_;
        if count>0 then 
            for i = 1,count,1 do 
                local item = self.listOfActivityItems_[i];
                item:UpdateStateInit();
            end
        end
    end
end

--[[
    方法 撤销界面       
    包括:
        删除所有持有的显示对象 
        注销所有持有的UI事件
]]--
function NewYearView:Dispose()
    print("View dispose");
  
    self.jaManager_:Dispose();
end

function NewYearView:Update(data)
    local listOfIiemData = data.ListOfItems;
    local count =#listOfIiemData;
    for i = 1,count ,1 do 
        local itemData = listOfIiemData[i];
        local item = self.listOfActivityItems_[i];
        item:UpdateDataSelf(itemData);
    end
    self.lmm_:changeArmature("lmm2019_hz_twxm", 0);
    if data.AimTaskIndex ~= nil then 
        print("aimIndex:"..data.AimTaskIndex);
        if data.AimTaskIndex == 1 then 
            ArmatureUtil.PlayLoop(self.lmm_,0);
            ArmatureUtil.PlayLoop(self.armPath_,7);
        elseif data.AimTaskIndex == 2 then 
            ArmatureUtil.PlayLoop(self.lmm_,48);
            ArmatureUtil.PlayLoop(self.armPath_,2);
        elseif data.AimTaskIndex == 3 then 
            ArmatureUtil.PlayLoop(self.lmm_,51);
            ArmatureUtil.PlayLoop(self.armPath_,4);
        elseif data.AimTaskIndex == 4 then 
            ArmatureUtil.PlayLoop(self.lmm_,53);
            ArmatureUtil.PlayLoop(self.armPath_,6);
        end
    else 
        ArmatureUtil.PlayLoop(self.armPath_,7);
    end
end

function NewYearView:RandPlayByList(list,cb,tag)
    if list ~= nil then 
        local count = #list;
        if count > 0 then 
            local rand = math.random( 1,count );
            local jsonName = list[rand];
            self.jaManager_:Play(jsonName,cb,tag);
        end
    else 
        writeToFile("Error:List == nil");
        writeToFile(debug.traceback(  ));
    end
    

end

function NewYearView:RandSendSnowBall()
    local y = 0;
    local x = math.random( 1,767 );
    local ball = SnowBall.new();
    ball:Init("191212lmm_paopaom_twxm",PathsUtil.ImagePath("btnSnowBall.png"),self:getController());
    self:addChild(ball,100009);
    ball:setPosition(cc.p(x,y));
    ball:runAction(cc.Sequence:create(cc.MoveBy:create(10,cc.p(0,1234)),cc.CallFunc:create(function() 
        --ball:OnUserClick();
        ball:removeFromParent();
    end)));
end

function NewYearView:StartSendSnowBallSeq()
    local tag = 1008;
    local req = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(
        function()
            self:RandSendSnowBall(); 
        end
    )));
    req:setTag(tag);
    self:runAction(req);
end

function NewYearView:StopSendSnowBallSeq()
    local tag = 1008;
    self:stopActionByTag(tag);
end

-- ----- view 界面动画表演 -----
JsonConfig.XBLNormalGreeting = "lmmxnpd057";
function NewYearView:XBLNormalGreeting(cb)
    --self.jaManager_:Play
    self.jaManager_:Play(JsonConfig.XBLNormalGreeting,cb,6);
end


JsonConfig.EndActivity2 = "191212hd_end2";
function NewYearView:LMMActivityEnd2(cb)
    --self.jaManager_:Play
    self.jaManager_:Play(JsonConfig.EndActivity2,cb,6);
end

JsonConfig.EndActivity1 = "191212hd_end1";
function NewYearView:LMMActivityEnd(cb)
    --self.jaManager_:Play
    self.jaManager_:Play(JsonConfig.EndActivity1,cb,6);
end


JsonConfig.FirstSendTask = "191212lmm_op";
function NewYearView:XBLSendTask(cb)
    --self.jaManager_:Play
    self.jaManager_:Play(JsonConfig.FirstSendTask,cb,6);
end
function NewYearView:XBLSendTaskByDayIndex(dayIndex,cb)
    print("NewYearView:XBLSendTaskByDayIndex:"..dayIndex);
    dump(JsonConfig.SendTasksList);
    if dayIndex > 0 and dayIndex <= self:getController():GetActivityDay() then 
        self.jaManager_:Play(JsonConfig.SendTasksList[dayIndex],cb,5);
    end
end

function NewYearView:XBLRemeberTaskByDayIndex(dayIndex,cb)
    print("NewYearView:XBLRemeberTaskByDayIndex:"..dayIndex);
    dump(JsonConfig.RemeberTask);
    if dayIndex > 1 and dayIndex <= self:getController():GetActivityDay() then 
        self.jaManager_:Play(JsonConfig.RemeberTask[dayIndex],cb,5);
    end
end

function NewYearView:XBLTodayTaskComplieByDayIndex(cb)
    print("XBLTodayTaskComplieByDayIndex json：");
    print(debug.traceback(  ));
    --self.jaManager_:Play(JsonConfig.ToDayTaskComplie ,cb,5);
end

function NewYearView:XBLCheerTaskComplieByDayIndex(i,cb)
    print("i:"..i);
    dump(JsonConfig.CheerTaskComplie);-- mark
    self.jaManager_:Play(JsonConfig.CheerTaskComplie[i],cb,5);
end
JsonConfig.XBLGreeting = "lmmxnpd026";
function NewYearView:XBLGreeting(cb)
    self.jaManager_:Play(JsonConfig.XBLGreeting,cb,6);
end

function NewYearView:ItemTempLock(i)
    if i>1 and i<=3 then 
        self.listOfActivityItems_[i]:PlayLock();
    end
end


function NewYearView:XBLContinueTellTaskByIndex(i,cb)
    if i>1 and i<=3 then 
        self.listOfActivityItems_[i]:PlayUnLock(function() 
            -- todo item unlock anim ...
            self.jaManager_:Play(JsonConfig.ContinueTellTask[i],cb,5);
        end);
    else 
        -- todo item unlock anim ...
        self.jaManager_:Play(JsonConfig.ContinueTellTask[i],cb,5);
    end

end

function NewYearView:XBLContinueTellTaskTomorrowByIndex(i,cb)
    if i > 0 and i < self:getController():GetActivityDay() then 
        self.jaManager_:Play(JsonConfig.ConinueTellTaskTomorrow[i],cb,5);
    end
end
 --  
function NewYearView:ClickXBLTipUpTask(i,cb)
    if i > 0 and i <= self:getController():GetActivityDay() then 
        self.jaManager_:Play(JsonConfig.ClickXBLTipUp[i],cb,5);
    end
end

function NewYearView:ClickLMMTipUpTask(i,index,cb)----ClickLMMTipUpA
    if i > 0 and i <= self:getController():GetActivityDay() then
        local list = JsonConfig.ClickLmmTipUp;
        self.jaManager_:Play(list[i],cb,5);
    end
end

function NewYearView:LmmClickRandPlay(index,cb)
    -- JsonConfig.ClickLmmRandSay
    local list = {};
    if index == 1 then 
        list = JsonConfig.ClickLmmRandSayA;
    elseif index == 2 then 
        list = JsonConfig.ClickLmmRandSayB;
    elseif index == 3 then 
        list = JsonConfig.ClickLmmRandSayC;
    elseif index == 4 then 
        list = JsonConfig.ClickLmmRandSayD;
    end
    self:RandPlayByList(list,cb,5);
end

JsonConfig.LmmClickUnOpenRandPlayList = {
    "lmmxnpd024A",
    "lmm01006A",
    "lmm01005A",
    "xianzhi1A",
    "xianzhi2A",
    "xianzhi3A",
    "xianzhi4A",
}
JsonConfig.XBLClickUnOpenRandPlayList1 = {
    "lmmxnpd023",
    "lmmxnpd025",
    "lmmxnpd062",
}

JsonConfig.XBLClickUnOpenRandPlayList2 = {
    "lmmxnpd023",
    "lmmxnpd025",
    "lmmxnpd062a",
}

function NewYearView:LmmClickUnOpenRandPlay()
    self:RandPlayByList(JsonConfig.LmmClickUnOpenRandPlayList ,cb,5);
end

function NewYearView:XBLClickUnOpenRandPlay1X(cb)
    self.jaManager_:Play("xbltv01111",cb,10);
end

function NewYearView:XBLClickUnOpenRandPlay2X(cb)
    self.jaManager_:Play("xbltv01111",cb,10);
end


function NewYearView:XBLClickUnOpenRandPlay1(cb)
    self:RandPlayByList(JsonConfig.XBLClickUnOpenRandPlayList1 ,cb,5);
end

function NewYearView:XBLClickUnOpenRandPlay2(cb)
    self:RandPlayByList(JsonConfig.XBLClickUnOpenRandPlayList2 ,cb,5);
end

JsonConfig.ClickXblRandSay2 = {
    "lmmxnpd053",
    "lmmxnpd054",
    "lmmxnpd055",
    "lmmxnpd056"
}

JsonConfig.ClickXBLRandSay = {
    "lmmxnpd023",
    "lmmxnpd025",
    "lmmxnpd046",
    "lmmxnpd047a",
}
function NewYearView:XblClickRandPlay2(cb)
    self:RandPlayByList(JsonConfig.ClickXblRandSay2,cb,5);
end

function NewYearView:XblClickRandPlay(cb) 
    self:RandPlayByList(JsonConfig.ClickXBLRandSay ,cb,5);
end

function NewYearView:IsRunningAction()
    return JsonScriptUtil.IsActionRunning(self);
end

function NewYearView:LmmRandAct(index)
    if index>4 then 
        index = 4;
    end
    if index<1 then 
        index = 1;
    end
    if self.lmm_ ~= nil then 
        -- 9 11 18 41
        local randActIndex = math.random( 1,4 )
        if randActIndex == 1 then 
            randActIndex = 9;
        elseif randActIndex == 2 then 
            randActIndex = 11;
        elseif randActIndex == 3 then 
            randActIndex = 18;
        elseif randActIndex == 4 then 
            randActIndex = 41;
        end
        if index == 1 then 
            self.lmm_:changeArmature("lmm2019_twxm",randActIndex);
        elseif index == 2 then 
            self.lmm_:changeArmature("lmm2019_daihg_twxm",randActIndex);
        elseif index == 3 then 
            self.lmm_:changeArmature("lmm2019_hgyf_twxm",randActIndex);
        elseif index == 4 then 
            self.lmm_:changeArmature("lmm2019_mfbgz_twxm",randActIndex);
        end
        ArmatureUtil.Play(self.lmm_,randActIndex);
    end

end


JsonConfig.ItemLocked = "lmmxnpd027";
JsonConfig.ItemDownloading = "lmmxnpd028";
JsonConfig.ItemEnter = {
    "lmmxnpd029a",
    "lmmxnpd30a",--lmmxnpd30a
    "lmmxnpd31a",--lmmxnpd31a
} 
JsonConfig.ItemEnter2 = {
    "lmmgosay001",
    "lmmgosay002",
    "lmmgosay003"
}
JsonConfig.ItemLockedToday = "lmmxnpd030";

function NewYearView:XBLTellLockedToday()
    self.jaManager_:Play(JsonConfig.ItemLockedToday,cb,6);
end

JsonConfig.ItemLockedUnOpen = "lmmxnpd061";
function NewYearView:ItemLockedUnOpen()
    self.jaManager_:Play(JsonConfig.ItemLockedUnOpen,cb,6);
end




function NewYearView:XBLTellItemEnter2(i,cb)

   
    if self.isTellEnterPackage_ == false then 
        print("jsonName:"..JsonConfig.ItemEnter2[i]);

        --JsonConfig.ItemEnter2
        self.jaManager_:Play(JsonConfig.ItemEnter2[i],function(e) 
            if cb ~= nil then 
                cb(e);
                self.isTellEnterPackage_ = false;
            end
        end ,6);
        self.isTellEnterPackage_ = true;
    end

end
function NewYearView:XBLTellItemEnter(i,cb)
    if self.isTellEnterPackage_ == false then 
        print("jsonName:"..JsonConfig.ItemEnter[i]);
        --JsonConfig.ItemEnter2
        self.jaManager_:Play(JsonConfig.ItemEnter[i],function(e) 
            if cb ~= nil then 
                cb(e);
                self.isTellEnterPackage_ = false;
            end
        end ,6);
        self.isTellEnterPackage_ = true;
    end
end
function NewYearView:XBLTellItemDownloading( cb )
    self.jaManager_:Play(JsonConfig.ItemDownloading,cb,5);
end

function NewYearView:XBLTellItemLocked(cb)
    self.jaManager_:Play(JsonConfig.ItemLocked,cb,5);
end

JsonConfig.FreeChatList = {
    "lmmxnpd023",
    "lmmxnpd024",
    "lmmxnpd025",
    "lmmxnpd046",
    "lmmxnpd047a",
}
function NewYearView:XBLFreeChat(cb)
    self:RandPlayByList(JsonConfig.FreeChatList,cb,4);
end

function NewYearView:XBLFreeChatSendTaskByDayIndex(dayIndex,cb)
    if dayIndex > 0 and dayIndex <= self:getController():GetActivityDay() then 
        self.jaManager_:Play(JsonConfig.ClickXBLTipUp[dayIndex],cb,4);
    end
end

JsonConfig.FreeChatNextTask = {
    "lmmxnpd029a",
    "lmmxnpd046",
    "lmmxnpd047a",
}

function NewYearView:XBLFreeChatSendTaskNextDay(dayIndex,cb)
    if dayIndex > 0 and dayIndex <= self:getController():GetActivityDay() then 
        self.jaManager_:Play(JsonConfig.FreeChatNextTask[dayIndex],cb,4);
    end
end
JsonConfig.XBLGreetingTipDate1 = "lmmxnpd060";
JsonConfig.XBLGreetingTipDate2 = "lmmxnpd060a";
function NewYearView:XBLGreetingTipDate1()
    self.jaManager_:Play(JsonConfig.XBLGreetingTipDate1,cb,6);
end

function NewYearView:XBLGreetingTipDate2()
    self.jaManager_:Play(JsonConfig.XBLGreetingTipDate2,cb,6);
end


return NewYearView;