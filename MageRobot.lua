Mage_Robot_Hit = "关闭机器人模式"

local Mage_IsRobotMode = false; --是否为机器人模式





-- 插件会自动尝试这些名字，哪个有ID就用哪个
local channelList = {
    "大脚世界频道",
    "大脚世界频道1",
    "大脚世界频道2",
    "大脚世界频道3",
    "大脚世界频道4",
    "大脚世界频道5",
    "大脚世界频道6",
    "大脚世界频道7",
}

-- ========================================================
-- 自动世界频道喊话函数 (3分钟一次)
-- ========================================================
function Mage_AutoAnnounce()
    -- 1. 在这里设置你的喊话内容
    local message = "死骑<爆鸡兽>,MS<落魄山丶崔巉>,FS<黑狗子>,随机乱踢人,奶骑需了法伤板甲,也要踢人,大家注意避坑！"

      -- 3. 检查定时器 (180秒 = 3分钟)
      if GetTimer("AutoWorldShout") > 120 then
          local targetId = 0
          local targetName = ""
          -- 遍历列表，寻找已加入的频道
          for _, name in ipairs(channelList) do
              local id, _ = GetChannelName(name)
              if id and id > 0 then
                  targetId = id
                  targetName = name
                  break -- 找到了就跳出循环
              end
          end

          -- 发送消息
          if targetId > 0 then
              SendChatMessage(message, "CHANNEL", nil, targetId)
              -- 提示信息 (调试用，告诉你最终发到了哪个频道)
              Mage_Default_AddMessage("已向 [" .. targetId .. ". " .. targetName .. "] 发送喊话。")
          else
              -- 如果都没找到，尝试加入大脚世界频道 (可选)
              -- JoinPermanentChannel("大脚世界频道")
              Mage_Default_AddMessage("错误：未找到合适的世界频道，无法喊话。")
          end
          -- 重置定时器
          StartTimer("AutoWorldShout")
      end
end


function Mage_Robot_OnUpdate()

--     Mage_AutoAnnounce();

    if UnitClass("player") ~= "法师" then
		HideUIPanel(MageRobotBtn);
		return 
	end

    if Mage_IsRobotMode then
		if not MageRobotBtn:GetChecked() then
	        MageRobotBtn:SetChecked(true)
		end
	else
		if MageRobotBtn:GetChecked() then
	        MageRobotBtn:SetChecked(false)
		end
    end
end

function Mage_Get_RobotMode()
	return Mage_IsRobotMode;
end	

function Mage_Robot()
	if Mage_Get_RobotMode() and not UnitAffectingCombat("player") then
		if GetTimer("Robot") < 0.5 then
			Mage_SetText("跳跃",200);
			return true;
		end;
		if GetTimer("Robot") > 20 then
			Mage_SetText("跳跃",200);
			StartTimer("Robot");
			return true;
		end
	end
	return false;
end	
	 
function Mage_Robot_fun()
	 if Mage_IsRobotMode then
		Mage_IsRobotMode = false;
		Blizzard_AddMessage("**关闭机器人模式**",1,0,0,"crit");
		Mage_Default_AddMessage("**关闭机器人模式**");
		Mage_Robot_Hit = "关闭机器人模式";
		MageTooltip:SetText(Mage_Robot_Hit);
	 else
		Mage_IsRobotMode = true;
		Blizzard_AddMessage("**打开机器人模式**",1,0,0,"crit");
		Mage_Default_AddMessage("**打开机器人模式**");
		Mage_Robot_Hit = "机器人模式";
		MageTooltip:SetText(Mage_Robot_Hit);
	 end
end


-- 核心处理事件
local function OnRobotEvent(self, event, ...)
    -- 1. 进出战斗
    if event == "PLAYER_REGEN_DISABLED" then

        return
    elseif event == "PLAYER_REGEN_ENABLED" then
    end
end

-- 核心处理函数
function Mage_RobotUpdate()

    if not Mage_Get_RobotMode() then return; end;
    if not UnitAffectingCombat("player") then
        if not Mage_Test_Battlefield() then

--             /run for i=1,10 do if GetBattlefieldStatus(i)=="confirm" then AcceptBattlefieldPort(i,1) StaticPopup1:Hide() return end end
--             /run if GossipFrame:IsShown() then SelectGossipOption(1) endw
--             /run if BattlefieldFrame:IsShown() then JoinBattlefield(0) end

--             if not IsPlayerInQueue() then
--                 if GetTimer("Target_Battlefield_Officer") < 0.5 then
--                    if Mage_Target_Battlefield_Officer() then return true; end;
--                     return true;
--                 end;
--                 if GetTimer("Target_Battlefield_Officer") > 10 then
--                    if Mage_Target_Battlefield_Officer() then return true; end;
--                     StartTimer("Target_Battlefield_Officer");
--                     return true;
--                 end
--             else
--
--             end
        end
    else

    end
    return false;
end




function Mage_IsPlayerInQueue()
    -- 遍历所有可能的排队槽位 (通常是 3 个)
    -- MAX_BATTLEFIELD_QUEUES 是系统常量
    for i = 1, MAX_BATTLEFIELD_QUEUES or 3 do
        local status, mapName, instanceID, levelRange, minPlayers, maxPlayers = GetBattlefieldStatus(i)
        -- status 的可能值:
        -- "none"      : 空闲
        -- "queued"    : 排队中 (我们要找的状态)
        -- "confirm"   : 已经排进去了，等待点击进入 (这也算排队中)
        -- "active"    : 已经在战场里了
        if status == "queued" or status == "confirm" then
            return true, mapName
        end
    end

    return false, nil
end

if UnitClass("player") == "法师" then
    -- ======================================================
    -- 创建插件的主框架
    local Mage_robot_frame = CreateFrame("Frame")

    -- 注册事件
    Mage_robot_frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    Mage_robot_frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    Mage_robot_frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    Mage_robot_frame:RegisterEvent("UI_ERROR_MESSAGE")
    Mage_robot_frame:SetScript("OnEvent", OnRobotEvent)
end