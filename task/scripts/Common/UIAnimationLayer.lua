local UIAnimation = requirePack("scripts.Common.UIAnimation")
local Json = requirePack("scripts.Common.Dkjson")
----------------------------------------[Lua必备]----------------------------------------
local UIAnimationLayer = class("UIAnimationLayer", function(...)
	return cc.Node:create()
end
)
g_tConfigTable.CREATE_NEW(UIAnimationLayer);
local function Log( ... )
print("[UIAnimationLayer]--------------", ...)
end
local MAX_WIDTH_RATIO = 4/3--最宽比率
local MAX_HEIGHT_RATIO = 2436/1125--最长比率，目前用的ipx作为最长，
local Tag_Action = 1111
----------------------------------------[结构必备]----------------------------------------
function UIAnimationLayer:ctor(json, audio_path)
	----------[数据]----------
	self._audio_path = audio_path
	self._event_json = {}
	self._json = json
	if json then
		self._json_npc = json.layers
		self._frame_time = 1 / json.common.frameRate
	else
		self._json_npc = nil
		self._frame_time = 1 / 24
	end
	----------[可视化]----------
	--1.场景层
	if json and json.sceneInfo then
		self:setContentSize(json.sceneInfo.width, json.sceneInfo.height)
	else
		self:setContentSize(768, 1024)
	end
	self:setAnchorPoint(cc.p(0.5,0.5))
	self:setPosition(cc.p(g_tConfigTable.winSize.width * 0.5, g_tConfigTable.winSize.height * 0.5))--屏幕中心
	--2.UI
	if nil == self._json_npc then
		return
	end
	self._ui = {}
	for k,v in pairs(self._json_npc) do
		--Log(v.layername)
		if "event" == v.framestype then
			--无操作
		elseif "sound" == v.framestype then
			--无操作
		elseif "camera" == v.layername then
			--无操作
		elseif "element" == v.framestype then
			local size = nil
			if v.contentSize then
				size = cc.size(v.contentSize[1],v.contentSize[2])
			end
			local delta_pos = nil
			if v.deltaPos then
				delta_pos = cc.p(v.deltaPos[1], v.deltaPos[2])
			else
				delta_pos = cc.p(0,0)
			end
			self._ui[v.layername] = UIAnimation.new(self:getArmName(v.frames), size, delta_pos, self._audio_path)
			self._ui[v.layername]:setName(v.layername)
			self._ui[v.layername]:init(v.frames)
			self._ui[v.layername]:setFrameTime(self._frame_time)--依据帧率设计事件
			self:addChild(self._ui[v.layername])
		else
			Log("check?")
		end
	end
	--3.事件节点
	self._event = {}
	--4.音频节点
	self._audio = {}
end
----------------------------------------[适配方案]----------------------------------------
------------------------------[无极动态适配]------------------------------
--单个方向在两套极端方案中自动调整
function UIAnimationLayer:setBasicUIRatioByRange(max_width_ratio, max_height_ratio)
	--0.初始化
	if nil == max_width_ratio then max_width_ratio = MAX_WIDTH_RATIO end
	if nil == max_height_ratio then max_height_ratio = MAX_HEIGHT_RATIO end
	--1.适配因子[0,1]，用于乘法计算
	local size = g_tConfigTable.winSize
	self._screen_ratio = size.height / size.width
	--Log("screen_ratio", self._screen_ratio)
	local screen_ratio_basic = 16 / 9 --基准比率
	if math.abs(self._screen_ratio - screen_ratio_basic) < 0.001 then
		--两者基本一致，视为基准
		self._width_delta_ratio, self._height_delta_ratio = 0,0--[0,1]
		self._screen_ratio = screen_ratio_basic
	elseif self._screen_ratio < screen_ratio_basic then--宽屏
		local gap = max_width_ratio * 9 - 9--计算以16为基准高度以后，宽的间距比率(4/3)*9 - 9 -> 12 - 9 -> 3
		self._width_delta_ratio = ((screen_ratio_basic / self._screen_ratio) * 9 - 9) / gap
		self._height_delta_ratio = 0
	else --长屏
		--以下公式以21:9的为最长
		local gap = max_height_ratio * 9 - 16--计算以9为基准宽度以后，宽的间距比率('21'/9)*9 - 16 -> '21' - 16 -> 5
		self._width_delta_ratio = 0
		self._height_delta_ratio = ((self._screen_ratio / screen_ratio_basic) * 16 - 16) / gap
	end
	local inside = function(val)
		if val < 0 then 
			return 0
		elseif val > 1 then
			return 1
		else
			return val
		end
	end
	self._width_delta_ratio = inside(self._width_delta_ratio)
	self._height_delta_ratio = inside(self._height_delta_ratio)
end
function UIAnimationLayer:getAdaptWidthPercentage()
	return self._width_delta_ratio
