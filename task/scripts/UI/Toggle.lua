local FramesItem = requirePack("scripts.UI.FramesItem");
local ButtonUtil = requirePack("scripts.Utils.ButtonUtil"); 

local Toggle = class("Toggle",function() 
    return cc.Node:create();
end);
g_tConfigTable.CREATE_NEW(FramesItem);

function Toggle:ctor()
    self.clickCallBack_ = nil;
end

function Toggle:OnBtnClick()
    if self.clickCallBack_ ~= nil then 
        self.clickCallBack_(self);
    end
end

function Toggle:SetClickCallBack(cb)
    print("SetClickCallBackxxxxxxxxxxxxxxxxx");
    self.clickCallBack_ = cb;
end

function Toggle:Init(btnFilePath,toggleList)
    dump(btnFilePath);
    self.btn_ = ButtonUtil.Create(
        btnFilePath,
        btnFilePath,
        function()
            print("xxxxxxxxxxxxxxxxxxxxxxxx------------xxxxxxxxxxxxxxxxxxx");
            self:OnBtnClick();
        end);
    self:addChild(self.btn_,2);
    local contentSize = self.btn_:getContentSize();
    self:setContentSize(contentSize);

    self.frameAnim_ = FramesItem.new();
    self.frameAnim_:Init(toggleList);
    self:addChild(self.frameAnim_,1);
end

function Toggle:On()
    self.frameAnim_:Index(1);
end

function Toggle:Off()
    self.frameAnim_:Index(2);
end




return Toggle;