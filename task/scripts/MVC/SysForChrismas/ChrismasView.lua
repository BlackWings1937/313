local ArmatureUtil = requirePack("scripts.Utils.ArmatureUtil"); 
local PathsUtil = requirePack("scripts.Utils.PathsUtil"); 
local SpriteUtil = requirePack("scripts.Utils.SpriteUtil"); 
local ButtonUtil = requirePack("scripts.Utils.ButtonUtil"); 
local JsonScriptUtil = requirePack("scripts.Utils.JsonScriptUtil");

local JsonScriptConfig = requirePack("scripts.JsonScriptConfig");

local Toggle = requirePack("scripts.UI.Toggle");
local BtnAnim = requirePack("scripts.UI.BtnAnim");
local StickerProcessBar = requirePack("scripts.UI.StickerProcessBar");
local CarouselItem = requirePack("scripts.UI.CarouselItem");
local CarouselGroup = requirePack("scripts.UI.CarouselGroup");
local FramesItem = requirePack("scripts.UI.FramesItem");
local Mask = requirePack("scripts.UI.Mask");


local BaseView = requirePack("scripts.MVC.Base.BaseView");

local ChrismasData = requirePack("scripts.MVC.SysForChrismas.ChrismasData");

local ChrismasView = class("ChrismasView",function() 
    return BaseView.new();
end);
g_tConfigTable.CREATE_NEW(ChrismasView);

function ChrismasView:ctor()
    -- 定义所有使用过的成员在这里..
    self.spBg_ = nil ;                    -- 背景图
    self.processBar_ = nil;               -- 进度条

    self.btnNext_ = nil;                  -- 下一步按钮

    
end


function ChrismasView:CloseLeaveView()
    self.mask_                  :setVisible(false);
    self.spQuitBg_              :setVisible(false);
    self.btnRealQuit_           :setVisible(false);     
    self.btnContinue_           :setVisible(false);   
    self.processBarLeaveView_   :setVisible(false);       
    self.spStarIconBgLeaveView_ :setVisible(false);       
    self.spStarIconLeaveView_   :setVisible(false);      
    self.lbOfProcessAtLeave_    :setVisible(false); 
end
function ChrismasView:ShowLeaveViewByStep(step)
    self.mask_:setVisible(true);
    self.spQuitBg_              :setVisible(true);
    self.btnRealQuit_           :setVisible(true);     
    self.btnContinue_           :setVisible(true);   
    self.processBarLeaveView_   :setVisible(true);       
    self.spStarIconBgLeaveView_ :setVisible(true);       
    self.spStarIconLeaveView_   :setVisible(true);      
    self.lbOfProcessAtLeave_    :setVisible(true); 
    self.processBarLeaveView_:UpdateProcessByIndex(step);
    self.lbOfProcessAtLeave_ :setString(((step/4)*100).."%");

    if JsonScriptUtil.IsActionRunning(self) == false then 
        local path =g_tConfigTable.sTaskpath .. "audio/Xmas082.mp3";
        SoundUtil:getInstance():playLua(path,path,function()
        end);

    end

end

