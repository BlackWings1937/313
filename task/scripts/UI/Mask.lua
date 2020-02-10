local ButtonUtil = requirePack("scripts.Utils.ButtonUtil"); 

local Mask = class("Mask",function() 
    return cc.Node:create();
end)
g_tConfigTable.CREATE_NEW(Mask);


function Mask:ctor()

end


function Mask:Init(filePath,color)
    self.btn_ =  ButtonUtil.Create(
        filePath, 
        filePath,
        function()
            print("block");
        end
    );
    self:addChild(self.btn_);
    self.btn_:setScale(10000);
    
    local layer = cc.LayerColor:create(color ,10000,10000);--ccc4(100,0,0,100)
    self:addChild(layer);
end

return Mask;