local JsonConfig = {};
JsonConfig.SendTasksList = {
    "fhkl017",
    "fhkl019",
    "fhkl021"
}

JsonConfig.SendTasksListPart0 = {
    "fhkl005",
    "fhkl010",
    "fhkl013"
}
JsonConfig.RemeberTask = {
    "fhkl040",
    "fhkl040",
    "fhkl041",
}
--JsonConfig.ToDayTaskComplie = "lmmxnpd026";

JsonConfig.CheerTaskCompliePart1 = {
    "fhkl022",
    "fhkl026",
    "fhkl030",
}

JsonConfig.CheerTaskCompliePart2 = {
    "fhkl024",
    "fhkl028",
    "fhkl032",
}


JsonConfig.ContinueTellTask = {
    "fhkl005",
    "fhkl010",
    "fhkl013",
}
JsonConfig.ConinueTellTaskTomorrow = {
    "fhkl040",
    "fhkl041",
}

JsonConfig.ClickXBLTipUp = {
    "fhkl017",
    "fhkl019",
    "fhkl021",
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
local ActivityItemExist1 = requirePack("scripts.UI.ActivityItemExist1");
local SnowBall = requirePack("scripts.UI.SnowBall");

local DragonView = class("DragonView",function() 
    return NormalView.new();
end);
g_tConfigTable.CREATE_NEW(DragonView);

function DragonView:ctor()
    -- 定义所有使用过的成员在这里..
    self.listOfActivityItems_ = {};
    self.jaManager_ = nil;

    self.isShowPaoPao_ = false;

    self.isTellEnterPackage_ = false;

    self.isDontTouchActivityItems_ = false;
    self.isWaitingClick_ = false;
end
 
function DragonView:SetIsWaitingClick(v)
    self.isWaitingClick_ = v;
end
function DragonView:GetIsWaitingClick() 
    return self.isWaitingClick_;
end

function DragonView:SetIsDontTouchActivityItems(v)
    self.isDontTouchActivityItems_ = v;
end
function DragonView:GetIsDontTouchActivityItems()
    return self.isDontTouchActivityItems_;
end
-- 
function DragonView:createCharactorBtn(arm,imgpath,cb)
    local x,y = arm:getPosition();
    local btn = ButtonUtil.Create(
        imgpath,
        imgpath,
        function()
            if cb ~= nil then 
                cb();
            end
        end);
    self:addChild(btn);
    btn:setPosition(cc.p(x,y));
    btn:setScale(1);
end

--[[
    方法 定义界面初始化
    包括:
        创建所有需要的显示对象 
        注册所有要使用的UI事件
]]--
function DragonView:Init()
    self.jaManager_ = JAManager.new();
    self.jaManager_:SetStageNode(self);
    self.jaManager_:PlayBgConfig("fhkl_BgConfig");



    local time = os.date("%Y%m%d");
    --dump(time);
    --writeToFile("time--------------------------------:"..time);
    print("View init:"..time);

    -- create bg config SpriteUtil.Create(PathsUtil.ImagePath(""));
    self.spBg_ = SpriteUtil.Create(PathsUtil.ImagePath("191212lmm_bg.png"));
    self:addChild(self.spBg_,-1);
    self.spBg_:setScale(1);
    self.spBg_:setPosition(cc.p(384,512));

    -- create path
    --[[]]--
    self.armPathBG_ =  TouchArmature:create("202002fhkl_lujin_yinying_twxm",TOUCHARMATURE_NORMAL);
    self:addChild(self.armPathBG_,0);
    self.armPathBG_:setPosition(cc.p(378,1024-567));
    --self.armPathBG_:setScale(0.42);

    self.newArmPath_ =  TouchArmature:create("19212lmm_luj_twxm",TOUCHARMATURE_NORMAL);
    self:addChild(self.newArmPath_);
    self.newArmPath_:setScale(0.42);
    self.newArmPath_:setPosition(cc.p(378,1024-567));
    self.newArmPath_:playByIndex(0,LOOP_YES)

    self.spStage_ = JsonScriptUtil.GetNpcByName(self,"npc_wutai01");
    self.spStage_:setPosition(cc.p(384,1024-405));
    self.spStage_:setScale(0.426);


    JsonScriptUtil.GetNpcByName(self,"npc_mb1_mov_twxm"):playByIndex(4,LOOP_YES);
    JsonScriptUtil.GetNpcByName(self,"npc_mb2_mov_twxm"):playByIndex(4,LOOP_YES);
    JsonScriptUtil.GetNpcByName(self,"npc_mb3_mov_twxm"):playByIndex(4,LOOP_YES);


--[[

    JsonScriptUtil.GetNpcByName(self,"npc_suo1_twxm"):setVisible(false);
    JsonScriptUtil.GetNpcByName(self,"npc_suo2_twxm"):setVisible(false);
    JsonScriptUtil.GetNpcByName(self,"npc_suo3_twxm"):setVisible(false);


    JsonScriptUtil.GetNpcByName(self,"npc_mb1"):setVisible(false);
    JsonScriptUtil.GetNpcByName(self,"npc_mb2"):setVisible(false);
    JsonScriptUtil.GetNpcByName(self,"npc_mb3"):setVisible(false);

]]--

    JsonScriptUtil.GetNpcByName(self,"npc_luj_twxm"):setVisible(false);

    self.xbl_ = self:getChildByName("XBL");
    self.lmm_ = JsonScriptUtil.GetNpcByName(self,"npc_txy");
    self.sjl_ =  JsonScriptUtil.GetNpcByName(self,"npc_sjl");
    self.bwl_ =  JsonScriptUtil.GetNpcByName(self,"npc_bwl");
    self.jl_ =  JsonScriptUtil.GetNpcByName(self,"npc_jl");

    if self.sjl_ ~= nil then 
        self:createCharactorBtn(
            self.sjl_,
            PathsUtil.ImagePath("btnXbl.png"),
            function()
                print("click sjl");
                self:getController():OnClickSjl();
            end
        );--arm,imgpath,cb
    end--
    if self.bwl_ ~= nil then 
        self:createCharactorBtn(
            self.bwl_,
            PathsUtil.ImagePath("btnXbl.png"),
            function()
                print("click bwl");
                self:getController():OnClickBwl();
            end
        );--arm,imgpath,cb
    end--
    if self.jl_ ~= nil then 
        self:createCharactorBtn(
            self.jl_,
            PathsUtil.ImagePath("btnXbl.png"),
            function()
                print("click jl");
                self:getController():OnClickJl();
            end
        );--arm,imgpath,cb
    end--

    if self.xbl_ ~= nil then 
        self:createCharactorBtn(
            self.xbl_,
            PathsUtil.ImagePath("btnXbl.png"),
            function()
                print("click xbl");
                self:getController():OnUserClickXBL();
            end
        );--arm,imgpath,cb
    end
    if self.lmm_ ~= nil then 
        self:createCharactorBtn(
            self.lmm_,
            PathsUtil.ImagePath("btnXbl.png"),
            function()
                print("click lmm");
                self:getController():OnUserClickXBL();
                --self:getController():OnUserClickLMM();
            end
        );--arm,imgpath,cb
    end--
    if self:GetIsDontTouchActivityItems() == false then 
        self:InitItems();
    end
   

    -- 创建点击按钮
    self.cbOfSetUp_ = nil;
    self.btnBlockBg_ =  ButtonUtil.Create(
        PathsUtil.ImagePath("btnSnowBall.png"),
        PathsUtil.ImagePath("btnSnowBall.png"),
        function()
            print("block here....");
        end);
    self:addChild( self.btnBlockBg_,100090);
    self.btnBlockBg_:setScale(10000);
    self.btnBlockBg_:setPosition(cc.p(720/2,1024/2));

    self.btnSetUp_ =  ButtonUtil.Create(
        PathsUtil.ImagePath("btnSnowBall.png"),
        PathsUtil.ImagePath("btnSnowBall.png"),
        function()
            if self.cbOfSetUp_  ~= nil then 
                self.cbOfSetUp_();
            end
        end);
    self:addChild( self.btnSetUp_,100090);
    self.btnSetUp_:setPosition(cc.p(720/2,1024/2));
    self.btnSetUp_:setScale(2.5);
    self:CloseSetUpView();
end

function DragonView:InitItems()
    local commenTable = {};
    commenTable.ImageBtnItem                  = PathsUtil.ImagePath("btnItem.png") ;
    commenTable.ImageProcessBg                = PathsUtil.ImagePath("gui_jindu_bg.png");
    commenTable.ImageProcessContent           = PathsUtil.ImagePath("gui_jindu_s.png") ;
    commenTable.ImageDecorationProcess            = PathsUtil.ImagePath("gui_needdown.png") ;
    commenTable.ImageBg                         =   PathsUtil.ImagePath("gui_s1.png");
    commenTable.ImageUpdate                         =   PathsUtil.ImagePath("btn_gengxin.png");
    commenTable.ImageFix                         =   PathsUtil.ImagePath("btn_xiufu.png");
    commenTable.MenuType = 2;
    commenTable.ImageLock                         = PathsUtil.ImagePath("gui_lock_1.png") ;
    local itemList = {
        {bgOfIcon = "202002fhkl_mb1",ArmName = JsonScriptUtil.GetNpcByName(self,"npc_mb1"),BagId = 198,
        Pos = SpriteUtil.ToFlashPoint(441,665),imgLock = "202002fhkl_suo3_twxm"},
        {bgOfIcon = "202002fhkl_mb2",ArmName = JsonScriptUtil.GetNpcByName(self,"npc_mb2"),BagId = 193,
        Pos = SpriteUtil.ToFlashPoint(298,541),imgLock = "202002fhkl_suo2_twxm"},
        {bgOfIcon = "202002fhkl_mb3",ArmName = JsonScriptUtil.GetNpcByName(self,"npc_mb3"),BagId = 195,
        Pos = SpriteUtil.ToFlashPoint(475,501),imgLock = "202002fhkl_suo1_twxm"},
    };
    local count = #itemList;
    for i = 1,count ,1 do 
        local data = itemList[i];
        local ai = ActivityItemExist1.new(commenTable.MenuType,data.BagId);
        self:addChild(ai,100001);
        table.insert(self.listOfActivityItems_,ai);
        ai:Init(
            data.ArmName,--
            commenTable.ImageBtnItem ,          
            commenTable.ImageProcessBg         ,
            commenTable.ImageProcessContent    ,
            commenTable.ImageDecorationProcess ,
            commenTable.ImageLock  ,--JsonScriptUtil.GetNpcByName(self,data.imgLock) , -- 
            commenTable.ImageUpdate,
            commenTable.ImageFix,
            self:getController(),
            "202002fhkl_lujin_wutai03_twxm"   --              
        );
       ai:setPosition(data.Pos);
    end
end

function DragonView:TestItemHasInfo()
    local itemList = {
        {bgOfIcon = "202002fhkl_mb1",BagId = 198,
        Pos = cc.p(10000,665),imgLock = "202002fhkl_suo3_twxm"},
        {bgOfIcon = "202002fhkl_mb2",BagId = 193,
        Pos = cc.p(10000,541),imgLock = "202002fhkl_suo2_twxm"},
        {bgOfIcon = "202002fhkl_mb3",BagId = 195,
        Pos = cc.p(10000,501),imgLock = "202002fhkl_suo1_twxm"},
    };
    local count = #itemList;
    for i = 1,count ,1 do 
        local data = itemList[i];
        local ai = ActivityItemExist1.new(2,data.BagId);
       -- self:addChild(ai,100001);
       ai:setPosition(data.Pos);
       local str = ai:getMenuDataForLua();
       print("json str:" .. str);
       if str == "" then 
           return false;
       end
    end
    return true;
end

function DragonView:CloseSetUpView()
    self.cbOfSetUp_  = nil;
    self.btnBlockBg_ :setVisible(false);
    self.btnSetUp_ :setVisible(false);
end

function DragonView:OpenSetUpView(cb)
    self.cbOfSetUp_  = cb;
    self.btnBlockBg_ :setVisible(true);
    self.btnSetUp_ :setVisible(true);
end

function DragonView:PreOpenSetUpViewBlock()
    self.btnBlockBg_ :setVisible(true);
end

function DragonView:UpdateItemStateList()
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
function DragonView:Dispose()
    print("View dispose");
  
    self.jaManager_:Dispose();
end

function DragonView:Update(data)

    local listOfIiemData = data.ListOfItems;

    if self:GetIsDontTouchActivityItems() == false then 
        local count =#listOfIiemData;
        for i = 1,count ,1 do 
            local itemData = listOfIiemData[i];
            local item = self.listOfActivityItems_[i];
            item:UpdateDataSelf(itemData);
        end
    end


    if data.AimTaskIndex ~= nil then 

        if data.AimTaskIndex == 1 then 

            ArmatureUtil.PlayLoop(self.sjl_,0 );
            ArmatureUtil.PlayLoop(self.bwl_,0 );
            ArmatureUtil.PlayLoop(self.jl_,0 );

            ArmatureUtil.PlayLoop(self.newArmPath_,7);
        elseif data.AimTaskIndex == 2 then
            
            ArmatureUtil.PlayLoop(self.sjl_,0 );
            ArmatureUtil.PlayLoop(self.bwl_,3 );
            ArmatureUtil.PlayLoop(self.jl_,0 );

            ArmatureUtil.PlayLoop(self.newArmPath_,2);
        elseif data.AimTaskIndex == 3 then
            ArmatureUtil.PlayLoop(self.sjl_,3 );
            ArmatureUtil.PlayLoop(self.bwl_,3 );
            ArmatureUtil.PlayLoop(self.jl_,0 ); 

            ArmatureUtil.PlayLoop(self.newArmPath_,4);
        elseif data.AimTaskIndex == 4 then 
            ArmatureUtil.PlayLoop(self.sjl_,3 );
            ArmatureUtil.PlayLoop(self.bwl_,3 );
            ArmatureUtil.PlayLoop(self.jl_,3); 
            ArmatureUtil.PlayLoop(self.newArmPath_,6);
        end
    else 
        ArmatureUtil.PlayLoop(self.sjl_,0 );
        ArmatureUtil.PlayLoop(self.bwl_,0 );
        ArmatureUtil.PlayLoop(self.jl_,0 );

        ArmatureUtil.PlayLoop(self.newArmPath_,7);
    end

end

function DragonView:RandPlayByList(list,cb,tag)
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

function DragonView:RandSendSnowBall()
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

function DragonView:StartSendSnowBallSeq()
    local tag = 1008;
    local req = cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(
        function()
            self:RandSendSnowBall(); 
        end
    )));
    req:setTag(tag);
    self:runAction(req);