--[[
    方法 定义界面初始化
    包括:
        创建所有需要的显示对象 cc.p(178 + SpriteUtil.GetContentSize(self.spBg_).width/2,1024 -( 194.67 + SpriteUtil.GetContentSize(self.spBg_).height/2))
        注册所有要使用的UI事件
]]--
function ChrismasView:Init()
--[[
    self.spBg_ = SpriteUtil.Create( PathsUtil.ImagePath("btnBack.png"));
    self:addChild(self.spBg_,10000000);
    self.spBg_:setPosition(cc.p(0,0));
    self.spBg_:setScale(10);
    print("catch123123123");
    dump(SpriteUtil.GetContentSize (self.spBg_))
]]--
    self.mask_ = Mask.new();
    self.mask_:Init(PathsUtil.ImagePath("btnBgMusic.png"),ccc4(0,0,0,153));
    self:addChild(self.mask_,100011);
    --self.mask_:setVisible(false);

    self.spQuitBg_ = SpriteUtil.Create(PathsUtil.ImagePath("gui_wfpop_bg.png"));
    self:addChild(self.spQuitBg_,100011);
    SpriteUtil.SetLhPos(self.spQuitBg_,cc.p(
        183,
        162
    ));

    self.btnRealQuit_ = ButtonUtil.Create(
        PathsUtil.ImagePath("gui_btn_leave.png"),
        PathsUtil.ImagePath("gui_btn_leave.png"),function()
            self:getController():OnUserRealBackHome();
    end);
    self.btnContinue_ = ButtonUtil.Create(
        PathsUtil.ImagePath("gui_btn_goon.png"),
        PathsUtil.ImagePath("gui_btn_goon.png"),
        function()
            self:CloseLeaveView();
    end);
    SpriteUtil.SetLhPos(self.btnRealQuit_,cc.p(
        251,
        546
    ));
    SpriteUtil.SetLhPos(self.btnContinue_,cc.p(
        378,
        546
    ));
    self:addChild(self.btnRealQuit_ ,100011);
    self:addChild(self.btnContinue_ ,100011);

    self.processBarLeaveView_ =  StickerProcessBar.new();
    self.processBarLeaveView_:Init(
        PathsUtil.ImagePath("gui_granule.png"),
        PathsUtil.ImagePath("gui_granule_bg.png"),
        PathsUtil.ImagePath("gui_progress_bg.png"),
        1,
        4,
        12,
        0
    );
    self:addChild(self.processBarLeaveView_ ,100011);
    SpriteUtil.SetLhPos(self.processBarLeaveView_,cc.p(
        274 - self.processBarLeaveView_:getContentSize().width*0.5*CFG_SCALE(0.427),
        453
    ));
    self.spStarIconBgLeaveView_ = SpriteUtil.Create( PathsUtil.ImagePath("gui_acquire_icon_bg.png"));
    self.spStarIconLeaveView_ = SpriteUtil.Create( PathsUtil.ImagePath("gui_acquire_icon.png"));
    self:addChild( self.spStarIconBgLeaveView_ ,100011);
    self:addChild(self.spStarIconLeaveView_,100011);
    SpriteUtil.SetLhPos(self.spStarIconBgLeaveView_,cc.p(438,440));
    SpriteUtil.SetLhPos(self.spStarIconLeaveView_,cc.p(438,440));

    self.lbOfProcessAtLeave_ = cc.Label:createWithSystemFont("0%","YY",31);
    self:addChild(self.lbOfProcessAtLeave_ ,100011);
    self.lbOfProcessAtLeave_:setPosition(cc.p(768/2,1024-407));
    self.lbOfProcessAtLeave_:setColor(ccc4(0,200,255,255));
    self:CloseLeaveView();
    --[[
    local layer =  cc.Layer:create();--cc.LayerColor:create(ccc4(100,0,0,100),10000,10000);
    self.spQuitLayerBg_ = layer;
    self:addChild(self.spQuitLayerBg_,1000009);
    self.spQuitLayerBg_:registerScriptHandler(function(event) 
        if "enter" == event then
            self.spQuitLayerBg_:setTouchEnabled(true);
        elseif "exit" == event then
            self.spQuitLayerBg_:setTouchEnabled(false);
        end
    end)
    self.spQuitLayerBg_:setTouchEnabled(true);
    --self.spQuitLayerBg_:setVisible(false);
    self.spQuitLayerBg_:setContentSize(cc.size(10000,1000));
    ]]--
    

    --[[
    self.testBtn =  ButtonUtil.Create(
        PathsUtil.ImagePath("btnBack.png"), 
        PathsUtil.ImagePath("btnBack.png"),
        function()
            print("13212313113");
        end
    );
    self.testBtn:setScale(1000);
    
    --self:addChild(self.testBtn,1000000);
    self.node = cc.Node:create();
    self:addChild(self.node,1000000);
    self.node:addChild(self.testBtn);
    ]]--

    self.fingerTip_ = TouchArmature:create("point_all",TOUCHARMATURE_NORMAL);
    self.fingerTip_:setPosition(cc.p(768/2 + 30,1024-830));
    self:addChild(self.fingerTip_,100009);
    ArmatureUtil.PlayLoop(self.fingerTip_,1);
    self.fingerTip_:setScale(0.6);
    self.fingerTip_:setVisible(false);

    self.topLayer_ = cc.Node:create();
    self:addChild(self.topLayer_,100011);

    self.spBg_ = SpriteUtil.Create( PathsUtil.ImagePath("bg.png"));
    self:addChild(self.spBg_);
    self.spBg_:setPosition(cc.p(768/2,1024/2));
    self.spBg_:setScale(1);

    self.backBtn_ = ButtonUtil.Create(
        PathsUtil.ImagePath("btnBack.png"), 
        PathsUtil.ImagePath("btnBack.png"),
        function()
            self:getController():OnUserClickBackHome(); 
        end
    );
    self:addChild(self.backBtn_,100010);
    SpriteUtil.SetLhPos(self.backBtn_,cc.p(
        166,
        115
    ));

    self.processBar_ = StickerProcessBar.new();
    self.processBar_:Init(
        PathsUtil.ImagePath("gui_granule.png"),
        PathsUtil.ImagePath("gui_granule_bg.png"),
        PathsUtil.ImagePath("gui_progress_bg.png"),
        1,
        4,
        12,
        0
    );
    self:addChild(self.processBar_,100009);
    --self.processBar_:setPosition(SpriteUtil.ToCocosPoint(131,203));--SpriteUtil.ToCocosPoint(131,7)
    SpriteUtil.SetLhPos(self.processBar_,cc.p(178 - self.processBar_:getContentSize().width*0.5*CFG_SCALE(0.427) ,249));

    self.spStarIconBg_ = SpriteUtil.Create( PathsUtil.ImagePath("gui_acquire_icon_bg.png"));
    self.spStarIcon_ = SpriteUtil.Create( PathsUtil.ImagePath("gui_acquire_icon.png"));
    self:addChild( self.spStarIconBg_ ,100010);
    self:addChild(self.spStarIcon_,100010);
    SpriteUtil.SetLhPos(self.spStarIconBg_,cc.p(340,234));
    SpriteUtil.SetLhPos(self.spStarIcon_,cc.p(340,234));
    --self.spStarIconBg_ :setPosition(SpriteUtil.ToCocosPoint(380,203));
    --self.spStarIcon_:setPosition(SpriteUtil.ToCocosPoint(380,203));

    self.btnNext_ = ButtonUtil.Create( 
        PathsUtil.ImagePath("gui_next_icon.png"), 
        PathsUtil.ImagePath("gui_next_icon.png"),function()	
            -- todo on user click next
            print("self.btnNext_ next");
            self:getController():OnUserClickNextMove();
            self:BtnNextStopHurry();
        end);
    self:addChild(self.btnNext_,100002);
    SpriteUtil.SetLhPos(self.btnNext_,cc.p(332,646));
    local x,y = self.btnNext_:getPosition();
    self.btnNextStandPos_ = cc.p(x,y);
    
    self.carouselBg_ = SpriteUtil.Create(PathsUtil.ImagePath("gui_UI_bg.png"));
    SpriteUtil.SetLhPos( self.carouselBg_ ,cc.p(0,726));
    self:addChild(self.carouselBg_);

    

    self.carouselGroup_ = CarouselGroup.new();
    self.carouselGroup_:SetOffset(2);
    self.carouselGroup_:SetSpacing(0);
    self.carouselGroup_:SetItemSize(cc.size(148,148));
    self.carouselGroup_:SetSpeed(100);
    self.carouselGroup_:SetCreateItemCallBack(function(d)
        local item = CarouselItem.new();
        item:Init(
            PathsUtil.ImagePath("gui_default.png"),
            PathsUtil.ImagePath("gui_select01.png"),
            PathsUtil.ImagePath(d.iconName),
            PathsUtil.ImagePath("gui_vip_icon.png"),
            PathsUtil.ImagePath("gui_needover.png")
        );
        item:SetData(d)
        return item;
    end);
    self.carouselGroup_:SetOnUserSelectItemCallBack(function(item) 
        print("tiem");
        dump(item:GetData());
        self:getController():OnUserSelectDecorationItem(item);
    end);
    self:addChild(self.carouselGroup_);
    self.carouselGroup_:setPosition(cc.p(0,80));
    self.carouselGroup_:setContentSize(cc.size(0,200));
    SpriteUtil.SetLhPos(self.carouselGroup_,cc.p(0,805));

    self.armCard_ = TouchArmature:create("191225wf_ka", TOUCHARMATURE_NORMAL);
    self:addChild(self.armCard_,100001);
    
    ArmatureUtil.PlayAndStay(self.armCard_,1,1);
    self.armCard_:setName("AESOP*npc_ka");

    self.btnRecordAudio_ = ButtonUtil.Create(
        PathsUtil.ImagePath("gui_record_icon.png"),
        PathsUtil.ImagePath("gui_record_icon.png"),
        function()
            self:getController():OnUserClickRecordAudio();
            self:StopFingerTipSeq();
        end
    );
    self:addChild(self.btnRecordAudio_);

    self.btnReRecordAudio_ = ButtonUtil.Create(
        PathsUtil.ImagePath("gui_back_icon.png"),
        PathsUtil.ImagePath("gui_back_icon.png"),
        function() 
            self:getController():OnUserClickReRecordAudio();
        end
    );
    self:addChild(self.btnReRecordAudio_);

    self.btnRecordAudio_:setVisible(false);
    self.btnReRecordAudio_:setVisible(false);

    self.btnPlayAudio_ = BtnAnim.new();
    self.btnPlayAudio_:Init(PathsUtil.ImagePath("gui_voice_01.png"),{
        PathsUtil.ImagePath("gui_voice_01-01.png"),
        PathsUtil.ImagePath("gui_voice_01-02.png"),
        PathsUtil.ImagePath("gui_voice_01-03.png")
    });
    self.btnPlayAudio_:SetClickCallBack(function()
        self:getController():OnUserPlayItsAudio();
    end);
    self:addChild(self.btnPlayAudio_,100002);
    SpriteUtil.SetLhPos(self.btnPlayAudio_,cc.p(186,622));
    self.btnPlayAudio_:setVisible(false);







    -- 
    self.lbOfName_ = cc.Label:createWithSystemFont("","YY",23);
    self:addChild(self.lbOfName_ ,100006);
    self.lbOfName_:setPosition(SpriteUtil.ToCocosPoint(229.05,398));

    self.lbOfNameBg_ = SpriteUtil.Create(PathsUtil.ImagePath("gui_userfont_bg.png"));
    self:addChild(self.lbOfNameBg_ ,100005);
    self.lbOfNameBg_:setPosition(SpriteUtil.ToCocosPoint(229.05,398));
    

    self.btnBgMusic_ = Toggle.new();
    self.btnBgMusic_:Init(
        PathsUtil.ImagePath("btnBgMusic.png"),
        {
            PathsUtil.ImagePath("gui_bgm_icon_ON.png"),
            PathsUtil.ImagePath("gui_bgm_icon_off.png")
        }
    );
    self:addChild(self.btnBgMusic_ ,100005);
    SpriteUtil.SetLhPos(self.btnBgMusic_,cc.p(520,209));
    self.btnBgMusic_:SetClickCallBack(function()
        self:getController():OnUserClickBGMToggle();
    end);

    self.spIconFrame_ = SpriteUtil.Create(PathsUtil.ImagePath("gui_head_img.png"));
    self:addChild(self.spIconFrame_ ,100006);
    self.spIconFrame_:setPosition(SpriteUtil.ToCocosPoint(231.05,334.1));

    self.spHeadIcon_ = UInfoUtil:getInstance():getBabyHeadSprite();
    self:addChild(self.spHeadIcon_ ,100005);
    self.spHeadIcon_:setPosition(SpriteUtil.ToCocosPoint(231.05,334.1));
    self.spHeadIcon_:setScale(0.62);


    self.btnCheckAll_ = ButtonUtil.Create(
        PathsUtil.ImagePath("gui_finish_icon.png"),
        PathsUtil.ImagePath("gui_finish_icon.png"),
        function()
            self:getController():OnUserClickCheckAll();
        end);
    self:addChild(self.btnCheckAll_ ,100005);
    self.btnCheckAll_:setPosition(SpriteUtil.ToCocosPoint(386.1,855.25));
    self.btnCheckAll_:setVisible(false);


    --
    self.btnShare_ = ButtonUtil.Create(
        PathsUtil.ImagePath("gui_share.png"),
        PathsUtil.ImagePath("gui_share.png"),
        function()
            self:getController():OnUserClickShare();
        end);
    self:addChild(self.btnShare_ ,100005);
    self.btnShare_:setPosition(SpriteUtil.ToCocosPoint(621.15,46.05));
    self.btnShare_:setVisible(false);

    self.btnSendCard_ = ButtonUtil.Create(
        PathsUtil.ImagePath("gui_send_btn.png"),
        PathsUtil.ImagePath("gui_send_btn.png"),
        function()
            self:getController():OnUserClickSendCard();
        end);
    self:addChild(self.btnSendCard_ ,100005);
    self.btnSendCard_:setPosition(SpriteUtil.ToCocosPoint(391.1,652.15));
    self.btnSendCard_:setVisible(false);

    self.btnGetGift_ = ButtonUtil.Create(
        PathsUtil.ImagePath("gui_gift_btn.png"),
        PathsUtil.ImagePath("gui_gift_btn.png"),
        function()
            self:getController():OnUserClickBackToMain();
        end);
    self:addChild(self.btnGetGift_ ,100005);
    self.btnGetGift_:setPosition(SpriteUtil.ToCocosPoint(391.1,652.15));
    self.btnGetGift_:setVisible(false);
    

    self.btnReCreate_ = ButtonUtil.Create(
        PathsUtil.ImagePath("gui_back_icon.png"),
        PathsUtil.ImagePath("gui_back_icon.png"),
        function()
            self.btnReCreate_:setVisible(false);
            self:getController():OnUserClickReCreateCard();
        end);
    self:addChild(self.btnReCreate_ ,100005);
    self.btnReCreate_:setPosition(SpriteUtil.ToCocosPoint(391.1,652.15));
    self.btnReCreate_:setVisible(false);


    self:setComplieUIItemVisible(false);
    self:setBGMToggle(true);
