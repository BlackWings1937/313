-- region *.lua
-- Date
-- 此文件由[BabeLua]插件自动生成
requirePack("scripts.FrameWork.Global.GlobalFunctions");
local SceneBase = requirePack("scripts.FrameWork.Base.SceneBase");
local SpriteUtil = requirePack("scripts.FrameWork.Util.SpriteUtil");

local SceneTouches = class("SceneTouches", function(...)
    if ... == nil then 
        return cc.Node:create();
    end
    -- 创建sceneBase基类
    return SceneBase.new(...);
end )
g_tConfigTable.CREATE_NEW(SceneTouches);

function SceneTouches:ctor(...)
   self:initTouch();
end

function SceneTouches:setIsTouchOn(isOn)
    self.isTouchOn_ = isOn;
end

function SceneTouches:initTouch()
    self.isTouchOn_ = true;
    local listener = cc.EventListenerTouchOneByOne:create();
    listener:setSwallowTouches(false);
    listener:registerScriptHandler( function(t, v)
        if self.isTouchOn_ then 
            self:onTouchBegan(t, v);
        end
        return self.isTouchOn_;
    end , cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler( function(t, v)
      if self.isTouchOn_ then 
        self:onTouchMoved(t, v);
        end

    end , cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler( function(t, v)
    if self.isTouchOn_ then 
        self:onTouchEnded(t, v);
        end
    end , cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler( function(t, v)
    if self.isTouchOn_ then 
        self:onTouchCancle(t, v);
        end
    end , cc.Handler.EVENT_TOUCH_CANCELLED)
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:addEventListenerWithFixedPriority(listener, 1);
    self.listener_ = listener;
end


function SceneTouches:SetSwallowTouches(v)
    self.listener_:setSwallowTouches(v);
end

function SceneTouches:SetFixedPriority(index)--setPriority
    self:getEventDispatcher():setPriority(self.listener_,index);
end

function SceneTouches:disposeTouch()
    local eventDispatcher = self:getEventDispatcher();
    eventDispatcher:removeEventListener(self.listener_);
end

function SceneTouches:onExit()
    self:disposeTouch();
    SceneBase.onExit(self);
end


function SceneTouches:onTouchBegan(t, e)

end

function SceneTouches:onTouchMoved(t, e)

end

function SceneTouches:onTouchEnded(t, e)

end

function SceneTouches:onTouchCancle(t, e)

end

return SceneTouches

-- endregion
