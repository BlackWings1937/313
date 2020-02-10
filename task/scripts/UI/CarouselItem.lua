
local SpriteUtil = requirePack("scripts.Utils.SpriteUtil");
local PathsUtil = requirePack("scripts.Utils.PathsUtil"); 
local ButtonUtil = requirePack("scripts.Utils.ButtonUtil"); 

local FramesItem = requirePack("scripts.UI.FramesItem");
local SelectItem = requirePack("scripts.UI.Base.SelectGroup.SelectItem");

local CarouselItem = class("CarouselItem",function()
    return SelectItem.new();
end);

g_tConfigTable.CREATE_NEW(CarouselItem);

function CarouselItem:ctor()
    self.fiOfSelect_ = nil; 
    self.spIcon_ = nil;
    self.spVipIcon_ = nil;
    self.spSelectPreIcon_ = nil;
end

function CarouselItem:Selected()
    if self.fiOfSelect_ ~= nil then 
        self.fiOfSelect_:Index(2);
    end
    if self.spSelectPreIcon_ ~= nil then 
        self.spSelectPreIcon_:setVisible(true);
    end
end

function CarouselItem:UnSelect()
    if self.fiOfSelect_ ~= nil then 
        self.fiOfSelect_:Index(1);
    end

    if self.spSelectPreIcon_ ~= nil then 
        self.spSelectPreIcon_:setVisible(false);
    end
end

function CarouselItem:Init(
    unselectedBgPath,
    selectedBgPath,
    iconPath,
    vipIconPath,
    selectPreIconPath)

    self.fiOfSelect_ = FramesItem.new();
    self.fiOfSelect_:Init({unselectedBgPath,selectedBgPath}); 
    self:addChild(self.fiOfSelect_);
    local cs = self.fiOfSelect_:getContentSize();
    self:setContentSize(cs);

    self.spIcon_ = ButtonUtil.Create( 
        iconPath, 
        iconPath,function(b)
            -- todo on user click next
            print("self.spIcon_");	
            self:getGroup():OnItemClick(self);
        end
    );
    self:addChild(self.spIcon_);
    local btnSize =SpriteUtil.GetContentSize( self.spIcon_) ;
    btnSize.width = btnSize.width*0.7;
    btnSize.height = btnSize.height*0.7;
    
    self.spVipIcon_ = SpriteUtil.Create(
        vipIconPath
    );
    self:addChild(self.spVipIcon_);
    self.spVipIcon_:setPosition(cc.p(-btnSize.width/2,btnSize.height/2));

    self.spSelectPreIcon_ = SpriteUtil.Create(
        selectPreIconPath
    );
    self:addChild(self.spSelectPreIcon_);
    self.spSelectPreIcon_:setPosition(cc.p(btnSize.width/2,-btnSize.height/2));

    
end

function CarouselItem:SetData(d)
    SelectItem.SetData(self,d);
    
    if self.spVipIcon_ ~= nil then 
        self.spVipIcon_:setVisible(d.VipItem);
    end
    
end


return CarouselItem;