end

function ChrismasView:GetProcessStep()
    return self.processBar_:GetIndex();
end

function ChrismasView:BtnNextHurry()
    local rep = cc.RepeatForever:create(cc.Sequence:create(
        cc.MoveBy:create(0.1,cc.p(5,0)),
        cc.MoveBy:create(0.1,cc.p(-5,0))
    ));
    self.btnNext_:runAction(rep);
end

function ChrismasView:BtnNextStopHurry()
    self.btnNext_:stopAllActions();
    self.btnNext_:setPosition(self.btnNextStandPos_);
end

function ChrismasView:StartToNextBtnHurrySeq()
    self:StopToNextBtnHurrySeq();
    local tag = 1002;
    local seq = cc.Sequence:create(cc.DelayTime:create(10),
    cc.CallFunc:create(function() 
        self:BtnNextHurry();
    end));
    seq:setTag(tag);
    self:runAction(seq);
end

function ChrismasView:StopToNextBtnHurrySeq()
    self:stopActionByTag(1002);
end

function ChrismasView:StartFingerTipSeq()
    print("start finger tip.................");

    self:StopFingerTipSeq();
    local tag = 1001;
    local seq = cc.Sequence:create(cc.DelayTime:create(3),
    cc.CallFunc:create(function() 
        self.fingerTip_:setVisible(true);
        print("show finger tip.................");
    end));
    seq:setTag(tag);
    self:runAction(seq);
