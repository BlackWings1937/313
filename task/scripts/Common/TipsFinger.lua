--[[
create中的彩色版本？bwl_kong_yachi
原：TipsFinger
]]--
----------------------------------------[Lua必备]----------------------------------------
local TipsFinger = class("TipsFinger", function(...)
		return TouchArmature:create("point_all", TOUCHARMATURE_NORMAL, "")
	end
)
TipsFinger.Tip_Wave = 0
TipsFinger.Tip_Finger = 1
g_tConfigTable.CREATE_NEW(TipsFinger);
local function Log( ... )
	print("[TipsFinger]--------------", ...)
end
----------------------------------------[结构必备]----------------------------------------
--
	--参数：
	--	@parent：self.topNode
--
function TipsFinger:ctor(parent, scale, z_order)
	self.idx_click = 1--点击时的效果（与self.idx_clickWave或self.idx_clickFinger）
	-- 数据
	--self.idx_clickWave = 0
	--self.idx_clickFinger = 1
	self.idx_clickDragStart = 2
	self.idx_clickDragMove = 3
	self.idx_clickDragEnd = 4

	
	self.finger_speed = 128.0
	self.drag_time	= 1.0	--手指移动这段路程的时长

	self.delay_time	= 0.0	--[0,∞]延时启动的时长
	self.gap_time	= 5.0	--(0,∞]提示间隔的时长（不含动画本身的时间，所以尽量确保比动画时长长）
	
	self.pos_start = cc.p(0,0)--起点（对于点击事件就是只有这个点）
	self.finger_tag = 111
	self.repeat_tip_callback = nil--提示的回调（手指一般没有）
	--仅用于拖动：避免重复传入数值
	self.pos_end = cc.p(0,0)
	self.wait_time = 0.5--拖动到目的以后停顿的时间
	--仅用于连续的滑动动作：如圈圈、[A、B、C、D]
	self.pos_list = {}
	--后续如果需要拓展在这里拓展就好了
	

	-- 可视化
	if nil == z_order then z_order = 200000 end
	self:setVisible(false)
	self:setScale(CFG_SCALE(scale))--CFG_SCALE
	self:setLocalZOrder(z_order)
	parent:addChild(self)
end
----------------------------------------[辅助函数]----------------------------------------
--
	--[[
		TipsFinger.Tip_Wave或TipsFinger.Tip_Finger
	]]--
--
function TipsFinger:setFingerClickType(click_type)
	self.idx_click = click_type
end
--初始化通用数据
function TipsFinger:initData(pos, delay_time, gap_time, repeat_tip_callback)
	if nil ~= delay_time then self.delay_time = delay_time end
	if nil ~= gap_time then self.gap_time = gap_time end
	if nil ~= pos then self.pos_start = pos end
	if nil ~= repeat_tip_callback then self.repeat_tip_callback = repeat_tip_callback end
end
--功能：根据是否需要延迟创建对应的Action
function TipsFinger:getActionByDelayTime(action)
	if self.delay_time == 0 then
		self:setVisible(true)
		return action
	else
		--Sequence中不能包含RepeatForever，所以需要重新用一个CallFunc包装一次传过来的action
		action:retain()--如果没有立刻使用，需要临时存储，则需要使用一次retain以及在使用后使用release()确保对象不会被删除
		return cc.Sequence:create(
			cc.DelayTime:create(self.delay_time),
			cc.CallFunc:create(function()
				self:setVisible(true)
				self:runAction(action)
				action:release()
				action:setTag(self.finger_tag)
			end))
	end
end
----------------------------------------[功能函数]----------------------------------------
--点击提示
	--参数：
	--	@pos：必然已经用cc.p包装了，否则返回的是x,y占用了两个参数
	--	@delay_time、repeat_tip_callback：一般并不会设置
--
function TipsFinger:clickTips(gap_time, pos, delay_time, repeat_tip_callback)
	-- 1.初始化数据
	self:initData(pos, delay_time, gap_time, repeat_tip_callback)
	self:setPosition(self.pos_start)
	Log("clickTips[self, delay_time, gap_time]", tostring(self), self.gap_time, self.delay_time, "at pos", self.pos_start.x, self.pos_start.y)
	-- 2.动画效果
	local action = self:runAction(self:getActionByDelayTime(
		cc.RepeatForever:create(cc.Sequence:create(
			cc.CallFunc:create(function()
				self:playByIndex(self.idx_click, LOOP_NO) --播放一次点击
				if self.repeat_tip_callback then
					self.repeat_tip_callback()
				end
			end),
			cc.DelayTime:create(self.gap_time)
		))))
	action:setTag(self.finger_tag)
