
-- ==========================================
-- 配置区：80级保命物品优先级列表
-- 将你想用的物品按优先级从高到低排列
-- ==========================================
local Mage_Survival_Items = {
    -- [优先级 1] 术士的糖 (不占药水CD，优先吃)
    "邪能治疗石",       -- WotLK 80级 术士糖 (回血最多)
    "大师级治疗石",     -- 70级 糖 (备用)

    -- [优先级 2] 炼金/工程专用 (无限使用或特殊效果)
    "无尽治疗药水",     -- 炼金师专用 (无限喝，回血量中等)
    "治疗注射器",       -- 工程学专用 (回血，不占公用CD，如果你是工程)
    "疯狂炼金师药水",   -- 炼金师专用 (随机效果，包含回血)

    -- [优先级 3] 常规药水 (WotLK 标准)
    "符文治疗药水",     -- 80级 顶级红药 (回 2700-4500)
    "符文法力药水",     -- (如果你想在这里顺便判断蓝药，也可以加，但建议分开)

    -- [优先级 4] 低级/备用药水 (TBC/旧世剩余)
    "超级治疗药水",     -- 70级 红药
    "强效治疗药水",     -- 60级 红药
}

function Mage_playerSelectSelf()
    if not UnitExists("target") then return true; end
    if UnitCanAttack("player","target") then return true; end
    if UnitIsUnit("target", "player") then return true; end
    return false;
end


function Mage_playerSafe()
    -- 圣盾术判断逻辑
    if Mage_GetUnitHealthPercent("player") < 20 and UnitAffectingCombat("player") then
--         if not Mage_PlayerDeBU("自律") and Mage_GetSpellCooldown("圣盾术") == 0 then
--              if Mage_CastSpell("圣盾术") then return true; end;
--         end
    end

    if Mage_GetUnitHealthPercent("player") < 20 and UnitAffectingCombat("player") and not Mage_Test_Battlefield() and not Mage_PlayerBU("圣盾术") then
        -- 检测防抖定时器 (防止瞬间重复按键)
        if GetTimer("PotionRecovery") < 0.2 or GetTimer("PotionRecovery") > 3 then
            for _, itemName in ipairs(Mage_Survival_Items) do
               if Mage_FindItemInBag(itemName) and Mage_IsItemReady(itemName) then
                  if Mage_CastSpell(itemName) then StartTimer("PotionRecovery"); return true; end;
              end
           end
       end
    end



    if Mage_HasSpell("霜甲术") and not Mage_PlayerBU("霜甲术") then
      if Mage_CastSpell("霜甲术") then return true; end;
    end

    if Mage_HasSpell("奥术智慧") and not Mage_PlayerBU("奥术智慧") and not Mage_PlayerBU("奥术智慧") then
        if Mage_CastSpell("奥术智慧") then return true; end;
    end


   if UnitAffectingCombat("player") then
        if Mage_HasSpell("神启") and Mage_GetSpellCooldown("神启") == 0 and Mage_CheckPartyLowHealth() and not Mage_PlayerBU("神启") then
            if Mage_CastSpell("神启") then return true; end;
        end
         if Mage_PlayerBU("神圣恳求") and not Mage_IsPartyHealthSafe() then
            if Mage_CancelAuraPlea() then return true; end;
        end
        if Mage_IsTargetLegacyBoss() or Mage_CheckPartyLowHealth() then
            if Mage_HasSpell("复仇之怒") and Mage_GetSpellCooldown("复仇之怒") == 0 and not Mage_PlayerBU("复仇之怒") then
                if Mage_CastSpell("复仇之怒") then return true; end;
            end
        end
    else
          if Mage_HasSpell("神圣恳求") and Mage_GetSpellCooldown("神圣恳求") == 0 and Mage_GetUnitManaPercent("player") < 90 then
              if Mage_CastSpell("神圣恳求") then return true; end;
          end
    end
	return false;
end


-- 检测小队所有成员（包括自己）血量是否都在 95% 以上
-- 返回: true (全员安全/满血), false (有人血量低于等于 95%)
function Mage_IsPartyHealthSafe()
    -- 1. 先检查自己
    if Mage_GetUnitHealthPercent("player") <= 90 then
        return false
    end
    for i = 1, 4 do
        local unit = "party" .. i
        if UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) and UnitIsVisible(unit) and IsSpellInRange("圣光术",unit) == 1 then
            if Mage_GetUnitHealthPercent(unit) <= 90 then
                return false
            end
        end
    end
    return true
end

-- ============================================================
-- 函数: 检查小队(包括自己)是否有超过2人血量低于75%
-- 返回值: true (满足条件, 至少3人危急), false (不满足)
-- ============================================================
function Mage_CheckPartyLowHealth()
    local lowHealthCount = 0
    local threshold = 75 -- 75% 血量阈值
    local unitsToCheck = {"player", "party1", "party2", "party3", "party4"}
    for _, unit in pairs(unitsToCheck) do
        if UnitExists(unit) then
            if not UnitIsDeadOrGhost(unit) and UnitIsConnected(unit) then
                if Mage_GetUnitManaPercent(unit) < threshold then
                    lowHealthCount = lowHealthCount + 1;
                end
                if Mage_GetUnitManaPercent(unit) < 30 then
                    lowHealthCount = lowHealthCount + 2; -- 额外计数
                end
            end
        end
    end
    if lowHealthCount > 2 then
        return true
    end
    return false
end