end
function ChrismasView:StopFingerTipSeq()
    self.fingerTip_:setVisible(false);
    self:stopActionByTag(1001);
end

function ChrismasView:setBGMToggle(v)
    if v then 
        SoundUtil:getInstance():playBackgroundMusic(g_tConfigTable.sTaskpath.."sounds/bgm_no_16.mp3",true);
        self.btnBgMusic_:On();
    else
        SoundUtil:getInstance():stopBackgroundMusic(g_tConfigTable.sTaskpath.."sounds/bgm_no_16.mp3",true);
        self.btnBgMusic_:Off();
    end
end

function ChrismasView:setComplieUIItemVisible(result)
    self.lbOfName_:setVisible(result);
    self.lbOfNameBg_:setVisible(result);
    self.btnBgMusic_:setVisible(result);
    self.spIconFrame_:setVisible(result);
    self.spHeadIcon_:setVisible(result);
end

function ChrismasView:setProcessBarViewVisible( result )
    self.processBar_:setVisible(result);
    self.spStarIconBg_:setVisible(result);
    self.spStarIcon_:setVisible(result);
end

--[[]]--
function ChrismasView:XblCueGetGift(cb)
    local jsonName = "Xmas135";
    self:PlayJson(jsonName,false,function() 
        if cb ~= nil then 
            cb();
        end
    end);
end

function ChrismasView:StartXBLCueGetGift()

    self:StopXBLCueGetGift();
    local tag = 4321;
    local seq = cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(function()
        self:XblTellCueGetGift();
    end));
    seq:setTag(tag);
    self:runAction(seq);
end

function ChrismasView:StopXBLCueGetGift()
    self:stopActionByTag(4321);
end

function ChrismasView:ClearCardShowStatus()

    --[[

    local x,y = self.armCard_:getPosition();
    self.armCard_:removeFromParent();


    self.armCard_:create("191225wf_ka", TOUCHARMATURE_NORMAL);
    self:addChild(self.armCard_,100001);
    ArmatureUtil.PlayAndStay(self.armCard_,1,1);
    self.armCard_:setName("AESOP*npc_ka");
]]--

    self.armCard_:ChangeOneSkin("kapian1","191225kong");--"kapian2","gui_heka"..index
    self.armCard_:ChangeOneSkin("kapian2","191225kong");--"kapian2","gui_heka"..index
    self.armCard_:ChangeOneSkin("tietu","191225kong");
    self.armCard_:ChangeOneSkin("youdian","191225kong");

end

function ChrismasView:XblTellCueGetGift()
    local jsonName = "Xmas135" ;
    self:PlayJson(jsonName,true,function()
        self:StartXBLCueGetGift();
    end);
end

function ChrismasView:XblCueShowToParent()
    local jsonName = "Xmas133" ;
    self:PlayJson(jsonName,false,function() end);
