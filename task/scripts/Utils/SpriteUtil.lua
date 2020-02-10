
local SpriteUtil = {}

SpriteUtil.scaleAdapt_ = 1;

SpriteUtil.SetScaleAdapt = function(v)
    SpriteUtil.scaleAdapt_ = v;
end

SpriteUtil.Create = function(p)
    local sp = cc.Sprite:create(p);
    sp:setScale(SpriteUtil.scaleAdapt_);
    return sp;
end

SpriteUtil.GetContentSize = function(sp)
    local scale = SpriteUtil.scaleAdapt_;
    local contentSize = sp:getContentSize();
    return cc.size(contentSize.width*scale,contentSize.height*scale);
end

SpriteUtil.contentSize_ = cc.p(0,0)
SpriteUtil.SetContentSize = function(v)
    SpriteUtil.contentSize_ = v;
end

SpriteUtil.ToCocosPoint = function(x,y) 
    local v = cc.p(x,y);
    v.y = SpriteUtil.contentSize_.height - v.y;
    return v;
end

SpriteUtil.ToFlashPoint = function(x,y)
    local v = cc.p(x,y);
    v.y = SpriteUtil.contentSize_.height - v.y;
    dump(SpriteUtil.contentSize_)
    return v;
end

SpriteUtil.SetPosForLanHu = function(sp,pos) 
    sp:setPosition(cc.p(pos.x + sp:getContentSize().width*0.5*CFG_SCALE(0.427),
    1024 - (pos.y + sp:getContentSize().height*0.5*CFG_SCALE(0.427) )));
end

SpriteUtil.SetLhPos = function(sp,pos) 
    sp:setPosition(cc.p(pos.x + sp:getContentSize().width*0.5*CFG_SCALE(0.427),1024 - ( pos.y +sp:getContentSize().height*0.5*CFG_SCALE(0.427)))) 
end


return SpriteUtil;