end

function DragonView:StopSendSnowBallSeq()
    local tag = 1008;
    self:stopActionByTag(tag);
end

-- ----- view 界面动画表演 -----
function DragonView:XBLTellNoData()
    print("XBLTellNoData start");

    --self:DelayCallBack(0.5,function()
        local fingerTip = TouchArmature:create("point_all", TOUCHARMATURE_NORMAL, "")
        self:addChild(fingerTip,100020);
        fingerTip:setPosition(cc.p(105,1027-150));
        fingerTip:playByIndex(1,LOOP_YES);
    --end);

    self.jaManager_:Play("fhkl058",function() end,6);
    print("XBLTellNoData end");
end
function DragonView:XBLTipNoData()
    self.jaManager_:Play("fhkl058",function() end,6);
    print("XBLTellNoData end");
end

JsonConfig.XBLNormalGreeting = "lmmxnpd057";
function DragonView:XBLNormalGreeting(cb)
    --self.jaManager_:Play
    self.jaManager_:Play(JsonConfig.XBLNormalGreeting,cb,6);
end


JsonConfig.EndActivity2 = "191212hd_end2";
function DragonView:LMMActivityEnd2(cb)
    --self.jaManager_:Play
    self.jaManager_:Play(JsonConfig.EndActivity2,cb,6);