end
function UIAnimationLayer:getAdaptHeightPercentage()
	return self._height_delta_ratio
end
------------------------------[阈值动态适配]------------------------------
--单个方向只有两套方案。 ratio 一般为16/9或16/10
function UIAnimationLayer:setBasicUIRatio(ratio)
	local size = g_tConfigTable.winSize
	local delta = ratio - size.height / size.width
	if math.abs(delta) < 0.001 then --基本没差别，认为就是标准方案
		self._flag_width, self._flag_height = false, false
	elseif delta > 0 then--宽屏方案
		self._flag_width, self._flag_height = true, false
	else--既然不是标准不是宽屏，那就是长屏
		self._flag_width, self._flag_height = false, true
	end
end
function UIAnimationLayer:setBasicUIRatioWidth(ratio)
	local size = g_tConfigTable.winSize
	local delta = ratio - size.height / size.width
	if delta > 0.001 then --宽屏方案
		self._flag_width = true
	else--基本没差别，认为就是标准方案
		self._flag_width = false
	end
end
function UIAnimationLayer:setBasicUIRatioHeight(ratio)
	local size = g_tConfigTable.winSize
	local delta = size.height / size.width - ratio
	if delta > 0.001 then--长屏方案
		self._flag_height = true
	else--基本没差别，认为就是标准方案
		self._flag_height = false
	end
end

function UIAnimationLayer:isAdaptWidth()
	return self._flag_width
end
function UIAnimationLayer:isAdaptHeight()
	return self._flag_height
end
------------------------------[布局]------------------------------
--设置偏移
function UIAnimationLayer:setDeltaPos(npc_name, delta_pos)
	local x,y = self._ui[npc_name]:getPosition()
	self._ui[npc_name]:setPosition(delta_pos.x + x, delta_pos.y + y)
end
--设置偏移
function UIAnimationLayer:setDeltaPosForAllArm(delta_pos)
	for k,v in pairs(self._ui) do
		local x,y = v:getPosition()
		v:setPosition(delta_pos.x + x, delta_pos.y + y)
	end
end

----------------------------------------[使用]----------------------------------------
------------------------------[初始化]------------------------------
--类似C++静态函数
UIAnimationLayer.parseJson = function(file_path)
	local json_p =  Json.parseFile(file_path)
	if nil == json_p.name then
		json_p.name = file_path--如果name属性不存在，则存入路径
	end
	return json_p
end
--辅助初始化的方法
function UIAnimationLayer:getArmName(json)
	for k,v in pairs(json) do
		if nil ~= v.einfo and nil ~= v.einfo.ename then
			return v.einfo.ename
		end
	end
	Log("Can't find Arm Name")
	dump(json)
	return ""
end
--初始化
function UIAnimationLayer:initUI(json)
	----------[数据]----------
	self._json = json
	self._json_npc = json.layers
	self._frame_time = 1 / json.common.frameRate
	----------[可视化]----------
	for k,v in pairs(self._json_npc) do
		--Log(v.layername)
		if "event" == v.framestype then
			--无操作
		elseif "sound" == v.framestype then
			--无操作
		elseif "camera" == v.layername then
			--无操作
		elseif "element" == v.framestype then
			self._ui[v.layername]:setStatus(v.frames)
		else
			Log("check?")
		end
	end
end
------------------------------[运行]------------------------------
function UIAnimationLayer:playStory(json, callback, event_callback)
	----------[数据]----------
	if json then
		self._json = json
		self._json_npc = json.layers
	end
	self._finish_callback = callback
	self._event_callback = event_callback
	self._event_json = {}--事件的json配置
	self._event_step = {}--事件的步骤

	self._audio_json = {}--同理
	self._audio_step = {}
	self._sound_path = {}
	----------[可视化]----------
	if self._json.name then
		Log("Play[name]", self._json.name)
	end
	local event_index = 1
	local audio_index = 1
	local audio_npc_name = {}
	for k,v in pairs(self._json_npc) do
		if "event" == v.framestype then
			--如果没有则创建节点
			if nil == self._event[event_index] then
				self._event[event_index] = cc.Node:create()
				self:addChild(self._event[event_index])
			end
			--事件插入
			self._event_json[event_index] = v.frames
			self._event_step[event_index] = 1
			event_index = event_index + 1--逐个增加
		elseif "sound" == v.framestype then
			--同理
			if nil == self._audio[audio_index] then
				self._audio[audio_index] = cc.Node:create()
				self:addChild(self._audio[audio_index])
			end
			local npc_name = "say_" == string.sub(v.layername, 1, 4) and "npc_" .. string.sub(v.layername, 5) or nil--"say_xx从xx开始"
			audio_npc_name[audio_index] = npc_name
			self._audio[audio_index].speak_npc = nil--暂时置为空

			self._audio_json[audio_index] = v.frames
			self._audio_step[audio_index] = 1
			audio_index = audio_index + 1
		elseif "camera" == v.layername then
			--无操作
		elseif "element" == v.framestype then
			self._ui[v.layername]:startAction(v.frames)
		else
			Log("check?")
		end
	end
	----------[事件监听]----------
	for i, event in ipairs(self._event) do
		event:stopActionByTag(Tag_Action)
		if self._event_json[i] then--各自开始自己的事件循环
			self:eventAction(i)
		end
	end
	if 1 == event_index then--如果没有event则直接一个倒计时
		if nil == self._event[1] then
			self._event[1] = cc.Node:create()
			self:addChild(self._event[1])
		end
		local action = self._event[1]:runAction(cc.Sequence:create(
			cc.DelayTime:create(json.common.totalDuration * self._frame_time),
			cc.CallFunc:create(function()
				if self._finish_callback then
					self._finish_callback()
				end
			end)))
		action:setTag(Tag_Action)
	end
	----------[音频]----------
	for i, audio in ipairs(self._audio) do
		audio:stopActionByTag(Tag_Action)--启动前都要暂停

		if self._audio_json[i] then--各自开始自己的事件循环
			if audio_npc_name[i] then
				audio.speak_npc = self._ui[audio_npc_name[i]]
				Log(audio_npc_name[i], audio.speak_npc)
			end
			self:audioAction(i)
		end
	end
