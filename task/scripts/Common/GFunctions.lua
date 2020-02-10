--功能：仅本文档使用的Log
local Log = function ( ... )
	CC_GameLog("[g_tConfigTable]--------------", ...)
end

g_tConfigTable.winSize = VisibleRect:winSize()

----------------------------------------[数值]----------------------------------------
g_tConfigTable.getValueWithDefault = function(val, default_val)
	if nil ~= val then
		return val
	else
		return default_val
	end
end
--取一个整数的每一位：1代表最低位（个位）
g_tConfigTable.getEveryDigit = function(num)
	num = math.round(num)--先转为整数
	local r_table = {}
	local i = 1
	repeat
		r_table[i] = num % 10
		i = i + 1
		num = num / 10
	until num < 1--0.x则代表已经取完了
	return r_table
end
----------------------------------------[UI]----------------------------------------
g_tConfigTable.ScaleToSize = function(node, aim_size)
	local size = node:getContentSize()
	node:setScaleX(aim_size.width / size.width)
	node:setScaleY(aim_size.height / size.height)
end
--x_type和y_type使用顶部定义的常量Pos_X_xxx和Pos_X_yyy
	--[[
		@is_change_anchor：是否修改anchor为参数中的anchor，
			如果是则修改，否则依旧使用默认的(0.5,0.5)为锚点
		@
	]]--
--
g_tConfigTable.setUIPos = function(parent, ui_node, ui_s, ui_x, ui_y, x_type, y_type, anchor_x, anchor_y, is_change_anchor, is_touch_arm)
	local width = g_tConfigTable.winSize.width
	local height = g_tConfigTable.winSize.height
	local x = 0
	local y = 0
	if parent then
		local size = parent:getContentSize()
		width = size.width
		height = size.height
		--toucharm里面比较特殊，实际锚点需要根据getBoudingBox计算，getAnchorPoint的是并不准确的，默认为0,0
		if is_touch_arm then
			local x1, y1, w1, h1 = 0, 0, 0, 0
			x1, y1, w1, h1 = parent:getBoundingBoxValue(x1, y1, w1, h1)
			local xp, yp = parent:getPosition()
			local anchor_x = (xp - x1) / w1--TouchArm的“实际”anchor
			local anchor_y = (yp - y1) / h1
			--Log("[parent_anchor]：", anchor_x, anchor_y)
			x = -width * anchor_x--需要去掉这个“实际”anchor的偏移
			y = -height * anchor_y--并且要用ContentSize()的尺寸，而不是boudingbox的w、h
		end
	end
	local half_w = width / 2
	local half_h = height / 2
	----------[数据初始化]----------
	local ui_s_x, ui_s_y = ui_s, ui_s
	if nil == ui_s then
		ui_s_x,ui_s_y = ui_node:getScaleX(), ui_node:getScaleY()
	end
	if nil == ui_x then ui_x = 0 end
	if nil == ui_y then ui_y = 0 end
	if nil == x_type then x_type = 0 end
	if nil == y_type then y_type = 0 end
	if nil == anchor_x then anchor_x = 0.5 end
	if nil == anchor_y then anchor_y = 0.5 end
	if nil == is_change_anchor then is_change_anchor = false end
	----------[布局]----------
	x = x + ui_x + half_w * x_type
	y = y + ui_y + half_h * y_type
	--print("before_Pos", x,y)
	if is_change_anchor then
		ui_node:setAnchorPoint(cc.p(anchor_x, anchor_y))
	else
		local size = ui_node:getContentSize()
		local anchor = ui_node:getAnchorPoint()
		x = x - size.width * (anchor_x - anchor.x) * ui_s_x
		y = y - size.height * (anchor_y - anchor.y) * ui_s_y
	end
	--print("after_Pos", x,y)
	ui_node:setScaleX(ui_s_x)--CFG_SCALE(ui_s))
	ui_node:setScaleY(ui_s_y)--CFG_SCALE(ui_s))
	ui_node:setPosition(cc.p(x, y))
	if nil == ui_node:getParent() and parent then
		parent:addChild(ui_node)
	end
end
--暂未完成
g_tConfigTable.getUIPosOrigin = function(ui_node)
	local x,y = p:getPostion()
	local size = p:getContentSize()
	size.width = size.width * p:getScaleX()
	size.height = size.height * p:getScaleY()
