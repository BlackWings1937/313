
local SelectGroupBase = requirePack("scripts.UI.Base.SelectGroup.SelectGroupBase");
local SpriteUtil = requirePack("scripts.Utils.SpriteUtil"); 
local PathsUtil = requirePack("scripts.Utils.PathsUtil"); 

local CarouselGroup = class("CarouselGroup",function() 
    return SelectGroupBase.new();
end);

g_tConfigTable.CREATE_NEW(CarouselGroup);

function CarouselGroup:ctor()
    self.content_ = cc.Node:create();
    self:addChild(self.content_);
    self.listOfItems_ = {};

    self.offset_ = 0;
    self.spacing_ = 0;

    self.speed_ = 1;

    self.tagOfMoving_ = 1001;

    self.itemSize_ = cc.size(0,0);

    self.cbOfCreateItem_ = nil;
    self.cbOfUserClickItem_ = nil;

    --[[
    for i = 1,10,1 do 
        local sp = SpriteUtil.Create(PathsUtil.ImagePath("btnBack.png"));
        sp:setPositionX(170*i);
        self:addChild(sp,100000);
    end
    ]]--
end



function CarouselGroup:getSpeed()
    return self.speed_;
end



function CarouselGroup:startMove()
    local seq = cc.Sequence:create(
        cc.DelayTime:create(0.016),
        cc.CallFunc:create(function()
            self:update(); 
        end) );
    local req = cc.RepeatForever:create(seq);
    req:setTag(self.tagOfMoving_);
    self:runAction(req);
end

function CarouselGroup:stopMove()
    self:stopActionByTag(self.tagOfMoving_);
end

function CarouselGroup:update()
    local x,y = self.content_:getPosition();
    x = x - 0.016*self.speed_;
    self.content_:setPosition(cc.p(x,y));
    self:updateContentPos(cc.p(x,y));


end

function CarouselGroup:updateContentPos(pos)
    local headIndex = self:caculateHeadIndexByPos(pos);
    local itemCount = #self.listOfItems_;
    local index = headIndex%itemCount;
    if index == 0 then 
        index = itemCount;
    end

    
    local startIndex = index;
    for i = 1,itemCount,1 do 
        local item = self.listOfItems_[startIndex];
        local pos = self:caculatePosByIndex(headIndex + i - 1);
        item:setPosition(pos);

        startIndex = startIndex + 1;
        if startIndex > itemCount then 
            startIndex = 1;
        end
    end
end


function CarouselGroup:caculatePosByIndex(index)
    if index > 0 then 
        local v = self.offset_;
        v = v + self.itemSize_.width/2;

        local midCount = math.max(0,index-1);
        v = v + midCount*(self.itemSize_.width+self.spacing_) ;
        return cc.p(v,0);
    end

    print("Error index need > 0 index:"..index);
    return -1;
end

function CarouselGroup:caculateHeadIndexByPos(pos)
    local x = pos.x;
    local distance = math.abs(x);
    local offset = self.offset_;

    local itemWidth = self.spacing_ + self.itemSize_.width;
    local headIndex = math.floor(distance/itemWidth);

    headIndex = headIndex + 1;
    return headIndex;
end

function CarouselGroup:setItemsIsSelected(isSelected)
    local count = #self.listOfItems_;
    for i = 1,count,1 do 
        local item = self.listOfItems_[i];
        if isSelected then 
            item:Selected();
        else
            item:UnSelect();
        end
    end
end

--[[
    getposByIndex()
    getItemposFirstIndexwho
    getsortlist 
    getindexlist
    update every one pos
]]--
function CarouselGroup:OnItemClick(item)
    self:setItemsIsSelected(false);

    if item ~= nil then
        item:Selected();
        local count = #self.listOfItems_;
        for i = 1,count,1 do 
            local itemNow = self.listOfItems_[i];
            if itemNow:GetData().index == item:GetData().index then 
                itemNow:Selected();
            end
        end
    end

    
    
    if self.cbOfUserClickItem_ ~= nil then 
        self.cbOfUserClickItem_(item);
    end
end

function CarouselGroup:Update(list)
    self:stopMove();
    self.content_:setPositionX(0);
    local count = #self.listOfItems_;
    for i = count,1,-1 do 
        local item = self.listOfItems_[i];
        item:removeFromParent();
    end
    self.listOfItems_ = {};

    count = #list;
    for i = 1,count,1 do 
        local d = list[i];
        local item = self.cbOfCreateItem_(d);
        item:setGroup(self);
        self.content_:addChild(item);
        table.insert(self.listOfItems_,item);
        item:setGroup(self);
        item:UnSelect();
    end
    self:updateContentPos(cc.p(0,0));
end



function CarouselGroup:SetOffset(v)
    self.offset_ = v;
end

function CarouselGroup:SetSpacing(v)
    self.spacing_ = v;
end

function CarouselGroup:SetItemSize(v)
    self.itemSize_ = v;
end

function CarouselGroup:SetSpeed(v)
    self.speed_ = v;
end

function CarouselGroup:SetCreateItemCallBack(cb)
    self.cbOfCreateItem_ = cb;
end

function CarouselGroup:SetOnUserSelectItemCallBack(cb)
    self.cbOfUserClickItem_ = cb;
end

function CarouselGroup:Init()

end

return CarouselGroup;