end
function ChrismasView:XblCueSendForParent(cb)
    local jsonName = "Xmas134" ;
    self:PlayJson(jsonName,false,function() 
        if cb ~= nil then 
            cb();
        end
    end);
end

function ChrismasView:XblCueDecorationStep(step)
    local jsonName = "buzhou" .. step;
    self:PlayJson(jsonName,false,function() end);
end

function ChrismasView:XblCueRecodeAudio()
    local jsonName = "buzhou4";
    self:PlayJson(jsonName,false,function() end); 
end

function ChrismasView:XblCueFinish( isFollowWx,cb)
    -- body
    self:PlayJson("buzhou5",false,function()
        self:PlayJson("buzhou5a",false,function()

            if cb ~= nil then 
                cb();
            end
            --[[
            if isFollowWx then 
                self:PlayJson("Xmas134",false,function()
                    if cb ~= nil then 
                        cb();
                    end
                end);
            else 
                self:PlayJson("Xmas133",false,function()
                    if cb ~= nil then 
                        cb();
                    end
                end);
            end]]--
        end); 
    end); 
end

function ChrismasView:PlayJson(jsonName,isNeedCallBack,cb)
    --print(debug.traceback(  ));
   -- print("jsonName:"..jsonName);
   
    local path =g_tConfigTable.sTaskpath .. "audio/Xmas082.mp3";
    SoundUtil:getInstance():stop(path);


    local curIdStr = UInfoUtil:getInstance():getCurUidStr();
    local aimPath = GET_REAL_PATH_ONLY("",PathGetRet_ONLY_SD) .. "xialingyingTemp/".."user_"..curIdStr.."_cardAudio.wav"
    SoundUtil:getInstance():stop(aimPath);
    self:StopAudioAnim();

    JsonScriptUtil.StopAllAction(self);
    JsonScriptUtil.PlayBgConfig(self,jsonName,function(e) 
        print("sssl1"..e);
        if e == "Complie" then 
            print("sssl2");

            if cb ~= nil then 
                print("sssl3");

                cb();
            end
        elseif e == "Interupt" or e == "InternalINterupt" then 
            print("sssl4");

            if isNeedCallBack then 
                print("sssl5");

                if cb ~= nil then 
                    print("sssl6");

                    cb();
                end
            end
        end
    end);
end


--[[
    方法 撤销界面       
    包括:
        删除所有持有的显示对象 
        注销所有持有的UI事件
]]--
function ChrismasView:Dispose()
   JsonScriptUtil.StopAllAction(self);
   self:stopAllActions();
   print("stopAllAcion -------------------------------------------------- ");
end

function ChrismasView:Update(d)
    self.lbOfName_:setString(d.userName); 
    -- todo dispose view
    if d.ViewType == ChrismasData.EnumViewType.E_DECORATION then 
        self:updateViewAsDecoration(d);
    elseif d.ViewType == ChrismasData.EnumViewType.E_RECORD_AUDIO then 
        self:updateViewAsRecordAudio(d);
    elseif d.ViewType == ChrismasData.EnumViewType.E_FINISH then 
        self:updateViewAsFinish(d);
    elseif d.ViewType == ChrismasData.EnumViewType.E_SHARE then 
        self:updateViewAsShare(d);
    elseif d.ViewType == ChrismasData.EnumViewType.E_GET_GIFT  then 
        self:updateViewAsGetGift(d);
    elseif d.ViewType == ChrismasData.EnumViewType.E_OLD then 
        self:updateViewAsOld(d);
    end
end

function ChrismasView:setCardThingUpMode()
    self.lbOfName_    :setPositionY(self.lbOfName_    :getPositionY()+119);
    self.lbOfNameBg_  :setPositionY(self.lbOfNameBg_  :getPositionY()+119);
    self.btnBgMusic_  :setPositionY(self.btnBgMusic_  :getPositionY()+119);
    self.spIconFrame_ :setPositionY(self.spIconFrame_ :getPositionY()+119);
    self.spHeadIcon_  :setPositionY(self.spHeadIcon_  :getPositionY()+119);
    self.btnPlayAudio_:setPositionY(self.btnPlayAudio_:getPositionY()+119);
end

function ChrismasView:setCardThingDownMode()
    self.lbOfName_    :setPositionY(self.lbOfName_    :getPositionY()-119);
    self.lbOfNameBg_  :setPositionY(self.lbOfNameBg_  :getPositionY()-119);
    self.btnBgMusic_  :setPositionY(self.btnBgMusic_  :getPositionY()-119);
    self.spIconFrame_ :setPositionY(self.spIconFrame_ :getPositionY()-119);
    self.spHeadIcon_  :setPositionY(self.spHeadIcon_  :getPositionY()-119);
    self.btnPlayAudio_:setPositionY(self.btnPlayAudio_:getPositionY()-119);
end