end
--暂未验证
g_tConfigTable.getUIPos = function(parent, ui_node, pos)
	if nil == pos then pos = cc.p(ui_node:getPosition()) end
	local p = ui_node:getParent()
	while p ~= parent do
		local x,y = p:getPostion()
	end
end

--
	--[[
	参数：
	]]--
--
g_tConfigTable.DrawRoundedRectangle = function(draw_node, width, height, radius_table, color)
	local half_w = width * 0.5
	local half_h = height * 0.5
	local pos = {}
	local c4 = {{-1,1}, {1,1}, {1,-1},{-1,-1}}--左上、右上、右下、左下
	for k,v in pairs(c4) do
		pos[k] = cc.p(half_w * (1 + v[1]) + radius_table[k] * (-v[1]), half_h * (1 + v[2]) + radius_table[k] * (-v[2]))
		--绘制区域1~4：绘制圆角
		if 0 ~= radius_table[k] then
			if color.a ~= 1.0 then
				--绘制圆
				local circle = cc.DrawNode:create()
				circle:drawSolidCircle(cc.p(0,0), radius_table[k], 3.14, 500, 1, 1, color)
				--circle:drawDot(cc.p(0,0), radius_table[k], color)
				circle:setPosition(pos[k])
				--绘制1/4的矩形区域
				local stencil = cc.DrawNode:create()
				stencil:drawSolidRect(cc.p(0,0), cc.p(radius_table[k]* (-v[1]), radius_table[k]* (-v[2])), cc.c4f(1,1,1,1))--半圆区域
				--裁切
				local clip = cc.ClippingNode:create(stencil)
				clip:addChild(circle)
				draw_node:addChild(clip, -1)
			else
				--全不透明
				draw_node:drawSolidCircle(pos[k], radius_table[k], 3.14, 500, 1, 1, color)
				--draw_node:drawDot(pos[k], radius_table[k], color)
			end
		end
	end
	--绘制区域5：中心矩形
	local left_r =  radius_table[1] >= radius_table[4] and radius_table[1] or radius_table[4]
	local right_r = radius_table[2] >= radius_table[3] and radius_table[2] or radius_table[3]
	draw_node:drawSolidRect(cc.p(left_r, 0), cc.p(width - right_r, height), color)--中心一个竖着的底
	--绘制区域6：左侧、右侧
	if 0 ~= left_r then--左侧右侧只要有圆角就要绘制6区域，否则都含在5区域
		draw_node:drawSolidRect(cc.p(0, radius_table[4]), cc.p(left_r, height - radius_table[1]), color)
		--绘制区域7：左侧
		if radius_table[1] >= radius_table[4] then
			--下面的圆角比较小：且存在圆角，而非直角
			if 0 ~= radius_table[4] then
				draw_node:drawSolidRect(cc.p(radius_table[4],0), cc.p(left_r, radius_table[4]), color)
			end
		else
			--上面的圆角比较小
			if 0 ~= radius_table[1] then
				draw_node:drawSolidRect(cc.p(radius_table[1], height-radius_table[1]), cc.p(left_r, height), color)
			end
		end
	end
	if 0 ~= right_r then
		draw_node:drawSolidRect(cc.p(width - right_r, radius_table[3]), cc.p(width, height - radius_table[2]), color)
		--绘制区域7：右侧
		if radius_table[2] >= radius_table[3] then
			--下面的圆角比较小：且存在圆角，而非直角
			if 0 ~= radius_table[3] then
				draw_node:drawSolidRect(cc.p(width - right_r, 0), cc.p(width - radius_table[3], radius_table[3]), color)
			end
		else
			--上面的圆角比较小
			if 0 ~= radius_table[2] then
				draw_node:drawSolidRect(cc.p(width - right_r, height-radius_table[2]), cc.p(width - radius_table[2], height), color)
			end
		end
	end
end
g_tConfigTable.GetDrawRoundedRectangle = function(width, height, radius_table, color)
	local draw_node = cc.DrawNode:create()
	draw_node:setContentSize(width, height)
	g_tConfigTable.DrawRoundedRectangle(draw_node, width, height, radius_table, color)
	return draw_node
