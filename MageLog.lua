
Mage_Settings = nil;

-- 定义敌对单位的掩码
local HOSTILE_FLAG = 0x00000040

-- ======================================================
-- 近战攻击者统计 (8秒窗口)
-- ======================================================
local meleeAttackers = {} -- 格式: { [GUID] = 最后攻击时间戳 }
local MELEE_WINDOW = 5    -- n秒窗口

-- 辅助函数: 计算当前8秒内有多少个单位在对你进行近战攻击
function Mage_GetActiveMeleeCount()
    local now = GetTime()
    local count = 0

    for guid, lastTime in pairs(meleeAttackers) do
        if (now - lastTime) <= MELEE_WINDOW then
            count = count + 1
        else
            -- 超过8秒没打过你，从表中移除（清理垃圾数据）
            meleeAttackers[guid] = nil
        end
    end
    return count
end
-- ======================================================



if UnitClass("player") == "法师" then
    -- 创建插件的主框架
    local frame = CreateFrame("Frame")
    local playerGUID = UnitGUID("player")

    -- 变量初始化
    local totalDamage = 0
    local combatStartTime = 0
    local isInCombat = false

    -- 注册事件
    frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("UI_ERROR_MESSAGE")


    -- 辅助函数：是否敌对
    local function IsHostile(flags)
        if not flags then return false end
        return bit.band(flags, HOSTILE_FLAG) > 0
    end

    -- 辅助函数：格式化数字
    local function formatNumber(num)
        if num >= 10000 then return string.format("%.1fk", num / 1000) else return num end
    end

    -- 核心处理函数
    local function OnEvent(self, event, ...)
        -- 1. 进出战斗 (DPS统计)
        if event == "PLAYER_REGEN_DISABLED" then
            totalDamage = 0
            combatStartTime = GetTime()
            isInCombat = true
            return
        elseif event == "PLAYER_REGEN_ENABLED" then
            if isInCombat then
                local duration = GetTime() - combatStartTime
                if duration < 1 then duration = 1 end
                local dps = totalDamage / duration
                if totalDamage > 0 then
                    if Mage_Get_CombatLogMode() then
                        Mage_AddMessage(string.format("|cff00ff00[统计]|r 战斗结束. 秒伤: %.1f", dps))
                    end
                end
            end
            isInCombat = false
            return
        elseif event == "UI_ERROR_MESSAGE" then
              local arg1, arg2 = ...
              if arg2 == "目标不在视野中" then
                 StartTimer("FAILED_LINE_OF_SIGHT")
                 Blizzard_AddMessage("**视野遮档，无法施法**", 1, 0, 0, "crit")
                 Mage_SendFollowNotifyMessage("视野遮档，无法施法")
                 if UnitExists("target") and not UnitCanAttack("player","target") then
                     StartTimer(UnitName("target").."_FAILED_LINE_OF_SIGHT");
                     Mage_SendChatMessage("视野遮档，无法给" .. UnitName("target").. "施放治疗法术", UnitName("target"));
                 end
             elseif arg2 == "你必须面对目标" then
                 StartTimer("YOU_MUST_FACE_THE_GOAL")
                 Blizzard_AddMessage("**你必须面对目标，无法施法**", 1, 0, 0, "crit")
                 Mage_SendFollowNotifyMessage("你必须面对目标，无法施法")
             end
            return
        end

        -- 2. 战斗日志分析
        if event == "COMBAT_LOG_EVENT_UNFILTERED" then
            local timestamp, subevent, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, _, _, arg12, arg13, arg14, arg15, arg16, arg17, arg18 = CombatLogGetCurrentEventInfo()
            -- --------------------------------------------------
            -- 逻辑 A: 监控附近【所有敌对单位】的施法
            -- --------------------------------------------------
            if IsHostile(sourceFlags) and sourceGUID ~= playerGUID then
                local enemyName = sourceName or "未知敌人"
                if subevent == "SPELL_CAST_START" then
                    if Mage_Get_CombatLogMode() then
    --                     Mage_AddMessage(string.format("|cffFF4500[读条]|r %s 正在释放 >> %s <<", enemyName, arg13))
                    end
                elseif subevent == "SPELL_CAST_SUCCESS" then
                    if Mage_Get_CombatLogMode() then
    --                     Mage_AddMessage(string.format("|cff00FFFF[瞬发]|r %s 使用了 [%s]", enemyName, arg13))
                    end
                end
            end

            -- --------------------------------------------------
            -- 逻辑 B & D: 玩家自己的动作 (伤害 + 治疗分析)
            -- --------------------------------------------------
            if sourceGUID == playerGUID then

                -- [DPS统计]
                if subevent == "SWING_DAMAGE" then totalDamage = totalDamage + arg12
                elseif subevent == "SPELL_DAMAGE" or subevent == "RANGE_DAMAGE" then totalDamage = totalDamage + arg15 end

                -- [免疫检测]
                if subevent == "SWING_MISSED" or subevent == "SPELL_MISSED" or subevent == "RANGE_MISSED" then
                    local missType = (subevent == "SWING_MISSED") and arg12 or arg15
                    local spellName = (subevent == "SWING_MISSED") and "普通攻击" or arg13
                    if missType == "IMMUNE" then
                        if Mage_Get_CombatLogMode() then
                            Mage_AddMessage(string.format("|cffFF00FF[无效]|r %s 免疫了你的 <%s> !", destName or "目标", spellName))
                        end
                      local g_FindNpcName = false;
                      for k, v in pairs(Mage_SaveData) do
                          if v["npcname"] == destName and  v["spellname"] == spellName then
                         g_FindNpcName = true;
                          end
                      end
                      if not g_FindNpcName then
                          table.insert(Mage_SaveData,{["npcname"] = destName,["spellname"] = spellName,});
                      end;
                    end
                end
            end

            -- --------------------------------------------------
            -- 逻辑 C: 承伤监控 + n秒近战单位计数
            -- --------------------------------------------------
            if destGUID == playerGUID then
                local inAmount = 0
                local enemyName = sourceName or "未知"

                -- >>> 新增逻辑: 只有是 SWING_DAMAGE (近战平砍) 时才更新攻击者列表 <<<
                if subevent == "SWING_DAMAGE" then
                    inAmount = arg12
                    -- 记录该怪物的攻击时间
                    meleeAttackers[sourceGUID] = GetTime()

                elseif subevent == "SPELL_DAMAGE" then inAmount = arg15
                elseif subevent == "ENVIRONMENTAL_DAMAGE" then inAmount = arg13 end

                if inAmount > 0 then
                    -- 获取当前的围攻数量 (自动清理8秒前的数据)
                    local attackerCount = Mage_GetActiveMeleeCount()

                    -- 如果是近战伤害，在后面显示 [围攻: N]
                    local extraInfo = ""
                    if subevent == "SWING_DAMAGE" then
                        -- 颜色区分: 1-2个怪白色，3个以上橙色警告
                        if attackerCount >= 3 then
                            extraInfo = string.format(" |cffFF4500[围攻:%d]|r", attackerCount)
                        else
                            extraInfo = string.format(" [围攻:%d]", attackerCount)
                        end
                    end
                    if Mage_Get_CombatLogMode() then
                         Mage_AddMessage(string.format("|cffff0000[承伤]|r %s: -%d%s", enemyName, inAmount, extraInfo))
                    end
                end
            end
        end
    end

    frame:SetScript("OnEvent", OnEvent)


end
