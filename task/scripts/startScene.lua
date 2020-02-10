print("start sef lua begin!!");

require "baseScripts.config"
require "cocos.init"
require "baseScripts.global"
require "baseScripts.tableLib"

local mLuaFileExt1 = ".lua"
local mLuaFileExt2 = ".luac"
-- 创建H主场景界面
-- nFromModule :  从什么模块出来
-- nToModule: 要去往哪个模块

local t = {}

function t.createAppScene( nFromModule, nToModule, nMenuType, sBagId, sPackPath)
	--nFromModule, nToModule,m_sGoSourceScritpsPath,path,id 
	-- 根据情况
	local id = sBagId
	-- 包资源路径
	--local m_sGoSourceScritpsPath = sPackPath
	--print("createScene     sSdPath   === ",m_sGoSourceScritpsPath)
	local sSdPath = sPackPath--GET_REAL_PATH_ONLY(m_sGoSourceScritpsPath, PathGetRet_ALL_IN_SD); 
	print("===createScene     sSdPath   === ",sSdPath)
	g_tConfigTable.sTaskpath = sSdPath
	--
	local isLuaCreate = true
	local sFilePath = sSdPath..("appscripts/startScene"..mLuaFileExt2)
	if cc.FileUtils:getInstance():isFileExist(sFilePath) == false then
		local sFilePath = sSdPath..("appscripts/startScene"..mLuaFileExt1)
		if cc.FileUtils:getInstance():isFileExist(sFilePath) == false then
			isLuaCreate = false
		end
	end
	if not isLuaCreate then
		return nil
	end
	-- 
	print("进入到音频的世界欢迎你！")
	--
	local scene = cc.Scene:create()
	local ShowLayer = requirePack("appscripts.ShowLayer");
	local showLayer = ShowLayer.new(sSdPath);
	scene:addChild(showLayer);
	-- 返回创建中的场景
	return scene
end

--cc.exports.createAppScene = _createAppScene

print("start sef lua end!!");


return t