end
----------------------------------------[字符串]----------------------------------------
--str原字符串、p是分隔符
g_tConfigTable.stringSplit = function(str, p)
    local rt = {}
    string.gsub(
        str,
        "[^" .. p .. "]+",
        function(w)
            table.insert(rt, w)
        end
    )
    return rt
end
----------------------------------------[触摸区域]----------------------------------------
--功能：（静态方法）获得一个对象的矩形检测范围
	--参数：
	--@arm_node:从该对象获取其外圈矩形，该对象是一个TouchArm
	--@scale:缩放这个矩形大小，（向中心放大缩小），默认为1
	--返回值：
	--@rect：cc.rect()
--
g_tConfigTable.GetArmRect = function(arm_node)
	local x, y, w, h = 0, 0, 0, 0
	x, y, w, h = arm_node:getBoundingBoxValue(x, y, w, h)
	return cc.rect(x , y , w, h)
end

g_tConfigTable.GetArmRectWithScale = function(arm_node, scale)
	local x, y, w, h = 0, 0, 0, 0
	x, y, w, h = arm_node:getBoundingBoxValue(x, y, w, h)
	if nil == scale then
		scale = 1
	end
	return cc.rect(x + 0.5*(1-scale)*w, y + 0.5*(1-scale)*h, w*scale, h*scale)
end

g_tConfigTable.GetPointAtRect = function(rect, anchor)
	local pos = {}
	pos.x = rect.x + anchor.x * rect.width
	pos.y = rect.y + anchor.y * rect.height
	return pos
end
--功能：检测是否点中某个对象
	--参数：
	--	touch_pos：点击的坐标，一般用如下方式从Touch方法返回的touch转换而来。也可以不用转换
	--	local touch_pos = self.stageNode:convertTouchToNodeSpace(touch)
--
g_tConfigTable.IsTouchOnArm = function(touch_pos, arm_node)
	local rect = g_tConfigTable.GetArmRect(arm_node)
	return cc.rectContainsPoint(rect, touch_pos)
end
g_tConfigTable.IsTouchOnSprite = function(touch_pos, sprite_node)
	local rect = sprite_node:getBoundingBox()
	return cc.rectContainsPoint(rect, touch_pos)
end
----------------------------------------[动画播放]----------------------------------------
----------------------------------------[Debug]----------------------------------------
g_tConfigTable.DebugNodeMsg = function(node)
	Log("----------------")
	Log("position:\t[x,y]:", node:getPositionX(), node:getPositionY())
	local anchor = node:getAnchorPoint()
	Log("anchor:\t[x,y]", anchor.x, anchor.y)
	local size = node:getContentSize()
	Log("size:\t[w,h]", size.width, size.height)
	Log("scale:\t[x,y]", node:getScaleX(), node:getScaleY())
	Log("----------------")
	Log("is_visible:\t", node:isVisible())
	Log("----------------")
end

----------------------------------------[随机]----------------------------------------
g_tConfigTable.ResetRandomSeed = function()
	local seed = os.time()
	math.randomseed(seed)
end
    --功能：（静态方法）从数组A中剔除数组B后的数组中获得一个随机值
	
	--参数：r_table要与witout相同结构（子对象进行比较）
	--  @r_table:从这个table里面选取一个随机值（取value）
	--  @without:r_table应该先剔除这个表再进行随机。
		--该值可以为nil，可以为表结构（without)
	--  @return_num:要获得多少个随机值，至少1个，当不足则返回空表，方便检查错误
		--当仅返回一个随机值的时候，以r_table中它们的【基本单位】为准（即return r_table[i]）
			--当r_table为{1,2,3}，则返回number
			--当r_table为{{1,2},{2,3},{3,5}},则返回table
	--返回值:
	--  @table:返回的随机值（table里面的value部分，不含key部分）
	--  @index:返回的随机值在r_table里面的序号（从1开始）