end

JsonConfig.EndActivity1 = "191212hd_end1";
function DragonView:LMMActivityEnd(cb)
    --self.jaManager_:Play
    self.jaManager_:Play(JsonConfig.EndActivity1,cb,6);
end


function DragonView:XBLSendTaskOrig(dayIndex,cb)
    self.jaManager_:Play(JsonConfig.SendTasksListPart0[dayIndex],function()
        if cb ~= nil then 
            cb();
        end
    end,5);
end


function DragonView:XBLSendTaskByDayIndex(dayIndex,cb)
    self.jaManager_:Play(JsonConfig.SendTasksList[dayIndex],cb,5);
end

function DragonView:XBLRemeberTaskByDayIndex(dayIndex,cb)
    if dayIndex > 1 and dayIndex <= self:getController():GetActivityDay() then 
        self.jaManager_:Play(JsonConfig.RemeberTask[dayIndex],cb,5);
    end
end

function DragonView:XBLTodayTaskComplieByDayIndex(cb)
    print("XBLTodayTaskComplieByDayIndex json：");
    print(debug.traceback(  ));
    --self.jaManager_:Play(JsonConfig.ToDayTaskComplie ,cb,5);
end


JsonConfig.SuccessResultPart1 = "fhkl034";
JsonConfig.SuccessResultPart2 = "fhkl036";
function DragonView:SuccessResult(cb)
    self.jaManager_:Play(JsonConfig.SuccessResultPart1 ,function()
        self.jaManager_:Play(JsonConfig.SuccessResultPart2,function()
            if cb ~= nil then 
                cb();
            end
        end ,5);
    end ,5);
