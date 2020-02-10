requirePack(g_tConfigTable.NewRootFolderPath.."FrameWork.Global.GlobalFunctions");
local TouchArmatureTmp = class("TouchArmatureTmp",function() 
    return cc.Node:create();
end);

g_tConfigTable.CREATE_NEW(TouchArmatureTmp);
---------------声明区----------------------
TouchArmatureTmp.EnumPlayLoopType = {
    ["LOOP_ORIG"] = -1,
    ["LOOP_NO"] = 0,
    ["LOOP_YES"] = 1,
}

TouchArmatureTmp.EnumPlayCallBackType = {
    ["TouchArmLuaStatus_AnimEnd"] = 0;
    ["TouchArmLuaStatus_AnimLoopEnd"] = 1;
    ["TouchArmLuaStatus_AnimPerEnd"] = 2;
    ["TouchArmLuaStatus_CustomEvent"] =3;
    ["TouchArmLuaStatus_TouchBegan"] = 4;
    ["TouchArmLuaStatus_TouchMoved"] = 5;
    ["TouchArmLuaStatus_TouchEnded"] = 6;
    ["TouchArmLuaStatus_TouchArmEnded"] =7;
}

---------------私有方法---------------------

function TouchArmatureTmp:onExit() 
    print("TouchArmatureTmp:onExit");
    if self.updateHandle_ ~= nil then 
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.updateHandle_);
    end
end


function TouchArmatureTmp:ctor()
    self:enableNodeEvents();
end
function TouchArmatureTmp:updateArmName(n)
    self.lArmName_:setString("ArmName:"..n);
end

function TouchArmatureTmp:updatePlayIndex(n)
    self.lPlayIndex_:setString("Index:"..n);
end

function TouchArmatureTmp:updateChildArmture(n)
    self.lChildArmature:setString("childArm:"..n);
end

function TouchArmatureTmp:updateTime(n)
    self.lTime:setString("time:"..n);
end

function TouchArmatureTmp:update(dt)
    if self.isPlaying_ then 
        if self.time_ == 0 then 
            self:callBackStart();
        end
        self.time_ = self.time_ + dt;
        -- update play time:
        self:updateTime(self.time_);
        if self.aimTime_<= self.time_ then 
           -- play a loop
           -- if continue
           if self.isPlayForever_ then 
               self.time_ = 0;
               self:callBackOneLoop();
           else 
                self.isPlaying_ = false;
                self:callBackStop();
           end
        end
    end
end

function TouchArmatureTmp:callBackOneLoop()
    if self.cb_ ~= nil then 
        self.cb_(TouchArmatureTmp.EnumPlayCallBackType.TouchArmLuaStatus_AnimPerEnd,self,-1);
    end
end

function TouchArmatureTmp:callBackStop()
    if self.cb_ ~= nil then 
        self.cb_(TouchArmatureTmp.EnumPlayCallBackType.TouchArmLuaStatus_AnimEnd,self,-1);
    end
end

function TouchArmatureTmp:callBackStart()
    if self.cb_ ~= nil then 
        self.cb_(TouchArmatureTmp.EnumPlayCallBackType.TouchArmLuaStatus_TouchBegan,self,-1);
    end
end

function TouchArmatureTmp:stopPlayingAnimation()
    if self.isPlaying_ then 
        self.time_ = self.aimTime_ ;
        self.isPlayForever_ = false;
        self:update(0.016);
    end
end

function TouchArmatureTmp:initData()
    self.time_ = 0;
    self.aimTime_ = 0;
    self.isPlayForever_ = false;
    self.isPlaying_ = false;
end

function TouchArmatureTmp:initBg(size)
    if size ~= nil then 
        local spBg = cc.Scale9Sprite:create(
            "allimgs/spRedBox.png",
            cc.rect(0,0,12,12),
            cc.rect(2,2,7,7)
        );
        self:addChild(spBg);
        spBg:setContentSize(size.width,size.height);
    end
end

function TouchArmatureTmp:initText(animName)
    local l =  cc.Label:createWithSystemFont("", "Arial", 18);
    self:addChild(l);
    self.lArmName_ = l;

    self.lPlayIndex_ = cc.Label:createWithSystemFont("", "Arial", 18);
    self:addChild(self.lPlayIndex_);
    self.lPlayIndex_:setPositionY(-30);

    self.lChildArmature = cc.Label:createWithSystemFont("", "Arial", 18);
    self:addChild(self.lChildArmature);
    self.lChildArmature:setPositionY(-60);

    self.lTime =  cc.Label:createWithSystemFont("", "Arial", 18);
    self:addChild(self.lTime);
    self.lTime:setPositionY(30);

    if animName ~= nil then 
        self.armName_ = animName;
        self:updateArmName(self.armName_);
    end
    self.playIndex_ = "";
    self:updatePlayIndex(self.playIndex_);
    self.childArm_ = "";
    self:updateChildArmture(self.childArm_);
    self:updateTime(self.time_);
end

function TouchArmatureTmp:initUpdate()
    self.updateHandle_ = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt) 
        self:update(dt);
    end,0,false);  
end

function TouchArmatureTmp:playOnce(index,dt)
    self.time_ = 0;
    self.aimTime_ = dt;
    self.isPlayForever_ = false;
    self.isPlaying_ = true;
end

function TouchArmatureTmp:playForever(index,dt)
    self.time_ = 0;
    self.aimTime_ =dt;
    self.isPlayForever_ = true;
    self.isPlaying_ = true;
end


-----------------对外接口-----------------------
function TouchArmatureTmp:Init(animName,size)
    self:initData();
    self:initBg(size);
    self:initText(animName);
    self:initUpdate();
end

function TouchArmatureTmp:playByIndex(index,iLoop,dt)
    -- break before play
    self:stopPlayingAnimation();
    -- play now
    dt = dt or 10;
    if iLoop == TouchArmatureTmp.EnumPlayLoopType.LOOP_ORIG then 
        self:playOnce(index,dt);
    elseif iLoop == TouchArmatureTmp.EnumPlayLoopType.LOOP_NO then 
        self:playOnce(index,dt);
    elseif iLoop == TouchArmatureTmp.EnumPlayLoopType.LOOP_YES then 
        self:playForever(index,dt);
    end
    -- update play index
    self.playIndex_  = index;
    self:updatePlayIndex(self.playIndex_ );
end

function TouchArmatureTmp:changeArmature(animName,index)
    self.armName_ = animName
    self:updateArmName(self.armName_);
    self:playByIndex(index,TouchArmatureTmp.EnumPlayLoopType.LOOP_NO);
end

function TouchArmatureTmp:changeChildArmaturesToName(childArmName,animName)
    self.childArm_ = childArmName;
    self:updateChildArmture(self.childArm_);
end

function TouchArmatureTmp:changeChildArmatureToName(childArmName,animName)
    self:changeChildArmaturesToName(childArmName,animName);
end

function TouchArmatureTmp:setLuaCallBack(cb)
    self.cb_ = cb;
end

return TouchArmatureTmp;
