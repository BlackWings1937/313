--[[
    连环画UI 
    给它一列表图片路径，它按列表顺序生成图片，初始显示第一张
    根据 Index 方法切换到你要让他显示的那张图片
    并且它会用拿到的最大的图片，设置自身contentsize大小
]]--

local SpriteUtil = requirePack("scripts.Utils.SpriteUtil"); 

local FramesItem = class("FramesItem",function() 
    return cc.Node:create();
end)
g_tConfigTable.CREATE_NEW(FramesItem);

function FramesItem:ctor()
    self.listOfFrames_ = {};
end

--[[
    初始化连环画 
    参数:
    list: 图片绝对路径列表
]]--
function FramesItem:Init(list)
    if list ~= nil then 
        local countOfList = #list;
        local contentSize = cc.size(0,0);
        for i = 1,countOfList,1 do 
            local sp = SpriteUtil.Create(list[i]);
            self:addChild(sp);
            sp:setVisible(false);
            local spContentSize = sp:getContentSize();

            if spContentSize.width > contentSize.width then 
                contentSize.width = spContentSize.width ;
            end
            if spContentSize.height > contentSize.height then 
                contentSize.height = spContentSize.height ;
            end
            table.insert(self.listOfFrames_,sp);
        end

        self:setContentSize(contentSize);
        self:Index(1);
    end
end

--[[
    撤销连环画，撤销后再次 init 可以复用这个item
]]--
function FramesItem:Dispose()
    self:removeAllChlidren();
    self.listOfFrames_ = {};
    self:setContentSize(cc.size(0,0));
end

--[[
    连环画显示对应索引
    参数:
    index:要显示的图片索引
]]--
function FramesItem:Index(index)
    local countOfList = #self.listOfFrames_ ;
    for i = countOfList,1,-1 do 
        self.listOfFrames_[i]:setVisible((i == index));
    end
end

function FramesItem:Count()
    return #self.listOfFrames_;
end


return FramesItem;