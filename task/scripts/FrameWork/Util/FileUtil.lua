--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local FileUtil = {}

--[[
    读取task文件夹路径下的叫 fileName 的文件
    参数：
    fileName:文件名
    返回值:
    string: 文件内容
]]--
FileUtil.LoadFileContent = function (fileName)--*line *all
    local f = assert(io.open(fileName,'r'));
    local str = f:read("*all");
    f:close();
    return str;
end

--[[
    读取文件到文件指针
    参数:
    fileName:文件名
    返回:
    f：文件句柄
]]--
FileUtil.LoadFile = function (fileName)
    local f = assert(io.open(g_tConfigTable.sTaskpath..fileName,'r'));
    return f;
end

--[[
    撤销文件句柄
    参数:
    f:文件句柄
]]--
FileUtil.Dispose = function (f)
    if f~= nil then 
        f:close();
    end
end

--[[
    判断文件是否存在
    参数:
    path:文件路径
]]--
FileUtil.Exists = function(path)
    local file = io.open(path, "r")
    if file then
      io.close(file)
      return true
    end
    return false
end

--[[
    删除文件
    参数:
    path:文件路径
]]--
FileUtil.Delete = function(path)
    os.remove(path);
end

--[[
    创建并写入内容到文件
    参数:
    path:目标文件路径
    content:文件内容
]]--
FileUtil.Write = function(path, content)
    --[[

    ]]--
    local file = io.open(path,"w+")
    if file then
      if file:write(content) == nil then return false end
      io.close(file)
      return true
    else
      return false
    end
end


--[[
    创建目录
    参数:
    path:绝对路径
    返回创建结果
]]--
FileUtil.CreateDir = function(path)
    return cc.FileUtils:getInstance():createDirectory(path);
end


--[[
    查看路径是否存在
    参数:
    path:绝对路径
]]--
FileUtil.ExistsDir = function(path)
    if path == "" then 
        return false;
    end
    return cc.FileUtils:getInstance():isDirectoryExist(path);
end

--[[
    移除一个路径 "D:/bilibili2/"
    参数:
    path:绝对路径
]]--
FileUtil.RemoveDir = function(path)
    return  cc.FileUtils:getInstance():removeDirectory(path);
end

FileUtil.CopyTo = function(sourcefile,destinationfile)
	local read_file =""
	local write_file=""
	local temp_content ="";
	-- open read file stream
	read_file = io.open(sourcefile,"r")
	-- read all content
	temp_content = read_file:read("*a")
	-- open write file stream
	write_file = io.open(destinationfile,"w")
	-- write all content
	write_file:write(temp_content)
    -- close stream
	read_file:close()
	write_file:close()
end



--[[-- 暂时弃用
    读取文件中的一行(每读完一行下一次读取下一行)
    参数:
    f:文件句柄
    返回值
    string:content 文件中一行的内容

FileUtil.ReadLine = function (f)
    if f~= nil then 
        return f:read("*line");
    else 
        return "";
    end
end
]]--
return FileUtil;
--endregion
