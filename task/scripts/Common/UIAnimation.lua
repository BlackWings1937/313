----------------------------------------[Lua必备]----------------------------------------
local UIAnimation = class("UIAnimation", function(...)
	return cc.Node:create()
end
)
g_tConfigTable.CREATE_NEW(UIAnimation);
local Tag_Action = 1111

local function Log( ... )
print("[UIAnimation]--------------", ...)
end
----------------------------------------[结构必备]----------------------------------------

function UIAnimation:ctor(arm_name, size, delta_pos, audio_path)
	----------[可视化]----------
	self._arm_name = arm_name
	self._touch_arm = TouchArmature:create(self._arm_name, TOUCHARMATURE_NORMAL)
	self:addChild(self._touch_arm)
	--Log("create TouchArm", arm_name)
	self:setAnchorPoint(cc.p(0.5,0.5))
	if size then
		self:setContentSize(size)
	else
		size = cc.size(0,0)
	end
	-- Log("size")
	-- dump(size)
	-- self.delta_pos = delta_pos
	-- dump(cc.p(size.width * 0.5, size.height * 0.5))
	-- dump(cc.p(size.width * 0.5 + delta_pos.x, size.height * 0.5 + delta_pos.y))
	-- self._touch_arm:setPosition(cc.p(size.width * 0.5 + delta_pos.x, size.height * 0.5 + delta_pos.y))
	----------[数据]----------
	self._action_json = nil
	self._action_step = 0
	self._frame_time = 1 / 24--动画24帧每秒
	self._audio_path = audio_path

	self:setCascadeOpacityEnabled(true)
	self:setCascadeColorEnabled(true)
	
end

function UIAnimation:setFrameTime(time)
	self._frame_time = time
end
----------------------------------------[json行为]----------------------------------------
------------------------------[初始化]------------------------------
--属性初始化：一般使用一个专用的json来初始化属性设置【json.layers[i].frames】
function UIAnimation:init(json)
	self:setVisible(false)--暂时隐藏
	for k,v in pairs(json) do
		if nil ~= v.einfo then
			local info = v.einfo
			self:setLocalZOrder(v.z)
			--Log(self:getName(), "set At pos", info.x, 1024 - info.y)
			self:setPosition(cc.p(info.x, 1024 - info.y))
			--self:setPosition(cc.p(info.x + self.delta_pos.x, 1024 - info.y + self.delta_pos.y))
			self._touch_arm:setScale(info.sx, info.sy)--初始的只影响其自身
			self:setRotation(info.rot)
			self:setSkewX(info.skewX)
			self:setSkewY(info.skewY)
			return
		end
	end
end
--行为初始化：为了后续的剧情播放正确，需要初始到一个合适的状态【json.layers[i].frames】
function UIAnimation:setStatus(json)
	if nil == json[1].einfo then
		self:setVisible(false)
	end
	for k,v in pairs(json) do
		if nil ~= v.einfo then
			local info = v.einfo
			self:setLocalZOrder(v.z)
			--Log(self:getName(), "set At pos", info.x, 1024 - info.y)
			self:setPosition(cc.p(info.x, 1024 - info.y))
			--self:setPosition(cc.p(info.x + self.delta_pos.x, 1024 - info.y + self.delta_pos.y))
			self:setScale(info.sx / self._touch_arm:getScaleX(), info.sy / self._touch_arm:getScaleY())--相对缩放值
			self:setRotation(info.rot)
			self:setSkewX(info.skewX)
			self:setSkewY(info.skewY)
			return
		end
	end
end
------------------------------[运行]------------------------------
--开始播放行为【json.layers[i].frames】
function UIAnimation:startAction(json)
	-- if "npc_xbl" == self:getName() then
	-- 	Log("开始Action")
	-- end
	----------[0.数据初始化]----------
	self._action_json = json
	self._action_step = 1--（lua）从1开始
	----------[1.数据初始化]----------
	self:stopActionByTag(Tag_Action)
	self:action()
end