end

function DragonView:PretentAsBoneByIndex(index)
    if index == 1 then 
        self.bwl_:playByIndex("0",LOOP_YES);
    elseif index == 2 then 
        self.sjl_:playByIndex("0",LOOP_YES);
    elseif index == 3 then 
        self.jl_:playByIndex("0",LOOP_YES);
    end
end

function DragonView:XBLCheerTaskComplieByDayIndex(i,cb)
    self:PretentAsBoneByIndex(i);
    self:PreOpenSetUpViewBlock();
    self:SetIsWaitingClick(true);
    self.jaManager_:Play(JsonConfig.CheerTaskCompliePart1[i],function()
        
        self:OpenSetUpView(function()
            self.jaManager_:Play(JsonConfig.CheerTaskCompliePart2[i],function()
    self:SetIsWaitingClick(false);

                if cb ~= nil then 
                    cb();
                end
            end ,5);
            self:CloseSetUpView();
        end);
    end ,6);
end
JsonConfig.XBLGreeting = "lmmxnpd026";
function DragonView:XBLGreeting(cb)
    self.jaManager_:Play(JsonConfig.XBLGreeting,cb,6);
end

function DragonView:ItemTempLock(i)
    if i>1 and i<=3 then 
        self.listOfActivityItems_[i]:PlayLock();
    end
