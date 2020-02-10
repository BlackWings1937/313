--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
g_tConfigTable.IsOpenDebug = true;
g_tConfigTable.Director = {};
g_tConfigTable.Director.winSize = VisibleRect:winSize();
g_tConfigTable.Director.ContentSize = cc.p(1080,1920);
g_tConfigTable.Director.midPos = cc.p(g_tConfigTable.Director.winSize.width/2,g_tConfigTable.Director.winSize.height/2);
g_tConfigTable.Director.actiontag_ = 0;
g_tConfigTable.Director.GetUnicActionTag = function ()
    g_tConfigTable.Director.actiontag_ = g_tConfigTable.Director.actiontag_ + 1;
    return g_tConfigTable.Director.actiontag_;
end
g_tConfigTable.CREATE_NEW = function (classObj)
    classObj.new = function (...)
        -- 创建实例
        local instance = {};

        -- 创建基类的基类
        if classObj.__create then 
            instance = classObj.__create(...) 
        end

        -- 复制基类键值对
        for k,v in pairs(classObj) do 
            instance[k] = v;
        end

        instance.class = classObj;
        instance:ctor(...);
        return instance;
    end
end

--endregion