end

function UIAnimationLayer:eventAction(index)
	----------[结束]----------
	if self._event_step[index] > #self._event_json[index] then
		local delay_func = function()
			if 1 == index and self._finish_callback then--避免多个EventNode都触发结束事件
				self._finish_callback()
			end
		end
		performWithDelay(self, delay_func, 0.1)
		return 
	end
	----------[未结束]----------
	local now = self._event_json[index][self._event_step[index]]
	local time = now.dt * self._frame_time
	--Log("event_step", self._event_step, "/", #self._event_json, "-----", now.dt, "---------", now.frameid)
	if now.eventname and self._event_callback then
		self._event_callback(now.eventname)--发送事件
	end
	----------[播放效果]----------
	local action = self._event[index]:runAction(cc.Sequence:create(
		cc.DelayTime:create(time),
		cc.CallFunc:create(function()
			self._event_step[index]  = self._event_step[index] + 1
			self:eventAction(index)
		end)))
	action:setTag(Tag_Action)
end
function UIAnimationLayer:audioAction(index)
	----------[结束]----------
	if self._audio_step[index] > #self._audio_json[index] then
		return 
	end
	----------[未结束]----------
	local now = self._audio_json[index][self._audio_step[index]]
	local time = now.dt * self._frame_time
	if now.name then
		--播放音频
		UIAnimationLayer:stopAudio(self._sound_path[index], self._audio[index].speak_npc)
		if now.name == "nickname.mp3" and Utils:GetInstance():hasNickname() then
			self._sound_path[index] = SoundUtil:getInstance():getbabynamepath() --self.scriptAction_:GetAudioResPath()..data.name;
		else
			self._sound_path[index] = self._audio_path .. now.name
		end
		self:playAudio(self._sound_path[index],function()
			if self then
				self._sound_path[index] = self:stopAudio(self._sound_path[index], self._audio[index].speak_npc)
			end
		end, self._audio[index].speak_npc)
	end
	----------[播放效果]----------
	local action = self._audio[index]:runAction(cc.Sequence:create(
		cc.DelayTime:create(time),
		cc.CallFunc:create(function()
			self._audio_step[index]  = self._audio_step[index] + 1
			self:audioAction(index)
		end)))
	action:setTag(Tag_Action)
end
function UIAnimationLayer:stopAudio(audio, npc)
	if audio then
		SoundUtil:getInstance():stop(audio)--停掉原来的
	end
	if npc then
		npc:mouse(false)
	end
	return nil
end
function UIAnimationLayer:playAudio(audio, callback, npc)
	if audio then
		SoundUtil:getInstance():playLua(audio, audio, callback)--停掉原来的
	end
	if npc then
		npc:mouse(true)
	end
end
function UIAnimationLayer:stopStory()
	----------[事件监听]----------
	for i, event in ipairs(self._event) do
		event:stopActionByTag(Tag_Action)
	end
	----------[音频]----------
	for i, audio in ipairs(self._audio) do
		self:stopAudio(self._sound_path[i], self._audio[i].speak_npc)
		audio:stopActionByTag(Tag_Action)--停掉行为
	end
end

function UIAnimationLayer:adaptEvent(event_name)
	local event = g_tConfigTable.stringSplit(event_name, "_")
	if "adapt" == event[1] then
		event[3] = tonumber(event[3]) * self._frame_time
		return event
	else
		return false
	end
end

return UIAnimationLayer