function ChrismasView:updateViewAsOld(d) --Xmas135
    print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
    dump(d);
    self.armCard_:ChangeOneSkin("kapian2","gui_heka".. d.TempDecorationOptions[1]);--"kapian2","gui_heka"..index
    self.armCard_:ChangeOneSkin("tietu","191225wf_tie0".. d.TempDecorationOptions[2]);
    self.armCard_:ChangeOneSkin("youdian","191225wf_zi0".. d.TempDecorationOptions[3]);
    ArmatureUtil.Play(self.armCard_,1);

    self.processBar_:setVisible(false);
    self.spStarIconBg_:setVisible(false);
    self.spStarIcon_:setVisible(false);

    self.btnNext_:setVisible(false);
    self.btnReCreate_:setVisible(true);
    self.btnPlayAudio_:setVisible(true);

    self.carouselGroup_:setVisible(false);
    self.carouselBg_:setVisible(false);

    self:setComplieUIItemVisible(true);

    SpriteUtil.SetLhPos(self.lbOfNameBg_,cc.p(207,288));
    local x,y = self.lbOfNameBg_:getPosition();
    self.lbOfName_:setPosition(cc.p(x,y));

    SpriteUtil.SetLhPos(self.btnBgMusic_,cc.p(520,209));

    SpriteUtil.SetLhPos(self.spIconFrame_,cc.p(204,197));
    x,y = self.spIconFrame_:getPosition();
    self.spHeadIcon_:setPosition(x,y);
   -- SpriteUtil.SetLhPos(self.spHeadIcon_,cc.p(203,209));
    SpriteUtil.SetLhPos(self.btnPlayAudio_,cc.p(190,504));

    --[[
    local xbl = self:getChildByName("XBL");
    if xbl == nil then 
        xbl = TouchArmature:create("XBL2019_ZH_type2",TOUCHARMATURE_NORMAL);
        self:addChild(xbl,100001);
        xbl:setPosition(cc.p(502,292));
        xbl:setName("XBL");
    end
    ]]--

    --[[
    self.spIconFrame_ :setPositionY(self.spIconFrame_ :getPositionY()-119);
    self.spHeadIcon_  :setPositionY(self.spHeadIcon_  :getPositionY()-119);
    self.btnPlayAudio_:setPositionY(self.btnPlayAudio_:getPositionY()-119);]]--
end

function ChrismasView:updateViewAsGetGift(d)
    self.btnSendCard_:setVisible(false);
    self.btnGetGift_:setVisible(true);
end

