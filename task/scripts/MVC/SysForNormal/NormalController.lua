local BaseController = requirePack("scripts.MVC.Base.BaseController");
local JsonScriptUtil = requirePack("scripts.Utils.JsonScriptUtil");
local ArmatureUtil = requirePack("scripts.Utils.ArmatureUtil"); 
local PathsUtil = requirePack("scripts.Utils.PathsUtil"); 
local SpriteUtil = requirePack("scripts.Utils.SpriteUtil"); 
local ButtonUtil = requirePack("scripts.Utils.ButtonUtil"); 
local JsonScriptUtil = requirePack("scripts.Utils.JsonScriptUtil");

local NormalController = class("NormalController",function() 
    return BaseController.new();
end);
g_tConfigTable.CREATE_NEW(NormalController);

function NormalController:ctor()
    -- 定义所有使用过的成员在这里..
    self.rootNode_ = nil;                               -- 屏幕根节点
end

--[[
    通过这个方法传入sys所有需要的外部参数
    初始化:
        View
        data
]]--
function NormalController:Start(rootNode,view,data)
    local size = VisibleRect:winSize();

    SpriteUtil.SetScaleAdapt(0.427);
    SpriteUtil.SetContentSize(cc.size(768,1024));
    PathsUtil.SetImagePath(g_tConfigTable.sTaskpath .. "bgimg/");

    JsonScriptUtil.SetJsonPath(
        g_tConfigTable.sTaskpath .. "json/",
        g_tConfigTable.sTaskpath .. "bgimg/",
        g_tConfigTable.sTaskpath .. "audio/"
    );

    self.rootNode_ = rootNode;

    self:setView(view.new());--
    self:setData(data.new());--
    
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
    self:getView():setPosition(cc.p(size.width/2,size.height/2));
end

--[[
    通过这个方法终止sys
    撤销:
        View
        data
]]--
function NormalController:Stop()
    self:getView():Dispose();
    self:getData():Dispose();
end

return NormalController;