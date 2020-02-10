local ButtonUtil = requirePack("scripts.Utils.ButtonUtil"); 
local FramesItem = requirePack("scripts.UI.FramesItem");


local BtnAnim = class("BtnAnim",function() 
    return cc.Node:create();
end);
g_tConfigTable.CREATE_NEW(FramesItem);

function BtnAnim:ctor()
    self.clickCallBack_ = nil;
end

function BtnAnim:OnBtnClick()
    if self.clickCallBack_ ~= nil then 
        self.clickCallBack_(self);
    end
end

function BtnAnim:SetClickCallBack(cb)
    self.clickCallBack_ = cb;
end

function BtnAnim:Init(filePath,animFilePathsList)
    self.btn_ = ButtonUtil.Create(
        filePath,
        filePath,
        function()
            self:OnBtnClick();
        end);
    self:addChild(self.btn_,1);
    local contentSize = self.btn_:getContentSize();
    self:setContentSize(contentSize);

    self.frameAnim_ = FramesItem.new();
    self.frameAnim_:Init(animFilePathsList);
    self:addChild(self.frameAnim_,2);
    self.frameAnim_:setVisible(false);

    self.frameIndex_ = 1;
    self.frameAnim_:runAction(
        cc.RepeatForever:create(cc.Sequence:create(
            cc.DelayTime:create(0.5),
            cc.CallFunc:create(function() 
                local index = self.frameIndex_ % self.frameAnim_:Count() + 1;
                self.frameAnim_:Index(index);
                self.frameIndex_  = self.frameIndex_  + 1;
                if self.frameIndex_>10000 then 
                    self.frameIndex_ = 1;
                end
            end)
        ))
    );
end

function BtnAnim:Idle()
    self.btn_:setVisible(true);
    self.frameAnim_:setVisible(false);
end

function BtnAnim:Run()
    self.frameAnim_:setVisible(true);
    self.btn_:setVisible(false);
end





return BtnAnim;