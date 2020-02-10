local JsonScriptUtil = requirePack("scripts.Utils.JsonScriptUtil");

local JAManager = class("JAManager",function()
    return {};
end);
g_tConfigTable.CREATE_NEW(JAManager);

JAManager.MAX_ACTION_LEVEL = 10000;

function JAManager:ctor()
    self.stageNode_ = nil;
    self.runningAction_ = nil;
end

function JAManager:createActionAtLevel(level)
    local action = {};
    action.level = level;
    return action;
end

function JAManager:markActionRunningAtLevel(level)
    self.runningAction_ = self:createActionAtLevel(level);
end

function JAManager:markActionStop()
    self.runningAction_ = nil;
end


function JAManager:PlayBgConfig(jsonName,cb)
    if self.stageNode_ ~= nil then 
        self:stopAllAction();
        JsonScriptUtil.PlayBgConfig(
            self.stageNode_,
            jsonName,
            function(eventName)
                print("bgconfigDone:"..eventName);
                if eventName == "Complie" or eventName == "Interupt" or eventName == "InternalINterupt" then 
                    self:markActionStop();
                end
                if eventName ~=  "Interupt" or eventName ~= "InternalINterupt"  then 
                    if cb ~= nil then 
                        cb(eventName);
                    end
                end
            end
        );
        self:markActionRunningAtLevel(JAManager.MAX_ACTION_LEVEL);
    end
end

function JAManager:play(jsonName,cb,level)
    print("playAction ------------------:"..jsonName);
    JsonScriptUtil.PlayAction(self.stageNode_,jsonName,function(eventName) 
        print("eventName:"..eventName);
        if eventName == "Complie" or eventName == "Interupt" or eventName == "InternalINterupt" then 
            self:markActionStop();
        end
        if eventName ~=  "Interupt" or eventName ~= "InternalINterupt"  then 
            if cb ~= nil then 
                cb(eventName);
            end
        end


    end);
    self:markActionRunningAtLevel(level);
end

function JAManager:stopAllAction()
    if self.stageNode_ ~= nil then 
        JsonScriptUtil.StopAllAction(self.stageNode_);
    end
end

function JAManager:Play(jsonName,cb,level)
    print("jsonName:" .. jsonName .. "level:" .. level );
   -- if  self.runningAction_ ~= nil then 
   --     dump(self.runningAction_);
   -- end
    if self.stageNode_ ~= nil then 
        if self.runningAction_ == nil then 
            -- todo just play
            self:play(jsonName,cb,level);
            print("success1");
        else
            local runningLevel = self.runningAction_.level;
            if level >= runningLevel then 
                 -- todo stop now action
                 self:stopAllAction();
                 -- todo play action
                 self:play(jsonName,cb,level);
                 print("success2");

            else
                print("fail");
            end
        end
    end
end


function JAManager:SetStageNode(n)
    self.stageNode_ = n;
end

function JAManager:Dispose()
    self:stopAllAction();
    JsonScriptUtil.IsBanPlay = true;
end

return JAManager;