
local SpriteUtil = requirePack("scripts.Utils.SpriteUtil"); 

local ScaleProcess = class("ScaleProcess",function()
    return cc.Node:create();
end);
g_tConfigTable.CREATE_NEW(ScaleProcess);

function ScaleProcess:ctor()
    self.spBg_ = nil;
    self.spContent_ = nil;
    self.origScale_ = 1;
end

function ScaleProcess:Init(bgPath,contentPath)
    self.spBg_ = SpriteUtil.Create(bgPath);
    self.spContent_ = SpriteUtil.Create(contentPath);
    self:addChild(self.spBg_);
    self:addChild(self.spContent_);
    self.origScale_ = self.spContent_:getScale();
    self.spContent_:setAnchorPoint(cc.p(0,0.5));
    local contentSize = SpriteUtil.GetContentSize(self.spContent_);
    self:setContentSize(contentSize);
    self.spContent_:setPositionX(-contentSize.width/2);
end

--[[
    v: [0-1]
]]--
function ScaleProcess:Process(v)
    self.spContent_:setScaleX( v * self.origScale_ );
end

return ScaleProcess;


    --[[
        test code rember include
    self.processTest = ScaleProcess.new();
    self.processTest:Init(PathsUtil.ImagePath("gui_jindu_bg.png"),PathsUtil.ImagePath("gui_jindu_s.png"));
    self.processTest:setPosition(cc.p(100,100));
    self.processTest:Process(0.0);
    self:addChild(self.processTest);

    self.value_ = 0;
    self.maxValue_ = 100
    self:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.016),cc.CallFunc:create(function()
        self.value_ = self.value_ + 1;
        if self.value_ >= self.maxValue_ then 
            self.value_ = 0;
        end
        self.processTest:Process(self.value_/self.maxValue_);
    end))) )
    ]]--