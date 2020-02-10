--[[
一个“计时器”定时器的功能
]]--
----------------------------------------[必备]----------------------------------------
local TimeUtility = class("TimeUtility", function(...)
		return cc.Node:create()
	end
)
g_tConfigTable.CREATE_NEW(TimeUtility);
local function Log( ... )
	--print("[TimeUtility]--------------", ...)
end

----------------------------------------[结构必备]----------------------------------------
--
	--参数：
	--	@parent：顶层节点，这个方法会将其绑定到该节点之下
--
function TimeUtility:ctor(parent)
	-- 数据
	self.delay_time	= 1.0	--延时启动
	self.gap_time	= 1.0	--每一次计时之间的时间间隔
	self.wait_time	= 0.5	--拖动到目的以后停顿的时间
	self.time_callback	= nil	--单次循环结束回调
	self.tip_tag = 111 -- tip的ActionTag
	--后续如果需要拓展在这里拓展就好了
	--self:setVisible(false)--本来就不含可视内容
	parent:addChild(self)
end


--功能：根据是否需要延迟创建对应的Action
function TimeUtility:getActionByDelayTime(action)
	if self.delay_time == 0 then
		return action
	else
		--Sequence中不能包含RepeatForever，所以需要重新用一个CallFunc包装一次传过来的action
		action:retain()--如果没有立刻使用，需要临时存储，则需要使用一次retain以及在使用后使用release()确保对象不会被删除
		return cc.Sequence:create(
			cc.DelayTime:create(self.delay_time),
			cc.CallFunc:create(function()
				self:runAction(action)
				action:release()
				action:setTag(self.tip_tag)
			end))
	end
end

--功能：开启（使用新的配置或者继续上次的配置）
function TimeUtility:start(delay_time, gap_time, repeat_tip_callback)
	-- 1.初始化数据
	if nil ~= delay_time then self.delay_time = delay_time end
	if nil ~= gap_time then self.gap_time = gap_time end
	if nil ~= repeat_tip_callback then self.repeat_tip_callback = repeat_tip_callback end
	if 0 >= self.delay_time then
		self.delay_time = 0.01
	end
	Log(self:getName(), "start[self, delay_time, gap_time]", tostring(self), self.delay_time, self.gap_time)
	-- 2.计时效果
	-- 开启新的
	local repeat_action = cc.RepeatForever:create(cc.Sequence:create(
		cc.CallFunc:create(function()
			if self.repeat_tip_callback then
				self.repeat_tip_callback()
			end
		end),--callfunc
		cc.DelayTime:create(self.gap_time)
		))
	local action = self:runAction(self:getActionByDelayTime(repeat_action))
	action:setTag(self.tip_tag)
end

function TimeUtility:stop()
	Log(self:getName(), "stop_tip", tostring(self))
	self:stopActionByTag(self.tip_tag)
end

return TimeUtility