
local SelectGroupBase = class("SelectGroupBase",function() 
    return cc.Node:create();
end);

g_tConfigTable.CREATE_NEW(SelectGroupBase);

function SelectGroupBase:OnItemClick(item)

end

return SelectGroupBase;