function UIAnimation:action()
	if self._action_step > #self._action_json then
		return 
	end
	local now_frame = self._action_json[self._action_step]

	local time = now_frame.dt * self._frame_time
	local action = nil
	----------[1.下一步]----------
	local callback = cc.CallFunc:create(function()
		self._action_step  = self._action_step + 1
		self:action()
	end)
	----------[1.瞬时属性]----------
	self:setLocalZOrder(now_frame.z)
	-----[动画资源（XML）]-----
	if now_frame.einfo and self._arm_name ~= now_frame.einfo.ename then--与上一次的动画不同
		-- if "npc_xbl" == self:getName() then
		-- 	Log("From", self._arm_name, "change To:", now_frame.einfo.ename)
		-- 	Log(self:getName(), "play Index", now_frame.einfo.eitem, "[", now_frame.dt, "]")
		-- end
		self._arm_name = now_frame.einfo.ename
		self._touch_arm:changeArmatureByIndx(now_frame.einfo.ename, 0)--changeArmatureByName
		local loop_flag = nil ~= now_frame.einfo.loop and LOOP_NO or LOOP_YES
		if LOOP_NO == loop_flag then
			Log(self:getName(), "play Anim", now_frame.einfo.eitem, "->LOOPNO [arm]")
		end
		self._touch_arm:playByMovName(now_frame.einfo.eitem, loop_flag, self._audio_path)--跟上播放，否则会出问题
	else
		-----[动画下标]-----
		if now_frame.einfo and now_frame.einfo.eitem then
			-- if "npc_xbl" == self:getName() then
			-- 	Log(self:getName(), "play Index", now_frame.einfo.eitem, "[", now_frame.dt, "]")
			-- end
			local loop_flag = nil ~= now_frame.einfo.loop and LOOP_NO or LOOP_YES
			if LOOP_NO == loop_flag then
				Log(self:getName(), "play Anim", now_frame.einfo.eitem, "->LOOPNO [index]")
			end
			self._touch_arm:playByMovName(now_frame.einfo.eitem, loop_flag, self._audio_path)--playByNameOnlyArmature
			--self._touch_arm:playByIndex(now_frame.einfo.eitem, LOOP_NO, self._audio_path)
			--now_frame.einfo.eitem > xbl:getMovementCount()
		end
	end
	
	----------[2.动画行为]----------
	if nil == now_frame.einfo then--空帧则作隐藏
		self:setVisible(false)
		----------[延时]----------
		action = cc.DelayTime:create(time)
	elseif self._action_step >= #self._action_json then--最后一个关键帧
		----------[延时]----------
		action = cc.DelayTime:create(time)
	else--后面还有关键帧
		self:setVisible(true)
		local now = now_frame.einfo
		local next = self._action_json[self._action_step + 1].einfo
		if nil == next then
			action = cc.DelayTime:create(time)
		else
			----------[位置]----------
			local delta_pos = {}
			delta_pos.x = next.x - now.x
			delta_pos.y = -(next.y - now.y)
			local move = cc.MoveBy:create(time, delta_pos)
			----------[缩放]----------
			--可能要考虑翻转UI
			local scale = cc.ScaleBy:create(time, next.sx / now.sx, next.sy / now.sy)
			----------[旋转、倾斜]----------
			local rotate = cc.RotateBy:create(time, next.rot - now.rot)
			local skew = cc.SkewTo:create(time, next.skewX, next.skewY)
			action = cc.Spawn:create(move, scale, rotate, skew)
		end
	end
	----------[播放效果]----------
	local sq_action = self:runAction(cc.Sequence:create(action, callback))
	sq_action:setTag(Tag_Action)
end
----------------------------------------[辅助方法]----------------------------------------
function UIAnimation:getTouchArm()
	return self._touch_arm
end
function UIAnimation:getUIRect()
	local x, y, w, h = 0, 0, 0, 0
	x, y, w, h = self._touch_arm:getBoundingBoxValue(x, y, w, h)
	w = w * self:getScaleX()
	h = h * self:getScaleY()

	x = x + self:getPositionX()
	y = y + self:getPositionY()
	return cc.rect(x,y,w,h)
end
function UIAnimation:changeBone(boneName, boneImg)
	self._touch_arm:ChangeOneSkin(boneName, boneImg)
end
--是否因为说话而改变嘴巴开张
function UIAnimation:mouse(is_speak)
	self._touch_arm:changeChildArmaturesToName("sp_mouse", is_speak and "speak_mouse" or "idle_mouse")
end

return UIAnimation