
requirePack("baseScripts.homeUI.FrameWork.AnimationEngineLua.AnimationEngine");

local PathsUtil = requirePack("scripts.Utils.PathsUtil"); 
local SpriteUtil = requirePack("scripts.Utils.SpriteUtil"); 
local Controller = requirePack("scripts.MVC.SysForChrismas.ChrismasController");

local RootNode = class("RootNode",function() 
    local node = cc.Node:create();
    return node;
end);

g_tConfigTable.CREATE_NEW(RootNode);

function RootNode:registerNodeEvent()
    self:registerScriptHandler(function(e)
        if e == "enter" then 
            self:onEnter();
        elseif e == "exit" then 
            self:onExit();
        end
    end);
end

function RootNode:onEnter()
    g_tConfigTable.AnimationEngine.GetInstance();
    print(debug.traceback());
end

function RootNode:onExit()
    g_tConfigTable.AnimationEngine.GetInstance():Dispose();

    print(debug.traceback());
    if self.controller_ ~= nil then 
        self.controller_:Stop();
    end
end

function RootNode:ctor()
    self:registerNodeEvent();
    SpriteUtil.SetScaleAdapt(0.427);
    SpriteUtil.SetContentSize(cc.size(768,1024));
    PathsUtil.SetImagePath(g_tConfigTable.sTaskpath .. "image/");
    print("catch scale:"..ArmatureDataDeal:sharedDataDeal():getUIItemScale_1024_1920() );


    local winSize = cc.Director:getInstance():getWinSize()
    --self:setScale((1024-200)/1024);
    --self:setPosition(cc.p((winSize.width-768*((1024-200)/1024))*0.5,(winSize.height-1024*((1024-200)/1024))*0.5))

    --[[

    self.spBg_ = SpriteUtil.Create( PathsUtil.ImagePath("gui_bgm_icon_off.png"));
    self:addChild(self.spBg_,10000);
    self.spBg_:setPosition(cc.p(0,0));
]]--
    self.controller_ = Controller.new();
    self.controller_:Start(self);

end


return RootNode;