end


function DragonView:XBLContinueTellTaskByIndex(i,cb)
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

function DragonView:XBLContinueTellTaskTomorrowByIndex(i,cb)
    if i > 0 and i < self:getController():GetActivityDay() then 
        self.jaManager_:Play(JsonConfig.ConinueTellTaskTomorrow[i],cb,5);
    end
end
 --  
function DragonView:ClickXBLTipUpTask(i,cb)
    if i > 0 and i <= self:getController():GetActivityDay() then 
        self.jaManager_:Play(JsonConfig.ClickXBLTipUp[i],cb,4);
    end
end
JsonConfig.RemenberNextDay = "fhkl042";
function DragonView:XBLRemenberNextDay()
    self.jaManager_:Play(JsonConfig.RemenberNextDay,cb,4);
end

function DragonView:ClickLMMTipUpTask(i,index,cb)----ClickLMMTipUpA
    if i > 0 and i <= self:getController():GetActivityDay() then
        local list = JsonConfig.ClickLmmTipUp;
        self.jaManager_:Play(list[i],cb,5);
    end
end

function DragonView:LmmClickRandPlay(index,cb)
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

function DragonView:LmmClickUnOpenRandPlay()
    self:RandPlayByList(JsonConfig.LmmClickUnOpenRandPlayList ,cb,5);
end

function DragonView:XBLClickUnOpenRandPlay1X(cb)
    self.jaManager_:Play("xbltv01111",cb,10);
end

function DragonView:XBLClickUnOpenRandPlay2X(cb)
    self.jaManager_:Play("xbltv01111",cb,10);
end


function DragonView:XBLClickUnOpenRandPlay1(cb)
    self:RandPlayByList(JsonConfig.XBLClickUnOpenRandPlayList1 ,cb,5);
end