--
g_tConfigTable.GetRandomValueFromTable = function(r_table, without, return_num)
	--1.变量声明：获得一个真正的随机内容
	local random_table = {}--用于存储剔除without之后的随机抽取的内容表
	local random_index = {}--用于存储它们之间的序号
	--2.1对without_table进行修正
	if nil == without then
		without = {} --空表
	end
	--2.2对return_num进行修正
	if nil == return_num or return_num < 1 then
		return_num = 1
	end
	--3.剔除不参与的数据
	local idx = 1
	for k,v in pairs(r_table) do
		local flag = true --标记是否保存（false代表这个要被剔除）
		for k1,v1 in pairs(without) do
			if "table" ~= type(v) then
				if v == v1 then
					flag = false -- 重复的就不要了
					break
				end
			else
				--table类型则要继续进行判断（v和v1是同级的）
				if g_tConfigTable.TableCompare(v, v1) then
					flag = false
					break
				end
			end
		end
		if flag then
			local insert_idx = #random_table + 1--插入的序号
			random_index[insert_idx] = idx--存入它们在r_table中的编号
			random_table[insert_idx] = v--存入值
		end
		idx = idx + 1
	end
	--4.获取随机值并返回
	g_tConfigTable.ResetRandomSeed()
	if return_num > #random_table then
		print("getRandomValueFromTable:You need too much return random_value")
		return {}, 0 --完全无法满足要求的时候，则返回空表
	elseif 1 == return_num then
		local idx = math.random(1,#random_table)
		return random_table[idx], idx
	else
		local return_table = {}
		local return_index = {}
		for i = 1, return_num do
			local idx = math.random(1,#random_table)
			return_table[i] = random_table[idx]
			return_index[i] = random_index[idx]
			--Log("    random_value is :", return_table[i])
			table.remove(random_table, idx)
			table.remove(random_index, idx)
		end
		return return_table, return_index
	end
end

g_tConfigTable.GetRandomValueFromTableWithPercentage = function(r_table, p_tabel)
	--检测概率
	local total = 0
	local total_p_tabel = clone(p_tabel)
	for k,v in pairs(p_tabel) do
		total = total + v
		total_p_tabel[k] = total
	end
	if total ~= 100 then 
		Log("GetRandomValueFromTableWithPercentage wrong : total value = ", total)
		dump(p_tabel)
		return nil
	end
	--获取随机值
	local random = math.random(1,100)
	for k,v in pairs(total_p_tabel) do
		if random <= v then
			return r_table[k], k
		end
	end
	Log("random val is:", random)
	dump(total_p_tabel)
end
----------------------------------------[IO]----------------------------------------
--local preScore = cc.UserDefault:getInstance():getIntegerForKey("XIYOUJI_3_Bridge_SCORE", -1)
--cc.UserDefault:getInstance():setIntegerForKey("XIYOUJI_3_Bridge_SCORE", score)
g_tConfigTable.readFile = function(file_path)
	local file, err = io.open(file_path, "r")
	if file and not err then
		local content = file:read("*a")
		io.close(file)
		return content
	else
		print(err)
		return nil
	end
end
g_tConfigTable.WriteFile = function(file_path, content)
	local file, err = io.open(file_path, "w+")--"w+"模式，确保覆盖原文件或者能够创建文件
	if file and not err then
		file:write(content)
		file:flush()
		io.close(file)
		return true
	else
		print(err)
		return false
	end
end
--功能：（静态方法）获取在本地可读写位置的文件路径
	--参数：
	--  @file_name：文件名称（参数应该包含例如".json"的后缀）
	--返回值：
	--  @string：该文件对应的全路径
--
g_tConfigTable.GetLocalWirtablePath = function(file_name)
	local save_path = UInfoUtil:getInstance():getCurUserSavePath() --本地文件存储路径
	return save_path..file_name --对应文件的存储路径
end
--功能：（静态方法）从json文件路径读取json文件，并以table的形式返回
	--参数：
	--  @jsonfile_path：json文件路径，如果文件不存在那就需要default_initfile_callback
	--  @default_initfile_callback:初始化文件的一个回调方式，该callback返回一个表
	--返回值：
	--  @json_table：从json文件读取到的table
--
g_tConfigTable.loadJson = function(jsonfile_path, default_initfile_callback)
	--1.基本变量声明
	local json_table = {} --文件中的数据将读取到这个局部table里面
	--2.读取json文件
	if jsonfile_path and io.exists(jsonfile_path) then --文件存在
		json_table = readJsonFromFile(jsonfile_path) --文件存在则读取对应的json文件
	else
		if nil == default_initfile_callback then
			json_table = {} --默认初始化为空
		else
			json_table = default_initfile_callback() --获得默认的初始化方式
		end
	end
	--3.返回json解析出的table
	return json_table
end
--功能：（静态方法）将table写入json文件并保存在本地，如果文件不存在则会创建
	--参数：
	--  @jsonfile_path：文件路径
	--  @json_table:一个Lua的table对象，将该对象写入文件
	--返回值：
	--  @无返回值
--
g_tConfigTable.saveJson = function(jsonfile_path, json_table)
	--1.基本变量声明
	local save_msg = json.encode(json_table)
	--Log("save json:", save_msg) -- debug
	--2.写入文件
	g_tConfigTable.WriteFile(jsonfile_path, save_msg)
end
----------------------------------------[其他功能]----------------------------------------
--[[
功能：table是否相同的比较
参数:@table_a,table_b:比较的两个table
返回值：@true:两者相同
备注：代码还可以继续优化
]]--
g_tConfigTable.TableCompare = function(table_a, table_b)
	--1.从数量上判断两个表是否可能不同
	local num_a = 0
	local num_b = 0
	for k,v in pairs(table_a) do num_a = num_a + 1 end
	for k,v in pairs(table_b) do num_b = num_b + 1 end
	if num_a ~= num_b then
		return false
	end
	--2.个数相同则进行逐个元素判断
	local type_a, type_b
	for k,v in pairs(table_a) do
		type_a = type(v)--v就是table_a[k]
		type_b = type(table_b[k])
		if type_a == type_b then
			if "table" == type_b then --两者都是table则递归
				if false == g_tConfigTable.TableCompare(v, table_b[k]) then
					return false--不同
				end
			else--都不是table则直接比较
				if nil == table_b[k] or v ~= table_b[k] then
					return false--不同
				end
			end
		else
			return false --既然不同类型则必然不同
		end
	end
	return true
end

--功能：table是否相同的比较
	--参数:
	-- @table_a,table_b:比较的两个table
	--返回值：
	--  @true:两者相同
	--备注：代码还可以继续优化
--
g_tConfigTable.IsSameDay = function(TimeStamp_a, TimeStamp_b)
	if TimeStamp_a.year == TimeStamp_b.year
		and TimeStamp_a.month == TimeStamp_b.month
		and TimeStamp_a.day == TimeStamp_b.day then
		return true -- 年月日相同那就是同一天
	else
		return false
	end
end


--功能:【过程】线段是否相交
	--肖国华 2018年12月3日
	--参数:
	--  @pt1,pt2:线段1的两个端点
	--  @pt3,pt4:线段2的两个端点
	--返回值:
	--  @true线段1、2相交，false线段1、2不相交
	--备注:为了避免修改cocos源代码从而复制并修改的代码
--
g_tConfigTable.isSegmentIntersect = function(pt1,pt2,pt3,pt4)
	local s, t, ret = 0,0,false
	ret, s, t = cc.pIsLineIntersect(pt1, pt2, pt3, pt4,s,t)
	if ret and  s >= 0.0 and s <= 1.0 and t >= 0.0 and t <= 1.0 then --源代码最后t <= 0.0错误
		return true
	end
	return false
end
--功能:【过程】线段是否与矩形相交
	--肖国华 2018年12月3日
	--参数:
	--  @line_p1,line_p2:线段的两个端点
	--  @rect:矩形（必须是cc.rect)
	--返回值:
	--  @number:与矩形的4条线段中的几条相交。
		--0:完全不相交
		--1:线段一头在矩形外，一头在矩形内
		--2:线段两头都在矩形外
--
g_tConfigTable.lineIntersectRect = function(line_p1,line_p2,rect)
	local p = {}
	p[1] = cc.p(rect.x,rect.y)
	p[2] = cc.p(rect.x + rect.width, rect.y)
	p[3] = cc.p(rect.x + rect.width, rect.y + rect.height)
	p[4] = cc.p(rect.x, rect.y + rect.height)
	local cut_num = 0
	for i = 1, 4 do
		if self:pIsSegmentIntersect(line_p1, line_p2, p[i], p[i%4 + 1]) then--1\2\3\4和2\3\4\1
			cut_num = cut_num + 1
		end
	end
	return cut_num
end