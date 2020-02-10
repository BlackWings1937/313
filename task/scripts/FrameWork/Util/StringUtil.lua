--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local StringUtil = {}

StringUtil.Split = function (str, split_char)
 local sub_str_tab = {};
    while (true) do
        local pos = string.find(str, split_char);
        if (not pos) then
            sub_str_tab[#sub_str_tab + 1] = str;
            break;
        end
        local sub_str = string.sub(str, 1, pos - 1);
        sub_str_tab[#sub_str_tab + 1] = sub_str;
        str = string.sub(str, pos + 1, #str);
    end

    return sub_str_tab;
end

StringUtil.PathFolderToExe = function (value)
	local path = ""
	for i=1,#value do
        --获取当前下标字符串
		local tmp = string.sub(value,i,i)
        --如果为'\\'则替换
		if tmp=='\\' then
			path = path..'/'
		else
			path = path..tmp
		end
	end
	return path
end

StringUtil.IsContent = function(strall,str)
    local result = string.find(strall,str);
    if result == nil then 
        return false;
    else 
        return true;
    end
end

StringUtil.GetN_Behind = function(str,index)
    local list =  StringUtil.Split(str,'_');
    local count = #list;
    if index <= count then 
        local name = ""
        local count = #list
        for i = index, count - 1, 1 do
            name = name .. list[i] .. "_"
        end
        name = name .. list[count]
        return name;
    end
    return "";
end

return StringUtil;
--endregion
