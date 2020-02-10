local ArmatureUtil = requirePack("scripts.Utils.ArmatureUtil"); 
local PathsUtil = requirePack("scripts.Utils.PathsUtil"); 
local SpriteUtil = requirePack("scripts.Utils.SpriteUtil"); 
local ButtonUtil = requirePack("scripts.Utils.ButtonUtil");

local SnowBall = class("SnowBall",function() 
    return cc.Node:create();
end);
g_tConfigTable.CREATE_NEW(SnowBall);

function SnowBall:ctor()
    self.btn_ = nil;
    self.arm_ = nil;
    self.controller_ = nil;
end

function SnowBall:Init(armName,btnPath,controller)
    self.btn_ = ButtonUtil.Create(btnPath,btnPath,function() 
        self:OnUserClick();
    end);
    self:addChild(self.btn_);

    self.arm_ =TouchArmature:create(armName, TOUCHARMATURE_NORMAL);
    self:addChild(self.arm_);
    ArmatureUtil.PlayLoop(self.arm_,0);
end

function SnowBall:OnUserClick()
    Utils:GetInstance():baiduTongji("qunahuodongMD","310_end_wanfatouch")
    ArmatureUtil.Play(self.arm_,1);
    self.arm_:setLuaCallBack(
        function(eType, _tempArm, sEvent)
            if eType == TouchArmLuaStatus_AnimEnd then
                self:removeFromParent();
            end
        end
    );
end


return SnowBall;