function DragonView:XBLClickUnOpenRandPlay2(cb)
    self:RandPlayByList(JsonConfig.XBLClickUnOpenRandPlayList2 ,cb,5);
end

JsonConfig.ClickXblRandSay2 = {
    "lmmxnpd053",
    "lmmxnpd054",
    "lmmxnpd055",
    "lmmxnpd056"
}

JsonConfig.ClickXBLRandSay = {
    "fhkl053",
    "fhkl055",
}
function DragonView:XblClickRandPlay2(cb)
    self:RandPlayByList(JsonConfig.ClickXblRandSay2,cb,4);
end

function DragonView:XblClickRandPlay(cb) 
    self:RandPlayByList(JsonConfig.ClickXBLRandSay ,cb,4);
end

function DragonView:IsRunningAction()
    return JsonScriptUtil.IsActionRunning(self);
end

function DragonView:LmmRandAct(index)
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


JsonConfig.ItemLocked = "fhkl044";
JsonConfig.ItemDownloading = "fhkl045";
JsonConfig.ItemEnter = "fhkl046";
JsonConfig.ItemLockedToday = "fhkl044";
function DragonView:XBLTellLockedToday()
    self.jaManager_:Play(JsonConfig.ItemLockedToday,cb,4);
end

JsonConfig.ItemLockedUnOpen = "lmmxnpd061";
function DragonView:ItemLockedUnOpen()
    self.jaManager_:Play(JsonConfig.ItemLockedUnOpen,cb,4);
end

function DragonView:XBLTellItemEnter(cb)
    if self.isTellEnterPackage_ == false then 
        self.jaManager_:Play(JsonConfig.ItemEnter,function(e) 
            if cb ~= nil then 
                cb(e);
                self.isTellEnterPackage_ = false;
            end
        end ,6);
        self.isTellEnterPackage_ = true;
    end
end
function DragonView:XBLTellItemDownloading( cb )
    self.jaManager_:Play(JsonConfig.ItemDownloading,cb,5);
end

function DragonView:XBLTellItemLocked(cb)
    self.jaManager_:Play(JsonConfig.ItemLocked,cb,5);
end

JsonConfig.FreeChatList = {
    "fhkl053",
    "fhkl055"
}
function DragonView:XBLFreeChat(cb)
    self:RandPlayByList(JsonConfig.FreeChatList,cb,4);
end

function DragonView:XBLFreeChatSendTaskByDayIndex(dayIndex,cb)
    if dayIndex > 0 and dayIndex <= self:getController():GetActivityDay() then 
        self.jaManager_:Play(JsonConfig.ClickXBLTipUp[dayIndex],cb,4);
    end
end

JsonConfig.FreeChatNextTask = {
    "fhkl042",
    "fhkl042",
    "fhkl042",
}

function DragonView:XBLFreeChatSendTaskNextDay(dayIndex,cb)
    if dayIndex > 0 and dayIndex <= self:getController():GetActivityDay() then 
        self.jaManager_:Play(JsonConfig.FreeChatNextTask[dayIndex],cb,4);
    end
end
JsonConfig.XBLGreetingTipDate1 = "lmmxnpd060";
JsonConfig.XBLGreetingTipDate2 = "lmmxnpd060a";
function DragonView:XBLGreetingTipDate1()
    self.jaManager_:Play(JsonConfig.XBLGreetingTipDate1,cb,6);
end

function DragonView:XBLGreetingTipDate2()
    self.jaManager_:Play(JsonConfig.XBLGreetingTipDate2,cb,6);
end


function DragonView:XBLTellGetBwl()
    self.jaManager_:Play("fhkl047" ,function() end,4);
end
function DragonView:XBLTellGetSjl()
    self.jaManager_:Play("fhkl049" ,function() end,4);
end
function DragonView:XBLTellGetJl()
    self.jaManager_:Play("fhkl051" ,function() end,4);
end

function DragonView:BwlShowOff()
    self.jaManager_:Play("fhkl048" ,function() end,4);
end
function DragonView:SjlShowOff()
    self.jaManager_:Play("fhkl050" ,function() end,4);
end
function DragonView:JlShowOff()
    self.jaManager_:Play("fhkl052" ,function() end,4);
end



return DragonView;