function ChrismasView:updateViewAsDecoration(d)
    ArmatureUtil.PlayAndStay(self.armCard_,1,1);
    self:setComplieUIItemVisible(false);
    if self.btnNext_ ~= nil then 
        SpriteUtil.SetLhPos(self.btnNext_,cc.p(332,646));
        local x,y = self.btnNext_:getPosition();
        self.btnNextStandPos_ = cc.p(x,y);

        self.btnNext_:setVisible(false); 
    end

    local step = d.DecorationStep;

    
    
    self.fingerTip_:setPosition(cc.p(768/2 + 30,1024-830));

    
    if self.processBar_ ~= nil then 
        self.processBar_:setVisible(true);
        self.processBar_:UpdateProcessByIndex(step - 1);
    end

    self.armCard_:setPosition(cc.p(384,512));
    self.armCard_:setZOrder(100001);
    local xbl = self:getChildByName("XBL");
    if xbl ~= nil then 
        xbl:setZOrder(100000);
    end
    self.btnPlayAudio_:setVisible(false);
    self.spStarIconBg_:setVisible(true);
    self.spStarIcon_:setVisible(true);

    self.carouselGroup_:setVisible(true);
    self.carouselBg_:setVisible(true);

    if self.carouselGroup_ ~= nil then 
        local listOfItemsData = {};
        print("step:" .. step);
        -- singleTimeList
        if step == 1 then 
            listOfItemsData = d.ListOfBackGroundOption;
        elseif step == 2 then 
            listOfItemsData = d.ListOfDecorationOption;
        elseif step == 3 then 
            listOfItemsData = d.ListOfWordOption;
        end

        -- is vip
        local startIndex = 2;
        if d.IsVip then 
            startIndex = 1;
        end

        local nowList = {};

        for i = startIndex , #listOfItemsData , 1 do 
            table.insert(nowList,listOfItemsData[i]);
        end

        -- is need double
        if #nowList >= 4 then 
            for i = startIndex , #listOfItemsData , 1 do 
                table.insert(nowList,listOfItemsData[i]);
            end
            self.carouselGroup_:Update(nowList);
            self.carouselGroup_:startMove();
            
            self.carouselGroup_:setPositionX(
                self.carouselGroup_.offset_ + self.carouselGroup_.itemSize_.width/2
            );
        else
            local size = cc.Director:getInstance():getWinSize();
            print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx123");
            dump(size);
            local num = (size.width/2) - ((self.carouselGroup_.itemSize_.width+self.carouselGroup_.spacing_)*
            (#self.carouselGroup_.listOfItems_))/2;
            print("num:"..num);
            self.carouselGroup_:Update(nowList);

            local x,y = self.armCard_:getPosition();
       
            self.carouselGroup_:setPositionX(
                x - ((self.carouselGroup_.itemSize_.width+self.carouselGroup_.spacing_)*
                (#self.carouselGroup_.listOfItems_))/2 - self.carouselGroup_.offset_ 
                --[[
                self.carouselGroup_.offset_ + 
                self.carouselGroup_.itemSize_.width/2  --+ 235--+
                + (768/2) - ((self.carouselGroup_.itemSize_.width+self.carouselGroup_.spacing_)*
                (#self.carouselGroup_.listOfItems_))/2 --

                ]]--
            );
        end

    end
end

function ChrismasView:StartAudioAnim()
    self.btnPlayAudio_:Run();

end

function ChrismasView:StopAudioAnim()
    self.btnPlayAudio_:Idle();
end

function ChrismasView:updateViewAsRecordAudio(d)
    self.processBar_:UpdateProcessByIndex(3);
    if self.carouselGroup_ ~= nil then 
        self.carouselGroup_:setVisible(false);
    end
    if  self.btnPlayAudio_ ~= nil then 
        self.btnPlayAudio_:setVisible(false);
    end
    if self.carouselBg_ ~= nil then 
        self.carouselBg_:setVisible(false);
    end
    self.btnRecordAudio_:setVisible(true);
    SpriteUtil.SetPosForLanHu(self.btnRecordAudio_,cc.p(332,761));
    --self.btnRecordAudio_:setPosition(SpriteUtil.ToCocosPoint(375,835));

    local x,y = self.btnRecordAudio_:getPosition();
    self.fingerTip_:setPosition(x,y);
    self:StartFingerTipSeq();


    self.btnNext_:setVisible(false); 
    self.btnReRecordAudio_:setVisible(false);

    SpriteUtil.SetPosForLanHu(self.btnReRecordAudio_,cc.p(254,761));
    SpriteUtil.SetPosForLanHu(self.btnNext_,cc.p(412,763));
    local x,y = self.btnNext_:getPosition();
    self.btnNextStandPos_ = cc.p(x,y);
    --self.btnReRecordAudio_:setPosition(SpriteUtil.ToCocosPoint(283.05,864));
end

function ChrismasView:updateViewAsFinish(d)
    --self:setComplieUIItemVisible(true);
    self.processBar_:UpdateProcessByIndex(4);
    SpriteUtil.SetLhPos(self.lbOfNameBg_,cc.p(204,406));
    local x,y = self.lbOfNameBg_:getPosition();
    self.lbOfName_:setPosition(cc.p(x,y));
    --SpriteUtil.SetLhPos(self.lbOfName_,cc.p(242,295));
    SpriteUtil.SetLhPos(self.btnBgMusic_,cc.p(520,328));

    SpriteUtil.SetLhPos(self.spIconFrame_,cc.p(204,317));
    local x,y = self.spIconFrame_:getPosition();
    self.spHeadIcon_:setPosition(cc.p(x,y));
    --SpriteUtil.SetLhPos(self.spHeadIcon_,cc.p(209,203));
    SpriteUtil.SetLhPos(self.btnPlayAudio_,cc.p(190,623));
    
    self:setComplieUIItemVisible(true);


    self:setProcessBarViewVisible(false);
    self.btnReRecordAudio_:setVisible(false);
    self.btnNext_:setVisible(false);
    self.btnCheckAll_:setVisible(true);
end

function ChrismasView:closeCheckAllBtn( )
    self.btnCheckAll_:setVisible(false);
end
function ChrismasView:closeRecordAudioBtn()
    self.btnPlayAudio_:setVisible(false);
end

function ChrismasView:updateViewAsShare(d)
    self:setComplieUIItemVisible(true);
    self.btnPlayAudio_:setVisible(true);
    local upValue = 119;

    SpriteUtil.SetLhPos(self.lbOfName_,cc.p(242,295));
    SpriteUtil.SetLhPos(self.lbOfNameBg_,cc.p(207,288));
    SpriteUtil.SetLhPos(self.btnBgMusic_,cc.p(520,209));
    SpriteUtil.SetLhPos(self.spIconFrame_,cc.p(204,197));
    local x,y = self.spIconFrame_:getPosition();
    self.spHeadIcon_:setPosition(cc.p(x,y));
    
    --SpriteUtil.SetLhPos(self.spHeadIcon_,cc.p(209,203));
    SpriteUtil.SetLhPos(self.btnPlayAudio_,cc.p(190,504));

    SpriteUtil.SetLhPos(self.btnShare_,cc.p(529,103));
    self.btnShare_:setVisible(true);
    self.btnSendCard_:setVisible(true);

    --[[
    if self:getController():GetIsSuccess() then 
        self.btnShare_:setVisible(false);
        self.btnSendCard_:setVisible(false);
        self.btnReCreate_:setVisible(true);
    end
    ]]--
end

function ChrismasView:screenShotCardByData(list)--  --191225wf_tie0 191225wf_zi0
    dump(list); --  
    local armCard_ = TouchArmature:create("191225wf_ka", TOUCHARMATURE_NORMAL);
    armCard_:ChangeOneSkin("kapian2","gui_heka"..list[1]);--"kapian2","gui_heka"..index
    armCard_:ChangeOneSkin("tietu","191225wf_tie0"..list[2]);
    armCard_:ChangeOneSkin("youdian","191225wf_zi0"..list[3]);
    armCard_:setPosition(cc.p(435/2,380/2));

    ArmatureUtil.Play(armCard_,0);
    self:addChild(armCard_,0);
    

    local rt = cc.RenderTexture:create(
         435
        ,369);-- 
    rt:begin(); 
    armCard_:visit();
    rt:endToLua();
    rt:saveToFile("ChrisMasCard.png",1);
    armCard_:removeFromParent();
end

function ChrismasView:screenShot()
    self.armCard_:setPosition(435/2,380/2);
    print("path123:" .. cc.FileUtils:getInstance():getWritablePath() );
    local rt = cc.RenderTexture:create(
        435
        ,369);-- 
    rt:begin(); 
    self.armCard_:visit();
    rt:endToLua();
    rt:saveToFile("testHere.png",1);
 --[[]]--
end

function ChrismasView:ShowItemFlyToAimByItem(item)
    local data = item:GetData();
    local x,y = item:getPosition();
    local posOfItem = cc.p(x,y);
    posOfItem = item:getParent():convertToWorldSpace(posOfItem);
    posOfItem = self:convertToNodeSpace(posOfItem);

    local startPos = posOfItem;
    local endPos = cc.p(768/2,1024/2);
    local spName = PathsUtil.ImagePath(data.iconName);
    local sp = SpriteUtil.Create(spName);
    sp:setPosition(startPos);
    self:addChild(sp,100010);
    local index = data.index;
    sp:runAction(cc.Sequence:create(cc.MoveTo:create(0.25,endPos),cc.CallFunc:create(function()
        -- armture update
        sp:removeFromParent();
        self:getController():OnTryDecorationByIndex(index);
    end)));
end

function ChrismasView:ShowNextBtn()
    if self.btnNext_ ~= nil then
        self.btnNext_:setVisible(true);
    end
end

function ChrismasView:StopAllJsonActions()
    JsonScriptUtil.StopAllAction(self);
end

function ChrismasView:SwitchCardByIndex(index,preIndex)
    if self.armCard_ ~= nil then 
        self.armCard_:ChangeOneSkin("kapian2","gui_heka"..index)  
        if preIndex == -1 then 
            print("catchKong xxxxxxxxxxxxx");
            self.armCard_:ChangeOneSkin("kapian1","191225kong")  
        else
            print("catchKong yyyyyyyyyyyy");
            self.armCard_:ChangeOneSkin("kapian1","gui_heka" .. preIndex)  
        end
        ArmatureUtil.Play(self.armCard_,2);
    end
end

function ChrismasView:SwitchDecorationByIndex(index)
    if self.armCard_ ~= nil then 
        self.armCard_:ChangeOneSkin("tietu","191225wf_tie0"..index)
        ArmatureUtil.Play(self.armCard_,3);
    end
end

function ChrismasView:SwitchWordByIndex(index)
    if self.armCard_ ~= nil then 
        self.armCard_:ChangeOneSkin("youdian","191225wf_zi0"..index) 
        ArmatureUtil.Play(self.armCard_,4);
    end
end

function ChrismasView:XblCueLoveParent(cb)
    local count = #JsonScriptConfig.ListOfPrayForParent;
    math.randomseed(os.time());
    local index = math.random(1,count);
    local jsonName = JsonScriptConfig.ListOfPrayForParent[index];
    self:getController().xblLeadWord_ = jsonName;
    self:PlayJson(jsonName,false,function() 
        if cb ~= nil then 
            print("marka");
            cb();
        end
    end);
end

function ChrismasView:XblCue(name,cb)
    self:PlayJson(name,false,function() 
        if cb ~= nil then 
            cb();
        end
    end);
end

function ChrismasView:XblCueAudioToPoint(cb)
    local jsonName = JsonScriptConfig.AudioFlyToAim;
    self:PlayJson(jsonName,false,function() 
        if cb ~= nil then 
            cb();
        end
    end);
end

function ChrismasView:setViewAsRecordingMode()
    self.btnRecordAudio_:setVisible(false);
    self.btnReRecordAudio_:setVisible(false);
    self.btnPlayAudio_:setVisible(false);
    
end

function ChrismasView:setViewAsRecordComplieMode()
    self.btnPlayAudio_:setVisible(true);
    self.btnReRecordAudio_:setVisible(true);
    self.btnNext_:setVisible(true);
    
end



function ChrismasView:StartRecord( cb )
    -- body
    SoundUtil:getInstance():soundListenStartLua(
        Utils:GetInstance().sourceType,
        Utils:GetInstance().sourceId,
        false,
        function(iEndType)
            print(iEndType)
            --Utils:GetInstance():removeListenTips(self.topLayer_)
            SoundUtil:getInstance():soundListenStop()
            SoundUtil:getInstance():resumeBackgroundMusic();
            self.tipsNode_:removeFromParent();

            if iEndType > 0 then
                Utils:GetInstance():doSetMicTypeToNormal();
                local iMicType = Utils:GetInstance():doGetMicType();
                if iMicType == MIC_BAD then 
                else
                    self:getController():OnUserRecordSuccess();
                end
            end
            if cb ~= nil then 
                cb();
            end
        end);
    local pos = SpriteUtil.ToCocosPoint(50, 866);--387.1

    SoundUtil:getInstance():pauseBackgroundMusic();
    local x,y = self.btnRecordAudio_:getPosition();
    self.tipsNode_ = TouchArmature:create("voicetips", TOUCHARMATURE_NORMAL);
    self.tipsNode_:playByIndexOnlyArmature(0);
    self.tipsNode_:setPosition(cc.p(x,y));
    self:addChild(self.tipsNode_,100009);

    --Utils:GetInstance():addListenTips(CCP(pos.x,pos.y),self.topLayer_)
end

            
            --[[


            SoundUtil:getInstance():soundListenStartLua(
                Utils:GetInstance().sourceType,
                Utils:GetInstance().sourceId,
                false,
                function(iEndType)
                         print(iEndType)
                    self:soundListenerCallback(iEndType)
                end
            )
            Utils:GetInstance():addListenTips(CCP(375, 200),self.topLayer_)

            function shout:listenSound()
                SoundUtil:getInstance():soundListenStartLua(
                    Utils:GetInstance().sourceType,
                    Utils:GetInstance().sourceId,
                    false,
                            function(iEndType)
                                    print(iEndType)
                        self:soundListenerCallback(iEndType)
                    end
                )
                Utils:GetInstance():addListenTips(CCP(cc.p(384)-self.wx, cc.p(212)-self.wy), self)
            end
            function shout:soundListenerCallback(ntype)
                Utils:GetInstance():removeListenTips(self)
                SoundUtil:getInstance():soundListenStop()
                local iMicType = Utils:GetInstance():doGetMicType()
                if iMicType == 1 then
                    print(" in LUA TouchCryNode::soundListenerCallback  iMicType==MIC_BAD")
                end
                --录音结束
                self:playAudio(self.Cfg.special[1].endJson,function()
                    self:refreshEndScene()
                end)
                
                if ntype > 0 then
                    Utils:GetInstance():doSetMicTypeToNormal()
                end
            end
            ]]--

return ChrismasView;


    --[[
    local item = CarouselItem.new();
    item:Init(
        PathsUtil.ImagePath("gui_default.png"),
        PathsUtil.ImagePath("gui_select01.png"),
        PathsUtil.ImagePath("gui_heka01_vip.png"),
        PathsUtil.ImagePath("gui_vip_icon.png"),
        PathsUtil.ImagePath("gui_needover.png"));
    self:addChild(item);
    item:setPosition(cc.p(200,200));]]--