end
--拖动提示
	--参数：
	--	@pos：必然已经用cc.p包装了，否则返回的是x,y占用了两个参数
	--	@move_time：强制设置移动的时长（与移动速度无关），调用时可能会用nil对前面的进行占位
--
function TipsFinger:dragTips(gap_time, pos_start, pos_end, delay_time, move_time, repeat_tip_callback)
	-- 1.初始化数据
	self:initData(pos_start, delay_time, gap_time, repeat_tip_callback)
	if nil ~= pos_end then self.pos_end = pos_end end
	if nil ~= gap_time then--此处是为了方便后续启动的时候能够不传入（所有）参数实现“重播”的效果
		if nil ~= move_time then 
			self.drag_time = move_time
		else
			self.drag_time = cc.pGetDistance(self.pos_start, self.pos_end) / self.finger_speed
		end
	end
	Log("dragTips[self, delay_time, gap_time]", tostring(self), "at pos", self.gap_time, self.delay_time)
	-- 2.动画效果
	local action = self:runAction(self:getActionByDelayTime(
		cc.RepeatForever:create(
			cc.Sequence:create(
				cc.Spawn:create(--设置位置、播放动画、淡入
					cc.Place:create(self.pos_start),
					cc.CallFunc:create(function() self:playByIndex(2, LOOP_NO) end),
					cc.FadeIn:create(0.5)),
				cc.MoveTo:create(self.drag_time, self.pos_end),--移动
				cc.DelayTime:create(self.wait_time),--停顿时间
				cc.FadeOut:create(0.5),--淡出
				cc.DelayTime:create(self.gap_time),--时间间隔
				cc.CallFunc:create(function() --回调
					if self.repeat_tip_callback then 
						self.repeat_tip_callback()
					end
				end)
		))))
	action:setTag(self.finger_tag)
end
--多点挪动
	--参数：
	--	@pos_list：已用cc.p包装的pos的“数组”
	--暂未实现
--
function TipsFinger:moveTips(gap_time, pos_list, delay_time, move_time, repeat_tip_callback)
	-- 1.初始化数据
	self:initData(pos, delay_time, gap_time, repeat_tip_callback)
	if nil ~= pos_list then self.pos_list = pos_list end
	if nil ~= gap_time then--此处是为了方便后续启动的时候能够不传入（所有）参数实现“重播”的效果
		if nil ~= move_time then 
			self.drag_time = move_time
		else
			self.drag_time = cc.pGetDistance(self.pos_start, self.pos_end) / self.finger_speed
		end
	end
	Log("moveTips", tostring(self))
	-- 2.动画效果
	local action = self:runAction(self:getActionByDelayTime(
		cc.RepeatForever:create(
			cc.Sequence:create(
				cc.Spawn:create(--设置位置、播放动画、淡入
					cc.Place:create(self.pos_start),
					cc.CallFunc:create(function() self:playByIndex(2, LOOP_NO) end),
					cc.FadeIn:create(0.5)),
				cc.MoveTo:create(self.drag_time, self.pos_end),--移动
				cc.DelayTime:create(self.wait_time),--停顿时间
				cc.FadeOut:create(0.5),--淡出
				cc.DelayTime:create(self.gap_time),--时间间隔
				cc.CallFunc:create(function() --回调
					if self.repeat_tip_callback then 
						self.repeat_tip_callback()
					end
				end)
		))))
	action:setTag(self.finger_tag)
end

--停止手指提示（可以使用之前的启动方法的无参数方式进行重新开启）
function TipsFinger:stopTip()
	Log("stop_tip", tostring(self))
	self:setVisible(false)
	self:stopActionByTag(self.finger_tag)
end

-- 功能：左右翻转
function TipsFinger:FlipFinger(flip_flag)
	local scale = self:getScaleX()
	if scale < 0 then scale = -scale end
	if flip_flag then
		self:setScaleX(-1 * scale)
	else
		self:setScaleX(scale)
	end
end

return TipsFinger