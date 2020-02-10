 
local SpriteUtil = requirePack("scripts.Utils.SpriteUtil"); 

local ButtonUtil = {};

ButtonUtil.Create = function(p1,p2,cb)
    local b = ccui.Button:create( 
        p1, 
        p2
    );
    b:addClickEventListener(function()
        if cb~= nil then 
            cb(b);
        end
    end);
    b:setScale(SpriteUtil.scaleAdapt_);
    return b;
end

return ButtonUtil;