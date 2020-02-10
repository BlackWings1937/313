--[[
    这个UI对象 叫做 贴纸进度条
    意思就是用数个贴纸表示进度-[可以在示例项目中找到使用例子]-
]]--

local SpriteUtil = requirePack("scripts.Utils.SpriteUtil"); 

local FramesItem = requirePack("scripts.UI.FramesItem");

local StickerProcessBar = class("StickerProcessBar",function()
    return cc.Node:create(); 
end);
g_tConfigTable.CREATE_NEW(StickerProcessBar);

StickerProcessBar.EnumType = {
    ["HORIZONTAL"] = 1,       -- 纵向
    ["VERTICAL"] = 2,         -- 横向
}

function StickerProcessBar:ctor()
    self.spBg_ = nil;                             -- bar 背景图
    self.listOfItems_ = {};                       -- 贴纸列表
    self.offset_ = 0 ;                            -- 开始预留距离
    self.spacing_ = 0;                            -- 贴纸间的间距
    self.rearPos_ = cc.p(0,0);                    -- 目前贴纸的结尾点
end

function StickerProcessBar:caculatePosForHorizonMode(item)
    local contentSize = SpriteUtil.GetContentSize(item);
    local pos = cc.pAdd(self.rearPos_,cc.p(contentSize.width/2,0));
    self.rearPos_ = cc.pAdd(self.rearPos_,cc.p(contentSize.width+self.spacing_,0));
    dump(pos);
    return pos;
end

function StickerProcessBar:caculatePosForVerticalMode(item)
    local contentSize =SpriteUtil.GetContentSize(item); --item:getContentSize();
    local pos = cc.pAdd(self.rearPos_,cc.p(0,contentSize.height/2));
    self.rearPos_ = cc.pAdd(self.rearPos_,cc.p(0,contentSize.height+self.spacing_));
    return pos;
end

-- ----- 对外接口 -----

--[[
    初始化贴纸进度条
    参数:
    onImagePath:       亮起图片绝对路径 
    offImagePath:      关闭图片绝对路径
    bgImagePath:       背景图片绝对路径
    mode:              1: [横向模式] 2: [纵向模式]
    count:             贴纸数目(总共)
    offset:            排列开头预留位置
    spacing:           贴纸间隔距离
]]--
function StickerProcessBar:Init(
    onImagePath,
    offImagePath,
    bgImagePath,
    mode,
    count,
    offset,
    spacing)

    self.offset_  = offset;
    self.spacing_ = spacing;
    self.index_ = 1;

    self.spBg_ = SpriteUtil.Create(bgImagePath);
    self:addChild(self.spBg_);
    local contentSize = self.spBg_:getContentSize();


    if mode == StickerProcessBar.EnumType.HORIZONTAL then 
        self.rearPos_ = cc.p(self.offset_,0);
        self.spBg_:setAnchorPoint(cc.p(0,0.5));
        self.spBg_:setPosition(cc.p(0,-1));--debug
    else 
        self.rearPos_ = cc.p(0,self.offset_);
        self.spBg_:setAnchorPoint(cc.p(0.5,0));
        self.spBg_:setPosition(cc.p(0,0));
    end

    self:setContentSize(contentSize);
    local framesPath = {};
    table.insert( framesPath,onImagePath);
    table.insert( framesPath,offImagePath);
    for i = 1, count, 1 do 
        local item = FramesItem.new();
        item:Init(framesPath);
        self:addChild(item);
        table.insert( self.listOfItems_,item)
        
        if mode == StickerProcessBar.EnumType.HORIZONTAL then 
            item:setPosition(self:caculatePosForHorizonMode(item));
        else 
            item:setPosition(self:caculatePosForVerticalMode(item));
        end
    end

    self:UpdateProcessByIndex(2);
end

--[[
    撤销进度条
]]--
function StickerProcessBar:Dispose()
    self:removeAllChildren();
    self.spBg_ = nil;                             
    self.listOfItems_ = {};                       
    self.offset_ = 0 ;                            
    self.spacing_ = 0;                            
    self.rearPos_ = cc.p(0,0);                    
end

--[[
    更新进度条索引
]]--
function StickerProcessBar:UpdateProcessByIndex(index)
    local countOfItems = #self.listOfItems_;
    index = math.min(countOfItems,index);
    self.index_ = index;
    for i = 1,countOfItems,1 do
        if i<=index then 
            self.listOfItems_[i]:Index(1);
        else 
            self.listOfItems_[i]:Index(2);
        end
    end
end

function StickerProcessBar:GetIndex()
    return self.index_;
end




return StickerProcessBar;